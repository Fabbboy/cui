const std = @import("std");

const Pair = @import("ADT/Pair.zig").Pair;
const Window = @import("GFX/Window.zig");
const WindowDesc = Window.WindowDesc;
const glad = @import("c.zig").glad;

pub fn main() !void {
    var desc = WindowDesc.init();
    _ = desc.setName("Hello, World!")
        .setDims(Pair(u32, u32).init(800, 600))
        .setGLV(Pair(u4, u4).init(4, 6));

    var window = try Window.init(desc);
    try window.makeCurrent();
    defer window.deinit();

    while (window.shouldClose() == false) {
        window.update();
        std.debug.print("{}:{}\n", .{window.desc.dims.a, window.desc.dims.b});
        glad.glClear(glad.GL_COLOR_BUFFER_BIT);
    }
}
