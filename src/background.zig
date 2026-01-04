const std = @import("std");
const rl = @import("raylib");

pub const Background = struct {
    const Self = @This();

    texture: rl.Texture,

    pub fn init(texture: rl.Texture) Self {
        return Self{
            .texture = texture,
        };
    }

    pub fn draw(self: *Self) void {
        rl.drawTexture(self.texture, 0, 0, rl.Color.white);
    }
};
