const std = @import("std");
const mem = std.mem;

const Source = @import("../ADT/Source.zig");
const String = @import("../ADT/String.zig");

const glad = @import("../c.zig").glad;
const ziglm = @import("ziglm");

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

    self.shader_id = try self.link_shader(vertex_shader, frag_shader);

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

pub fn bind(self: *Self) void {
    glad.glUseProgram(@as(c_uint, @intCast(self.shader_id)));
}

fn link_shader(self: *Self, vertex_shader: u32, frag_shader: u32) ShaderError!u32 {
    const shader_id = glad.glCreateProgram();
    glad.glAttachShader(shader_id, vertex_shader);
    glad.glAttachShader(shader_id, frag_shader);
    glad.glLinkProgram(shader_id);

    var success: i32 = 0;
    glad.glGetProgramiv(shader_id, glad.GL_LINK_STATUS, &success);
    if (success == 0) {
        var log_length: i32 = 0;
        glad.glGetProgramiv(shader_id, glad.GL_INFO_LOG_LENGTH, &log_length);

        var log_str = try String.initCapacity(@as(usize, @intCast(log_length)), self.allocator);

        glad.glGetProgramInfoLog(shader_id, log_length, null, @as([*c]u8, @alignCast(@ptrCast(&log_str))));

        self.err = log_str;

        return ShaderError.LinkageFailed;
    }

    return shader_id;
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

pub fn setInt(self: *Self, name: []const u8, value: i32) void {
    const location = glad.glGetUniformLocation(@as(c_uint, @intCast(self.shader_id)), @as([*c]const u8, @alignCast(@ptrCast(name))));
    glad.glUniform1i(location, value);
}

pub fn setFloat(self: *Self, name: []const u8, value: f32) void {
    const location = glad.glGetUniformLocation(@as(c_uint, @intCast(self.shader_id)), @as([*c]const u8, @alignCast(@ptrCast(name))));
    glad.glUniform1f(location, value);
}

pub fn setVec2(self: *Self, name: []const u8, value: ziglm.Vec2(f32)) void {
    const location = glad.glGetUniformLocation(@as(c_uint, @intCast(self.shader_id)), @as([*c]const u8, @alignCast(@ptrCast(name))));
    glad.glUniform2f(location, value.x, value.y);
}

pub fn setVec3(self: *Self, name: []const u8, value: ziglm.Vec3(f32)) void {
    const location = glad.glGetUniformLocation(@as(c_uint, @intCast(self.shader_id)), @as([*c]const u8, @alignCast(@ptrCast(name))));
    glad.glUniform3f(location, value.x, value.y, value.z);
}

pub fn setVec4(self: *Self, name: []const u8, value: ziglm.Vec4(f32)) void {
    const location = glad.glGetUniformLocation(@as(c_uint, @intCast(self.shader_id)), @as([*c]const u8, @alignCast(@ptrCast(name))));
    glad.glUniform4f(location, value.x, value.y, value.z, value.w);
}

pub fn setMat2(self: *Self, name: []const u8, value: ziglm.Mat2(f32)) void {
    const location = glad.glGetUniformLocation(@as(c_uint, @intCast(self.shader_id)), @as([*c]const u8, @alignCast(@ptrCast(name))));
    glad.glUniformMatrix2fv(location, 1, @as(u8, @intFromBool(false)), @as([*c]const f32, @alignCast(@ptrCast(&value))));
}

pub fn setMat3(self: *Self, name: []const u8, value: ziglm.Mat3(f32)) void {
    const location = glad.glGetUniformLocation(@as(c_uint, @intCast(self.shader_id)), @as([*c]const u8, @alignCast(@ptrCast(name))));
    glad.glUniformMatrix3fv(location, 1, @as(u8, @intFromBool(false)), @as([*c]const f32, @alignCast(@ptrCast(&value))));
}

pub fn setMat4(self: *Self, name: []const u8, value: ziglm.Mat4(f32)) void {
    const location = glad.glGetUniformLocation(@as(c_uint, @intCast(self.shader_id)), @as([*c]const u8, @alignCast(@ptrCast(name))));
    glad.glUniformMatrix4fv(location, 1, @as(u8, @intFromBool(false)), @as([*c]const f32, @ptrCast(&value)));
}
