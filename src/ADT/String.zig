const std = @import("std");
const mem = std.mem;

pub const StringError = error{OutOfMemory};

const Self = @This();

str: []const u8,
length: usize,
alloc: mem.Allocator,

pub fn init(str: []const u8, alloc: mem.Allocator) StringError!Self {
    const len = str.len;
    const buf = try alloc.alloc(u8, len);
    @memcpy(buf, str);
    return Self{
        .str = buf,
        .length = len,
        .alloc = alloc,
    };
}

pub fn initCapacity(capacity: usize, alloc: mem.Allocator) StringError!Self {
    const buf = try alloc.alloc(u8, capacity);
    return Self{
        .str = buf,
        .length = 0,
        .alloc = alloc,
    };
}

fn ensureCapacity(self: *Self, new_capacity: usize) StringError!void {
    if (new_capacity <= self.length) {
        return;
    }

    const new_buf = try self.alloc.alloc(u8, new_capacity);
    @memcpy(new_buf, self.str);
    self.alloc.free(self.str);
    self.str = new_buf;
}

pub fn write(self: *Self, str: []const u8) StringError!void {
    const new_length = self.length + str.len;
    try self.ensureCapacity(new_length);
    @memcpy(self.str + self.length, str);
    self.length = new_length;
}

pub fn deinit(self: *Self) void {
    self.alloc.free(self.str);
}

pub fn as_str(self: *const Self) []const u8 {
    return self.str;
}
