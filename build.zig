const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{
        .default_target = .{
            .os_tag = .linux,
            .cpu_arch = .riscv64,
        }
    });
    const optimize = b.standardOptimizeOption(.{});

    const init = b.addExecutable(.{
        .name = "init",
        .root_module = b.createModule(.{
            .root_source_file = b.path("init.zig"),
            .target = target,
            .optimize = optimize,
        })
    });
    b.installArtifact(init);

    const shell = b.addExecutable(.{
        .name = "shell",
        .root_module = b.createModule(.{
            .root_source_file = b.path("shell.zig"),
            .target = target,
            .optimize = optimize,
        })
    });
    b.installArtifact(shell);

    const create_initramfs = b.addSystemCommand(&.{"cpio"});
    const bin_path = std.Build.LazyPath{.cwd_relative = b.getInstallPath(.bin, ".")};
    create_initramfs.setCwd(bin_path);
    create_initramfs.addArg("--create");
    create_initramfs.addArg("--format");
    create_initramfs.addArg("newc");
    create_initramfs.addArg("--file");
    create_initramfs.addArg("initramfs.cpio");
    const contents = "init\nshell\n";
    create_initramfs.setStdIn(.{ .bytes = contents });
    create_initramfs.step.dependOn(&shell.step);
    create_initramfs.step.dependOn(&init.step);

    const run_qemu = b.addSystemCommand(&.{"qemu-system-riscv64"});
    run_qemu.addArg("-serial");
    run_qemu.addArg("vc:120Cx48C");
    run_qemu.addArg("-machine");
    run_qemu.addArg("virt");
    run_qemu.addArg("-kernel");
    run_qemu.addArg("Image");
    run_qemu.addArg("-initrd");
    run_qemu.addArg(b.getInstallPath(.bin, "initramfs.cpio"));
    run_qemu.step.dependOn(&create_initramfs.step);

    b.getInstallStep().dependOn(&run_qemu.step);
}