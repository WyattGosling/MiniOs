# MiniOs
It is a mini os idea. Using linux and zig to build a custom userspace. It probably sucks

# Prerequisites

You will need qemu and zig: `brew install qemu zig`

You will need a linux kernel in order to run this. I used [6.17](https://github.com/torvalds/linux/releases/tag/v6.17) as that was the most recent release at the time this project was started. I had to build this on a linux machine and copy it to my Mac.When building linux, target riscv64. You can folllow the instructions in https://popovicu.com/posts/making-a-micro-linux-distro/

# Building / Running

This project uses the zig build system to handle everything, including launching via qemu.

```shell
zig build
```

# Acknowledgements

Uros Popovic for creating this guide which helped me get started.
