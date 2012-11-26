//
//  EJBindingWebGLCanvas.m
//  EjectaGL
//
//  Created by vikram on 11/24/12.
//
//

#import "EJBindingWebGLCanvas.h"
#import "EJBindingWebGLBuffer.h"
#import "EJBindingWebGLProgram.h"
#import "EJBindingWebGLShader.h"
#import "EJBindingWebGLUniformLocation.h"
#import "EJBindingFloat32Array.h"

@implementation EJBindingWebGLCanvas

- (id)initWithContext:(JSContextRef)ctx object:(JSObjectRef)obj argc:(size_t)argc argv:(const JSValueRef [])argv {
	if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {
        
		ejectaInstance = [EJApp instance]; // Keep a local copy - may be faster?
		useRetinaResolution = true;

        CGSize screen = [EJApp instance].view.bounds.size;
        contentScale = (useRetinaResolution && [UIScreen mainScreen].scale == 2) ? 2 : 1;
        
        width = screen.width * contentScale;
        height = screen.height * contentScale;
	}
	return self;
}

- (void)dealloc {
	[webGLContext release];
	[super dealloc];
}

/*** CONSTANTS ***/

/* ClearBufferMask */
EJ_DEFINE_NUMBER_CONST(DEPTH_BUFFER_BIT,   0x00000100)
EJ_DEFINE_NUMBER_CONST(STENCIL_BUFFER_BIT, 0x00000400)
EJ_DEFINE_NUMBER_CONST(COLOR_BUFFER_BIT,   0x00004000)

/* Boolean */
EJ_DEFINE_NUMBER_CONST(FALSE, 0)
EJ_DEFINE_NUMBER_CONST(TRUE,  1)

/* BeginMode */
EJ_DEFINE_NUMBER_CONST(POINTS,                         0x0000)
EJ_DEFINE_NUMBER_CONST(LINES,                          0x0001)
EJ_DEFINE_NUMBER_CONST(LINE_LOOP,                      0x0002)
EJ_DEFINE_NUMBER_CONST(LINE_STRIP,                     0x0003)
EJ_DEFINE_NUMBER_CONST(TRIANGLES,                      0x0004)
EJ_DEFINE_NUMBER_CONST(TRIANGLE_STRIP,                 0x0005)
EJ_DEFINE_NUMBER_CONST(TRIANGLE_FAN,                   0x0006)

/* AlphaFunction (not supported in ES20) */
/*      GL_NEVER */
/*      GL_LESS */
/*      GL_EQUAL */
/*      GL_LEQUAL */
/*      GL_GREATER */
/*      GL_NOTEQUAL */
/*      GL_GEQUAL */
/*      GL_ALWAYS */

/* BlendingFactorDest */
EJ_DEFINE_NUMBER_CONST(ZERO,                           0)
EJ_DEFINE_NUMBER_CONST(ONE,                            1)
EJ_DEFINE_NUMBER_CONST(SRC_COLOR,                      0x0300)
EJ_DEFINE_NUMBER_CONST(ONE_MINUS_SRC_COLOR,            0x0301)
EJ_DEFINE_NUMBER_CONST(SRC_ALPHA,                      0x0302)
EJ_DEFINE_NUMBER_CONST(ONE_MINUS_SRC_ALPHA,            0x0303)
EJ_DEFINE_NUMBER_CONST(DST_ALPHA,                      0x0304)
EJ_DEFINE_NUMBER_CONST(ONE_MINUS_DST_ALPHA,            0x0305)

/* BlendingFactorSrc */
/*      GL_ZERO */
/*      GL_ONE */
EJ_DEFINE_NUMBER_CONST(DST_COLOR,                      0x0306)
EJ_DEFINE_NUMBER_CONST(ONE_MINUS_DST_COLOR,            0x0307)
EJ_DEFINE_NUMBER_CONST(SRC_ALPHA_SATURATE,             0x0308)
/*      GL_SRC_ALPHA */
/*      GL_ONE_MINUS_SRC_ALPHA */
/*      GL_DST_ALPHA */
/*      GL_ONE_MINUS_DST_ALPHA */

/* BlendEquationSeparate */
EJ_DEFINE_NUMBER_CONST(FUNC_ADD,                       0x8006)
EJ_DEFINE_NUMBER_CONST(BLEND_EQUATION,                 0x8009)
EJ_DEFINE_NUMBER_CONST(BLEND_EQUATION_RGB,             0x8009)    /* same as BLEND_EQUATION */
EJ_DEFINE_NUMBER_CONST(BLEND_EQUATION_ALPHA,           0x883D)

/* BlendSubtract */
EJ_DEFINE_NUMBER_CONST(FUNC_SUBTRACT,                  0x800A)
EJ_DEFINE_NUMBER_CONST(FUNC_REVERSE_SUBTRACT,          0x800B)

/* Separate Blend Functions */
EJ_DEFINE_NUMBER_CONST(BLEND_DST_RGB,                  0x80C8)
EJ_DEFINE_NUMBER_CONST(BLEND_SRC_RGB,                  0x80C9)
EJ_DEFINE_NUMBER_CONST(BLEND_DST_ALPHA,                0x80CA)
EJ_DEFINE_NUMBER_CONST(BLEND_SRC_ALPHA,                0x80CB)
EJ_DEFINE_NUMBER_CONST(CONSTANT_COLOR,                 0x8001)
EJ_DEFINE_NUMBER_CONST(ONE_MINUS_CONSTANT_COLOR,       0x8002)
EJ_DEFINE_NUMBER_CONST(CONSTANT_ALPHA,                 0x8003)
EJ_DEFINE_NUMBER_CONST(ONE_MINUS_CONSTANT_ALPHA,       0x8004)
EJ_DEFINE_NUMBER_CONST(BLEND_COLOR,                    0x8005)

/* Buffer Objects */
EJ_DEFINE_NUMBER_CONST(ARRAY_BUFFER,                   0x8892)
EJ_DEFINE_NUMBER_CONST(ELEMENT_ARRAY_BUFFER,           0x8893)
EJ_DEFINE_NUMBER_CONST(ARRAY_BUFFER_BINDING,           0x8894)
EJ_DEFINE_NUMBER_CONST(ELEMENT_ARRAY_BUFFER_BINDING,   0x8895)

