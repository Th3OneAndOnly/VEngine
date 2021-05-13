module vengine

import gg
import gx
import time

const (
	zero_cmd      = ZeroCommand{}
	// Milliseconds per update call. Doesn't exactly mean the update function is called this often, but it is called AT MOST this often, multiple times before rendering. Should obviously be larger than max_frame_wait_time
	ms_per_update = 60
	// Debug. 'all' is used for everything, so if debug is on it will always run. Anything else is complier flags. This is so that when I/someone is working on AI or smth I don't need to see the gameloop debug messages.
	debug_tags    = init_list()
)

[heap]
pub struct App {
mut:
	gg          &gg.Context = 0
	cmds        []Command
	last_frame  []Command
	counter     int
	mouse_pos   Vector2
	screen_size Vector2
	objects     []GameObject
}

pub struct AppConfig {
	width     int
	height    int
	title     string
	bg_color  gx.Color = gx.rgb(120, 120, 120)
	font_size int      = 32
}

pub fn (a &App) get_mouse_pos() Vector2 {
	return a.mouse_pos
}

pub fn (a &App) get_screen_size() Vector2 {
	return a.screen_size
}

pub fn (mut a App) add_object(mut obj GameObject) {
	obj.app = &a
	a.objects << *obj // Thanks SO MUCH miccah. Can't believe it was this simple.
}

pub fn (mut app App) begin() {
	go app.loop()
	app.gg.run()
}

pub fn create_app(cfg AppConfig) &App {
	mut app := &App{
		screen_size: Vector2{cfg.width, cfg.height}
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

fn (mut a App) render(ratio f32) {
	log('begin render: $ratio', 'gameloop')
	a.cmds = []
	for mut object in a.objects {
		result := object.queue_draw(ratio)
		log('draw object $result', 'gameloop')
		a.cmds << *result
		object.last_state = *result
	}
}

fn (mut a App) update(delta f32) {
	for mut object in a.objects {
		object.update(delta)
	}
}

// Simple game loop. I've done, like, 3 of these in my time. Same as any other time I've done it (mostly) and works just as well.
fn (mut a App) loop() {
	mut start := f32(0)
	mut elapsed := f32(0)
	mut lag := f32(0)
	for {
		start = f32(time.ticks())
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
		elapsed = f32(time.ticks()) - start
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

	if app.cmds.len == 0 && app.last_frame.len > 0 {
		for cmd in app.last_frame {
			cmd.draw(mut app.gg)
		}
	}
	// Avoid blank frames at all costs

	app.gg.end()
	app.last_frame = app.cmds
}

[console; if debug]
fn log(msg string, tag string) {
	if tag in vengine.debug_tags {
		println('[VENGINE DEBUG]: $msg')
	}
}

fn init_list() []string {
	$if debug {
		mut list := ['all']
		$if gameloop ? {
			list << 'gameloop'
		}
		return list
	} $else {
		return []string{}
	}
}
