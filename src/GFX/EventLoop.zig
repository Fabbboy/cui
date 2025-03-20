const std = @import("std");
const mem = std.mem;

const WindowEvent = @import("Event.zig").WindowEvent;

const Self = @This();

events: std.ArrayList(WindowEvent),

pub fn init(allocator: mem.Allocator) Self {
    return Self{
        .events = std.ArrayList(WindowEvent).init(allocator),
    };
}

pub fn deinit(self: *Self) void {
    self.events.deinit();
}

pub fn next(self: *Self) WindowEvent {
    const popped = self.events.pop();
    if (popped) |p| {
        return p;
    }

    return WindowEvent.Poll;
}