EJ_DEFINE_NUMBER_CONST(STREAM_DRAW,                    0x88E0)
EJ_DEFINE_NUMBER_CONST(STATIC_DRAW,                    0x88E4)
EJ_DEFINE_NUMBER_CONST(DYNAMIC_DRAW,                   0x88E8)

EJ_DEFINE_NUMBER_CONST(BUFFER_SIZE,                    0x8764)
EJ_DEFINE_NUMBER_CONST(BUFFER_USAGE,                   0x8765)

EJ_DEFINE_NUMBER_CONST(CURRENT_VERTEX_ATTRIB,          0x8626)

/* CullFaceMode */
EJ_DEFINE_NUMBER_CONST(FRONT,                          0x0404)
EJ_DEFINE_NUMBER_CONST(BACK,                           0x0405)
EJ_DEFINE_NUMBER_CONST(FRONT_AND_BACK,                 0x0408)

/* EnableCap */
EJ_DEFINE_NUMBER_CONST(TEXTURE_2D,                     0x0DE1)
EJ_DEFINE_NUMBER_CONST(CULL_FACE,                      0x0B44)
EJ_DEFINE_NUMBER_CONST(BLEND,                          0x0BE2)
EJ_DEFINE_NUMBER_CONST(DITHER,                         0x0BD0)
EJ_DEFINE_NUMBER_CONST(STENCIL_TEST,                   0x0B90)
EJ_DEFINE_NUMBER_CONST(DEPTH_TEST,                     0x0B71)
EJ_DEFINE_NUMBER_CONST(SCISSOR_TEST,                   0x0C11)
EJ_DEFINE_NUMBER_CONST(POLYGON_OFFSET_FILL,            0x8037)
EJ_DEFINE_NUMBER_CONST(SAMPLE_ALPHA_TO_COVERAGE,       0x809E)
EJ_DEFINE_NUMBER_CONST(SAMPLE_COVERAGE,                0x80A0)

/* ErrorCode */
EJ_DEFINE_NUMBER_CONST(NO_ERROR,                       0)
EJ_DEFINE_NUMBER_CONST(INVALID_ENUM,                   0x0500)
EJ_DEFINE_NUMBER_CONST(INVALID_VALUE,                  0x0501)
EJ_DEFINE_NUMBER_CONST(INVALID_OPERATION,              0x0502)
EJ_DEFINE_NUMBER_CONST(OUT_OF_MEMORY,                  0x0505)

/* FrontFaceDirection */
EJ_DEFINE_NUMBER_CONST(CW,                             0x0900)
EJ_DEFINE_NUMBER_CONST(CCW,                            0x0901)

/* GetPName */
EJ_DEFINE_NUMBER_CONST(LINE_WIDTH,                     0x0B21)
EJ_DEFINE_NUMBER_CONST(ALIASED_POINT_SIZE_RANGE,       0x846D)
EJ_DEFINE_NUMBER_CONST(ALIASED_LINE_WIDTH_RANGE,       0x846E)
EJ_DEFINE_NUMBER_CONST(CULL_FACE_MODE,                 0x0B45)
EJ_DEFINE_NUMBER_CONST(FRONT_FACE,                     0x0B46)
EJ_DEFINE_NUMBER_CONST(DEPTH_RANGE,                    0x0B70)
EJ_DEFINE_NUMBER_CONST(DEPTH_WRITEMASK,                0x0B72)
EJ_DEFINE_NUMBER_CONST(DEPTH_CLEAR_VALUE,              0x0B73)
EJ_DEFINE_NUMBER_CONST(DEPTH_FUNC,                     0x0B74)
EJ_DEFINE_NUMBER_CONST(STENCIL_CLEAR_VALUE,            0x0B91)
EJ_DEFINE_NUMBER_CONST(STENCIL_FUNC,                   0x0B92)
EJ_DEFINE_NUMBER_CONST(STENCIL_FAIL,                   0x0B94)
EJ_DEFINE_NUMBER_CONST(STENCIL_PASS_DEPTH_FAIL,        0x0B95)
EJ_DEFINE_NUMBER_CONST(STENCIL_PASS_DEPTH_PASS,        0x0B96)
EJ_DEFINE_NUMBER_CONST(STENCIL_REF,                    0x0B97)
EJ_DEFINE_NUMBER_CONST(STENCIL_VALUE_MASK,             0x0B93)
EJ_DEFINE_NUMBER_CONST(STENCIL_WRITEMASK,              0x0B98)
EJ_DEFINE_NUMBER_CONST(STENCIL_BACK_FUNC,              0x8800)
EJ_DEFINE_NUMBER_CONST(STENCIL_BACK_FAIL,              0x8801)
EJ_DEFINE_NUMBER_CONST(STENCIL_BACK_PASS_DEPTH_FAIL,   0x8802)
EJ_DEFINE_NUMBER_CONST(STENCIL_BACK_PASS_DEPTH_PASS,   0x8803)
EJ_DEFINE_NUMBER_CONST(STENCIL_BACK_REF,               0x8CA3)
EJ_DEFINE_NUMBER_CONST(STENCIL_BACK_VALUE_MASK,        0x8CA4)
EJ_DEFINE_NUMBER_CONST(STENCIL_BACK_WRITEMASK,         0x8CA5)
EJ_DEFINE_NUMBER_CONST(VIEWPORT,                       0x0BA2)
EJ_DEFINE_NUMBER_CONST(SCISSOR_BOX,                    0x0C10)
/*      GL_SCISSOR_TEST */
EJ_DEFINE_NUMBER_CONST(COLOR_CLEAR_VALUE,              0x0C22)
EJ_DEFINE_NUMBER_CONST(COLOR_WRITEMASK,                0x0C23)
EJ_DEFINE_NUMBER_CONST(UNPACK_ALIGNMENT,               0x0CF5)
EJ_DEFINE_NUMBER_CONST(PACK_ALIGNMENT,                 0x0D05)
EJ_DEFINE_NUMBER_CONST(MAX_TEXTURE_SIZE,               0x0D33)
EJ_DEFINE_NUMBER_CONST(MAX_VIEWPORT_DIMS,              0x0D3A)
EJ_DEFINE_NUMBER_CONST(SUBPIXEL_BITS,                  0x0D50)
EJ_DEFINE_NUMBER_CONST(RED_BITS,                       0x0D52)
EJ_DEFINE_NUMBER_CONST(GREEN_BITS,                     0x0D53)
EJ_DEFINE_NUMBER_CONST(BLUE_BITS,                      0x0D54)
EJ_DEFINE_NUMBER_CONST(ALPHA_BITS,                     0x0D55)
EJ_DEFINE_NUMBER_CONST(DEPTH_BITS,                     0x0D56)
EJ_DEFINE_NUMBER_CONST(STENCIL_BITS,                   0x0D57)
EJ_DEFINE_NUMBER_CONST(POLYGON_OFFSET_UNITS,           0x2A00)
/*      GL_POLYGON_OFFSET_FILL */
EJ_DEFINE_NUMBER_CONST(POLYGON_OFFSET_FACTOR,          0x8038)
EJ_DEFINE_NUMBER_CONST(TEXTURE_BINDING_2D,             0x8069)
EJ_DEFINE_NUMBER_CONST(SAMPLE_BUFFERS,                 0x80A8)
EJ_DEFINE_NUMBER_CONST(SAMPLES,                        0x80A9)
EJ_DEFINE_NUMBER_CONST(SAMPLE_COVERAGE_VALUE,          0x80AA)
EJ_DEFINE_NUMBER_CONST(SAMPLE_COVERAGE_INVERT,         0x80AB)

