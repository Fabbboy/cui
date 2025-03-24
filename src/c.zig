pub const glfw = @cImport({
    @cInclude("GLFW/glfw3.h");
});

pub const glad = @cImport({
    @cInclude("glad.h");
});

pub const stbi = @cImport({
    @cInclude("stb_image.h");
});

pub const GLType = enum(u32) {
    Float = glad.GL_FLOAT,
    Int = glad.GL_INT,

    pub fn toOpengl(self: GLType) c_uint {
        return @as(c_uint, @intFromEnum(self));
    }
};

pub const ImgFormat = enum(i32) {
    RGB = stbi.STBI_rgb,
    RGBA = stbi.STBI_rgb_alpha,

    pub fn toStbi(self: ImgFormat) c_int {
        return @as(c_int, @intFromEnum(self));
    }

    pub fn toOpengl(self: ImgFormat) c_uint {
        switch (self) {
            .RGB => return glad.GL_RGB,
            .RGBA => return glad.GL_RGBA,
        }
    }
};

pub const RenderMode = enum(u32) {
    Triangles = glad.GL_TRIANGLES,
    Lines = glad.GL_LINES,
    Points = glad.GL_POINTS,

    pub fn toOpengl(self: RenderMode) c_uint {
        return @as(c_uint, @intFromEnum(self));
    }
};
