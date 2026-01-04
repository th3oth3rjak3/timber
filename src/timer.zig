const std = @import("std");
const rl = @import("raylib");

pub const Timer = struct {
    const Self = @This();

    const DEFAULT_TIME: f32 = 6.0;
    const FULL_WIDTH: f32 = 400;
    const TIME_BAR_WIDTH_PER_SECOND: f32 = FULL_WIDTH / DEFAULT_TIME;
    const BAR_HEIGHT: f32 = 50;
    const BAR_BOTTOM_PADDING: f32 = 10;

    timeRemaining: f32,

    pub fn init() Self {
        return Self{
            .timeRemaining = DEFAULT_TIME,
        };
    }

    pub fn update(self: *Self, deltaTime: f32) void {
        self.timeRemaining = @max(0, self.timeRemaining - deltaTime);
    }

    pub fn addBonusTime(self: *Self, bonus: f32) void {
        self.timeRemaining = @min(DEFAULT_TIME, self.timeRemaining + bonus);
    }

    pub fn draw(self: *Self) void {
        // Position on screen
        const pos = rl.Vector2{ .x = (1920 / 2) - (FULL_WIDTH / 2), .y = (1080 - BAR_HEIGHT - BAR_BOTTOM_PADDING) };

        // Draw red timer rectangle
        rl.drawRectangleRec(
            rl.Rectangle{
                .x = pos.x,
                .y = pos.y,
                .width = self.timeRemaining * TIME_BAR_WIDTH_PER_SECOND,
                .height = BAR_HEIGHT,
            },
            rl.Color{ .r = 200, .g = 0, .b = 0, .a = 255 },
        );
    }
};
