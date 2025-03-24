const c = @import("../c.zig");
const glad = c.glad;
const stbi = c.stbi;
const ImgFormat = c.ImgFormat;

pub const TextureError = error{
    InvalidImage,
    UnsupportedFormat,
};

const Self = @This();

tex_id: u32,
format: ImgFormat,
width: u32,
height: u32,

pub fn init(path: []const u8, format: ImgFormat) TextureError!Self {
    var width: c_int = 0;
    var height: c_int = 0;
    var channels: c_int = 0;
    const stbi_format = format.toStbi();
    const data = stbi.stbi_load(@as([*c]const u8, @alignCast(@ptrCast(path))), &width, &height, &channels, stbi_format);

    if (data == null) {
        return TextureError.InvalidImage;
    }

    var tex_id: u32 = 0;
    glad.glGenTextures(1, &tex_id);
    glad.glBindTexture(glad.GL_TEXTURE_2D, tex_id);
    glad.glTexParameteri(glad.GL_TEXTURE_2D, glad.GL_TEXTURE_WRAP_S, glad.GL_REPEAT);
    glad.glTexParameteri(glad.GL_TEXTURE_2D, glad.GL_TEXTURE_WRAP_T, glad.GL_REPEAT);
    glad.glTexParameteri(glad.GL_TEXTURE_2D, glad.GL_TEXTURE_MIN_FILTER, glad.GL_LINEAR);
    glad.glTexParameteri(glad.GL_TEXTURE_2D, glad.GL_TEXTURE_MAG_FILTER, glad.GL_LINEAR);
    glad.glTexImage2D(
        glad.GL_TEXTURE_2D,
        0,
        @as(c_int, @intCast(format.toOpengl())),
        width,
        height,
        0,
        format.toOpengl(),
        glad.GL_UNSIGNED_BYTE,
        data,
    );
    glad.glGenerateMipmap(glad.GL_TEXTURE_2D);
    stbi.stbi_image_free(data);

    return Self{
        .tex_id = tex_id,
        .format = format,
        .width = @as(u32, @intCast(width)),
        .height = @as(u32, @intCast(height)),
    };
}

pub fn bind(self: *Self, slot: u32) void {
    const casted = @as(c_uint, @intCast(slot));
    const base = @as(c_uint, @intCast(glad.GL_TEXTURE0));
    const added = @as(c_uint, @intCast(base + casted));

    glad.glActiveTexture(added);
    glad.glBindTexture(glad.GL_TEXTURE_2D, self.tex_id);
}

pub fn deinit(self: *Self) void {
    glad.glDeleteTextures(1, &self.tex_id);
}
