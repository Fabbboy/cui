const std = @import("std");
const heap = std.heap;
const mem = std.mem;

const Pair = @import("ADT/Pair.zig").Pair;
const EventLoop = @import("Window/EventLoop.zig");
const WindowEvent = @import("Window/Event.zig").WindowEvent;
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

pub const GameApp = struct {
    pub fn deinit(self: *GameApp) void {
        _ = self;
    }

    pub fn handle(self: *GameApp, event: WindowEvent, event_loop: *EventLoop) void {
        _ = event_loop;
        _ = event;
        _ = self;
    }

    pub fn app(self: *GameApp) EventApp(GameApp) {
        return EventApp(GameApp){
            .self = self,
            .vtable = .{
                .handle = &GameApp.handle,
                .deinit = &GameApp.deinit,
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
    _ = desc.setName("ZUI")
        .setDims(Pair(u32, u32).init(800, 600))
        .setGLV(Pair(u4, u4).init(4, 6));

    var gameApp = GameApp{};

    var app = try App(GameApp).init(desc, gameApp.app(), gpa.allocator());
    defer app.deinit();

    try app.run();

    std.debug.print("Allocated: {d:.2}KiB\n", .{@as(f64, @floatFromInt(gpa.total_requested_bytes)) / 1024.0});
}
