//
//  ThreeViewController.m
//  Demo_OpenGLES_2
//
//  Created by billthaslu on 2021/8/15.
//

#import "ThreeViewController.h"

@interface ThreeViewController ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ThreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self testTimer];
}

- (void)setupGLView {
    self.glView = [[DemoGLView3 alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.glView];
}

- (void)testTimer {
    self.timer = [NSTimer timerWithTimeInterval:0.1 target:self.glView selector:@selector(displayContent) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

@end





#pragma mark ----------------------------------DemoGLView3----------------------------------

#import "DemoGLUtility.h"
#import <GLKit/GLKit.h>
#import <LXMKit/LXMKit.h>

static const char * kPassThruVertex = _STRINGIFY(

attribute vec4 position;
attribute mediump vec4 inputCoordinate;
varying mediump vec2 coordinate;
                                                 
void main()
{
    gl_Position = position;
    coordinate = inputCoordinate.xy;
//    gl_PointSize = 40.0;
}
                                                 
);

static const char * kPassThruFragment = _STRINGIFY(

varying mediump vec2 coordinate;
uniform sampler2D texture;
                                                   
void main()
{
    gl_FragColor = texture2D(texture, coordinate);
}
                                                   
);

@implementation DemoGLView3

- (BOOL)loadShaders {
    
    BOOL result = [super loadShadersWithVertexShaderSource:kPassThruVertex fragmentShaderSource:kPassThruFragment];
    if (result) {
        // 绑定的操作必须要在link之前进行，link成功之后生效
        GLint attributeLocation[ShaderAttributeIndexCount] = {ShaderAttributeIndexPosition, ShaderAttributeIndexCoordinate};
        GLchar *attributeName[ShaderAttributeIndexCount] = {"position", "inputCoordinate"};
            
        for (int i = 0; i < ShaderAttributeIndexCount; i++) {
            glBindAttribLocation(_program, attributeLocation[i], attributeName[i]);
        }
    }
    return result;
}

- (void)setupProgramAndViewport {
    [self setupProgramAndViewport6];
}

- (GLKTextureInfo *)textureInfoForTest {
    // 加载图片纹理
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"saber" ofType:@"jpeg"];//1280*1024
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"xianhua" ofType:@"png"];// 64*64
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];

    NSDictionary *optionDict = @{GLKTextureLoaderOriginBottomLeft : @(YES)};
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:image.CGImage options:optionDict error:nil];
    return textureInfo;
}

- (void)setupProgramAndViewport0 {
    glUseProgram(_program);
    
    glViewport(0, 0, _width, _height);
    
    // 设置顶点数组
    const VertexAndCoordinate vertices[] = {
        {GLKVector3Make(-0.5, 0.5, 0), GLKVector2Make(0.0, 1.0)},
        {GLKVector3Make(0.5, 0.5, 0), GLKVector2Make(1.0, 1.0)},
        {GLKVector3Make(-0.5, -0.5, 0), GLKVector2Make(0.0, 0.0)},
        {GLKVector3Make(0.5, -0.5, 0), GLKVector2Make(1.0, 0.0)},
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
    
    
    // 加载图片纹理
    GLKTextureInfo *textureInfo = [self textureInfoForTest];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureInfo.name);
    glUniform1i(0, 0);
    
    
}

- (void)setupProgramAndViewport3 {
    glUseProgram(_program);
    
    glViewport(0, 0, _width, _height);
    
    
    
    // 设置顶点数组
    const VertexAndCoordinate vertices[] = {
        {GLKVector3Make(-0.75, 0.75, 0), GLKVector2Make(0.0, 1.0)},
        {GLKVector3Make(-0.25, 0.75, 0), GLKVector2Make(1.0, 1.0)},
        {GLKVector3Make(-0.75, 0.25, 0), GLKVector2Make(0.0, 0.0)},
        {GLKVector3Make(-0.25, 0.25, 0), GLKVector2Make(1.0, 0.0)},
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
    
    
    // 加载图片纹理
    GLKTextureInfo *textureInfo = [self textureInfoForTest];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureInfo.name);
    glUniform1i(0, 0);
    
}

