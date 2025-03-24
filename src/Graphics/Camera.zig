const Pair = @import("../ADT/Pair.zig").Pair;

const c = @import("../c.zig");
const glad = c.glad;
const glm = @import("../glm.zig");

const Self = @This();

position: glm.Vec2,
projection: glm.Mat4,
view: glm.Mat4,

pub fn init(dims: Pair(u32, u32)) Self {
    const half_w = @as(f32, @floatFromInt(dims.a)) / 2.0;
    const half_h = @as(f32, @floatFromInt(dims.b)) / 2.0;

    const projection = glm.ortho(-half_w, half_w, -half_h, half_h, -1.0, 1.0);

    const view = glm.Mat4.identity();

    return Self{
        .position = glm.Vec2.zeros(),
        .projection = projection,
        .view = view,
    };
}

pub fn resize(self: *Self, dims: Pair(u32, u32)) void {
    const half_w = @as(f32, @floatFromInt(dims.a)) / 2.0;
    const half_h = @as(f32, @floatFromInt(dims.b)) / 2.0;

    self.projection = glm.ortho(-half_w, half_w, -half_h, half_h, -1.0, 1.0);
}

pub fn getProjection(self: *Self) glm.Mat4 {
    return self.projection;
}

pub fn getView(self: *Self) glm.Mat4 {
    return self.view;
}

pub fn getMVP(self: *Self, model: glm.Mat4) glm.Mat4 {
    return model.matmul(self.view).matmul(self.projection);
}
