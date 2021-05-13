import gx
import vengine as ve
import math.util as mathu

// FIXME: What the heck do I need all this repitition for struct embeds exist for a reason
[heap]
struct CircleFollowMouse {
mut:
	app      &ve.App = 0
	position ve.Vector2
	radius   int
	color    gx.Color
}

fn (o &CircleFollowMouse) queue_draw(ratio f32) &ve.Command {
	dump(o.position)
	item := &ve.DrawCircle{ // TODO: Get rid of this code-repitition
		position: o.position
		radius: o.radius
		color: o.color
		quality: mathu.imax(mathu.imin(o.radius / 5, 10), 30)
	}
	dump(item.position)
	// assert item.position == o.position
	return item
}

fn (mut o CircleFollowMouse) update(delta i64) {
	dump(o.app.get_mouse_pos())
	o.position = o.app.get_mouse_pos()
	dump(o.position)
	dump(o.app.get_mouse_pos())
}

[console]
fn main() {
	println('Working')
	ratio := ve.Vector2{4, 3}
	scale := 120
	mut app := ve.create_app(
		width: int(scale * ratio.x)
		height: int(scale * ratio.y)
		title: 'Mouse App'
	)
	app.add_object(mut CircleFollowMouse{
		position: ve.Vector2{0, 0}
		radius: 20
		color: gx.blue
	})
	app.begin()
}
