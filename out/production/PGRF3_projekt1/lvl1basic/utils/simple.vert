#version 150
in vec2 inPosition; // input from the vertex buffer

out vec3 vertColor; // output from this shader to the next pipeline stage

uniform mat4 mat; // variable constant for all vertices in a single draw

uniform vec3 lightPos;
uniform vec3 camera;
uniform vec3 lightPosArray[2];
//uniform float lightType; //podle druhu lightType pouzije osvetleni
uniform float teleso; //teleso, ktere se bude kreslit

out vec3 outNormal; //vypocitane normaly do fragment shaderu
out vec3 outPosition;

out vec2 textureCoord;

const float PI = 3.14154926;
const float DELTA = 0.001;

vec3 sphere(vec2 paramPos){
    float z = paramPos.x * 2 * PI; //zenith
    float a = (paramPos.y - 0.5)*PI; //azimut
    return vec3 (
    cos(z)*cos(a),
    sin(z)*cos(a),
    sin(a)
    );

}
vec3 trumpet(vec2 paramPos){
//trumpeta
    float z = paramPos.x * 2 * PI; //zenith
    float a = paramPos.y * 17; //azimut
    return vec3 (
        a,
        3/(pow((a+1),0.7))*cos(z),
        3/(pow((a+1),0.7))*sin(z)
        );
}
vec3 something(vec2 paramPos){
float z = 2 * PI * paramPos.x; //zenith
    return vec3(
        cos(z) * paramPos.y,
        sin(z) * paramPos.y,
        (1 - paramPos.y)
    );
}
vec3 sphericElephant(vec2 paramPos){ //Elephant ve sferickych souradnicich
    float z = paramPos.x * PI; //zenith - podle x
    float a = paramPos.y * 2 * PI; //azimut - podle y
    float R = 3.0 + cos(4 * a);

    return vec3(R * sin(z) * cos(a), R * sin(z) * sin(a), R * cos(z));
}
vec3 sphericFan(vec2 paramPos){//rho = sin(s), phi=t-1, theta = sqrt(s)
    float z = paramPos.y * 2* PI;// azimut
    float a = paramPos.x * PI;//zenith
    float R = sin (z);

    return vec3(R * sin(a - 1) * cos(sqrt(z)),R * sin(a - 1) * sin(sqrt(z)),R * cos(a - 1));
}
vec3 cylindricSombrero(vec2 paramPos){
    float s = paramPos.y * 2 * PI; //parametry s,t <0;2Pi>, zenit azimut
    float t = paramPos.x * 2 * PI;

    float R = t;
    float z = 2 * sin(t);

    return vec3(R * cos(s), R * sin(s), z);
}
vec3 cylindricPenthal(vec2 paramPos){
    // mela by to byt fce r = -3, theta = s*4, z = sqrt(t)
    // avsak vykresluje neco jineho, nez by podle http://www.math.uri.edu/~bkaskosz/flashmo/tools/cylin/ mela
    float s = paramPos.y * 2 * PI;
    //float t = paramPos.x; spatny rozsah
    float t = (paramPos.x - 0.5) * 2;

    float R = t-3;
    float z = sqrt(t);

    return vec3(R * cos(s * 4), R * sin((s * 4)), z);
}
vec3 surface(vec2 paramPos, vec2 dx, vec2 dy){
    if (teleso == 1.0)
        return vec3(cross((sphere(paramPos + dx) - sphere(paramPos - dx)) / (2 * DELTA),(sphere(paramPos + dy) - sphere(paramPos  - dy)) / ( 2 * DELTA)));
    if (teleso == 2.0)
       return vec3(cross((trumpet(paramPos + dx) - trumpet(paramPos - dx)) / (2 * DELTA),(trumpet(paramPos + dy) - trumpet(paramPos  - dy)) / ( 2 * DELTA)));
    if (teleso == 3.0)
       return vec3(cross((something(paramPos + dx) - something(paramPos - dx)) / (2 * DELTA),(something(paramPos + dy) - something(paramPos  - dy)) / ( 2 * DELTA)));
    if (teleso == 4.0)
        return vec3(cross((sphericElephant(paramPos + dx) - sphericElephant(paramPos - dx)) / (2 * DELTA),(sphericElephant(paramPos + dy) - sphericElephant(paramPos - dy) / (2 * DELTA))));
    if (teleso == 5.0)
        return vec3(cross((sphericFan(paramPos + dx) - sphericFan(paramPos-dx)) / (2 * DELTA), (sphericFan(paramPos + dy) - sphericFan(paramPos - dy)) / (2 * DELTA)));
    if (teleso == 6.0)
        return vec3(cross((cylindricSombrero(paramPos + dx) - cylindricSombrero(paramPos - dx)) / (2 * DELTA),(cylindricSombrero(paramPos + dy) - cylindricSombrero(paramPos - dy)) / (2 * DELTA)));
    if (teleso == 7.0)
        return vec3(cross((cylindricPenthal(paramPos + dx) - cylindricPenthal(paramPos - dx)) / (2 * DELTA),(cylindricPenthal(paramPos + dy) - cylindricPenthal(paramPos - dy))/(2 * DELTA)));
    return vec3(0,0,1);
}
vec3 surfacePosition(vec2 paramPos){ //vypocet souradnic pro normaly
    if (teleso == 1.0)
        return vec3(sphere(paramPos));
     if (teleso == 2.0)
        return vec3(trumpet(paramPos));
    if (teleso == 3.0)
        return vec3(something(paramPos));
    if (teleso == 4.0)
        return vec3(sphericElephant(paramPos));
    if (teleso == 5.0)
        return vec3(sphericFan(paramPos));
    if (teleso == 6.0)
        return vec3(cylindricSombrero(paramPos));
    if (teleso == 7.0)
        return vec3(cylindricPenthal(paramPos));
    return vec3(0,0,1);
}
vec3 normal(vec2 paramPos){
    vec2 dx = vec2(DELTA,0);
    vec2 dy = vec2(0,DELTA);
    //vec3 tx = (sphere(paramPos+dx) - sphere(paramPos-dx))/(2*DELTA); //je reseno v surface
    //vec3 ty = (sphere(paramPos+dy) - sphere(paramPos-dy))/(2*DELTA); //je reseno v surface
    //return normalize(cross(tx,ty)); //mozna nemusime normalizovat, normalizujeme ve fragment shaderu
    return normalize(surface(paramPos, dx,dy));
}
vec3 phong(vec2 paramPos, int lightNum){ //v fragment shaderu bude per pixel, ted je per vertex
    vec3 inNormal = normal(paramPos); //vypocet normal pro dane teleso
    outNormal = inNormal;
    vec3 position = surfacePosition(paramPos);
    outPosition = position;

    vec3 positionLight = lightPosArray[lightNum];

    vec3 matDifCol = vec3(0.8, 0.9, 0.6);
    vec3 matSpecCol = vec3(1.0);
    vec3 ambientLightCol = vec3(0.3, 0.1, 0.5);
    vec3 directLightCol = vec3(1.0, 0.9, 0.9);

    vec3 ambiComponent = ambientLightCol * matDifCol;

    //float difCoef = max(0, dot(inNormal, normalize(lightPos-position)));
    float difCoef = max(0, dot(inNormal, normalize(positionLight-position)));
    vec3 difComponent = directLightCol * matDifCol * difCoef;

    //vec3  reflected = reflect(normalize(position-lightPos), inNormal);
    vec3  reflected = reflect(normalize(position-positionLight), inNormal);
    float specCoef = pow(max(0, dot(normalize(camera-position),reflected)), 70);

    vec3 specComponent = directLightCol * matSpecCol * specCoef;

    return ambiComponent + difComponent + specComponent;
}
vec3 blinPhong(vec2 paramPos){ //v fragment shaderu bude per pixel, ted je per vertex
    vec3 inNormal = normal(paramPos); //vypocet normal pro dane teleso
    outNormal = inNormal;
    vec3 position = surfacePosition(paramPos);
    outPosition = position;

    vec3 matDifCol = vec3(0.8, 0.9, 0.6);
    vec3 matSpecCol = vec3(1.0);
    vec3 ambientLightCol = vec3(0.3, 0.1, 0.5);
    vec3 directLightCol = vec3(1.0, 0.9, 0.9);

    vec3 ambiComponent = ambientLightCol * matDifCol;

    float difCoef = max(0, dot(inNormal, normalize(lightPos-position)));
    vec3 difComponent = directLightCol * matDifCol * difCoef;

    vec3  reflected = reflect(normalize(position-lightPos), inNormal);
    float specCoef = 0.0;
    //float specCoef = pow(max(0, dot(normalize(camera-position),reflected)), 70);

    //if(dot(inNormal,normalize(lightPos-position)) > 0.0){
        vec3 halfVector = normalize(normalize(lightPos-position) + normalize(camera-position));
        specCoef = max(0, pow(dot(inNormal,halfVector), 70));  //70 lesklost
   // }
    vec3 specComponent = matSpecCol * directLightCol * specCoef;

    return ambiComponent + difComponent + specComponent;
}

