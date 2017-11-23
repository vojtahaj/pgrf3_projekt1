#version 150
in vec2 inPosition; // input from the vertex buffer
//in vec3 inNormal; // input from the vertex buffer
//out vec3 vertColor; // output from this shader to the next pipeline stage
uniform mat4 mat; // variable constant for all vertices in a single draw
uniform vec3 lightPos;
uniform vec3 camera;

const float pi = 3.1415926;
void main() {
	//gl_Position = mat * vec4(inPosition.xy, 0.5*sqrt(((inPosition.x*inPosition.x)+(inPosition.y*inPosition.y))), 1.0);
    gl_Position = mat * vec4(inPosition.xy,0.0,1.0);

    float s = 0;
    float sMax = 2 * pi;
    float t = -1;
    float tMax = 1;

//    for(float i = s;i<sMax; i=i+0.2){
//        for (float j=t;j<tMax;j=j+0.2){
//          gl_Position = mat * vec4(j* cos(i),j* sin(i),j,1.0);
//        }
//
//    }
    //gl_Position = mat * vec4(t* cos(s),t* sin(s),t,1.0);
    //vertColor = inPosition.xy * 0.5 + 0.5;
	//vertColor = vec3(0.7, 0.9, 0.4) * max(0, dot(inNormal, normalize(lightPos - inPosition))); //Lambertovo osvetleni


}
