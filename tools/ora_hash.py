def ora_hash(data, max_bucket=0xffffffff, seed=0):
    if not data:
        return
    def uint32(n):
        return n & 0xffffffff
    def int_from_bytes(data):
        return int.from_bytes(data, 'little')
    def mix(data, final=False):
        nonlocal a, b, c, seed
        s7 = int_from_bytes(data[12:16])
        if final:
            s7 = uint32(s7 << 8)
        s0 = uint32(a + int_from_bytes(data[0:4]) + s7 + seed)
        if final:
            s0 = uint32(s0 + len_)
        s1 = s0 ^ s0>>7
        s2 = uint32(b + int_from_bytes(data[4:8]) + s1)
        s3 = uint32(s2 ^ s2<<0xd)
        s4 = uint32(c + int_from_bytes(data[8:12]) + s3)
        s5 = s4 ^ s4>>0x11
        s0 = uint32(s0 + s5 + s7 + seed)
        if final:
            s0 = uint32(s0 + len_)
        s6 = uint32(s0 ^ s0<<9)
        s1 = uint32(s1 + s2 + s6)
        s2 = s1 ^ s1>>3
        s3 = uint32(s2 + s3 + s4)
        a = uint32(s2 + s3)
        s3 = uint32(s3 ^ s3<<7)
        s0 = uint32(s0 + s3 + s5)
        b = uint32(s0 + s3)
        s0 = uint32(s0 ^ s0>>0xf)
        s1 = uint32(s0 + s1 + s6)
        c = uint32(s0 + s1)
        seed = uint32(s1 ^ s1<<0xb)
    a = b = c = 0x9e3779b9
    len_ = len(data)
    while len(data) >= 16:
        mix(data)
        data = data[16:]
    mix(data, final=True)
    return seed % (max_bucket + 1)
