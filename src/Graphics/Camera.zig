const Pair = @import("../ADT/Pair.zig").Pair;

const c = @import("../c.zig");
const glad = c.glad;
const zglm = @import("ziglm");

const Self = @This();

position: zglm.Vec2(f32),
zoom: f32,
projection: zglm.Mat4(f32),
view: zglm.Mat4(f32),
dims: Pair(u32, u32),

pub fn init(dims: Pair(u32, u32)) Self {
    const half_w = @as(f32, @floatFromInt(dims.a)) / 2.0;
    const half_h = @as(f32, @floatFromInt(dims.b)) / 2.0;

    const projection = zglm.Mat4(f32).ortho(-half_w, half_w, -half_h, half_h, -1.0, 1.0);

    const view = zglm.Mat4(f32).identity;

    return Self{
        .position = zglm.Vec2(f32).new(0.0, 0.0),
        .zoom = 1.0,
        .projection = projection,
        .view = view,
        .dims = dims,
    };
}

pub fn resize(self: *Self, dims: Pair(u32, u32)) void {
    self.dims = dims;

    const half_w = @as(f32, @floatFromInt(dims.a)) / 2.0;
    const half_h = @as(f32, @floatFromInt(dims.b)) / 2.0;

    self.projection = zglm.Mat4(f32).ortho(-half_w, half_w, -half_h, half_h, -1.0, 1.0);
}

pub fn getProjection(self: *Self) zglm.Mat4(f32) {
    return self.projection;
}

pub fn getView(self: *Self) zglm.Mat4(f32) {
    return self.view;
}

pub fn getMVP(self: *Self, model: zglm.Mat4(f32)) zglm.Mat4(f32) {
    return self.projection.mul(self.view.mul(model));
}
