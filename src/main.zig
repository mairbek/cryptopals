const std = @import("std");
const challeges = @import("challenges.zig");

pub fn main() !void {
    var allocator = std.heap.page_allocator;

    const challenge1 = try challeges.convertHexToBase64(&allocator, "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d");
    defer allocator.free(challenge1);
    std.debug.print("Challenge 1 {s} \n", .{challenge1});

    const challenge2 = try challeges.fixedXor(&allocator, "1c0111001f010100061a024b53535009181c", "686974207468652062756c6c277320657965");
    defer allocator.free(challenge2);
    std.debug.print("Challenge 2 {s} \n", .{challenge2});
}
