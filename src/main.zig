const std = @import("std");
const io = @import("std").io;

const SphereList = @import("sphere.zig").SphereList;
const Sphere = @import("sphere.zig").Sphere;
const Point3 = @import("vec.zig").Point3;
const Camera = @import("camera.zig").Camera;

pub fn main() !void {
    // setup heap allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == std.heap.Check.ok);

    // configure world
    var world: SphereList = SphereList.init(gpa.allocator());
    defer world.deinit();
    try world.add(Sphere.init(Point3.init(0, 0, -1), 0.5));
    try world.add(Sphere.init(Point3.init(0, -100.5, -1), 100));

    // camera
    var cam: Camera = undefined;
    cam.aspect_ratio = 16.0 / 9.0;
    cam.image_width = 400;
    try cam.render(world);
}
