// V Code for handling GameObjects and the code representation of what's on screen.
import gg
import gx

interface GameObject {
	queue_draw(ratio f32) Command
	update(delta i64)
}

struct DrawCircle {
	position Vector2
	radius   int
	color    gx.Color
}

fn (d DrawCircle) draw(mut ctx gg.Context) {
	log('drawing circle: $d')
	ctx.draw_circle(d.position.x, d.position.y, d.radius, d.color)
}

struct Circle {
mut:
	position Vector2
	radius   int
	color    gx.Color
	velocity Vector2 = Vector2{0, 0}
}

fn (c Circle) queue_draw(ratio f32) Command {
	return DrawCircle{
		position: (c.position - c.velocity) + (c.velocity * vec2(ratio))
		radius: c.radius
		color: c.color
	}
}

fn (mut c Circle) update(delta i64) {
	log('update circle: (with delta $delta), cur position: ($c.position), new position.y: (${
		c.position.y + f32(0.01 * f32(delta))})')
	c.position.y += f32(0.01 * f32(delta))
}