/* GetTextureParameter */
/*      GL_TEXTURE_MAG_FILTER */
/*      GL_TEXTURE_MIN_FILTER */
/*      GL_TEXTURE_WRAP_S */
/*      GL_TEXTURE_WRAP_T */

EJ_DEFINE_NUMBER_CONST(NUM_COMPRESSED_TEXTURE_FORMATS, 0x86A2)
EJ_DEFINE_NUMBER_CONST(COMPRESSED_TEXTURE_FORMATS,     0x86A3)

/* HintMode */
EJ_DEFINE_NUMBER_CONST(DONT_CARE,                      0x1100)
EJ_DEFINE_NUMBER_CONST(FASTEST,                        0x1101)
EJ_DEFINE_NUMBER_CONST(NICEST,                         0x1102)

/* HintTarget */
EJ_DEFINE_NUMBER_CONST(GENERATE_MIPMAP_HINT,            0x8192)

/* DataType */
EJ_DEFINE_NUMBER_CONST(BYTE,                           0x1400)
EJ_DEFINE_NUMBER_CONST(UNSIGNED_BYTE,                  0x1401)
EJ_DEFINE_NUMBER_CONST(SHORT,                          0x1402)
EJ_DEFINE_NUMBER_CONST(UNSIGNED_SHORT,                 0x1403)
EJ_DEFINE_NUMBER_CONST(INT,                            0x1404)
EJ_DEFINE_NUMBER_CONST(UNSIGNED_INT,                   0x1405)
EJ_DEFINE_NUMBER_CONST(FLOAT,                          0x1406)
EJ_DEFINE_NUMBER_CONST(FIXED,                          0x140C)

/* PixelFormat */
EJ_DEFINE_NUMBER_CONST(DEPTH_COMPONENT,                0x1902)
EJ_DEFINE_NUMBER_CONST(ALPHA,                          0x1906)
EJ_DEFINE_NUMBER_CONST(RGB,                            0x1907)
EJ_DEFINE_NUMBER_CONST(RGBA,                           0x1908)
EJ_DEFINE_NUMBER_CONST(LUMINANCE,                      0x1909)
EJ_DEFINE_NUMBER_CONST(LUMINANCE_ALPHA,                0x190A)

/* PixelType */
/*      GL_UNSIGNED_BYTE */
EJ_DEFINE_NUMBER_CONST(UNSIGNED_SHORT_4_4_4_4,         0x8033)
EJ_DEFINE_NUMBER_CONST(UNSIGNED_SHORT_5_5_5_1,         0x8034)
EJ_DEFINE_NUMBER_CONST(UNSIGNED_SHORT_5_6_5,           0x8363)

/* Shaders */
EJ_DEFINE_NUMBER_CONST(FRAGMENT_SHADER,                0x8B30)
EJ_DEFINE_NUMBER_CONST(VERTEX_SHADER,                  0x8B31)
EJ_DEFINE_NUMBER_CONST(MAX_VERTEX_ATTRIBS,             0x8869)
EJ_DEFINE_NUMBER_CONST(MAX_VERTEX_UNIFORM_VECTORS,     0x8DFB)
EJ_DEFINE_NUMBER_CONST(MAX_VARYING_VECTORS,            0x8DFC)
EJ_DEFINE_NUMBER_CONST(MAX_COMBINED_TEXTURE_IMAGE_UNITS, 0x8B4D)
EJ_DEFINE_NUMBER_CONST(MAX_VERTEX_TEXTURE_IMAGE_UNITS, 0x8B4C)
EJ_DEFINE_NUMBER_CONST(MAX_TEXTURE_IMAGE_UNITS,        0x8872)
EJ_DEFINE_NUMBER_CONST(MAX_FRAGMENT_UNIFORM_VECTORS,   0x8DFD)
EJ_DEFINE_NUMBER_CONST(SHADER_TYPE,                    0x8B4F)
EJ_DEFINE_NUMBER_CONST(DELETE_STATUS,                  0x8B80)
EJ_DEFINE_NUMBER_CONST(LINK_STATUS,                    0x8B82)
EJ_DEFINE_NUMBER_CONST(VALIDATE_STATUS,                0x8B83)
EJ_DEFINE_NUMBER_CONST(ATTACHED_SHADERS,               0x8B85)
EJ_DEFINE_NUMBER_CONST(ACTIVE_UNIFORMS,                0x8B86)
EJ_DEFINE_NUMBER_CONST(ACTIVE_UNIFORM_MAX_LENGTH,      0x8B87)
EJ_DEFINE_NUMBER_CONST(ACTIVE_ATTRIBUTES,              0x8B89)
EJ_DEFINE_NUMBER_CONST(ACTIVE_ATTRIBUTE_MAX_LENGTH,    0x8B8A)
EJ_DEFINE_NUMBER_CONST(SHADING_LANGUAGE_VERSION,       0x8B8C)
EJ_DEFINE_NUMBER_CONST(CURRENT_PROGRAM,                0x8B8D)

