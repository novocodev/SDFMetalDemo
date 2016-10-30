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

const NSString *kComputeKernelName = @"signed_distance_bounds";
const NSString *kHitTestKernelName = @"signed_distance_bounds_hit_test";
const int kMaxPointsCount = 32;

@implementation MetalSceneManager
{
	dispatch_queue_t _clientRequestQueue;
	dispatch_queue_t _shaderJITQueue;
    dispatch_queue_t _computePipelineCreateQueue;
	id<MTLDevice> _device;
    id <MTLLibrary> _library;
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
        _computePipelineCreateQueue = dispatch_queue_create("vo.co.sp.cpc", DISPATCH_QUEUE_CONCURRENT);
		
		[self setupMetal];
		
		[self setupBuffer];
		
		[self setupShader];
        
        NSString *pathToTemplate = [[NSBundle mainBundle] pathForResource:@"static-sdf-template-metal-shader" ofType:@"tpl"];
        
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
    [_sdf uniformBuffer:_uniformBuffer bufferSize:sizeof(struct SDFUniforms)];
}

- (void) setupScene: (Scene *)scene {
	//Add to client request queue
	dispatch_sync(_clientRequestQueue, ^{
		_currentScene = scene;
        _currentScene.delegate = self;
		_mediaStartTime = CACurrentMediaTime();
        [scene setupScene:_uniformBuffer];
        
        dispatch_sync(_shaderJITQueue , ^{
            [self compileAndPushShader: scene];
        });
	});
}

- (void) renderToTexture:(id<MTLTexture>)texture inView:(MTKView *) view toDrawable: (id <MTLDrawable>)drawable {
	//Add to client request queue
	dispatch_sync(_clientRequestQueue, ^{
        [_currentScene updateScene:_uniformBuffer atMediaTime:(CACurrentMediaTime() - _mediaStartTime)];
        
		// Create a new command buffer for each renderpass to the current drawable.
		id<MTLCommandBuffer> commandBuffer = [_metalCommandQueue commandBuffer];
		
		[_sdf encodeToCommandBuffer:commandBuffer destinationTexture:texture];
		
		// Schedule a present using the current drawable.
		[commandBuffer presentDrawable:drawable];
		
		// Finalize command buffer.
		[commandBuffer commit];
		
		//Block until the render is complete so we can read out the hits
		[commandBuffer waitUntilCompleted];
	});
}


- (void) hitTestWithPoints: (NSMutableArray <NSValue *> *)points inView:(MTKView *) view initialViewScale:(float) initialViewScale {
    
	if (!_currentScene.supportsPicking) {
		return;
	}
	dispatch_async(_clientRequestQueue, ^{

        Touches touches;

        touches.viewWidth = view.currentDrawable.texture.width;
        touches.viewHeight = view.currentDrawable.texture.height;
        
        unsigned long pointsCount = points.count <= kMaxPointsCount ? points.count : kMaxPointsCount;
        
        for (int i=0; i<pointsCount; i++) {
#ifdef TARGET_IOS
            CGPoint point = points[i].CGPointValue;
#else
            CGPoint point = points[i].pointValue;
#endif
            touches.touches[i].touchPointX = point.x / view.frame.size.width * view.currentDrawable.texture.width;
            touches.touches[i].touchPointY = point.y / view.frame.size.height * view.currentDrawable.texture.height;
        }
		// Create a new command buffer for each renderpass to the current drawable.
		id<MTLCommandBuffer> commandBuffer = [_metalCommandQueue commandBuffer];
        
        struct Hits *hits;
        
        const unsigned int length_pagealigned = (sizeof(Hits)/4096 +1)*4096;
        
        void *hbuffer = valloc(length_pagealigned);
        
        hits = hbuffer;
        
        [_sdf encodeToCommandBuffer:commandBuffer touches:touches touchCount:pointsCount hits: hits];

		[commandBuffer commit];
		
		//Block until the hit test is complete so we can read out the hits
		[commandBuffer waitUntilCompleted];
        
        NSMutableArray <NSValue *> *confirmedHits = [[NSMutableArray alloc] init];
        
        for (int i=0; i<pointsCount; i++) {
            if(hits->hits[i].isHit) {
                NSValue *value = [NSValue valueWithBytes:&hits->hits[i] objCType:@encode(SDFHit)];
                [confirmedHits addObject:value];
            }
        }
		[_currentScene nodesSelected:confirmedHits inScene: _uniformBuffer];
	});
	
}

