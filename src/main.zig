const std = @import("std");
const rl = @import("raylib");
const GameAssets = @import("assets.zig").GameAssets;
const util = @import("utils.zig");
const Cloud = @import("cloud.zig").Cloud;
const Bee = @import("bee.zig").Bee;
const Tree = @import("tree.zig").Tree;

const SCREEN_WIDTH = 1920;
const SCREEN_HEIGHT = 1080;

pub fn main() anyerror!void {
    var prng = std.Random.DefaultPrng.init(@bitCast(std.time.timestamp()));
    const rand = prng.random();

    rl.initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Timber!!");
    defer rl.closeWindow();
    rl.setTargetFPS(120);

    rl.initAudioDevice();
    defer rl.closeAudioDevice();

    const assets = try GameAssets.load();
    defer assets.unload();

    var clouds: [3]Cloud = undefined;
    for (&clouds) |*c| {
        c.* = Cloud.init(assets.cloud, rand);
    }

    var tree = Tree.init(assets.tree);

    var bee = Bee.init(assets.bee, rand);

    // Game Loop
    while (!rl.windowShouldClose()) {
        // deltaTime
        const dt = rl.getFrameTime();

        // Update State
        for (&clouds) |*cloud| {
            cloud.update(rand, dt);
        }

        bee.update(rand, dt);

        // Render
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);

        rl.drawTexture(assets.background, 0, 0, rl.Color.white);
        for (&clouds) |*cloud| {
            cloud.draw();
        }

        tree.draw();

        bee.draw();
    }
}
