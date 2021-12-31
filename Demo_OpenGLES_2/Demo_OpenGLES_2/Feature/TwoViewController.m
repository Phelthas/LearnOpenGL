//
//  TwoViewController.m
//  Demo_OpenGLES_2
//
//  Created by billthaslu on 2021/7/25.
//

#import "TwoViewController.h"

@interface TwoViewController ()

@end

@implementation TwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setupGLView {
    self.glView = [[DemoGLView2 alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.glView];
}

@end




#pragma mark ----------------------------------DemoGLView2----------------------------------


#import "DemoGLUtility.h"
#import "DemoGLGeometry.h"
#import <GLKit/GLKit.h>
#import <LXMKit/LXMKit.h>

@implementation DemoGLView2

- (BOOL)loadShaders {
    BOOL result = [super loadShadersWithVertexShaderFileName:@"DemoOnlyPosition.vsh" fragmentShaderFileName:@"DemoWhiteColor.fsh"];
    return result;
}

- (void)setupProgramAndViewport {
    
    [self setupProgramAndViewport6];

}

// 直接设置正方形顶点，显示被拉伸了
- (void)setupProgramAndViewport1 {
    glUseProgram(_program);
    
    glViewport(0, 0, _width, _height);
    
    // 设置顶点数组
    const GLfloat vertices[] = {
        -0.5f,  0.5f, 0.0f,
        0.5f,  0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f,  -0.5f, 0.0f
    };
    
//    // 有问题的顺序
//    const GLKVector3 vertices[] = {
//        GLKVector3Make(-0.5f, 0.5f, 0.0f),
//        GLKVector3Make(0.5f, 0.5f, 0.0f),
//        GLKVector3Make(0.5f, -0.5f, 0.0f),
//        GLKVector3Make(-0.5f, -0.5f, 0.0f),
//    };

    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    // 传递vertices数据;3是每个顶点所占用元素个数，即这里是3个float为一个顶点
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, (GLfloat *)NULL);
    glEnableVertexAttribArray(0);
    
}

// 直接用给Y坐标乘以个系数，表现就正常了
- (void)setupProgramAndViewport2 {
    glUseProgram(_program);
    
    glViewport(0, 0, _width, _height);
    
//    CGFloat screenAspectRatio = 1;
    CGFloat screenAspectRatio = [self screenAspectRatio];
     
    // 设置顶点数组
    const GLKVector3 vertices[] = {
        GLKVector3Make(-0.5f, 0.5f * screenAspectRatio, 0.0f), //topLeft
        GLKVector3Make(0.5f, 0.5f * screenAspectRatio, 0.0f),  //topRight
        GLKVector3Make(-0.5f, -0.5f * screenAspectRatio, 0.0f), // bottomLeft
        GLKVector3Make(0.5f, -0.5f * screenAspectRatio, 0.0f),  // bottomRight
    };
    
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // 传递vertices数据;3是每个顶点所占用元素个数，即这里是3个float为一个顶点
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, (GLfloat *)NULL);
    glEnableVertexAttribArray(0);
    
}

// 但是不再中心点显示的正方形还是有问题
- (void)setupProgramAndViewport3 {
    glUseProgram(_program);
    
    glViewport(0, 0, _width, _height);
    
//    CGFloat screenAspectRatio = 1;
    CGFloat screenAspectRatio = [self screenAspectRatio];
    
    // 设置顶点数组
    const GLKVector3 vertices[] = {
        GLKVector3Make(-0.75f, 0.75f * screenAspectRatio, 0.0f), //topLeft
        GLKVector3Make(-0.25f, 0.75f * screenAspectRatio, 0.0f),  //topRight
        GLKVector3Make(-0.75f, 0.25f * screenAspectRatio, 0.0f), // bottomLeft
        GLKVector3Make(-0.25f, 0.25f * screenAspectRatio, 0.0f),  // bottomRight
    };
    
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // 传递vertices数据;3是每个顶点所占用元素个数，即这里是3个float为一个顶点
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, (GLfloat *)NULL);
    glEnableVertexAttribArray(0);
    
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
    const GLKVector3 vertices[] = {
        GLKVector3Make(dstLeftX, dstTopY, 0.0f), //topLeft
        GLKVector3Make(dstRightX, dstTopY, 0.0f),  //topRight
        GLKVector3Make(dstLeftX, dstBottomY, 0.0f), // bottomLeft
        GLKVector3Make(dstRightX, dstBottomY, 0.0f),  // bottomRight
    };
    
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // 传递vertices数据;3是每个顶点所占用元素个数，即这里是3个float为一个顶点
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, (GLfloat *)NULL);
    glEnableVertexAttribArray(0);
    
}

