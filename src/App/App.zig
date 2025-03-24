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

pub const Plugin = struct {
    self: *anyopaque,
    vtable: VTable,
    //all systems

    pub const VTable = struct {
        build: *const fn (*anyopaque, *App) anyerror!void,
    };

    pub fn run(self: *Plugin, app: *App) anyerror!void {
        _ = app;
        _ = self;
    }
};

pub const App = struct {
    const Self = @This();
    allocator: mem.Allocator,
    registry: ecs.Registry,
    plugins: std.ArrayList(Plugin),

    pub fn init(allocator: mem.Allocator) Self {
        return Self{
            .allocator = allocator,
            .registry = ecs.Registry.init(allocator),
            .plugins = std.ArrayList(Plugin).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.registry.deinit();
    }

    pub fn run(self: *Self) anyerror!void {
        for (self.plugins.items) |*plugin| {
            try plugin.vtable.build(plugin.self, self);
        }

        for (self.plugins.items) |*plugin| {
            try plugin.run(self);
        }
    }
};
