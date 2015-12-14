/// @see https://www.opengl.org/wiki/GL_EXT_texture_integer

#include <iostream>
#include <GL/glew.h> ///< must be before glfw
#include <GL/glfw.h>
#include <vector>
#include <fstream>
#include <sstream>
#include <algorithm>

using namespace std;

/// Convenience constants
static const int ONE = 1;
static const bool DONT_NORMALIZE = false;
static const bool DONT_TRANSPOSE = false;
static const int ZERO_STRIDE = 0;
static const void* ZERO_BUFFER_OFFSET = 0;

const int window_w = 1024;
const int window_h = 768;

const int window_w = 1024;
const int window_h = 768;

GLuint textureID;

#define GL_CHECK_ERROR_BLOCK
#ifdef GL_CHECK_ERROR_BLOCK
    static inline const char* ErrorString(GLenum error) {
      const char* msg;

      switch (error) {
    #define Case(Token)  case Token: msg = #Token; break;
      Case(GL_INVALID_ENUM);
      Case(GL_INVALID_VALUE);
      Case(GL_INVALID_OPERATION);
      Case(GL_INVALID_FRAMEBUFFER_OPERATION);
      Case(GL_NO_ERROR);
      Case(GL_OUT_OF_MEMORY);
    #undef Case
      }

      return msg;
    }

    static inline void _glCheckError(const char* file, int line) {
      GLenum error;
      while ((error = glGetError()) != GL_NO_ERROR) {
        fprintf(stderr, "ERROR: file %s, line %i: %s.\n", file, line,
                ErrorString(error));
      }
    }

    #ifndef NDEBUG
    #define glCheckError() _glCheckError(__FILE__, __LINE__)
    #else
    #define glCheckError() ((void)0)
    #endif
#endif

/// Compiles the vertex, geometry and fragment shaders stored in the given strings
GLuint compile_shaders(const char * vshader, const char * fshader, const char * gshader = NULL) {
    const int SHADER_LOAD_FAILED = 0;
    GLint Success = GL_FALSE;
    int InfoLogLength;

    /// Create the Vertex Shader
    GLuint VertexShaderID = glCreateShader(GL_VERTEX_SHADER);

    /// Compile Vertex Shader
    fprintf(stdout, "Compiling Vertex shader: ");
    char const * VertexSourcePointer = vshader;
    glShaderSource(VertexShaderID, 1, &VertexSourcePointer , NULL);
    glCompileShader(VertexShaderID);

    /// Check Vertex Shader
    glGetShaderiv(VertexShaderID, GL_COMPILE_STATUS, &Success);
    glGetShaderiv(VertexShaderID, GL_INFO_LOG_LENGTH, &InfoLogLength);
    if(!Success) {
        std::vector<char> VertexShaderErrorMessage(InfoLogLength);
        glGetShaderInfoLog(VertexShaderID, InfoLogLength, NULL, &VertexShaderErrorMessage[0]);
        fprintf(stdout, "Failed:\n%s\n", &VertexShaderErrorMessage[0]);
        return SHADER_LOAD_FAILED;
    }
    else
        fprintf(stdout, "Success\n");

    /// Create the Fragment Shader
    GLuint FragmentShaderID = glCreateShader(GL_FRAGMENT_SHADER);

    /// Compile Fragment Shader
    fprintf(stdout, "Compiling Fragment shader: ");
    char const * FragmentSourcePointer = fshader;
    glShaderSource(FragmentShaderID, 1, &FragmentSourcePointer , NULL);
    glCompileShader(FragmentShaderID);

    /// Check Fragment Shader
    glGetShaderiv(FragmentShaderID, GL_COMPILE_STATUS, &Success);
    glGetShaderiv(FragmentShaderID, GL_INFO_LOG_LENGTH, &InfoLogLength);
    if(!Success) {
        std::vector<char> FragmentShaderErrorMessage(InfoLogLength);
        glGetShaderInfoLog(FragmentShaderID, InfoLogLength, NULL, &FragmentShaderErrorMessage[0]);
        fprintf(stdout, "Failed:\n%s\n", &FragmentShaderErrorMessage[0]);
        return SHADER_LOAD_FAILED;
    }
    else
        fprintf(stdout, "Success\n");

    GLuint GeometryShaderID = 0;
    if(gshader != NULL) {
        /// Create the Geometry Shader
        GeometryShaderID = glCreateShader(GL_GEOMETRY_SHADER);

        /// Compile Geometry Shader
        fprintf(stdout, "Compiling Geometry shader: ");
        char const * GeometrySourcePointer = gshader;
        glShaderSource(GeometryShaderID, 1, &GeometrySourcePointer , NULL);
        glCompileShader(GeometryShaderID);

        /// Check Geometry Shader
        glGetShaderiv(GeometryShaderID, GL_COMPILE_STATUS, &Success);
        glGetShaderiv(GeometryShaderID, GL_INFO_LOG_LENGTH, &InfoLogLength);
        if(!Success) {
            std::vector<char> GeometryShaderErrorMessage(InfoLogLength);
            glGetShaderInfoLog(GeometryShaderID, InfoLogLength, NULL, &GeometryShaderErrorMessage[0]);
            fprintf(stdout, "Failed:\n%s\n", &GeometryShaderErrorMessage[0]);
            return SHADER_LOAD_FAILED;
        }
        else
            fprintf(stdout, "Success\n");
    }

    /// Link the program
    fprintf(stdout, "Linking shader program: ");
    GLuint ProgramID = glCreateProgram();
    glAttachShader(ProgramID, VertexShaderID);
    glAttachShader(ProgramID, FragmentShaderID);
    if(gshader != NULL) glAttachShader(ProgramID, GeometryShaderID);
    glLinkProgram(ProgramID);

    /// Check the program
    glGetProgramiv(ProgramID, GL_LINK_STATUS, &Success);
    glGetProgramiv(ProgramID, GL_INFO_LOG_LENGTH, &InfoLogLength);
    std::vector<char> ProgramErrorMessage( std::max(InfoLogLength, int(1)) );
    glGetProgramInfoLog(ProgramID, InfoLogLength, NULL, &ProgramErrorMessage[0]);
    if(!Success) {
        fprintf(stdout, "Failed:\n%s\n", &ProgramErrorMessage[0]);
        return SHADER_LOAD_FAILED;
    }
    else
        fprintf(stdout, "Success\n");

    glDeleteShader(VertexShaderID);
    glDeleteShader(FragmentShaderID);
    if(gshader != NULL) glDeleteShader(GeometryShaderID);

    /// make sure you see the text in terminal
    fflush(stdout);

    return ProgramID;
}


