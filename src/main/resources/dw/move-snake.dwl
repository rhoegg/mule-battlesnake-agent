%dw 2.0
import * from dw::core::Arrays
output application/json

var body = payload.you.body
var board = payload.board
var head = body[0] // First body part is always head
var neck = body[1] // Second body part is always neck

var moves = ["up", "down", "left", "right"]

// Step 0: Find my neck location so I don't eat myself
var myNeckLocation = neck match {
	case neck if neck.x < head.x -> "left" //my neck is on the left of my head
	case neck if neck.x > head.x -> "right" //my neck is on the right of my head
	case neck if neck.y < head.y -> "down" //my neck is below my head
	case neck if neck.y > head.y -> "up"	//my neck is above my head
	else -> ''
}

var moveInfo = moves map (move) -> 
	{
		move: move,
		location: 	move match {
			case "up" -> head update { case y at .y -> y + 1 }  
			case "down" -> head update { case y at .y -> y - 1 }
			case "left" -> head update { case x at .x -> x - 1 }
			case "right" -> head update { case x at .x -> x + 1 }
		}
	}

// TODO: Step 1 - Don't hit walls.
// Use information from `board` and `head` to not move beyond the game board.
fun isWall(moveInfo) = 
	moveInfo.location.x < 0 or
	moveInfo.location.y < 0 or
	moveInfo.location.x >= board.width or
	moveInfo.location.y >= board.height

// TODO: Step 2 - Don't hit yourself.
// Use information from `body` to avoid moves that would collide with yourself.
fun collidesWithMyTail(moveInfo) =
	body contains moveInfo.location

// TODO: Step 3 - Don't collide with others.
// Use information from `payload` to prevent your Battlesnake from colliding with others.
fun collidesWithOtherSnake(moveInfo) =
	board.snakes some ($.body contains moveInfo.location)

// TODO: Step 4 - Find food.
// Use information in `payload` to seek out and find food.
// food = board.food


// Find safe moves by eliminating neck location and any other locations computed in above steps
var safeMoves = moveInfo
	filter ( ($.move != myNeckLocation) 
		and ! isWall($) 
		and ! collidesWithMyTail($)
		and ! collidesWithOtherSnake($)
	)
	map $.move

// Next random move from safe moves
var nextMove = log(safeMoves)[log(randomInt(sizeOf(safeMoves)))]

---
{
	move: nextMove,
	shout: "Moving $(nextMove)"
}