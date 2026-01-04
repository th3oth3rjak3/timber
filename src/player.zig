const std = @import("std");
const rl = @import("raylib");
const Side = @import("shared.zig").Side;

pub const Player = struct {
    const Self = @This();

    const Y_POSITION: i32 = 720;
    const X_LEFT_POSITION: i32 = 580;
    const X_RIGHT_POSITION: i32 = 1200;

    texture: rl.Texture,
    side: Side,
    x: i32,
    y: i32,

    pub fn init(texture: rl.Texture) Self {
        return Self{
            .texture = texture,
            .side = .right,
            .x = X_RIGHT_POSITION,
            .y = Y_POSITION,
        };
    }

    pub fn update(self: *Self, side: Side) void {
        switch (side) {
            .left => {
                self.side = side;
                self.x = X_LEFT_POSITION;
            },
            .right => {
                self.side = side;
                self.x = X_RIGHT_POSITION;
            },
            .none => {},
        }
    }

    pub fn draw(self: *Self) void {
        var src = rl.Rectangle{
            .x = 0,
            .y = 0,
            .width = @as(f32, @floatFromInt(self.texture.width)),
            .height = @as(f32, @floatFromInt(self.texture.height)),
        };

        const pos = rl.Vector2{
            .x = @as(f32, @floatFromInt(self.x)),
            .y = @as(f32, @floatFromInt(self.y)),
        };

        if (self.side == .left) {
            src.width = -src.width;
        }

        rl.drawTextureRec(self.texture, src, pos, rl.Color.white);
    }
};
