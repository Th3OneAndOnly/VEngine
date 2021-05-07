struct Vector2 {
mut:
	x f32
	y f32
}

fn (v Vector2) str() string {
	return 'Vector2{$v.x, $v.y}'
}

fn (a Vector2) + (b Vector2) Vector2 {
	return Vector2{a.x + b.x, a.y + b.y}
}

fn (a Vector2) - (b Vector2) Vector2 {
	return Vector2{a.x - b.x, a.y - b.y}
}

fn (a Vector2) * (b Vector2) Vector2 {
	return Vector2{a.x * b.x, a.y * b.y}
}

fn (a Vector2) / (b Vector2) Vector2 {
	return Vector2{a.x / b.x, a.y / b.y}
}

fn vec2(v f32) Vector2 {
	return Vector2{v, v}
}
