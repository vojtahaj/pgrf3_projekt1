#version 150
const int LIGHTCOUNT = 2;
const float PI = 3.14154926;
const float DELTA = 0.00001;
const int LIGHT_PHONG_V = 3;
const int LIGHT_BLIN_V = 4;
const int MATERIAL_COUNT = 10; //2 svetla * 5 parametru

in vec2 inPosition; // input from the vertex buffer

uniform mat4 mat; // variable constant for all vertices in a single draw
uniform vec3 lightPos;
uniform vec3 camera; //eyePos
uniform vec3 lightPosArray[LIGHTCOUNT];
uniform vec3 lightDirArray[LIGHTCOUNT];
uniform vec3 materials[MATERIAL_COUNT];
uniform int lightType; //podle druhu lightType pouzije osvetleni
uniform int teleso; //teleso, ktere se bude kreslit
uniform int lightParam;

out vec3 outNormal; //vypocitane normaly do fragment shaderu
out vec3 outPosition;
out vec2 textureCoord;
out vec3 vertColor; // output from this shader to the next pipeline stage
out vec3 eyeVec;
out vec3 lightVec[LIGHTCOUNT];

vec3 sphere(vec2 paramPos){
    float z = paramPos.x * 2 * PI; //zenith
    float a = (0.5 - paramPos.y) * PI; //azimut
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
vec3 surface(vec2 paramPos, out vec3 normal){
    vec2 dx = vec2(DELTA,0);
    vec2 dy = vec2(0,DELTA);
    if (teleso == 1){
        outPosition =  vec3(sphere(paramPos));
        normal = vec3(normalize(cross((sphere(paramPos + dx) - sphere(paramPos - dx)) / (2 * DELTA), (sphere(paramPos + dy) - sphere(paramPos  - dy)) / ( 2 * DELTA))));
        return outPosition;
        }
    if (teleso == 2){
       normal = vec3(normalize(cross((trumpet(paramPos + dy) - trumpet(paramPos  - dy)) / ( 2 * DELTA), (trumpet(paramPos + dx) - trumpet(paramPos - dx)) / (2 * DELTA))));
       return  outPosition = vec3(trumpet(paramPos));
       }
    if (teleso == 3){
       normal = vec3(normalize(cross((something(paramPos + dy) - something(paramPos  - dy)) / ( 2 * DELTA), (something(paramPos + dx) - something(paramPos - dx)) / (2 * DELTA))));
       return outPosition = vec3(something(paramPos));
       }
    if (teleso == 4){
        normal = vec3(normalize(cross((sphericElephant(paramPos + dy) - sphericElephant(paramPos - dy)) / (2 * DELTA), (sphericElephant(paramPos + dx) - sphericElephant(paramPos - dx)) / (2 * DELTA))));
        return outPosition = vec3(sphericElephant(paramPos));
        }
    if (teleso == 5){
        normal = vec3(normalize(cross((sphericFan(paramPos + dy) - sphericFan(paramPos - dy)) / (2 * DELTA), (sphericFan(paramPos + dx) - sphericFan(paramPos-dx)) / (2 * DELTA))));
        return outPosition =  vec3(sphericFan(paramPos));
        }
    if (teleso == 6){
        normal = vec3(normalize(cross((cylindricSombrero(paramPos + dy) - cylindricSombrero(paramPos - dy)) / (2 * DELTA), (cylindricSombrero(paramPos + dx) - cylindricSombrero(paramPos - dx)) / (2 * DELTA))));
        return outPosition = vec3(cylindricSombrero(paramPos));
        }
    if (teleso == 7){
        normal = vec3(normalize(cross((cylindricPenthal(paramPos + dy) - cylindricPenthal(paramPos - dy))/(2 * DELTA), cylindricPenthal(paramPos + dx) - cylindricPenthal(paramPos - dx)) / (2 * DELTA)));
        return outPosition = vec3(cylindricPenthal(paramPos));
        }
    return vec3(0,0,1);
}
vec3 surfacePosition(vec2 paramPos){ //vypocet souradnic gridu
    if (teleso == 1)
        return vec3(sphere(paramPos));
     if (teleso == 2)
        return vec3(trumpet(paramPos));
    if (teleso == 3)
        return vec3(something(paramPos));
    if (teleso == 4)
        return vec3(sphericElephant(paramPos));
    if (teleso == 5)
        return vec3(sphericFan(paramPos));
    if (teleso == 6)
        return vec3(cylindricSombrero(paramPos));
    if (teleso == 7)
        return vec3(cylindricPenthal(paramPos));
    return vec3(0,0,1);
}
void light(vec3 position, int numberOfLight, out vec3 ambient,out vec3 diffuse, out vec3 specular){
         vec3 inNormal = outNormal;


         vec3 matDifCol = materials[lightParam + 0].xyz;//vec3(0.8, 0.9, 0.6);
         vec3 matSpecCol = materials[lightParam + 1].xyz;
         vec3 ambientLightCol = materials[lightParam + 2].xyz;
         vec3 directLightCol = materials[lightParam + 3].xyz;
         float shinness = materials[lightParam + 4].x;

        //smer svetla
        vec3 dirLight = normalize(lightPosArray[numberOfLight] - position );
        vec3 dirCamera = normalize(position - camera);

         ambient = ambientLightCol * matDifCol;

         float difCoef = max(0, dot(inNormal, dirLight));
          diffuse = directLightCol * matDifCol * difCoef;
    //     vec3 difComponent = directLightCol * matDifCol * difCoef;

         vec3  reflected = reflect(normalize(position - lightPosArray[numberOfLight]), inNormal);
         float specCoef = 0.0;

         if (lightType == LIGHT_PHONG_V) {// phong
            specCoef = pow(max(0, dot(dirCamera, reflected)), shinness);

            specular = directLightCol * matSpecCol * specCoef;
         }
         if (lightType == LIGHT_BLIN_V){//blinphong

            if(dot(inNormal, normalize(dirLight)) > 0.0){
              vec3 halfVector = normalize(dirLight + dirCamera);

              specCoef = pow(dot(inNormal, halfVector), shinness);
              specular = directLightCol * matSpecCol * specCoef;
            }
         }
         specular = directLightCol * matSpecCol * specCoef;
        //reflektorove svetlo
        vec3 lightDirection = lightDirArray[numberOfLight];
        //uhel, pro kuzelovite svetlo, ve stupnich
        float lightCutoff = 70;

       float spotEffect = degrees(acos(dot(normalize(lightDirection), normalize(-dirLight))));
       //vypocet rozmazani
       float attBlear = clamp((spotEffect - lightCutoff) / (1 - lightCutoff),0.0,1.0);
       if (spotEffect > lightCutoff) {
           diffuse = vec3(0);
           specular = vec3(0);
        }
       else {
        vec3 specComponent = matSpecCol * directLightCol * specCoef;
        specular *= attBlear * specComponent;
        diffuse *= attBlear;

       }
}
mat3 tangentMat(vec2 paramPos){
     vec2 dx = vec2(DELTA, 0);
     vec2 dy = vec2(0, DELTA);
     vec3 tx = (surfacePosition(paramPos + dx) - surfacePosition(paramPos - dx)) / (2 * DELTA);
     vec3 ty = (surfacePosition(paramPos + dy) - surfacePosition(paramPos - dy)) / (2 * DELTA);
     vec3 x = normalize(tx); //normala
     vec3 y = normalize(-ty); //tangenta
     vec3 z = cross(x, y); //bitangenta
     x = cross(y, z); //zajisteni ortonormality
     return mat3(x,y,z);

}
void main() {

   gl_Position = mat * vec4(surface(inPosition, outNormal),1.0);

    vec3 ambientSum = vec3(0);
    vec3 diffSum = vec3(0);
    vec3 specSum = vec3(0);

    vec3 ambient, diffuse, specular;

     for (int i = 0; i<LIGHTCOUNT; i++){
         light(outPosition, i, ambient, diffuse, specular);
    	 ambientSum += ambient;
    	 diffSum += diffuse;
    	 specSum += specular;
     }
    ambientSum /= LIGHTCOUNT;
    vertColor = ambientSum + diffSum + specSum;

    textureCoord = vec2(inPosition.x, inPosition.y);

    mat3 tanMat = tangentMat(inPosition);
    eyeVec =  (camera - outPosition) * tanMat;
    for (int i=0;i<LIGHTCOUNT;i++)
      lightVec[i] = (lightPosArray[i] - outPosition) * tanMat;

}
