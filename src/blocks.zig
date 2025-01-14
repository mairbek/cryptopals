const std = @import("std");

pub fn pkcs7pad(allocator: std.mem.Allocator, data: []const u8, block_size: u8) ![]u8 {
    const padding_len = block_size - (data.len % block_size);
    var padded_data = try allocator.alloc(u8, data.len + padding_len);
    @memcpy(padded_data[0..data.len], data);
    @memset(padded_data[data.len..], @intCast(padding_len));
    return padded_data;
}
