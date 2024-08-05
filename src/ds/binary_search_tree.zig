const std = @import("std");

pub fn BinarySearchTree(comptime T: type) type {
    return struct {
        nodeNums: u32,
        root: TreeNode,
        allocator: std.mem.Allocator,

        const Self = @This();

        const TreeNode = struct {
            left: ?*TreeNode,
            right: ?*TreeNode,
            value: T,

            pub fn init(value: T) !TreeNode {
                return .{ .left = null, .right = null, .value = value };
            }
        };

        pub fn init(allocator: std.mem.Allocator, value: T) !Self {
            return .{ .nodeNums = 0, .root = try TreeNode.init(value), .allocator = allocator };
        }

        pub fn allocateNode(self: *Self) !*TreeNode {
            return self.allocator.create(TreeNode);
        }

        pub fn destroyNode(self: *Self, node: *TreeNode) !void {
            self.allocator.destroy(node);
        }

        pub fn createNode(self: *Self, value: T) !*TreeNode {
            const node = try self.allocateNode();
            node.* = try TreeNode.init(value);
            return node;
        }

        pub fn insertNode(self: *Self, currentNode: *TreeNode, value: T) !void {
            if (value > currentNode.value) {
                if (currentNode.right == null) {
                    currentNode.right = try self.createNode(value);
                } else {
                    try self.insertNode(currentNode.right.?, value);
                }
            } else {
                if (currentNode.left == null) {
                    currentNode.left = try self.createNode(value);
                } else {
                    try self.insertNode(currentNode.left.?, value);
                }
            }
        }

        fn _inOrder(self: Self, node: ?*TreeNode) void {
            if (node == null) return;
            self._inOrder(node.?.left);
            std.debug.print("{} ", .{node.?.value});
            self._inOrder(node.?.right);
        }

        pub fn inOrder(self: Self, node: ?*TreeNode) void {
            self._inOrder(node);
            std.debug.print("\n", .{});
        }
    };
}

test "Test Binary Search Tree Insertion" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var binarySearchTree = try BinarySearchTree(i32).init(allocator, 0);
    try binarySearchTree.insertNode(&binarySearchTree.root, 2);
    try binarySearchTree.insertNode(&binarySearchTree.root, -1);
    try binarySearchTree.insertNode(&binarySearchTree.root, 3);
    try binarySearchTree.insertNode(&binarySearchTree.root, 4);
    try binarySearchTree.insertNode(&binarySearchTree.root, 6);
    try binarySearchTree.insertNode(&binarySearchTree.root, 2);
    try binarySearchTree.insertNode(&binarySearchTree.root, 3);
    try binarySearchTree.insertNode(&binarySearchTree.root, 4);

    binarySearchTree.inOrder(&binarySearchTree.root);
}
