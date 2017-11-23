#version 150
in vec2 inPosition;
in vec3 vertColor;
void main() {
	gl_FragColor = vec4(vertColor, 1.0);
}
