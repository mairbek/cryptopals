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

    var i: u8 = 0;
    const challenge3bytes = try challeges.hexToBytes(&allocator, "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736");
    var minScore: f32 = 100.0;
    var minChar: u8 = 'A';
    while (i < 26) {
        const ch: u8 = 'A' + i;

        const candidate = try challeges.xor(&allocator, challenge3bytes, ch);
        defer allocator.free(candidate);

        const score: f32 = challeges.computeDistribution(candidate);
        if (score < minScore) {
            minScore = score;
            minChar = ch;
        }
        i += 1;
    }
    std.debug.print("Challenge 3 {c} \n", .{minChar});
}
