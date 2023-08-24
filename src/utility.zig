const std = @import("std");

var prng = std.rand.DefaultPrng.init(42);
var random_gen = prng.random();

pub fn random() f64 {
    return random_gen.float(f64);
}

pub fn rangedRandom(min: f64, max: f64) f64 {
    return min + (max - min) * random();
}