/// Compiles the vertex, geometry and fragment shaders using file path
GLuint load_shaders(const char * vertex_file_path, const char * fragment_file_path, const char * geometry_file_path = NULL) {
    const int SHADER_LOAD_FAILED = 0; 

    std::string VertexShaderCode, FragmentShaderCode, GeometryShaderCode;
    {
        /// Read the Vertex Shader code from the file
        std::ifstream VertexShaderStream(vertex_file_path, std::ios::in);
        if(VertexShaderStream.is_open()) {
            VertexShaderCode = std::string(std::istreambuf_iterator<char>(VertexShaderStream),
                                           std::istreambuf_iterator<char>());
            VertexShaderStream.close();
        } else {
            printf("Could not open file: %s\n", vertex_file_path);
            return SHADER_LOAD_FAILED;
        }   
    
        /// Read the Fragment Shader code from the file
        std::ifstream FragmentShaderStream(fragment_file_path, std::ios::in);
        if(FragmentShaderStream.is_open()) {
            FragmentShaderCode = std::string(std::istreambuf_iterator<char>(FragmentShaderStream),
                                             std::istreambuf_iterator<char>());
            FragmentShaderStream.close();
        } else {
            printf("Could not open file: %s\n", fragment_file_path);
            return SHADER_LOAD_FAILED;
        }

        /// Read the Geometry Shader code from the file
        if(geometry_file_path != NULL) {
            std::ifstream GeometryShaderStream(geometry_file_path, std::ios::in);
            if(GeometryShaderStream.is_open()) {
                GeometryShaderCode = std::string(std::istreambuf_iterator<char>(GeometryShaderStream),
                                                 std::istreambuf_iterator<char>());
                GeometryShaderStream.close();
            } else {
                printf("Could not open file: %s\n", geometry_file_path);
                return SHADER_LOAD_FAILED;
            }
        }
    }

    /// Compile them
    char const * VertexSourcePointer = VertexShaderCode.c_str();
    char const * FragmentSourcePointer = FragmentShaderCode.c_str();
    char const * GeometrySourcePointer = NULL;
    if(geometry_file_path != NULL) GeometrySourcePointer = GeometryShaderCode.c_str();
    return compile_shaders(VertexSourcePointer, FragmentSourcePointer, GeometrySourcePointer);
}

