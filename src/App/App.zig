const std = @import("std");
const mem = std.mem;

const ecs = @import("ecs");

const WindowDesc = @import("../Window/Desc.zig");
const Window = @import("../Window/Window.zig");
const EventLoop = @import("EventLoop.zig");
const WindowEvent = @import("Event.zig").WindowEvent;

pub const Plugin = struct {
    self: *anyopaque,
    vtable: VTable,
    //all systems

    pub const VTable = struct {
        build: *const fn (*anyopaque, *App) anyerror!void,
        deinit: *const fn (*anyopaque) void,
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

    pub fn createEntity(self: *Self) ecs.Entity {
        return self.registry.create();
    }

    pub fn insertPlugin(self: *Self, plugin: Plugin) !void {
        try self.plugins.append(plugin);
    }

    pub fn spawn(self: *Self, entity: ecs.Entity, val: anytype) void {
        self.registry.add(entity, val);
    }

    pub fn deinit(self: *Self) void {
        self.registry.deinit();

        for (self.plugins.items) |*plugin| {
            plugin.vtable.deinit(plugin.self);
        }
        self.plugins.deinit();
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
