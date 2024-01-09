//
//  DemoGLKit.h
//  DemoUtils
//
//  Created by billthaslu on 2022/2/10.
//

#ifndef DemoGLKit_h
#define DemoGLKit_h

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>


#import "DemoGLProgram.h"
#import "DemoGLContext.h"
#import "DemoGLFramebuffer.h"
#import "LXMDemoGLView.h"
#import "DemoGLCapturePipline.h"
#import "DemoGLShaders.h"
#import "DemoGLInputProtocol.h"

//----utils----start
#import "DemoGLDefines.h"
#import "DemoGLGeometry.h"
#import "DemoGLUtility.h"
#import "DemoGLModels.h"
//----utils----end


//----output----start
#import "DemoGLOutput.h"
#import "DemoGLPicture.h"
#import "DemoGLVideoCamera.h"
//----output----end


//----filter----start
#import "DemoGLFilter.h"
#import "DemoGLTestFilter.h"
#import "DemoGLTwoInputFilter.h"
#import "DemoGLMultiDrawFilter.h"
#import "DemoGLStickerFilter.h"
#import "DemoGLSpriteSheetFilter.h"
#import "DemoGLRoundRectFilter.h"
//----filter----end


#endif /* DemoGLKit_h */
