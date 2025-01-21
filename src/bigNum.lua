local bigNum = {}

function bigNum.compare(a, b)
    a = a:gsub("^0+", "")
    b = b:gsub("^0+", "")

    if a == "" and b == "" then
        return 0
    end

    if a == "" then
        return -1
    elseif b == "" then
        return 1
    end

    if #a > #b then
        return 1
    elseif #a < #b then
        return -1
    end

    for i = 1, #a do
        local digitA = tonumber(a:sub(i, i))
        local digitB = tonumber(b:sub(i, i))
        if digitA > digitB then
            return 1
        elseif digitA < digitB then
            return -1
        end
    end

    return 0
end

function bigNum.add(a, b)
    local negative = false
    if a:sub(1, 1) == "-" and b:sub(1, 1) ~= "-" then
        negative = true
        a = a:sub(2)
    elseif b:sub(1, 1) == "-" and a:sub(1, 1) ~= "-" then
        negative = true
        b = b:sub(2)
    elseif a:sub(1, 1) == "-" and b:sub(1, 1) == "-" then
        a = a:sub(2)
        b = b:sub(2)
    end

    if negative then
        return "-" .. bigNum.add(a, b)
    end

    local carry = 0
    local result = {}
    a, b = a:reverse(), b:reverse()

    local maxLength = math.max(#a, #b)
    for i = 1, maxLength do
        local digitA = tonumber(a:sub(i, i)) or 0
        local digitB = tonumber(b:sub(i, i)) or 0
        local sum = digitA + digitB + carry
        carry = math.floor(sum / 10)
        table.insert(result, sum % 10)
    end

    if carry > 0 then
        table.insert(result, carry)
    end

    return table.concat(result):reverse()
end

function bigNum.sub(a, b)
    local aNegative = a:sub(1, 1) == "-"
    local bNegative = b:sub(1, 1) == "-"

    if aNegative then a = a:sub(2) end
    if bNegative then b = b:sub(2) end

    if aNegative ~= bNegative then
        if aNegative then
            return "-" .. bigNum.add(a, b)
        else
            return bigNum.add(a, b)
        end
    end

    local negative = false
    if aNegative and bNegative then
        a, b = b, a
    elseif #a < #b or (#a == #b and a < b) then
        negative = true
        a, b = b, a
    end

    local borrow = 0
    local result = {}
    a, b = a:reverse(), b:reverse()

    while #b < #a do
        b = b .. "0"
    end

    for i = 1, #a do
        local digitA = tonumber(a:sub(i, i)) or 0
        local digitB = tonumber(b:sub(i, i)) or 0
        local diff = digitA - digitB - borrow

        if diff < 0 then
            diff = diff + 10
            borrow = 1
        else
            borrow = 0
        end

        table.insert(result, diff)
    end

    while #result > 1 and result[#result] == 0 do
        table.remove(result)
    end

    local subNum = table.concat(result):reverse()
    if negative then subNum = "-" .. subNum end
    return subNum
end

function bigNum.mul(a, b)
    local aNegative = a:sub(1, 1) == "-"
    local bNegative = b:sub(1, 1) == "-"

    if aNegative then a = a:sub(2) end
    if bNegative then b = b:sub(2) end

    local result = "0"
    a, b = a:reverse(), b:reverse()

    for i = 1, #b do
        local digitB = tonumber(b:sub(i, i))
        local carry = 0
        local temp = {}

        for _ = 1, i - 1 do
            table.insert(temp, 0)
        end

        for j = 1, #a do
            local digitA = tonumber(a:sub(j, j))
            local prod = digitA * digitB + carry
            carry = math.floor(prod / 10)
            table.insert(temp, prod % 10)
        end

        if carry > 0 then
            table.insert(temp, carry)
        end

        result = bigNum.add(result, table.concat(temp):reverse())
    end

    if aNegative ~= bNegative and result ~= "0" then
        result = "-" .. result
    end

    return result
end

function bigNum.div(a, b)
    assert(b ~= "0", "Division by zero is not allowed")

    local negative = false
    if a:sub(1, 1) == "-" and b:sub(1, 1) ~= "-" then
        negative = true
        a = a:sub(2)
    elseif b:sub(1, 1) == "-" and a:sub(1, 1) ~= "-" then
        negative = true
        b = b:sub(2)
    elseif a:sub(1, 1) == "-" and b:sub(1, 1) == "-" then
        a = a:sub(2)
        b = b:sub(2)
    end

    local quotient = ""
    local remainder = "0"

    for i = 1, #a do
        local digit = a:sub(i, i)
        remainder = bigNum.add(bigNum.mul(remainder, "10"), digit)

        local count = "0"
        while bigNum.compare(remainder, b) >= 0 do
            remainder = bigNum.sub(remainder, b)
            count = bigNum.add(count, "1")
        end

        quotient = quotient .. count
    end

    quotient = quotient:gsub("^0+", "")
    quotient = (quotient == "" and "0" or quotient)

    if negative and quotient ~= "0" then
        quotient = "-" .. quotient
    end

    return quotient
end

function bigNum.mod(a, m)
    local current = "0"

    for i = 1, #a do
        current = bigNum.add(bigNum.mul(current, "10"), a:sub(i, i))

        while bigNum.compare(current, m) >= 0 do
            current = bigNum.sub(current, m)
        end
    end

    current = current:gsub("^0+", "")
    return current == "" and "0" or current
end

function bigNum.modExp(base, exp, mod)
    local result = "1"
    base = bigNum.mod(base, mod)

    while exp ~= "0" do
        if bigNum.mod(exp, "2") == "1" then
            result = bigNum.mod(bigNum.mul(result, base), mod)
        end
        exp = bigNum.div(exp, "2")
        base = bigNum.mod(bigNum.mul(base, base), mod)
    end

    return result
end

function bigNum.fastExp(base, exp)
    local result = "1"
    while exp ~= "0" do
        if tonumber(exp:sub(-1)) % 2 == 1 then
            result = bigNum.mul(result, base)
        end
        exp = bigNum.div(exp, "2")
        base = bigNum.mul(base, base)
    end
    return result
end

function bigNum.toBinary(num)
    local binary = {}

    while bigNum.compare(num, "0") > 0 do
        local remainder = bigNum.mod(num, "2")

        table.insert(binary, 1, remainder)

        num = bigNum.div(num, "2")
    end

    if #binary == 0 then
        return "0"
    end

    return table.concat(binary)
end

function bigNum.fromBinary(binary)
    local result = "0"
    for i = 1, #binary do
        local bit = binary:sub(i, i)
        result = bigNum.add(bigNum.mul(result, "2"), bit)
    end
    return result
end

function bigNum.and_bitwise(a, b)
    if a == b then return a end
    local binA = bigNum.toBinary(a)
    local binB = bigNum.toBinary(b)
    local maxLength = math.max(#binA, #binB)

    binA = string.rep("0", maxLength - #binA) .. binA
    binB = string.rep("0", maxLength - #binB) .. binB

    local result = {}
    for i = 1, maxLength do
        local bitA = binA:sub(i, i)
        local bitB = binB:sub(i, i)
        table.insert(result, (bitA == "1" and bitB == "1") and "1" or "0")
    end
    return bigNum.fromBinary(table.concat(result))
end

function bigNum.or_bitwise(a, b)
    if a == b then return a end
    local binA = bigNum.toBinary(a)
    local binB = bigNum.toBinary(b)
    local maxLength = math.max(#binA, #binB)

    binA = string.rep("0", maxLength - #binA) .. binA
    binB = string.rep("0", maxLength - #binB) .. binB

    local result = {}
    for i = 1, maxLength do
        local bitA = binA:sub(i, i)
        local bitB = binB:sub(i, i)
        table.insert(result, (bitA == "1" or bitB == "1") and "1" or "0")
    end
    return bigNum.fromBinary(table.concat(result))
end

function bigNum.xor_bitwise(a, b)
    if a == b then return "0" end
    local binA = bigNum.toBinary(a)
    local binB = bigNum.toBinary(b)
    local maxLength = math.max(#binA, #binB)

    binA = binA:rep(maxLength - #binA) .. binA
    binB = binB:rep(maxLength - #binB) .. binB

    local result = {}
    for i = 1, maxLength do
        local bitA = binA:sub(i, i)
        local bitB = binB:sub(i, i)
        table.insert(result, (bitA ~= bitB) and "1" or "0")
    end
    return bigNum.fromBinary(table.concat(result))
end

function bigNum.rshift_bitwise(a, shift)
    local binA = bigNum.toBinary(a)
    binA = binA:sub(1, #binA - shift)
    return bigNum.fromBinary(binA)
end

function bigNum.lshift_bitwise(a, shift)
    local binA = bigNum.toBinary(a)
    binA = binA .. string.rep("0", shift)
    return bigNum.fromBinary(binA)
end

return bigNum
