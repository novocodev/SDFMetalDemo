
#import "PrimitivesDemoScene.h"

@implementation PrimitivesDemoScene
{
    int updatecount;
}

- (instancetype) init {
    if (self = [super initWithTargetFramerate: 15 supportsPicking: true])
    {
        //Add custom setup here
    }
    return self;
}

-(void) callDelegate{
    [self.delegate sceneDidUpdate:self];
}

- (void) setupScene: (SDFScene *)scene {
    
    scene->modelVersion = 1.0; //Model version to allow shaders to barf if they are not compatible
    
    // camera
    vector_float3 origin = { -0.5+5.5*cos(0.0), 1.0, 0.5 + 5.5*sin(0.0) };

    vector_float3 target = { 0.0, 0.0, 0.0 };
    
    matrix_float3x3 camera = [self setupCamera:origin target: target rotation:M_PI];
    
    scene->cameraTransform = camera;
    scene->rayOrigin = origin;
    
    scene->nodeCount = 47;
    
    struct SDFMaterial materialRed = {
        {1.00,0.00,0.00},
        {1.00,0.85,0.55},
        {1.00,0.00,0.00},
        {0.50,0.70,1.00},
        {0.25,0.25,0.25},
        {1.00,1.00,1.00}
    };
    
    struct SDFMaterial materialGreen = {
        {0.00,1.00,0.00},
        {1.00,0.85,0.55},
        {0.00,1.00,0.00},
        {0.50,0.70,1.00},
        {0.25,0.25,0.25},
        {1.00,1.00,1.00}
    };

    struct SDFMaterial materialBlue = {
        {0.00,0.00,1.00},
        {1.00,0.85,0.55},
        {0.00,0.00,1.00},
        {0.50,0.70,1.00},
        {0.25,0.25,0.25},
        {1.00,1.00,1.00}
    };

    struct SDFMaterial materialYellow = {
        {1.00,1.00,0.00},
        {1.00,0.85,0.55},
        {1.00,1.00,0.00},
        {0.50,0.70,1.00},
        {0.25,0.25,0.25},
        {1.00,1.00,1.00}
    };
    
    scene->materials[0] = materialRed;
    scene->materials[1] = materialGreen;
    scene->materials[2] = materialBlue;
    scene->materials[3] = materialYellow;
    
    scene->materialCount = 4;
    
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
    
    struct SDFNode node16ModOffset;
    node16ModOffset.type = pModOffsetType;
    node16ModOffset.floats[0] = -1.0; // x-offset
    node16ModOffset.floats[1] = 0.25; // y-offset
    node16ModOffset.floats[2] = -1.0; // z-offset
    scene->nodes[16] = node16ModOffset;
    
    struct SDFNode node17TriPrism;
    node17TriPrism.type = fTriPrismType;
    node17TriPrism.materialId = 1;
    node17TriPrism.floats[9] = 0.25; // x dim
    node17TriPrism.floats[10] = 0.05; // y dim
    scene->nodes[17] = node17TriPrism;
    
    struct SDFNode node18Union;
    node18Union.type = pUnionType;
    scene->nodes[18] = node18Union;
    
    struct SDFNode node19ModOffset;
    node19ModOffset.type = pModOffsetType;
    node19ModOffset.floats[0] = 2.0; // x-offset
    node19ModOffset.floats[1] = 0.05; // y-offset
    node19ModOffset.floats[2] = -1.0; // z-offset
    scene->nodes[19] = node19ModOffset;
    
    struct SDFNode node20Cylinder;
    node20Cylinder.type = fCylinderType;
    node20Cylinder.materialId = 1;
    node20Cylinder.floats[9] = 0.1; // x dim
    node20Cylinder.floats[10] = 0.2; // y dim
    scene->nodes[20] = node20Cylinder;
    
    struct SDFNode node21Union;
    node21Union.type = pUnionType;
    scene->nodes[21] = node21Union;
    
    struct SDFNode node22ModOffset;
    node22ModOffset.type = pModOffsetType;
    node22ModOffset.floats[0] = -1.0; // x-offset
    node22ModOffset.floats[1] = -0.05; // y-offset
    node22ModOffset.floats[2] = 0.0; // z-offset
    scene->nodes[22] = node22ModOffset;
    
    struct SDFNode node23Cone;
    node23Cone.type = fConeType;
    node23Cone.materialId = 1;
    node23Cone.floats[9] = 0.2; // x dim
    node23Cone.floats[10] = 0.3; // y dim
    scene->nodes[23] = node23Cone;
    
    struct SDFNode node24Union;
    node24Union.type = pUnionType;
    scene->nodes[24] = node24Union;
    
    struct SDFNode node25ModOffset;
    node25ModOffset.type = pModOffsetType;
    node25ModOffset.floats[0] = 0.0; // x-offset
    node25ModOffset.floats[1] = 0.0; // y-offset
    node25ModOffset.floats[2] = 3.0; // z-offset
    scene->nodes[25] = node25ModOffset;
    
    struct SDFNode node26Torus82;
    node26Torus82.type = fTorus82Type;
    node26Torus82.materialId = 1;
    node26Torus82.floats[9] = 0.2; // x dim
    node26Torus82.floats[10] = 0.05; // y dim
    scene->nodes[26] = node26Torus82;
    
    struct SDFNode node27Union;
    node27Union.type = pUnionType;
    scene->nodes[27] = node27Union;
    
    struct SDFNode node28ModOffset;
    node28ModOffset.type = pModOffsetType;
    node28ModOffset.floats[0] = -1.0; // x-offset
    node28ModOffset.floats[1] = 0.0; // y-offset
    node28ModOffset.floats[2] = 3.0; // z-offset
    scene->nodes[28] = node28ModOffset;
    
    struct SDFNode node29Torus88;
    node29Torus88.type = fTorus88Type;
    node29Torus88.materialId = 1;
    node29Torus88.floats[9] = 0.2; // x dim
    node29Torus88.floats[10] = 0.05; // y dim
    scene->nodes[29] = node29Torus88;
    
    struct SDFNode node30Union;
    node30Union.type = pUnionType;
    scene->nodes[30] = node30Union;
    
    struct SDFNode node31ModOffset;
    node31ModOffset.type = pModOffsetType;
    node31ModOffset.floats[0] = 2.0; // x-offset
    node31ModOffset.floats[1] = 0.05; // y-offset
    node31ModOffset.floats[2] = 0.0; // z-offset
    scene->nodes[31] = node31ModOffset;
    
    struct SDFNode node32Cylinder6;
    node32Cylinder6.type = fCylinder6Type;
    node32Cylinder6.materialId = 1;
    node32Cylinder6.floats[9] = 0.1; // x dim
    node32Cylinder6.floats[10] = 0.2; // y dim
    scene->nodes[32] = node32Cylinder6;
    
    struct SDFNode node33Union;
    node33Union.type = pUnionType;
    scene->nodes[33] = node33Union;
    
    struct SDFNode node34ModOffset;
    node34ModOffset.type = pModOffsetType;
    node34ModOffset.floats[0] = -2.0; // x-offset
    node34ModOffset.floats[1] = 0.1; // y-offset
    node34ModOffset.floats[2] = -1.0; // z-offset
    scene->nodes[34] = node34ModOffset;
    
    struct SDFNode node35ModRotate;
    node35ModRotate.type = pModRotateType;
    node35ModRotate.ints[0] = 1; // x-offset
    node35ModRotate.ints[1] = 2; // y-offset
    node35ModRotate.floats[0] = M_PI/2.0; // z-offset
    scene->nodes[35] = node35ModRotate;
    
    struct SDFNode node36HexagonIncircle;
    node36HexagonIncircle.type = fHexagonIncircleType;
    node36HexagonIncircle.materialId = 1;
    node36HexagonIncircle.floats[9] = 0.25; // x dim
    node36HexagonIncircle.floats[10] = 0.05; // y dim
    scene->nodes[36] = node36HexagonIncircle;

    struct SDFNode node37Union;
    node37Union.type = pUnionType;
    scene->nodes[37] = node37Union;
    
    struct SDFNode node38ModReset;
    node38ModReset.type = pModResetType;
    scene->nodes[38] = node38ModReset;

    struct SDFNode node39ModOffset;
    node39ModOffset.type = pModOffsetType;
    node39ModOffset.floats[0] = -2.0; // x-offset
    node39ModOffset.floats[1] = 0.2; // y-offset
    node39ModOffset.floats[2] = 1.0; // z-offset
    scene->nodes[39] = node39ModOffset;

    struct SDFNode node40Sphere;
    node40Sphere.type = fSphereType;
    node40Sphere.materialId = 0;
    node40Sphere.floats[9] = 0.25; // radius
    scene->nodes[40] = node40Sphere;

    struct SDFNode node41RoundBox;
    node41RoundBox.type = fRoundBoxType;
    node41RoundBox.materialId = 1;
    node41RoundBox.floats[9] = 0.15; // x dim
    node41RoundBox.floats[10] = 0.15; // y dim
    node41RoundBox.floats[11] = 0.15; // z dim
    node41RoundBox.floats[12] = 0.05; // z dim
    scene->nodes[41] = node41RoundBox;
    
    struct SDFNode node42Subtraction;
    node42Subtraction.type = pSubtractionType;
    node42Subtraction.materialId = 3;
    scene->nodes[42] = node42Subtraction;
    
    struct SDFNode node43Union;
    node43Union.type = pUnionType;
    scene->nodes[43] = node43Union;
    
    struct SDFNode node44ModOffset;
    node44ModOffset.type = pModOffsetType;
    node44ModOffset.floats[0] = 0.0; // x-offset
    node44ModOffset.floats[1] = 0.0; // y-offset
    node44ModOffset.floats[2] = -1.0; // z-offset
    scene->nodes[44] = node44ModOffset;
    
    struct SDFNode node45Torus82;
    node45Torus82.type = fTorus82Type;
    node45Torus82.materialId = 1;
    node45Torus82.floats[9] = 0.2; // x dim
    node45Torus82.floats[10] = 0.1; // y dim
    scene->nodes[45] = node45Torus82;
    
    struct SDFNode node44Union;
    node44Union.type = pUnionType;
    scene->nodes[46] = node44Union;
    
}

