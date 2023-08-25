const Color = @import("color.zig").Color;
const Ray = @import("ray.zig").Ray;
const HitRecord = @import("sphere.zig").HitRecord;

const Vec3 = @import("vec.zig").Vec3;
const math = @import("std").math;
const random = @import("utility.zig").random;

pub const Material = union(enum) {
    lambertian: Lambertian,
    metal: Metal,
    dielectric: Dielectric,

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
    fuzz: f64,

    pub fn init(albedo: Color, fuzz: f64) Metal {
        return Metal{
            .albedo = albedo,
            .fuzz = if (fuzz < 1) fuzz else 1,
        };
    }

    pub fn scatter(self: Metal, ray_in: Ray, rec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        var reflected: Vec3 = Vec3.reflect(Vec3.unit(ray_in.dir), rec.normal);
        reflected = Vec3.add(reflected, Vec3.randomUnitVector().smul(self.fuzz));

        scattered.* = Ray.init(rec.p, reflected);
        attenuation.* = self.albedo;
        return true;
    }
};

pub const Dielectric = struct {
    ir: f64,

    pub fn init(index_of_refraction: f64) Dielectric {
        return Dielectric{
            .ir = index_of_refraction,
        };
    }

    pub fn scatter(self: Dielectric, ray_in: Ray, rec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        attenuation.* = Color.init(1.0, 1.0, 1.0);
        const refraction_ratio: f64 = if (rec.front_face) (1.0 / self.ir) else self.ir;

        const unit_direction: Vec3 = Vec3.unit(ray_in.dir);
        const cos_theta: f64 = @min(-Vec3.dot(unit_direction, rec.normal), 1.0);
        const sin_theta: f64 = math.sqrt(1 - cos_theta * cos_theta);

        const cannot_refract: bool = (refraction_ratio * sin_theta) > 1.0;
        var direction: Vec3 = undefined;
        if (cannot_refract or (reflectance(cos_theta, refraction_ratio) > random())) {
            direction = Vec3.reflect(unit_direction, rec.normal);
        } else {
            direction = Vec3.refract(unit_direction, rec.normal, refraction_ratio);
        }

        scattered.* = Ray.init(rec.p, direction);
        return true;
    }

    fn reflectance(cosine: f64, ref_idx: f64) f64 {
        // Use schlick's approximation for reflectance.
        var r0: f64 = (1 - ref_idx) / (1 + ref_idx);
        r0 = r0 * r0;
        return r0 + (1 - r0) * math.pow(f64, (1 - cosine), 5);
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
    var mat: Material = .{ .metal = Metal.init(Color.zeros(), 0.3) };
    var attenuation: Color = undefined;
    var scattered: Ray = undefined;

    var rec: HitRecord = undefined;
    var ray_in: Ray = undefined;
    _ = mat.scatter(ray_in, rec, &attenuation, &scattered);
}

test "create dielectric" {
    var mat: Material = .{ .dielectric = Dielectric.init(0.3) };
    var attenuation: Color = undefined;
    var scattered: Ray = undefined;

    var rec: HitRecord = undefined;
    var ray_in: Ray = undefined;
    _ = mat.scatter(ray_in, rec, &attenuation, &scattered);
}
