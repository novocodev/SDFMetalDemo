//
//  SceneMananger.m
//  voĉo
//  Copyright © 2016 Novoĉo. All rights reserved.
//

#import "MetalSceneManager.h"
#import "SignedDistanceBoundsPerformanceShader.h"
#import "Stack.h"
#ifndef TARGET_IOS
#import "MTKView+ContentScaleFactor.h"
#endif
@implementation MetalSceneManager
{
	dispatch_queue_t _clientRequestQueue;
	dispatch_queue_t _shaderJITQueue;
	id<MTLDevice> _device;
	id<MTLCommandQueue> _metalCommandQueue;
	SignedDistanceBoundsPerformanceShader *_sdf;
	Scene *_currentScene;
	float _mediaStartTime;
	void *_uniformBuffer;
    NSString *_template;
}


- (instancetype) initWithDevice: (_Nonnull id<MTLDevice>)device {
	if (self = [super init])
	{
		_device = device;
		_clientRequestQueue = dispatch_queue_create("vo.co.sp.client.request", DISPATCH_QUEUE_SERIAL);
		_shaderJITQueue = dispatch_queue_create("vo.co.sp.shader.jit", DISPATCH_QUEUE_SERIAL);
		
		[self setupMetal];
		
		[self setupBuffer];
		
		[self setupShader];
        
        NSString *pathToTemplate = [[NSBundle mainBundle] pathForResource:@"static-sdb-template-metal-shader" ofType:@"tpl"];
        
        _template = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:pathToTemplate] encoding:NSUTF8StringEncoding];
	}
	return self;
}

- (void)setupMetal {
	// Create a new command queue.
	_metalCommandQueue = [_device newCommandQueue];
}

- (void)setupBuffer {
	const unsigned int length_pagealigned = (sizeof(SDFScene)/4096 +1)*4096;
    
    _uniformBuffer = valloc(length_pagealigned);
}


- (void) setupShader {
	_sdf = [[SignedDistanceBoundsPerformanceShader alloc] initWithDevice:_device];
}

- (void) setupScene: (Scene *)scene {
	//Add to client request queue
	dispatch_async(_clientRequestQueue, ^{
		_currentScene = scene;
        _currentScene.delegate = self;
		_mediaStartTime = CACurrentMediaTime();
		NSError *error;
		
        [scene setupScene:_uniformBuffer];
        
        NSString *func = [self generateStaticSDFFunc:_uniformBuffer];
        NSString *source;
        @autoreleasepool {
            source = [NSString stringWithFormat:_template, func];
        }

        id <MTLLibrary> library = [_device newLibraryWithSource:source options:nil error:&error];
        
        if(error != nil) {
            NSLog(@"library error = %@",error);
        }
        
        [ _sdf useKernel:[@"static_" stringByAppendingString:_currentScene.kernelName] fromLibrary:library uniformBuffer:_uniformBuffer error:&error];
		
		NSLog(@"Scene setup for kernel %@",_currentScene.kernelName);
	});
}

- (void) renderSourceTexture:(id<MTLTexture>)sourceTexture
        destinationTexture:(id<MTLTexture>)destinationTexture inView:(MTKView *) view toDrawable: (id <MTLDrawable>)drawable {
	//Occasionally we get width/height of 0/0 or drawable nil which causes the kernel to throw an error
	//catch here and skip this frame
	if(destinationTexture.width == 0 || destinationTexture.height == 0 || drawable == nil) {
		return;
	}
	
	//Add to client request queue
	dispatch_sync(_clientRequestQueue, ^{

        BOOL updatedSceneContent = [_currentScene updateScene:_uniformBuffer atMediaTime:(CACurrentMediaTime() - _mediaStartTime)];
        
		// Create a new command buffer for each renderpass to the current drawable.
		id<MTLCommandBuffer> commandBuffer = [_metalCommandQueue commandBuffer];
		
		[_sdf encodeToCommandBuffer:commandBuffer sourceTexture:sourceTexture destinationTexture:destinationTexture];
		
		// Schedule a present using the current drawable.
		[commandBuffer presentDrawable:drawable];
		
		// Finalize command buffer.
		[commandBuffer commit];
		
		//Block until the render is complete so we can read out the hits
		[commandBuffer waitUntilCompleted];
	});
}


- (void) hitTestWithPoint: (CGPoint) point inView:(MTKView *) view initialViewScale:(float) initialViewScale {
//Add to client request queue

	if (!_currentScene.supportsPicking) {
		return;
	}
	dispatch_sync(_clientRequestQueue, ^{

        SDFTouch touch;

        touch.touchPointX = point.x / view.frame.size.width * view.currentDrawable.texture.width;
        touch.touchPointY = point.y / view.frame.size.height * view.currentDrawable.texture.height;
        touch.viewWidth = view.currentDrawable.texture.width;
        touch.viewHeight = view.currentDrawable.texture.height;
        
		// Create a new command buffer for each renderpass to the current drawable.
		id<MTLCommandBuffer> commandBuffer = [_metalCommandQueue commandBuffer];
		
		struct SDFHit *hit;
		
		const unsigned int length_pagealigned = (sizeof(hit)/4096 +1)*4096;
		
		void *hbuffer = valloc(length_pagealigned);
		
		hit = hbuffer;
		
		[_sdf encodeToCommandBuffer:commandBuffer touches:touch hits: hit];
        
		// Finalize command buffer.
		[commandBuffer commit];
		
		//Block until the hit test is complete so we can read out the hits
		[commandBuffer waitUntilCompleted];
		
		//Now Read Out hit data
		//NSLog(@"Hit isHit = %i",hit->isHit);
		//NSLog(@"Hit hitDistance = %f",hit->hitPointX);
		//NSLog(@"Hit hitNodeId = %u",hit->hitNodeId);
		
		if(hit->isHit) {
            [_currentScene nodeSelected:hit->hitNodeId inScene: _uniformBuffer];
		}
		
	});
	
}


