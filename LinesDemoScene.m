
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
    
    scene->nodeCount = 5;
    
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
    node0LineSegment.floats[9] = -1.3; // x dim
    node0LineSegment.floats[10] = 0.1; // y dim
    node0LineSegment.floats[11] = -0.1; // z dim
    node0LineSegment.floats[12] = -0.8; // z dim
    node0LineSegment.floats[13] = 0.5; // y dim
    node0LineSegment.floats[14] = 0.2; // z dim
    node0LineSegment.floats[15] = 0.005; // z dim
    scene->nodes[0] = node0LineSegment;
    
    struct SDFNode node1LineSegment;
    node1LineSegment.type = fLineSegmentType;
    node1LineSegment.materialId = 2;
    node1LineSegment.floats[9] = 1.3; // x dim
    node1LineSegment.floats[10] = -0.1; // y dim
    node1LineSegment.floats[11] = 0.1; // z dim
    node1LineSegment.floats[12] = 0.8; // z dim
    node1LineSegment.floats[13] = -0.5; // y dim
    node1LineSegment.floats[14] = -0.2; // z dim
    node1LineSegment.floats[15] = 0.005; // z dim
    scene->nodes[1] = node1LineSegment;
    
    struct SDFNode node2Union;
    node2Union.type = pUnionType;
    scene->nodes[2] = node2Union;
    
    struct SDFNode node3LineSegment;
    node3LineSegment.type = fLineSegmentType;
    node3LineSegment.materialId = 2;
    node3LineSegment.floats[9] = -1.3; // x dim
    node3LineSegment.floats[10] = 0.1; // y dim
    node3LineSegment.floats[11] = -0.1; // z dim
    node3LineSegment.floats[12] = 0.8; // z dim
    node3LineSegment.floats[13] = -0.5; // y dim
    node3LineSegment.floats[14] = -0.2; // z dim
    node3LineSegment.floats[15] = 0.005; // z dim
    scene->nodes[3] = node3LineSegment;
    
    struct SDFNode node4Union;
    node4Union.type = pUnionType;
    scene->nodes[4] = node4Union;

    
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

- (void) nodeSelected:(uint) nodeId inScene:(SDFScene *)scene {
    int materialid = scene->nodes[nodeId].materialId;
    
    scene->materials[materialid].ambient[0]= 1.0;
    scene->materials[materialid].ambient[1] = 0.0;
    scene->materials[materialid].ambient[2] = 0.0;
}


@end
