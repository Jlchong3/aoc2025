const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const day = b.option(u64, "day", "The day selected to run");
    const part = b.option(u64, "part", "The part selected to run");

    const main_run_step = b.step("run", "Run all files selected");

    var previous_step: ?*std.Build.Step = null;

    if (day) |d| {
        const dir_name = b.fmt("day{d}", .{d});
        var dir = try std.fs.cwd().openDir(dir_name, .{ .iterate = true });
        var dir_iterator = dir.iterate();

        while (try dir_iterator.next()) |file| {
            if (file.kind != .file or !std.mem.endsWith(u8, file.name, ".zig")) continue;

            // Added safety check for short filenames to prevent crashing
            if (file.name.len < 5) continue;

            const challenge_part = try std.fmt.parseUnsigned(u64, &.{file.name[file.name.len - 5]}, 10);
            if (part == null or challenge_part == part.?) {
                const exe = b.addExecutable(.{
                    .name = file.name,
                    .root_module = b.createModule(.{
                        .root_source_file = b.path(b.fmt("{s}/{s}", .{dir_name, file.name})),
                        .target = target,
                        .optimize = optimize,
                    }),
                });
                const run_cmd = b.addRunArtifact(exe);

                if (previous_step) |prev| {
                    run_cmd.step.dependOn(prev);
                }
                previous_step = &run_cmd.step;

                main_run_step.dependOn(&run_cmd.step);
            }
        }

    } else {
        var dir = try std.fs.cwd().openDir(".", .{ .iterate = true });
        defer dir.close();

        var dir_iterator = dir.iterate();

        while (try dir_iterator.next()) |dir_entry| {
            if (dir_entry.kind != .directory) continue;
            var sub_dir = try std.fs.cwd().openDir(dir_entry.name, .{ .iterate = true });
            defer sub_dir.close();
            var sub_dir_iterator = sub_dir.iterate();
            while (try sub_dir_iterator.next()) |file| {
                if (file.kind != .file or !std.mem.endsWith(u8, file.name, ".zig")) continue;

                // Added safety check
                if (file.name.len < 5) continue;

                const challenge_part = try std.fmt.parseUnsigned(u64, &.{file.name[file.name.len - 5]}, 10);
                if (part == null or challenge_part == part.?) {
                    const exe = b.addExecutable(.{
                        .name = file.name,
                        .root_module = b.createModule(.{
                            .root_source_file = b.path(b.fmt("{s}/{s}", .{dir_entry.name, file.name})),
                            .target = target,
                            .optimize = optimize,
                        }),
                    });
                    const run_cmd = b.addRunArtifact(exe);

                    if (previous_step) |prev| {
                        run_cmd.step.dependOn(prev);
                    }
                    previous_step = &run_cmd.step;

                    main_run_step.dependOn(&run_cmd.step);
                }
            }
        }
    }
}
