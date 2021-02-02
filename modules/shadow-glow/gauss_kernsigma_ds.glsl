uniform sampler2D texture;
uniform vec2 kernelData;
uniform vec2 offsetFactor;

void main () {

    vec3 incrementalGaussian;
    incrementalGaussian.x = 1.0 / (sqrt(2.0 * 3.1415926) * kernelData.y);
    incrementalGaussian.y = exp(-0.5 / (kernelData.y * kernelData.y));
    incrementalGaussian.z = incrementalGaussian.y * incrementalGaussian.y;

    vec2 uv = gl_TexCoord[0].xy;
    vec4 color = vec4( 0.0 );
    float kernsum = 0.0;

    color += texture2D(texture, uv) * incrementalGaussian.x;
    kernsum += incrementalGaussian.x;
    incrementalGaussian.xy *= incrementalGaussian.yz;

    for ( float i = 1.0; i <= (kernelData.x - 1.0) * 0.5; i++ ) {
        color += texture2D(texture, uv - i * offsetFactor) * incrementalGaussian.x;
        color += texture2D(texture, uv + i * offsetFactor) * incrementalGaussian.x;
        kernsum += 2.0 * incrementalGaussian.x;
        incrementalGaussian.xy *= incrementalGaussian.yz;
    }

    vec4 colorout = color / kernsum;

    gl_FragColor = vec4(
		gl_Color.rgb * colorout.rgb,
		gl_Color.a * colorout.a
	);
}