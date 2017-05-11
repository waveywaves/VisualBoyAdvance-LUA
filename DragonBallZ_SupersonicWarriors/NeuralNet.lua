math.randomseed(os.time())
--Using seed as 12 for reproducible results and debugging

function print_r ( t )
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end


function sigmoid(x)
	if x then
		return 2/(1+math.exp(-4.9*x))-1
	end
end

table.reduce = function (list, fn)
    local acc
    for k, v in ipairs(list) do
        if 1 == k then
            acc = v
        else
            acc = fn(acc, v)
        end
    end
    return acc
end


--[[

Basic outline :-

Create Pool
Instantiate ALL GENERATIONS OF PLAYERS
Instantiate FITNESS
	Get FITNESSes after playing the game
Instantiate SELECTION
	Top fitness indices are selected
Instantiate REPLICATION for NEXT GENERATIONS
	TOPOLOGY and GENES are extracted from the FITTEST GENOME
	after replication a new GENERATION is instantiated and progeny is added


Neural Network Basic Outline :-

Get the topology
If genes do not exist
	Set layer Dimensions
	Instantiate Weight and Bias Matrices
	Give Weight a random normal value and bias as 1
If genes exist
	Genes are the values for Weights and biases
	if the weight is >0 then link exists
		if the link exists then by probability it is checked for mutation
		connection weight mutation chance is 0.8
			if yes then it is also checked for uniform mutation or random mutation
			which is 0.9 prob vs 0.1 prob
		if the link does not exists
			if the layer is not an output layer
				uniform chance for new node is taken into consideration which is 0.03
				weight is given as a uniform random value


Progress :-

NeuralNet generator based on the given topology
	Instantiates Neurons --
	Instantiate Links --
	Mutation
		Link Mutation
			CreateLink if it does not exist --
			Mutate Link Weights --
			Mutate Link Structure --
				Add Neuron between two existing ones and Split Link --
				Add Random Link Between two random Neurons --

		Neuron Mutation
			Mutate Neuron Bias --

LinkSink Checker
	Links in the same Layer --
	Node alternation --

NeuralNet Forward Pass --
NeuralNet Fitness Evaluation --

NeuralNet Replication --
	Cloning --
	Crossover (need to create matingRing function and interSpecies Checkers for generation 2 and above) --

Culling Species

Speciation
	Step 1: Mutate Genome
	Step 2: Check Compatibility with current species (Excess or Disjoint genes)
	Step 3: Reassign to other species if compatible or Create an entirely New Species
	Step 4: Instantiate Population Control
	Step 5: Cull Species if their fitness is among the lowest for 10 generations or they have very less population

Pool Generation:-
	Instantiate First Generation of Genomes
		Create 50 species of Genomes
			Create 100 Genomes in each Species

		Run the Fitnss Evaluation for each Species and decide the species Champion
			25% of the overall next gen population will be the clones of this Champion
			75% of the overall next gen population will be crossovers between random genomes belonging to the fittest category
			Let 0.3% be the probability rate of inter species crossover
			Population Control

		Add these Species to the Next Generation of babies for max fitness


Instantiation and Mutation --
Pool Generation --
Speciation and Replication --
Acquiring Data and Evaluation --

]]


