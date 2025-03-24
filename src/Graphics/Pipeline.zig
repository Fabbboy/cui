const std = @import("std");
const mem = std.mem;

const c = @import("../c.zig");
const glad = c.glad;
const GLType = c.GLType;
const RenderMode = c.RenderMode;
const Buffer = @import("Buffer.zig").Buffer;

pub const PipelineError = error{
    PipelineCreationFailed,
    OutOfMemory,
};

pub const Attribute = struct {
    size: usize,
    gl_type: GLType,
    normalized: bool,
    attached: ?*Buffer,

    pub fn init(size: usize, gl_type: GLType, normalized: bool, attached: ?*Buffer) Attribute {
        return Attribute{
            .size = size,
            .gl_type = gl_type,
            .normalized = normalized,
            .attached = attached,
        };
    }

    pub fn enable(self: *Attribute, index: u32, stride: usize, offset: usize) void {
        if (self.attached) |buffer| {
            buffer.bind();
        }

        glad.glVertexAttribPointer(
            index,
            @as(c_int, @intCast(self.size)),
            self.gl_type.toOpengl(),
            @as(u8, @intFromBool(self.normalized)),
            @as(c_int, @intCast(stride)),
            @as(?*const anyopaque, @ptrFromInt(offset)),
        );
        glad.glEnableVertexAttribArray(index);
    }

    pub fn deinit(self: *Attribute) void {
        if (self.attached) |buffer| {
            buffer.deinit();
            self.attached = null;
        }
    }
};

pub const Pipeline = struct {
    const Self = @This();

    id: u32,
    attributes: std.ArrayList(Attribute),
    ebo: ?Buffer,
    stride: usize,

    pub fn init(allocator: mem.Allocator) !Self {
        var vao: u32 = 0;
        glad.glGenVertexArrays(1, &vao);
        if (vao == 0) {
            return PipelineError.PipelineCreationFailed;
        }

        return Self{
            .id = vao,
            .attributes = std.ArrayList(Attribute).init(allocator),
            .ebo = null,
            .stride = 0,
        };
    }

    pub fn attach(self: *Self, attribute: Attribute) !void {
        try self.attributes.append(attribute);
    }

    pub fn attachEbo(self: *Self, ebo: Buffer) void {
        self.ebo = ebo;
    }

    fn calcStride(self: *Self) void {
        self.stride = 0;
        for (self.attributes.items) |*attribute| {
            self.stride += attribute.size * @sizeOf(f32);
        }
    }

    pub fn finalize(self: *Self) void {
        self.bind();
        self.calcStride();

        if (self.ebo) |ebo| {
            ebo.bind();
        }

        var offset: usize = 0;
        for (self.attributes.items, 0..) |*attribute, index| {
            attribute.enable(
                @as(u32, @intCast(index)),
                self.stride,
                offset,
            );
            offset += attribute.size * @sizeOf(f32);
        }

        glad.glBindVertexArray(0);
    }

    pub fn bind(self: *const Self) void {
        glad.glBindVertexArray(self.id);
    }

    pub fn deinit(self: *Self) void {
        for (self.attributes.items) |*attribute| {
            attribute.deinit();
        }

        self.attributes.deinit();

        if (self.ebo) |ebo| {
            ebo.deinit();
        }

        if (self.id != 0) {
            glad.glDeleteVertexArrays(1, &self.id);
        }
    }

    pub fn render(self: *const Self, mode: RenderMode, count: usize) void {
        self.bind();

        if (self.ebo) |ebo| {
            ebo.bind();
            glad.glDrawElements(mode.toOpengl(), @as(c_int, @intCast(count)), glad.GL_UNSIGNED_INT, null);
        } else {
            glad.glDrawArrays(mode.toOpengl(), 0, @as(c_int, @intCast(count)));
        }
    }
};
