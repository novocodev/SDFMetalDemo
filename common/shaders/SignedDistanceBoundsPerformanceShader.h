//
//  SignedDistanceBoundsPerformanceShader.h
//  voĉo
//
//  Created by Andrew Reslan on 13/05/2016.
//  Copyright © 2016 Novoĉo. All rights reserved.
//

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


@interface SignedDistanceBoundsPerformanceShader : NSObject //: MPSUnaryImageKernel


- (_Nonnull instancetype) initWithDevice:(_Nonnull id<MTLDevice>)device;

//- (void) useKernel:(NSString * _Nonnull)kernelName kernelUniformBuffer:(void *)buffer error:(__autoreleasing NSError ** _Nullable)error;

- (void) useKernel:(NSString * _Nonnull)kernelName fromLibrary:(id<MTLLibrary>) library uniformBuffer:(void *)uniformBuffer error:(__autoreleasing NSError ** _Nullable)error;


- (NSString *) kernelName;

- (void) uniformBuffer:(const void *)buffer bufferSize:(NSInteger )size;

- (void)encodeToCommandBuffer:(_Nonnull id<MTLCommandBuffer>)commandBuffer
                sourceTexture:(_Nonnull id<MTLTexture>)sourceTexture
           destinationTexture:(_Nonnull id<MTLTexture>)destinationTexture;

- (void)encodeToCommandBuffer:(_Nonnull id<MTLCommandBuffer>)commandBuffer
                      touches:(SDFTouch) point hits: (SDFHit *) hit;

/*
- (BOOL)encodeToCommandBuffer:(_Nonnull id<MTLCommandBuffer>)commandBuffer
               inPlaceTexture:(_Nonnull id<MTLTexture>  * _Nonnull)texture
        fallbackCopyAllocator:(_Nullable MPSCopyAllocator)copyAllocator;
*/


@property (nonatomic, assign) float deviceAttitudePitch;
@property (nonatomic, assign) float deviceAttitudeRoll;
@property (nonatomic, assign) float deviceAttitudeYaw;

@end
