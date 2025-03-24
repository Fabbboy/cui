const std = @import("std");
const mem = std.mem;

const glfw = @import("../c.zig").glfw;

const WindowEvent = @import("Event.zig").WindowEvent;
const EventApp = @import("App.zig").EventApp;
const Window = @import("Window.zig");
const WindowError = Window.WindowError;
const WindowDesc = @import("Desc.zig");

const Self = @This();

_events: std.ArrayList(WindowEvent),
_window: ?Window,
_desc: WindowDesc,
_running: bool,

pub fn init(desc: WindowDesc, allocator: mem.Allocator) Self {
    return Self{
        ._events = std.ArrayList(WindowEvent).init(allocator),
        ._window = null,
        ._desc = desc,
        ._running = true,
    };
}

pub fn window(self: *Self) WindowError!*Window {
    if (self._window) |*w| {
        try self._window.?.makeCurrent();
        return w;
    }

    const w = try Window.init(self._desc, self);
    self._window = w;
    try self._window.?.makeCurrent();
    return &self._window.?;
}

pub fn deinit(self: *Self) void {
    self._events.deinit();
    if (self._window) |*w| {
        w.deinit();
        self._window = null;
    }
}

pub fn pushEvent(self: *Self, event: WindowEvent) !void {
    try self._events.append(event);
}

pub fn run(self: *Self, comptime T: type, app: EventApp(T)) !void {
    self._running = true;
    while (self._running) {
        try self._events.append(WindowEvent.PreFrame);
        while (self._events.pop()) |e| {
            app.vtable.handle(app.self, e, self);
        }

        try self._window.?.pollEvents(self);
        try self._events.append(WindowEvent.Action);
    }
}

pub fn exit(self: *Self) void {
    self._running = false;
}
