//
//  Scene.m
//  voĉo
//
//  Created by Andrew Reslan on 23/05/2016.
//  Copyright © 2016 Novoĉo. All rights reserved.
//

#import "Scene.h"

@implementation Scene

- (instancetype) initWithTargetFramerate:(float)tfr supportsPicking:(BOOL)supportsPicking {
	if (self = [super init])
	{
		_kernelName = @"signed_distance_bounds";
		_targetFramerate = tfr;
		_supportsPicking = supportsPicking;		
	}
	
	return self;
}
- (void) setupScene: (SDFScene *)scene {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (BOOL) updateScene: (SDFScene *)scene atMediaTime:(float)mediaTime {
	[NSException raise:NSInternalInconsistencyException
	 format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return NO;
}


- (void) nodeSelected:(uint) nodeId inScene:(SDFScene *)scene {
	[NSException raise:NSInternalInconsistencyException
	 format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (matrix_float3x3) setupCamera: (vector_float3 )origin target: (vector_float3)target rotation:(float) rotation {

	// camera direction
	vector_float3 cd = vector_normalize(target-origin);
	//NSLog(@"cd.x = %f, cd.y = %f, cd.z = %f", cd.x, cd.y, cd.z);
	
	vector_float3 upVector = {sin(rotation),cos(rotation),0.0};
	
	// user defined camera up vector
	vector_float3 cu = vector_normalize(upVector);
	
	//NSLog(@"cu.x = %f, cu.y = %f, cu.z = %f", cu.x, cu.y, cu.z);
	
	//Camera right
	vector_float3 cr = vector_normalize( vector_cross(cd,cu) );
	
	//NSLog(@"cr.x = %f, cr.y = %f, cr.z = %f", cr.x, cr.y, cr.z);
	
	// (de slopped) camera up vector / normal vector of the image plane
	cu = vector_normalize( vector_cross(cr,cd) );
	//NSLog(@"cu.x = %f, cu.y = %f, cu.z = %f", cu.x, cu.y, cu.z);
	
	//Return view matrix
	matrix_float3x3 cameraMatrix = { cr, cu, cd };
	return cameraMatrix;
	
}
    
@end
