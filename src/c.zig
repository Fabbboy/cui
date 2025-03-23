pub const glfw = @cImport({
    @cInclude("GLFW/glfw3.h");
});

pub const glad = @cImport({
    @cInclude("glad.h");
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