/* StencilFunction */
EJ_DEFINE_NUMBER_CONST(NEVER,                          0x0200)
EJ_DEFINE_NUMBER_CONST(LESS,                           0x0201)
EJ_DEFINE_NUMBER_CONST(EQUAL,                          0x0202)
EJ_DEFINE_NUMBER_CONST(LEQUAL,                         0x0203)
EJ_DEFINE_NUMBER_CONST(GREATER,                        0x0204)
EJ_DEFINE_NUMBER_CONST(NOTEQUAL,                       0x0205)
EJ_DEFINE_NUMBER_CONST(GEQUAL,                         0x0206)
EJ_DEFINE_NUMBER_CONST(ALWAYS,                         0x0207)

/* StencilOp */
/*      GL_ZERO */
EJ_DEFINE_NUMBER_CONST(KEEP,                           0x1E00)
EJ_DEFINE_NUMBER_CONST(REPLACE,                        0x1E01)
EJ_DEFINE_NUMBER_CONST(INCR,                           0x1E02)
EJ_DEFINE_NUMBER_CONST(DECR,                           0x1E03)
EJ_DEFINE_NUMBER_CONST(INVERT,                         0x150A)
EJ_DEFINE_NUMBER_CONST(INCR_WRAP,                      0x8507)
EJ_DEFINE_NUMBER_CONST(DECR_WRAP,                      0x8508)

/* StringName */
EJ_DEFINE_NUMBER_CONST(VENDOR,                         0x1F00)
EJ_DEFINE_NUMBER_CONST(RENDERER,                       0x1F01)
EJ_DEFINE_NUMBER_CONST(VERSION,                        0x1F02)
EJ_DEFINE_NUMBER_CONST(EXTENSIONS,                     0x1F03)

/* TextureMagFilter */
EJ_DEFINE_NUMBER_CONST(NEAREST,                        0x2600)
EJ_DEFINE_NUMBER_CONST(LINEAR,                         0x2601)

/* TextureMinFilter */
/*      GL_NEAREST */
/*      GL_LINEAR */
EJ_DEFINE_NUMBER_CONST(NEAREST_MIPMAP_NEAREST,         0x2700)
EJ_DEFINE_NUMBER_CONST(LINEAR_MIPMAP_NEAREST,          0x2701)
EJ_DEFINE_NUMBER_CONST(NEAREST_MIPMAP_LINEAR,          0x2702)
EJ_DEFINE_NUMBER_CONST(LINEAR_MIPMAP_LINEAR,           0x2703)

/* TextureParameterName */
EJ_DEFINE_NUMBER_CONST(TEXTURE_MAG_FILTER,             0x2800)
EJ_DEFINE_NUMBER_CONST(TEXTURE_MIN_FILTER,             0x2801)
EJ_DEFINE_NUMBER_CONST(TEXTURE_WRAP_S,                 0x2802)
EJ_DEFINE_NUMBER_CONST(TEXTURE_WRAP_T,                 0x2803)

/* TextureTarget */
/*      GL_TEXTURE_2D */
EJ_DEFINE_NUMBER_CONST(TEXTURE,                        0x1702)

EJ_DEFINE_NUMBER_CONST(TEXTURE_CUBE_MAP,               0x8513)
EJ_DEFINE_NUMBER_CONST(TEXTURE_BINDING_CUBE_MAP,       0x8514)
EJ_DEFINE_NUMBER_CONST(TEXTURE_CUBE_MAP_POSITIVE_X,    0x8515)
EJ_DEFINE_NUMBER_CONST(TEXTURE_CUBE_MAP_NEGATIVE_X,    0x8516)
EJ_DEFINE_NUMBER_CONST(TEXTURE_CUBE_MAP_POSITIVE_Y,    0x8517)
EJ_DEFINE_NUMBER_CONST(TEXTURE_CUBE_MAP_NEGATIVE_Y,    0x8518)
EJ_DEFINE_NUMBER_CONST(TEXTURE_CUBE_MAP_POSITIVE_Z,    0x8519)
EJ_DEFINE_NUMBER_CONST(TEXTURE_CUBE_MAP_NEGATIVE_Z,    0x851A)
EJ_DEFINE_NUMBER_CONST(MAX_CUBE_MAP_TEXTURE_SIZE,      0x851C)

/* TextureUnit */
EJ_DEFINE_NUMBER_CONST(TEXTURE0,                       0x84C0)
EJ_DEFINE_NUMBER_CONST(TEXTURE1,                       0x84C1)
EJ_DEFINE_NUMBER_CONST(TEXTURE2,                       0x84C2)
EJ_DEFINE_NUMBER_CONST(TEXTURE3,                       0x84C3)
EJ_DEFINE_NUMBER_CONST(TEXTURE4,                       0x84C4)
EJ_DEFINE_NUMBER_CONST(TEXTURE5,                       0x84C5)
EJ_DEFINE_NUMBER_CONST(TEXTURE6,                       0x84C6)
EJ_DEFINE_NUMBER_CONST(TEXTURE7,                       0x84C7)
EJ_DEFINE_NUMBER_CONST(TEXTURE8,                       0x84C8)
EJ_DEFINE_NUMBER_CONST(TEXTURE9,                       0x84C9)
EJ_DEFINE_NUMBER_CONST(TEXTURE10,                      0x84CA)
EJ_DEFINE_NUMBER_CONST(TEXTURE11,                      0x84CB)
EJ_DEFINE_NUMBER_CONST(TEXTURE12,                      0x84CC)
EJ_DEFINE_NUMBER_CONST(TEXTURE13,                      0x84CD)
EJ_DEFINE_NUMBER_CONST(TEXTURE14,                      0x84CE)
EJ_DEFINE_NUMBER_CONST(TEXTURE15,                      0x84CF)
EJ_DEFINE_NUMBER_CONST(TEXTURE16,                      0x84D0)
EJ_DEFINE_NUMBER_CONST(TEXTURE17,                      0x84D1)
EJ_DEFINE_NUMBER_CONST(TEXTURE18,                      0x84D2)
EJ_DEFINE_NUMBER_CONST(TEXTURE19,                      0x84D3)
EJ_DEFINE_NUMBER_CONST(TEXTURE20,                      0x84D4)
EJ_DEFINE_NUMBER_CONST(TEXTURE21,                      0x84D5)
EJ_DEFINE_NUMBER_CONST(TEXTURE22,                      0x84D6)
EJ_DEFINE_NUMBER_CONST(TEXTURE23,                      0x84D7)
EJ_DEFINE_NUMBER_CONST(TEXTURE24,                      0x84D8)
EJ_DEFINE_NUMBER_CONST(TEXTURE25,                      0x84D9)
EJ_DEFINE_NUMBER_CONST(TEXTURE26,                      0x84DA)
EJ_DEFINE_NUMBER_CONST(TEXTURE27,                      0x84DB)
EJ_DEFINE_NUMBER_CONST(TEXTURE28,                      0x84DC)
EJ_DEFINE_NUMBER_CONST(TEXTURE29,                      0x84DD)
EJ_DEFINE_NUMBER_CONST(TEXTURE30,                      0x84DE)
EJ_DEFINE_NUMBER_CONST(TEXTURE31,                      0x84DF)
EJ_DEFINE_NUMBER_CONST(ACTIVE_TEXTURE,                 0x84E0)