// 也可以先确定目标frame，再反过来计算顶点
- (void)setupProgramAndViewport5 {
    glUseProgram(_program);
    
    glViewport(0, 0, _width, _height);
    
//    CGFloat width = MIN(self.width, self.height) * 0.25;
    CGFloat width = 100;
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
    const GLKVector3 vertices[] = {
        GLKVector3Make(CGRectGetMinX(finalRect), CGRectGetMinY(finalRect), 0.0f), //topLeft
        GLKVector3Make(CGRectGetMaxX(finalRect), CGRectGetMinY(finalRect), 0.0f),  //topRight
        GLKVector3Make(CGRectGetMinX(finalRect), CGRectGetMinY(finalRect) - finalRect.size.height, 0.0f), // bottomLeft 此时坐标系已经变成向下减少，所以要减去
        GLKVector3Make(CGRectGetMaxX(finalRect), CGRectGetMinY(finalRect) - finalRect.size.height, 0.0f),  // bottomRight 此时坐标系已经变成向下减少，所以要减去
    };
    
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // 传递vertices数据;3是每个顶点所占用元素个数，即这里是3个float为一个顶点
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, (GLfloat *)NULL);
    glEnableVertexAttribArray(0);
    
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
    
    /**
     转换到（-1， 1）区间 公式
     x坐标 = normalizedValue * 2 - 1
     y坐标 = (normalizedValue * 2 - 1) * -1
     
     // 归一化以后的顶点
     GLKVector3 normalizedVertices[] = {
         GLKVector3Make(CGRectGetMinX(normalizedRect), CGRectGetMinY(normalizedRect), 0.0f), //topLeft
         GLKVector3Make(CGRectGetMaxX(normalizedRect), CGRectGetMinY(normalizedRect), 0.0f),  //topRight
         GLKVector3Make(CGRectGetMinX(normalizedRect), CGRectGetMaxY(normalizedRect), 0.0f), // bottomLeft
         GLKVector3Make(CGRectGetMaxX(normalizedRect), CGRectGetMaxY(normalizedRect), 0.0f), //bottomRight
     };
     
     // 设置顶点数组
     const GLKVector3 vertices[] = {
         GLKVector3Make(normalizedVertices[0].x * 2 - 1, 1 - normalizedVertices[0].y * 2, 0.0f), //topLeft
         GLKVector3Make(normalizedVertices[1].x * 2 - 1, 1 - normalizedVertices[1].y * 2, 0.0f),  //topRight
         GLKVector3Make(normalizedVertices[2].x * 2 - 1, 1 - normalizedVertices[2].y * 2, 0.0f), // bottomLeft
         GLKVector3Make(normalizedVertices[3].x * 2 - 1, 1 - normalizedVertices[3].y * 2, 0.0f),  // bottomRight
     };
     
     */
    const GLKVector3 vertices[] = {
        vertexConvertionFromNormalizedPoint(CGRectGetTopLeftPoint(normalizedRect)), //topLeft
        vertexConvertionFromNormalizedPoint(CGRectGetTopRightPoint(normalizedRect)),  //topRight
        vertexConvertionFromNormalizedPoint(CGRectGetBottomLeftPoint(normalizedRect)), // bottomLeft
        vertexConvertionFromNormalizedPoint(CGRectGetBottomRightPoint(normalizedRect)),  // bottomRight
    };

    
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // 传递vertices数据;3是每个顶点所占用元素个数，即这里是3个float为一个顶点
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, (GLfloat *)NULL);
    glEnableVertexAttribArray(0);
    
}

static inline GLKVector3 vertexConvertionFromNormalizedPoint(CGPoint normalizedPoint) {
    return GLKVector3Make(coordinateConvertionX(normalizedPoint.x), coordinateConvertionX(normalizedPoint.y), 0);
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
