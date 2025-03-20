const glfw = @import("c.zig").glfw;
const glad = @import("c.zig").glad;

pub fn main() !void {
    if (glfw.glfwInit() == 0) {
        return error.Unreachable;
    }

    defer glfw.glfwTerminate();

    glfw.glfwWindowHint(glfw.GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfw.glfwWindowHint(glfw.GLFW_CONTEXT_VERSION_MINOR, 6);
    glfw.glfwWindowHint(glfw.GLFW_OPENGL_PROFILE, glfw.GLFW_OPENGL_CORE_PROFILE);

    const window = glfw.glfwCreateWindow(640, 480, "Hello World", null, null);
    if (window == null) {
        return error.Unreachable;
    }

    glfw.glfwMakeContextCurrent(window);

    if (glad.gladLoadGLLoader(@as(glad.GLADloadproc, @ptrCast(&glfw.glfwGetProcAddress))) == 0) {
        return error.Unreachable;
    }

    glad.glClearColor(0.1, 0.2, 0.3, 1.0);

    while (glfw.glfwWindowShouldClose(window) == 0) {
        glfw.glfwSwapBuffers(window);
        glfw.glfwPollEvents();
        glad.glClear(glad.GL_COLOR_BUFFER_BIT);
    }
}
