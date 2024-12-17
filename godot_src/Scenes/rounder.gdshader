shader_type canvas_item;

uniform float radius_scale: hint_range(0.0, 1.0, 0.1) = 0.1;
uniform bool rounded_corner_top_left = true;
uniform bool rounded_corner_top_right = true;
uniform bool rounded_corner_bottom_left = true;
uniform bool rounded_corner_bottom_right = true;
uniform float width = 1.0;
uniform float height = 1.0;
uniform float opacity: hint_range(0.0, 1.0) = 1.0;
uniform bool isInRadians = false;

group_uniforms ShaderParameters.RadianRotation;
uniform float xRadians: hint_range(0, 6.2830); // X IS FIXED
uniform float yRadians: hint_range(0, 6.2830); // Y IS FIXED
uniform float zRadians: hint_range(0, 6.2830); // Z IS FIXED
group_uniforms;

group_uniforms ShaderParameters.DegreesRotation;
uniform float xDegrees: hint_range(0, 360); // X IS FIXED
uniform float yDegrees: hint_range(0, 360); // Y IS FIXED
uniform float zDegrees: hint_range(0, 360); // Z IS FIXED
group_uniforms;

void fragment() {
	vec4 image = texture(TEXTURE, UV);
	vec2 pos = vec2(UV.x*width, UV.y*height);
	float radius = min(width, height)*radius_scale/2.0;
	float dist;
	// Top left corner
	if (rounded_corner_top_left) {
		dist = length(pos - vec2(radius));
		if (dist > radius && pos.x < radius && pos.y < radius) {
			image.a = 0.0;
		}

	}

	if (rounded_corner_top_right) {
		dist = length(pos - vec2(width-radius, radius));
		if (dist > radius && pos.x > width-radius && pos.y < radius) {
			image.a = 0.0;
		}

	}

	if (rounded_corner_bottom_left) {
		dist = length(pos - vec2(radius, height-radius));
		if (dist > radius && pos.x < radius && pos.y > height-radius) {
			image.a = 0.0;
		}

	}

	if (rounded_corner_bottom_right) {
		dist = length(pos - vec2(width-radius, height-radius));
		if (dist > radius && pos.x > width-radius && pos.y > height-radius) {
			image.a = 0.0;
		}

	}

    image.a *= opacity;

	COLOR = image;
}





float degToRad(float angle) {
	return angle * PI / 180.0;
}

void vertex() {
    // Calculate the center of the object using its dimensions
    vec2 center = vec2(width * 0.5, height * 0.5);

    // Move vertices so the center is at the origin
    vec3 pos = vec3(VERTEX.xy - center, 0.0);

    // Convert degrees to radians if needed
    float radX = xRadians;
    float radY = yRadians;
    float radZ = zRadians;

    if (!isInRadians) {
        radX = degToRad(xDegrees);
        radY = degToRad(yDegrees);
        radZ = degToRad(zDegrees);
    }

    // Precompute trigonometric values for rotation
    float cosX = cos(radX);
    float cosY = cos(radY);
    float cosZ = cos(radZ);
    float sinX = sin(radX);
    float sinY = sin(radY);
    float sinZ = sin(radZ);

    // Construct rotation matrix (ZYX Euler order)
    mat3 finalRot;
    finalRot[0][0] = cosZ * cosY;
    finalRot[1][0] = cosZ * sinY * sinX - sinZ * cosX;
    finalRot[2][0] = sinZ * sinX + cosZ * sinY * cosX;

    finalRot[0][1] = sinZ * cosY;
    finalRot[1][1] = cosZ * cosX + sinZ * sinY * sinX;
    finalRot[2][1] = sinZ * sinY * cosX - cosZ * sinX;

    finalRot[0][2] = -sinY;
    finalRot[1][2] = cosY * sinX;
    finalRot[2][2] = cosY * cosX;

    // Apply the rotation
    pos = pos * finalRot;

    // Shift vertices back to their original position
    VERTEX = pos.xy + center;
}
