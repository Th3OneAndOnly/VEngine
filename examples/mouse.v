import gx
import vengine { App, Command, DrawCircle, Vector2, create_app, get_last_state, null_cmd }
import math.util as mathu

// FIXME: What the heck do I need all this repitition for struct embeds exist for a reason
[heap]
struct CircleFollowMouse {
mut:
	app        &App    = 0
	last_state Command = null_cmd()
	position   Vector2
	radius     int
	color      gx.Color
}

fn (o CircleFollowMouse) queue_draw(ratio f32) &Command {
	mut old_position := o.position
	if state := get_last_state(o) {
		if state is vengine.DrawCircle {
			old_position = state.position
		}
	}
	item := &DrawCircle{ // TODO: Get rid of this code-repitition
		position: old_position.interpolate(o.position, ratio)
		radius: o.radius
		color: o.color
		quality: mathu.imax(mathu.imin(o.radius / 5, 10), 30)
	}
	return item
}

fn (mut o CircleFollowMouse) update(delta f32) {
	o.position = o.app.get_mouse_pos()
}

[console]
fn main() {
	ratio := Vector2{4, 3}
	scale := 120
	mut app := create_app(
		width: int(scale * ratio.x)
		height: int(scale * ratio.y)
		title: 'Mouse App'
	)
	app.add_object(mut CircleFollowMouse{
		position: Vector2{0, 0}
		radius: 20
		color: gx.blue
	})
	app.begin()
}
