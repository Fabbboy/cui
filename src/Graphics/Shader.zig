const std = @import("std");
const mem = std.mem;

const Source = @import("../ADT/Source.zig");
const String = @import("../ADT/String.zig");

const glad = @import("../c.zig").glad;

pub const ShaderError = error{
    VertexShaderFailed,
    FragmentShaderFailed,
    LinkageFailed,
} || Source.SourceError;

const Self = @This();

shader_id: usize,
err: ?String,
allocator: mem.Allocator,

pub fn init(vertex: *const Source, frag: *const Source, allocator: mem.Allocator) ShaderError!Self {
    var self = Self{
        .shader_id = 0,
        .err = null,
        .allocator = allocator,
    };

    const vertex_shader = try self.compile_shader(vertex, glad.GL_VERTEX_SHADER);
    const frag_shader = try self.compile_shader(frag, glad.GL_FRAGMENT_SHADER);

    _ = vertex_shader;
    _ = frag_shader;

    return self;
}

pub fn deinit(self: *Self) void {
    if (self.shader_id != 0) {
        glad.glDeleteProgram(@as(c_uint, @intCast(self.shader_id)));
    }

    if (self.err) |*e| {
        e.deinit();
    }
}

fn compile_shader(self: *Self, source: *const Source, shader_type: u32) ShaderError!u32 {
    const contents = try source.getContents();

    const shader_id = glad.glCreateShader(shader_type);
    glad.glShaderSource(
        shader_id,
        1,
        @as([*c]const [*c]const u8, @alignCast(@ptrCast(&contents))),
        null,
    );
    glad.glCompileShader(shader_id);

    var success: i32 = 0;
    glad.glGetShaderiv(shader_id, glad.GL_COMPILE_STATUS, &success);
    if (success == 0) {
        var log_length: i32 = 0;
        glad.glGetShaderiv(shader_id, glad.GL_INFO_LOG_LENGTH, &log_length);

        var log_str = try String.initCapacity(@as(usize, @intCast(log_length)), self.allocator);

        glad.glGetShaderInfoLog(shader_id, log_length, null, @as([*c]u8, @alignCast(@ptrCast(&log_str))));

        self.err = log_str;

        return switch (shader_type) {
            glad.GL_VERTEX_SHADER => ShaderError.VertexShaderFailed,
            glad.GL_FRAGMENT_SHADER => ShaderError.FragmentShaderFailed,
            else => unreachable,
        };
    }

    return shader_id;
}