/* TextureWrapMode */
EJ_DEFINE_NUMBER_CONST(REPEAT,                         0x2901)
EJ_DEFINE_NUMBER_CONST(CLAMP_TO_EDGE,                  0x812F)
EJ_DEFINE_NUMBER_CONST(MIRRORED_REPEAT,                0x8370)

/* Uniform Types */
EJ_DEFINE_NUMBER_CONST(FLOAT_VEC2,                     0x8B50)
EJ_DEFINE_NUMBER_CONST(FLOAT_VEC3,                     0x8B51)
EJ_DEFINE_NUMBER_CONST(FLOAT_VEC4,                     0x8B52)
EJ_DEFINE_NUMBER_CONST(INT_VEC2,                       0x8B53)
EJ_DEFINE_NUMBER_CONST(INT_VEC3,                       0x8B54)
EJ_DEFINE_NUMBER_CONST(INT_VEC4,                       0x8B55)
EJ_DEFINE_NUMBER_CONST(BOOL,                           0x8B56)
EJ_DEFINE_NUMBER_CONST(BOOL_VEC2,                      0x8B57)
EJ_DEFINE_NUMBER_CONST(BOOL_VEC3,                      0x8B58)
EJ_DEFINE_NUMBER_CONST(BOOL_VEC4,                      0x8B59)
EJ_DEFINE_NUMBER_CONST(FLOAT_MAT2,                     0x8B5A)
EJ_DEFINE_NUMBER_CONST(FLOAT_MAT3,                     0x8B5B)
EJ_DEFINE_NUMBER_CONST(FLOAT_MAT4,                     0x8B5C)
EJ_DEFINE_NUMBER_CONST(SAMPLER_2D,                     0x8B5E)
EJ_DEFINE_NUMBER_CONST(SAMPLER_CUBE,                   0x8B60)

/* Vertex Arrays */
EJ_DEFINE_NUMBER_CONST(VERTEX_ATTRIB_ARRAY_ENABLED,    0x8622)
EJ_DEFINE_NUMBER_CONST(VERTEX_ATTRIB_ARRAY_SIZE,       0x8623)
EJ_DEFINE_NUMBER_CONST(VERTEX_ATTRIB_ARRAY_STRIDE,     0x8624)
EJ_DEFINE_NUMBER_CONST(VERTEX_ATTRIB_ARRAY_TYPE,       0x8625)
EJ_DEFINE_NUMBER_CONST(VERTEX_ATTRIB_ARRAY_NORMALIZED, 0x886A)
EJ_DEFINE_NUMBER_CONST(VERTEX_ATTRIB_ARRAY_POINTER,    0x8645)
EJ_DEFINE_NUMBER_CONST(VERTEX_ATTRIB_ARRAY_BUFFER_BINDING, 0x889F)

/* Read Format */
EJ_DEFINE_NUMBER_CONST(IMPLEMENTATION_COLOR_READ_TYPE,   0x8B9A)
EJ_DEFINE_NUMBER_CONST(IMPLEMENTATION_COLOR_READ_FORMAT, 0x8B9B)

/* Shader Source */
EJ_DEFINE_NUMBER_CONST(COMPILE_STATUS,                 0x8B81)
EJ_DEFINE_NUMBER_CONST(INFO_LOG_LENGTH,                0x8B84)
EJ_DEFINE_NUMBER_CONST(SHADER_SOURCE_LENGTH,           0x8B88)
EJ_DEFINE_NUMBER_CONST(SHADER_COMPILER,                0x8DFA)

/* Shader Binary */
EJ_DEFINE_NUMBER_CONST(SHADER_BINARY_FORMATS,          0x8DF8)
EJ_DEFINE_NUMBER_CONST(NUM_SHADER_BINARY_FORMATS,      0x8DF9)

/* Shader Precision-Specified Types */
EJ_DEFINE_NUMBER_CONST(LOW_FLOAT,                  0x8DF0)
EJ_DEFINE_NUMBER_CONST(MEDIUM_FLOAT,               0x8DF1)
EJ_DEFINE_NUMBER_CONST(HIGH_FLOAT,                 0x8DF2)
EJ_DEFINE_NUMBER_CONST(LOW_INT,                    0x8DF3)
EJ_DEFINE_NUMBER_CONST(MEDIUM_INT,                 0x8DF4)
EJ_DEFINE_NUMBER_CONST(HIGH_INT,                   0x8DF5)

/* Framebuffer Object. */
EJ_DEFINE_NUMBER_CONST(FRAMEBUFFER,                                      0x8D40)
EJ_DEFINE_NUMBER_CONST(RENDERBUFFER,                                     0x8D41)

EJ_DEFINE_NUMBER_CONST(RGBA4,                                            0x8056)
EJ_DEFINE_NUMBER_CONST(RGB5_A1,                                          0x8057)
EJ_DEFINE_NUMBER_CONST(RGB565,                                           0x8D62)
EJ_DEFINE_NUMBER_CONST(DEPTH_COMPONENT16,                                0x81A5)
EJ_DEFINE_NUMBER_CONST(STENCIL_INDEX,                                    0x1901)
EJ_DEFINE_NUMBER_CONST(STENCIL_INDEX8,                                   0x8D48)

