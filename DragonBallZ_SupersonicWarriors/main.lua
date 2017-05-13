require("overlays")
require("NeuralNet")
require("NeuralNetPool")
--require("guiFileIO")

--local nGenerations = 100000
local INPUTS  = {}

local savestateObject = savestate.create()
savestate.save(savestateObject)

function loadStateConditionCheck(INPUTS,currentNet, PlayerKIUsageTable)

	if INPUTS.HPPlayer == 0 or INPUTS.HPEnemy == 0 then
		savestate.load(savestateObject)
		nextNet = true
	else
		nextNet = false
	end

	currentNet.fitness = FitnessFunction(INPUTS.HPPlayer,PlayerKIUsageTable,INPUTS.HPEnemy)

	local tab = {}
	tab.nextNet = nextNet
	tab.currentNet = currentNet

	return tab
end

function fillKITable(kitable,ki,nextNet)

	local KITable = kitable

	if nextNet == true then
		KITable = {}
	elseif getFrameNumber() % 10 == 0 then
		table.insert(KITable,ki)
	end

	return KITable
end

Generation = instantiateGenerationOne({6,6})

local nextNet = false
local NeuralNetIndex = 1
local KItable = {}
local genIndex = 1
while true do
	if (genIndex == 1) then
		if (NeuralNetIndex <= #Generation) then
			i = NeuralNetIndex
			speciesIndex = NeuralNetIndex
			currentNetwork = Generation[NeuralNetIndex]

			INPUTS = generateOverlays()
			if KItable then
				KItable = fillKITable(KItable,INPUTS.KIPlayer,nextNet)
			else
				KItable = {}
				KItable = fillKITable(KItable,INPUTS.KIPlayer,nextNet)
			end
			if emu.framecount()%4 == 0 then
				stateTab = loadStateConditionCheck(INPUTS,currentNetwork,KItable)
				nextNet = stateTab.nextNet
				currentNetwork = stateTab.currentNet
				currentNetworkOutputs = extractOutputs(NeuralNetworkForwardPass(currentNetwork,INPUTS))
				convertOutputsToControls(currentNetworkOutputs)
				outputToControlConversion = convertOutputsToControls(currentNetworkOutputs)

			end

			if nextNet and NeuralNetIndex == #Generation[NeuralNetIndex] then
				NeuralNetIndex = 1
				speciesIndex = 1
				genIndex = genIndex + 1
				Generation = instantiateRegularGeneration(Generation)
				nextNet = false
				normalizeControls()
			elseif nextNet then
				NeuralNetIndex = NeuralNetIndex + 1
				nextNet = false
				normalizeControls()
			end
		end

	elseif(genIndex >1) then

	end
	processOverlay(genIndex,speciesIndex,NeuralNetIndex,currentNetwork.fitness)
	neuralNetGraphOverlay(currentNetwork)
	outputKeysOverlay(outputToControlConversion)
	emu.frameadvance()
	emu.registerafter(normalizeControls)

end


