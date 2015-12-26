--- A 2 component vector.
-- @module vec2

local sqrt= math.sqrt
local ffi = require "ffi"

local vec2 = {}

-- Private constructor.
local function new(x, y, z)
	local v = {}
	v.x, v.y = x, y
	return setmetatable(v, vec2_mt)
end

-- Do the check to see if JIT is enabled. If so use the optimized FFI structs.
local status, ffi
if type(jit) == "table" and jit.status() then
	status, ffi = pcall(require, "ffi")
	if status then
		ffi.cdef "typedef struct { double x, y;} cpml_vec2;"
		new = ffi.typeof("cpml_vec2")
	end
end

--- The public constructor.
-- @param x Can be of three types: </br>
-- number x component
-- table {x, y} or {x = x, y = y}
-- scalar to fill the vector eg. {x, x}
-- @tparam number y y component
function vec2.new(x, y)
	-- number, number, number
	if x and y then
		assert(type(x) == "number", "new: Wrong argument type for x (<number> expected)")
		assert(type(y) == "number", "new: Wrong argument type for y (<number> expected)")

		return new(x, y)

	-- {x=x, y=y} or {x, y}
	elseif type(x) == "table" then
		local x, y = x.x or x[1], x.y or x[2]
		assert(type(x) == "number", "new: Wrong argument type for x (<number> expected)")
		assert(type(y) == "number", "new: Wrong argument type for y (<number> expected)")

		return new(x, y)

	-- {x, x, x} eh. {0, 0, 0}, {3, 3, 3}
	elseif type(x) == "number" then
		return new(x, x)
	else
		return new(0, 0)
	end
end


--- Clone a vector.
-- @tparam vec2 a vector to be cloned
-- @treturn vec2
function vec2.clone(a)
	return new(a.x, a.y, a.z)
end

--- Add two vectors.
-- @tparam vec2 out vector to store the result
-- @tparam vec2 a Left hand operant
-- @tparam vec2 b Right hand operant
function vec2.add(out, a, b)
	out.x = a.x + b.x
	out.y = a.y + b.y
	return out
end

--- Subtract one vector from another.
-- @tparam vec2 out vector to store the result
-- @tparam vec2 a Left hand operant
-- @tparam vec2 b Right hand operant
function vec2.sub(out, a, b)
	out.x = a.x - b.x
	out.y = a.y - b.y
	return out
end

--- Multiply a vector by a scalar.
-- @tparam vec2 out vector to store the result
-- @tparam vec2 a Left hand operant
-- @tparam number b Right hand operant
function vec2.mul(out, a, b)
	out.x = a.x * b
	out.y = a.y * b
	return out
end

--- Divide one vector by a scalar.
-- @tparam vec2 out vector to store the result
-- @tparam vec2 a Left hand operant
-- @tparam number b Right hand operant
function vec2.div(out, a, b)
	out.x = a.x / b
	out.y = a.y / b
	return out
end

--- Get the normal of a vector.
-- @tparam vec2 out vector to store the result
-- @tparam vec2 a vector to normalize
function vec2.normalize(out, a)
	local l = vec2.len(a)
	out.x = a.x / l
	out.y = a.y / l
	return out
end

--- Trim a vector to a given length
-- @tparam vec2 out vector to store the result
-- @tparam vec2 a vector to be trimmed
-- @tparam number len the length to trim the vector to
function vec2.trim(out, a, len)
	len = math.min(vec2.len(a), len)
	vec2.normalize(out, a)
	vec2.mul(out, len)
	return out
end

--- Get the cross product of two vectors.
-- @tparam vec2 a Left hand operant
-- @tparam vec2 b Right hand operant
-- @treturn number magnitude of cross product in 3d
function vec2.cross(a, b)
	return a.x * b.y - a.y * b.x
end

--- Get the dot product of two vectors.
-- @tparam vec2 a Left hand operant
-- @tparam vec2 b Right hand operant
-- @treturn number 
function vec2.dot(a, b)
	return a.x * b.x + a.y * b.y