EJ_DEFINE_NUMBER_CONST(RENDERBUFFER_WIDTH,                               0x8D42)
EJ_DEFINE_NUMBER_CONST(RENDERBUFFER_HEIGHT,                              0x8D43)
EJ_DEFINE_NUMBER_CONST(RENDERBUFFER_INTERNAL_FORMAT,                     0x8D44)
EJ_DEFINE_NUMBER_CONST(RENDERBUFFER_RED_SIZE,                            0x8D50)
EJ_DEFINE_NUMBER_CONST(RENDERBUFFER_GREEN_SIZE,                          0x8D51)
EJ_DEFINE_NUMBER_CONST(RENDERBUFFER_BLUE_SIZE,                           0x8D52)
EJ_DEFINE_NUMBER_CONST(RENDERBUFFER_ALPHA_SIZE,                          0x8D53)
EJ_DEFINE_NUMBER_CONST(RENDERBUFFER_DEPTH_SIZE,                          0x8D54)
EJ_DEFINE_NUMBER_CONST(RENDERBUFFER_STENCIL_SIZE,                        0x8D55)

EJ_DEFINE_NUMBER_CONST(FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE,               0x8CD0)
EJ_DEFINE_NUMBER_CONST(FRAMEBUFFER_ATTACHMENT_OBJECT_NAME,               0x8CD1)
EJ_DEFINE_NUMBER_CONST(FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL,             0x8CD2)
EJ_DEFINE_NUMBER_CONST(FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE,     0x8CD3)

EJ_DEFINE_NUMBER_CONST(COLOR_ATTACHMENT0,                                0x8CE0)
EJ_DEFINE_NUMBER_CONST(DEPTH_ATTACHMENT,                                 0x8D00)
EJ_DEFINE_NUMBER_CONST(STENCIL_ATTACHMENT,                               0x8D20)

EJ_DEFINE_NUMBER_CONST(NONE,                                             0)

EJ_DEFINE_NUMBER_CONST(FRAMEBUFFER_COMPLETE,                             0x8CD5)
EJ_DEFINE_NUMBER_CONST(FRAMEBUFFER_INCOMPLETE_ATTACHMENT,                0x8CD6)
EJ_DEFINE_NUMBER_CONST(FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT,        0x8CD7)
EJ_DEFINE_NUMBER_CONST(FRAMEBUFFER_INCOMPLETE_DIMENSIONS,                0x8CD9)
EJ_DEFINE_NUMBER_CONST(FRAMEBUFFER_UNSUPPORTED,                          0x8CDD)

EJ_DEFINE_NUMBER_CONST(FRAMEBUFFER_BINDING,                              0x8CA6)
EJ_DEFINE_NUMBER_CONST(RENDERBUFFER_BINDING,                             0x8CA7)
EJ_DEFINE_NUMBER_CONST(MAX_RENDERBUFFER_SIZE,                            0x84E8)

EJ_DEFINE_NUMBER_CONST(INVALID_FRAMEBUFFER_OPERATION,                    0x0506)

/* WebGL-specific enums */
EJ_DEFINE_NUMBER_CONST(UNPACK_FLIP_Y_WEBGL,                0x9240)
EJ_DEFINE_NUMBER_CONST(UNPACK_PREMULTIPLY_ALPHA_WEBGL,     0x9241)
EJ_DEFINE_NUMBER_CONST(CONTEXT_LOST_WEBGL,                 0x9242)
EJ_DEFINE_NUMBER_CONST(UNPACK_COLORSPACE_CONVERSION_WEBGL, 0x9243)
EJ_DEFINE_NUMBER_CONST(BROWSER_DEFAULT_WEBGL,              0x9244)

/*** PROPERTIES ***/

EJ_BIND_GET(width, ctx) {
	return JSValueMakeNumber(ctx, width);
}

EJ_BIND_SET(width, ctx, value) {
    NSLog(@"Warning: Can't change canvas width");
}

EJ_BIND_GET(height, ctx) {
	return JSValueMakeNumber(ctx, height);
}

EJ_BIND_SET(height, ctx, value) {
    NSLog(@"Warning: Can't change canvas height");
}

/*** FUNCTIONS ***/

/** Canvas functions **/

EJ_BIND_FUNCTION(getContext, ctx, argc, argv) {
	if( argc < 1 || ![JSValueToNSString(ctx, argv[0]) isEqualToString:@"experimental-webgl"] ) {
		return NULL;
	};
	
	if( webGLContext ) { return jsObject; }
	ejectaInstance.currentWebGLContext = nil;
    
    webGLContext = [[EJWebGLContextScreen alloc] initWithWidth:width height:height contentScale:contentScale];
	
	[webGLContext create];
	ejectaInstance.currentWebGLContext = webGLContext;
    
	// Context and canvas are one and the same object, so getContext just
	// returns itself
	return jsObject;
}

/** Context functions **/

// TODO(vikram): Arrange the functions in the order in which they appear
// in the WebGL specs - http://www.khronos.org/registry/webgl/specs/latest/
// instead of the alphabetical order.

EJ_BIND_FUNCTION(attachShader, ctx, argc, argv) {
    EJBindingWebGLProgram *jsProgram =
            (EJBindingWebGLProgram *)JSObjectGetPrivate((JSObjectRef)argv[0]);
    EJBindingWebGLShader *jsShader =
            (EJBindingWebGLShader *)JSObjectGetPrivate((JSObjectRef)argv[1]);
    glAttachShader(jsProgram.index, jsShader.index);
    return NULL;
}

EJ_BIND_FUNCTION(bindBuffer, ctx, argc, argv) {
    GLenum target = JSValueToNumberFast(ctx, argv[0]);
    EJBindingWebGLBuffer *jsBuffer =
            (EJBindingWebGLBuffer *)JSObjectGetPrivate((JSObjectRef)argv[1]);
    glBindBuffer(target, jsBuffer.index);
    return NULL;
}

EJ_BIND_FUNCTION(bufferData, ctx, argc, argv) {
    GLenum target = JSValueToNumberFast(ctx, argv[0]);
    GLenum usage = JSValueToNumberFast(ctx, argv[2]);
    
    NSObject <EJTypedArray> *jsTypedArray =
            (NSObject <EJTypedArray> *)JSObjectGetPrivate((JSObjectRef)argv[1]);
    
    // TODO(vikram): What's the right validation check here?
    if (jsTypedArray && (jsTypedArray.size > 0)) {
        glBufferData(target, jsTypedArray.size, jsTypedArray.data, usage);
    } else {
        NSLog(@"Warning: bufferData: Invalid typed array at position 2.");
    }
    return NULL;
}

EJ_BIND_FUNCTION(clear, ctx, argc, argv) {
    GLbitfield mask = JSValueToNumberFast(ctx, argv[0]);
    glClear(mask);
    return NULL;
}

