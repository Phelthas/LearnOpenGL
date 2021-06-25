//
//  DemoGLView.h
//  Demo_OpenGLES_2
//
//  Created by billthaslu on 2021/6/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoGLView : UIView {
    EAGLContext *_context;
    GLuint _program;
    GLuint _frameBufferHandler;
    GLuint _renderBufferHandler;
    GLint _width;
    GLint _height;
}

//@property (nonatomic, strong) EAGLContext *context;
//@property (nonatomic, assign) GLuint program;
//@property (nonatomic, assign) GLuint frameBufferHandler;
//@property (nonatomic, assign) GLuint renderBufferHandler;
//@property (nonatomic, assign) GLint width;
//@property (nonatomic, assign) GLint height;

- (BOOL)loadShaders;

- (BOOL)initializeBuffer;

- (void)displayContent;

@end

NS_ASSUME_NONNULL_END
