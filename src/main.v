// Our entrypoint into the program.
import gg
import gx
import time

const (
	// Max amount of time in milliseconds we should wait for commands to draw. Also how often we render. Should be low for smoothness, high to prevent hanging and tearing.
	max_frame_wait_time = 50

	// Milliseconds per update call. Doesn't exactly mean the update function is called this often, but it is called AT MOST this often, multiple times before rendering. Should obviously be larger than max_frame_wait_time
	ms_per_update       = 60

	// Rate we sleep. According to this number of cycles we sleep a small bit to alleivate the thread and the CPU. We also sleep when we are running really fast to allow for chances to update.
	sleep_rate          = 40
)

struct App {
mut: // Simple container, no smartness here.
	gg      &gg.Context
	fm      chan int
	ch      chan &Command
	counter int
	objects []GameObject
}

[if debug]
fn log(msg string) {
	println('DEBUG: $msg')
}

// The entry point of our operations. A small note for windows users: if you want stuff to print out while using gg, attach [console] to the top of your main!
[console]
fn main() {
	draw := chan &Command{cap: 1000} // The channel we send drawing commands to.
	frames := chan int{} // The channel we update the render frame counter.
	mut app := &App{
		gg: 0
		fm: frames
		ch: draw
	}
	app.gg = gg.new_context(
		width: 600
		height: 400
		font_size: 32
		window_title: 'Test Engine'
		bg_color: gx.rgb(120, 120, 120)
		frame_fn: frame
		user_data: app
	)

	init(mut app)

	go app.loop()

	app.gg.run()
}

fn (mut a App) render(ratio f32) {
	for mut object in a.objects {
		a.ch <- object.queue_draw(ratio)
		log('render object $object')
	}
}

fn (mut a App) update(delta i64) {
	for mut object in a.objects {
		object.update(delta)
		log('update object $object')
	}
}

fn init(mut app App) {
}

// Simple game loop. I've done, like, 3 of these in my time. Same as any other time I've done it (mostly) and works just as well.
fn (mut a App) loop() {
	mut start := i64(0)
	mut elapsed := i64(0)
	mut lag := i64(0)
	for {
		log('elapsed : $elapsed')
		start = time.ticks()
		lag += elapsed

		for lag >= ms_per_update {
			a.update(elapsed)
			lag -= ms_per_update
		}
		// If we are rendering REALLY fast this means that our either our update or render functions are running really fast. This is common in early development and it causes bad problems down the road, since we'll never actually update again and since we don't update we loop too fast and it's a viscious cycle. This will break it.
		if elapsed < 5 {
			time.sleep(ms_per_update * time.millisecond)
		}

		a.render(f32(lag / ms_per_update))
		elapsed = time.ticks() - start
	}
}

fn frame(mut app App) {
	app.gg.begin()
	for { // Keep looping through the channel until no more commands exist.
		select {
			cmd := <-app.ch {
				cmd.draw(mut app.gg)
			}
			> max_frame_wait_time * time.millisecond {
				break
			}
		}
	}

	// To let everyone else know we finished drawing a new frame. This happens no matter whether ~~anyone is consuming them~~yeah turns out channels need somebody on the other end -- who knew?
	app.fm.try_push(app.counter) // If it fails I don't care. It's just gonna miss a single frame.
	app.counter++
	app.gg.end()
}
