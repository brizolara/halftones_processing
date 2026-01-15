uniform sampler2D texture;
uniform vec2 resolution;
uniform int option; // 0 = shape halftone, 1 = line halftone

/// shape halftone
uniform int shapeType; // 0 = circle, 1 = square, 2 = diamond

/// lines
uniform float lin_phase = 0; // 0-1
uniform float lin_freq = 0;
uniform float lin_orientation = 0; // angle in radians

/// concentric circles
uniform vec2 center; // normalized coordinates (0–1 range)
uniform float ringDensity;


// Custom shape function
float shape(vec2 pos, int type) {
    if (type == 0) {
        return length(pos); // circle
    } else if (type == 1) {
        return max(abs(pos.x), abs(pos.y)); // square
    } else if (type == 2) {
        return abs(pos.x) + abs(pos.y); // diamond
    } return length(pos);
}

// Line halftone function
/*float lineHalftone(vec2 uv, float intensity) {
    float line = sin(uv.y *2.0*3.14159*lin_freq + 3.14159*lin_phase);
    return 1.0 - step(line, intensity);
}*/
// Line halftone function with angle control
/*float lineHalftone(vec2 uv, float intensity, float angle) {
    // Build a direction vector from the angle
    vec2 dir = vec2(cos(angle), sin(angle));

    // Project uv onto this direction
    float coord = dot(uv, dir);

    // Compute sine wave along that direction
    float line = sin(coord * 2.0 * 3.14159 * lin_freq + 3.14159 * lin_phase);

    return 1.0 - step(line, intensity);
}*/
// uniforms you likely already have
/*uniform float lin_freq;   // cycles per screen along the line direction
uniform float lin_phase;  // phase in cycles (not radians)
*/

// Line halftone with angle, screen-space, and aspect-safe
float lineHalftone(vec2 uv, float intensity, float angle) {
    // Convert uv to pixel space and center at screen midpoint
    //vec2 p = (uv * resolution) - 0.5 * resolution;
    vec2 p = gl_FragCoord.xy;

    // Direction unit vector from angle (radians)
    vec2 dir = vec2(cos(angle), sin(angle));

    // Project onto direction (in pixels)
    float coord = dot(p, dir);

    // Frequency in cycles per screen length along dir
    float line = sin((coord * 2.0 * 3.14159 * lin_freq)/length(resolution) + 2.0 * 3.14159 * lin_phase);

    return 1.0 - step(line, intensity);
}


// Concentric circle halftone
float concentricHalftone(vec2 uv, vec2 center, float intensity) {
    float d = length(uv - center);
    float rings = sin(d * ringDensity * 3.14159); // ring spacing

    // Band test: thickness grows with intensity
    //return 1.0 - abs(rings) * intensity;
    //return 1.0 - smoothstep(intensity - 0.05, intensity + 0.05, abs(rings));
    return 1.0 - step(rings, intensity);
}


void main() {
    vec2 uv = gl_FragCoord.xy / resolution;
    //vec2 uv = vTexCoord;
    uv = vec2(uv.x, 1.0 - uv.y); // fix orientation

    vec3 texColor = texture2D(texture, uv).rgb;
    float intensity = dot(texColor, vec3(0.299, 0.587, 0.114));

    float mask;
    if (option == 0) {
        // Custom shape halftone
        vec2 shiftedUV = fract(uv * 50.0) - 0.5;
        float d = shape(shiftedUV, shapeType);
        mask = step(intensity, d);
    } else if (option == 1) {
        // Line halftone
        vec2 cellUV = fract(uv * 50.0) - 0.5;
        mask = lineHalftone(cellUV, intensity, lin_orientation);
    } else if (option == 2) {
        // Concentric circle halftone
        mask = concentricHalftone(uv, center, intensity);
    }

    //gl_FragColor = vec4(vec3(1.0 - mask), 1.0); // inverting
    gl_FragColor = vec4(vec3(mask), 1.0);
}

