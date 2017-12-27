#version 150
const int LIGHTCOUNT = 2;

in vec2 inPosition;
in vec3 vertColor;
in vec3 outPosition;
in vec3 outNormal;
in vec2 textureCoord;

uniform vec3 lightPos;
uniform vec3 lightPosArray[LIGHTCOUNT];
uniform vec3 camera;
uniform sampler2D textureID;
uniform int teleso;
uniform int lightType;

void light(vec3 position, int numberOfLight, out vec3 ambient,out vec3 diffuse, out vec3 specular){
     vec3 inNormal = outNormal;

     vec3 matDifCol = vec3(0.8, 0.9, 0.6);
     vec3 matSpecCol = vec3(1.0);
     vec3 ambientLightCol = vec3(0.3, 0.1, 0.5);
     vec3 directLightCol = vec3(1.0, 0.9, 0.9);

     ambient = ambientLightCol * matDifCol;

     float difCoef = max(0, dot(inNormal, normalize(lightPosArray[numberOfLight] - position)));
     vec3 difComponent = directLightCol * matDifCol * difCoef;

     vec3  reflected = reflect(normalize(position - lightPosArray[numberOfLight]), inNormal);
     float specCoef = 0;

     if (lightType == 1) {// phong
        specCoef = pow(max(0, dot(normalize(camera - position),reflected)), 70);

        vec3 specComponent = directLightCol * matSpecCol * specCoef;

//        ambient = ambiComponent;
//        diffuse = difComponent;
//        specular = specComponent;
     }
     if (lightType == 2){//blinphong
        specCoef = 0.0;
            //float specCoef = pow(max(0, dot(normalize(camera-position),reflected)), 70);

            if(dot(inNormal, normalize(lightPosArray[numberOfLight] - position)) > 0.0){
                vec3 halfVector = normalize((lightPosArray[numberOfLight] - position) + normalize(camera - position));
                specCoef = pow(dot(inNormal, halfVector), 70);
            }
     }
     //reflektorove svetlo
     vec3 lightDirection = vec3(0,0,-1);
//      //uhel, pro kuzelovite svetlo, ve stupnich
     float lightCutoff = 10;
//
    float spotEffect = degrees(acos(dot(normalize(lightDirection), -normalize((lightPosArray[numberOfLight] - position)))));
//    //vypocet rozmazani
    float attBlear = clamp((spotEffect - lightCutoff) / (1 - lightCutoff),0.0,1.0);
    if (spotEffect > lightCutoff) {
        diffuse = vec3(0);
        specular = vec3(0);
     }
    else {
      vec3 specComponent = matSpecCol * directLightCol * specCoef;
     specular = attBlear * specComponent;
     diffuse = attBlear * difComponent;
    }
     //return ambiComponent + attBlear *(difComponent  + specComponent);
}

vec3 blinPhong(vec3 position){
    vec3 inNormal = normalize(outNormal);

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

    if(dot(inNormal,normalize(lightPos-position)) > 0.0){
        vec3 halfVector = normalize((lightPos-position) + normalize(camera-position));
        specCoef = pow(dot(inNormal,halfVector), 70);
    }
    vec3 lightDirection = vec3(0,0,-1);
    //uhel, pro kuzelovite svetlo, ve stupnich
    float lightCutoff = 10;

    float spotEffect = degrees(acos(dot(normalize(lightDirection),- normalize(lightPos-position))));
    //vypocet rozmazani
    float attBlear = clamp((spotEffect - lightCutoff) / (1-lightCutoff),0,1);
    if (spotEffect > lightCutoff) {
    return ambiComponent;
    }

    vec3 specComponent = matSpecCol * directLightCol * specCoef;

    return ambiComponent + attBlear *(difComponent  + specComponent);
}
void main() {
	//gl_FragColor = vec4(vertColor, 1.0);
	//gl_FragColor = vec4(phong(outPosition),1.0);
	//gl_FragColor = /*vec4(vertColor, 1.0)**/texture(textureID,textureCoord);
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
	gl_FragColor = vec4 (ambientSum + diffSum + specSum, 1.0);

    if (lightType == 3 || lightType == 4){
     gl_FragColor = vec4(vertColor, 1.0);
    }
	//gl_FragColor = vec4(blinPhong(outPosition),1.0);
//	gl_FragColor = vec4(normalize(outNormal) + 0.5 * 0.5, 1.0);
//	gl_FragColor = vec4(outPosition,1.0);
//    gl_FragColor = vec4(textureCoord,0.0,1.0);
}
