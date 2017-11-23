#version 150
in vec3 vertColor;
out vec4 outColor;
void main() {
	gl_FragColor = vec4(vertColor, 1.0);
	//outColor = vec4(vertColor, 1.0);

}
