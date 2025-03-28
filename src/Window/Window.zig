const std = @import("std");

const glfw = @import("../c.zig").glfw;
const glad = @import("../c.zig").glad;
const WindowDesc = @import("./Desc.zig");
const Pair = @import("../ADT/Pair.zig").Pair;
const EventLoop = @import("../App/EventLoop.zig");
const WindowEvent = @import("../App/Event.zig").WindowEvent;

const KeyCode = @import("../Input/Keyboard.zig").KeyCode;

pub const WindowError = error{
    GLFWInitFailed,
    GLFWWindowCreationFailed,
    GLADLoadFailed,
};

const Self = @This();

window: ?*glfw.GLFWwindow,
desc: WindowDesc,
event_loop: *EventLoop,

fn handle_viewport(window: ?*glfw.GLFWwindow, width: c_int, height: c_int) callconv(.c) void {
    const self_ptr = glfw.glfwGetWindowUserPointer(window);
    if (self_ptr == null) {
        return;
    }

    const self = @as(*Self, @alignCast(@ptrCast(self_ptr)));

    const dim = Pair(u32, u32){ .a = @as(u32, @intCast(width)), .b = @as(u32, @intCast(height)) };

    self.event_loop.pushEvent(.{ .Resize = .{ .dims = dim } }) catch unreachable;
}

fn handle_key(window: ?*glfw.GLFWwindow, key: c_int, scancode: c_int, action: c_int, mods: c_int) callconv(.c) void {
    _ = scancode;
    _ = mods;

    const self_ptr = glfw.glfwGetWindowUserPointer(window);
    if (self_ptr == null) {
        return;
    }
    const self = @as(*Self, @alignCast(@ptrCast(self_ptr)));
    const keycode = @as(KeyCode, @enumFromInt(key));

    switch (action) {
        glfw.GLFW_PRESS => {
            _ = self.event_loop.pushEvent(.{ .Pressed = keycode }) catch unreachable;
        },
        glfw.GLFW_RELEASE => {
            _ = self.event_loop.pushEvent(.{ .Released = keycode }) catch unreachable;
        },
        else => {},
    }
}

fn glfw_err_cb(err: c_int, description: [*c]const u8) callconv(.c) void {
    std.debug.print("GLFW Error: {}\n", .{err});
    std.debug.print("Description: {s}\n", .{description});
}

pub fn init(desc: WindowDesc, event_loop: *EventLoop) WindowError!Self {
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
        .event_loop = event_loop,
    };
}

pub fn makeCurrent(self: *Self) WindowError!void {
    glfw.glfwMakeContextCurrent(self.window);
    if (glad.gladLoadGLLoader(@as(glad.GLADloadproc, @ptrCast(&glfw.glfwGetProcAddress))) == 0) {
        return WindowError.GLADLoadFailed;
    }

    glfw.glfwSetWindowUserPointer(self.window, self);

    _ = glfw.glfwSetFramebufferSizeCallback(self.window, handle_viewport);
    _ = glfw.glfwSetKeyCallback(self.window, handle_key);
}

pub fn deinit(self: *Self) void {
    glfw.glfwDestroyWindow(self.window);
    self.window = null;
}

pub fn pollEvents(self: *Self, event_loop: *EventLoop) !void {
    const window = self.window;
    if (window == null) {
        return;
    }

    glfw.glfwPollEvents();
    if (glfw.glfwWindowShouldClose(window) != 0) {
        try event_loop.pushEvent(WindowEvent.Close);
    }
    try event_loop.pushEvent(WindowEvent.Redraw);
}

pub fn getDims(self: *Self) Pair(u32, u32) {
    return self.desc.dims;
}

pub fn resize(self: *Self, dims: Pair(u32, u32)) void {
    const cCastedDimsA = @as(c_int, @intCast(dims.a));
    const cCastedDimsB = @as(c_int, @intCast(dims.b));

    glad.glViewport(0, 0, cCastedDimsA, cCastedDimsB);

    self.desc.dims = dims;
}

pub inline fn shouldClose(self: *Self) bool {
    return glfw.glfwWindowShouldClose(self.window) != 0;
}

pub inline fn update(self: *Self) void {
    glfw.glfwSwapBuffers(self.window);
    glfw.glfwPollEvents();
}

pub inline fn clear(self: *Self) void {
    _ = self;
    glad.glClear(glad.GL_COLOR_BUFFER_BIT);
}
