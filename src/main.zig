const std = @import("std");
const io = @import("std").io;

const Vec3 = @import("vec.zig").Vec3;
const color = @import("color.zig");
const Color = color.Color;

pub fn main() !void {
    // Image
    const image_width: u32 = 256;
    const image_height: u32 = 256;

    var buf = std.io.bufferedWriter(std.io.getStdOut().writer());
    var stdout = buf.writer();

    try stdout.print("P3\n {} {}\n255\n", .{ image_width, image_height });

    var j: u32 = 0;
    while (j < image_height) : (j += 1) {
        std.debug.print("\rScanlines remaining: {} ", .{image_height - j});
        var i: u32 = 0;
        while (i < image_width) : (i += 1) {
            const pixel_color = Color.init(
                @as(f64, @floatFromInt(i)) / (image_width - 1),
                @as(f64, @floatFromInt(j)) / (image_height - 1),
                0,
            );
            try color.writeColor(stdout, pixel_color);
        }
    }
    try buf.flush();

    std.debug.print("\rDone.                    \n", .{});
}
