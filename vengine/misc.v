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

pub fn (v Vector2) str() string {
	return 'Vector2{$v.x, $v.y}'
}

pub fn (v Vector2) interpolate(other Vector2, amount f32) Vector2 {
	return Vector2{((other.x - v.x) * amount) + v.x, ((other.y - v.y) * amount) + v.y}
}

pub fn num2vec(v f32) Vector2 {
	return Vector2{v, v}
}
