shader_type canvas_item;

uniform float blur_radius = 20.0; // Increased blur radius for more intensity
uniform int blur_samples = 32;    // Increased number of samples for better quality

uniform sampler2D source_texture;

void fragment() {
    vec2 uv = UV; // Normalized texture coordinates
    vec4 color = vec4(0.0); // Accumulated color
    float total_weight = 0.0; // For normalizing the weights

    // Precompute Gaussian weights for efficiency (approximated linearly)
    float sigma = float(blur_samples) * 0.5;
    float two_sigma_squared = 2.0 * sigma * sigma;
    float normalization = 1.0 / (3.14159265 * two_sigma_squared);

    // Dynamic clamping of sample count based on blur radius
    int adjusted_samples = int(max(2.0, float(blur_samples) * (blur_radius / 10.0)));

    for (int x = -adjusted_samples; x <= adjusted_samples; x++) {
        for (int y = -adjusted_samples; y <= adjusted_samples; y++) {
            vec2 offset = vec2(float(x), float(y)) * blur_radius / vec2(textureSize(source_texture, 0));

            // Approximate weight using a stronger falloff for more intensity
            float weight = max(0.0, 1.0 - float(x * x + y * y) / float(adjusted_samples * adjusted_samples));

            // Amplify the weight for more intensity
            weight *= 2.0;  // This increases the intensity of each sample

            color += texture(source_texture, uv + offset) * weight;
            total_weight += weight;
        }
    }

    // Normalize the final color
    COLOR = color / total_weight;
}
