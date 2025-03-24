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
        switch (self) {
            .Float => return glad.GL_FLOAT,
            .Int => return glad.GL_INT,
        }
    }
};

pub const ImgFormat = enum(u32) {
    RGB = stbi.STBI_rgb,
    RGBA = stbi.STBI_rgb_alpha,

    pub fn toStbi(self: ImgFormat) c_int {
        switch (self) {
            .RGB => return stbi.STBI_rgb,
            .RGBA => return stbi.STBI_rgb_alpha,
        }
    }

    pub fn toOpengl(self: ImgFormat) c_uint {
        switch (self) {
            .RGB => return glad.GL_RGB,
            .RGBA => return glad.GL_RGBA,
        }
    }
};
