const std = @import("std");
const rl = @import("raylib");
const util = @import("utils.zig");

pub const Bee = struct {
    const Self = @This();

    const MIN_SPEED: f32 = 200;
    const MAX_SPEED: f32 = 399;

    const MIN_Y: f32 = 500;
    const MAX_Y: f32 = 999;

    texture: *const rl.Texture,
    x: f32,
    y: f32,
    speed: f32,

    pub fn init(texture: *const rl.Texture, rand: std.Random) Self {
        return Self{
            .texture = texture,
            .x = 1920,
            .y = util.randomRange(f32, rand, MIN_Y, MAX_Y),
            .speed = util.randomRange(f32, rand, MIN_SPEED, MAX_SPEED),
        };
    }

    // Update the state based on the time that has elapsed.
    pub fn update(self: *Self, rand: std.Random, deltaTime: f32) void {
        self.x -= self.speed * deltaTime;
        const leftBound: f32 = @floatFromInt(0 - @as(i32, @intCast(self.texture.*.width)));

        if (self.x < leftBound) {
            self.x = 1920;
            self.y = util.randomRange(f32, rand, MIN_Y, MAX_Y);
        }
    }

    pub fn draw(self: *Self) void {
        rl.drawTexture(self.texture.*, @intFromFloat(self.x), @intFromFloat(self.y), rl.Color.white);
    }
};
