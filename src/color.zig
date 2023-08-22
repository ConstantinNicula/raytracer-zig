const std = @import("std");
const Vec3 = @import("vec.zig").Vec3;

pub const Color = Vec3;

pub fn writeColor(out: anytype, pixel_color: Color) !void {
    try out.print("{} {} {}\n", .{
        @as(i32, @intFromFloat(255.999 * pixel_color.x)),
        @as(i32, @intFromFloat(255.999 * pixel_color.y)),
        @as(i32, @intFromFloat(255.999 * pixel_color.z)),
    });
}
