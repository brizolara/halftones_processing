#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform vec2 u_resolution;
uniform float Directions;
uniform float Quality;
uniform float Size;

void main() {
  float Pi = 6.28318530718;
  vec2 Radius = Size / u_resolution;
  vec2 uv = gl_FragCoord.xy / u_resolution;
  //uv = vec2(uv.x, 1.0 - uv.y); // fix orientation
  vec4 Color = texture2D(texture, uv);

  for (float d = 0.0; d < Pi; d += Pi / Directions) {
    for (float i = 1.0 / Quality; i <= 1.0; i += 1.0 / Quality) {
      vec2 dir = vec2(cos(d), sin(d));
      Color += texture2D(texture, uv + dir * Radius * i);
    }
  }

  Color /= (Quality * Directions - 15.0);
  gl_FragColor = Color;
}

