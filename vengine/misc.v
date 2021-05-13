module vengine

pub struct Vector2 {
pub mut:
	x f32
	y f32
}

pub fn (a Vector2) + (b Vector2) Vector2 {
	return Vector2{a.x + b.x, a.y + b.y}
}

pub fn (a Vector2) - (b Vector2) Vector2 {
	return Vector2{a.x - b.x, a.y - b.y}
}

pub fn (a Vector2) * (b Vector2) Vector2 {
	return Vector2{a.x * b.x, a.y * b.y}
}

pub fn (a Vector2) / (b Vector2) Vector2 {
	return Vector2{a.x / b.x, a.y / b.y}
}

pub fn vec2(v f32) Vector2 {
	return Vector2{v, v}
}

pub fn (v Vector2) str() string {
	return 'Vector2{$v.x, $v.y}'
}
