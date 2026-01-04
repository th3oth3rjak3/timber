const std = @import("std");
const rl = @import("raylib");

pub const Tree = struct {
    const Self = @This();
    const X_POSITION: i32 = 810;
    const Y_POSITION: i32 = 0;

    texture: rl.Texture,

    pub fn init(texture: rl.Texture) Self {
        return Self{
            .texture = texture,
        };
    }

    pub fn draw(self: *Self) void {
        rl.drawTexture(self.texture, X_POSITION, Y_POSITION, rl.Color.white);
    }
};

pub const BackgroundTree = struct {};