static GLfloat vertices[] = {
    -1.0000,-1.0000,+0.0000,
    +1.0000,-1.0000,+0.0000,
    -1.0000,+1.0000,+0.0000,
    +1.0000,+1.0000,+0.0000,};

void init(){   
    /// Compile the shaders
    GLuint programID = load_shaders("vshader.glsl", "fshader.glsl");
    if(!programID) exit(EXIT_FAILURE);
    glUseProgram(programID);
    
    /// @todo explain more or refer to another exercise
    GLuint VertexArrayID;
    glGenVertexArrays(ONE, &VertexArrayID);
    glBindVertexArray(VertexArrayID);  
    
    /// Generate one buffer, put the resulting identifier in vertexbuffer
    GLuint vertexbuffer; 
    glGenBuffers(ONE, &vertexbuffer); 
    /// The subsequent commands will affect the specified buffer
    glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer); 
    /// Pass the vertex positions to OpenGL
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW); 
   
    /// Vertex Attribute ID for Vertex Positions
    GLuint position = glGetAttribLocation(programID, "position");
    glEnableVertexAttribArray(position);
    glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer);
    glVertexAttribPointer(position, 3, GL_FLOAT, DONT_NORMALIZE, ZERO_STRIDE, ZERO_BUFFER_OFFSET);
    
    /// Specify window bounds
    glUniform1f(glGetUniformLocation(programID, "window_h"), window_h);    
    glUniform1f(glGetUniformLocation(programID, "window_w"), window_w);    
    
    
#ifdef WITH_TEXTURE
    /// setup textures
    glUniform1i(glGetUniformLocation(programID, "tex"), 0 /*GL_TEXTURE_0*/);    
#endif
}

void display(){
    glClear(GL_COLOR_BUFFER_BIT);
    
    /// Activate texture
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureID);
    
    /// Starting from vertex 0, we have 4 vertices
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

int main(int, char**){
    /// GLFW Initialization
    if( !glfwInit() ){
        fprintf( stderr, "Failed to initialize GLFW\n" );
        return EXIT_FAILURE;
    }
    
    /// Hint GLFW that we would like an OpenGL 3 context (at least)
    /// http://www.glfw.org/faq.html#41__how_do_i_create_an_opengl_30_context
    glfwOpenWindowHint(GLFW_OPENGL_VERSION_MAJOR, 3);
    glfwOpenWindowHint(GLFW_OPENGL_VERSION_MINOR, 2);
    glfwOpenWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    
    /// Attempt to open the window: fails if required version unavailable
    /// @note some Intel GPUs do not support OpenGL 3.0
    /// @note update the driver of your graphic card
    if( !glfwOpenWindow(window_w, window_h, 0,0,0,0, 32,0, GLFW_WINDOW ) ){
        fprintf( stderr, "Failed to open OpenGL 3 GLFW window.\n" );
        glfwTerminate();
        return EXIT_FAILURE;
    }
   
	/// GLEW Initialization (must have a context)
	glewExperimental = true; ///< 
	if( glewInit() != GLEW_NO_ERROR ){
		fprintf( stderr, "Failed to initialize GLEW\n"); 
        return EXIT_FAILURE;
	}

#ifdef WITH_TEXTURE
    ///--- Create texture
    {
        unsigned short pixels[320*240];
        for (int i = 0; i < 320*240/2; ++i)
            pixels[i] = 1000;
        
        glGenTextures(1, &textureID);
        glBindTexture(GL_TEXTURE_2D, textureID);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE16UI_EXT, 320, 240, 0, GL_LUMINANCE_INTEGER_EXT, GL_UNSIGNED_SHORT, pixels);
    }
#endif
    
    /// Set window title
    std::stringstream title;
    title << "fullscreenquad (" << glGetString(GL_VERSION) << ")";
    glfwSetWindowTitle(title.str().c_str());

    /// Initialize our OpenGL program
    init();
    
    /// Render loop & keyboard input
    while(glfwGetKey(GLFW_KEY_ESC)!=GLFW_PRESS && glfwGetWindowParam(GLFW_OPENED)){
        display();
        glfwSwapBuffers();
    }
    
#ifdef WITH_TEXTURE
    ///--- Cleanup
    {
        glDeleteTextures(1, &textureID);
    }
#endif
    
    /// Close OpenGL window and terminate GLFW
    glfwTerminate();
    exit( EXIT_SUCCESS );
}
