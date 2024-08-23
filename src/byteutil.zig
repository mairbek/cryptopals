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

pub fn hexToBytes(allocator: std.mem.Allocator, hex: []const u8) ![]const u8 {
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

pub fn xor(allocator: std.mem.Allocator, bytes: []const u8, ch: u8) ![]const u8 {
    var result = try allocator.alloc(u8, bytes.len);
    var i: usize = 0;
    while (i < bytes.len) : (i += 1) {
        result[i] = bytes[i] ^ ch;
    }
    return result;
}

// TODO(mairbek): implement base64 encoding in Zig.
pub fn convertHexToBase64(allocator: std.mem.Allocator, hex: []const u8) ![]const u8 {
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

pub fn bytesToHex(allocator: std.mem.Allocator, bytes: []const u8) ![]u8 {
    var hexString = try allocator.alloc(u8, bytes.len * 2);
    for (0.., bytes) |idx, byte| {
        const hex = byteToHex(byte);
        hexString[idx * 2] = hex[0];
        hexString[idx * 2 + 1] = hex[1];
    }
    return hexString;
}

pub fn fixedXor(allocator: std.mem.Allocator, a: []const u8, b: []const u8) ![]const u8 {
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

pub fn repeatingKeyXor(allocator: std.mem.Allocator, plaintext: []const u8, key: []const u8) ![]u8 {
    var result: []u8 = try allocator.alloc(u8, plaintext.len);

    var k: usize = 0;
    var i: usize = 0;
    while (i < plaintext.len) : (i += 1) {
        result[i] = plaintext[i] ^ key[k];
        k = (k + 1) % key.len;
    }
    return result;
}
