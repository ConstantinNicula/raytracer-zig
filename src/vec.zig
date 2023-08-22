const math = @import("std").math;

pub const Vec3 = struct {
    x: f64,
    y: f64,
    z: f64,

    pub fn init(x: f64, y: f64, z: f64) Vec3 {
        return Vec3{
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn zeros() Vec3 {
        return Vec3{ .x = 0, .y = 0, .z = 0 };
    }

    pub fn ones() Vec3 {
        return Vec3{ .x = 1, .y = 1, .z = 1 };
    }

    pub fn add(self: Vec3, other: Vec3) Vec3 {
        return Vec3{
            .x = self.x + other.x,
            .y = self.y + other.y,
            .z = self.z + other.z,
        };
    }

    pub fn sub(self: Vec3, other: Vec3) Vec3 {
        return Vec3{
            .x = self.x - other.x,
            .y = self.y - other.y,
            .z = self.z - other.z,
        };
    }

    pub fn smul(self: Vec3, s: f64) Vec3 {
        return Vec3{
            .x = self.x * s,
            .y = self.y * s,
            .z = self.z * s,
        };
    }

    pub fn sdiv(self: Vec3, s: f64) Vec3 {
        return self.smul((1.0 / s));
    }

    pub fn vmul(self: Vec3, other: Vec3) Vec3 {
        return Vec3{
            .x = self.x * other.x,
            .y = self.y * other.y,
            .z = self.z * other.z,
        };
    }

    pub fn len(self: Vec3) f64 {
        return math.sqrt(self.sqlen());
    }

    pub fn sqlen(self: Vec3) f64 {
        return self.x * self.x + self.y * self.y + self.z * self.z;
    }

    pub fn dot(u: Vec3, v: Vec3) f64 {
        return u.x * v.x + u.y * v.y + u.z * v.z;
    }

    pub fn cross(u: Vec3, v: Vec3) Vec3 {
        return Vec3{
            .x = u.y * v.z - u.z * v.y,
            .y = u.z * v.x - u.x * v.z,
            .z = u.x * v.y - u.y * v.x,
        };
    }

    pub fn unit(v: Vec3) Vec3 {
        return v.sdiv(v.len());
    }
};

pub const Point3 = Vec3;

const assert = @import("std").debug.assert;
const eps: f64 = 1e-6;

fn assertEq(exp: Vec3, val: Vec3) void {
    assert(math.fabs(exp.x - val.x) < eps);
    assert(math.fabs(exp.y - val.y) < eps);
    assert(math.fabs(exp.z - val.z) < eps);
}

test "vector zeros" {
    assertEq(Vec3.zeros(), Vec3{ .x = 0, .y = 0, .z = 0 });
}

test "vector ones" {
    assertEq(Vec3.ones(), Vec3{ .x = 1, .y = 1, .z = 1 });
}

test "vector add" {
    var v: Vec3 = Vec3.init(1.0, 2.0, 3.0);
    var res = v.add(Vec3.init(1.0, 2.0, 3.0));
    assertEq(Vec3.init(2.0, 4.0, 6.0), res);
}

test "vector sub" {
    var v: Vec3 = Vec3.init(1.0, 2.0, 3.0);
    var res = v.sub(Vec3.init(0.5, 0.5, 0.5));
    assertEq(Vec3.init(0.5, 1.5, 2.5), res);
}

test "vector scalar multiply" {
    var v: Vec3 = Vec3.init(1.0, 2.0, 3.0);
    var res: Vec3 = v.smul(2.0);
    assertEq(Vec3.init(2.0, 4.0, 6.0), res);
}

test "vector scalar divide" {
    var v: Vec3 = Vec3.init(1.0, 2.0, 3.0);
    var res: Vec3 = v.sdiv(2.0);
    assertEq(Vec3.init(0.5, 1.0, 1.5), res);
}

test "vector vector multiply" {
    var v: Vec3 = Vec3.init(1.0, 2.0, 3.0);
    var res: Vec3 = v.vmul(v);
    assertEq(Vec3.init(1.0, 4.0, 9.0), res);
}

test "vector len" {
    var v: Vec3 = Vec3.init(1.0, 2.0, 3.0);
    var len: f64 = v.len();
    assert(math.fabs(len - math.sqrt(14.0)) < eps);
}

test "vector sqlen" {
    var v: Vec3 = Vec3.init(1.0, 2.0, 3.0);
    var len: f64 = v.sqlen();
    assert(math.fabs(len - 14.0) < eps);
}

test "vector dot" {
    var v1: Vec3 = Vec3.init(4.0, 1.0, 5.0);
    var v2: Vec3 = Vec3.init(2.3, 1.6, 2.19);
    assert(math.fabs(Vec3.dot(v1, v2) - (4.0 * 2.3 + 1.6 + 5.0 * 2.19)) < eps);
}

test "vector cross" {
    var v1: Vec3 = Vec3.init(4.89, 1.78, 5.0);
    var v2: Vec3 = Vec3.init(2.3, 1.6, 2.19);
    var res: Vec3 = Vec3.cross(v1, v2);

    assert(math.fabs(Vec3.dot(v1, res)) < eps);
    assert(math.fabs(Vec3.dot(v2, res)) < eps);
}

test "vector unit" {
    var v1: Vec3 = Vec3.init(2.3, 1.6, 2.19);
    var res: Vec3 = Vec3.unit(v1);
    assert(math.fabs(1 - res.len()) < eps);
    assertEq(v1, res.smul(v1.len()));
}
