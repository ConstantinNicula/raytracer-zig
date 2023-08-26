const std = @import("std");
const io = @import("std").io;

const SphereList = @import("sphere.zig").SphereList;
const Sphere = @import("sphere.zig").Sphere;
const Point3 = @import("vec.zig").Point3;
const Camera = @import("camera.zig").Camera;
const Material = @import("material.zig").Material;
const Lambertian = @import("material.zig").Lambertian;
const Dielectric = @import("material.zig").Dielectric;
const Metal = @import("material.zig").Metal;
const Color = @import("color.zig").Color;
const Vec3 = @import("vec.zig").Vec3;

const utils = @import("utility.zig");

pub fn main() !void {
    // setup heap allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == std.heap.Check.ok);

    // configure world
    var world: SphereList = SphereList.init(gpa.allocator());
    defer world.deinit();

    // create materials
    const material_ground: Material = Material{ .lambertian = Lambertian.init(Color.init(0.5, 0.5, 0.5)) };
    try world.add(Sphere.init(Point3.init(0, -1000, 0), 1000, material_ground));

    var a: i32 = -11;
    while (a < 11) : (a += 1) {
        var b: i32 = -11;
        while (b < 11) : (b += 1) {
            const choose_mat = utils.random();
            const center: Point3 = Point3.init(@as(f64, @floatFromInt(a)) + utils.random() * 0.9, 0.2, @as(f64, @floatFromInt(b)) + utils.random() * 0.9);

            if (center.sub(Point3.init(3, 0.2, 0)).len() > 0.9) {
                if (choose_mat < 0.8) {
                    // diffuse
                    var albedo: Color = Color.random().vmul(Color.random());
                    var sphere_material = Material{ .lambertian = Lambertian.init(albedo) };
                    try world.add(Sphere.init(center, 0.2, sphere_material));
                } else if (choose_mat < 0.95) {
                    // metal
                    var albedo: Color = Color.randomRange(0.5, 1.0);
                    var fuzz: f64 = utils.rangedRandom(0, 0.5);
                    var spehere_material = Material{ .metal = Metal.init(albedo, fuzz) };
                    try world.add(Sphere.init(center, 0.2, spehere_material));
                } else {
                    // glass
                    var sphere_material = Material{ .dielectric = Dielectric.init(1.5) };
                    try world.add(Sphere.init(center, 0.2, sphere_material));
                }
            }
        }
    }

    const material1: Material = Material{ .dielectric = Dielectric.init(1.5) };
    try world.add(Sphere.init(Point3.init(0, 1, 0), 1.0, material1));

    const material2: Material = Material{ .lambertian = Lambertian.init(Color.init(0.4, 0.2, 0.1)) };
    try world.add(Sphere.init(Point3.init(-4, 1, 0), 1.0, material2));

    const material3: Material = Material{ .metal = Metal.init(Color.init(0.7, 0.6, 0.5), 0.0) };
    try world.add(Sphere.init(Point3.init(4, 1, 0), 1.0, material3));

    // camera
    var cam: Camera = undefined;
    cam.aspect_ratio = 16.0 / 9.0;
    cam.image_width = 1200;
    cam.samples_per_pixel = 500;
    cam.max_depth = 50;

    cam.vfov = 20;
    cam.lookFrom = Point3.init(13, 2, 3);
    cam.lookAt = Point3.init(0, 0, 0);
    cam.vup = Vec3.init(0, 1, 0);
    cam.defocus_angle = 0.6;
    cam.focus_dist = 10.0;

    try cam.render(world);
}