function instantiateNeuralNetwork(topology) --genes are the neurons present in a NN and their relationship

	local NeuralNetwork = {}
	NeuralNetwork.GlobalNeuronSink = {}
	NeuralNetwork.GlobalLinkSink = {}


	NeuralNetwork.topology        = topology
	NeuralNetwork.inputLayerSize  = topology[1]
	NeuralNetwork.outputLayerSize = topology[#topology]
	NeuralNetwork.fitness = nil

	NeuralNetwork.inputLayer = {}
	for i=1,NeuralNetwork.inputLayerSize do
		table.insert(NeuralNetwork.inputLayer,instantiateNeuron(NeuralNetwork))
	end

	NeuralNetwork.outputLayer = {}
	for i=1,NeuralNetwork.outputLayerSize do

		table.insert(NeuralNetwork.outputLayer,instantiateNeuron(NeuralNetwork))
	end

	NeuralNetwork.hiddenLayer = {}
	if #topology > 2 then
		NeuralNetwork.hiddenLayers = {}
		for i=2,#topology-1 do
			NeuralNetwork.hiddenLayers[i-1] = {}
			NeuralNetwork.hiddenLayers[i-1].hiddenLayerSize = topology[i]
			NeuralNetwork.hiddenLayers[i-1].hiddenLayer = {}
			for j=1,topology[i] do
				NeuralNetwork.hiddenLayers[i-1].hiddenLayer[j] = {}
				table.insert(NeuralNetwork.hiddenLayers[i-1].hiddenLayer[j],instantiateNeuron(NeuralNetwork))
			end
		end
	else

		NeuralNetwork.hiddenLayer = {}

	end
--[[
	nn = NeuralNetwork

	for i=1,10 do
	nn.GlobalLinkSink   = mutateNeuralNetworkLinks(nn)
	nn.GlobalLinkSink   = mutateNeuralNetworkLinkWeights(nn)
	nn.GlobalLinkSink = mutateNeuralNetworkLinkStructure(nn)
	--nn.GlobalNeuronSink = mutateNeuralNetworkNeuronBias(nn)
	nn.GlobalLinkSink = LinkSinkChecker(nn)
	end

	NeuralNetwork = nn
]]
	NeuralNetwork.LinkSink = LinkSinkChecker(NeuralNetwork)
--[[
	local INPUTS = {}

	  INPUTS.y = -24.126984127
	  INPUTS.x = -2.47619047619
	  INPUTS.KIEnemy = 54
	  INPUTS.KIPlayer = 50
	  INPUTS.HPEnemy = 328
	  INPUTS.HPPlayer = 133

	NeuralNetwork = NeuralNetworkForwardPass(NeuralNetwork,INPUTS)
--]]
	return NeuralNetwork

end

function instantiateNeuron(NeuralNetwork)


	local Neuron = {}
	Neuron.id = #NeuralNetwork.GlobalNeuronSink +1
	Neuron.sum = 0
	Neuron.activation = 0
	Neuron.bias = 1
	Neuron.incoming = {}

	table.insert(NeuralNetwork.GlobalNeuronSink,Neuron)

	return Neuron.id
end

function instantiateLink(node1id,node2id)

	local Link = {}
	Link.node1id = node1id
	Link.node2id = node2id
	Link.weight = 1
	Link.state = true

	return Link
end

function mutateNeuralNetworkLinks(NeuralNetwork)

	local LinkSink = NeuralNetwork.GlobalLinkSink
	local newLinkProbability = 0.5



		math.random()
		node1id = math.random(1,#NeuralNetwork.inputLayer)
		node2id = math.random(NeuralNetwork.outputLayer[1],NeuralNetwork.outputLayer[#NeuralNetwork.outputLayer])
			math.random()
			if math.random() < newLinkProbability then
				li = instantiateLink(node1id,node2id)
				table.insert(LinkSink,li)
			end

	local newLinkSink = {}

	for i=1,#LinkSink do
		local link = LinkSink[i]
		deny = 0
		for j=1,#newLinkSink do
			if newLinkSink[j] == link then
				deny = deny + 1
			end
		end
		if deny < 1 then
			table.insert(newLinkSink,link)
		end
	end

	return newLinkSink

end

function mutateNeuralNetworkNeuronBias(NeuralNetwork)
	local NeuronSink = NeuralNetwork.GlobalNeuronSink
	local biasWeightMutationProbability = 0.2

	for i=1,#NeuronSink do
		neuron = NeuronSink[i]
		if math.random() < biasWeightMutationProbability then
			math.random()
			neuron.bias = neuron.bias + math.random()
		end
	end

	return NeuronSink

end

function mutateNeuralNetworkLinkWeights(NeuralNetwork)
	local LinkSink = NeuralNetwork.GlobalLinkSink
	local linkWeightMutationProbability = 0.5

	for i=1,#LinkSink do
		link = LinkSink[i]
		if math.random() > linkWeightMutationProbability then
			math.random()
			link.weight = (link.weight + math.random()/10000)
			math.random()
			if math.random()>0.5 then
				link.weight = link.weight/2
			end
		end
	end

	return LinkSink

end

function mutateNeuralNetworkLinkStructure(NeuralNetwork)
	local LinkSink = NeuralNetwork.GlobalLinkSink
	local NeuronSink = NeuralNetwork.GlobalNeuronSink
	local linkStructureMutationProbability = 0.1
	local linkStructureNewNeuronProbability = 0.7
	local linkStructureLinkWithHiddenProbability = 0.3


	for i=1,#LinkSink do
		link=LinkSink[i]
		n1 = nil
		n2 = nil
		n3 = nil
		if math.random() > linkStructureMutationProbability then
			p = math.random()
			if p>linkStructureNewNeuronProbability and p<1 then
				math.random()

				n1 = link.node1id
				n3 = link.node2id
				link.state = false

				n2 = instantiateNeuron(NeuralNetwork)


				newLink1 = instantiateLink(n2,n3)
				newLink2 = instantiateLink(n1,n2)

				newLink1.state = true
				newLink2.state = true

				table.insert(LinkSink,newLink1)
				table.insert(LinkSink,newLink2)
				table.insert(NeuralNetwork.hiddenLayer, n2)

			elseif p<linkStructureLinkWithHiddenProbability and  p>0 then

				math.random()
				randomNodeid = math.random(1,#NeuronSink)
				InpExists = existsNodeInLayer(randomNodeid,NeuralNetwork.inputLayer)
				OutExists = existsNodeInLayer(randomNodeid,NeuralNetwork.outputLayer)

				if NeuralNetwork.hiddenLayers then
					for h=1,#NeuralNetwork.hiddenLayers do
						HidExists = existsNodeInLayer(randomNodeid,NeuralNetwork.hiddenLayers[h])
						if HidExists then
							hidCount = hidCount + 1
							hid = h
						end
					end

				elseif NeuralNetwork.hiddenLayer then
					HidExists = existsNodeInLayer(randomNodeid,NeuralNetwork.hiddenLayer)
				end



				if InpExists then
					math.random()

					node1id = randomNodeid
					node2id = math.random(NeuralNetwork.inputLayer[#NeuralNetwork.inputLayer]+1,#NeuralNetwork.GlobalNeuronSink)

					newLink = instantiateLink(node1id,node2id)
					table.insert(LinkSink,newLink)

				elseif OutExists then
					math.random()

					node2id = randomNodeid
					if NeuralNetwork.hiddenLayer or NeuralNetwork.hiddenLayers then
						choi1 = math.random(1,NeuralNetwork.inputLayerSize)
						choi2 = math.random(NeuralNetwork.outputLayerSize + 1, #NeuralNetwork.GlobalNeuronSink)

						if math.random(1,10)/10 > 0.5 then
							node1id = choi2
						else
							node1id = choi1
						end
					else
						node1id = math.random(1,NeuralNetwork.inputLayerSize)
					end

					newLink = instantiateLink(node1id,node2id)

					table.insert(LinkSink,newLink)


				elseif HidExists then
					math.random()

					if NeuralNetwork.hiddenLayer then
						math.random()

						if math.random(1,10)/10 > 0.5 then
							node2id = math.random(1,NeuralNetwork.inputLayerSize)
							node1id = randomNodeid

							newLink = instantiateLink(node1id,node2id)

							table.insert(LinkSink,newLink)

						else

							node1id = math.random(NeuralNetwork.outputLayer[1],NeuralNetwork.outputLayer[#NeuralNetwork.outputLayer])
							node2id = randomNodeid

							newLink = instantiateLink(node1id,node2id)

							table.insert(LinkSink,newLink)

						end
					end
				end
			end
		end
	end

	return LinkSink

end

function existsNodeInLayer(node,Layer)
	local exists = 0

	for i=1,#Layer do
		if Layer[i] == node then
			exists = exists + 1
		end
	end

	if exists > 0 then
		return true

	else
		return false
	end
end


function LinkSinkChecker(NeuralNetwork)
	LinkSink = NeuralNetwork.GlobalLinkSink

	for i=1,#LinkSink do
		--check which layer each of the nodes are in
		if LinkSink[i] then
			InpExists = existsNodeInLayer(LinkSink[i].node1id,NeuralNetwork.inputLayer)
			OutExists = existsNodeInLayer(LinkSink[i].node1id,NeuralNetwork.outputLayer)

			if NeuralNetwork.hiddenLayer then
				HidExists = existsNodeInLayer(LinkSink[i].node1id,NeuralNetwork.hiddenLayer)
			elseif NeuralNetwork.hiddenLayers then
				for h=1,#NeuralNetwork.hiddenLayers do
				HidExists = existsNodeInLayer(LinkSink[i].node1id,NeuralNetwork.hiddenLayers[h])
					if HidExists then
						hidCount = hidCount + 1
						hid = h
					end
				end
			end


			if InpExists then
				ex = existsNodeInLayer(LinkSink[i].node2id,NeuralNetwork.inputLayer)

			elseif OutExists then
				ex = existsNodeInLayer(LinkSink[i].node2id,NeuralNetwork.outputLayer)

			end

			if ex == true then
				table.remove(LinkSink,i)
			end

		end

		if LinkSink[i] then

			if existsNodeInLayer(LinkSink[i].node1id,NeuralNetwork.outputLayer) then

				tempnode1 = LinkSink[i].node1id
				tempnode2 = LinkSink[i].node2id

				LinkSink[i].node1id = tempnode2
				LinkSink[i].node2id = tempnode1

			elseif existsNodeInLayer(LinkSink[i].node2id,NeuralNetwork.inputLayer) then

				tempnode1 = LinkSink[i].node1id
				tempnode2 = LinkSink[i].node2id

				LinkSink[i].node1id = tempnode2
				LinkSink[i].node2id = tempnode1

			end
		end


	end

	table.sort(LinkSink, function(a, b) return b.node2id > a.node2id end)

	return LinkSink
end

function NeuralNetworkForwardPass(NeuralNetwork,INPUTrecords)

	for nnl=1,#NeuralNetwork.GlobalNeuronSink do
		NeuralNetwork.GlobalNeuronSink[nnl].incoming = {}
	end
--[[

	local Neuron = {}
	Neuron.id = #NeuralNetwork.GlobalNeuronSink +1
	Neuron.sum = 0 -- weighted sum of incoming values calculated here
	Neuron.bias = 1
	Neuron.incoming = {} -- Inputs recorded as weighted inputs

	local Link = {}
	Link.node1id = node1id
	Link.node2id = node2id
	Link.weight = 1
	Link.state = true

	]]

	--NeuralNetwork.GlobalLinkSink
	--NeuralNetwork.GlobalNeuronSink
	--NeuralNetwork.InputLayer


	INPUTS = {}

	sumOfAllInputs = INPUTrecords.x + INPUTrecords.y + INPUTrecords.HPPlayer +INPUTrecords.HPEnemy +INPUTrecords.KIPlayer + INPUTrecords.KIEnemy


	if INPUTrecords.x then
		table.insert(INPUTS,INPUTrecords.x/sumOfAllInputs)
	else
		table.insert(INPUTS,0)
	end

	if INPUTrecords.y then
		table.insert(INPUTS,INPUTrecords.y/sumOfAllInputs)
	else
		table.insert(INPUTS,0)
	end

	if INPUTrecords.HPPlayer then
		table.insert(INPUTS,INPUTrecords.HPPlayer/sumOfAllInputs)
	else
		table.insert(INPUTS,0)
	end

	if INPUTrecords.HPEnemy then
		table.insert(INPUTS,INPUTrecords.HPEnemy/sumOfAllInputs)
	else
		table.insert(INPUTS,0)
	end

	if INPUTrecords.KIPlayer then
		table.insert(INPUTS,INPUTrecords.KIPlayer/sumOfAllInputs)
	else
		table.insert(INPUTS,0)
	end

	if INPUTrecords.KIEnemy then
		table.insert(INPUTS,INPUTrecords.KIEnemy/sumOfAllInputs)
	else
		table.insert(INPUTS,0)
	end

	inputSum = table.reduce(
		INPUTS,
		function (a, b)
			return a + b
		end
		)

	for i=1,NeuralNetwork.inputLayerSize do --initializing inputs
		table.insert(NeuralNetwork.GlobalNeuronSink[i].incoming,INPUTS[i])

		if sumOfIncoming == nil then
			sumOfIncoming = 0
		end

		for val=1,#NeuralNetwork.GlobalNeuronSink[i].incoming do
			sumOfIncoming = sumOfIncoming + NeuralNetwork.GlobalNeuronSink[i].incoming[val]
		end

		NeuralNetwork.GlobalNeuronSink[i].sum = sumOfIncoming
	end

	local previousNeuronIndex = nil
	local currentNeuronIndex = nil


	for i=1,#NeuralNetwork.GlobalLinkSink do

		link = NeuralNetwork.GlobalLinkSink[i]
		oneID = link.node1id
		twoID = link.node2id

		if i == 1 then
			previousNeuronIndex = link.node2id
			currentNeuronIndex = link.node2id
		elseif i>1 then
			currentNeuronIndex = link.node2id
		end




		if link.state then

			if currentNeuronIndex > previousNeuronIndex then
				sumOfIncoming = table.reduce(	NeuralNetwork.GlobalNeuronSink[previousNeuronIndex].incoming,
												function (a, b)
													return a + b
												end
												)

				NeuralNetwork.GlobalNeuronSink[previousNeuronIndex].sum = sumOfIncoming
				if existsNodeInLayer(NeuralNetwork.GlobalNeuronSink[previousNeuronIndex].id,NeuralNetwork.inputLayer) == false then
					NeuralNetwork.GlobalNeuronSink[previousNeuronIndex].activation = sigmoid((sumOfIncoming))
				else
					NeuralNetwork.GlobalNeuronSink[previousNeuronIndex].activation = (sumOfIncoming)
				end
				weightedValue = link.weight*NeuralNetwork.GlobalNeuronSink[oneID].sum
				sigmoidLedActivation = sigmoid(weightedValue)
				NeuralNetwork.GlobalNeuronSink[oneID].activation = sigmoidLedActivation
				table.insert(NeuralNetwork.GlobalNeuronSink[twoID].incoming,link.weight*NeuralNetwork.GlobalNeuronSink[oneID].activation)
			elseif currentNeuronIndex == previousNeuronIndex then
				table.insert(NeuralNetwork.GlobalNeuronSink[twoID].incoming,link.weight*NeuralNetwork.GlobalNeuronSink[oneID].activation)
			end
		end
		previousNeuronIndex = link.node2id
	end
	return NeuralNetwork
end

function extractOutputs(passedNeuralNetwork)

	local OUTPUTS = {}

	for i=1,#passedNeuralNetwork.outputLayer do

		currentNeuronIndex = passedNeuralNetwork.outputLayer[i]
		currentNeuron = passedNeuralNetwork.GlobalNeuronSink[currentNeuronIndex]

		table.insert(OUTPUTS, currentNeuron.activation)

	end

	return OUTPUTS

end

function FitnessFunction(UserHP,KITable,EnemyHP)

	fitness = 0
	AverageUserKI = 0

	local sum = 0
	for i=1,#KITable do
		sum = sum + KITable[i]
	end

	AverageUserKI = sum/#KITable
	fitness = (UserHP - EnemyHP) + (AverageUserKI/2)

	return fitness

end

--[[
nn = instantiateNeuralNetwork({6,8})

print_r(nn.GlobalNeuronSink)

]]
