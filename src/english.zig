const std = @import("std");
const byteutil = @import("byteutil.zig");

pub fn scoreText(bytes: []const u8) f32 {
    const letterDistribution: [26]f32 = [_]f32{
        8.167, // a
        1.492, // b
        2.782, // c
        4.253, // d
        12.702, // e
        2.228, // f
        2.015, // g
        6.094, // h
        6.966, // i
        0.153, // j
        0.772, // k
        4.025, // l
        2.406, // m
        6.749, // n
        7.507, // o
        1.929, // p
        0.095, // q
        5.987, // r
        6.327, // s
        9.056, // t
        2.758, // u
        0.978, // v
        2.360, // w
        0.150, // x
        1.974, // y
        0.074, // z
    };
    var result: f32 = 0;
    for (bytes) |b| {
        if (b >= 'a' and b <= 'z') {
            result += letterDistribution[b - 'a'];
        } else if (b >= 'A' and b <= 'Z') {
            result += letterDistribution[b - 'A'];
        } else if (b == ' ') {
            result += 20.0;
        }
    }
    return result;
}

pub fn maxScore(bytes: []const u8, from: u8, to: u8) !struct { u8, f32 } {
    const allocator = std.heap.page_allocator;

    var maxS: f32 = 0;
    var maxI: u8 = 0;
    var i: u8 = from;
    while (i <= to) : (i += 1) {
        const candidate = try byteutil.xor(allocator, bytes, i);
        const score = scoreText(candidate);
        if (score > maxS) {
            maxS = score;
            maxI = i;
        }
    }
    return .{ maxI, maxS };
}