- (NSInteger) shaderMaterialsCount:(SDFScene *) scene {
    return scene->materialCount;
}

- (NSString *) generateShaderMaterials:(SDFScene *) scene {
    
    NSMutableString *mutableMaterialsList = [NSMutableString new];
    
    for(int i = 0; i < scene->materialCount; i++) {
        
        SDFMaterial mat = scene->materials[i];
        
        [mutableMaterialsList appendString: @"{\n"];
        [mutableMaterialsList appendString: [NSString stringWithFormat:@"vec3 (%f,%f,%f),\n",mat.ambient[0], mat.ambient[1], mat.ambient[2]]];
        [mutableMaterialsList appendString: [NSString stringWithFormat:@"vec3 (%f,%f,%f),\n",mat.diffuse[0], mat.diffuse[1], mat.diffuse[2]]];
        [mutableMaterialsList appendString: [NSString stringWithFormat:@"vec3 (%f,%f,%f),\n",mat.specular[0], mat.specular[1], mat.specular[2]]];
        [mutableMaterialsList appendString: [NSString stringWithFormat:@"vec3 (%f,%f,%f),\n",mat.reflect[0], mat.reflect[1], mat.reflect[2]]];
        [mutableMaterialsList appendString: [NSString stringWithFormat:@"vec3 (%f,%f,%f),\n",mat.bac[0], mat.bac[1], mat.bac[2]]];
        [mutableMaterialsList appendString: [NSString stringWithFormat:@"vec3 (%f,%f,%f)\n",mat.frensel[0], mat.frensel[1], mat.frensel[2]]];
        [mutableMaterialsList appendString: @"}"];
        if(i < scene->materialCount-1) {
            [mutableMaterialsList appendString: @",\n"];
        }
    }
    
    return mutableMaterialsList;
}

