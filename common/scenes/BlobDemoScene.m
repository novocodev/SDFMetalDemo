
#import "BlobDemoScene.h"

@implementation BlobDemoScene
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
    
    scene->nodeCount =4;
    
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
    
    struct SDFNode node0RedOctohedron;
    node0RedOctohedron.type = fBlobType;
    node0RedOctohedron.materialId = 0;
    scene->nodes[0] = node0RedOctohedron;

    struct SDFNode node1ModOffset;
    node1ModOffset.type = pModOffsetType;
    node1ModOffset.floats[0] = 1.0; // x-offset
    node1ModOffset.floats[1] = 0.0; // y-offset
    node1ModOffset.floats[2] = 0.0; // z-offset
    scene->nodes[1] = node1ModOffset;
    
    struct SDFNode node2BlueOctohedron;
    node2BlueOctohedron.type = fBlobType;
    node2BlueOctohedron.materialId = 2;
    scene->nodes[2] = node2BlueOctohedron;
    
    struct SDFNode node7Union;
    node7Union.type = pUnionType;
    scene->nodes[3] = node7Union;
    
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
