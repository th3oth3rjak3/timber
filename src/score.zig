const std = @import("std");
const rl = @import("raylib");
const GameAssets = @import("assets.zig").GameAssets;

pub const Score = struct {
    const Self = @This();
    const FONT_SIZE: f32 = 48;
    const SPACING: f32 = 2;
    const PADDING: f32 = 12;

    displayBuffer: [13]u8, // Big enough to hold "Score: 65535\0"
    score: u16,
    font: *const rl.Font,

    pub fn init(font: *const rl.Font) Self {
        return Self{
            .displayBuffer = undefined,
            .score = 0,
            .font = font,
        };
    }

    pub fn increment(self: *Self) void {
        self.score += 1;
    }

    pub fn draw(self: *Self) void {
        // Position on screen
        const pos = rl.Vector2{ .x = 20, .y = 20 };
        // Format score into buffer
        const text = std.fmt.bufPrintZ(&self.displayBuffer, "Score: {}", .{self.score}) catch unreachable;

        // Measure text size with your font
        const size = rl.measureTextEx(
            self.font.*,
            text,
            FONT_SIZE,
            SPACING,
        );

        // Draw semi-transparent black rectangle behind the text
        rl.drawRectangleRec(
            rl.Rectangle{
                .x = pos.x - PADDING,
                .y = pos.y - PADDING,
                .width = size.x + PADDING * 2,
                .height = size.y + PADDING * 2,
            },
            rl.Color{ .r = 0, .g = 0, .b = 0, .a = 150 }, // alpha 150 = semi-transparent
        );

        // Draw white text on top
        rl.drawTextEx(
            self.font.*,
            text,
            pos,
            FONT_SIZE,
            SPACING,
            rl.Color.white,
        );
    }
};