end

--- Get the length of a vector.
-- @tparam vec2 a vector to get the length of
-- @treturn number
function vec2.len(a)
	return sqrt(a.x * a.x + a.y * a.y)
end

--- Get the squared length of a vector.
-- @tparam vec2 a vector to get the squared length of
-- @treturn number
function vec2.len2(a)
	return a.x * a.x + a.y * a.y
end

--- Get the distance between two vectors.
-- @tparam vec2 a first vector
-- @tparam vec2 b second vector
-- @treturn number
function vec2.dist(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	return sqrt(dx * dx + dy * dy)
end

--- Get the squared distance between two vectors.
-- @tparam vec2 a first vector
-- @tparam vec2 b second vector
-- @treturn number
function vec2.dist2(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	return dx * dx + dy * dy
end

--- Lerp between two vectors.
-- @tparam vec3 out vector for result to be stored in
-- @tparam vec3 a first vector
-- @tparam vec3 b second vector
-- @tparam number s step value
-- @treturn vec3
function vec2.lerp(out, a, b, s)
	vec2.sub(out, b, a)
	vec2.mul(out, out, s)
	vec2.add(out, out, a)
	return out
end

--- Unpack a vector into form x,y
-- @tparam vec2 a first vector
-- @treturn number x component
-- @treturn number y component
function vec2.unpack(a)
	return a.x, a.y
end

--- Return a string formatted "{x, y}"
-- @tparam vec2 a the vector to be turned into a string
-- @treturn string
function vec2.tostring(a)
	return string.format("(%+0.3f,%+0.3f)", a.x, a.y)
end

--- Return a boolean showing if a table is or is not a vec2
-- @param v the object to be tested
-- @treturn boolean
function vec2.isvector(v)
	return 	type(v) == "table" and
			type(v.x) == "number" and
			type(v.y) == "number"
end

local vec2_mt = {}

vec2_mt.__index = vec2
vec2_mt.__tostring = vec2.tostring

function vec2_mt.__call(self, x, y, z)
	return vec2.new(x, y, z)
end

function vec2_mt.__unm(a)
	return vec2.new(-a.x, -a.y)
end

function vec2_mt.__eq(a,b)
	assert(vec2.isvector(a), "__eq: Wrong argument type for left hand operant. (<cpml.vec2> expected)")
	assert(vec2.isvector(b), "__eq: Wrong argument type for right hand operant. (<cpml.vec2> expected)")

	return a.x == b.x and a.y == b.y
end

function vec2_mt.__add(a, b)
	assert(vec2.isvector(a), "__add: Wrong argument type for left hand operant. (<cpml.vec2> expected)")
	assert(vec2.isvector(b), "__add: Wrong argument type for right hand operant. (<cpml.vec2> expected)")

	local temp = vec2.new()
	vec2.add(temp, a, b)
	return temp
end

function vec2_mt.__mul(a, b)
	local isvecb = vec2.isvector(b)
	a, b = isvecb and b or a, isvecb and a or b

	assert(vec2.isvector(a), "__mul: Wrong argument type for left hand operant. (<cpml.vec2> expected)")
	assert(type(b) == "number", "__mul: Wrong argument type for right hand operant. (<number> expected)")

	local temp = vec2.new()
	vec2.mul(temp, a, b)
	return temp
end

function vec2_mt.__div(a, b)
	local isvecb = isvector(b)
	a, b = isvecb and b or a, isvecb and a or b

	assert(vec2.isvector(a), "__div: Wrong argument type for left hand operant. (<cpml.vec2> expected)")
	assert(type(b) == "number", "__div: Wrong argument type for right hand operant. (<number> expected)")

	local temp = vec2.new()
	vec2.div(temp, a, b)
	return temp
end

if status then
	ffi.metatype(new, vec2_mt)
end

return setmetatable({}, vec2_mt)
