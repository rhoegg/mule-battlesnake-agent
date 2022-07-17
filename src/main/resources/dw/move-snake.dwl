%dw 2.0
output application/json
import * from dw::Strategy

var you = payload.you
var board = payload.board

var orientation = orient(you, board)

---
{
	move: orientation[vars.action],
	shout: "Moving $(vars.action)."
}