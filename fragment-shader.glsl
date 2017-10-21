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

bool isAngleBetween(float target, float angle1, float angle2) {
  float startAngle = min(angle1, angle2);
  float endAngle = max(angle1, angle2);

  if (endAngle - startAngle < 0.1) {
    return false;
  }

  target = mod((360. + (mod(target, 360.))), 360.);
  startAngle = mod((3600000. + startAngle), 360.);
  endAngle = mod((3600000. + endAngle), 360.);

  if (startAngle < endAngle) return startAngle <= target && target <= endAngle;
  return startAngle <= target || target <= endAngle;
}

float sector(vec2 coord, vec2 center, float startAngle, float endAngle) {
  vec2 uvToCenter = coord - center;
  float angle = degrees(atan(uvToCenter.y, uvToCenter.x));
  if (isAngleBetween(angle, startAngle, endAngle)) {
    return 1.0;
  } else {
    return 0.;
  }
}

void main() {
  vec2 coord = vec2(gl_FragCoord);
  float isFilled = circle(coord, center, radius) * sector(coord, center, 0., 75.);
  gl_FragColor = vec4(1. - isFilled);
}