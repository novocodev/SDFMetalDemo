
#import "Scene.h"

@implementation Scene

- (instancetype) initWithTargetFramerate:(float)tfr supportsPicking:(BOOL)supportsPicking {
    if (self = [super init]) {
        _targetFramerate = tfr;
        _supportsPicking = supportsPicking;
    }

    return self;
}

- (void) setupScene: (SDFScene *)scene {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (void) updateScene: (SDFScene *)scene atMediaTime:(float)mediaTime {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}


- (void) nodesSelected:(NSMutableArray <NSValue *> *)hits  inScene:(SDFScene *)scene {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (matrix_float3x3) setupCamera: (vector_float3 )origin target: (vector_float3)target rotation:(float) rotation {

    // camera direction
    vector_float3 cd = vector_normalize(target-origin);

    vector_float3 upVector = {sin(rotation),cos(rotation),0.0};

    // user defined camera up vector
    vector_float3 cu = vector_normalize(upVector);

    //Camera right
    vector_float3 cr = vector_normalize( vector_cross(cd,cu) );

    // (de slopped) camera up vector / normal vector of the image plane
    cu = vector_normalize( vector_cross(cr,cd) );

    //Return view matrix
    matrix_float3x3 cameraMatrix = { cr, cu, cd };
    return cameraMatrix;

}

@end

