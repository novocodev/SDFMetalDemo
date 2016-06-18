//
//  ViewController.h
//  voĉo-iOS
//  Copyright © 2016 Novoĉo. All rights reserved.
//

#ifdef TARGET_IOS
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

#import <MetalKit/MetalKit.h>

#ifdef TARGET_IOS
@interface SDFMetalDemoViewController : UIViewController <MTKViewDelegate>
#else
@interface SDFMetalDemoViewController : NSViewController <MTKViewDelegate>
#endif


@end

