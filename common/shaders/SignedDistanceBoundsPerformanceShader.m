//
//  SignedDistanceBoundsPerformanceShader.m
//  voĉo
//  Copyright © 2016 Novoĉo. All rights reserved.
//

#import "SignedDistanceBoundsPerformanceShader.h"

//const NSString *kComputeKernelName = @"signed_distance_bounds";
//const NSString *kHitTestKernelName = @"signed_distance_bounds_hit_test";

@interface SignedDistanceBoundsPerformanceShader ()
{
	id<MTLDevice> _device;
	id<MTLBuffer> _uniformBuffer;
    id<MTLComputePipelineState> _computePipeline;
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

- (void) updatePipeline:(id<MTLComputePipelineState>) computePipeline hitPipeline:(id<MTLComputePipelineState>) hitPipeline {
    _computePipeline = computePipeline;
    _hitPipeline = hitPipeline;
}
    
- (void) uniformBuffer:(const void *)buffer bufferSize:(NSInteger )size {
    const unsigned int length_pagealigned = (size/4096 +1)*4096;
	_uniformBuffer = [_device newBufferWithBytesNoCopy:buffer length:length_pagealigned options:MTLResourceCPUCacheModeDefaultCache deallocator:nil];
}
    

- (NSString *) kernelName {
	return _kernelName;
}

- (void) encodeToCommandBuffer:(id<MTLCommandBuffer>)commandBuffer
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
#ifdef DEBUG
	[commandEncoder pushDebugGroup:@"Dispatch signed distance bounds kernel"];
#endif
	[commandEncoder setComputePipelineState:_computePipeline];
	[commandEncoder setTexture:destinationTexture atIndex:0];
	[commandEncoder setBuffer:_uniformBuffer offset:0 atIndex:0];
	[commandEncoder dispatchThreadgroups:threadgroupsPerGrid threadsPerThreadgroup:threadsPerThreadgroup];
#ifdef DEBUG
	[commandEncoder popDebugGroup];
#endif
	[commandEncoder endEncoding];
}

- (void)encodeToCommandBuffer:(_Nonnull id<MTLCommandBuffer>)commandBuffer
        touches:(Touches) touches touchCount: (unsigned long) touchCount hits: (Hits *) hits {
        
	MTLSize threadsPerThreadgroup = MTLSizeMake(touchCount, 1, 1);
	MTLSize threadgroupsPerGrid = MTLSizeMake(1, 1, 1);
    
    //NSLog(@"touch.x = %u",touch.touchPointX);
    //NSLog(@"touch.y = %u",touch.touchPointY);
    //NSLog(@"touch.viewWidth = %f",touch.viewWidth);
    //NSLog(@"touch.viewHeight = %f",touch.viewHeight);
	
	const unsigned int length_pagealigned = (sizeof(Hits)/4096 +1)*4096;
	
	id<MTLBuffer> _hitsBuffer = [_device newBufferWithBytesNoCopy:hits length:length_pagealigned options:MTLResourceCPUCacheModeDefaultCache deallocator:nil];
	
	id<MTLComputeCommandEncoder> commandEncoder = [commandBuffer computeCommandEncoder];
#ifdef DEBUG
	[commandEncoder pushDebugGroup:@"Dispatch signed distance bounds hit test kernel"];
#endif
	[commandEncoder setComputePipelineState:_hitPipeline];
	[commandEncoder setBuffer:_uniformBuffer offset:0 atIndex:0];
    [commandEncoder setBytes:&touches length:sizeof(Touches) atIndex:1];
	[commandEncoder setBuffer:_hitsBuffer offset:0 atIndex:2];
	[commandEncoder dispatchThreadgroups:threadgroupsPerGrid threadsPerThreadgroup:threadsPerThreadgroup];
#ifdef DEBUG
	[commandEncoder popDebugGroup];
#endif
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
