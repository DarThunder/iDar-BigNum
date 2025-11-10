local B = {}
local mt = { __index = B }
local BASE = 256

local function zero_digits()
    return {0}
end

local function normalize(digits)
    local n = #digits
    while n > 1 and digits[n] == 0 do
        digits[n] = nil
        n = n - 1
    end
    return digits
end

local function is_zero(digits)
    return #digits == 1 and digits[1] == 0
end

local function compare_abs(a_digits, b_digits)
    if #a_digits > #b_digits then return 1 end
    if #a_digits < #b_digits then return -1 end
    for i = #a_digits, 1, -1 do
        if (a_digits[i] or 0) > (b_digits[i] or 0) then return 1 end
        if (a_digits[i] or 0) < (b_digits[i] or 0) then return -1 end
    end
    return 0
end

local function add_abs(a_digits, b_digits)
    local carry = 0
    local result = {}
    local maxLen = math.max(#a_digits, #b_digits)
    for i = 1, maxLen do
        local sum = (a_digits[i] or 0) + (b_digits[i] or 0) + carry
        result[i] = sum % BASE
        carry = math.floor(sum / BASE)
    end
    if carry > 0 then
        result[maxLen + 1] = carry
    end
    return result
end

local function sub_abs(a_digits, b_digits)
    local borrow = 0
    local result = {}
    local maxLen = #a_digits
    for i = 1, maxLen do
        local diff = (a_digits[i] or 0) - (b_digits[i] or 0) - borrow
        if diff < 0 then
            diff = diff + BASE
            borrow = 1
        else
            borrow = 0
        end
        result[i] = diff
    end
    return normalize(result)
end

local function mul_abs(a_digits, b_digits)
    if is_zero(a_digits) or is_zero(b_digits) then return zero_digits() end
    
    local result = {}
    for i = 1, #a_digits do
        local carry = 0
        for j = 1, #b_digits do
            local k = i + j - 1
            local prod = (a_digits[i] * b_digits[j]) + (result[k] or 0) + carry
            result[k] = prod % BASE
            carry = math.floor(prod / BASE)
        end
        result[i + #b_digits] = carry
    end
    return normalize(result)
end

local function lshift_bytes(digits, n)
    if n <= 0 or is_zero(digits) then return digits end
    local result = {}
    for i = 1, n do
        result[i] = 0
    end
    for i = 1, #digits do
        result[i + n] = digits[i]
    end
    return normalize(result)
end


local function mul_by_small(digits, n)
    local carry = 0
    local result = {}
    for i = 1, #digits do
        local prod = (digits[i] * n) + carry
        result[i] = prod % BASE
        carry = math.floor(prod / BASE)
    end
    while carry > 0 do
        table.insert(result, carry % BASE)
        carry = math.floor(carry / BASE)
    end
    return result
end

local function add_small(digits, n)
    local result = {}
    local sum = digits[1] + n
    result[1] = sum % BASE
    local carry = math.floor(sum / BASE)

    local i = 2
    while i <= #digits or carry > 0 do
        sum = (digits[i] or 0) + carry
        result[i] = sum % BASE
        carry = math.floor(sum / BASE)
        i = i + 1
    end
    return result
end

local function divmod_by_small(digits, n)
    local remainder = 0
    local quotient = {}

    for i = #digits, 1, -1 do
        local value = digits[i] + remainder * BASE
        local q = math.floor(value / n)
        quotient[i] = q
        remainder = value % n
    end

    return normalize(quotient), remainder
end

local function divmod_abs(a_digits, b_digits)
    if is_zero(b_digits) then error("Division by zero", 2) end
    if compare_abs(a_digits, b_digits) < 0 then
        return zero_digits(), normalize({table.unpack(a_digits)})
    end

    local n, m = #a_digits, #b_digits
    local quotient = {}
    local remainder = {}

    for i = 1, n do remainder[i] = a_digits[i] end

    local norm = math.floor(BASE / (b_digits[m] + 1))
    if norm > 1 then
        remainder = mul_by_small(remainder, norm)
        b_digits = mul_by_small(b_digits, norm)
    end

    n = #remainder
    m = #b_digits

    for i = n - m, 0, -1 do
        local r_hi = remainder[i + m + 1] or 0
        local r_lo = remainder[i + m] or 0
        local num = r_hi * BASE + r_lo
        local den = b_digits[m]
        local q_hat = math.floor(num / den)

        if q_hat >= BASE then q_hat = BASE - 1 end

        local prod = mul_by_small(b_digits, q_hat)
        prod = lshift_bytes(prod, i)

        while q_hat > 0 and compare_abs(remainder, prod) < 0 do
            q_hat = q_hat - 1
            prod = mul_by_small(b_digits, q_hat)
            prod = lshift_bytes(prod, i)
        end

        remainder = sub_abs(remainder, prod)
        quotient[i + 1] = q_hat
    end

    if norm > 1 then
        remainder, _ = divmod_by_small(remainder, norm)
    end

    return normalize(quotient), normalize(remainder)
end

local function fromString(str)
    local digits = zero_digits()
    for i = 1, #str do
        local digit_val = str:byte(i) - 48 -- '0' es 48
        if digit_val < 0 or digit_val > 9 then
            error("Invalid number string: " .. str, 2)
        end
        digits = mul_by_small(digits, 10)
        digits = add_small(digits, digit_val)
    end
    return digits
end

local function toString(digits, sign)
    if is_zero(digits) then return "0" end
    
    local s = {}
    local temp_digits = digits
    
    while not is_zero(temp_digits) do
        local remainder
        temp_digits, remainder = divmod_by_small(temp_digits, 10)
        table.insert(s, 1, string.char(remainder + 48)) -- '0' es 48
    end
    
    local prefix = (sign < 0) and "-" or ""
    return prefix .. table.concat(s)
end

function B.new(n)
    if type(n) == "table" and getmetatable(n) == mt then
        return n
    end

    local obj = {
        sign = 1,
        digits = zero_digits()
    }
    setmetatable(obj, mt)

    local n_type = type(n)
    if n_type == "string" then
        if n:sub(1,1) == "-" then
            obj.sign = -1
            n = n:sub(2)
        end
        obj.digits = fromString(n)
        if is_zero(obj.digits) then obj.sign = 1 end
    elseif n_type == "number" then
        if n < 0 then
            obj.sign = -1
            n = -n
        end
        local d = {}
        local i = 1
        while n > 0 do
            d[i] = n % BASE
            n = math.floor(n / BASE)
            i = i + 1
        end
        obj.digits = #d > 0 and d or zero_digits()
    else
        error("Cannot create bignum from type: " .. n_type, 2)
    end

    return obj
end

function B.fromBinary(binaryString)
    local obj = {
        sign = 1,
        digits = {0}
    }
    setmetatable(obj, mt)

    local temp_digits = {0}

    for i = 1, #binaryString do
        local bit_val = binaryString:byte(i) - 48

        temp_digits = mul_by_small(temp_digits, 2)

        if bit_val == 1 then
            temp_digits = add_small(temp_digits, 1)
        elseif bit_val ~= 0 then
            error("Invalid binary string: " .. binaryString, 2)
        end
    end

    obj.digits = temp_digits
    if is_zero(obj.digits) then obj.sign = 1 end
    return obj
end

function B.fromBytes(str)
    local obj = { sign = 1, digits = {} }
    setmetatable(obj, mt)
    if str == nil or #str == 0 then
        obj.digits = zero_digits()
        return obj
    end

    for i = 1, #str do
        obj.digits[i] = str:byte(i)
    end

    obj.digits = normalize(obj.digits)
    return obj
end

function B:toBytes()
    if is_zero(self.digits) then return "" end

    local chars = {}
    for i = 1, #self.digits do
        chars[i] = string.char(self.digits[i])
    end
    return table.concat(chars)
end

function B:toString()
    return toString(self.digits, self.sign)
end

function B:clone()
    local c = { sign = self.sign, digits = {} }
    for i = 1, #self.digits do
        c.digits[i] = self.digits[i]
    end
    setmetatable(c, mt)
    return c
end

function B:raw_negate()
    local c = self:clone()
    if not is_zero(c.digits) then
        c.sign = -c.sign
    end
    return c
end

function B:raw_abs()
    local c = self:clone()
    c.sign = 1
    return c
end

function B:bitLength()
    if is_zero(self.digits) then return 0 end

    local last_digit = self.digits[#self.digits]
    local bits_in_last = 0

    while last_digit > 0 do
        last_digit = math.floor(last_digit / 2)
        bits_in_last = bits_in_last + 1
    end

    return (#self.digits - 1) * 8 + bits_in_last
end

function B:add(other)
    local a, b = self, B.new(other)
    local result = { sign = 1, digits = zero_digits() }
    setmetatable(result, mt)

    if a.sign == b.sign then
        result.digits = add_abs(a.digits, b.digits)
        result.sign = a.sign
    else
        local cmp = compare_abs(a.digits, b.digits)
        if cmp >= 0 then
            result.digits = sub_abs(a.digits, b.digits)
            result.sign = a.sign
        else
            result.digits = sub_abs(b.digits, a.digits)
            result.sign = b.sign
        end
    end

    if is_zero(result.digits) then result.sign = 1 end
    return result
end

function B:sub(other)
    local b_neg = B.new(other):raw_negate()
    return self:add(b_neg)
end

function B:mul(other)
    local a, b = self, B.new(other)
    local result = { sign = 1, digits = zero_digits() }
    setmetatable(result, mt)

    result.digits = mul_abs(a.digits, b.digits)
    result.sign = a.sign * b.sign

    if is_zero(result.digits) then result.sign = 1 end
    return result
end

function B:divmod(other)
    local a, b = self, B.new(other)
    local q = { sign = 1, digits = zero_digits() }
    local r = { sign = 1, digits = zero_digits() }
    setmetatable(q, mt); setmetatable(r, mt)

    q.digits, r.digits = divmod_abs(a.digits, b.digits)
    q.sign = a.sign * b.sign
    r.sign = a.sign

    if is_zero(q.digits) then q.sign = 1 end
    if is_zero(r.digits) then r.sign = 1 end
    return q, r
end

function B:div(other)
    local q, r = self:divmod(B.new(other))
    return q
end

function B:mod(other)
    local b_obj = B.new(other)
    local _, r = self:divmod(b_obj)

    if r.sign < 0 then
        r = r + b_obj
    end

    return r
end

function B:pow(exp)
    local base = self:clone()
    local exp_obj = B.new(exp)
    local result = B.new(1)
    
    if exp_obj.sign < 0 then
        if self:toString() == "1" then return B.new(1) end
        if self:toString() == "-1" then return exp_obj:mod(2):toString() == "0" and B.new(1) or B.new(-1) end
        return B.new(0)
    end
    
    local ZERO = B.new(0)
    local ONE = B.new(1)
    local TWO = B.new(2)

    while exp_obj > ZERO do
        if (exp_obj % TWO) == ONE then
            result = result * base
        end
        exp_obj = exp_obj / TWO
        base = base * base
    end
    return result
end

function B:sqrt()
    local ZERO = B.new(0)
    local ONE = B.new(1)
    local TWO = B.new(2)
    local n = self

    if n < ZERO then error("Square root of negative number", 2) end
    if n == ZERO then return ZERO end

    local num_bits = n:bitLength()
    local x = ONE:lshift(math.ceil(num_bits / 2))

    local prev_x
    local iterations = 0

    repeat
        prev_x = x
        x = (x + (n / x)) / TWO
        iterations = iterations + 1
        os.sleep(0)
    until x >= prev_x
    return prev_x
end

function B:modExp(exp, mod)
    local base = self:clone()
    local exp_obj = B.new(exp)
    local mod_obj = B.new(mod)

    local result = B.new(1)
    base = base % mod_obj

    local ZERO = B.new(0)
    local ONE = B.new(1)
    local TWO = B.new(2)

    while exp_obj > ZERO do
        os.sleep(0)

        if (exp_obj % TWO) == ONE then
            result = (result * base) % mod_obj
        end
        exp_obj = exp_obj / TWO
        base = (base * base) % mod_obj
    end

    if result.sign < 0 then
        result = result + mod_obj
    end
    return result
end

function B:band(other)
    local a, b = self.digits, B.new(other).digits
    local result = {}
    local maxLen = math.max(#a, #b)
    for i = 1, maxLen do
        result[i] = bit.band(a[i] or 0, b[i] or 0)
    end
    local obj = { sign = 1, digits = normalize(result) }
    setmetatable(obj, mt)
    return obj
end

function B:bor(other)
    local a, b = self.digits, B.new(other).digits
    local result = {}
    local maxLen = math.max(#a, #b)
    for i = 1, maxLen do
        result[i] = bit.bor(a[i] or 0, b[i] or 0)
    end
    local obj = { sign = 1, digits = normalize(result) }
    setmetatable(obj, mt)
    return obj
end

function B:bxor(other)
    local a, b = self.digits, B.new(other).digits
    local result = {}
    local maxLen = math.max(#a, #b)
    for i = 1, maxLen do
        result[i] = bit.bxor(a[i] or 0, b[i] or 0)
    end
    local obj = { sign = 1, digits = normalize(result) }
    setmetatable(obj, mt)
    return obj
end

function B:rshift(n)
    local n_bytes = math.floor(n / 8)
    local n_bits = n % 8

    local digits = self.digits
    local result = {}

    if n_bytes > 0 then
        for i = 1, #digits - n_bytes do
            result[i] = digits[i + n_bytes]
        end
        if #result == 0 then return B.new(0) end
    else
        result = self.digits
    end

    if n_bits > 0 then
        local rmask = bit.blshift(1, n_bits) - 1
        local lmask = BASE - 1 - rmask

        local new_digits = {}
        for i = 1, #result do
            local low = bit.band(result[i], rmask)
            local high = bit.brshift(bit.band(result[i], lmask), n_bits)

            new_digits[i] = (new_digits[i] or 0) + high
            if i > 1 then
                new_digits[i-1] = new_digits[i-1] + bit.blshift(low, 8 - n_bits)
            end
        end
        result = new_digits
    end

    local obj = { sign = 1, digits = normalize(result) }
    setmetatable(obj, mt)
    return obj
end

function B:lshift(n)
    local n_bytes = math.floor(n / 8)
    local n_bits = n % 8

    local digits = self.digits
    local result = {}

    if n_bytes > 0 then
        result = lshift_bytes(digits, n_bytes)
    else
        result = self.digits
    end

    if n_bits > 0 then
        local rmask = bit.blshift(1, 8 - n_bits) - 1
        local lmask = BASE - 1 - rmask

        local carry = 0
        local new_digits = {}
        for i = 1, #result do
            local low = bit.blshift(bit.band(result[i], rmask), n_bits)
            local high = bit.brshift(bit.band(result[i], lmask), 8 - n_bits)

            new_digits[i] = low + carry
            carry = high
        end
        if carry > 0 then
            table.insert(new_digits, carry)
        end
        result = new_digits
    end

    local obj = { sign = 1, digits = normalize(result) }
    setmetatable(obj, mt)
    return obj
end

mt.__add = function(a, b) return B.new(a):add(B.new(b)) end
mt.__sub = function(a, b) return B.new(a):sub(B.new(b)) end
mt.__mul = function(a, b) return B.new(a):mul(B.new(b)) end
mt.__div = function(a, b) return B.new(a):div(B.new(b)) end
mt.__mod = function(a, b) return B.new(a):mod(B.new(b)) end
mt.__pow = function(a, b) return B.new(a):pow(B.new(b)) end
mt.__unm = function(a) return B.new(a):raw_negate() end
mt.__tostring = function(a) return a:toString() end

mt.__eq = function(a, b)
    local a_obj, b_obj = B.new(a), B.new(b)
    if a_obj.sign ~= b_obj.sign then return false end
    return compare_abs(a_obj.digits, b_obj.digits) == 0
end

mt.__lt = function(a, b)
    local a_obj, b_obj = B.new(a), B.new(b)
    if a_obj.sign ~= b_obj.sign then
        return a_obj.sign < b_obj.sign
    end
    if a_obj.sign > 0 then
        return compare_abs(a_obj.digits, b_obj.digits) < 0
    else
        return compare_abs(a_obj.digits, b_obj.digits) > 0
    end
end

mt.__le = function(a, b)
    local a_obj, b_obj = B.new(a), B.new(b)
    if a_obj.sign ~= b_obj.sign then
        return a_obj.sign < b_obj.sign
    end
    if a_obj.sign > 0 then
        return compare_abs(a_obj.digits, b_obj.digits) <= 0
    else
        return compare_abs(a_obj.digits, b_obj.digits) >= 0
    end
end

return function(n)
    return B.new(n)
end