//
//  SignedDistanceBoundsPerformanceShader.m
//  voĉo
//  Copyright © 2016 Novoĉo. All rights reserved.
//

#import "SignedDistanceBoundsPerformanceShader.h"

@interface SignedDistanceBoundsPerformanceShader ()
{
	id<MTLDevice> _device;
	id<MTLBuffer> _uniformBuffer;
	id<MTLFunction> _computeFunction;
	id<MTLFunction> _hitFunction;
	id<MTLComputePipelineState> _pipeline;
	id<MTLComputePipelineState> _hitPipeline;
	id<MTLSamplerState> _sampler;
	float _destinationTextureWidth;
	float _destinationTextureHeight;
	
	NSString *_kernelName;
}
@end

@implementation SignedDistanceBoundsPerformanceShader

- (instancetype) initWithDevice:(id<MTLDevice>)device {
	if ((self = [super init]))
	{
		_device = device;
	}
	
	return self;
}


- (void) useKernel:(NSString * _Nonnull)kernelName fromLibrary:(id<MTLLibrary>) library uniformBuffer:(void *)uniformBuffer error:(__autoreleasing NSError ** _Nullable)error {
   
    NSLog(@"useKernel() called with kernelName = %@",kernelName);
    _kernelName = kernelName;
    
    _computeFunction = [library newFunctionWithName:kernelName];
    
    _hitFunction = [library newFunctionWithName:[kernelName stringByAppendingString:@"_hit_test"]];

    _pipeline = [_device newComputePipelineStateWithFunction:_computeFunction error:error];
    
    _hitPipeline = [_device newComputePipelineStateWithFunction:_hitFunction error:error];

    [self uniformBuffer:uniformBuffer bufferSize:sizeof(struct SDFScene)];
    
    //[self uniformBuffer:uniformBuffer bufferSize:sizeof(struct SDFUniforms)];
    
    if (!_pipeline)
    {
        NSLog(@"Error occurred when building compute pipeline for function %@", kernelName);
    }
}
    
    
- (void) uniformBuffer:(const void *)buffer bufferSize:(NSInteger )size {
    
    const unsigned int length_pagealigned = (size/4096 +1)*4096;
	_uniformBuffer = [_device newBufferWithBytesNoCopy:buffer length:length_pagealigned options:MTLResourceCPUCacheModeDefaultCache deallocator:nil];

}
    

- (NSString *) kernelName {
	return _kernelName;
}

- (void) encodeToCommandBuffer:(id<MTLCommandBuffer>)commandBuffer
        sourceTexture:(id<MTLTexture>)sourceTexture
        destinationTexture:(id<MTLTexture>)destinationTexture {
	// We choose a fixed thread per threadgroup count here out of convenience, but could possibly
	// be more efficient by using a non-square threadgroup pattern like 32x16 or 16x32
	MTLSize threadsPerThreadgroup = MTLSizeMake(16, 16, 1);
	
	_destinationTextureWidth = destinationTexture.width;
	_destinationTextureHeight = destinationTexture.height;
	
	MTLRegion destRect = [self clippedToSize: MTLSizeMake(destinationTexture.width, destinationTexture.height, 0)];
	
	// Determine how many threadgroups we need to dispatch to fully cover the destination region
	// There will almost certainly be some wasted threads except when both textures are neat
	// multiples of the thread-per-threadgroup size and the offset and clip region are agreeable.
	unsigned long widthInThreadgroups = (destRect.size.width + threadsPerThreadgroup.width - 1) / threadsPerThreadgroup.width;
	unsigned long heightInThreadgroups = (destRect.size.height + threadsPerThreadgroup.height - 1) / threadsPerThreadgroup.height;
	MTLSize threadgroupsPerGrid = MTLSizeMake(widthInThreadgroups, heightInThreadgroups, 1);
	
	
	id<MTLComputeCommandEncoder> commandEncoder = [commandBuffer computeCommandEncoder];
	//[commandEncoder pushDebugGroup:@"Dispatch signed distance bounds kernel"];
	[commandEncoder setComputePipelineState:_pipeline];
	[commandEncoder setTexture:destinationTexture atIndex:0];
	[commandEncoder setBuffer:_uniformBuffer offset:0 atIndex:0];
	[commandEncoder dispatchThreadgroups:threadgroupsPerGrid threadsPerThreadgroup:threadsPerThreadgroup];
	//[commandEncoder popDebugGroup];
	[commandEncoder endEncoding];
}

- (void)encodeToCommandBuffer:(_Nonnull id<MTLCommandBuffer>)commandBuffer
        touches:(SDFTouch) touch hits: (struct SDFHit *) hit {
        
	MTLSize threadsPerThreadgroup = MTLSizeMake(1, 1, 1);
	MTLSize threadgroupsPerGrid = MTLSizeMake(1, 1, 1);
    
    NSLog(@"touch.x = %u",touch.touchPointX);
    NSLog(@"touch.y = %u",touch.touchPointY);
    NSLog(@"touch.viewWidth = %f",touch.viewWidth);
    NSLog(@"touch.viewHeight = %f",touch.viewHeight);
    
	
	id<MTLBuffer> _touchesBuffer = [_device newBufferWithBytes:&touch length:sizeof(SDFTouch) options:MTLResourceCPUCacheModeDefaultCache];
	
	const unsigned int length_pagealigned = (sizeof(SDFHit)/4096 +1)*4096;
	
	id<MTLBuffer> _hitsBuffer = [_device newBufferWithBytesNoCopy:hit length:length_pagealigned options:MTLResourceCPUCacheModeDefaultCache deallocator:nil];
	
	id<MTLComputeCommandEncoder> commandEncoder = [commandBuffer computeCommandEncoder];
	//[commandEncoder pushDebugGroup:@"Dispatch signed distance bounds hit test kernel"];
	[commandEncoder setComputePipelineState:_hitPipeline];
	[commandEncoder setBuffer:_uniformBuffer offset:0 atIndex:0];
	[commandEncoder setBuffer:_touchesBuffer offset:0 atIndex:1];
	[commandEncoder setBuffer:_hitsBuffer offset:0 atIndex:2];
	[commandEncoder dispatchThreadgroups:threadgroupsPerGrid threadsPerThreadgroup:threadsPerThreadgroup];
	//[commandEncoder popDebugGroup];
	[commandEncoder endEncoding];
}

- (BOOL) origin:(MTLOrigin)a equalToOrigin:(MTLOrigin)b {
	return a.x == b.x && a.y == b.y && a.z == b.z;
}

- (BOOL)  size:(MTLSize)a equalToSize:(MTLSize) b {
	return a.width == b.width && a.height == b.height && a.depth == b.depth;
}

/// Returns true iff two regions compare as member-wise equal
- (BOOL)  region:(MTLRegion)a equalToRegion:(MTLRegion)b {
	return [self origin: a.origin equalToOrigin:b.origin] && [self size: a.size equalToSize: b.size];
}

/// Reshapes the provided region so it fits in a region with the provided size
//- (MTLRegion) region:(MTLRegion)region  clippedToSize:(MTLSize) size {
- (MTLRegion) clippedToSize:(MTLSize) size {
	return MTLRegionMake3D(0, 0, 0, size.width, size.height, size.depth);
}




@end
