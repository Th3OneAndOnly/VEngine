module vengine

import gg

pub interface Command {
	draw(mut ctx gg.Context)
}

interface GameObject {
mut:
	app &App
	last_state Command
	position Vector2
	update(delta f32)
	queue_draw(ratio f32) &Command
}

struct ZeroCommand {
}

fn (z ZeroCommand) draw(mut ctx gg.Context) {}

pub fn get_last_state(g GameObject) ?Command {
	if g.last_state is ZeroCommand {
		return none
	}
	return g.last_state
}

pub fn null_cmd() ZeroCommand {
	return zero_cmd
}
