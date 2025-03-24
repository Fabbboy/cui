const ecs = @import("ecs");

const EventLoop = @import("EventLoop.zig");
const WindowEvent = @import("Event.zig").WindowEvent;
const Window = @import("../Window/Window.zig");
const Desc = @import("../Window/Desc.zig");

const AppNs = @import("App.zig");
const App = AppNs.App;
const Plugin = AppNs.Plugin;

pub const DefaultPlugin = struct {
    windowEntity: ?ecs.Entity,
    event_loop: ?EventLoop,
    window: ?*Window,

    pub fn init() DefaultPlugin {
        return DefaultPlugin{
            .windowEntity = null,
            .event_loop = null,
            .window = null,
        };
    }

    pub fn deinit(selfo: *anyopaque) void {
        const self = @as(*DefaultPlugin, @alignCast(@ptrCast(selfo)));

        if (self.event_loop) |*el| {
            el.deinit();
        }

        if (self.window) |w| {
            w.deinit();
        }
    }

    pub fn build(selfo: *anyopaque, app: *App) anyerror!void {
        const self = @as(*DefaultPlugin, @alignCast(@ptrCast(selfo)));

        self.windowEntity = app.createEntity();
        const defaultDesc = Desc.init();

        self.event_loop = EventLoop.init(defaultDesc, app.allocator);
        self.window = try self.event_loop.?.window();
        app.spawn(self.windowEntity.?, self.window.?);
        app.spawn(self.windowEntity.?, self.event_loop.?);
    }

    pub fn plugin(self: *DefaultPlugin) Plugin {
        return Plugin{
            .self = @as(*anyopaque, self),
            .vtable = Plugin.VTable{
                .build = DefaultPlugin.build,
                .deinit = DefaultPlugin.deinit,
            },
        };
    }
};
