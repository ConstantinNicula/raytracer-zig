const std = @import("std");
const io = @import("std").io;

const Vec3 = @import("vec.zig").Vec3;
const Point3 = @import("vec.zig").Point3;
const Ray = @import("ray.zig").Ray;
const color = @import("color.zig");
const Color = color.Color;

fn rayColor(ray: Ray) Color {
    const unit_dir: Vec3 = Vec3.unit(ray.dir);
    const a: f64 = 0.5 * (unit_dir.y + 1.0);

    var ret = Color.ones().smul(1.0 - a);
    ret = ret.add(Color.init(0.5, 0.7, 1.0).smul(a));
    return ret;
}

pub fn main() !void {
    const aspect_ratio: f64 = 16.0 / 9.0;
    // compute image widht and heigh based on aspect ratio
    const image_width: u32 = 400;
    const image_height: u32 = blk: {
        var height: u32 = @intFromFloat(image_width / aspect_ratio);
        height = if (height < 1) 1 else height;
        break :blk height;
    };

    // compute viewport width
    const focal_length: f64 = 1.0;
    const viewport_height: f64 = 2.0;
    const viewport_width: f64 = viewport_height * (@as(f64, @floatFromInt(image_width)) /
        @as(f64, @floatFromInt(image_height)));
    const camera_center: Point3 = Point3.zeros();

    // compute uv vectors
    const viewport_u: Vec3 = Vec3.init(viewport_width, 0, 0);
    const viewport_v: Vec3 = Vec3.init(0, -viewport_height, 0);

    // compute delta uv
    const pixel_delta_u = viewport_u.sdiv(@floatFromInt(image_width));
    const pixel_delta_v = viewport_v.sdiv(@floatFromInt(image_height));

    // compute location of upper left pixel
    const viewport_upper_left: Vec3 = camera_center
        .sub(Vec3.init(0, 0, focal_length))
        .sub(viewport_u.sdiv(2.0))
        .sub(viewport_v.sdiv(2.0));
    const pixel00_loc = viewport_upper_left.add(pixel_delta_u.add(pixel_delta_v).sdiv(2.0));

    // configured buffered writer
    var buf = std.io.bufferedWriter(std.io.getStdOut().writer());
    var stdout = buf.writer();

    try stdout.print("P3\n {} {}\n255\n", .{ image_width, image_height });

    var j: u32 = 0;
    while (j < image_height) : (j += 1) {
        std.debug.print("\rScanlines remaining: {} ", .{image_height - j});
        var i: u32 = 0;
        while (i < image_width) : (i += 1) {
            var pixel_center = pixel00_loc
                .add(pixel_delta_u.smul(@floatFromInt(i)))
                .add(pixel_delta_v.smul(@floatFromInt(j)));

            const ray_direction = pixel_center.sub(camera_center);
            const r: Ray = Ray.init(camera_center, ray_direction);

            const pixel_color = rayColor(r);
            try color.writeColor(stdout, pixel_color);
        }
    }
    try buf.flush();

    std.debug.print("\rDone.                    \n", .{});
}