// 用几何方法把顶点算出来
- (void)setupProgramAndViewport4 {
    glUseProgram(_program);
    
    glViewport(0, 0, _width, _height);
    
    CGFloat leftX = -0.75;
    CGFloat topY = 0.75;
    CGFloat rightX = -0.25;
    CGFloat bottomY = 0.25;
    
    CGFloat xRatio = 1;
    CGFloat yRation = 1;
    if (self.width > self.height) {
        xRatio = self.height / self.width;
        yRation = 1;
    } else {
        xRatio = 1;
        yRation = self.width / self.height;
    }
    
    /**
     计算公式
     CGFloat width = (rightX - leftX) * xRatio;
     CGFloat height = (topY - bottomY) * yRation;
     
     CGFloat centerX = (rightX + leftX) / 2;
     CGFloat centerY = (topY + bottomY) / 2;
     
     
     CGFloat newLeftX = centerX - width / 2 = (rightX + leftX) / 2 - (rightX - leftX) * xRatio / 2;
     CGFloat newTopY = centerY + height / 2 = (topY + bottomY) / 2 + (topY - bottomY) * yRation / 2
                                             = (1 + yRation) * topY / 2 + (1 - yRation) * bottomY / 2;
                                             = ((1 + yRation) * topY + (1 - yRation) * bottomY) / 2;
     
     CGFloat newRightX = centerX + width / 2 = (rightX + leftX) / 2 + (rightX - leftX) * xRatio / 2;
     CGFloat newBottomY = centerY - height / 2 = (topY + bottomY) / 2 - (topY - bottomY) * yRation / 2
                                             = (1 - yRation) * topY / 2 + (1 + yRation) * bottomY / 2;
                                             = ((1 - yRation) * topY + (1 + yRation) * bottomY) / 2;
     
     */
    CGFloat dstLeftX = ((1 - xRatio) * rightX + (1 + xRatio) * leftX) / 2;
    CGFloat dstTopY = ((1 + yRation) * topY + (1 - yRation) * bottomY) / 2;
    CGFloat dstRightX = ((1 + xRatio) * rightX + (1 - xRatio) * leftX) / 2;
    CGFloat dstBottomY = ((1 - yRation) * topY + (1 + yRation) * bottomY) / 2;
    
    // 设置顶点数组
    const VertexAndCoordinate vertices[] = {
        {GLKVector3Make(dstLeftX, dstTopY, 0.0f), GLKVector2Make(0.0, 1.0)},//topLeft
        {GLKVector3Make(dstRightX, dstTopY, 0.0f), GLKVector2Make(1.0, 1.0)},//topRight
        {GLKVector3Make(dstLeftX, dstBottomY, 0.0f), GLKVector2Make(0.0, 0.0)},// bottomLeft
        {GLKVector3Make(dstRightX, dstBottomY, 0.0f), GLKVector2Make(1.0, 0.0)},// bottomRight
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
    
    
    // 加载图片纹理
    GLKTextureInfo *textureInfo = [self textureInfoForTest];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureInfo.name);
    glUniform1i(0, 0);
    
}

// 也可以先确定目标frame，再反过来计算顶点
- (void)setupProgramAndViewport5 {
    glUseProgram(_program);
    
    glViewport(0, 0, _width, _height);
    
    CGFloat width = MIN(self.width, self.height) * 0.25;
    CGSize size = CGSizeMake(width, width);
    CGRect rect = CGRectMake(self.width / 4 - size.width / 2, self.height / 4 - size.height / 2, width, width);
    
    // 归一化
    CGRect normalizedRect = CGRectMake(rect.origin.x / self.width,
                                       rect.origin.y / self.height,
                                       rect.size.width / self.width,
                                       rect.size.height / self.height);
    
    // 转换到（-1， 1）区间
    /**
     x坐标 = normalizedValue * 2 - 1
     y坐标 = (normalizedValue * 2 - 1) * -1
     宽高 = normalizedValue * 2
     */
    CGRect finalRect = CGRectMake(normalizedRect.origin.x * 2 - 1,
                                  (normalizedRect.origin.y * 2 - 1) * -1,
                                  normalizedRect.size.width * 2,
                                  normalizedRect.size.height * 2);
    
    // 设置顶点数组
    // 注意：先用CGRect转换区间，则计算y坐标的时候会不一样 ！！！
    
    const VertexAndCoordinate vertices[] = {
        {GLKVector3Make(finalRect.origin.x, finalRect.origin.y, 0.0f), GLKVector2Make(0.0, 1.0)},//topLeft
        {GLKVector3Make(finalRect.origin.x + finalRect.size.width, finalRect.origin.y, 0.0f), GLKVector2Make(1.0, 1.0)},//topRight
        {GLKVector3Make(finalRect.origin.x, finalRect.origin.y - finalRect.size.height, 0.0f), GLKVector2Make(0.0, 0.0)},// bottomLeft
        {GLKVector3Make(finalRect.origin.x + finalRect.size.width, finalRect.origin.y - finalRect.size.height, 0.0f), GLKVector2Make(1.0, 0.0)},// bottomRight
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
    
    
    // 加载图片纹理
    GLKTextureInfo *textureInfo = [self textureInfoForTest];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureInfo.name);
    glUniform1i(0, 0);
    
}

