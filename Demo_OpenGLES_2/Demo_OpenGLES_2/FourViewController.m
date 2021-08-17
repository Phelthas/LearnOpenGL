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

typedef enum : NSUInteger {
    ShaderAttributeIndexPosition = 0,
    ShaderAttributeIndexCoordinate,
    ShaderAttributeIndexCount,  //不实际使用，只是为了计数
} ShaderAttributeIndex;


@implementation DemoGLView4

- (BOOL)loadShaders {
    [EAGLContext setCurrentContext:_context];
    
    GLuint vertexShader, fragmentShader;
    _program = glCreateProgram();
    
    
    if (![DemoGLUtility complieShader:&vertexShader type:GL_VERTEX_SHADER shaderSource:kPassThruVertex]) {
        return false;
    }
    if (![DemoGLUtility complieShader:&fragmentShader type:GL_FRAGMENT_SHADER shaderSource:kPassThruFragment]) {
        return false;
    }
    
    glAttachShader(_program, vertexShader);

    glAttachShader(_program, fragmentShader);

    
    GLint attributeLocation[ShaderAttributeIndexCount] = {ShaderAttributeIndexPosition, ShaderAttributeIndexCoordinate};
    GLchar *attributeName[ShaderAttributeIndexCount] = {"position", "inputCoordinate"};
        
    for (int i = 0; i < ShaderAttributeIndexCount; i++) {
        glBindAttribLocation(_program, attributeLocation[i], attributeName[i]);
    }
    
    
    if (![DemoGLUtility linkProgram:_program]) {
        if (vertexShader) {
            glDeleteShader(vertexShader);
        }
        if (fragmentShader) {
            glDeleteShader(fragmentShader);
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        return false;
    }
    
    if (vertexShader) {
        glDetachShader(_program, vertexShader);
        glDeleteShader(vertexShader);
    }
    if (fragmentShader) {
        glDetachShader(_program, fragmentShader);
        glDeleteShader(fragmentShader);
    }

    return true;
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
//    CGFloat leftX = leftXForSamplingSize(samplingSize);
//    CGFloat rightX = rightXForSamplingSize(samplingSize);
//    CGFloat topY = topYForSamplingSize(samplingSize);
//    CGFloat bottomY = bottomYForSamplingSize(samplingSize);
//
//    const VertexAndCoordinate vertices[] = {
//        {GLKVector3Make(-0.5, 0.5, 0), GLKVector2Make(leftX, topY)},
//        {GLKVector3Make(0.5, 0.5, 0), GLKVector2Make(rightX, topY)},
//        {GLKVector3Make(-0.5, -0.5, 0), GLKVector2Make(leftX, bottomY)},
//        {GLKVector3Make(0.5, -0.5, 0), GLKVector2Make(rightX, bottomY)},
//    };
    
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
    glUniform1i(ShaderAttributeIndexCoordinate, 0);
    
    
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
