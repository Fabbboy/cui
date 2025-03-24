const std = @import("std");
const heap = std.heap;
const mem = std.mem;

const Pair = @import("ADT/Pair.zig").Pair;
const EventLoop = @import("App/EventLoop.zig");
const WindowEvent = @import("App/Event.zig").WindowEvent;
const Window = @import("Window/Window.zig");
const WindowDesc = @import("Window/Desc.zig");
const glad = @import("c.zig").glad;

const AppNs = @import("App/App.zig");
const App = AppNs.App;
const EventApp = AppNs.EventApp;

const c = @import("c.zig");
const glfw = c.glfw;
const RenderMode = c.RenderMode;
const GLType = c.GLType;

const Source = @import("ADT/Source.zig");

const Shader = @import("Graphics/Shader.zig");
const BufferNs = @import("Graphics/Buffer.zig");
const Buffer = BufferNs.Buffer;
const BufferType = BufferNs.BufferType;
const BufferUsage = BufferNs.BufferUsage;

const Pipeline = @import("Graphics/Pipeline.zig").Pipeline;
const Attribute = @import("Graphics/Pipeline.zig").Attribute;

const Texture = @import("Graphics/Texture.zig");

const KeyCode = @import("Input/Keyboard.zig").KeyCode;
const Input = @import("Input/Input.zig");

const Camera = @import("Graphics/Camera.zig");
const glm = @import("glm.zig");

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{
        .verbose_log = false,
        .enable_memory_limit = true,
        .thread_safe = false,
    }){};

    defer {
        if (gpa.deinit() == .leak) {
            @panic("Memory leak detected.");
        }
    }

    var desc = WindowDesc.init();
    _ = desc.setName("ZUI")
        .setDims(Pair(u32, u32).init(800, 600))
        .setGLV(Pair(u4, u4).init(4, 6));

    var app = App.init(gpa.allocator());
    defer app.deinit();

    try app.run();

    std.debug.print("Allocated: {d:.2}KiB\n", .{@as(f64, @floatFromInt(gpa.total_requested_bytes)) / 1024.0});
}
