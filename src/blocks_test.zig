const std = @import("std");
const pkcs7pad = @import("blocks.zig").pkcs7pad;

test "pkcs7pad pads correctly with block size 20" {
    var allocator = std.testing.allocator;
    const data = "YELLOW SUBMARINE";
    const block_size: u8 = 20;
    const expected = "YELLOW SUBMARINE\x04\x04\x04\x04";

    const padded_data = try pkcs7pad(allocator, data, block_size);
    defer allocator.free(padded_data);

    try std.testing.expectEqualStrings(expected, padded_data);
}

test "pkcs7pad pads correctly with block size 16" {
    var allocator = std.testing.allocator;
    const data = "YELLOW SUBMARINE";
    const block_size: u8 = 16;
    const expected = "YELLOW SUBMARINE\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10";

    const padded_data = try pkcs7pad(allocator, data, block_size);
    defer allocator.free(padded_data);

    try std.testing.expectEqualStrings(expected, padded_data);
}

test "pkcs7pad pads correctly with block size 8" {
    var allocator = std.testing.allocator;
    const data = "YELLOW SUBMARINE";
    const block_size: u8 = 8;
    const expected = "YELLOW SUBMARINE\x08\x08\x08\x08\x08\x08\x08\x08";

    const padded_data = try pkcs7pad(allocator, data, block_size);
    defer allocator.free(padded_data);

    try std.testing.expectEqualStrings(expected, padded_data);
}
