const glfw = @import("../c.zig").glfw;

pub const KeyCode = enum(i32) {
    // Control keys
    Escape = glfw.GLFW_KEY_ESCAPE,
    Enter = glfw.GLFW_KEY_ENTER,
    Tab = glfw.GLFW_KEY_TAB,
    Backspace = glfw.GLFW_KEY_BACKSPACE,
    Insert = glfw.GLFW_KEY_INSERT,
    Delete = glfw.GLFW_KEY_DELETE,
    Right = glfw.GLFW_KEY_RIGHT,
    Left = glfw.GLFW_KEY_LEFT,
    Down = glfw.GLFW_KEY_DOWN,
    Up = glfw.GLFW_KEY_UP,
    PageUp = glfw.GLFW_KEY_PAGE_UP,
    PageDown = glfw.GLFW_KEY_PAGE_DOWN,
    Home = glfw.GLFW_KEY_HOME,
    End = glfw.GLFW_KEY_END,

    // Modifier keys
    LeftShift = glfw.GLFW_KEY_LEFT_SHIFT,
    RightShift = glfw.GLFW_KEY_RIGHT_SHIFT,
    LeftControl = glfw.GLFW_KEY_LEFT_CONTROL,
    RightControl = glfw.GLFW_KEY_RIGHT_CONTROL,
    LeftAlt = glfw.GLFW_KEY_LEFT_ALT,
    RightAlt = glfw.GLFW_KEY_RIGHT_ALT,
    LeftSuper = glfw.GLFW_KEY_LEFT_SUPER,
    RightSuper = glfw.GLFW_KEY_RIGHT_SUPER,
    CapsLock = glfw.GLFW_KEY_CAPS_LOCK,
    ScrollLock = glfw.GLFW_KEY_SCROLL_LOCK,
    NumLock = glfw.GLFW_KEY_NUM_LOCK,

    // Function keys
    F1 = glfw.GLFW_KEY_F1,
    F2 = glfw.GLFW_KEY_F2,
    F3 = glfw.GLFW_KEY_F3,
    F4 = glfw.GLFW_KEY_F4,
    F5 = glfw.GLFW_KEY_F5,
    F6 = glfw.GLFW_KEY_F6,
    F7 = glfw.GLFW_KEY_F7,
    F8 = glfw.GLFW_KEY_F8,
    F9 = glfw.GLFW_KEY_F9,
    F10 = glfw.GLFW_KEY_F10,
    F11 = glfw.GLFW_KEY_F11,
    F12 = glfw.GLFW_KEY_F12,

    // Numbers (top row)
    Key0 = glfw.GLFW_KEY_0,
    Key1 = glfw.GLFW_KEY_1,
    Key2 = glfw.GLFW_KEY_2,
    Key3 = glfw.GLFW_KEY_3,
    Key4 = glfw.GLFW_KEY_4,
    Key5 = glfw.GLFW_KEY_5,
    Key6 = glfw.GLFW_KEY_6,
    Key7 = glfw.GLFW_KEY_7,
    Key8 = glfw.GLFW_KEY_8,
    Key9 = glfw.GLFW_KEY_9,

    // Letters
    A = glfw.GLFW_KEY_A,
    B = glfw.GLFW_KEY_B,
    C = glfw.GLFW_KEY_C,
    D = glfw.GLFW_KEY_D,
    E = glfw.GLFW_KEY_E,
    F = glfw.GLFW_KEY_F,
    G = glfw.GLFW_KEY_G,
    H = glfw.GLFW_KEY_H,
    I = glfw.GLFW_KEY_I,
    J = glfw.GLFW_KEY_J,
    K = glfw.GLFW_KEY_K,
    L = glfw.GLFW_KEY_L,
    M = glfw.GLFW_KEY_M,
    N = glfw.GLFW_KEY_N,
    O = glfw.GLFW_KEY_O,
    P = glfw.GLFW_KEY_P,
    Q = glfw.GLFW_KEY_Q,
    R = glfw.GLFW_KEY_R,
    S = glfw.GLFW_KEY_S,
    T = glfw.GLFW_KEY_T,
    U = glfw.GLFW_KEY_U,
    V = glfw.GLFW_KEY_V,
    W = glfw.GLFW_KEY_W,
    X = glfw.GLFW_KEY_X,
    Y = glfw.GLFW_KEY_Y,
    Z = glfw.GLFW_KEY_Z,

    // Punctuation and special keys
    Space = glfw.GLFW_KEY_SPACE,
    Apostrophe = glfw.GLFW_KEY_APOSTROPHE, // '
    Comma = glfw.GLFW_KEY_COMMA,
    Minus = glfw.GLFW_KEY_MINUS,
    Period = glfw.GLFW_KEY_PERIOD,
    Slash = glfw.GLFW_KEY_SLASH,
    Semicolon = glfw.GLFW_KEY_SEMICOLON,
    Equal = glfw.GLFW_KEY_EQUAL,
    LeftBracket = glfw.GLFW_KEY_LEFT_BRACKET,
    RightBracket = glfw.GLFW_KEY_RIGHT_BRACKET,
    Backslash = glfw.GLFW_KEY_BACKSLASH,
    GraveAccent = glfw.GLFW_KEY_GRAVE_ACCENT,

    LastEntry = glfw.GLFW_KEY_LAST,

    pub fn toOpengl(self: KeyCode) c_int {
        return @as(c_int, @intFromEnum(self));
    }

    pub fn toUsize(self: KeyCode) usize {
        return @as(usize, @intCast(@intFromEnum(self)));
    }
};
