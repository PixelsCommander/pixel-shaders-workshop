#ifdef GL_ES
precision mediump float;
#endif

precision highp float;
uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_mouse;

float PI = 3.14159;
vec2 center = u_resolution * 0.5;
float radius = min(u_resolution.x, u_resolution.y) * .5;

float circle(vec2 coord, vec2 center, float radius) {
  float distanceToCenter = distance(coord, center);
  return step(distanceToCenter, radius);
}

void main() {
  vec2 coord = vec2(gl_FragCoord);
  float isFilled = circle(coord, center, radius);
  gl_FragColor = vec4(1. - isFilled);
}