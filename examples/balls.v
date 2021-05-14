import gx
import vengine { App, Command, DrawCircle, Vector2, create_app, null_cmd, num2vec }
import math.util as mathu
import rand

// FIXME: repitition
[heap]
struct Ball {
mut:
	app        &App    = 0
	last_state Command = null_cmd()
	position   Vector2
	velocity   Vector2
	radius     int
	color      gx.Color
}

fn (o Ball) queue_draw(ratio f32) &Command {
	// Right now continous makes for odd, regular slow-downs, so I'll stick with discrete.
	mut old_position := o.position - o.velocity // subtracting velocity makes it discrete
	// if state := get_last_state(o) {  // using the previous state makes it continuous (maybe it should be the next state.)
	// 	if state is vengine.DrawCircle {
	// 		old_position = state.position
	// 	}
	// }
	item := &DrawCircle{
		position: old_position.interpolate(o.position, ratio)
		radius: o.radius
		color: o.color
		quality: mathu.imax(mathu.imin(o.radius / 5, 10), 30)
	}
	return item
}

fn (mut o Ball) update(delta f32) {
	if o.position.x <= 0 {
		o.velocity.x = mathu.fabs_32(o.velocity.x)
	} else if o.position.x >= o.app.get_screen_size().x {
		o.velocity.x = -mathu.fabs_32(o.velocity.x)
	}

	if o.position.y <= 0 {
		o.velocity.y = mathu.fabs_32(o.velocity.y)
	} else if o.position.y >= o.app.get_screen_size().y {
		o.velocity.y = -mathu.fabs_32(o.velocity.y)
	}
	o.position += o.velocity * num2vec(delta)
}

[console]
fn main() {
	ratio := Vector2{4, 3}
	scale := 240
	width := int(scale * ratio.x)
	height := int(scale * ratio.y)
	mut app := create_app(
		width: width
		height: height
		title: 'Mouse App'
	)
	for _ in 0 .. 100 {
		mut new_ball := Ball{
			position: Vector2{rand.int_in_range(0, width), rand.int_in_range(0, height)}
			velocity: Vector2{0.5 * rand.f32_in_range(-1.0, 1.0), 0.5 * rand.f32_in_range(-1.0,
				1.0)}
			radius: 10
			color: gx.Color{
				r: byte(rand.int_in_range(0, 255))
				g: byte(rand.int_in_range(0, 255))
				b: byte(rand.int_in_range(0, 255))
			}
		}
		app.add_object(mut new_ball)
	}
	app.begin()
}
