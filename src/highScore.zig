const std = @import("std");
const rl = @import("raylib");

pub const HighScore = struct {
    const Self = @This();
    const FONT_SIZE: f32 = 48;
    const SPACING: f32 = 2;
    const PADDING: f32 = 12;

    best: u16,

    pub fn load(allocator: std.mem.Allocator) !Self {
        const file = std.fs.cwd().openFile("highscore.zon", .{}) catch {
            std.debug.print("No file exists, continuing\n", .{});
            return Self{ .best = 0 };
        };
        defer file.close();

        const file_size = (try file.stat()).size;
        const data = try allocator.alloc(u8, file_size);
        defer allocator.free(data);

        var file_reader = file.reader(data);
        try file_reader.interface.fill(file_size);

        const null_terminated = try allocator.dupeZ(u8, data);
        defer allocator.free(null_terminated);

        return try std.zon.parse.fromSlice(Self, allocator, null_terminated, null, .{});
    }

    pub fn save(self: *Self) !void {
        const file = try std.fs.cwd().createFile("highscore.zon", .{});
        defer file.close();

        var writebuf: [1024]u8 = undefined;
        var fileWriter = file.writer(&writebuf);
        const writer = &fileWriter.interface;

        try std.zon.stringify.serialize(self, .{}, writer);
        try writer.flush();
    }

    pub fn update(self: *Self, new: u16) void {
        self.best = new;
    }

    pub fn draw(self: *Self, font: *const rl.Font) void {
        // Position on screen
        const pos = rl.Vector2{ .x = 20, .y = 100 };

        var displayBuffer: [12]u8 = undefined;

        // Format score into buffer
        const text = std.fmt.bufPrintZ(&displayBuffer, "Best: {}", .{self.best}) catch unreachable;

        // Measure text size with your font
        const size = rl.measureTextEx(
            font.*,
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
            font.*,
            text,
            pos,
            FONT_SIZE,
            SPACING,
            rl.Color.white,
        );
    }
};
