//
//  DemoGLDefines.h
//  DemoUtils
//
//  Created by billthaslu on 2022/3/2.
//

#ifndef DemoGLDefines_h
#define DemoGLDefines_h

#ifdef __APPLE__
    #import <OpenGLES/ES2/gl.h>
    #import <OpenGLES/ES2/glext.h>
#else
    #include <GLES2/gl2.h>
    #include <GLES2/gl2ext.h>
    #include <dlfcn.h>
#endif

typedef struct {
    float v[2];
} DemoGLVector2;

typedef struct {
    float v[4];
} DemoGLVector4;

typedef struct {
    DemoGLVector2 position;
    DemoGLVector2 textureCoordinate;
} DemoGLVertex;

//typedef struct {
//    float position[4];
//    float textureCoordinate[2];
//} DemoGLVertex;

static inline const char * GetGLErrorString(GLenum error) {
    const char *str;
    switch( error )
    {
        case GL_NO_ERROR:
            str = "GL_NO_ERROR";
            break;
        case GL_INVALID_ENUM:
            str = "GL_INVALID_ENUM";
            break;
        case GL_INVALID_VALUE:
            str = "GL_INVALID_VALUE";
            break;
        case GL_INVALID_OPERATION:
            str = "GL_INVALID_OPERATION";
            break;
        case GL_INVALID_FRAMEBUFFER_OPERATION:
            str = "GL_INVALID_FRAMEBUFFER_OPERATION";
            break;
#if defined __gl_h_ || defined __gl3_h_
        case GL_OUT_OF_MEMORY:
            str = "GL_OUT_OF_MEMORY";
            break;
        case GL_INVALID_FRAMEBUFFER_OPERATION:
            str = "GL_INVALID_FRAMEBUFFER_OPERATION";
            break;
#endif
#if defined __gl_h_
        case GL_STACK_OVERFLOW:
            str = "GL_STACK_OVERFLOW";
            break;
        case GL_STACK_UNDERFLOW:
            str = "GL_STACK_UNDERFLOW";
            break;
        case GL_TABLE_TOO_LARGE:
            str = "GL_TABLE_TOO_LARGE";
            break;
#endif
        default:
            str = "(ERROR: Unknown Error Enum)";
            break;
    }
    return str;
}

#define GetGLErrorOC()                                    \
{                                                        \
    GLenum err = glGetError();                            \
    while (err != GL_NO_ERROR) {                        \
        NSLog(@"GLError:0x%X %s set in File:%s Line:%d\n", \
        err, GetGLErrorString(err), __FILE__, __LINE__);\
        err = glGetError();                                \
    }                                                    \
}

#endif /* DemoGLDefines_h */
