const KeyCode = @import("../Input/Keyboard.zig").KeyCode;

const Pair = @import("../ADT/Pair.zig").Pair;

pub const WindowEvent = union(enum) {
    Redraw: void,
    Close: void,
    Resize: struct {
        dims: Pair(u32, u32),
    },
    Pressed: KeyCode,
    Released: KeyCode,
    Action: void,
};
