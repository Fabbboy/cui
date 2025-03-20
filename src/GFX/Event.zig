pub const WindowEvent = union(enum) {
    Redraw: void,
    Close: void,    
};
