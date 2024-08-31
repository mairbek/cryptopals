const std = @import("std");
const byteutil = @import("byteutil.zig");
const english = @import("english.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: {s} <challenge_number>\n", .{args[0]});
        return;
    }

    const challenge_number = std.fmt.parseInt(u32, args[1], 10) catch {
        std.debug.print("Invalid challenge number: {s}\n", .{args[1]});
        return;
    };

    // TODO(mairbek): make this compile time.
    switch (challenge_number) {
        1 => try runChallenge1(allocator),
        2 => try runChallenge2(allocator),
        3 => try runChallenge3(allocator),
        4 => try runChallenge4(allocator),
        5 => try runChallenge5(allocator),
        6 => try runChallenge6(allocator),
        else => std.debug.print("Invalid challenge number: {d}\n", .{challenge_number}),
    }
}

fn runChallenge1(allocator: std.mem.Allocator) !void {
    const challenge1 = try byteutil.convertHexToBase64(allocator, "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d");
    defer allocator.free(challenge1);
    std.debug.print("Challenge 1 {s} \n", .{challenge1});
}

fn runChallenge2(allocator: std.mem.Allocator) !void {
    const challenge2 = try byteutil.fixedXor(allocator, "1c0111001f010100061a024b53535009181c", "686974207468652062756c6c277320657965");
    defer allocator.free(challenge2);
    std.debug.print("Challenge 2 {s} \n", .{challenge2});
}

fn runChallenge3(allocator: std.mem.Allocator) !void {
    const challenge3bytes = try byteutil.hexToBytes(allocator, "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736");
    defer allocator.free(challenge3bytes);
    const min = try english.maxScore(challenge3bytes, 'A', 'Z');
    const res = try byteutil.xor(allocator, challenge3bytes, min[0]);
    std.debug.print("Challenge 3 '{s}' {c} {d:.3}\n", .{ res, min[0], min[1] });
}

fn runChallenge4(allocator: std.mem.Allocator) !void {
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
        const line_bytes = try byteutil.hexToBytes(allocator, line);
        const mm = try english.maxScore(line_bytes, 0, 0xfe);
        if (mm[1] > maxScore) {
            maxScore = mm[1];
            charI = mm[0];
            lineI = line_bytes;
        } else {
            allocator.free(line_bytes);
        }
    }
    const candidate = try byteutil.xor(allocator, lineI, charI);
    defer allocator.free(lineI);
    defer allocator.free(candidate);
    std.debug.print("Challenge 4: {s} -- {d} {d:.3} \n", .{ candidate, charI, maxScore });
}

fn runChallenge5(allocator: std.mem.Allocator) !void {
    const challenge5 = try byteutil.repeatingKeyXor(allocator, "Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal", "ICE");
    defer allocator.free(challenge5);
    const c5print = try byteutil.bytesToHex(allocator, challenge5);
    defer allocator.free(c5print);
    std.debug.print("Challenge 5: {s} \n", .{c5print});
}

fn runChallenge6(allocator: std.mem.Allocator) !void {
    // Get the current working directory
    const cwd = std.fs.cwd();
    const file = try cwd.openFile("6.txt", .{});
    defer file.close();

    // Read the entire file as text
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var arr = std.ArrayList(u8).init(allocator);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const decoded_max_size = line.len / 4 * 3 + 3;
        const decoded = try allocator.alloc(u8, decoded_max_size);
        defer std.heap.page_allocator.free(decoded);

        // Decode the Base64 content
        try std.base64.standard.Decoder.decode(decoded, line);
        try arr.appendSlice(decoded);
    }
    var min_key_size: usize = 0;
    var min_score: f32 = 100000;
    for (2..40) |key_size| {
        const sc: u32 = byteutil.hamming(arr.items[0..key_size], arr.items[key_size .. key_size * 2]);
        const scNorm: f32 = @as(f32, @floatFromInt(sc)) / @as(f32, @floatFromInt(key_size));
        if (scNorm < min_score) {
            min_score = scNorm;
            min_key_size = key_size;
        }
    }
    std.debug.print("key size {d} score {d}\n", .{ min_key_size, min_score });
}
