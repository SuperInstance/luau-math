--[[
	Sequence.luau — Mathematical sequences and constants for Luau
	Provides Fibonacci, Golden, Pascal.
]]

local Sequence = {}

--------------------------------------------------------------------------------
-- Fibonacci
--------------------------------------------------------------------------------

local Fibonacci = {}

function Fibonacci.nth(n: number): number
	assert(n >= 0, "n must be >= 0")
	if n <= 1 then
		return n
	end
	local a, b = 0, 1
	for _ = 2, n do
		a, b = b, a + b
	end
	return b
end

function Fibonacci.sequence(count: number): { number }
	assert(count >= 0, "count must be >= 0")
	local result = {}
	local a, b = 0, 1
	for i = 1, count do
		table.insert(result, a)
		a, b = b, a + b
	end
	return result
end

Sequence.Fibonacci = Fibonacci

--------------------------------------------------------------------------------
-- Golden ratio & Fibonacci spiral
--------------------------------------------------------------------------------

local Golden = {}

function Golden.ratio(): number
	return (1 + math.sqrt(5)) / 2
end

function Golden.fibonacciSpiral(points: number): { { x: number, y: number, r: number } }
	assert(points >= 0, "points must be >= 0")
	local result = {}
	local phi = Golden.ratio()
	-- Golden angle in radians
	local goldenAngle = 2 * math.pi / (phi * phi)

	local a, b = 0, 1
	for i = 1, points do
		local angle = (i - 1) * goldenAngle
		local r = math.sqrt(i) * 5 -- scale factor for visibility
		table.insert(result, {
			x = r * math.cos(angle),
			y = r * math.sin(angle),
			r = b, -- Fibonacci number at this index
		})
		a, b = b, a + b
	end
	return result
end

Sequence.Golden = Golden

--------------------------------------------------------------------------------
-- Pascal's Triangle
--------------------------------------------------------------------------------

local Pascal = {}

function Pascal.row(n: number): { number }
	assert(n >= 0, "n must be >= 0")
	local row = {}
	local val = 1
	table.insert(row, val)
	for k = 1, n do
		val = val * (n - k + 1) / k
		table.insert(row, math.floor(val + 0.5))
	end
	return row
end

function Pascal.triangle(rows: number): { { number } }
	assert(rows >= 0, "rows must be >= 0")
	local result = {}
	for i = 0, rows - 1 do
		table.insert(result, Pascal.row(i))
	end
	return result
end

Sequence.Pascal = Pascal

return Sequence
