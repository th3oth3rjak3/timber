const std = @import("std");
const rl = @import("raylib");
const util = @import("utils.zig");

const Axe = @import("axe.zig").Axe;
const Background = @import("background.zig").Background;
const BackgroundTree = @import("tree.zig").BackgroundTree;
const Bee = @import("bee.zig").Bee;
const Cloud = @import("cloud.zig").Cloud;
const GameAssets = @import("assets.zig").GameAssets;
const Player = @import("player.zig").Player;
const Score = @import("score.zig").Score;
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
        c.* = Cloud.init(&assets.cloud, rand);
    }

    var backgroundTrees: [3]BackgroundTree = undefined;
    backgroundTrees[0] = BackgroundTree.init(&assets.treeAlt, 20, 0);
    backgroundTrees[1] = BackgroundTree.init(&assets.treeAlt, 1500, -40);
    backgroundTrees[2] = BackgroundTree.init(&assets.treeAlt, 1900, 0);

    var background = Background.init(&assets.background);
    var tree = Tree.init(&assets.tree);
    var player = Player.init(&assets.player);
    var axe = Axe.init(&assets.axe);
    var bee = Bee.init(&assets.bee, rand);
    var score = Score.init(&assets.font);

    // Game Loop
    while (!rl.windowShouldClose()) {
        // deltaTime
        const dt = rl.getFrameTime();

        // Update State
        for (&clouds) |*cloud| {
            cloud.update(rand, dt);
        }

        bee.update(rand, dt);

        if (rl.isKeyPressed(rl.KeyboardKey.left)) {
            rl.playSound(assets.chop);
            score.increment();
            player.update(.left);
            axe.update(.left);
        }

        if (rl.isKeyPressed(rl.KeyboardKey.right)) {
            rl.playSound(assets.chop);
            score.increment();
            player.update(.right);
            axe.update(.right);
        }

        if (rl.isKeyReleased(rl.KeyboardKey.right)) {
            axe.update(.none);
        }

        if (rl.isKeyReleased(rl.KeyboardKey.left)) {
            axe.update(.none);
        }

        // Render
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);

        background.draw();

        for (&clouds) |*cloud| {
            cloud.draw();
        }

        for (&backgroundTrees) |*backgroundTree| {
            backgroundTree.draw();
        }

        tree.draw();
        player.draw();
        axe.draw();
        bee.draw();
        score.draw();
    }
}
