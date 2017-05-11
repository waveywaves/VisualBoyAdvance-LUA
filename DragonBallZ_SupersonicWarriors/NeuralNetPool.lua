require("NeuralNet")
local nOrganisms = 50
local nSpecies = 20


function instantiateGenerationOne(topology)

	local Generation = {}
	Generation.id = 1



	for i=1,nOrganisms do
		newNN = instantiateNeuralNetwork(topology)

		for j=1,1 do
			newNN.GlobalLinkSink   = mutateNeuralNetworkLinks(newNN)
			newNN.GlobalLinkSink   = mutateNeuralNetworkLinkWeights(newNN)
			newNN.GlobalLinkSink = mutateNeuralNetworkLinkStructure(newNN)
			--nn.GlobalNeuronSink = mutateNeuralNetworkNeuronBias(nn)
			newNN.GlobalLinkSink = LinkSinkChecker(newNN)
		end

		mutatedNeuralNetwork = newNN
		table.insert(Generation,mutatedNeuralNetwork)
	end

	return Generation

end

function getFitnessSorted(groupOfNNs)

	table.sort(groupOfNNs, function(a, b) return a.fitness > b.fitness end)
	return groupOfNNs
end

function instantiateRegularGeneration(previousGeneration)

		newGeneration = {}
		inCompatibleOrganisms = {}

		newGeneration.id = previousGeneration.id + 1
		matingRing = {}

		if previousGeneration.id == 1 then

			tabComp = compatibilityCheck(previousGeneration)
			inCompatibleOrganisms = tabComp.inCompatibleOrganisms
			previousGeneration = tabComp.groupOfNNs

			-- Mean Fitness Calculation
			local meanFitness = 0
			for f=1,#previousGeneration do

				if f ~= previousGeneration then
					meanFitness = meanFitness + previousGeneration[f].fitness
				else
					meanFitness = meanFitness + previousGeneration[f].fitness
					meanFitness = meanFitness / #previousGeneration
				end

			end

			local FitAndDifferent = {}

			for nn=1,#inCompatibleOrganisms do

				if inCompatibleOrganisms[nn].fitness > meanFitness then
					inCompatibleOrganisms[nn].eligibilityToFormSpecies = true
					table.insert(FitAndDifferent,inCompatibleOrganisms[nn])
				end

			end

			previousGeneration = getFitnessSorted(previousGeneration)

			for nn=1,#previousGeneration do

				if previousGeneration[nn].fitness	 > meanFitness then
					table.insert(FitAndDifferent,previousGeneration[nn])
				end

			end

			local champ = previousGeneration[1]

			--for all species in the next gen
			--25% of the population will be the champ
			--75% would be random crossovers between rest of the fittest organisms

			for i=1,nSpecies-math.ceil(0.05*nSpecies) do
				table.insert(newGeneration,instantiateSpecies(champ,FitAndDifferent))
			end
			for j=1,5 do
				matingRing = instantiateMatingRing(FitAndDifferent)
				index = math.random(1,5)
				if (math.random() > 0.7) then
					newNN = matingRing[index]
					newNN.GlobalLinkSink   = mutateNeuralNetworkLinks(newNN)
					newNN.GlobalLinkSink   = mutateNeuralNetworkLinkWeights(newNN)
					newNN.GlobalLinkSink = mutateNeuralNetworkLinkStructure(newNN)
					--nn.GlobalNeuronSink = mutateNeuralNetworkNeuronBias(nn)
					newNN.GlobalLinkSink = LinkSinkChecker(newNN)
					table.insert(matingRing,newNN)
				end
				table.insert(newGeneration,matingRing)
			end

		else

			for s=1,#previousGeneration do

				speciesTabComp = compatibilityCheck(previousGeneration[s])
				inCompatibleOrganisms = speciesTabComp.inCompatibleOrganisms
				previousGeneration[s] = speciesTabComp.groupOfNNs

			end

		end

		return newGeneration
end

