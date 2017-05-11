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

--NeuralNetwork = instantiateNeuralNetwork({6,8})
--instantiateNeuralNetworkSpecies(NeuralNetwork)

Generation = instantiateGenerationOne({6,8})

emu.registerafter(normalizeControls)

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

			stateTab = loadStateConditionCheck(INPUTS,currentNetwork,KItable)
			nextNet = stateTab.nextNet
			currentNetwork = stateTab.currentNet
			currentNetworkOutputs = extractOutputs(NeuralNetworkForwardPass(currentNetwork,INPUTS))

			convertOutputsToControls(currentNetworkOutputs)
			outputToControlConversion = convertOutputsToControls(currentNetworkOutputs)


			OutputOverlays(outputToControlConversion)

			if nextNet and NeuralNetIndex == #Generation then
				Generation = instantiateRegularGeneration(Generation)
				genIndex = genIndex + 1
				NeuralNetIndex = 1
				nextNet = true
				normalizeControls()
				speciesIndex = 1

			elseif nextNet then
				NeuralNetIndex = NeuralNetIndex + 1
				speciesIndex = NeuralNetIndex
				nextNet = false
				normalizeControls()
			end
		end

	elseif(genIndex >1) then
			i = speciesIndex

			if (NeuralNetIndex <= #Generation[speciesIndex])  then
			currentNetwork = Generation[speciesIndex][NeuralNetIndex]

			INPUTS = generateOverlays()
			if KItable then
				KItable = fillKITable(KItable,INPUTS.KIPlayer,nextNet)
			else
				KItable = {}
				KItable = fillKITable(KItable,INPUTS.KIPlayer,nextNet)
			end

			stateTab = loadStateConditionCheck(INPUTS,currentNetwork,KItable)
			nextNet = stateTab.nextNet
			currentNetwork = stateTab.currentNet
			currentNetworkOutputs = extractOutputs(NeuralNetworkForwardPass(currentNetwork,INPUTS))

			convertOutputsToControls(currentNetworkOutputs)
			outputToControlConversion = convertOutputsToControls(currentNetworkOutputs)


			OutputOverlays(outputToControlConversion)

			if nextNet and speciesIndex > #Generation[i] then
				NeuralNetIndex = 1
				speciesIndex = speciesIndex + 1
				nextNet = false
				normalizeControls()
			elseif nextNet then
				NeuralNetIndex = NeuralNetIndex + 1
				nextNet = false
				normalizeControls()
			end
		else
			Generation = instantiateRegularGeneration(Generation)
			genIndex = genIndex + 1
			NeuralNetIndex = 1
			nextNet = true
			normalizeControls()
		end
	end
	processOverlay(genIndex,speciesIndex,NeuralNetIndex,currentNetwork.fitness)
	emu.frameadvance()

end


