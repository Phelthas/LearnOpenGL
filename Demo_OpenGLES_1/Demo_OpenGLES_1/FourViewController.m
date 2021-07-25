//
//  FourViewController.m
//  Demo_OpenGLES_1
//
//  Created by billthaslu on 2021/6/3.
//  Copyright © 2021 lxm. All rights reserved.
//

#import "FourViewController.h"
#import <GLKit/GLKit.h>
#import "LXMAspectUtil.h"


typedef struct {
    GLKVector3 vertex;
    GLKVector2 coordinate;
} VertexAndCoordinate;

@interface FourViewController ()<GLKViewDelegate>

@property (nonatomic, strong) GLKView *glkView;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKBaseEffect *baseEffect;

@end

@implementation FourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];

    _glkView = [[GLKView alloc] initWithFrame:self.view.bounds context:_context];
    _glkView.delegate = self;
    [self.view addSubview:_glkView];
    
    // 加载图片纹理
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"saber" ofType:@"jpeg"];//1280*1024
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"xianhua" ofType:@"png"];// 64*64
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];

    NSDictionary *optionDict = @{GLKTextureLoaderOriginBottomLeft : @(YES)};
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:image.CGImage options:optionDict error:nil];
//    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:image.CGImage options:nil error:nil];
    
    CGSize imageSize = image.size;
    CGSize displaySize = CGSizeMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.5);
    CGSize aspectFillSize = [LXMAspectUtil aspectFillSizeForSourceSize:imageSize destinationSize:displaySize];
    //按照aspectFill的方式计算出来的aspectFillSize一定是>=displaySize的
    CGSize samplingSize = CGSizeMake(displaySize.width / aspectFillSize.width, displaySize.height / aspectFillSize.height);
    
    // 注意：AspectFit的方式，不能用这种方式来实现！！！
    
    CGFloat leftX = (1 - samplingSize.width) / 2;
    CGFloat rightX = (1 + samplingSize.width) / 2;
    CGFloat topY = (1 + samplingSize.height) / 2;
    CGFloat bottomY = (1 - samplingSize.height) / 2;
    
    
    const VertexAndCoordinate vertexArray[] = {
        {{0.5, 0.5, 0}, {rightX, topY}},
        {{0.5, -0.5, 0}, {rightX, bottomY}},
        {{-0.5, -0.5, 0}, {leftX, bottomY}},
        {{-0.5, 0.5, 0}, {leftX, topY}},
    };
    
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexArray), vertexArray, GL_STATIC_DRAW);
    
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(VertexAndCoordinate), NULL + offsetof(VertexAndCoordinate, vertex));
    
    // 通过 index 的排列组合可以发现：只要这几个点连线画出来是矩形就可以了，跟点的顺序无关
    const GLuint indexArray[] = {
        0, 1, 3,
        1, 2, 3,
    };
    
    GLuint ebo;
    glGenBuffers(1, &ebo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indexArray), indexArray, GL_STATIC_DRAW);
    

    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.constantColor = GLKVector4Make(1, 1, 1, 0.5);
    self.baseEffect.texture2d0.name = textureInfo.name;// name是必须的
    self.baseEffect.texture2d0.target = textureInfo.target;// target不设也行
    
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndCoordinate), NULL + offsetof(VertexAndCoordinate, coordinate));
    
}


#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
        
    glClearColor(0.5, 1, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.baseEffect prepareToDraw];
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

}
@end
