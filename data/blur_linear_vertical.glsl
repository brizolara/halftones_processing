#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform vec2 u_resolution;
uniform float Size;   // blur radius

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  vec4 sum = vec4(0.0);

  // vertical direction
  vec2 dir = vec2(0.0, 1.0 / u_resolution.y);

  for (float i = -Size; i <= Size; i += 1.0) {
    sum += texture2D(texture, uv + dir * i);
  }

  gl_FragColor = sum / (2.0 * Size + 1.0);
}