- (NSString *) generateStaticSDFFunc: (SDFScene *) scene {
	
    NSMutableString *mutableFuncBody = [NSMutableString new];
	
	   uint nodeCount = scene->nodeCount;
	   
	   Stack *ds = [[Stack alloc] init];
	   
	   for(uint i=0; i<nodeCount; i++) {
	    struct SDFNode currNode = scene->nodes[i];
	    
	    switch (currNode.type) {
            case fLineSegmentType:
            {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"vec3 res%i = vec3(fCapsule(tempPos, vec3(%f,%f,%f),vec3(%f,%f,%f),%f),%i,%f);\n",i,currNode.floats[9],currNode.floats[10],currNode.floats[11],currNode.floats[12],currNode.floats[13],currNode.floats[14],currNode.floats[15],i,currNode.materialId]];
                [ds push:[NSString stringWithFormat:@"res%i",i]];
            }
            break;
	        case fPlaneType:
	        {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"vec3 res%i = vec3(fPlane(tempPos, vec3(%f,%f,%f),%f),%i,%f);\n",i,currNode.floats[9],currNode.floats[10],currNode.floats[11],currNode.floats[12],i,currNode.materialId]];
                [ds push:[NSString stringWithFormat:@"res%i",i]];
	        }
	        break;
	        case fSphereType:
	        {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"vec3 res%i = vec3(fSphere(tempPos, %f),%i,%f);\n",i,currNode.floats[9],i,currNode.materialId]];
                [ds push:[NSString stringWithFormat:@"res%i",i]];
	        }
	        break;
	        
	        case fBoxCheapType:
	        {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"vec3 res%i = vec3(fBoxCheap(tempPos, vec3(%f,%f,%f)),%i,%f);\n",i,currNode.floats[9],currNode.floats[10],currNode.floats[11],i,currNode.materialId]];
                [ds push:[NSString stringWithFormat:@"res%i",i]];
	        }
	        break;
            case fRoundBoxType:
            {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"vec3 res%i = vec3(fRoundBox(tempPos, vec3(%f,%f,%f),%f),%i,%f);\n",i,currNode.floats[9],currNode.floats[10],currNode.floats[11],currNode.floats[12],i,currNode.materialId]];
                [ds push:[NSString stringWithFormat:@"res%i",i]];
            }
            break;
            case fTorusType:
            {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"vec3 res%i = vec3(fTorus(tempPos, %f,%f),%i,%f);\n",i,currNode.floats[9],currNode.floats[10],i,currNode.materialId]];
                [ds push:[NSString stringWithFormat:@"res%i",i]];
            }
                break;
            case fCapsuleType:
            {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"vec3 res%i = vec3(fCapsule(tempPos, vec3(%f,%f,%f),vec3(%f,%f,%f),%f),%i,%f);\n",i,currNode.floats[9],currNode.floats[10],currNode.floats[11],currNode.floats[12],currNode.floats[13],currNode.floats[14],currNode.floats[15],i,currNode.materialId]];
                [ds push:[NSString stringWithFormat:@"res%i",i]];
            }
                break;
            case fTriPrismType:
            {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"vec3 res%i = vec3(fTriPrism(tempPos, vec2(%f,%f)),%i,%f);\n",i,currNode.floats[9],currNode.floats[10],i,currNode.materialId]];
                [ds push:[NSString stringWithFormat:@"res%i",i]];
            }
                break;
            case fCylinderType:
            {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"vec3 res%i = vec3(fCylinder(tempPos, %f,%f),%i,%f);\n",i,currNode.floats[9],currNode.floats[10],i,currNode.materialId]];
                [ds push:[NSString stringWithFormat:@"res%i",i]];
            }
                break;
                
            case fConeType:
            {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"vec3 res%i = vec3(fCone(tempPos, %f,%f),%i,%f);\n",i,currNode.floats[9],currNode.floats[10],i,currNode.materialId]];
                [ds push:[NSString stringWithFormat:@"res%i",i]];
            }
                break;
            case fTorus82Type:
            {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"vec3 res%i = vec3(fTorus82(tempPos, vec2(%f,%f)),%i,%f);\n",i,currNode.floats[9],currNode.floats[10],i,currNode.materialId]];
                [ds push:[NSString stringWithFormat:@"res%i",i]];
            }
                break;
            case fTorus88Type:
            {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"vec3 res%i = vec3(fTorus88(tempPos, vec2(%f,%f)),%i,%f);\n",i,currNode.floats[9],currNode.floats[10],i,currNode.materialId]];
                [ds push:[NSString stringWithFormat:@"res%i",i]];
            }
                break;
            case fCylinder6Type:
            {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"vec3 res%i = vec3(fCylinder6(tempPos, vec2(%f,%f)),%i,%f);\n",i,currNode.floats[9],currNode.floats[10],i,currNode.materialId]];
                [ds push:[NSString stringWithFormat:@"res%i",i]];
            }
                break;
            case fOctahedronType:
            {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"vec3 res%i = vec3(fOctahedron(tempPos,%f),%i,%f);\n",i,currNode.floats[9],i,currNode.materialId]];
                [ds push:[NSString stringWithFormat:@"res%i",i]];
            }
            break;
            case fEllipsoidType:
            {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"vec3 res%i = vec3(fEllipsoid(tempPos, vec3(%f,%f,%f)),%i,%f);\n",i,currNode.floats[9],currNode.floats[10],currNode.floats[11],i,currNode.materialId]];
                [ds push:[NSString stringWithFormat:@"res%i",i]];
            }
                break;
            case fHexagonIncircleType:
            {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"vec3 res%i = vec3(fHexagonIncircle(tempPos, vec2(%f,%f)),%i,%f);\n",i,currNode.floats[9],currNode.floats[10],i,currNode.materialId]];
                [ds push:[NSString stringWithFormat:@"res%i",i]];
            }
                break;
            case fBlobType:
            {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"vec3 res%i = vec3(fBlob(tempPos),%i,%f);\n",i,i,currNode.materialId]];
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
                if ([ds size] == 2) {
                    [mutableFuncBody appendString:[NSString stringWithFormat:@"res = pS(%@,%@);\n",[ds pop], [ds pop]]];
                    [ds push:@"res"];
                } else {
                    [mutableFuncBody appendString:[NSString stringWithFormat:@"vec3 res%i = pS(%@,%@);\n",i,[ds pop], [ds pop]]];
                    [ds push:[NSString stringWithFormat:@"res%i",i]];
                }
	        }
	        break;
	        case pModOffsetType:
	        {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"pModOffset(tempPos, vec3(%f,%f,%f))\n;",currNode.floats[0],currNode.floats[1],currNode.floats[2]]];
	        }
	        break;
            case pModRotateType:
            {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"pR(tempPos,%i,%i,%f)\n;",currNode.ints[0],currNode.ints[1],currNode.floats[0]]];
                //pR(thread vec3 &p, int axis1, int axis2, float a)
            }
                break;
	        case pModPolarType:
	        {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"cells = pModPolar(tempPos,%i,%i,%f);\n",currNode.ints[0],currNode.ints[1],currNode.floats[0]]];
	            
	        }
	        break;
            case pMod3Type:
            {
                [mutableFuncBody appendString:[NSString stringWithFormat:@"cells = pMod3(tempPos,vec3(%f,%f,%f));\n",currNode.floats[0],currNode.floats[1],currNode.floats[2]]];
            }
            break;
	        case pModResetType:
	        {
                [mutableFuncBody appendString:@"tempPos = pos;\n"];
                [mutableFuncBody appendString:@"cells = vec3(0.0);\n"];
	        }
	        break;
	        default:
	        {
	        }
	    }
	    
	   }

	return mutableFuncBody;
}