EJ_BIND_FUNCTION(clearColor, ctx, argc, argv) {
    GLclampf
            r = JSValueToNumberFast(ctx, argv[0]),
            g = JSValueToNumberFast(ctx, argv[1]),
            b = JSValueToNumberFast(ctx, argv[2]),
            alpha = JSValueToNumberFast(ctx, argv[3]);
    
    glClearColor(r, g, b, alpha);
    return NULL;
}

EJ_BIND_FUNCTION(compileShader, ctx, argc, argv) {
    EJBindingWebGLShader *jsShader =
            (EJBindingWebGLShader *)JSObjectGetPrivate((JSObjectRef)argv[0]);
    glCompileShader(jsShader.index);
    return NULL;
}

EJ_BIND_FUNCTION(createBuffer, ctx, argc, argv) {
    GLuint buffer;
    glGenBuffers(1, &buffer);
    
    // Create a buffer class
    JSClassRef bufferClass = [
            [EJApp instance]
            getJSClassForClass:[EJBindingWebGLBuffer class]];
    JSObjectRef obj = JSObjectMake(ctx, bufferClass, NULL);
	JSValueProtect(ctx, obj);
	
	// Create the native instance
	EJBindingWebGLBuffer *jsBuffer = [
            [EJBindingWebGLBuffer alloc] initWithContext:ctx object:obj
            index:buffer];
	
	// Attach the native instance to the js object
	JSObjectSetPrivate(obj, (void *)jsBuffer);
	JSValueUnprotect(ctx, obj);
	return obj;
}

EJ_BIND_FUNCTION(createProgram, ctx, argc, argv) {
    GLuint program = glCreateProgram();
    
    // Create a shader program class
    JSClassRef programClass = [
            [EJApp instance]
            getJSClassForClass:[EJBindingWebGLProgram class]];
    JSObjectRef obj = JSObjectMake(ctx, programClass, NULL);
	JSValueProtect(ctx, obj);
	
	// Create the native instance
	EJBindingWebGLProgram *jsProgram = [
            [EJBindingWebGLProgram alloc] initWithContext:ctx object:obj
            index:program];
	
	// Attach the native instance to the js object
	JSObjectSetPrivate(obj, (void *)jsProgram);
	JSValueUnprotect(ctx, obj);
	return obj;
}

EJ_BIND_FUNCTION(createShader, ctx, argc, argv) {
    GLenum type =  JSValueToNumberFast(ctx, argv[0]);
    GLuint shader = glCreateShader(type);
    
    // Create a shader class
    JSClassRef shaderClass = [
                               [EJApp instance]
                               getJSClassForClass:[EJBindingWebGLShader class]];
    JSObjectRef obj = JSObjectMake(ctx, shaderClass, NULL);
	JSValueProtect(ctx, obj);
	
	// Create the native instance
	EJBindingWebGLShader *jsShader = [
            [EJBindingWebGLShader alloc] initWithContext:ctx object:obj
            index:shader];
	
	// Attach the native instance to the js object
	JSObjectSetPrivate(obj, (void *)jsShader);
	JSValueUnprotect(ctx, obj);
	return obj;
}

EJ_BIND_FUNCTION(cullFace, ctx, argc, argv) {
    GLenum mode = JSValueToNumberFast(ctx, argv[0]);
    glCullFace(mode);
    return NULL;
}

EJ_BIND_FUNCTION(drawArrays, ctx, argc, argv) {
    GLenum mode = JSValueToNumberFast(ctx, argv[0]);
    GLenum first = JSValueToNumberFast(ctx, argv[1]);
    GLsizei count = JSValueToNumberFast(ctx, argv[2]);
    
    glDrawArrays(mode, first, count);
    return NULL;
}

EJ_BIND_FUNCTION(drawElements, ctx, argc, argv) {
    GLenum mode = JSValueToNumberFast(ctx, argv[0]);
    GLsizei count = JSValueToNumberFast(ctx, argv[1]);
    GLenum type = JSValueToNumberFast(ctx, argv[2]);
    GLvoid *offset = (GLvoid *)((long)JSValueToNumberFast(ctx, argv[3]));
    
    glDrawElements(mode, count, type, offset);
    return NULL;
}

EJ_BIND_FUNCTION(enable, ctx, argc, argv) {
    GLenum cap = JSValueToNumberFast(ctx, argv[0]);
    glEnable(cap);
    return NULL;
}

EJ_BIND_FUNCTION(enableVertexAttribArray, ctx, argc, argv) {
    GLuint index =  JSValueToNumberFast(ctx, argv[0]);
    glEnableVertexAttribArray(index);
    return NULL;
}

EJ_BIND_FUNCTION(getAttribLocation, ctx, argc, argv) {
    EJBindingWebGLProgram *jsProgram =
            (EJBindingWebGLProgram *)JSObjectGetPrivate((JSObjectRef)argv[0]);
    NSString *name = JSValueToNSString(ctx, argv[1]);

    return JSValueMakeNumber(ctx,
                             glGetAttribLocation(jsProgram.index,
                                                 [name UTF8String]));
}

EJ_BIND_FUNCTION(getProgramParameter, ctx, argc, argv) {
    EJBindingWebGLProgram *jsProgram =
            (EJBindingWebGLProgram *)JSObjectGetPrivate((JSObjectRef)argv[0]);
    GLenum pname = JSValueToNumberFast(ctx, argv[1]);
    
    GLint value;
    glGetProgramiv(jsProgram.index, pname, &value);
    return JSValueMakeNumber(ctx, value);
}

EJ_BIND_FUNCTION(getProgramInfoLog, ctx, argc, argv) {
    EJBindingWebGLProgram *jsProgram =
    (EJBindingWebGLProgram *)JSObjectGetPrivate((JSObjectRef)argv[0]);
    
    /* Get the info log size */
    GLint size;
    glGetProgramiv(jsProgram.index, GL_INFO_LOG_LENGTH, &size);
    
    /* Get the actual log message and return it */
    GLchar *message = (GLchar *)malloc(size);
    glGetProgramInfoLog(jsProgram.index, size, &size, message);
    
    JSStringRef jss = JSStringCreateWithUTF8CString(message);
    JSValueRef ret = JSValueMakeString(ctx, jss);
    
    JSStringRelease(jss);
    free(message);
    
    return ret;
}

