const std = @import("std");
const io = @import("std").io;

const SphereList = @import("sphere.zig").SphereList;
const Sphere = @import("sphere.zig").Sphere;
const Point3 = @import("vec.zig").Point3;
const Camera = @import("camera.zig").Camera;
const Material = @import("material.zig").Material;
const Lambertian = @import("material.zig").Lambertian;
const Metal = @import("material.zig").Metal;
const Color = @import("color.zig").Color;

pub fn main() !void {
    // setup heap allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == std.heap.Check.ok);

    // configure world
    var world: SphereList = SphereList.init(gpa.allocator());
    defer world.deinit();

    // create materials
    const material_ground: Material = Material{ .lambertian = Lambertian.init(Color.init(0.8, 0.8, 0.0)) };
    const material_center: Material = Material{ .lambertian = Lambertian.init(Color.init(0.7, 0.3, 0.3)) };
    const material_left: Material = Material{ .metal = Metal.init(Color.init(0.8, 0.8, 0.8)) };
    const material_right: Material = Material{ .metal = Metal.init(Color.init(0.8, 0.6, 0.2)) };

    try world.add(Sphere.init(Point3.init(0, -100.5, -1), 100, &material_ground));
    try world.add(Sphere.init(Point3.init(0, 0, -1), 0.5, &material_center));
    try world.add(Sphere.init(Point3.init(-1, 0, -1), 0.5, &material_left));
    try world.add(Sphere.init(Point3.init(1, 0, -1), 0.5, &material_right));

    // camera
    var cam: Camera = undefined;
    cam.aspect_ratio = 16.0 / 9.0;
    cam.image_width = 400;
    cam.samples_per_pixel = 100;
    cam.max_depth = 50;
    try cam.render(world);
}