- (void)setupProgramAndViewport6 {
    // 先确定frame，再根据屏幕宽高归一化计算顶点位置
    glUseProgram(_program);
    glViewport(0, 0, _width, _height);
    
    CGFloat width = MIN(self.width, self.height) * 0.25;
    CGSize size = CGSizeMake(width, width);
    CGRect rect = CGRectMake(self.width / 4 - size.width / 2, self.height / 4 - size.height / 2, width, width);
    
    // 归一化
    CGRect normalizedRect = CGRectMake(rect.origin.x / self.width,
                                       rect.origin.y / self.height,
                                       rect.size.width / self.width,
                                       rect.size.height / self.height);
    
    // 归一化以后的顶点
    GLKVector3 normalizedVertices[] = {
        GLKVector3Make(normalizedRect.origin.x, normalizedRect.origin.y, 0.0f), //topLeft
        GLKVector3Make(normalizedRect.origin.x + normalizedRect.size.width, normalizedRect.origin.y, 0.0f),  //topRight
        GLKVector3Make(normalizedRect.origin.x, normalizedRect.origin.y + normalizedRect.size.height, 0.0f), // bottomLeft
        GLKVector3Make(normalizedRect.origin.x + normalizedRect.size.width, normalizedRect.origin.y + normalizedRect.size.height, 0.0f), //bottomRight
    };
    
    /**
     转换到（-1， 1）区间 公式
     x坐标 = normalizedValue * 2 - 1
     y坐标 = (normalizedValue * 2 - 1) * -1
     */
    
    // 设置顶点数组
    const VertexAndCoordinate vertices[] = {
        {GLKVector3Make(normalizedVertices[0].x * 2 - 1, 1 - normalizedVertices[0].y * 2, 0.0f), GLKVector2Make(0.0, 1.0)},//topLeft
        {GLKVector3Make(normalizedVertices[1].x * 2 - 1, 1 - normalizedVertices[1].y * 2, 0.0f), GLKVector2Make(1.0, 1.0)},//topRight
        {GLKVector3Make(normalizedVertices[2].x * 2 - 1, 1 - normalizedVertices[2].y * 2, 0.0f), GLKVector2Make(0.0, 0.0)},// bottomLeft
        {GLKVector3Make(normalizedVertices[3].x * 2 - 1, 1 - normalizedVertices[3].y * 2, 0.0f), GLKVector2Make(1.0, 0.0)},// bottomRight
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
    
    
    // 加载图片纹理
    GLKTextureInfo *textureInfo = [self textureInfoForTest];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureInfo.name);
    glUniform1i(0, 0);
    
}



- (void)displayContent {
    

    glClearColor(0.0, 0.25, 0.25f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Draw triangle
    // GL_TRIANGLE_STRIP的方式是固定的顶点顺序还绘制三角形的
    /**
     if n % 2 == 0 {
         vertex = [n-1, n-2, n]
     } else {
         vertex = [n-2, n-1, n]
     }
     即画出来的三角形一定是（v1, v0, v2）, (v1, v2, v3), (v3, v2, v4)... 这样的顺序
     */
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
}


@end
