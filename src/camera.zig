const SphereList = @import("sphere.zig").SphereList;
const Sphere = @import("sphere.zig").Sphere;
const HitRecord = @import("sphere.zig").HitRecord;

const Ray = @import("ray.zig").Ray;
const color = @import("color.zig");
const Color = color.Color;
const Vec3 = @import("vec.zig").Vec3;
const Point3 = @import("vec.zig").Point3;
const Interval = @import("interval.zig").Interval;

const std = @import("std");
const math = std.math;

pub const Camera = struct {
    aspect_ratio: f64 = 1.0,
    image_width: u32 = 100,

    image_height: u32, // image height
    center: Point3,
    pixel00_loc: Point3,
    pixel_delta_u: Vec3,
    pixel_delta_v: Vec3,

    pub fn initialize(self: *Camera) void {
        // compute image widht and heigh based on aspect ratio
        self.image_height = @intFromFloat(@as(f64, @floatFromInt(self.image_width)) / self.aspect_ratio);
        self.image_height = if (self.image_height < 1) 1 else self.image_height;

        self.center = Point3.zeros();

        // compute viewport width
        const focal_length: f64 = 1.0;
        const viewport_height: f64 = 2.0;
        const viewport_width: f64 = viewport_height * (@as(f64, @floatFromInt(self.image_width)) /
            @as(f64, @floatFromInt(self.image_height)));

        // compute uv vectors
        const viewport_u: Vec3 = Vec3.init(viewport_width, 0, 0);
        const viewport_v: Vec3 = Vec3.init(0, -viewport_height, 0);

        // compute delta uv
        self.pixel_delta_u = viewport_u.sdiv(@floatFromInt(self.image_width));
        self.pixel_delta_v = viewport_v.sdiv(@floatFromInt(self.image_height));

        // compute location of upper left pixel
        const viewport_upper_left: Vec3 = self.center
            .sub(Vec3.init(0, 0, focal_length))
            .sub(viewport_u.sdiv(2.0))
            .sub(viewport_v.sdiv(2.0));

        self.pixel00_loc = viewport_upper_left.add(self.pixel_delta_u.add(self.pixel_delta_v).sdiv(2.0));
    }

    pub fn render(self: *Camera, world: SphereList) !void {
        self.initialize();

        // configured buffered writer
        var buf = std.io.bufferedWriter(std.io.getStdOut().writer());
        var stdout = buf.writer();

        try stdout.print("P3\n {} {}\n255\n", .{ self.image_width, self.image_height });

        var j: u32 = 0;
        while (j < self.image_height) : (j += 1) {
            std.debug.print("\rScanlines remaining: {} ", .{self.image_height - j});
            var i: u32 = 0;
            while (i < self.image_width) : (i += 1) {
                var pixel_center = self.pixel00_loc
                    .add(self.pixel_delta_u.smul(@floatFromInt(i)))
                    .add(self.pixel_delta_v.smul(@floatFromInt(j)));

                const ray_direction = pixel_center.sub(self.center);
                const r: Ray = Ray.init(self.center, ray_direction);

                const pixel_color = rayColor(r, world);
                try color.writeColor(stdout, pixel_color);
            }
        }
        try buf.flush();
        std.debug.print("\rDone.                    \n", .{});
    }

    fn rayColor(ray: Ray, world: SphereList) Color {
        var rec: HitRecord = undefined;
        if (world.hit(ray, Interval.init(0, math.inf(f64)), &rec)) {
            return rec.normal.add(Color.ones()).smul(0.5);
        }

        const unit_dir: Vec3 = Vec3.unit(ray.dir);
        const a: f64 = 0.5 * (unit_dir.y + 1.0);

        var ret = Color.ones().smul(1.0 - a);
        ret = ret.add(Color.init(0.5, 0.7, 1.0).smul(a));
        return ret;
    }
};
