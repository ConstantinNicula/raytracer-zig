const std = @import("std");
const Vec3 = @import("vec.zig").Vec3;
const Interval = @import("interval.zig").Interval;
const raylib = @import("raylib");

pub const Color = Vec3;

const UColor = struct { r: u8, g: u8, b: u8 };

fn linearToGamma(linear_component: f64) f64 {
    return std.math.sqrt(linear_component);
}

fn convertColor(pixel_color: Color, samples_per_pixel: u32) UColor {
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
    return UColor{
        .r = @as(u8, @intFromFloat(256 * intensity.clamp(r))),
        .g = @as(u8, @intFromFloat(256 * intensity.clamp(g))),
        .b = @as(u8, @intFromFloat(256 * intensity.clamp(b))),
    };
}

pub fn writeColorToFile(out: anytype, pixel_color: Color, samples_per_pixel: u32) !void {
    const color: UColor = convertColor(pixel_color, samples_per_pixel);
    try out.print("{} {} {}\n", .{ color.r, color.g, color.b });
}

pub fn writeColorToRowImage(image: *raylib.Image, x_pos: u32, pixel_color: Color, samples_per_pixel: u32) void {
    const color: UColor = convertColor(pixel_color, samples_per_pixel);
    raylib.ImageDrawPixel(image, @intCast(x_pos), 0, raylib.Color{ .r = color.r, .g = color.g, .b = color.b, .a = 255 });
}
