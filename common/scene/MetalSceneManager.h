
#pragma once

@import simd;
@import MetalKit;

#import "Scene.h"


@interface MetalSceneManager : NSObject <SceneDelegate>

- (instancetype) initWithDevice: (_Nonnull id<MTLDevice>)device;

- (void) renderToTexture:(id<MTLTexture>)texture inView:(MTKView *) view toDrawable: (id <MTLDrawable>)drawable;
        
- (void) setupScene: (Scene *)scene;

- (void) hitTestWithPoints: (NSMutableArray <NSValue *> *)points inView:(MTKView *) view initialViewScale:(float) initialViewScale;

@end

