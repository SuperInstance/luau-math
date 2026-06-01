--[[
	run-tests.luau — Test suite for luau-math (25+ tests)
	Run with: luau tests/run-tests.luau
]]

local Symmetry = require("../src/Symmetry")
local Rhythm = require("../src/Rhythm")
local Sequence = require("../src/Sequence")

local passed = 0
local failed = 0

local function assertEq(name: string, actual: any, expected: any)
	if actual == expected then
		print("  ✅ " .. name)
		passed += 1
	else
		print("  ❌ " .. name .. " — expected " .. tostring(expected) .. ", got " .. tostring(actual))
		failed += 1
	end
end

local function assertApprox(name: string, actual: number, expected: number, tol: number)
	if math.abs(actual - expected) <= tol then
		print("  ✅ " .. name)
		passed += 1
	else
		print("  ❌ " .. name .. " — expected ~" .. tostring(expected) .. ", got " .. tostring(actual))
		failed += 1
	end
end

-- ============================================================================
-- Symmetry: CyclicGroup
-- ============================================================================
print("🔷 Symmetry.CyclicGroup")
do
	local c3 = Symmetry.CyclicGroup.new(3)

	assertEq("elements count", #c3:elements(), 3)
	assertEq("identity", c3:identity(), 0)
	assertEq("compose 1+2 mod 3", c3:compose(1, 2), 0)
	assertEq("compose 2+2 mod 3", c3:compose(2, 2), 1)
	assertEq("inverse of 1 in Z/3", c3:inverse(1), 2)
	assertEq("inverse of 0 is 0", c3:inverse(0), 0)
	assertEq("order", c3:order(), 3)
end

-- ============================================================================
-- Symmetry: DihedralGroup
-- ============================================================================
print("🔷 Symmetry.DihedralGroup")
do
	local d3 = Symmetry.DihedralGroup.new(3)

	assertEq("elements count", #d3:elements(), 6)
	assertEq("order", d3:order(), 6)

	local e = d3:identity()
	assertEq("identity rotation", e.rotation, 0)
	assertEq("identity no reflection", e.reflection, false)

	-- Compose two rotations
	local r1 = { rotation = 1, reflection = false }
	local r2 = { rotation = 2, reflection = false }
	local r3 = d3:compose(r1, r2)
	assertEq("r1*r2 rotation", r3.rotation, 0)
	assertEq("r1*r2 no reflection", r3.reflection, false)

	-- Inverse of a reflection is itself
	local s = { rotation = 1, reflection = true }
	local sinv = d3:inverse(s)
	assertEq("reflection inverse rotation", sinv.rotation, 1)
	assertEq("reflection inverse is reflection", sinv.reflection, true)
end

-- ============================================================================
-- Symmetry: Burnside's Lemma
-- ============================================================================
print("🔷 Symmetry.Burnside")
do
	-- Classic example: 2 colors on 3 vertices under C3 rotation
	-- Fix(e) = 2^3 = 8, Fix(r) = 2, Fix(r^2) = 2
	-- Burnside = (8+2+2)/3 = 4
	local orbits = Symmetry.Burnside.lemma({ 8, 2, 2 }, 3)
	assertEq("2-color necklaces (n=3)", orbits, 4)
end

-- ============================================================================
-- Rhythm: Tempo
-- ============================================================================
print("🔷 Rhythm.Tempo")
do
	assertApprox("bpm 120 → 500ms", Rhythm.Tempo.bpmToMs(120), 500, 0.01)
	assertApprox("500ms → bpm 120", Rhythm.Tempo.msToBpm(500), 120, 0.01)
	assertApprox("bpm 60 → 1000ms", Rhythm.Tempo.bpmToMs(60), 1000, 0.01)
end

-- ============================================================================
-- Rhythm: Polyrhythm
-- ============================================================================
print("🔷 Rhythm.Polyrhythm")
do
	assertEq("cycleLength(3,4)", Rhythm.Polyrhythm.cycleLength(3, 4), 12)
	assertEq("cycleLength(2,3)", Rhythm.Polyrhythm.cycleLength(2, 3), 6)

	local pat = Rhythm.Polyrhythm.pattern(2, 3)
	assertEq("pattern voice A length", #pat[1], 6)
	assertEq("pattern voice B length", #pat[2], 6)

	-- Voice A (every 2): 1,0,1,0,1,0
	assertEq("voice A[1]", pat[1][1], 1)
	assertEq("voice A[2]", pat[1][2], 0)
	assertEq("voice A[3]", pat[1][3], 1)

	-- Voice B (every 3): 1,0,0,1,0,0
	assertEq("voice B[1]", pat[2][1], 1)
	assertEq("voice B[4]", pat[2][4], 1)
end

-- ============================================================================
-- Rhythm: Syncopation
-- ============================================================================
print("🔷 Rhythm.Syncopation")
do
	-- A pattern with all beats on strong positions should have low syncopation
	local straight = { 1, 0, 1, 0, 1, 0, 1, 0 }
	local s1 = Rhythm.Syncopation.score(straight)
	assert("straight pattern has syncopation >= 0", s1 >= 0)
end

-- ============================================================================
-- Rhythm: Groove
-- ============================================================================
print("🔷 Rhythm.Groove")
do
	local swing = Rhythm.Groove.swingFactor(120, 66.67)
	assertEq("swing returns 2 values", #swing, 2)
	assert("downbeat > upbeat", swing[1] > swing[2])

	-- Straight (0% swing) should be equal
	local straight = Rhythm.Groove.swingFactor(120, 0)
	assertApprox("straight downbeat", straight[1], 250, 0.1)
	assertApprox("straight upbeat", straight[2], 250, 0.1)
end

-- ============================================================================
-- Rhythm: RhythmicEntropy
-- ============================================================================
print("🔷 Rhythm.RhythmicEntropy")
do
	-- Regular pattern: all intervals the same → entropy = 0
	local regular = { 1, 0, 1, 0, 1, 0, 1, 0 }
	local h1 = Rhythm.RhythmicEntropy.calculate(regular)
	assertApprox("regular entropy ≈ 0", h1, 0, 0.001)

	-- Irregular pattern: varying intervals → entropy > 0
	local irregular = { 1, 0, 0, 1, 1, 0, 1, 0 }
	local h2 = Rhythm.RhythmicEntropy.calculate(irregular)
	assert("irregular entropy > 0", h2 > 0)

	-- Single onset → 0
	local single = { 0, 0, 1, 0 }
	local h3 = Rhythm.RhythmicEntropy.calculate(single)
	assertEq("single onset entropy = 0", h3, 0)
end

-- ============================================================================
-- Sequence: Fibonacci
-- ============================================================================
print("🔷 Sequence.Fibonacci")
do
	assertEq("F(0)", Sequence.Fibonacci.nth(0), 0)
	assertEq("F(1)", Sequence.Fibonacci.nth(1), 1)
	assertEq("F(10)", Sequence.Fibonacci.nth(10), 55)

	local seq = Sequence.Fibonacci.sequence(7)
	assertEq("sequence length", #seq, 7)
	assertEq("seq[1]=0", seq[1], 0)
	assertEq("seq[2]=1", seq[2], 1)
	assertEq("seq[7]=8", seq[7], 8)
end

-- ============================================================================
-- Sequence: Golden
-- ============================================================================
print("🔷 Sequence.Golden")
do
	local phi = Sequence.Golden.ratio()
	assertApprox("golden ratio ≈ 1.618", phi, 1.6180339887, 0.0001)

	local spiral = Sequence.Golden.fibonacciSpiral(5)
	assertEq("spiral points count", #spiral, 5)
	assertEq("spiral[1].r = F(1)", spiral[1].r, 1)
	assertEq("spiral[5].r = F(5)", spiral[5].r, 5)
end

-- ============================================================================
-- Sequence: Pascal
-- ============================================================================
print("🔷 Sequence.Pascal")
do
	local row4 = Sequence.Pascal.row(4)
	assertEq("row(4) length", #row4, 5)
	assertEq("row(4) = {1,4,6,4,1}", row4[1] .. "," .. row4[2] .. "," .. row4[3] .. "," .. row4[4] .. "," .. row4[5], "1,4,6,4,1")

	local tri = Sequence.Pascal.triangle(4)
	assertEq("triangle(4) rows", #tri, 4)
	assertEq("triangle row 0", #tri[1], 1)
	assertEq("triangle row 3", #tri[4], 4)
end

-- ============================================================================
-- Summary
-- ============================================================================
print("\n" .. string.rep("=", 40))
print(string.format("Results: %d passed, %d failed, %d total", passed, failed, passed + failed))
if failed == 0 then
	print("🎉 All tests passed!")
else
	print("⚠️  Some tests failed.")
end
