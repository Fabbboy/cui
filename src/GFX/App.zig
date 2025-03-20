const WindowEvent = @import("Event.zig").WindowEvent;
const EventLoop = @import("EventLoop.zig");

pub fn EventApp(T: type) type {
    return struct {
        self: *T,
        vtable: VTable,

        pub const VTable = struct {
            handle: *const fn (*T, WindowEvent, *EventLoop) void,
        };
    };
}