- (NSString *) generateStaticSDFFunc: (SDFScene *) scene {
	
    NSMutableString *mutableFuncBody = [NSMutableString new];
	
	   uint nodeCount = scene->nodeCount;
	   
	   Stack *ds = [[Stack alloc] init];
	   
	   for(uint i=0; i<nodeCount; i++) {
	    struct SDFNode currNode = scene->nodes[i];
	    
	    switch (currNode.type) {
	        case fPlaneType:
	        {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"vec2 res%i = vec2(fPlane(pos, vec3(%f,%f,%f),%f),%i);\n",i,currNode.floats[9],currNode.floats[10],currNode.floats[11],currNode.floats[12],i]];
                [ds push:[NSString stringWithFormat:@"res%i",i]];
	        }
	        break;
	        case fSphereType:
	        {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"vec2 res%i = vec2(fSphere(pos, %f),%i);\n",i,currNode.floats[9],i]];
                
                //[mutableFuncBody appendString:[NSString stringWithFormat:@"vec2 res%i = vec2(fSphere(pos, scene.nodes[%i].floats[9]),%i);\n",i,i,i]];
                [ds push:[NSString stringWithFormat:@"res%i",i]];
	        }
	        break;
	        
	        case fBoxCheapType:
	        {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"vec2 res%i = vec2(fBoxCheap(pos, vec3(%f,%f,%f)),%i);\n",i,currNode.floats[9],currNode.floats[10],currNode.floats[11],i]];
                [ds push:[NSString stringWithFormat:@"res%i",i]];
	        }
	        break;
            case fOctahedronType:
            {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"vec2 res%i = vec2(fOctahedron(pos,%f),%i);\n",i,currNode.floats[9],i]];
                [ds push:[NSString stringWithFormat:@"res%i",i]];
            }
            break;
            case fEllipsoidType:
            {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"vec2 res%i = vec2(fEllipsoid(pos, vec3(%f,%f,%f)),%i);\n",i,currNode.floats[9],currNode.floats[10],currNode.floats[11],i]];
                [ds push:[NSString stringWithFormat:@"res%i",i]];
            }
                break;
            case fBlobType:
            {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"vec2 res%i = vec2(fBlob(pos),%i);\n",i,i]];
                [ds push:[NSString stringWithFormat:@"res%i",i]];
            }
                break;
	        case pUnionType:
	        {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"res = pU(%@,%@);\n",[ds pop], [ds pop]]];
                [ds push:@"res"];
	        }
	        break;
	        case pSubtractionType:
	        {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"res = pS(%@,%@,%i);\n",[ds pop], [ds pop], i]];
                [ds push:@"res"];
	        }
	        break;
	        case pModOffsetType:
	        {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"pModOffset(pos, vec3(%f,%f,%f))\n;",currNode.floats[0],currNode.floats[1],currNode.floats[2]]];
	        }
	        break;
	        case pModPolarType:
	        {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"cell = pModPolar(pos,0,2,%f);\n",currNode.floats[0]]];
	            
	        }
	        break;
            case pMod3Type:
            {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"cells3 = pMod3(pos,vec3(%f,%f,%f));\n",currNode.floats[0],currNode.floats[1],currNode.floats[2]]];
            }
            break;
	        case pModResetType:
	        {
                [mutableFuncBody appendString:@"pos = origPos;\n"];
                [mutableFuncBody appendString:@"cell = 0;\n"];
	        }
	        break;
	        default:
	        {
	            //push(ds, vec2{10000000000.0,-1.0});
	        }
	    }
	    
	   }

	return mutableFuncBody;
}

#pragma SceneDelegate
    
    - (void)sceneDidUpdate:(Scene *)scene {

        dispatch_async(_clientRequestQueue, ^{
            @autoreleasepool {
                
                //TODO: ?
                //BOOL updatedSceneContent = [_currentScene updateScene:_uniformBuffer atMediaTime:(CACurrentMediaTime() - _mediaStartTime)];
                 
                 //if(updatedSceneContent) {
                 //dispatch_async(_shaderJITQueue, ^{

                 //Build a shader and compile it
                 //Then push it back onto the client request queue to replace
                 //the dynamic shader
                 
                 NSString *func = [self generateStaticSDFFunc:_uniformBuffer];
                
                NSString *shader;
                
                @autoreleasepool {
                  shader = [NSString stringWithFormat:_template, func];
                }
                NSError *error;
                @autoreleasepool {
                    id <MTLLibrary> library = [_device newLibraryWithSource:[NSString stringWithString:shader] options:nil error:&error];
                    if(error == nil) {
                        NSError *error;
                 
                        [ _sdf useKernel:[@"static_" stringByAppendingString:_currentScene.kernelName] fromLibrary:library uniformBuffer:_uniformBuffer error:&error];
                    }
                }
            }
            
        });
    }


@end

