
@import Metal;
@import CoreGraphics;

#import "Scene.h"
#import <Foundation/Foundation.h>


@interface SignedDistanceBoundsPerformanceShader : NSObject


- (_Nonnull instancetype) initWithDevice:(_Nonnull id<MTLDevice>)device;

- (void) updatePipeline:(id<MTLComputePipelineState>) computePipeline hitPipeline:(id<MTLComputePipelineState>) hitPipeline;


- (NSString *) kernelName;

- (void) uniformBuffer:(const void *)buffer bufferSize:(NSInteger )size;

- (void)encodeToCommandBuffer:(_Nonnull id<MTLCommandBuffer>)commandBuffer
           destinationTexture:(_Nonnull id<MTLTexture>)destinationTexture;

- (void)encodeToCommandBuffer:(_Nonnull id<MTLCommandBuffer>)commandBuffer
                      touches:(Touches) touches touchCount: (unsigned long) touchCount hits: (Hits *) hits;

@property (nonatomic, assign) float deviceAttitudePitch;
@property (nonatomic, assign) float deviceAttitudeRoll;
@property (nonatomic, assign) float deviceAttitudeYaw;

@end
