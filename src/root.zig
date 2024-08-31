const std = @import("std");
const byteutil = @import("byteutil.zig");
const testing = std.testing;

test "another test" {
    try testing.expectEqual(byteutil.hamming("this is a test", "wokka wokka!!!"), 37);
}
