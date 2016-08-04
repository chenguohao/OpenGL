//
//  ContentView.m
//  OpenGL
//
//  Created by guohao on 3/8/2016.
//  Copyright © 2016 leomaster. All rights reserved.
//

#import "ContentView.h"
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/ES2/gl.h>


@interface ContentView(){
    GLuint _colorRenderBuffer;
    GLuint _positionSlot;
    GLuint _colorSlot;
    GLuint _projectionUniform;
}

@property (nonatomic,strong)CAEAGLLayer* eaglLayer;
@property (nonatomic,strong)EAGLContext* context;

@end

@implementation ContentView

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self setupVBOs];
        [self complie];
        [self render];
    }
    return self;
}

#pragma mark - set up

- (void)setupLayer{
    _eaglLayer = (CAEAGLLayer*)self.layer;
    _eaglLayer.opaque = YES;
}

- (void)setupContext{
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_context) {
        NSLog(@"fail to create context");
        exit(1);
    }else{
        [EAGLContext setCurrentContext:self.context];
    }
}

- (void)setupRenderBuffer{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eaglLayer];
}

- (void)setupFrameBuffer{
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
}


#pragma mark - complie shader

- (void)complie{
    
    // complie
    GLuint vertexShader = [self complieShader:@"SimpleVertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self complieShader:@"SimpleFragment" withType:GL_FRAGMENT_SHADER];
    // link
    GLuint programHandler = glCreateProgram();
    glAttachShader(programHandler, vertexShader);
    glAttachShader(programHandler, fragmentShader);
    glLinkProgram(programHandler);
    GLint linkStatus;
    glGetProgramiv(programHandler, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandler, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    // run
    glUseProgram(programHandler);
    
    
    /////////
    _positionSlot = glGetAttribLocation(programHandler, "Position");
    _colorSlot = glGetAttribLocation(programHandler, "SourceColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    
}

- (GLuint)complieShader:(NSString*)shaderName withType:(GLenum)shaderType {
  
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError* error;
    NSString* shaderStr = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderStr) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    GLuint shaderHandler = glCreateShader(shaderType);
    const char* shaderStringUtf8 = [shaderStr UTF8String];
    int shaderStringLength       = [shaderStr length];
    glShaderSource(shaderHandler, 1, &shaderStringUtf8, &shaderStringLength);
    glCompileShader(shaderHandler);
    
    GLint compileStatus;
    glGetShaderiv(shaderHandler, GL_COMPILE_STATUS, &compileStatus);
    if (compileStatus == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandler, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    return shaderHandler;
}

#pragma mark - content to draw

typedef struct {
    float position[3];
    float color[4];
} Vertex;

const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}},
    {{1, 1, 0}, {0, 1, 0, 1}},
    {{-1, 1, 0}, {0, 0, 1, 1}},
    {{-1, -1, 0}, {0, 0, 0, 1}}
};

const GLubyte Indices[] = {
    0,1,2,
    2,3,0
};

- (void)setupVBOs{
    GLuint vertexBuffer;
    glGenBuffers(1,&vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
}

#pragma mark - draw

- (void)render{
    glClearColor(0, 0.3, 0.4, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    
    
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) *3));
    
    
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]),
                   GL_UNSIGNED_BYTE, 0);
    
    
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
