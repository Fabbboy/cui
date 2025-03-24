const std = @import("std");
const mem = std.mem;

const ecs = @import("ecs");

const WindowDesc = @import("../Window/Desc.zig");
const Window = @import("../Window/Window.zig");
const EventLoop = @import("EventLoop.zig");
const WindowEvent = @import("Event.zig").WindowEvent;

pub fn EventApp(T: type) type {
    return struct {
        self: *T,
        vtable: VTable,

        pub const VTable = struct {
            handle: *const fn (*T, WindowEvent, *EventLoop) void,
            deinit: *const fn (*T) void,
        };
    };
}

pub fn App(comptime T: type) type {
    return struct {
        const Self = @This();
        event_loop: EventLoop,
        window: *Window,
        allocator: mem.Allocator,
        handler: EventApp(T),
        registry: ecs.Registry,

        pub fn init(desc: WindowDesc, handler: EventApp(T), allocator: mem.Allocator) !Self {
            var event_loop = EventLoop.init(desc, allocator);
            const window = try event_loop.window();

            return Self{
                .event_loop = event_loop,
                .window = window,
                .allocator = allocator,
                .handler = handler,
                .registry = ecs.Registry.init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.handler.vtable.deinit(self.handler.self);
            self.event_loop.deinit();
            self.registry.deinit();
        }

        pub fn run(self: *Self) !void {
            try self.event_loop.run(T, self.handler);
        }
    };
}
