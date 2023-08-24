const std = @import("std");

pub const Interval = struct {
    min: f64,
    max: f64,

    pub fn init(min: f64, max: f64) Interval {
        return Interval{
            .min = min,
            .max = max,
        };
    }

    pub fn contains(self: Interval, x: f64) bool {
        return self.min <= x and x <= self.max;
    }

    pub fn surrounds(self: Interval, x: f64) bool {
        return self.min < x and x < self.max;
    }

    const empty = Interval.init(std.math.inf(f64), -std.math.inf(f64));
    const universe = Interval.init(-std.math.inf(f64), std.math.inf(f64));
};