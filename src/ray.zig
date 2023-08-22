const Vec3 = @import("vec.zig").Vec3;
const Point3 = @import("vec.zig").Point3;

pub const Ray = struct {
    origin: Point3,
    dir: Vec3,

    pub fn init(origin: Vec3, dir: Vec3) Ray {
        return Ray{
            .origin = origin,
            .dir = dir,
        };
    }

    pub fn at(self: Ray, t: f64) Point3 {
        return self.origin.add(self.dir.smul(t));
    }
};

const assertEq = @import("vec.zig").assertEq;
test "test ray.at()" {
    var r: Ray = Ray.init(Vec3.init(1.0, 2.0, 3.0), Vec3.ones());
    var res: Point3 = r.at(1.0);
    var exp: Point3 = Point3.init(2.0, 3.0, 4.0);
    assertEq(exp, res);
}
