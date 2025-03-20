const Pair = @import("../ADT/Pair.zig").Pair;
const EventLoop = @import("EventLoop.zig");
const WindowEvents = @import("Event.zig").WindowEvent;

const WindowDesc = @This();

name: ?[]const u8,
dims: Pair(u32, u32),
glV: Pair(u4, u4),
event_loop: *EventLoop,

pub fn init(event_loop: *EventLoop) WindowDesc {
    return WindowDesc{
        .name = null,
        .dims = Pair(u32, u32){ .a = 640, .b = 480 },
        .glV = Pair(u4, u4){ .a = 4, .b = 6 },
        .event_loop = event_loop,
    };
}

pub fn setDims(self: *WindowDesc, dims: Pair(u32, u32)) *WindowDesc {
    self.dims = dims;
    return self;
}

pub fn setGLV(self: *WindowDesc, glV: Pair(u4, u4)) *WindowDesc {
    self.glV = glV;
    return self;
}

pub fn setName(self: *WindowDesc, name: []const u8) *WindowDesc {
    self.name = name;
    return self;
}
