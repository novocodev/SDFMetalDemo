@import Metal;
@import simd;

#import <math.h>

#import "SDFMetalDemoViewController.h"
#import "MetalSceneManager.h"
#import "ThreeDSpaceWarpingDemoScene.h"
#import "PolarSpaceWarpingDemoScene.h"
#import "BlobDemoScene.h"
#import "PrimitivesDemoScene.h"


#ifndef TARGET_IOS
#import "MTKView+ContentScaleFactor.h"
#endif

static int const numFpsSamples = 16;

@interface SDFMetalDemoViewController ()

// View.
@property (nonatomic, strong) MTKView *metalView;

// Source Texture.
@property (nonatomic, strong) id<MTLTexture> sourceTexture;
@end

@implementation SDFMetalDemoViewController
{
	MetalSceneManager *_sceneManager;
	float _targetFPS;
	CFTimeInterval fpsSamples[numFpsSamples];
	int currentSample;
	float _initialViewScaleFactor;
	CFTimeInterval _viewLastRenderTime;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSLog(@"viewDidLoad called");
	self.metalView = (MTKView *)self.view;
	
	// Set the view to use the default device.
	self.metalView.device = MTLCreateSystemDefaultDevice();
	
	[self setupView];
	
	_sceneManager = [[MetalSceneManager alloc] initWithDevice:self.metalView.device];
	
	
	Scene *launchScene = [[ThreeDSpaceWarpingDemoScene alloc] init];
	[self newScene: launchScene];
    
    [self performSelector:@selector(newScene:) withObject:[[PolarSpaceWarpingDemoScene alloc] init] afterDelay:10];
    
    [self performSelector:@selector(newScene:) withObject:[[BlobDemoScene alloc] init] afterDelay:20];
    
    [self performSelector:@selector(newScene:) withObject:[[PrimitivesDemoScene alloc] init] afterDelay:30];

	
	//[self setupVilageto];
}

- (Scene *) newScene: (Scene *)scene {
	currentSample = 0;
	_targetFPS = scene.targetFramerate;
	[_sceneManager setupScene:scene];
	
	_viewLastRenderTime = CACurrentMediaTime();
	
	return scene;
}

- (void)didReceiveMemoryWarning {
#ifdef TARGET_IOS
	[super didReceiveMemoryWarning];
#endif

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
	
	_initialViewScaleFactor = self.metalView.contentScaleFactor;
}

 
#ifdef TARGET_IOS
- (void)render:(UIView *)view drawable:(id<CAMetalDrawable>)drawable {
#else
- (void)render:(NSView *)view drawable:(id<CAMetalDrawable>)drawable {
#endif

	[_sceneManager renderSourceTexture:self.metalView.currentDrawable.texture
	 destinationTexture:self.metalView.currentDrawable.texture inView: (MTKView *)view toDrawable: drawable];
}

#pragma mark - MTKViewDelegate

// Called whenever view changes orientation or layout is changed.
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
}

// Called whenever the view needs to render.
- (void)drawInMTKView:(nonnull MTKView *)view {
	//Calculate the current framerate
	CFTimeInterval lastRenderTime = _viewLastRenderTime;
	_viewLastRenderTime = CACurrentMediaTime();
	
	float frameRate = [self calcFPS:_viewLastRenderTime - lastRenderTime];
	
	float contentScaleFactor = view.contentScaleFactor * frameRate / _targetFPS;
	
	/*
	 * clamp scale factor to original factor and one quarter original factor
	 * this prevents wild variations and works well for most devices
	 */
	if (contentScaleFactor > _initialViewScaleFactor) {
		contentScaleFactor = _initialViewScaleFactor;
	} else if (contentScaleFactor < _initialViewScaleFactor/4.0) {
		contentScaleFactor = _initialViewScaleFactor/4.0;
	}
	
	view.contentScaleFactor = contentScaleFactor;
	
	@autoreleasepool {
		[self render: view drawable: view.currentDrawable];
	}
}

#pragma mark - UIResponder
#ifdef TARGET_IOS
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSSet <UITouch *> * allTouches = [event allTouches];
	NSLog(@"touchesBegan() called with %lu touches",(unsigned long)allTouches.count);
	
	UITouch * t = [allTouches anyObject];
	if (t != nil) {
		CGPoint touchPoint = [t locationInView:self.metalView];
		
        [_sceneManager hitTestWithPoint: touchPoint inView: self.metalView initialViewScale: _initialViewScaleFactor];
	}
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	NSSet <UITouch *> * allTouches = [event allTouches];
	NSLog(@"touchesMoved() called with %lu touches",(unsigned long)allTouches.count);
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"touchesEnded() called");
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"touchesCancelled() called");
}
#else
    -(void)mouseDown:(NSEvent *)theEvent {
    }
    
    - (void)mouseUp:(NSEvent *)theEvent
    {
        CGPoint touchPoint = [theEvent locationInWindow];
        touchPoint.y = [[[theEvent window] contentView] frame].size.height - touchPoint.y;
        [_sceneManager hitTestWithPoint: touchPoint inView:self.metalView initialViewScale: _initialViewScaleFactor];
    }
    
    - (void)mouseExited:(NSEvent *)theEvent
    {
    }
#endif

/*
 * Calculate the running frames per second
 * for use in adjusting the buffer resolution
 */
- (float) calcFPS: (CFTimeInterval) deltaTime {
	CFTimeInterval fps = 0;
	
	if(currentSample == 0) {
		fps = _targetFPS;
	} else {
		//We use a fixed array of samples, use modulo to write into array
		fpsSamples[currentSample % numFpsSamples] = 1.0 / deltaTime;
		
		//If we have not filled the samples array yet exclude empty index values from
		//the FPS calculation
		int maxSample = currentSample < numFpsSamples ? currentSample+1 : numFpsSamples;
		
		//Accumulate the FPS values from the array
		for (int i = 0; i < maxSample; i++) {
			fps += fpsSamples[i];
		}
		
		//Calculate Average FPS from array
		fps /= maxSample;
		
		//Average with the current FPS to give it more influence
		fps += fpsSamples[currentSample % numFpsSamples];
		fps /= 2.0;
	}
	//increment the total FPS sample count
	currentSample++;
	
	return (float)fps;
}

@end
