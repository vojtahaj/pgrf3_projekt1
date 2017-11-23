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
//    float a = paramPos.x * 2 * PI; //azimuth
//    float z = (paramPos.y - 0.5)*PI; //zenith
//    return vec3 (
//    cos(a)*cos(z),
//    sin(a)*cos(z),
//    sin(z)
//    );
    //trumpeta
    float s = paramPos.x * 2 * PI; //azimuth
    float t = paramPos.y*17; //zenith
    return vec3 (
        t,
        6/(pow((t+1),0.7))*cos(s),
        6/(pow((t+1),0.7))*sin(s)
        );

}

vec3 normal(vec2 paramPos){
    vec2 dx = vec2(DELTA,0);
    vec2 dy = vec2(0,DELTA);
    vec3 tx = sphere(paramPos+dx)-sphere(paramPos-dx); 
    vec3 ty = sphere(paramPos+dy)-sphere(paramPos-dy);
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
void main() {
    float lightType = 1.0;
    gl_Position = mat * vec4(sphere(inPosition),1.0);

    if (lightType == 1.0){ //Phonguv osvetlovaci model
       vertColor =  phong(inPosition);

    }

    vertColor = vec3(normal(inPosition));


}
