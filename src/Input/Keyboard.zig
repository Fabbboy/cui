const glfw = @import("../c.zig").glfw;

pub const KeyCode = enum(i32) {
  Escape = glfw.GLFW_KEY_ESCAPE,
};