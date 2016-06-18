
#import "PrimitivesDemoScene.h"

@implementation PrimitivesDemoScene
{
    int updatecount;
}

- (instancetype) init {
    if (self = [super initWithTargetFramerate: 15 supportsPicking: true])
    {
        //Add custom setup here
        //Add a timer that is going to update scene content every second
        [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(callDelegate) userInfo:nil repeats:YES];
    }
    return self;
}

-(void) callDelegate{
    [self.delegate sceneDidUpdate:self];
}

- (void) setupScene: (SDFScene *)scene {
    
    scene->modelVersion = 1.0; //Model version to allow shaders to barf if they are not compatible
    scene->deviceAttitudePitch = 0.0; //_deviceAttitudePitch;
    scene->deviceAttitudeRoll = 0.0; //_deviceAttitudeRoll;
    scene->deviceAttitudeYaw = 0.0; //_deviceAttitudeYaw;
    //NSLog(@"texture width = %f, hight = %f",textureWidth, textureHeight);
    
    // camera
    vector_float3 origin = { -0.5+5.5*cos(0.0), 1.0, 0.5 + 5.5*sin(0.0) };
    //vector_float3 origin = { 0.0, 0.0, 10.0 };
    vector_float3 target = { 0.0, 0.0, 0.0 };
    
    matrix_float3x3 camera = [self setupCamera:origin target: target rotation:M_PI];
    
    scene->cameraTransform = camera;
    scene->rayOrigin = origin;
    
    scene->nodeCount =16;
    
    struct SDFMaterial materialRed;
    materialRed.red = 1.0;
    materialRed.green = 0.7;
    materialRed.blue = 0.8;
    materialRed.alpha = 1.0;
    
    struct SDFMaterial materialGreen;
    materialGreen.red = 0.0;
    materialGreen.green = 1.0;
    materialGreen.blue = 0.0;
    materialGreen.alpha = 1.0;
    
    struct SDFMaterial materialBlue;
    materialBlue.red = 0.0;
    materialBlue.green = 0.0;
    materialBlue.blue = 1.0;
    materialBlue.alpha = 1.0;
    
    struct SDFMaterial materialYellow;
    materialYellow.red = 0.9;
    materialYellow.green = 0.7;
    materialYellow.blue = 0.9;
    materialYellow.alpha = 1.0;
    
    scene->materials[0] = materialRed;
    scene->materials[1] = materialGreen;
    scene->materials[2] = materialBlue;
    scene->materials[3] = materialYellow;
    
    struct SDFNode node0Plane;
    node0Plane.type = fPlaneType;
    node0Plane.materialId = 0;
    node0Plane.floats[9] = 0.0; // radius
    node0Plane.floats[10] = 1.0; // radius
    node0Plane.floats[11] = 0.0; // radius
    node0Plane.floats[12] = 0.0; // radius
    scene->nodes[0] = node0Plane;
    
    struct SDFNode node1ModOffset;
    node1ModOffset.type = pModOffsetType;
    node1ModOffset.floats[0] = 0.0; // x-offset
    node1ModOffset.floats[1] = 0.25; // y-offset
    node1ModOffset.floats[2] = 0.0; // z-offset
    scene->nodes[1] = node1ModOffset;
    
    struct SDFNode node2Sphere;
    node2Sphere.type = fSphereType;
    node2Sphere.materialId = 2;
    node2Sphere.floats[9] = 0.25; // radius
    scene->nodes[2] = node2Sphere;
    
    struct SDFNode node3Union;
    node3Union.type = pUnionType;
    scene->nodes[3] = node3Union;
    
    struct SDFNode node4ModOffset;
    node4ModOffset.type = pModOffsetType;
    node4ModOffset.floats[0] = 1.0; // x-offset
    node4ModOffset.floats[1] = 0.0; // y-offset
    node4ModOffset.floats[2] = 0.0; // z-offset
    scene->nodes[4] = node4ModOffset;
    
    struct SDFNode node5BoxCheap;
    node5BoxCheap.type = fBoxCheapType;
    node5BoxCheap.materialId = 1;
    node5BoxCheap.floats[9] = 0.25; // x dim
    node5BoxCheap.floats[10] = 0.25; // y dim
    node5BoxCheap.floats[11] = 0.25; // z dim
    scene->nodes[5] = node5BoxCheap;

    
    struct SDFNode node6Union;
    node6Union.type = pUnionType;
    scene->nodes[6] = node6Union;
    
    struct SDFNode node7ModOffset;
    node7ModOffset.type = pModOffsetType;
    node7ModOffset.floats[0] = 0.0; // x-offset
    node7ModOffset.floats[1] = 0.0; // y-offset
    node7ModOffset.floats[2] = 1.0; // z-offset
    scene->nodes[7] = node7ModOffset;
    
    struct SDFNode node8RoundBox;
    node8RoundBox.type = fRoundBoxType;
    node8RoundBox.materialId = 1;
    node8RoundBox.floats[9] = 0.15; // x dim
    node8RoundBox.floats[10] = 0.15; // y dim
    node8RoundBox.floats[11] = 0.15; // z dim
    node8RoundBox.floats[12] = 0.1; // z dim
    scene->nodes[8] = node8RoundBox;

    struct SDFNode node9Union;
    node9Union.type = pUnionType;
    scene->nodes[9] = node9Union;
    
    struct SDFNode node10ModOffset;
    node10ModOffset.type = pModOffsetType;
    node10ModOffset.floats[0] = -1.0; // x-offset
    node10ModOffset.floats[1] = 0.0; // y-offset
    node10ModOffset.floats[2] = 0.0; // z-offset
    scene->nodes[10] = node10ModOffset;
    
    struct SDFNode node11Torus;
    node11Torus.type = fTorusType;
    node11Torus.materialId = 1;
    node11Torus.floats[9] = 0.05; // x dim
    node11Torus.floats[10] = 0.2; // y dim
    scene->nodes[11] = node11Torus;
    
    struct SDFNode node12Union;
    node12Union.type = pUnionType;
    scene->nodes[12] = node12Union;
    
    
    struct SDFNode node13ModReset;
    node13ModReset.type = pModResetType;
    scene->nodes[13] = node13ModReset;
    
    struct SDFNode node14Capsule;
    node14Capsule.type = fCapsuleType;
    node14Capsule.materialId = 1;
    node14Capsule.floats[9] = -1.3; // x dim
    node14Capsule.floats[10] = 0.1; // y dim
    node14Capsule.floats[11] = -0.1; // z dim
    node14Capsule.floats[12] = -0.8; // z dim
    node14Capsule.floats[13] = 0.5; // y dim
    node14Capsule.floats[14] = 0.2; // z dim
    node14Capsule.floats[15] = 0.1; // z dim

    scene->nodes[14] = node14Capsule;
    
    struct SDFNode node15Union;
    node15Union.type = pUnionType;
    scene->nodes[15] = node15Union;
    
}

