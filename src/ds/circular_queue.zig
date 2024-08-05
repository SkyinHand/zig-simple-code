const std = @import("std");

pub fn CircularQueue(comptime T: type) type {
    return struct {
        front: usize,
        rear: usize,
        capacity: usize,
        items: []T,
        allocator: std.mem.Allocator,

        const Self = @This();

        pub const CircularQueueError = error{ QueueEmpty, QueueFull };

        pub fn init(allocator: std.mem.Allocator, capacity: usize) !Self {
            return .{ .front = 0, .rear = 0, .capacity = capacity + 1, .items = try allocator.alloc(T, capacity + 1), .allocator = allocator };
        }

        pub fn deinit(self: Self) void {
            self.allocator.free(self.items);
        }

        pub fn isEmpty(self: Self) bool {
            return self.front == self.rear;
        }

        pub fn isFull(self: Self) bool {
            return (self.rear + 1) % self.capacity == self.front;
        }

        pub fn push(self: *Self, value: T) !void {
            if (self.isFull()) {
                return CircularQueueError.QueueFull;
            }

            self.items[self.rear] = value;
            self.rear = (self.rear + 1) % self.capacity;
        }

        pub fn pop(self: *Self) !T {
            if (self.isEmpty()) {
                return CircularQueueError.QueueEmpty;
            }
            const ret = self.items[self.front];
            self.front = (self.front + 1) % self.capacity;
            return ret;
        }
    };
}

test "Test Circular Queue" {
    const allocator = std.testing.allocator;

    var queue = try CircularQueue(i32).init(allocator, 3);
    defer queue.deinit();

    try queue.push(1);
    try queue.push(2);
    try queue.push(3);

    try std.testing.expectEqual(try queue.pop(), 1);
    try std.testing.expectEqual(try queue.pop(), 2);

    try queue.push(4);
    try queue.push(5);

    try std.testing.expectEqual(try queue.pop(), 3);
    try std.testing.expectEqual(try queue.pop(), 4);
    try std.testing.expectEqual(try queue.pop(), 5);
}
