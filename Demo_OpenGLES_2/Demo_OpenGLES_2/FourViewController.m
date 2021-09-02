//
//  FourViewController.m
//  Demo_OpenGLES_2
//
//  Created by billthaslu on 2021/8/15.
//

#import "FourViewController.h"

@interface FourViewController ()

@end

@implementation FourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
}

- (void)setupGLView {
    self.glView = [[DemoGLView4 alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.glView];
}

@end




#pragma mark ----------------------------------DemoGLView4----------------------------------

#import "DemoGLUtility.h"
#import "DemoGLGeometry.h"
#import <GLKit/GLKit.h>
#import <LXMKit/LXMKit.h>


@implementation DemoGLView4

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 测试表面设置这一句还是有用的，纹理透明的部分就会把后面的露出来；
        // 如果没有这一句，相当于背景色是黑色的
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}

- (void)setupProgramAndViewport {
    glUseProgram(_program);
    
    glViewport(0, 0, _width, _height);
    
    // 加载图片纹理
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"saber" ofType:@"jpeg"];//1280*1024
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"xianhua" ofType:@"png"];// 64*64
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];

    NSDictionary *optionDict = @{GLKTextureLoaderOriginBottomLeft : @(YES)};
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:image.CGImage options:optionDict error:nil];
    
    CGSize imageSize = image.size;
    CGSize displaySize = CGSizeMake(self.width * 0.5, self.height * 0.5);
    CGSize samplingSize = [LXMAspectUtil normalizedAspectFillSizeForSourceSize:imageSize destinationSize:displaySize];
    /**
     写法1
     CGFloat leftX = leftXForSamplingSize(samplingSize);
     CGFloat rightX = rightXForSamplingSize(samplingSize);
     CGFloat topY = topYForSamplingSize(samplingSize);
     CGFloat bottomY = bottomYForSamplingSize(samplingSize);

     const VertexAndCoordinate vertices[] = {
         {GLKVector3Make(-0.5, 0.5, 0), GLKVector2Make(leftX, topY)},
         {GLKVector3Make(0.5, 0.5, 0), GLKVector2Make(rightX, topY)},
         {GLKVector3Make(-0.5, -0.5, 0), GLKVector2Make(leftX, bottomY)},
         {GLKVector3Make(0.5, -0.5, 0), GLKVector2Make(rightX, bottomY)},
     };
     */
    
    const VertexAndCoordinate vertices[] = {
        {GLKVector3Make(-0.5, 0.5, 0), [DemoGLGeometry topLeftForSamplingSize:samplingSize]},
        {GLKVector3Make(0.5, 0.5, 0), [DemoGLGeometry topRightForSamplingSize:samplingSize]},
        {GLKVector3Make(-0.5, -0.5, 0), [DemoGLGeometry bottomLeftForSamplingSize:samplingSize]},
        {GLKVector3Make(0.5, -0.5, 0), [DemoGLGeometry bottomRightForSamplingSize:samplingSize]},
    };
    
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // 传递vertices数据;3是每个顶点所占用元素个数，即这里是3个float为一个顶点
    glVertexAttribPointer(ShaderAttributeIndexPosition, 3, GL_FLOAT, GL_FALSE, sizeof(VertexAndCoordinate), offsetof(VertexAndCoordinate, vertex) + NULL);
    glEnableVertexAttribArray(ShaderAttributeIndexPosition);
    
    glVertexAttribPointer(ShaderAttributeIndexCoordinate, 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndCoordinate), offsetof(VertexAndCoordinate, coordinate) + NULL);
    glEnableVertexAttribArray(ShaderAttributeIndexCoordinate);
    
    
   
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureInfo.name);
    glUniform1i(0, 0);
    
    
}

@end
