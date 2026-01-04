const std = @import("std");
const rl = @import("raylib");

const Side = @import("shared.zig").Side;

pub const Log = struct {
    const Self = @This();

    const X_POSITION: f32 = 810;
    const Y_POSITION: f32 = 720;

    const SPEED_X: f32 = 5000;
    const SPEED_Y: f32 = -1500;

    isActive: bool,
    x: f32,
    y: f32,
    xSpeed: f32,
    ySpeed: f32,
    texture: *const rl.Texture,

    pub fn init(texture: *const rl.Texture, side: Side) Self {
        const xSpeed = switch (side) {
            .left => SPEED_X,
            .right => -SPEED_X,
            .none => 0,
        };

        return Self{
            .isActive = true,
            .texture = texture,
            .x = X_POSITION,
            .y = Y_POSITION,
            .xSpeed = xSpeed,
            .ySpeed = SPEED_Y,
        };
    }

    pub fn update(self: *Self, deltaTime: f32) void {
        self.x += deltaTime * self.xSpeed;
        self.y += deltaTime * self.ySpeed;

        const rightSide = self.x + @as(f32, @floatFromInt(self.texture.width));
        if (self.x > 1920 or rightSide < 0) {
            self.isActive = false;
        }

        const bottomSide = self.y + @as(f32, @floatFromInt(self.texture.height));
        if (bottomSide < 0) {
            self.isActive = false;
        }
    }

    pub fn draw(self: *Self) void {
        if (!self.isActive) {
            return;
        }

        rl.drawTexture(self.texture.*, @intFromFloat(self.x), @intFromFloat(self.y), rl.Color.white);
    }
};
