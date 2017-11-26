#version 150
in vec2 inPosition; // input from the vertex buffer
out vec3 vertColor; // output from this shader to the next pipeline stage
uniform mat4 mat; // variable constant for all vertices in a single draw

uniform vec3 lightPos;
uniform vec3 camera;
//uniform float lightType; //podle druhu lightType pouzije osvetleni

const float PI = 3.14154926;
const float DELTA = 0.001;


vec3 sphere(vec2 paramPos){
    float a = paramPos.x * 2 * PI; //azimuth
    float z = (paramPos.y - 0.5)*PI; //zenith
    return vec3 (
    cos(a)*cos(z),
    sin(a)*cos(z),
    sin(z)
    );


}
vec3 trumpet(vec2 paramPos){
//trumpeta
    float s = paramPos.x * 2 * PI; //azimuth
    float t = paramPos.y * 17; //zenith
    return vec3 (
        t,
        6/(pow((t+1),0.7))*cos(s),
        6/(pow((t+1),0.7))*sin(s)
        );
}
vec3 normal(vec2 paramPos){
    vec2 dx = vec2(DELTA,0);
    vec2 dy = vec2(0,DELTA);
    vec3 tx = sphere(paramPos+dx) - sphere(paramPos-dx);
    vec3 ty = sphere(paramPos+dy) - sphere(paramPos-dy);
    return normalize(cross(tx,ty)); //mozna nemusime normalizovat, normalizujeme ve fragment shaderu
}
vec3 phong(vec2 paramPos){
    vec3 inNormal = normal(paramPos);
    vec3 position = sphere(paramPos);

    vec3 matDifCol = vec3(0.8, 0.9, 0.6);
    vec3 matSpecCol = vec3(1.0);
    vec3 ambientLightCol = vec3(0.3, 0.1, 0.5);
    vec3 directLightCol = vec3(1.0, 0.9, 0.9);

    vec3 ambiComponent = ambientLightCol * matDifCol;

    float difCoef = max(0, dot(inNormal, normalize(lightPos-position)));
    vec3 difComponent = directLightCol * matDifCol * difCoef;

    vec3  reflected = reflect(normalize(position-lightPos), inNormal);
    float specCoef = pow(max(0, dot(normalize(camera-position),reflected)), 70);

    vec3 specComponent = directLightCol * matSpecCol * specCoef;

    return ambiComponent + difComponent + specComponent;
}

vec3 sphericElephant(vec2 paramPos){ //Elephant ve sferickych souradnicich
    float a = paramPos.x * PI; //azimut - podle x
    float z = paramPos.y * 2 * PI; //zenith - podle y
    float R = 3.0 + cos(4 * z);

    return vec3(R * sin(a) * cos(z), R * sin(a) * sin(z), R * cos(a));
}
vec3 cylindricSombrero(vec2 paramPos){
    float s = paramPos.y * 2 * PI; //parametry s,t <0;2Pi>, zenit azimut
    float t = paramPos.x * 2 * PI;

    float R = t;
    float z = 2*sin(t);

    return vec3(R * cos(s), R * sin(s), z);
}
void main() {
    float lightType = 1.0;
    gl_Position = mat * vec4(sphere(inPosition),1.0);
    gl_Position = mat * vec4(sphericElephant(inPosition),1.0);
   // gl_Position = mat * vec4(sphericElephant(inPosition),1.0);
   //gl_Position = mat * vec4(cylindricSombrero(inPosition),1.0);

    if (lightType == 1.0){ //Phonguv osvetlovaci model
       vertColor =  phong(inPosition);
    }

   //  vertColor = vec3(inPosition,1.0);


}
