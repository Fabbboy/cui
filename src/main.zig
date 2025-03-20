const std = @import("std");
const heap = std.heap;

const Pair = @import("ADT/Pair.zig").Pair;
const EventLoop = @import("GFX/EventLoop.zig");
const WindowEvent = @import("GFX/Event.zig").WindowEvent;
const Window = @import("GFX/Window.zig");
const WindowDesc = @import("GFX/Desc.zig");
const glad = @import("c.zig").glad;

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

    var event_loop = EventLoop.init(gpa.allocator());
    defer event_loop.deinit();

    var desc = WindowDesc.init(&event_loop);
    _ = desc.setName("Hello, World!")
        .setDims(Pair(u32, u32).init(800, 600))
        .setGLV(Pair(u4, u4).init(4, 6));

    var window = try Window.init(desc);
    try window.makeCurrent();
    defer window.deinit();
}
