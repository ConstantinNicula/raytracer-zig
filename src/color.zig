const std = @import("std");
const Vec3 = @import("vec.zig").Vec3;
const Interval = @import("interval.zig").Interval;
pub const Color = Vec3;

fn linearToGamma(linear_component: f64) f64 {
    return std.math.sqrt(linear_component);
}

pub fn writeColor(out: anytype, pixel_color: Color, samples_per_pixel: u32) !void {
    var r = pixel_color.x;
    var g = pixel_color.y;
    var b = pixel_color.z;

    // Divide the color by the number of samples.
    const scale = 1.0 / @as(f64, @floatFromInt(samples_per_pixel));
    r *= scale;
    g *= scale;
    b *= scale;

    // Apply the linera to gamma transform.
    r = linearToGamma(r);
    g = linearToGamma(g);
    b = linearToGamma(b);

    // Write the translated [0, 255] value of each color component
    const intensity: Interval = Interval.init(0.0, 0.999);
    try out.print("{} {} {}\n", .{
        @as(i32, @intFromFloat(256 * intensity.clamp(r))),
        @as(i32, @intFromFloat(256 * intensity.clamp(g))),
        @as(i32, @intFromFloat(256 * intensity.clamp(b))),
    });
}
