//
//  DemoGLView.h
//  Demo_OpenGLES_2
//
//  Created by billthaslu on 2021/6/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoGLView : UIView

- (BOOL)loadShaders;

- (BOOL)initializeBuffer;

- (void)displayContent;

@end

NS_ASSUME_NONNULL_END
