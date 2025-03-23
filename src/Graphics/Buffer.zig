//buffer class
const std = @import("std");
const mem = std.mem;

const glad = @import("../c.zig").glad;

pub const BufferError = error{
    BufferCreationFailed,
};

pub const BufferType = enum(u32) {
    ArrayBuffer = glad.GL_ARRAY_BUFFER,
    ElementArrayBuffer = glad.GL_ELEMENT_ARRAY_BUFFER,
    UniformBuffer = glad.GL_UNIFORM_BUFFER,

    pub fn toOpengl(self: BufferType) c_uint {
        switch (self) {
            .ArrayBuffer => return glad.GL_ARRAY_BUFFER,
            .ElementArrayBuffer => return glad.GL_ELEMENT_ARRAY_BUFFER,
            .UniformBuffer => return glad.GL_UNIFORM_BUFFER,
        }
    }
};

pub const BufferUsage = enum(u32) {
    StaticDraw = glad.GL_STATIC_DRAW,
    DynamicDraw = glad.GL_DYNAMIC_DRAW,

    pub fn toOpengl(self: BufferUsage) c_uint {
        switch (self) {
            .StaticDraw => return glad.GL_STATIC_DRAW,
            .DynamicDraw => return glad.GL_DYNAMIC_DRAW,
        }
    }
};

pub const Buffer = struct {
    pub const Self = @This();

    id: u32,
    btype: BufferType,
    usage: BufferUsage,

    pub fn create(btype: BufferType, usage: BufferUsage, comptime T: type, data: []const T) !Self {
        var id: u32 = undefined;
        glad.glGenBuffers(1, &id);
        if (id == 0) {
            return BufferError.BufferCreationFailed;
        }

        const len = data.len * @sizeOf(T);

        glad.glBindBuffer(btype.toOpengl(), id);
        glad.glBufferData(btype.toOpengl(), @as(c_long, @intCast(len)), data.ptr, usage.toOpengl());

        return Buffer{
            .id = id,
            .btype = btype,
            .usage = usage,
        };
    }

    pub fn bind(self: *const Self) void {
        glad.glBindBuffer(self.btype.toOpengl(), self.id);
    }

    pub fn unbind(self: *const Self) void {
        glad.glBindBuffer(self.btype.toOpengl(), 0);
    }

    pub fn deinit(self: *const Self) void {
        glad.glDeleteBuffers(1, &self.id);
    }
};
