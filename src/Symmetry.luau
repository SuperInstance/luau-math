--[[
	Symmetry.luau — Group theory primitives for Luau
	Provides CyclicGroup, DihedralGroup, and Burnside's lemma.
]]

local Symmetry = {}

--------------------------------------------------------------------------------
-- CyclicGroup: rotations of a regular n-gon (Z/nZ)
--------------------------------------------------------------------------------

local CyclicGroup = {}
CyclicGroup.__index = CyclicGroup

function CyclicGroup.new(n: number)
	assert(n >= 1, "CyclicGroup order must be >= 1")
	local self = setmetatable({}, CyclicGroup)
	self._n = math.floor(n)
	return self
end

function CyclicGroup:elements(): { number }
	local elems = {}
	for i = 0, self._n - 1 do
		table.insert(elems, i)
	end
	return elems
end

function CyclicGroup:compose(a: number, b: number): number
	return (a + b) % self._n
end

function CyclicGroup:inverse(a: number): number
	return (self._n - (a % self._n)) % self._n
end

function CyclicGroup:identity(): number
	return 0
end

function CyclicGroup:order(): number
	return self._n
end

Symmetry.CyclicGroup = CyclicGroup

--------------------------------------------------------------------------------
-- DihedralGroup: rotations + reflections of a regular n-gon (D_n)
-- Elements encoded as { rotation: number, reflection: boolean }
--------------------------------------------------------------------------------

local DihedralGroup = {}
DihedralGroup.__index = DihedralGroup

export type DihedralElement = {
	rotation: number,
	reflection: boolean,
}

function DihedralGroup.new(n: number)
	assert(n >= 1, "DihedralGroup order must be >= 1")
	local self = setmetatable({}, DihedralGroup)
	self._n = math.floor(n)
	return self
end

function DihedralGroup:elements(): { DihedralElement }
	local elems = {}
	for i = 0, self._n - 1 do
		table.insert(elems, { rotation = i, reflection = false })
	end
	for i = 0, self._n - 1 do
		table.insert(elems, { rotation = i, reflection = true })
	end
	return elems
end

function DihedralGroup:compose(
	a: DihedralElement,
	b: DihedralElement
): DihedralElement
	-- D_n multiplication: if b has a reflection it flips the rotation direction
	if not a.reflection and not b.reflection then
		-- r^a * r^b = r^(a+b)
		return { rotation = (a.rotation + b.rotation) % self._n, reflection = false }
	elseif not a.reflection and b.reflection then
		-- r^a * s*r^b = s*r^(b-a)
		return { rotation = (b.rotation - a.rotation) % self._n, reflection = true }
	elseif a.reflection and not b.reflection then
		-- s*r^a * r^b = s*r^(a+b)
		return { rotation = (a.rotation + b.rotation) % self._n, reflection = true }
	else
		-- s*r^a * s*r^b = r^(b-a)
		return { rotation = (b.rotation - a.rotation) % self._n, reflection = false }
	end
end

function DihedralGroup:inverse(a: DihedralElement): DihedralElement
	if not a.reflection then
		return { rotation = (self._n - a.rotation) % self._n, reflection = false }
	else
		-- (s*r^a)^-1 = s*r^a  (reflections are self-inverse in this encoding)
		return { rotation = a.rotation % self._n, reflection = true }
	end
end

function DihedralGroup:identity(): DihedralElement
	return { rotation = 0, reflection = false }
end

function DihedralGroup:order(): number
	return 2 * self._n
end

Symmetry.DihedralGroup = DihedralGroup

--------------------------------------------------------------------------------
-- Burnside's Lemma
-- fixedCounts: array of numbers, one per group element, giving |Fix(g)|
-- groupOrder: |G|
-- Returns the number of distinct orbits = (1/|G|) * sum(|Fix(g)|)
--------------------------------------------------------------------------------

local Burnside = {}

function Burnside.lemma(fixedCounts: { number }, groupOrder: number): number
	assert(groupOrder > 0, "groupOrder must be > 0")
	assert(#fixedCounts == groupOrder, "fixedCounts length must equal groupOrder")
	local sum = 0
	for _, c in fixedCounts do
		sum += c
	end
	return sum / groupOrder
end

Symmetry.Burnside = Burnside

return Symmetry