EJ_BIND_FUNCTION(getShaderInfoLog, ctx, argc, argv) {
    EJBindingWebGLShader *jsShader =
            (EJBindingWebGLShader *)JSObjectGetPrivate((JSObjectRef)argv[0]);

    /* Get the info log size */
    GLint size;
    glGetShaderiv(jsShader.index, GL_INFO_LOG_LENGTH, &size);
    
    /* Get the actual log message and return it */
    GLchar *message = (GLchar *)malloc(size);
    glGetShaderInfoLog(jsShader.index, size, &size, message);
    
    JSStringRef jss = JSStringCreateWithUTF8CString(message);
    JSValueRef ret = JSValueMakeString(ctx, jss);

    JSStringRelease(jss);
    free(message);
    
    return ret;
}

EJ_BIND_FUNCTION(getShaderParameter, ctx, argc, argv) {
    EJBindingWebGLShader *jsShader =
            (EJBindingWebGLShader *)JSObjectGetPrivate((JSObjectRef)argv[0]);
    GLenum pname = JSValueToNumberFast(ctx, argv[1]);
    
    GLint value;
    glGetShaderiv(jsShader.index, pname, &value);
    return JSValueMakeNumber(ctx, value);
}

EJ_BIND_FUNCTION(getUniformLocation, ctx, argc, argv) {
    EJBindingWebGLProgram *jsProgram =
            (EJBindingWebGLProgram *)JSObjectGetPrivate((JSObjectRef)argv[0]);
    NSString *name = JSValueToNSString(ctx, argv[1]);
    
    GLuint uniform = glGetUniformLocation(jsProgram.index,
                                          [name UTF8String]);
    
    // Create a uniform location class
    JSClassRef uniformClass = [
            [EJApp instance]
            getJSClassForClass:[EJBindingWebGLUniformLocation class]];
    JSObjectRef obj = JSObjectMake(ctx, uniformClass, NULL);
	JSValueProtect(ctx, obj);
	
	// Create the native instance
	EJBindingWebGLShader *jsShader = [
            [EJBindingWebGLShader alloc] initWithContext:ctx object:obj
            index:uniform];
	
	// Attach the native instance to the js object
	JSObjectSetPrivate(obj, (void *)jsShader);
	JSValueUnprotect(ctx, obj);
	return obj;
}

EJ_BIND_FUNCTION(linkProgram, ctx, argc, argv) {
    EJBindingWebGLProgram *jsProgram =
            (EJBindingWebGLProgram *)JSObjectGetPrivate((JSObjectRef)argv[0]);
    
    glLinkProgram(jsProgram.index);
    return NULL;
}

EJ_BIND_FUNCTION(shaderSource, ctx, argc, argv) {
    EJBindingWebGLShader *jsShader =
            (EJBindingWebGLShader *)JSObjectGetPrivate((JSObjectRef)argv[0]);
    const GLchar *src = [JSValueToNSString(ctx, argv[1]) UTF8String];
    
    glShaderSource(jsShader.index, 1, &src, NULL);
    return NULL;
}

EJ_BIND_FUNCTION(uniform1f, ctx, argc, argv) {
    EJBindingWebGLUniformLocation *jsUniform = [EJBindingWebGLUniformLocation fromJSValueRef:argv[0]];
    GLfloat x = JSValueToNumberFast(ctx, argv[1]);
    
    glUniform1f(jsUniform.index, x);
    return NULL;
}

EJ_BIND_FUNCTION(uniform1i, ctx, argc, argv) {
    EJBindingWebGLUniformLocation *jsUniform = [EJBindingWebGLUniformLocation fromJSValueRef:argv[0]];
    GLint x = JSValueToNumberFast(ctx, argv[1]);
    
    glUniform1i(jsUniform.index, x);
    return NULL;
}

EJ_BIND_FUNCTION(uniform3f, ctx, argc, argv) {
    EJBindingWebGLUniformLocation *jsUniform = [EJBindingWebGLUniformLocation fromJSValueRef:argv[0]];
    GLfloat x = JSValueToNumberFast(ctx, argv[1]);
    GLfloat y = JSValueToNumberFast(ctx, argv[2]);
    GLfloat z = JSValueToNumberFast(ctx, argv[3]);
    
    glUniform3f(jsUniform.index, x, y, z);
    return NULL;
}

EJ_BIND_FUNCTION(uniformMatrix4fv, ctx, argc, argv) {
    EJBindingWebGLUniformLocation *jsUniform = [EJBindingWebGLUniformLocation fromJSValueRef:argv[0]];
    GLboolean transpose = JSValueToBoolean(ctx, argv[1]);
    GLfloat value[16];
    
    JSObjectRef jsArray = (JSObjectRef)argv[2];
    for (int i = 0; i < 16; i++) {
        value[i] = JSValueToNumberFast(ctx,
                JSObjectGetPropertyAtIndex(ctx, jsArray, i, NULL));
    }
    glUniformMatrix4fv(jsUniform.index, 1, transpose, value);
    return NULL;
}

EJ_BIND_FUNCTION(useProgram, ctx, argc, argv) {
    EJBindingWebGLProgram *jsProgram =
            (EJBindingWebGLProgram *)JSObjectGetPrivate((JSObjectRef)argv[0]);
    
    glUseProgram(jsProgram.index);
    return NULL;
}

EJ_BIND_FUNCTION(vertexAttribPointer, ctx, argc, argv) {
    GLuint index = JSValueToNumberFast(ctx, argv[0]);
    GLuint itemSize = JSValueToNumberFast(ctx, argv[1]);
    GLenum type = JSValueToNumberFast(ctx, argv[2]);
    GLboolean normalized = JSValueToBoolean(ctx, argv[3]);
    GLsizei stride = JSValueToNumberFast(ctx, argv[4]);
    
    // TODO(viks): Is the following completly safe?
    GLvoid *offset = (GLvoid *)((long)JSValueToNumberFast(ctx, argv[5]));
    
    glVertexAttribPointer(index, itemSize, type, normalized, stride, offset);
    return NULL;
}

EJ_BIND_FUNCTION(viewport, ctx, argc, argv) {
    GLint x = JSValueToNumberFast(ctx, argv[0]);
    GLint y = JSValueToNumberFast(ctx, argv[1]);
    GLsizei w = JSValueToNumberFast(ctx, argv[2]);
    GLsizei h = JSValueToNumberFast(ctx, argv[3]);
    
    glViewport(x, y, w, h);
    return NULL;
}

@end
