const TypeId = *const u8;

pub inline fn typeId(comptime T: type) TypeId {
    return &struct {
        comptime {
            _ = T;
        }
        var id: u8 = 0;
    }.id;
}