#pragma SceneDelegate
    
    - (void)sceneDidUpdate:(Scene *)scene {
        
        dispatch_async(_shaderJITQueue , ^{
            //[self compileAndPushShader: scene];
            [self updateMetalFunctions];
        });
    }

- (void) updateMetalFunctions {
    

    CFTimeInterval start = CACurrentMediaTime();
    
    const vector_float3 materials[24] = {
        {1.00,0.00,0.00},
        {0.50,0.00,000},
        {1.00,1.00,1.00},
        {1.00,1.00,1.00},
        {0.075,0.075,0.075},
        {0.40,0.40,0.40},
        
        {1.00,0.00,0.00},
        {0.50,0.00,000},
        {1.00,1.00,1.00},
        {1.00,1.00,1.00},
        {0.075,0.075,0.075},
        {0.40,0.40,0.40},
        
        {1.00,0.00,0.00},
        {0.50,0.00,000},
        {1.00,1.00,1.00},
        {1.00,1.00,1.00},
        {0.075,0.075,0.075},
        {0.40,0.40,0.40},
        
        {1.00,0.00,0.00},
        {0.50,0.00,000},
        {1.00,1.00,1.00},
        {1.00,1.00,1.00},
        {0.075,0.075,0.075},
        {0.40,0.40,0.40},
    };
    
    MTLFunctionConstantValues* constantValues = [MTLFunctionConstantValues new];
    
    NSRange range = NSMakeRange(0, 24);
    
    [constantValues setConstantValues:materials type:MTLDataTypeHalf3 withRange:range];
    
    dispatch_group_t group = dispatch_group_create();
    
    __block id<MTLComputePipelineState> computePipeline;
    
    dispatch_group_async(group,_computePipelineCreateQueue, ^ {
        NSError *deviceError;
        NSError *libraryError;
                computePipeline = [_device newComputePipelineStateWithFunction:[_library newFunctionWithName:kComputeKernelName constantValues: constantValues error: &libraryError] error:&deviceError];
        if (!computePipeline)
        {
            NSLog(@"Error occurred when building compute pipeline for function %@", kComputeKernelName);
        }
    });
    
    __block id<MTLComputePipelineState> hitPipeline;
    
    dispatch_group_async(group,_computePipelineCreateQueue, ^ {
        NSError *deviceError;
        NSError *libraryError;
        
        hitPipeline = [_device newComputePipelineStateWithFunction:[_library newFunctionWithName:kHitTestKernelName constantValues: constantValues error: &libraryError] error:&deviceError];
        if (!hitPipeline)
        {
            NSLog(@"Error occurred when building hit pipeline for function %@", kHitTestKernelName);
        }
    });
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    dispatch_async(_clientRequestQueue , ^{
        [_sdf updatePipeline:computePipeline hitPipeline:hitPipeline];
    });
    
    NSLog (@"New functions compiled in %f seconds",CACurrentMediaTime()-start);

}



