pub fn Pair(comptime A: type, comptime B: type) type {
    return struct {
        const Self = @This();
        a: A,
        b: B,

        pub fn init(a: A, b: B) Self {
            return Self{ .a = a, .b = b };
        }
    };
}
