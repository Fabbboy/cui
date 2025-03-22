const std = @import("std");
const mem = std.mem;
const fs = std.fs;

pub const SourceError = error{
    FileReadFailed,
    UnexpectedEof,
    OutOfMemory,
} || fs.File.OpenError || fs.File.StatError || fs.File.ReadError;

const Self = @This();

path: []const u8,
stat: ?fs.File.Stat,
len: usize,
contents: ?[]u8,
allocator: mem.Allocator,

fn readFullFile(self: *Self) SourceError!void {
    const file_fd = try fs.cwd().openFile(self.path, .{
        .mode = .read_only,
    });
    defer file_fd.close();

    self.stat = try file_fd.stat();
    const stat = self.stat.?;
    self.len = stat.size;
    self.contents = try self.allocator.alloc(u8, stat.size);

    const read_result = try file_fd.readAll(self.contents.?);
    if (read_result != stat.size) {
        return error.UnexpectedEof;
    }
}

pub fn init(allocator: mem.Allocator, path: []const u8) SourceError!Self {
    var self = Self{
        .path = path,
        .len = 0,
        .allocator = allocator,
        .contents = null,
        .stat = null,
    };

    try self.readFullFile();
    return self;
}

pub fn getContents(self: *const Self) SourceError![]u8 {
    if (self.contents) |c| {
        return c;
    } else {
        return error.FileReadFailed;
    }
}

pub fn deinit(self: *Self) void {
    if (self.contents) |c| {
        self.allocator.free(c);
        self.contents = null;
    }
}
