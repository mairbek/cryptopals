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

fn hexToBytes(allocator: *std.mem.Allocator, hex: []const u8) ![]const u8 {
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

// TODO(mairbek): implement base64 encoding in Zig.
pub fn convertHexToBase64(allocator: *std.mem.Allocator, hex: []const u8) ![]const u8 {
    var buffer: [0x100]u8 = undefined;
    const b = try hexToBytes(allocator, hex);
    defer allocator.free(b);
    const encoded = std.base64.standard.Encoder.encode(&buffer, b);
    return encoded;
}
