//
//  ViewController.m
//  voĉo-iOS
//
//  Created by Andrew Reslan on 25/05/2016.
//  Copyright © 2016 Novoĉo. All rights reserved.
//

@import Metal;
@import simd;
@import MetalPerformanceShaders;

#import "VocoViewController.h"
#import "MetalSceneManager.h"
#import "LaunchScene.h"
#import "PrimitivesScene.h"
#import "NewObjectModelScene.h"

@interface VocoViewController ()

// View.
@property (nonatomic, strong) MTKView *metalView;

// Source Texture.
@property (nonatomic, strong) id<MTLTexture> sourceTexture;
@end

@implementation VocoViewController
{
    MetalSceneManager *_sceneManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.metalView = (MTKView *)self.view;
    
    // Set the view to use the default device.
    self.metalView.device = MTLCreateSystemDefaultDevice();
    
    // Make sure the current device supports MetalPerformanceShaders.
    if (!MPSSupportsMTLDevice(self.metalView.device)) {
        return;
    }
    
    [self setupView];
    
    Scene *launchScene = [[LaunchScene alloc] init];
    _sceneManager = [[MetalSceneManager alloc] initScene:launchScene withDevice:self.metalView.device];
    
    //Scene *primitivesScene = [[PrimitivesScene alloc] init];
    //[_sceneManager performSelector:@selector(setupScene:) withObject:primitivesScene afterDelay:10];
    
    Scene *objectScene = [[NewObjectModelScene alloc] init];
    [_sceneManager performSelector:@selector(setupScene:) withObject:objectScene afterDelay:10];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupView {
    self.metalView.delegate = self;
    
    // Setup the render target, choose values based on your app.
    self.metalView.depthStencilPixelFormat = MTLPixelFormatDepth32Float_Stencil8;
    
    // Set up pixel format as your input/output texture.
    self.metalView.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    
    // Allow to access to currentDrawable.texture write mode.
    self.metalView.framebufferOnly = false;
}

- (void)render:(id<CAMetalDrawable>)drawable {
    [_sceneManager renderSourceTexture:self.metalView.currentDrawable.texture
                    destinationTexture:self.metalView.currentDrawable.texture toDrawable: drawable];
}

#pragma mark - MTKViewDelegate

// Called whenever view changes orientation or layout is changed.
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
}

// Called whenever the view needs to render.
- (void)drawInMTKView:(nonnull MTKView *)view {
    @autoreleasepool {
        [self render: view.currentDrawable];
    }
}


@end
