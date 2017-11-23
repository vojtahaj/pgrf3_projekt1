#version 150
in vec2 inPosition; // input from the vertex buffer
//in vec3 inNormal; // input from the vertex buffer
out vec3 vertColor; // output from this shader to the next pipeline stage
uniform mat4 mat; // variable constant for all vertices in a single draw
uniform vec3 lightPos;
uniform vec3 camera;

const float PI = 3.14154926;
const float DELTA = 0.001;

vec3 sphere(vec2 paramPos){
    float t = paramPos.x * 2 * PI; //azimuth
    float s = (paramPos.y - 0.5)*PI; //zenith
    return vec3 (
    cos(s)*cos(t),
    sin(s)*cos(t),
    sin(t)
    );
}

vec3 planeNormal(vec2 paramPos){
return vec3(0,0,1);
}
vec3 sphereNormal(vec2 paramPos){
    return sphere(parampos);
}
vec3 sphere2(vec2 paramPos){
    float a = paramPos.x * 2 * PI; //azimuth
    float z = paramPos.y*PI; //zenith
    return vec3 (
    cos(a)*cos(z),
    sin(a)*sin(z),
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

vec3 something(vec2 paramPos){
    float a = paramPos.x * 2 * PI; //azimuth
    //float z = paramPos.y*PI; //zenith

    return vec3(
    cos(a)*paramPos.y,
    sin(a)*paramPos.y,
    paramPos.y
);
}
vec3 somethingNormal(paramPos){
    vec3 a = 2 * PI * paramPos.x;
    //parcialni derivace podle x
    vec3 t1 = vec3(
        -sin(a) * paramPos.y,
        cos(a) * paramPos.y,
        0
    );
    //parcialni derivace podle y
    vec3 t2 = vec3(
        cos(a),
        sin(a),
        1
    );
    return cross(t1,t2);
}
vec3 elephant(vec2 paramPos){
    vec2 s = vec2(paramPos.y * 2.0 * PI);
    vec2 t = vec2(paramPos.x * 2.0 * PI);

return vec3 (1.0, 1.0, 1.0);
}
void main() {
	//gl_Position = mat * vec4(inPosition.xy, 0.5*sqrt(((inPosition.x*inPosition.x)+(inPosition.y*inPosition.y))), 1.0);
    //gl_Position = mat * vec4(inPosition.xy,0.0,1.0);
    //vec3 pozice = vec3(inPosition.x*2*pi,inPosition.y*2*pi, (inPosition.y - 0.5)*pi);
    //gl_Position = mat * vec4(cos(pozice.x)*cos(pozice.z),sin(pozice.y)*cos(pozice.z),sin(pozice.z),1.0 );


    //gl_Position = mat * vec4(cos(inPosition.x),cos(inPosition.y),0.0,1.0 );
    gl_Position = mat * vec4(sphere2(inPosition),1.0);
    //vertColor = inPosition.xy * 0.5 + 0.5;
	//vertColor = vec3(0.7, 0.9, 0.4) * max(0, dot(inNormal, normalize(lightPos - inPosition))); //Lambertovo osvetleni
    vertColor = vec3(inPosition,0.0);
}
