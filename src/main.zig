const std = @import("std");
const builtin = @import("builtin");
const b = @import("branch.zig");
const rl = @import("raylib");
const util = @import("utils.zig");

const Axe = @import("axe.zig").Axe;
const Background = @import("background.zig").Background;
const BackgroundTree = @import("tree.zig").BackgroundTree;
const Bee = @import("bee.zig").Bee;
const Branch = @import("branch.zig").Branch;
const Cloud = @import("cloud.zig").Cloud;
const GameAssets = @import("assets.zig").GameAssets;
const Log = @import("log.zig").Log;
const Player = @import("player.zig").Player;
const Score = @import("score.zig").Score;
const Timer = @import("timer.zig").Timer;
const Tree = @import("tree.zig").Tree;

const SCREEN_WIDTH = 1920;
const SCREEN_HEIGHT = 1080;

const is_debug = builtin.mode == .Debug or builtin.mode == .ReleaseSafe;
// This will get lazily evaluated and removed when not in debug mode
// https://ziggit.dev/t/allocator-swapping-and-type-consistency/10217/7
var dba: std.heap.DebugAllocator(.{}) =
    if (is_debug)
        .init
    else
        @compileError("Should not use debug allocator in release mode");

pub fn main() anyerror!void {
    defer if (is_debug) {
        const result = dba.deinit();
        if (result == .leak) {
            std.debug.print("MEMORY LEAK DETECTED!!!!\n", .{});
        }
    };

    const allocator =
        if (builtin.os.tag == .wasi) std.heap.wasm_allocator else if (is_debug) dba.allocator() else std.heap.smp_allocator;

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

    var branches: [6]Branch = undefined;
    for (&branches) |*branch| {
        branch.* = Branch.init(&assets.branch);
    }

    var background = Background.init(&assets.background);
    var tree = Tree.init(&assets.tree);
    var player = Player.init(&assets.player);
    var axe = Axe.init(&assets.axe);
    var bee = Bee.init(&assets.bee, rand);
    var score = Score.init(&assets.font);
    var timer = Timer.init();

    // Log storage
    var flyingLogs = std.ArrayList(Log).empty;
    defer flyingLogs.deinit(allocator);

    // Game Status
    var gameActive = true;

    // Game Loop
    while (!rl.windowShouldClose()) {
        // deltaTime
        const dt = rl.getFrameTime();

        // Update State
        for (&clouds) |*cloud| {
            cloud.update(rand, dt);
        }

        bee.update(rand, dt);

        if (gameActive) {
            timer.update(dt);

            if (rl.isKeyPressed(rl.KeyboardKey.left)) {
                rl.playSound(assets.chop);
                score.increment();
                player.update(.left);
                axe.update(.left);
                const newLog = try flyingLogs.addOne(allocator);
                newLog.* = Log.init(&assets.log, .left);
                b.updateBranches(&branches, rand);
                timer.addBonusTime(0.25);
            }

            if (rl.isKeyPressed(rl.KeyboardKey.right)) {
                rl.playSound(assets.chop);
                score.increment();
                player.update(.right);
                axe.update(.right);
                const newLog = try flyingLogs.addOne(allocator);
                newLog.* = Log.init(&assets.log, .right);
                b.updateBranches(&branches, rand);
                timer.addBonusTime(0.25);
            }

            if (rl.isKeyReleased(rl.KeyboardKey.right)) {
                axe.update(.none);
            }

            if (rl.isKeyReleased(rl.KeyboardKey.left)) {
                axe.update(.none);
            }

            // Check for player death
            if (branches[5].side == player.side) {
                gameActive = false;
                rl.playSound(assets.death);
            }

            // Check for out of time condition.
            if (timer.timeRemaining == 0) {
                gameActive = false;
                rl.playSound(assets.outOfTime);
            }
        }

        // Despawn offscreened logs
        for (flyingLogs.items, 0..) |*log, i| {
            if (!log.isActive) {
                _ = flyingLogs.swapRemove(i);
            }

            log.update(dt);
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

        for (flyingLogs.items) |*log| {
            log.draw();
        }

        for (&branches, 0..) |*branch, i| {
            branch.draw(i);
        }

        tree.draw();
        player.draw();
        axe.draw();
        bee.draw();
        score.draw();
        timer.draw();
    }
}
