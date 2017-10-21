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
  return smoothstep(distanceToCenter - 2., distanceToCenter, radius);
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

float arc(vec2 uv, vec2 center, float startAngle, float endAngle, float innerRadius, float outerRadius) {
  float result = 0.0;
  result = sector(uv, center, startAngle, endAngle) * circle(uv, center, outerRadius) * (1.0 - circle(uv, center, innerRadius));
  return result;
}

vec4 rgb(float r, float g, float b) {
    return vec4(r / 255., g / 255., b / 255., 1.);
}

void main() {
  vec2 coord = vec2(gl_FragCoord);
  float outerRadius = min(u_resolution.x, u_resolution.y) * .5;
  float distanceToMouse = distance(u_mouse, gl_FragCoord.xy) * 0.033;
  float distanceToMouseFromCenter = distance(u_mouse, center);
  float distanceToMouseFromCircle = abs(outerRadius - distanceToMouseFromCenter);
  float width = 2. + distanceToMouseFromCircle / distanceToMouse;
  vec4 backgroundColor = vec4(0.);
  float halfPI = PI * .5;
  float periodicTime = mod(u_time * .25, PI) - halfPI;
  vec4 color = rgb(255. * (sin(periodicTime) + 1.), 60. * distanceToMouse / 2., 160.) * (radius / distance(gl_FragCoord.xy, center));

  float innerRadius = outerRadius - width;

  float startX = clamp(periodicTime, -halfPI, 0.);
  float endX = clamp(periodicTime, 0., halfPI);

  float angleVariation = sin(startX) + 1.;
  float endAngleVariation = sin(endX);
  float rotation = 180. * (sin(periodicTime) + 1.);

  float startAngle = 360. * angleVariation + rotation - 90.;
  float endAngle = 360. * endAngleVariation + rotation - 90.;

  float isFilled = arc(coord, center, - startAngle, - endAngle, innerRadius, outerRadius);
  gl_FragColor = (backgroundColor - (backgroundColor - color) * isFilled);
}