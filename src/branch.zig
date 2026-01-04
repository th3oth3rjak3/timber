const std = @import("std");
const rl = @import("raylib");
const util = @import("utils.zig");

const Side = @import("shared.zig").Side;

pub const Branch = struct {
    const Self = @This();
    const X_LEFT_POSITION: f32 = 610;
    const X_RIGHT_POSITION: f32 = 1330;
    const Y_OFFSET: f32 = 150;
    const ORIGIN = rl.Vector2{ .x = 220, .y = 20 };

    texture: *const rl.Texture,
    side: Side,

    pub fn init(texture: *const rl.Texture) Self {
        return Self{
            .texture = texture,
            .side = .none,
        };
    }

    pub fn reset(self: *Self, side: Side) void {
        self.side = side;
    }

    pub fn draw(self: *Self, index: usize) void {
        if (self.side == .none) {
            return;
        }

        const srcWidth = @as(f32, @floatFromInt(self.texture.*.width));

        const source = rl.Rectangle{
            .x = 0,
            .y = 0,
            .width = if (self.side == .left) -srcWidth else srcWidth,
            .height = @as(f32, @floatFromInt(self.texture.*.height)),
        };

        const yPosition: f32 = @as(f32, @floatFromInt(index)) * Y_OFFSET;
        const xPosition: f32 = switch (self.side) {
            .left => X_LEFT_POSITION,
            .right => X_RIGHT_POSITION,
            .none => 0,
        };

        const dest = rl.Rectangle{
            .x = xPosition,
            .y = yPosition,
            .width = source.width,
            .height = source.height,
        };

        rl.drawTexturePro(self.texture.*, source, dest, ORIGIN, 0, rl.Color.white);
    }
};

pub fn updateBranches(branches: *[6]Branch, rand: std.Random) void {
    var lastBranch = branches[5];

    for (0..branches.len - 1) |i| {
        const index = branches.len - 1 - i;
        branches[index] = branches[index - 1];
    }

    const randInt = util.randomRange(u8, rand, 0, 6);
    switch (randInt) {
        0 => {
            lastBranch.reset(.left);
        },
        1 => {
            lastBranch.reset(.right);
        },
        else => {
            lastBranch.reset(.none);
        },
    }

    branches[0] = lastBranch;
}
