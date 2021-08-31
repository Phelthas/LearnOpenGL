//
//  ThreeViewController.m
//  Demo_OpenGLES_2
//
//  Created by billthaslu on 2021/8/15.
//

#import "ThreeViewController.h"

@interface ThreeViewController ()

@end

@implementation ThreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setupGLView {
    self.glView = [[DemoGLView3 alloc] initWithFrame:self.view.bounds];
    [self.glView loadShaders];
    [self.view addSubview:self.glView];
}

@end





#pragma mark ----------------------------------DemoGLView3----------------------------------

#import "DemoGLUtility.h"
#import <GLKit/GLKit.h>

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
    
    GLuint vertexShader;
    GLuint fragmentShader;
    _program = glCreateProgram();
    
    
    if (![DemoGLUtility complieShader:&vertexShader type:GL_VERTEX_SHADER shaderSource:kPassThruVertex]) {
        return false;
    }
    if (![DemoGLUtility complieShader:&fragmentShader type:GL_FRAGMENT_SHADER shaderSource:kPassThruFragment]) {
        return false;
    }
    
    glAttachShader(_program, vertexShader);

    glAttachShader(_program, fragmentShader);

    
    // 绑定的操作必须要在link之前进行，link成功之后生效
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
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"saber" ofType:@"jpeg"];//1280*1024
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"xianhua" ofType:@"png"];// 64*64
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];

    NSDictionary *optionDict = @{GLKTextureLoaderOriginBottomLeft : @(YES)};
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:image.CGImage options:optionDict error:nil];
    
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
