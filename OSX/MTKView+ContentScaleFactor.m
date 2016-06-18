
#ifdef __APPLE__

#import "MTKView+ContentScaleFactor.h"

#if TARGET_OS_IPHONE
// ios provides MTKView.contentScaleFactor
#elif TARGET_OS_MAC

@implementation MTKView (ContentScaleFactor)

- (void) setContentScaleFactor:(CGFloat)sf {
	self.layer.contentsScale = sf;
	CAMetalLayer *metalLayer = (CAMetalLayer *)self.layer;
	CGSize drawableSize = metalLayer.drawableSize;
	drawableSize.width = self.layer.bounds.size.width * self.layer.contentsScale;
	drawableSize.height = self.layer.bounds.size.height * self.layer.contentsScale;
	metalLayer.drawableSize = drawableSize;
}

- (CGFloat) contentScaleFactor {
	return self.layer.contentsScale;
}

@end

#endif
#endif
