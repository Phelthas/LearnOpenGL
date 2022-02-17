//
//  DemoGLView.h
//  DemoUtils
//
//  Created by billthaslu on 2022/2/9.
//

#import <UIKit/UIKit.h>
#import "DemoGLInputProtocol.h"
#import "DemoGLProgram.h"

NS_ASSUME_NONNULL_BEGIN

@interface DemoGLView : UIView<DemoGLInputProtocol>

@property (nonatomic, strong) DemoGLTextureFrame *inputFrameBufferForDisplay;
@property (nonatomic, assign) GLuint displayFramebuffer;
@property (nonatomic, assign) GLuint displayRenderbuffer;
@property (nonatomic, strong) DemoGLProgram *displayProgram;
@property (nonatomic, assign) GLint displayPositionAttribute;
@property (nonatomic, assign) GLint displayTextureCoordinateAttribute;
@property (nonatomic, assign) GLint displayInputTextureUniform;
@property (nonatomic, assign) GLint backingWidth;
@property (nonatomic, assign) GLint backingHeight;
@property (nonatomic, assign) CGSize boundsSizeForFramebuffer;

- (void)createDisplayFramebuffer;

- (void)destroyDisplayFramebuffer;

- (void)setDisplayFramebuffer;

- (void)prensentFramebuffer;

@end

NS_ASSUME_NONNULL_END