/*
 vec2 res = pU(vec2( fPlane(pos, vec3 {0.0,1.0,0.0}, 0.0f), 1.0 ),vec2( fSphere(pos - vec3( 0.0,0.25, 0.0), 0.25 ), 46.9));
 
 res = pU( res, vec2( fBoxCheap(pos - vec3( 1.0,0.25, 0.0), vec3(0.25) ), 3.0 ) );
 
 res = pU( res, vec2( fRoundBox(pos - vec3( 1.0,0.25, 1.0), vec3(0.15), 0.1 ), 41.0 ) );
 
 res = pU( res, vec2( fTorus(pos - vec3( 0.0,0.25, 1.0), 0.05, 0.20 ), 25.0 ) );
 
 res = pU( res, vec2( fCapsule(pos, vec3(-1.3,0.10,-0.1), vec3(-0.8,0.50,0.2), 0.1  ), 31.9 ) );
 
 
 
 res = pU( res, vec2( fTriPrism(pos - vec3(-1.0,0.25,-1.0), vec2(0.25,0.05) ),43.5 ) );
 
 res = pU( res, vec2( fCylinder(pos - vec3( 1.0,0.30,-1.0), 0.1,0.2 ), 8.0 ) );
 
 res = pU( res, vec2( fCone(pos - vec3( 0.0,0.25,-1.0), 0.2,0.3 ), 55.0 ) );
 
 
 res = pU( res, vec2( fTorus82(pos - vec3( 0.0,0.25, 2.0), vec2(0.20,0.05) ),50.0 ) );
 
 res = pU( res, vec2( fTorus88(pos - vec3(-1.0,0.25, 2.0), vec2(0.20,0.05) ),43.0 ) );
 
 res = pU( res, vec2( fCylinder6(pos - vec3( 1.0,0.30, 2.0), vec2(0.1,0.2) ), 12.0 ) );
 
 vec3 newPos = pos - vec3(-1.0,0.20, 1.0);
 vec2 newPosYZ = vec2(newPos.yz);
 pR(newPosYZ,PI/2.0);
 newPos.yz = vec2(newPosYZ.xy);
 
 res = pU( res, vec2( fHexagonIncircle(newPos, vec2(0.25,0.05) ),17.0 ) );
 
 
 
 res = pU( res, vec2( pS(
 fRoundBox(pos - vec3(-2.0,0.2, 1.0), vec3(0.15),0.05),
 fSphere(    pos - vec3(-2.0,0.2, 1.0), 0.25)), 13.0 ) );
 res = pU( res, vec2( pS(
 fTorus82(  pos - vec3(-2.0,0.2, 0.0), vec2(0.20,0.1)),
 fCylinder(  pRep( vec3(atan2(pos.x+2.0,pos.z)/6.2831,
 pos.y,
 0.02+0.5*length(pos-vec3(-2.0,0.2, 0.0))),
 vec3(0.05,1.0,0.05)), 0.02,0.6)), 51.0 ) );
 
 
 
 res = pU( res, vec2( 0.7*fSphere(    pos - vec3(-2.0,0.25,-1.0), 0.2 ) +
 0.03*sin(50.0*pos.x)*sin(50.0*pos.y)*sin(50.0*pos.z),
 65.0 ) );
 res = pU( res, vec2( 0.5*fTorus( pTwist(pos-vec3(-2.0,0.25, 2.0)),0.05,0.20), 46.7 ) );
 
 res = pU( res, vec2(fConeSection( pos - vec3( 0.0,0.35,-2.0), 0.15, 0.2, 0.1 ), 13.67 ) );
 
 res = pU( res, vec2(fEllipsoid( pos - vec3( 1.0,0.35,-2.0), vec3(0.15, 0.2, 0.05) ), 43.17 ) );
 
 return res;
 */

- (BOOL) updateScene:(SDFScene *)scene atMediaTime:(float) mediaTime {
    // camera
    vector_float3 origin = { -0.5+5.5*cos(mediaTime), 1.0, 0.5 + 5.5*sin(mediaTime) };
    //vector_float3 origin = { 0.0, 0.0, 10.0 };
    vector_float3 target = { 0.0, 0.0, 0.0 };
 
    matrix_float3x3 camera = [self setupCamera:origin target: target rotation:M_PI];
 
    scene->cameraTransform = camera;
    scene->rayOrigin = origin;
 
    return NO; //updatecount++ < 1;
}

- (void) nodeSelected:(uint) nodeId inScene:(SDFScene *)scene {
    int materialid = scene->nodes[nodeId].materialId;
    
    scene->materials[materialid].red = 1.0;
    scene->materials[materialid].green = 0.0;
    scene->materials[materialid].blue = 0.0;
}


@end
