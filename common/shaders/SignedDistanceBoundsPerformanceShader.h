
@import Metal;
@import CoreGraphics;

#import "Scene.h"
#import <Foundation/Foundation.h>


typedef struct SDFTouch {
    uint touchPointX;
    uint touchPointY;
    float viewWidth;
    float viewHeight;
} SDFTouch;


typedef struct SDFHit {
    bool  isHit;
    float hitPointX;
    float hitPointY;
    float hitPointZ;
    uint  hitNodeId;
} SDFHit;


@interface SignedDistanceBoundsPerformanceShader : NSObject


- (_Nonnull instancetype) initWithDevice:(_Nonnull id<MTLDevice>)device;

- (void) updatePipeline:(id<MTLComputePipelineState>) computePipeline hitPipeline:(id<MTLComputePipelineState>) hitPipeline;


- (NSString *) kernelName;

- (void) uniformBuffer:(const void *)buffer bufferSize:(NSInteger )size;

- (void)encodeToCommandBuffer:(_Nonnull id<MTLCommandBuffer>)commandBuffer
           destinationTexture:(_Nonnull id<MTLTexture>)destinationTexture;

- (void)encodeToCommandBuffer:(_Nonnull id<MTLCommandBuffer>)commandBuffer
                      touches:(SDFTouch) point hits: (SDFHit *) hit;

@property (nonatomic, assign) float deviceAttitudePitch;
@property (nonatomic, assign) float deviceAttitudeRoll;
@property (nonatomic, assign) float deviceAttitudeYaw;

@end