- (void) compileAndPushShader:(Scene *)scene {

    NSLog(@"Compile and Push shader called");
    CFTimeInterval start = CACurrentMediaTime();
    
    NSInteger materialsCount = [self shaderMaterialsCount:_uniformBuffer];
    NSString *materials = [self generateShaderMaterials:_uniformBuffer];
    NSString *func = [self generateStaticSDFFunc:_uniformBuffer];

    NSString *source = [NSString stringWithFormat:_template, materialsCount, materials, func];
    
    MTLCompileOptions *options = [[MTLCompileOptions alloc] init];
    options.fastMathEnabled = YES;
    
    NSError *error;
    _library = [_device newLibraryWithSource:[NSString stringWithString:source] options:options error:&error];
    if(error != nil) {
        NSLog(@"library error = %@",error);
    }
    
    dispatch_group_t group = dispatch_group_create();
    
    __block id<MTLComputePipelineState> computePipeline;
    
    dispatch_group_async(group,_computePipelineCreateQueue, ^ {
        NSError *deviceError;
        NSError *libraryError;

        const vector_float3 materials[24] = {
            {1.00,0.00,0.00},
            {0.50,0.00,000},
            {1.00,1.00,1.00},
            {1.00,1.00,1.00},
            {0.075,0.075,0.075},
            {0.40,0.40,0.40},
    
            {0.00,1.00,0.00},
            {0.00,0.90,0.00},
            {1.00,1.00,1.00},
            {0.70,0.70,0.70},
            {0.25,0.25,0.25},
            {1.00,1.00,1.00},
        
            {0.00,0.00,1.00},
            {1.00,0.85,0.55},
            {0.00,0.00,1.00},
            {0.50,0.70,1.00},
            {0.25,0.25,0.25},
            {1.00,1.00,1.00},
        
            {1.00,1.00,0.00},
            {1.00,0.85,0.55},
            {1.00,1.00,0.00},
            {0.50,0.70,1.00},
            {0.25,0.25,0.25},
            {1.00,1.00,1.00}
        };
        

        MTLFunctionConstantValues* constantValues = [MTLFunctionConstantValues new];
        
        NSRange range = NSMakeRange(0, 24);
        
        [constantValues setConstantValues:materials type:MTLDataTypeHalf3 withRange:range];
        
        
        computePipeline = [_device newComputePipelineStateWithFunction:[_library newFunctionWithName:kComputeKernelName constantValues: constantValues error: &libraryError] error:&deviceError];
        
        if (!computePipeline)
        {
            NSLog(@"Error occurred when building compute pipeline for function %@", kComputeKernelName);
        }
    });
    
    __block id<MTLComputePipelineState> hitPipeline;
    
    dispatch_group_async(group,_computePipelineCreateQueue, ^ {
        NSError *deviceError;
        NSError *libraryError;
        
        const vector_float3 materials[24] = {
            {1.00,0.00,0.00},
            {0.50,0.00,000},
            {1.00,1.00,1.00},
            {1.00,1.00,1.00},
            {0.075,0.075,0.075},
            {0.40,0.40,0.40},
            
            {0.00,1.00,0.00},
            {0.00,0.90,0.00},
            {1.00,1.00,1.00},
            {0.70,0.70,0.70},
            {0.25,0.25,0.25},
            {1.00,1.00,1.00},
            
            {0.00,0.00,1.00},
            {1.00,0.85,0.55},
            {0.00,0.00,1.00},
            {0.50,0.70,1.00},
            {0.25,0.25,0.25},
            {1.00,1.00,1.00},
            
            {1.00,1.00,0.00},
            {1.00,0.85,0.55},
            {1.00,1.00,0.00},
            {0.50,0.70,1.00},
            {0.25,0.25,0.25},
            {1.00,1.00,1.00}
        };
        
        MTLFunctionConstantValues* constantValues = [MTLFunctionConstantValues new];
        
        NSRange range = NSMakeRange(0, 24);
        
        [constantValues setConstantValues:materials type:MTLDataTypeHalf3 withRange:range];

        
        hitPipeline = [_device newComputePipelineStateWithFunction:[_library newFunctionWithName:kHitTestKernelName constantValues: constantValues error: &libraryError] error:&deviceError];
        
        if (!hitPipeline)
        {
            NSLog(@"Error occurred when building hit pipeline for function %@", kHitTestKernelName);
        }
    });

    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        dispatch_async(_clientRequestQueue , ^{
            [_sdf updatePipeline:computePipeline hitPipeline:hitPipeline];
        });

}

@end

