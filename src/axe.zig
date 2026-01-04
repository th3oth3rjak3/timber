const std = @import("std");
const rl = @import("raylib");
const Side = @import("shared.zig").Side;

pub const Axe = struct {
    const Self = @This();

    const X_POSITION_RIGHT: i32 = 1075;
    const X_POSITION_LEFT: i32 = 700;
    const Y_POSITION: i32 = 830;

    side: Side,
    texture: rl.Texture,
    x: i32,
    y: i32,

    pub fn init(texture: rl.Texture) Self {
        return Self{
            .side = .none,
            .texture = texture,
            .x = X_POSITION_RIGHT,
            .y = Y_POSITION,
        };
    }

    pub fn update(self: *Self, side: Side) void {
        self.side = side;
        switch (side) {
            .left => {
                self.x = X_POSITION_LEFT;
            },
            .right => {
                self.x = X_POSITION_RIGHT;
            },
            .none => {},
        }
    }

    pub fn draw(self: *Self) void {
        if (self.side == .none) {
            return;
        }

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
