const std = @import("std");

fn hexDigitToInt(digit: u8) !u8 {
    if (digit >= '0' and digit <= '9') {
        return digit - '0';
    } else if (digit >= 'a' and digit <= 'f') {
        return digit - 'a' + 10;
    } else if (digit >= 'A' and digit <= 'F') {
        return digit - 'A' + 10;
    } else {
        return error.InvalidHexDigit;
    }
}

pub fn hexToBytes(allocator: *std.mem.Allocator, hex: []const u8) ![]const u8 {
    const len = hex.len;
    if (len % 2 != 0) {
        return error.InvalidHexLength;
    }
    var rawBytes = try allocator.alloc(u8, len / 2);
    var i: usize = 0;
    while (i < len) : (i += 2) {
        const highNibble = try hexDigitToInt(hex[i]);
        const lowNibble = try hexDigitToInt(hex[i + 1]);
        rawBytes[i / 2] = (highNibble << 4) | lowNibble;
    }
    return rawBytes;
}

pub fn xor(allocator: *std.mem.Allocator, bytes: []const u8, ch: u8) ![]const u8 {
    var result = try allocator.alloc(u8, bytes.len);
    var i: usize = 0;
    while (i < bytes.len) : (i += 1) {
        result[i] = bytes[i] ^ ch;
    }
    return result;
}

// TODO(mairbek): implement base64 encoding in Zig.
pub fn convertHexToBase64(allocator: *std.mem.Allocator, hex: []const u8) ![]const u8 {
    const b = try hexToBytes(allocator, hex);
    defer allocator.free(b);
    const len = std.base64.standard.Encoder.calcSize(b.len);
    const buffer = try allocator.alloc(u8, len);
    const encoded = std.base64.standard.Encoder.encode(buffer, b);
    return encoded;
}

fn byteToHex(byte: u8) []const u8 {
    const hex_chars = "0123456789abcdef";
    return &[_]u8{ hex_chars[byte >> 4], hex_chars[byte & 0x0F] };
}

fn bytesToHex(allocator: *std.mem.Allocator, bytes: []const u8) ![]u8 {
    var hexString = try allocator.alloc(u8, bytes.len * 2);

    for (0.., bytes) |idx, byte| {
        const hex = byteToHex(byte);
        hexString[idx * 2] = hex[0];
        hexString[idx * 2 + 1] = hex[1];
    }

    return hexString;
}

pub fn fixedXor(allocator: *std.mem.Allocator, a: []const u8, b: []const u8) ![]const u8 {
    if (a.len != b.len) {
        return error.InvalidXorLength;
    }
    const ba = try hexToBytes(allocator, a);
    defer allocator.free(ba);
    const bb = try hexToBytes(allocator, b);
    defer allocator.free(bb);
    const result = try allocator.alloc(u8, ba.len);
    defer allocator.free(result);
    for (0.., ba, bb) |i, ai, bi| {
        result[i] = ai ^ bi;
    }
    const hex = try bytesToHex(allocator, result);
    return hex;
}

pub fn computeDistribution(bytes: []const u8) f32 {
    var result: [27]u8 = [_]u8{0} ** 27;
    var sum: u8 = 0;
    for (bytes) |byte| {
        if (byte >= 'a' and byte <= 'z') {
            result[byte - 'a'] += 1;
        } else if (byte >= 'A' and byte <= 'Z') {
            result[byte - 'A'] += 1;
        } else {
            result[26] += 1;
        }
        sum += 1;
    }
    const letterDistribution: [27]f32 = [_]f32{
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
        0.0, // other
    };

    var norm: [27]f32 = [_]f32{0.0} ** 27;
    var score: f32 = 0.0;
    for (0..27) |i| {
        norm[i] = @as(f32, @floatFromInt(result[i])) / @as(f32, @floatFromInt(sum));
        // std.debug.print("Norm {d:.3} / {d:.3} = {d:.3} \n", .{ @as(f32, @floatFromInt(result[i])), @as(f32, @floatFromInt(sum)), norm[i] });
        const err: f32 = norm[i] - (letterDistribution[i] / 100.0);
        score += (err * err);
        // std.debug.print("{any} Score: {d:.3} err {d:.3}' \n", .{ i, score, err });
    }
    return score;
}
