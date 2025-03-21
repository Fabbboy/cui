const std = @import("std");
const heap = std.heap;

const Pair = @import("ADT/Pair.zig").Pair;
const EventLoop = @import("Window/EventLoop.zig");
const WindowEvent = @import("Window/Event.zig").WindowEvent;
const Window = @import("Window/Window.zig");
const WindowDesc = @import("Window/Desc.zig");
const glad = @import("c.zig").glad;
const EventApp = @import("Window/App.zig").EventApp;

pub const GameApp = struct {
    window: *Window,

    pub fn init(window: *Window) GameApp {
        return GameApp{
            .window = window,
        };
    }

    pub fn handle(self: *GameApp, event: WindowEvent, event_loop: *EventLoop) void {
        switch (event) {
            WindowEvent.Redraw => {
                self.window.update();
                self.window.clear();
            },
            WindowEvent.Close => {
                event_loop.exit();
            },
        }
    }

    pub fn app(self: *GameApp) EventApp(GameApp) {
        return EventApp(GameApp){
            .self = self,
            .vtable = .{
                .handle = &GameApp.handle,
            },
        };
    }
};

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
    _ = desc.setName("Hello, World!")
        .setDims(Pair(u32, u32).init(800, 600))
        .setGLV(Pair(u4, u4).init(4, 6));

    var event_loop = EventLoop.init(desc, gpa.allocator());
    defer event_loop.deinit();
    const window = try event_loop.window();

    var gameapp = GameApp.init(window);
    const app = gameapp.app();
    try event_loop.run(GameApp, app);

    std.debug.print("Allocated: {d:.2}KiB\n", .{@as(f64, @floatFromInt(gpa.total_requested_bytes)) / 1024.0});
}
