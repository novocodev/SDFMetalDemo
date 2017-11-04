
#import "MultiTouchDemoScene.h"

@implementation MultitouchDemoScene
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
    //vector_float3 origin = { -0.5+1.5*cos(0.0), 0.5, 0.5 + 1.5*sin(0.0) };
    vector_float3 origin = { 0.0, 0.0, 0.4 };
    vector_float3 target = { 0.0, 0.0, 0.0 };

    matrix_float3x3 camera = [self setupCamera:origin target: target rotation:M_PI];

    scene->cameraTransform = camera;
    scene->rayOrigin = origin;

    scene->nodeCount = 11;

    struct SDFMaterial materialRed = {
        {1.20,0.00,0.00},
        {1.20,1.02,0.66},
        {1.00,0.00,0.00},
        {0.15,0.21,0.30},
        {0.075,0.075,0.075},
        {0.40,0.40,0.40}
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

    struct SDFMaterial materialCyan = {
        {1.00,1.00,0.00},
        {1.00,0.85,0.55},
        {0.00,1.00,1.00},
        {0.50,0.70,1.00},
        {0.25,0.25,0.25},
        {1.00,1.00,1.00}
    };
    struct SDFMaterial materialMagenta = {
        {1.00,1.00,0.00},
        {1.00,0.85,0.55},
        {1.00,0.00,1.00},
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
    scene->materials[3] = materialCyan;
    scene->materials[4] = materialMagenta;
    scene->materials[5] = materialYellow;

    scene->materialCount = 6;

    struct SDFNode node0ModOffset;
    node0ModOffset.type = pModOffsetType;
    node0ModOffset.floats[0] = 0.05; // x-offset
    node0ModOffset.floats[1] = -0.05; // y-offset
    node0ModOffset.floats[2] = 0.0; // z-offset
    scene->nodes[0] = node0ModOffset;

    struct SDFNode node0GreenBoxCheap;
    node0GreenBoxCheap.type = fBoxCheapType;
    node0GreenBoxCheap.materialId = 1;
    node0GreenBoxCheap.floats[9] = 0.04; // x dim
    node0GreenBoxCheap.floats[10] = 0.04; // y dim
    node0GreenBoxCheap.floats[11] = 0.01; // z dim
    scene->nodes[1] = node0GreenBoxCheap;

    struct SDFNode node1ModOffset;
    node1ModOffset.type = pModOffsetType;
    node1ModOffset.floats[0] = -0.1; // x-offset
    node1ModOffset.floats[1] = 0.0; // y-offset
    node1ModOffset.floats[2] = 0.0; // z-offset
    scene->nodes[2] = node1ModOffset;

    struct SDFNode node1GreenBoxCheap;
    node1GreenBoxCheap.type = fBoxCheapType;
    node1GreenBoxCheap.materialId = 2;
    node1GreenBoxCheap.floats[9] = 0.04; // x dim
    node1GreenBoxCheap.floats[10] = 0.04; // y dim
    node1GreenBoxCheap.floats[11] = 0.01; // z dim
    scene->nodes[3] = node1GreenBoxCheap;

    struct SDFNode node3Union;
    node3Union.type = pUnionType;
    scene->nodes[4] = node3Union;

    struct SDFNode node4ModOffset;
    node4ModOffset.type = pModOffsetType;
    node4ModOffset.floats[0] = 0.0; // x-offset
    node4ModOffset.floats[1] = 0.1; // y-offset
    node4ModOffset.floats[2] = 0.0; // z-offset
    scene->nodes[5] = node4ModOffset;

    struct SDFNode node5GreenBoxCheap;
    node5GreenBoxCheap.type = fBoxCheapType;
    node5GreenBoxCheap.materialId = 3;
    node5GreenBoxCheap.floats[9] = 0.04; // x dim
    node5GreenBoxCheap.floats[10] = 0.04; // y dim
    node5GreenBoxCheap.floats[11] = 0.01; // z dim
    scene->nodes[6] = node5GreenBoxCheap;

    struct SDFNode node6Union;
    node6Union.type = pUnionType;
    scene->nodes[7] = node6Union;

    struct SDFNode node7ModOffset;
    node7ModOffset.type = pModOffsetType;
    node7ModOffset.floats[0] = 0.1; // x-offset
    node7ModOffset.floats[1] = 0.0; // y-offset
    node7ModOffset.floats[2] = 0.0; // z-offset
    scene->nodes[8] = node7ModOffset;

    struct SDFNode node8GreenBoxCheap;
    node8GreenBoxCheap.type = fBoxCheapType;
    node8GreenBoxCheap.materialId = 4;
    node8GreenBoxCheap.floats[9] = 0.04; // x dim
    node8GreenBoxCheap.floats[10] = 0.04; // y dim
    node8GreenBoxCheap.floats[11] = 0.01; // z dim
    scene->nodes[9] = node8GreenBoxCheap;

    struct SDFNode node9Union;
    node9Union.type = pUnionType;
    scene->nodes[10] = node9Union;

}

- (void) updateScene:(SDFScene *)scene atMediaTime:(float) mediaTime {

    // camera
    //vector_float3 origin = { -0.5+1.5*cos(0.1*mediaTime), 1.0, 0.5 + 1.5*sin(0.1*mediaTime) };
    //vector_float3 origin = { 0.0, 0.0, 10.0 };
    //vector_float3 target = { 0.0, 0.0, 0.0 };

    //matrix_float3x3 camera = [self setupCamera:origin target: target rotation:M_PI];

    // scene->cameraTransform = camera;
    //scene->rayOrigin = origin;
}

- (void) nodesSelected:(NSMutableArray <NSValue *> *)hits  inScene:(SDFScene *)scene {
    for(int i=0; i<hits.count; i++) {

        SDFHit hitValue;
        [hits[i] getValue:&hitValue];

        int materialid = scene->nodes[hitValue.hitNodeId].materialId;

        scene->materials[materialid].ambient[0] = 1.0;
        scene->materials[materialid].ambient[1] = 0.0;
        scene->materials[materialid].ambient[2] = 0.0;
    }

    [self callDelegate];
}


@end

