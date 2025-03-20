const c = @cImport({
    @cInclude("glad.h");
    @cInclude("GLFW/glfw3.h");
});

pub fn main() !void {
    if (c.glfwInit() == 0) {
        return error.Unreachable;
    }

    defer c.glfwTerminate();

    const window = c.glfwCreateWindow(640, 480, "Hello World", null, null);
    if (window == null) {
        return error.Unreachable;
    }

    c.glfwMakeContextCurrent(window);

    if (c.gladLoadGLLoader(@as(c.GLADloadproc, @ptrCast(&c.glfwGetProcAddress))) == 0) {
        return error.Unreachable;
    }

    while (c.glfwWindowShouldClose(window) == 0) {
        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }
}
