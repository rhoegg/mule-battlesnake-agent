import drop, some from dw::core::Arrays
import E from dw::util::Math

fun sigmoid(vector) =
	(vector map (x) -> pow(E, x)) map (ex) -> (ex / (1 + ex))

fun orient(you, board) = do {
	var body = you.body
	var head = body[0] // First body part is always head
	var neck = body[1] // Second body part is always neck
	
	var myNeckLocation = neck match {
		case neck if neck.x < head.x -> "left" //my neck is on the left of my head
		case neck if neck.x > head.x -> "right" //my neck is on the right of my head
		case neck if neck.y < head.y -> "down" //my neck is below my head
		case neck if neck.y > head.y -> "up"	//my neck is above my head
		else -> "none"
	}
	
	var aheadDirection = myNeckLocation match {
		case "left" -> "right"
		case "right" -> "left"
		case "up" -> "down"
		case "down" -> "up"
		else -> "none"
	}
	
	var leftDirection = myNeckLocation match {
		case "left" -> "up"
		case "right" -> "down"
		case "up" -> "right"
		case "down" -> "left"
		else -> "none"
	}
	
	var rightDirection = myNeckLocation match {
		case "left" -> "down"
		case "right" -> "up"
		case "up" -> "left"
		case "down" -> "right"
		else -> "none"
	}
	---
	{
		neck: myNeckLocation,
		forward: aheadDirection,
		left: leftDirection,
		right: rightDirection
	}
}

fun observe(you, board) = do {
	var body = you.body
	var head = body[0] // First body part is always head
	var neck = body[1] // Second body part is always neck
	var orientation = orient(you, board)
	
	fun pointValue(point) = point match {
		// food
		case p if (board.food contains p) -> [1, 0]
		// wall
		case p if ((p.x < 0) or (p.x >= board.width) or (p.y < 0) or (p.y >= board.height)) -> [0, 1]
		// self
		case p if (body contains p) -> [0, 1]
		// enemy body
		case p if (board.snakes some ($.body contains p)) -> [0, 1]
		// open
		else -> [0, 0]
	}

	fun look(direction, distance) = direction match {
		case "left" -> ((head.x - distance) to head.x) map {x: $, y: head.y}
		case "right" -> (head.x to (head.x + distance)) map {x: $, y: head.y}
		case "up" -> (head.y to (head.y + distance)) map {x: head.x, y: $}
		case "down" -> ((head.y - distance) to head.y) map {x: head.x, y: $}
		else -> []
	} map pointValue($)

	var observation = {
		vision: [look(orientation.forward, 5), look(orientation.left, 3), look(orientation.right, 3)],
		facts: {
			health: you.health,
			length: you.length
		}
	}
		
	---	
	observation.vision + [observation.facts.health, observation.facts.length, 1] // 1 = bias
}

fun outOfBounds(you, board) =
	(you.head.x < 0) 
	or (you.head.y < 0) 
	or (you.head.x >= board.width) 
	or (you.head.y >= board.height)

fun collidedWithSelf(you) =
	(you.body drop 1) contains you.head

fun collidedWithHazards(you, board) =
	board.hazards contains you.head

fun collidedWithSnake(you, board) =
	flatten(board.snakes filter ($.id != you.id) map $.body) contains you.head

fun calculateReward(gameState) =
	gameState match {
		case gameState if (gameState.you.health == 0) -> -1
		case gameState if (outOfBounds(gameState.you, gameState.board)) -> -1
		case gameState if (collidedWithSelf(gameState.you)) -> -1
		case gameState if (collidedWithSnake(gameState.you, gameState.board)) -> -1 // counting all head on collisions as a loss FIXME
		else -> 0
	}
	
fun forwardANN(inputs, weights) = do { // add bias
	var inputLayer = sigmoid(inputs)
	var outputL1 = sigmoid(
		weights.layer1 map (nodeL1) -> 
			sum((inputLayer zip nodeL1.weights) map ($[0] * $[1]))
		)
	var outputL2 = sigmoid(
		weights.layer2 map (nodeL2) ->
			sum((outputL1 zip nodeL2.weights) map ($[0] * $[1]))
		)
	---
	{
		inputLayer: inputLayer,
		layer1: outputL1,
		layer2: outputL2,
		finalLayer: 	// no sigmoid for action layer
			weights.actions map (actionNode) ->
				sum((outputL2 zip actionNode.weights) map ($[0] * $[1]))
				
	}
}