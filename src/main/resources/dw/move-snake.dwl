%dw 2.0
output application/json
import * from dw::Strategy

var epsilon = 0.01
fun choose(actions) = 
	if (random() < epsilon)
		actions[randomInt(sizeOf(actions))].action
	else
		(actions maxBy $.weight).action

var you = payload.you
var board = payload.board

var orientation = orient(you, board)

var nnObservation = flatten(flatten(observe(you, board)))
var nnOutput = forwardANN(nnObservation, vars.nnState)

var actions = (["forward", "left", "right"] zip nnOutput) map {action: $[0], weight: $[1]}
var choice = choose(actions)
---
{
	move: orientation[choice],
	shout: "Moving $(choice)"
}