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

    const challenge3bytes = try challeges.hexToBytes(&allocator, "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736");
    defer allocator.free(challenge3bytes);
    const min = try challeges.maxScore(challenge3bytes, 'A', 'Z');
    const res = try challeges.xor(&allocator, challenge3bytes, min[0]);
    std.debug.print("Challenge 3 '{s}' {c} {d:.3}\n", .{ res, min[0], min[1] });

    // Get the current working directory
    const cwd = std.fs.cwd();
    const file = try cwd.openFile("4.txt", .{});
    defer file.close();

    // Create a buffered reader
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    // Create a buffer for reading lines
    var buf: [1024]u8 = undefined;
    // Read lines
    var maxScore: f32 = 0;
    var charI: u8 = 0;
    var lineI: []const u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const line_bytes = try challeges.hexToBytes(&allocator, line);
        const mm = try challeges.maxScore(line_bytes, 0, 0xfe);
        if (mm[1] > maxScore) {
            maxScore = mm[1];
            charI = mm[0];
            lineI = line_bytes;
        } else {
            allocator.free(line_bytes);
        }
    }
    const candidate = try challeges.xor(&allocator, lineI, charI);
    defer allocator.free(lineI);
    defer allocator.free(candidate);
    std.debug.print("Challenge 4: {s} -- {d} {d:.3} \n", .{ candidate, charI, maxScore });
}
