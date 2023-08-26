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

const random = @import("utility.zig").random;

pub const Camera = struct {
    aspect_ratio: f64 = 1.0,
    image_width: u32 = 100,
    samples_per_pixel: u32 = 10,
    max_depth: u32 = 10,
    vfov: f64 = 90,
    lookFrom: Point3 = Point3.init(0, 0, -1),
    lookAt: Point3 = Point3.init(0, 0, 0),
    vup: Vec3 = Vec3.init(0, 1, 0),
    defocus_angle: f64 = 0, // Variation angle of rays through each pixel
    focus_dist: f64 = 10,

    image_height: u32, // image height
    center: Point3,
    pixel00_loc: Point3,
    pixel_delta_u: Vec3,
    pixel_delta_v: Vec3,

    // Camera frame basis vectors
    u: Vec3,
    v: Vec3,
    w: Vec3,

    defocus_disk_u: Vec3,
    defocus_disk_v: Vec3,

    pub fn initialize(self: *Camera) void {
        // compute image widht and heigh based on aspect ratio
        self.image_height = @intFromFloat(@as(f64, @floatFromInt(self.image_width)) / self.aspect_ratio);
        self.image_height = if (self.image_height < 1) 1 else self.image_height;

        self.center = self.lookFrom;

        // compute viewport width
        const tetha: f64 = math.degreesToRadians(f64, self.vfov);
        const h = math.tan(tetha / 2.0);
        const viewport_height: f64 = 2 * self.focus_dist * h;
        const viewport_width: f64 = viewport_height * (@as(f64, @floatFromInt(self.image_width)) /
            @as(f64, @floatFromInt(self.image_height)));

        // Calculate the u, v, w unit basis vectors fro the camera coordinate frame.
        self.w = Vec3.unit(self.lookFrom.sub(self.lookAt));
        self.u = Vec3.unit(Vec3.cross(self.vup, self.w));
        self.v = Vec3.cross(self.w, self.u);

        // compute uv vectors
        const viewport_u: Vec3 = self.u.smul(viewport_width);
        const viewport_v: Vec3 = self.v.smul(-viewport_height);

        // compute delta uv
        self.pixel_delta_u = viewport_u.sdiv(@floatFromInt(self.image_width));
        self.pixel_delta_v = viewport_v.sdiv(@floatFromInt(self.image_height));

        // compute location of upper left pixel
        const viewport_upper_left: Vec3 = self.center
            .sub(self.w.smul(self.focus_dist))
            .sub(viewport_u.sdiv(2.0))
            .sub(viewport_v.sdiv(2.0));

        self.pixel00_loc = viewport_upper_left.add(self.pixel_delta_u.add(self.pixel_delta_v).sdiv(2.0));

        // calculate the camera defocus disk basis vectors.
        const defocus_radius = self.focus_dist * math.tan(math.degreesToRadians(f64, self.defocus_angle / 2.0));
        self.defocus_disk_u = self.u.smul(defocus_radius);
        self.defocus_disk_v = self.v.smul(defocus_radius);
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
                var pixel_color: Color = Color.zeros();
                var sample: u32 = 0;
                while (sample < self.samples_per_pixel) : (sample += 1) {
                    const r: Ray = self.getRay(i, j);
                    pixel_color = pixel_color.add(rayColor(r, self.max_depth, world));
                }
                try color.writeColor(stdout, pixel_color, self.samples_per_pixel);
            }
        }
        try buf.flush();
        std.debug.print("\rDone.                    \n", .{});
    }

    fn getRay(self: Camera, i: u32, j: u32) Ray {
        // Get a randomly smapled camera ray for the pixel at location i, j.
        const pixel_center = self.pixel00_loc
            .add(self.pixel_delta_u.smul(@floatFromInt(i)))
            .add(self.pixel_delta_v.smul(@floatFromInt(j)));
        const pixel_sample = pixel_center.add(self.pixelSampleSquare());

        const ray_origin = if (self.defocus_angle <= 0) self.center else self.pixelDefocusDiskSample();
        const ray_direction = pixel_sample.sub(ray_origin);
        return Ray.init(ray_origin, ray_direction);
    }

    fn pixelSampleSquare(self: Camera) Vec3 {
        // Returns a random point in the square surrounding a pixel at the origin.
        const px: f64 = -0.5 + random();
        const py: f64 = -0.5 + random();
        return Vec3.add(self.pixel_delta_u.smul(px), self.pixel_delta_v.smul(py));
    }

    fn pixelDefocusDiskSample(self: Camera) Vec3 {
        // returns a point in the camera defocus disk.
        const p: Vec3 = Vec3.randomInUnitDisk();
        return self.center
            .add(self.defocus_disk_u.smul(p.x))
            .add(self.defocus_disk_v.smul(p.y));
    }

    fn rayColor(ray: Ray, depth: u32, world: SphereList) Color {
        var rec: HitRecord = undefined;

        // If we've exceeded the ray bounce limit, no more light is gathered.
        if (depth == 0) {
            return Color.zeros();
        }

        if (world.hit(ray, Interval.init(0.001, math.inf(f64)), &rec)) {
            var scattered: Ray = undefined;
            var attenuation: Color = undefined;
            if (rec.mat.scatter(ray, rec, &attenuation, &scattered)) {
                return Vec3.vmul(attenuation, rayColor(scattered, depth - 1, world));
            }
            return Color.init(0, 0, 0);
        }

        const unit_dir: Vec3 = Vec3.unit(ray.dir);
        const a: f64 = 0.5 * (unit_dir.y + 1.0);
        return Color.lerp(Color.init(1.0, 1.0, 1.0), Color.init(0.5, 0.7, 1.0), a);
    }
};
