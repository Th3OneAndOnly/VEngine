module vengine

import gg
import gx
import time

const (
	// Max amount of time in milliseconds we should wait for commands to draw. Also how often we render. Should be low for smoothness, high to prevent hanging and tearing.
	max_frame_wait_time = 50

	// Milliseconds per update call. Doesn't exactly mean the update function is called this often, but it is called AT MOST this often, multiple times before rendering. Should obviously be larger than max_frame_wait_time
	ms_per_update       = 60
)

[heap]
struct App {
mut: // Simple container, no smartness here.
	gg        &gg.Context = 0
	fm        chan int
	cmds      []Command
	counter   int
	mouse_pos Vector2
	objects   []GameObject
}

pub fn (mut a App) add_object(mut obj GameObject) {
	obj.app = &a
	a.objects << obj
}

pub fn (a &App) get_mouse_pos() Vector2 {
	return a.mouse_pos
}

[if debug]
fn log(msg string) {
	println('[VENGINE DEBUG]: $msg')
}

pub struct AppConfig {
	width     int
	height    int
	title     string
	bg_color  gx.Color = gx.rgb(120, 120, 120)
	font_size int      = 32
}

pub fn create_app(cfg AppConfig) &App {
	frames := chan int{} // The channel we update the render frame counter.
	mut app := &App{
		fm: frames
	}
	app.gg = gg.new_context(
		width: cfg.width
		height: cfg.height
		font_size: cfg.font_size
		window_title: cfg.title
		bg_color: cfg.bg_color
		frame_fn: frame
		event_fn: event
		user_data: app
	)
	return app
}

pub fn (mut app App) begin() {
	go app.loop()

	// go fn (mut app App) {
	// 	for {
	// 		dump(app.mouse_pos)
	// 	}
	// }(mut app)

	app.gg.run()
}

fn (mut a App) render(ratio f32) {
	a.cmds = []
	for mut object in a.objects {
		println('We render object')
		$if debug {
			result := dump(object.queue_draw(ratio))
			// log('draw object $result')
			a.cmds << result
		} $else {
			a.cmds << object.queue_draw(ratio)
		}
	}
}

fn (mut a App) update(delta i64) {
	for mut object in a.objects {
		println('update')
		object.update(delta)
	}
}

// Simple game loop. I've done, like, 3 of these in my time. Same as any other time I've done it (mostly) and works just as well.
fn (mut a App) loop() {
	mut start := i64(0)
	mut elapsed := i64(0)
	mut lag := i64(0)
	for {
		start = time.ticks()
		lag += elapsed

		for lag >= vengine.ms_per_update {
			a.update(elapsed)
			lag -= vengine.ms_per_update
		}

		// If we are rendering REALLY fast this means that our either our update or render functions are running really fast. This is common in early development and it causes bad problems down the road, since we'll never actually update again and since we don't update we loop too fast and it's a viscious cycle. This will break it.
		if elapsed < 5 {
			time.sleep(vengine.ms_per_update * time.millisecond)
		}

		a.render(f32(lag / vengine.ms_per_update))
		elapsed = time.ticks() - start
	}
}

fn event(e &gg.Event, mut app App) {
	match e.typ {
		.mouse_move {
			app.mouse_pos = Vector2{e.mouse_x, e.mouse_y}
		}
		else {}
	}
}

fn frame(mut app App) {
	app.gg.begin()
	for cmd in app.cmds {
		cmd.draw(mut app.gg)
	}

	app.cmds = []
	// for { // Keep looping through the channel until no more commands exist.
	// 	select {
	// 		cmd := <-app.ch {
	// 			cmd.draw(mut app.gg)
	// 		}
	// 		> vengine.max_frame_wait_time * time.millisecond {
	// 			break
	// 		}
	// 	}
	// }

	// To let everyone else know we finished drawing a new frame. This happens no matter whether ~~anyone is consuming them~~yeah turns out channels need somebody on the other end -- who knew?
	app.fm.try_push(app.counter) // If it fails I don't care. It's just gonna miss a single frame.
	app.counter++
	app.gg.end()
}
