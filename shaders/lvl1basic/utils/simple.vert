#version 150
in vec2 inPosition; // input from the vertex buffer
out vec3 vertColor; // output from this shader to the next pipeline stage
uniform mat4 mat; // variable constant for all vertices in a single draw

uniform vec3 lightPos;
uniform vec3 camera;

const float PI = 3.14154926;
const float DELTA = 0.001;


vec3 sphere(vec2 paramPos){
    float a = paramPos.x * 2 * PI; //azimuth
    float z = (paramPos.y-0.5)*PI; //zenith
    return vec3 (
    cos(a)*cos(z),
    sin(a)*cos(z),
    sin(z)
    );
}

vec3 normal(vec2 paramPos){
    vec2 dx = vec2(DELTA,0);
    vec2 dy = vec2(0,DELTA);
    vec3 tx = sphere(paramPos+dx)-sphere(paramPos-dx);
    vec3 ty = sphere(paramPos+dy)-sphere(paramPos-dy);
    return normalize(cross(tx,ty)); //mozna nemusime normalizovat, normalizujeme ve fragment shaderu
}

void main() {


	gl_Position = mat * vec4(sphere(inPosition),1.0);
    vertColor = vec3(normal(inPosition));
}