void main() {
    float lightType = 2.0; //better uniform
   gl_Position = mat * vec4(surfacePosition(inPosition),1.0);
   outPosition = surfacePosition(inPosition);
   // gl_Position = mat * vec4(trumpet(inPosition),1.0);
   // gl_Position = mat * vec4(something(inPosition),1.0);
   // gl_Position = mat * vec4(sphericElephant(inPosition),1.0);
  //  gl_Position = mat * vec4(sphericFan(inPosition),1.0);
   // gl_Position = mat * vec4(cylindricSombrero(inPosition),1.0);
   // gl_Position = mat * vec4(cylindricPenthal(inPosition),1.0);
    if (lightType == 1.0){ //Phonguv osvetlovaci model
       vertColor =  phong(inPosition, 0);// * phong(inPosition, telesoType, 1);
    }
    if (lightType == 2.0){ //Bling-Phonguv osvetlovaci model
           vertColor =  blinPhong(inPosition);
    }
//    textureCoord = mod(inPosition * 4, 1);
//    vertColor = vec3(normal(inPosition, telesoType)) * 0.5 + 0.5; // * 0.5 + 0.5 je pro zobrazeni Zapornych normal
//    vertColor = vec3(inPosition, 0.0); //parametry vstupniho gridu na x a y
//    vertColor = vec3(textureCoord,0.0); // souradnice textury
//    vertColor = vec3(sphere(inPosition));
}
