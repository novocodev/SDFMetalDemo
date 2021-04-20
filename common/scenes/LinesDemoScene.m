
#import "LinesDemoScene.h"

@implementation LinesDemoScene
{
    int updatecount;
}

- (instancetype) init {
    if (self = [super initWithTargetFramerate: 15 supportsPicking: false])
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

    scene->nodeCount = 23;

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

    struct SDFNode node0LineSegment;
    node0LineSegment.type = fLineSegmentType;
    node0LineSegment.materialId = 0;
    node0LineSegment.floats[9] =  0.25; // x dim
    node0LineSegment.floats[10] = 0.25; // y dim
    node0LineSegment.floats[11] = 0.25; // z dim
    node0LineSegment.floats[12] = -0.25; // z dim
    node0LineSegment.floats[13] = 0.25; // y dim
    node0LineSegment.floats[14] = 0.25; // z dim
    node0LineSegment.floats[15] = 0.005; // z dim
    scene->nodes[0] = node0LineSegment;

    struct SDFNode node1LineSegment;
    node1LineSegment.type = fLineSegmentType;
    node1LineSegment.materialId = 2;
    node1LineSegment.floats[9] = -0.25; // x dim
    node1LineSegment.floats[10] = 0.25; // y dim
    node1LineSegment.floats[11] = 0.25; // z dim
    node1LineSegment.floats[12] = -0.25; // z dim
    node1LineSegment.floats[13] = 0.25; // y dim
    node1LineSegment.floats[14] = -0.25; // z dim
    node1LineSegment.floats[15] = 0.005; // z dim
    scene->nodes[1] = node1LineSegment;

    struct SDFNode node2Union;
    node2Union.type = pUnionType;
    scene->nodes[2] = node2Union;

    struct SDFNode node3LineSegment;
    node3LineSegment.type = fLineSegmentType;
    node3LineSegment.materialId = 2;
    node3LineSegment.floats[9] = -0.25; // x dim
    node3LineSegment.floats[10] = 0.25; // y dim
    node3LineSegment.floats[11] = -0.25; // z dim
    node3LineSegment.floats[12] = 0.25; // z dim
    node3LineSegment.floats[13] = 0.25; // y dim
    node3LineSegment.floats[14] = -0.25; // z dim
    node3LineSegment.floats[15] = 0.005; // z dim
    scene->nodes[3] = node3LineSegment;

    struct SDFNode node4Union;
    node4Union.type = pUnionType;
    scene->nodes[4] = node4Union;

    struct SDFNode node5LineSegment;
    node5LineSegment.type = fLineSegmentType;
    node5LineSegment.materialId = 2;
    node5LineSegment.floats[9] = 0.25; // x dim
    node5LineSegment.floats[10] = 0.25; // y dim
    node5LineSegment.floats[11] = -0.25; // z dim
    node5LineSegment.floats[12] = 0.25; // z dim
    node5LineSegment.floats[13] = 0.25; // y dim
    node5LineSegment.floats[14] = 0.25; // z dim
    node5LineSegment.floats[15] = 0.005; // z dim
    scene->nodes[5] = node5LineSegment;

    struct SDFNode node6Union;
    node6Union.type = pUnionType;
    scene->nodes[6] = node6Union;

    struct SDFNode node7LineSegment;
    node7LineSegment.type = fLineSegmentType;
    node7LineSegment.materialId = 0;
    node7LineSegment.floats[9] =  0.25; // x dim
    node7LineSegment.floats[10] = -0.25; // y dim
    node7LineSegment.floats[11] = 0.25; // z dim
    node7LineSegment.floats[12] = -0.25; // z dim
    node7LineSegment.floats[13] = -0.25; // y dim
    node7LineSegment.floats[14] = 0.25; // z dim
    node7LineSegment.floats[15] = 0.005; // z dim
    scene->nodes[7] = node7LineSegment;

    struct SDFNode node8Union;
    node8Union.type = pUnionType;
    scene->nodes[8] = node8Union;

    struct SDFNode node9LineSegment;
    node9LineSegment.type = fLineSegmentType;
    node9LineSegment.materialId = 2;
    node9LineSegment.floats[9] = -0.25; // x dim
    node9LineSegment.floats[10] = -0.25; // y dim
    node9LineSegment.floats[11] = 0.25; // z dim
    node9LineSegment.floats[12] = -0.25; // z dim
    node9LineSegment.floats[13] = -0.25; // y dim
    node9LineSegment.floats[14] = -0.25; // z dim
    node9LineSegment.floats[15] = 0.005; // z dim
    scene->nodes[9] = node9LineSegment;

    struct SDFNode node10Union;
    node10Union.type = pUnionType;
    scene->nodes[10] = node10Union;

    struct SDFNode node11LineSegment;
    node11LineSegment.type = fLineSegmentType;
    node11LineSegment.materialId = 2;
    node11LineSegment.floats[9] = -0.25; // x dim
    node11LineSegment.floats[10] = -0.25; // y dim
    node11LineSegment.floats[11] = -0.25; // z dim
    node11LineSegment.floats[12] = 0.25; // z dim
    node11LineSegment.floats[13] = -0.25; // y dim
    node11LineSegment.floats[14] = -0.25; // z dim
    node11LineSegment.floats[15] = 0.005; // z dim
    scene->nodes[11] = node11LineSegment;

    struct SDFNode node12Union;
    node12Union.type = pUnionType;
    scene->nodes[12] = node12Union;

    struct SDFNode node13LineSegment;
    node13LineSegment.type = fLineSegmentType;
    node13LineSegment.materialId = 2;
    node13LineSegment.floats[9] = 0.25; // x dim
    node13LineSegment.floats[10] = -0.25; // y dim
    node13LineSegment.floats[11] = -0.25; // z dim
    node13LineSegment.floats[12] = 0.25; // z dim
    node13LineSegment.floats[13] = -0.25; // y dim
    node13LineSegment.floats[14] = 0.25; // z dim
    node13LineSegment.floats[15] = 0.005; // z dim
    scene->nodes[13] = node13LineSegment;

    struct SDFNode node14Union;
    node14Union.type = pUnionType;
    scene->nodes[14] = node14Union;

    struct SDFNode node15LineSegment;
    node15LineSegment.type = fLineSegmentType;
    node15LineSegment.materialId = 0;
    node15LineSegment.floats[9] =  0.25; // x dim
    node15LineSegment.floats[10] = 0.25; // y dim
    node15LineSegment.floats[11] = 0.25; // z dim
    node15LineSegment.floats[12] = 0.25; // z dim
    node15LineSegment.floats[13] = -0.25; // y dim
    node15LineSegment.floats[14] = 0.25; // z dim
    node15LineSegment.floats[15] = 0.005; // z dim
    scene->nodes[15] = node15LineSegment;

    struct SDFNode node16Union;
    node16Union.type = pUnionType;
    scene->nodes[16] = node16Union;

    struct SDFNode node17LineSegment;
    node17LineSegment.type = fLineSegmentType;
    node17LineSegment.materialId = 2;
    node17LineSegment.floats[9] = -0.25; // x dim
    node17LineSegment.floats[10] = 0.25; // y dim
    node17LineSegment.floats[11] = 0.25; // z dim
    node17LineSegment.floats[12] = -0.25; // z dim
    node17LineSegment.floats[13] = -0.25; // y dim
    node17LineSegment.floats[14] = 0.25; // z dim
    node17LineSegment.floats[15] = 0.005; // z dim
    scene->nodes[17] = node17LineSegment;

    struct SDFNode node18Union;
    node18Union.type = pUnionType;
    scene->nodes[18] = node18Union;

    struct SDFNode node19LineSegment;
    node19LineSegment.type = fLineSegmentType;
    node19LineSegment.materialId = 2;
    node19LineSegment.floats[9] = -0.25; // x dim
    node19LineSegment.floats[10] = 0.25; // y dim
    node19LineSegment.floats[11] = -0.25; // z dim
    node19LineSegment.floats[12] = -0.25; // z dim
    node19LineSegment.floats[13] = -0.25; // y dim
    node19LineSegment.floats[14] = -0.25; // z dim
    node19LineSegment.floats[15] = 0.005; // z dim
    scene->nodes[19] = node19LineSegment;

    struct SDFNode node20Union;
    node20Union.type = pUnionType;
    scene->nodes[20] = node20Union;

    struct SDFNode node21LineSegment;
    node21LineSegment.type = fLineSegmentType;
    node21LineSegment.materialId = 2;
    node21LineSegment.floats[9] = 0.25; // x dim
    node21LineSegment.floats[10] = 0.25; // y dim
    node21LineSegment.floats[11] = -0.25; // z dim
    node21LineSegment.floats[12] = 0.25; // z dim
    node21LineSegment.floats[13] = -0.25; // y dim
    node21LineSegment.floats[14] = -0.25; // z dim
    node21LineSegment.floats[15] = 0.005; // z dim
    scene->nodes[21] = node21LineSegment;

    struct SDFNode node22Union;
    node22Union.type = pUnionType;
    scene->nodes[22] = node22Union;

}

- (void) updateScene:(SDFScene *)scene atMediaTime:(float) mediaTime {
    // camera
    vector_float3 origin = { -0.5+5.5*cos(0.1*mediaTime), 1.0, 0.5 + 5.5*sin(0.1*mediaTime) };
    //vector_float3 origin = { 0.0, 0.0, 10.0 };
    vector_float3 target = { 0.0, 0.0, 0.0 };

    matrix_float3x3 camera = [self setupCamera:origin target: target rotation:M_PI];

    scene->cameraTransform = camera;
    scene->rayOrigin = origin;
}


@end

