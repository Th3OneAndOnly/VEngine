module vengine

import gx
import gg
import math.util as mathu

pub struct DrawCircle {
pub:
	position Vector2
	radius   int
	color    gx.Color
	quality  int
}

pub struct DrawRectangle {
	position Vector2
	width    int
	height   int
	color    gx.Color
}

pub struct DrawPolygon {
	points []f32
	color  gx.Color
}

[heap]
pub struct Circle {
mut:
	app        &App    = 0
	last_state Command = zero_cmd
	position   Vector2
	radius     int
	color      gx.Color
}

[heap]
pub struct Rectangle {
mut:
	app        &App    = 0
	last_state Command = zero_cmd
	position   Vector2
	width      int
	height     int
	color      gx.Color
}

[heap]
pub struct Polygon {
	relative bool = true
mut:
	app        &App    = 0
	last_state Command = zero_cmd
	position   Vector2
	points     []Vector2
	color      gx.Color
}

fn (d DrawCircle) draw(mut ctx gg.Context) {
	ctx.draw_circle_with_segments(d.position.x, d.position.y, d.radius, d.quality, d.color)
}

fn (d DrawRectangle) draw(mut ctx gg.Context) {
	ctx.draw_rect(d.position.x, d.position.y, d.width, d.height, d.color)
}

fn (d DrawPolygon) draw(mut ctx gg.Context) {
	ctx.draw_convex_poly(d.points, d.color)
}

fn (o Circle) queue_draw(ratio f32) &Command {
	return &DrawCircle{
		position: o.position
		radius: o.radius
		color: o.color
		quality: mathu.imax(mathu.imin(o.radius / 5, 10), 30)
		// Quality is between 10 and 30, smaller circles have smaller quality.
		// i.e circles with radii between 50-150
	}
}

fn (mut o Circle) update(delta f32) {
}

fn (o Rectangle) queue_draw(ratio f32) &Command {
	return &DrawRectangle{
		position: o.position
		width: o.width
		height: o.height
		color: o.color
	}
}

fn (mut o Rectangle) update(delta f32) {
}

fn (o Polygon) queue_draw(ratio f32) &Command {
	mut points := []f32{cap: 2 * o.points.len}
	offset := if o.relative { o.position } else { Vector2{0, 0} }
	for vec in o.points {
		points << [vec.x + offset.x, vec.y + offset.y]
	}
	return &DrawPolygon{
		points: points
		color: o.color
	}
}

fn (mut o Polygon) update(delta f32) {
}
