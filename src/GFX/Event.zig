pub const WindowEvent = union(enum) {
    Poll: void,
    Redraw: void,
};
