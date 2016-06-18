
#import "BlobDemoScene.h"

@implementation BlobDemoScene
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
    
    scene->nodeCount =4;
    
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

- (BOOL) updateScene:(SDFScene *)scene atMediaTime:(float) mediaTime {
    // camera
    vector_float3 origin = { -0.5+5.5*cos(0.1*mediaTime), 1.0, 0.5 + 5.5*sin(0.1*mediaTime) };
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
