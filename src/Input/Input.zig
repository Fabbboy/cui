const std = @import("std");
const WindowEvent = @import("../Window/Event.zig").WindowEvent;
const KeyCode = @import("Keyboard.zig").KeyCode;

const Self = @This();

last_tick: [@intFromEnum(KeyCode.LastEntry)]bool,
key_states: [@intFromEnum(KeyCode.LastEntry)]bool,

pub fn init() Self {
    return Self{
        .last_tick = undefined,
        .key_states = undefined,
    };
}

pub fn update(self: *Self) void {
    @memcpy(&self.last_tick, &self.key_states);
}

pub fn insert(self: *Self, event: WindowEvent) void {
    switch (event) {
        WindowEvent.Pressed => |pressed| {
            self.key_states[pressed.toUsize()] = true;
        },
        WindowEvent.Released => |released| {
            self.key_states[released.toUsize()] = false;
        },
        else => {},
    }
}

pub fn justPressed(self: *const Self, key: KeyCode) bool {
    return self.key_states[key.toUsize()] and !self.last_tick[key.toUsize()];
}

pub fn justReleased(self: *const Self, key: KeyCode) bool {
    return !self.key_states[key.toUsize()] and self.last_tick[key.toUsize()];
}

pub fn isPressed(self: *const Self, key: KeyCode) bool {
    return self.key_states[key.toUsize()];
}

pub fn isReleased(self: *const Self, key: KeyCode) bool {
    return !self.key_states[key.toUsize()];
}

pub fn isDown(self: *const Self, key: KeyCode) bool {
    return self.key_states[key.toUsize()] and self.last_tick[key.toUsize()];
}

pub fn isUp(self: *const Self, key: KeyCode) bool {
    return !self.key_states[key.toUsize()] and !self.last_tick[key.toUsize()];
}
