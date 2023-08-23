const Ray = @import("ray.zig").Ray;
const Point3 = @import("vec.zig").Point3;
const Vec3 = @import("vec.zig").Vec3;

const std = @import("std");
const math = std.math;
const ArrayList = std.ArrayList;

pub const HitRecord = struct {
    p: Point3,
    normal: Vec3,
    t: f64,
    front_face: bool,

    pub fn init(p: Point3, normal: Vec3, t: f64) HitRecord {
        return HitRecord{
            .p = p,
            .normal = normal,
            .t = t,
        };
    }

    pub fn setFaceNormal(self: *HitRecord, ray: Ray, outward_normal: Vec3) void {
        self.front_face = Vec3.dot(ray.dir, outward_normal) < 0;
        self.normal = if (self.front_face) outward_normal else outward_normal.smul(-1);
    }
};

pub const Sphere = struct {
    center: Point3,
    radius: f64,

    pub fn init(center: Point3, radius: f64) Sphere {
        return Sphere{
            .center = center,
            .radius = radius,
        };
    }

    pub fn hit(self: Sphere, ray: Ray, ray_tmin: f64, ray_tmax: f64, rec: *HitRecord) bool {
        const oc: Vec3 = ray.origin.sub(self.center);
        const a: f64 = Vec3.dot(ray.dir, ray.dir);
        const half_b: f64 = Vec3.dot(oc, ray.dir);
        const c: f64 = Vec3.dot(oc, oc) - self.radius * self.radius;

        const discriminant = half_b * half_b - a * c;
        if (discriminant < 0) {
            return false;
        }

        const sqrtd: f64 = math.sqrt(discriminant);

        // Find the nearest root that lies in the acceptable range.
        var root: f64 = (-half_b - sqrtd) / a;
        if ((root <= ray_tmin) or (root >= ray_tmax)) {
            root = (-half_b + sqrtd) / a;
            if ((root <= ray_tmin) or (root >= ray_tmax)) {
                return false;
            }
        }

        rec.t = root;
        rec.p = ray.at(rec.t);
        const outward_normal: Vec3 = rec.p.sub(self.center).sdiv(self.radius);
        rec.setFaceNormal(ray, outward_normal);

        return true;
    }
};

pub const SphereList = struct {
    objects: ArrayList(Sphere),

    pub fn init(allocator: std.mem.Allocator) SphereList {
        return SphereList{
            .objects = ArrayList(Sphere).init(allocator),
        };
    }

    pub fn deinit(self: SphereList) void {
        self.objects.deinit();
    }

    pub fn clear(self: *SphereList) void {
        self.objects.clearRetainingCapacity();
    }

    pub fn add(self: *SphereList, object: Sphere) !void {
        try self.objects.append(object);
    }

    pub fn hit(self: SphereList, ray: Ray, ray_tmin: f64, ray_tmax: f64, rec: *HitRecord) bool {
        var temp_rec: HitRecord = undefined;
        var hit_anything: bool = false;
        var closest_so_far: f64 = ray_tmax;

        for (self.objects.items) |object| {
            if (object.hit(ray, ray_tmin, closest_so_far, &temp_rec)) {
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec.* = temp_rec;
            }
        }

        return hit_anything;
    }
};
