#version 150
const int LIGHTCOUNT = 1;

in vec2 inPosition;
in vec3 vertColor;
in vec3 outPosition;
in vec3 outNormal;
in vec2 textureCoord;
in vec3 lightVec;
in vec3 eyeVec;

out vec3 outColor;
uniform vec3 lightPos;
uniform vec3 lightPosArray[LIGHTCOUNT];
uniform vec3 camera;
uniform sampler2D diffTexture;
uniform sampler2D normTexture;
uniform sampler2D bumpTexture;
uniform int teleso;
uniform int lightType;
uniform int textureFormat; // druh textury - normalMapping, parallaxMapp

void light(vec3 position, int numberOfLight, out vec3 ambient,out vec3 diffuse, out vec3 specular){
     vec3 inNormal = outNormal;

     vec3 matDifCol = vec3(0.8, 0.9, 0.6);
     vec3 matSpecCol = vec3(1.0);
     vec3 ambientLightCol = vec3(0.3, 0.1, 0.5);
     vec3 directLightCol = vec3(1.0, 0.9, 0.9);

    //smer svetla
    vec3 dirLight = normalize(lightPosArray[numberOfLight] - position);
    vec3 dirCamera = normalize(camera - position);

     ambient = ambientLightCol * matDifCol;

     float difCoef = max(0, dot(inNormal, dirLight));
      diffuse = directLightCol * matDifCol * difCoef;
//     vec3 difComponent = directLightCol * matDifCol * difCoef;

     vec3  reflected = reflect(normalize(- dirLight), inNormal);
     float specCoef = 0.0;

     if (lightType == 1) {// phong
        specCoef = pow(max(0, dot(dirCamera, reflected)), 70);

        specular = directLightCol * matSpecCol * specCoef;
//        vec3 specComponent = directLightCol * matSpecCol * specCoef;

//        ambient = ambiComponent;
//        diffuse = difComponent;
//        specular = specComponent;
     }
     if (lightType == 2){//blinphong
        //float specCoef = pow(max(0, dot(normalize(camera-position),reflected)), 70);

        if(dot(inNormal, normalize(dirLight)) > 0.0){
          vec3 halfVector = normalize(dirLight + dirCamera);

          specCoef = pow(dot(inNormal, halfVector), 70);
          specular = directLightCol * matSpecCol * specCoef;
        }
     }
////     //reflektorove svetlo
//     vec3 lightDirection = vec3(0,0,1);
//////      //uhel, pro kuzelovite svetlo, ve stupnich
//     float lightCutoff = 10;
//////
//    float spotEffect = degrees(acos(dot(normalize(lightDirection), normalize(-(lightPosArray[numberOfLight] - position)))));
//////    //vypocet rozmazani
//    float attBlear = clamp((spotEffect - lightCutoff) / (1 - lightCutoff),0.0,1.0);
//    if (spotEffect > lightCutoff) {
//        diffuse = vec3(0);
//        specular = vec3(0);
//     }
//    else {
//      vec3 specComponent = matSpecCol * directLightCol * specCoef;
//     specular = attBlear * specComponent;
//     diffuse *= attBlear;
//
//    }
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

//    if(dot(inNormal,normalize(lightPos-position)) > 0.0){
//        vec3 halfVector = normalize((lightPos-position) + normalize(camera-position));
        vec3 halfVector = normalize(normalize(lightPos-position) + normalize(camera-position));
        specCoef = pow(dot(inNormal,halfVector), 70);
//    }
//    vec3 lightDirection = vec3(0,0,-1);
//    //uhel, pro kuzelovite svetlo, ve stupnich
//    float lightCutoff = 10;
//
//    float spotEffect = degrees(acos(dot(normalize(lightDirection),- normalize(lightPos-position))));
//    //vypocet rozmazani
//    float attBlear = clamp((spotEffect - lightCutoff) / (1-lightCutoff),0,1);
//    if (spotEffect > lightCutoff) {
//    return ambiComponent;
//    }
//
    vec3 specComponent = matSpecCol * directLightCol * specCoef;

    return ambiComponent +/* attBlear */(difComponent  + specComponent);
}
void main() {

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
	if(lightType == 2)
	gl_FragColor = vec4(blinPhong(outPosition),1.0);

    if (lightType == 3 || lightType == 4){
     gl_FragColor = vec4(vertColor, 1.0);
    }

    vec3 matDifCol = vec3(0.8, 0.9, 0.6);
        vec3 matSpecCol = vec3(1);
        vec3 ambientLightCol = vec3(0.3, 0.1, 0.5);
        vec3 directLightCol = vec3(1.0, 0.9, 0.9); // possibly n
        // better use uniforms

    	vec2 texCoord = textureCoord.xy * vec2(1, -1) + vec2(0, 1);
        vec3 inNormal = texture(normTexture, texCoord).xyz * 2 - 1;

        vec3 lVec = normalize(lightVec);

        vec3 ambiComponent = ambientLightCol * matDifCol;

        float difCoef = pow(max(0, lVec.z), 0.7) * max(0, dot(inNormal, lVec));
        vec3 difComponent = directLightCol * matDifCol * difCoef;

        vec3 reflected = reflect(-lVec, inNormal);
        float specCoef = pow(max(0, lVec.z), 0.7) * pow(max(0,
            dot(normalize(eyeVec), reflected)
        ), 70);
        vec3 specComponent = directLightCol * matSpecCol * specCoef;

    	vec4 outC = vec4(ambiComponent + difComponent + specComponent, 1.0);
//        gl_FragColor = outC * texture(diffTexture,texCoord);
        //parallax mapping
     //   outColor = vertColor;
        float scaleL = 0.04;
        float scaleK = -0.02;
        float height = texture(bumpTexture,textureCoord).r;
        float v = height * scaleL + scaleK;

        vec3 eye = normalize(eyeVec);
        vec2 offset = eye.xy / eye.z * v;
        texCoord = textureCoord + offset;
      //  outColor *= texture(diffTexture,texCoord);
//      if(texCoord.x > 1.0 || texCoord.y > 1.0 || texCoord.x < 0.0 || texCoord.y < 0)
//      discard;
//        gl_FragColor = vec4(/*vertColor */texture(diffTexture,texCoord));
//	gl_FragColor = vec4(blinPhong(outPosition),1.0);
//	gl_FragColor = vec4(normalize(outNormal) + 0.5 * 0.5, 1.0);
//	gl_FragColor = vec4(outPosition,1.0);
//    gl_FragColor = vec4(texCoord,0.0,1.0);
//    gl_FragColor = vec4(vertColor, 1.0);
    	//gl_FragColor = vec4(phong(outPosition),1.0);
//gl_FragColor = vec4(texture(normTexture,textureCoord).rgb,1.0);
    //	gl_FragColor = /* vec4(outNormal, 1.0) * texture(normTexture, textureCoord) */texture(normTexture, textureCoord);
//    gl_FragColor = vec4(normalize(lightVec),1.0);
}