function compatibilityCheck(groupOfNNs)

	local averagedWeights = {}
	local numbersOfNodes = {}
	local numbersOfConnections = {}

	for i=1,#groupOfNNs do

		local weights = {}
		for l = 1,#groupOfNNs[i].GlobalLinkSink do
			table.insert(weights,groupOfNNs[i].GlobalLinkSink[l].weight)
		end
		local sumOfWeights = 0
		for w = 1,#weights do
			sumOfWeights = sumOfWeights + weights[w]
		end
		local averagedWeight = (sumOfWeights/(#groupOfNNs[i].GlobalLinkSink))

		groupOfNNs[i].averagedWeight = averagedWeight

		table.insert(averagedWeights,averageWeight)

		groupOfNNs[i].numberOfNodes = #groupOfNNs[i].GlobalNeuronSink

		table.insert(numbersOfNodes,#groupOfNNs[i].GlobalNeuronSink)

		groupOfNNs[i].numberOfConnections = #groupOfNNs[i].GlobalLinkSink

		table.insert(numbersOfConnections,#groupOfNNs[i].GlobalLinkSink)

	end


	--defining Means

		local meanAveragedWeights = 0
		local meanNumberOfNodes = 0
		local meanNumberOfConnections = 0

	for w=1,#averagedWeights do

		if w ~= #averagedWeights then
			meanAveragedWeights = meanAveragedWeights + averagedWeights
		else
			meanAveragedWeights = meanAveragedWeights + averagedWeights
			meanAveragedWeights = meanAveragedWeights / #averagedWeights
		end

	end

	for n=1,#numbersOfNodes do

		if n ~= #numbersOfNodes then
			meanNumberOfNodes = meanNumberOfNodes + numbersOfNodes[n]
		else
			meanNumberOfNodes = meanNumberOfNodes + numbersOfNodes[n]
			meanNumberOfNodes = meanNumberOfNodes / #numbersOfNodes
		end

	end

	for c=1,#numbersOfConnections do
		if c ~= #numbersOfConnections then
			meanNumberOfConnections = meanNumberOfConnections + numbersOfConnections[c]
		else
			meanNumberOfConnections = meanNumberOfConnections + numbersOfConnections[c]
			meanNumberOfConnections = meanNumberOfConnections / #numbersOfConnections
		end
	end

	--defining MeanDeviation
	local meanDeviations = {}

	for i=1,#groupOfNNs do
		local var1 = 0
		local var2 = 0
		local var3 = 0
		local var = 0

		var1 = (groupOfNNs[i].averagedWeight - meanAveragedWeights)
		var2 = (groupOfNNs[i].numberOfNodes - meanNumberOfNodes)
		var3 = (groupOfNNs[i].numberOfConnections - meanNumberOfConnections)

		var = (var1+var2+var3)/3

		groupOfNNs[i].overallMeanDeviation = var
		table.insert(meanDeviations,var)
	end

	--Mean of meanDeviations
	local meanMeanDeviations = 0

	for m=1,#meanDeviations do
		if m ~= #meanDeviations then
			meanMeanDeviations = meanMeanDeviations + meanDeviations[m]
		else
			meanMeanDeviations = meanMeanDeviations + meanDeviations[m]
			meanMeanDeviations = meanMeanDeviations / #meanDeviations
		end
	end

	--checkIncompatible organnisms
	local inCompatibleOrganisms = {}

	for o=1,#groupOfNNs do
		if groupOfNNs[o].overallMeanDeviation > meanMeanDeviations then
			table.insert(inCompatibleOrganisms, groupOfNNs[o])
		end
	end


	tab = {}
	tab.inCompatibleOrganisms = inCompatibleOrganisms
	tab.groupOfNNs = groupOfNNs

	return tab
end

function instantiateSpecies(champ,FittestOrganisms)

	local newSpecies = {}
	local matingRing = {}

	for i = 1,math.floor((0.25/2)*nOrganisms) do
		table.insert(newSpecies,champ)
	end
	for j = 1,math.floor((0.25/2)*nOrganisms) do
			champ.GlobalLinkSink   = mutateNeuralNetworkLinks(champ)
			champ.GlobalLinkSink   = mutateNeuralNetworkLinkWeights(champ)
			champ.GlobalLinkSink = mutateNeuralNetworkLinkStructure(champ)
			--nn.GlobalNeuronSink = mutateNeuralNetworkNeuronBias(nn)
			champ.GlobalLinkSink = LinkSinkChecker(champ)
		table.insert(newSpecies,champ)
	end
	table.insert(FittestOrganisms,champ)
	matingRing = instantiateMatingRing(FittestOrganisms)

	for k=1,math.floor(0.75*nOrganisms) do
		index = math.random(1,#matingRing)
		table.insert(newSpecies,matingRing[index])
	end


	return newSpecies

end

function instantiateMatingRing(groupOfNNs)

	local groupOfNNs = getFitnessSorted(groupOfNNs)
	local chosenOnes = {}
	local matingGroup1 = {}
	local matingGroup2 = {}

	for i=1,math.ceil(#groupOfNNs*0.25) do
		table.insert(matingGroup1,groupOfNNs[i])
	end
	for i=math.ceil(#groupOfNNs*0.25)+1,#groupOfNNs do
		table.insert(matingGroup2,groupOfNNs[i])
	end

	--mate the two groups randomly

	for i=1,#matingGroup2 do
		j=math.random(1,#matingGroup1)

		if matingGroup2[i].fitness > matingGroup1[j].fitness then
			fit = matingGroup2[i]
			lessfit = matingGroup1[j]

		elseif matingGroup1[j].fitness > matingGroup2[i].fitness then
			lessfit = matingGroup2[i]
			fit = matingGroup1[j]

		elseif matingGroup1[j].fitness == matingGroup2[i].fitness then
			if math.random(1,10)/10 > 0.5 then
				fit = matingGroup2[i]
				lessfit = matingGroup1[j]
			else
				lessfit = matingGroup2[i]
				fit = matingGroup1[j]
			end
		end

		NeuronsFit = fit.GlobalNeuronSink
		NeuronsUnfit = lessfit.GlobalNeuronSink
		LinksFit = fit.GlobalLinkSink
		LinksUnfit = lessfit.GlobalLinkSink

		nn = instantiateNeuralNetwork(fit.topology)

		if #NeuronsFit == #NeuronsUnfit then

			nn.GlobalNeuronSink = NeuronsFit
			nn.GlobalLinkSink = {}

			for l1=1,#LinksFit do
				for l2=1,#LinksUnfit do
					if LinksFit[l1].node1id == LinksUnfit[l2].node1id and LinksFit[l1].node2id == LinksUnfit[l2].node2id then
						ll = instantiateLink(LinksFit[l1].node1id,LinksUnfit[l2].node2id)
						ll.weight = LinksFit[l1].weight
						table.insert(nn.GlobalLinkSink,ll)
					elseif LinksFit[l1].node1id == LinksUnfit[l2].node1id and LinksFit[l1].node2id ~= LinksUnfit[l2].node2id then
						ll = instantiateLink(LinksFit[l1].node1id,LinksUnfit[l2].node2id)
						ll.weight = LinksFit[l1].weight
						table.insert(nn.GlobalLinkSink,ll)
					end
				end
			end

		elseif #NeuronsFit < #NeuronsUnfit then

			for n = #NeuronsFit+1,#NeuronsUnfit do
				table.insert(nn.GlobalNeuronSink,NeuronsUnfit[n])
			end

			for l1=1,#LinksFit do
				for l2=1,#LinksUnfit do
					if LinksFit[l1].node1id == LinksUnfit[l2].node1id and LinksFit[l1].node2id == LinksUnfit[l2].node2id then
						ll = instantiateLink(LinksFit[l1].node1id,LinksUnfit[l2].node2id)
						ll.weight = LinksFit[l1].weight
						table.insert(nn.GlobalLinkSink,ll)
					elseif LinksFit[l1].node1id == LinksUnfit[l2].node1id and LinksFit[l1].node2id ~= LinksUnfit[l2].node2id then
						ll = instantiateLink(LinksFit[l1].node1id,LinksUnfit[l2].node2id)
						ll.weight = (LinksUnfit[l2].weight + LinksFit[l1].weight)/2
						table.insert(nn.GlobalLinkSink,ll)
					end
				end
			end

		elseif #NeuronsFit > #NeuronsUnfit then

			for l1=1,#LinksFit do
				for l2=1,#LinksUnfit do
					if LinksFit[l1].node1id == LinksUnfit[l2].node1id and LinksFit[l1].node2id == LinksUnfit[l2].node2id then
						ll = instantiateLink(LinksFit[l1].node1id,LinksUnfit[l2].node2id)
						ll.weight = (LinksUnfit[l2].weight + LinksFit[l1].weight)/2
						table.insert(nn.GlobalLinkSink,ll)
					elseif LinksFit[l1].node1id == LinksUnfit[l2].node1id and LinksFit[l1].node2id ~= LinksUnfit[l2].node2id then
						ll = instantiateLink(LinksFit[l1].node1id,LinksUnfit[l2].node2id)
						ll.weight = LinksUnfit[l2].weight
						table.insert(nn.GlobalLinkSink,ll)
					end
				end
			end
		end

		if #chosenOnes < nOrganisms then
			table.insert(chosenOnes,nn)
		end

	end

	return chosenOnes

end

