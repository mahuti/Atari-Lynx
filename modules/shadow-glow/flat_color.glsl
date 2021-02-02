uniform sampler2D texture;

void main() {

    vec2 uv = gl_TexCoord[0].xy;
    vec4 color = texture2D(texture, uv); 

    gl_FragColor = vec4(
        gl_Color.rgb,
        gl_Color.a * color.a
    );
}