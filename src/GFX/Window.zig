const std = @import("std");

const glfw = @import("../c.zig").glfw;
const glad = @import("../c.zig").glad;
const Pair = @import("../ADT/Pair.zig").Pair;

pub const WindowError = error{
    GLFWInitFailed,
    GLFWWindowCreationFailed,
    GLADLoadFailed,
};

pub const WindowDesc = struct {
    name: ?[]const u8,
    dims: Pair(u32, u32),
    glV: Pair(u4, u4),

    pub fn init() WindowDesc {
        return WindowDesc{
            .name = null,
            .dims = Pair(u32, u32){ .a = 640, .b = 480 },
            .glV = Pair(u4, u4){ .a = 4, .b = 6 },
        };
    }

    pub fn setDims(self: *WindowDesc, dims: Pair(u32, u32)) *WindowDesc {
        self.dims = dims;
        return self;
    }

    pub fn setGLV(self: *WindowDesc, glV: Pair(u4, u4)) *WindowDesc {
        self.glV = glV;
        return self;
    }

    pub fn setName(self: *WindowDesc, name: []const u8) *WindowDesc {
        self.name = name;
        return self;
    }
};

const Self = @This();

window: ?*glfw.GLFWwindow,
desc: WindowDesc,

fn handle_viewport(window: ?*glfw.GLFWwindow, width: c_int, height: c_int) callconv(.c) void {
    const self_ptr = glfw.glfwGetWindowUserPointer(window);
    if (self_ptr == null) {
        return;
    }

    const self = @as(*Self, @alignCast(@ptrCast(self_ptr)));

    self.desc.dims = Pair(u32, u32).init(@as(u32, @intCast(width)), @as(u32, @intCast(height)));
    glad.glViewport(0, 0, width, height);
}

fn glfw_err_cb(err: c_int, description: [*c]const u8) callconv(.c) void {
    std.debug.print("GLFW Error: {}\n", .{err});
    std.debug.print("Description: {s}\n", .{description});
}

pub fn init(desc: WindowDesc) WindowError!Self {
    if (glfw.glfwInit() == 0) {
        return WindowError.GLFWInitFailed;
    }

    _ = glfw.glfwSetErrorCallback(glfw_err_cb);

    const cCastedGLVA = @as(c_int, @intCast(desc.glV.a));
    const cCastedGLVB = @as(c_int, @intCast(desc.glV.b));

    glfw.glfwWindowHint(glfw.GLFW_CONTEXT_VERSION_MAJOR, cCastedGLVA);
    glfw.glfwWindowHint(glfw.GLFW_CONTEXT_VERSION_MINOR, cCastedGLVB);
    glfw.glfwWindowHint(glfw.GLFW_OPENGL_PROFILE, glfw.GLFW_OPENGL_CORE_PROFILE);

    const cCastedDimsA = @as(c_int, @intCast(desc.dims.a));
    const cCastedDimsB = @as(c_int, @intCast(desc.dims.b));

    const window = glfw.glfwCreateWindow(cCastedDimsA, cCastedDimsB, desc.name.?.ptr, null, null);
    if (window == null) {
        return WindowError.GLFWWindowCreationFailed;
    }

    return Self{
        .window = window,
        .desc = desc,
    };
}

pub fn makeCurrent(self: *Self) WindowError!void {
    glfw.glfwMakeContextCurrent(self.window);
    if (glad.gladLoadGLLoader(@as(glad.GLADloadproc, @ptrCast(&glfw.glfwGetProcAddress))) == 0) {
        return WindowError.GLADLoadFailed;
    }

    glfw.glfwSetWindowUserPointer(self.window, self);

    _ = glfw.glfwSetFramebufferSizeCallback(self.window, handle_viewport);
}

pub fn deinit(self: *Self) void {
    glfw.glfwDestroyWindow(self.window);
}

pub inline fn shouldClose(self: *Self) bool {
    return glfw.glfwWindowShouldClose(self.window) != 0;
}

pub inline fn update(self: *Self) void {
    glfw.glfwSwapBuffers(self.window);
    glfw.glfwPollEvents();
}
