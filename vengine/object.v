module vengine

import gg

interface Command {
	draw(mut ctx gg.Context)
}

interface GameObject {
mut:
	app &App
	position Vector2
	update(delta i64)
	queue_draw(ratio f32) &Command
}
