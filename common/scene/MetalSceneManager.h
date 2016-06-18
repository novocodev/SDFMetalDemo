//
//  SceneManager.h
//  voĉo
//
//  Created by Andrew Reslan on 23/05/2016.
//  Copyright © 2016 Novoĉo. All rights reserved.
//

#ifndef SceneManager_h
#define SceneManager_h

@import simd;
@import Metal;
@import MetalKit;

#import "Scene.h"


@interface MetalSceneManager : NSObject <SceneDelegate>

- (instancetype) initWithDevice: (_Nonnull id<MTLDevice>)device;

//- (instancetype) initScene:(Scene *)scene withView: (MTKView * _Nonnull)view;

- (void) renderSourceTexture:(id<MTLTexture>)sourceTexture
        destinationTexture:(id<MTLTexture>)destinationTexture inView:(MTKView *) view toDrawable: (id <MTLDrawable>)drawable;
        
- (void) setupScene: (Scene *)scene;

- (void) hitTestWithPoint: (CGPoint) point inView:(MTKView *) view initialViewScale:(float) initialViewScale;

@end

#endif /* SceneManager_h */
