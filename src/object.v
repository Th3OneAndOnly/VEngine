// V Code for handling GameObjects and the code representation of what's on screen.
import gg

interface Command {
	draw(mut ctx gg.Context)
}

interface GameObject {
mut:
	position Vector2
	update(delta i64)
	queue_draw(ratio f32) &Command
}
