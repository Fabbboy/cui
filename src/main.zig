const std = @import("std");
const heap = std.heap;
const mem = std.mem;

const Pair = @import("ADT/Pair.zig").Pair;
const EventLoop = @import("Window/EventLoop.zig");
const WindowEvent = @import("Window/Event.zig").WindowEvent;
const Window = @import("Window/Window.zig");
const WindowDesc = @import("Window/Desc.zig");
const glad = @import("c.zig").glad;
const EventApp = @import("Window/App.zig").EventApp;

const c = @import("c.zig");
const glfw = c.glfw;
const RenderMode = c.RenderMode;
const GLType = c.GLType;

const Source = @import("ADT/Source.zig");

const Shader = @import("Graphics/Shader.zig");
const BufferNs = @import("Graphics/Buffer.zig");
const Buffer = BufferNs.Buffer;
const BufferType = BufferNs.BufferType;
const BufferUsage = BufferNs.BufferUsage;

const Pipeline = @import("Graphics/Pipeline.zig").Pipeline;
const Attribute = @import("Graphics/Pipeline.zig").Attribute;

const Texture = @import("Graphics/Texture.zig");

const Camera = @import("Graphics/Camera.zig");

const ziglm = @import("ziglm");

pub const GameApp = struct {
    window: *Window,
    allocator: mem.Allocator,
    triangle_shader: ?Shader,
    triangle_vbo: ?Buffer,
    triangle_ebo: ?Buffer,
    vao: ?Pipeline,
    brick_wall: ?Texture,
    camera: ?Camera,

    pub fn init(window: *Window, allocator: mem.Allocator) GameApp {
        return GameApp{
            .window = window,
            .allocator = allocator,
            .triangle_shader = null,
            .triangle_vbo = null,
            .triangle_ebo = null,
            .vao = null,
            .brick_wall = null,
            .camera = null,
        };
    }

    pub fn deinit(self: *GameApp) void {
        if (self.triangle_shader) |*shader| {
            shader.deinit();
        }

        if (self.vao) |*vao| {
            vao.deinit();
        }

        if (self.brick_wall) |*tex| {
            tex.deinit();
        }
    }

    pub fn prepare(self: *GameApp) !void {
        var vertex_source = try Source.init(self.allocator, "assets/shaders/triangle.vert");
        defer vertex_source.deinit();
        var frag_source = try Source.init(self.allocator, "assets/shaders/triangle.frag");
        defer frag_source.deinit();

        self.triangle_shader = try Shader.init(&vertex_source, &frag_source, self.allocator);

        const vertices = [_]f32{
            // positions        // tex coords
            -0.5, 0.5, 0.0, 0.0, 1.0, // top left
            0.5, 0.5, 0.0, 1.0, 1.0, // top right
            0.5, -0.5, 0.0, 1.0, 0.0, // bottom right
            -0.5, -0.5, 0.0, 0.0, 0.0, // bottom left
        };

        const indices = [_]u32{
            0, 1, 2, // first triangle (top left → top right → bottom right)
            2, 3, 0, // second triangle (bottom right → bottom left → top left)
        };

        self.triangle_vbo = try Buffer.create(BufferType.ArrayBuffer, BufferUsage.StaticDraw, f32, &vertices);
        self.triangle_ebo = try Buffer.create(BufferType.ElementArrayBuffer, BufferUsage.StaticDraw, u32, &indices);

        self.vao = try Pipeline.init(self.allocator);
        if (self.vao) |*v| {
            v.bind();
            try v.attach(Attribute.init(3, GLType.Float, false, &self.triangle_vbo.?));
            try v.attach(Attribute.init(2, GLType.Float, false, &self.triangle_vbo.?));
            v.attachEbo(self.triangle_ebo.?);
            v.finalize();
        }

        self.brick_wall = try Texture.init("assets/textures/brick_wall.png", c.ImgFormat.RGBA);

        self.camera = Camera.init(self.window.getDims());
    }

    pub fn handle(self: *GameApp, event: WindowEvent, event_loop: *EventLoop) void {
        switch (event) {
            WindowEvent.Redraw => {
                self.window.clear();

                self.vao.?.bind();
                self.triangle_shader.?.bind();
                self.brick_wall.?.bind(0);
                self.triangle_shader.?.setInt("uTexture", 0);
                self.triangle_shader.?.setMat4("uView", self.camera.?.getView());
                self.triangle_shader.?.setMat4("uProjection", self.camera.?.getProjection());
                self.vao.?.render(RenderMode.Triangles, 6);

                self.window.update();
            },
            WindowEvent.Resize => |dims| {
                self.camera.?.resize(dims.dims);
                self.window.resize(dims.dims);
            },
            WindowEvent.Close => {
                event_loop.exit();
            },
        }
    }

    pub fn app(self: *GameApp) EventApp(GameApp) {
        return EventApp(GameApp){
            .self = self,
            .vtable = .{
                .handle = &GameApp.handle,
            },
        };
    }
};

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{
        .verbose_log = false,
        .enable_memory_limit = true,
        .thread_safe = false,
    }){};

    defer {
        if (gpa.deinit() == .leak) {
            @panic("Memory leak detected.");
        }
    }

    var desc = WindowDesc.init();
    _ = desc.setName("ZUI")
        .setDims(Pair(u32, u32).init(800, 600))
        .setGLV(Pair(u4, u4).init(4, 6));

    var event_loop = EventLoop.init(desc, gpa.allocator());
    defer event_loop.deinit();
    const window = try event_loop.window();

    var gameapp = GameApp.init(window, gpa.allocator());
    defer gameapp.deinit();
    try gameapp.prepare();

    const app = gameapp.app();
    try event_loop.run(GameApp, app);

    std.debug.print("Allocated: {d:.2}KiB\n", .{@as(f64, @floatFromInt(gpa.total_requested_bytes)) / 1024.0});
}
