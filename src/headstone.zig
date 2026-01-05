const std = @import("std");
const rl = @import("raylib");

pub const Headstone = struct {
    const Self = @This();

    texture: *const rl.Texture,
    isActive: bool,
    x: f32,
    y: f32,

    pub fn init(texture: *const rl.Texture) Self {
        return Self{
            .texture = texture,
            .x = 0,
            .y = 0,
            .isActive = false,
        };
    }

    pub fn show(self: *Self, x: f32, y: f32) void {
        self.isActive = true;
        self.x = x;
        self.y = y;
    }

    pub fn hide(self: *Self) void {
        self.isActive = false;
    }

    pub fn draw(self: *Self) void {
        if (!self.isActive) {
            return;
        }

        rl.drawTexture(self.texture.*, @intFromFloat(self.x), @intFromFloat(self.y), rl.Color.white);
    }
};