/*
 * Primitives still to be ported from shadertoy demo
 *

 
 res = pU( res, vec2( pS(
 fTorus82(  pos - vec3(-2.0,0.2, 0.0), vec2(0.20,0.1)), //Node 43
 fCylinder(  pRep( vec3(atan2(pos.x+2.0,pos.z)/6.2831, //Or this
 pos.y,
 0.02+0.5*length(pos-vec3(-2.0,0.2, 0.0))),
 vec3(0.05,1.0,0.05)), 0.02,0.6)), 51.0 ) );
 
 
 //Blobby thing
 res = pU( res, vec2( 0.7*fSphere(    pos - vec3(-2.0,0.25,-1.0), 0.2 ) +
 0.03*sin(50.0*pos.x)*sin(50.0*pos.y)*sin(50.0*pos.z),
 65.0 ) );
 
 //Twisted torus
 res = pU( res, vec2( 0.5*fTorus( pTwist(pos-vec3(-2.0,0.25, 2.0)),0.05,0.20), 46.7 ) );
 
 res = pU( res, vec2(fConeSection( pos - vec3( 0.0,0.35,-2.0), 0.15, 0.2, 0.1 ), 13.67 ) );
 
 res = pU( res, vec2(fEllipsoid( pos - vec3( 1.0,0.35,-2.0), vec3(0.15, 0.2, 0.05) ), 43.17 ) );
 
 return res;
 */

- (void) updateScene:(SDFScene *)scene atMediaTime:(float) mediaTime {
    // camera
    vector_float3 origin = { -0.5+5.5*cos(mediaTime), 1.0, 0.5 + 5.5*sin(mediaTime) };
    //vector_float3 origin = { 0.0, 0.0, 10.0 };
    vector_float3 target = { 0.0, 0.0, 0.0 };
 
    matrix_float3x3 camera = [self setupCamera:origin target: target rotation:M_PI];
 
    scene->cameraTransform = camera;
    scene->rayOrigin = origin;
}

- (void) nodeSelected:(uint) nodeId inScene:(SDFScene *)scene {
    int materialid = scene->nodes[nodeId].materialId;
    
    scene->materials[materialid].ambient[0] = 1.0;
    scene->materials[materialid].ambient[1] = 0.0;
    scene->materials[materialid].ambient[2] = 0.0;
    
    [self callDelegate];
}


@end
