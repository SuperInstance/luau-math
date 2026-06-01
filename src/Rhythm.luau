--[[
	Rhythm.luau — Rhythm and music math for Luau
	Provides Tempo, Polyrhythm, Syncopation, Groove, RhythmicEntropy.
]]

local Rhythm = {}

--------------------------------------------------------------------------------
-- Tempo
--------------------------------------------------------------------------------

local Tempo = {}

function Tempo.bpmToMs(bpm: number): number
	assert(bpm > 0, "BPM must be > 0")
	return 60000 / bpm
end

function Tempo.msToBpm(ms: number): number
	assert(ms > 0, "ms must be > 0")
	return 60000 / ms
end

Rhythm.Tempo = Tempo

--------------------------------------------------------------------------------
-- Polyrhythm
--------------------------------------------------------------------------------

local Polyrhythm = {}

-- LCM of two positive integers
local function lcm(a: number, b: number): number
	local function gcd(x: number, y: number): number
		while y ~= 0 do
			x, y = y, x % y
		end
		return x
	end
	return math.floor(math.abs(a * b)) / gcd(math.abs(a), math.abs(b))
end

function Polyrhythm.cycleLength(a: number, b: number): number
	return lcm(a, b)
end

function Polyrhythm.pattern(a: number, b: number): { { number } }
	local len = lcm(a, b)
	local voiceA = {}
	local voiceB = {}
	for i = 1, len do
		table.insert(voiceA, ((i - 1) % a == 0) and 1 or 0)
		table.insert(voiceB, ((i - 1) % b == 0) and 1 or 0)
	end
	return { voiceA, voiceB }
end

Rhythm.Polyrhythm = Polyrhythm

--------------------------------------------------------------------------------
-- Syncopation (Longuet-Higgins)
-- Pattern is an array of 0|1 values over a metrical grid.
-- Score sums the metrical weight at each onset; higher = more syncopated.
-- We use a simple hierarchical weighting: for N steps, weight of position i
-- is based on how often i falls on a strong beat.
--------------------------------------------------------------------------------

local Syncopation = {}

function Syncopation.score(pattern: { number }): number
	local n = #pattern
	if n == 0 then
		return 0
	end

	-- Compute metrical weight for each position using the LHL approach:
	-- For each subdivision level d (= 1, 2, 4, 8, ...), a position is on-beat
	-- if (i-1) % d == 0. The weight is the number of subdivision levels it's on.
	local weights = {}
	for i = 1, n do
		local w = 0
		local d = 1
		while d <= n do
			if (i - 1) % d == 0 then
				w += 1
			else
				break -- once we miss a level, no deeper levels apply
			end
			d = d * 2
		end
		weights[i] = w
	end

	-- Normalize weights so max weight = 0 (strong beats have 0 syncopation)
	local maxWeight = 0
	for _, w in weights do
		if w > maxWeight then
			maxWeight = w
		end
	end

	local totalSyncopation = 0
	for i = 1, n do
		if pattern[i] == 1 then
			-- Onset at position i: syncopation is (maxWeight - weight)
			-- plus if the next position has higher weight, add the difference
			local nextI = (i % n) + 1
			local sync = maxWeight - weights[i]
			if weights[nextI] > weights[i] then
				sync += weights[nextI] - weights[i]
			end
			totalSyncopation += sync
		end
	end

	return totalSyncopation
end

Rhythm.Syncopation = Syncopation

--------------------------------------------------------------------------------
-- Groove
--------------------------------------------------------------------------------

local Groove = {}

function Groove.swingFactor(bpm: number, swingPercent: number): { number }
	-- Returns { downbeatDuration, upbeatDuration } in ms
	local baseMs = Tempo.bpmToMs(bpm)
	-- swingPercent: 0 = straight, 50 = triplet, 100 = dotted
	local downFraction = 50 + swingPercent / 2
	local upFraction = 50 - swingPercent / 2
	local eighthMs = baseMs / 2
	return {
		eighthMs * (downFraction / 50),
		eighthMs * (upFraction / 50),
	}
end

Rhythm.Groove = Groove

--------------------------------------------------------------------------------
-- RhythmicEntropy
-- Shannon entropy of the interval distribution in a binary pattern.
--------------------------------------------------------------------------------

local RhythmicEntropy = {}

function RhythmicEntropy.calculate(pattern: { number }): number
	-- Extract inter-onset intervals
	local onsetPositions = {}
	for i, v in pattern do
		if v == 1 then
			table.insert(onsetPositions, i)
		end
	end

	if #onsetPositions <= 1 then
		return 0
	end

	-- Compute intervals (wrapping around)
	local intervals = {}
	local n = #pattern
	for i = 1, #onsetPositions - 1 do
		table.insert(intervals, onsetPositions[i + 1] - onsetPositions[i])
	end
	-- Wrap-around interval
	table.insert(intervals, n - onsetPositions[#onsetPositions] + onsetPositions[1])

	-- Count frequency of each interval
	local counts: { [number]: number } = {}
	for _, interval in intervals do
		counts[interval] = (counts[interval] or 0) + 1
	end

	-- Shannon entropy
	local total = #intervals
	local entropy = 0
	for _, count in counts do
		local p = count / total
		if p > 0 then
			entropy = entropy - p * math.log(p)
		end
	end

	return entropy
end

Rhythm.RhythmicEntropy = RhythmicEntropy

return Rhythm
