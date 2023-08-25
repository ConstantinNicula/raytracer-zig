const Color = @import("color.zig").Color;
const Ray = @import("ray.zig").Ray;
const HitRecord = @import("sphere.zig").HitRecord;

const Vec3 = @import("vec.zig").Vec3;

pub const Material = union(enum) {
    lambertian: Lambertian,
    metal: Metal,

    pub fn scatter(self: Material, ray_in: Ray, rec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        switch (self) {
            inline else => |case| return case.scatter(ray_in, rec, attenuation, scattered),
        }
    }
};

pub const Lambertian = struct {
    albedo: Color,

    pub fn init(albedo: Color) Lambertian {
        return Lambertian{ .albedo = albedo };
    }

    pub fn scatter(self: Lambertian, ray_in: Ray, rec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        _ = ray_in;
        var scatter_direction: Vec3 = Vec3.add(rec.normal, Vec3.randomUnitVector());

        // catch degenerate scatter direction
        if (scatter_direction.nearZero())
            scatter_direction = rec.normal;

        scattered.* = Ray.init(rec.p, scatter_direction);
        attenuation.* = self.albedo;
        return true;
    }
};

pub const Metal = struct {
    albedo: Color,

    pub fn init(albedo: Color) Metal {
        return Metal{ .albedo = albedo };
    }

    pub fn scatter(self: Metal, ray_in: Ray, rec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        var reflected: Vec3 = Vec3.reflect(Vec3.unit(ray_in.dir), rec.normal);
        scattered.* = Ray.init(rec.p, reflected);
        attenuation.* = self.albedo;
        return true;
    }
};

test "create lambertian" {
    var mat: Material = .{ .lambertian = Lambertian.init(Color.zeros()) };
    var attenuation: Color = undefined;
    var scattered: Ray = undefined;

    var rec: HitRecord = undefined;
    var ray_in: Ray = undefined;
    _ = mat.scatter(ray_in, rec, &attenuation, &scattered);
}

test "create metal" {
    var mat: Material = .{ .metal = Metal.init(Color.zeros()) };
    var attenuation: Color = undefined;
    var scattered: Ray = undefined;

    var rec: HitRecord = undefined;
    var ray_in: Ray = undefined;
    _ = mat.scatter(ray_in, rec, &attenuation, &scattered);
}
