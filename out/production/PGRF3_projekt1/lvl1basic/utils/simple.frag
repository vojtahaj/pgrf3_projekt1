#version 150
const int LIGHTCOUNT = 2;

in vec2 inPosition;
in vec3 vertColor;
in vec3 outPosition;
in vec3 outNormal;
in vec2 textureCoord;
in vec3 lightVec[LIGHTCOUNT];
in vec3 eyeVec;

out vec3 outColor;
uniform vec3 lightPos;
uniform vec3 lightPosArray[LIGHTCOUNT];
uniform vec3 lightDirArray[LIGHTCOUNT];
uniform vec3 lightDisArray[LIGHTCOUNT];
uniform vec3 camera;
uniform sampler2D diffTexture;
uniform sampler2D normTexture;
uniform sampler2D bumpTexture;
uniform int teleso;
uniform int lightType;
uniform int textureFormat; // druh textury - 2-normalMapping, 1-parallaxMapp
uniform int atten; // utlum ano/ne

vec2 offset(){
    float scaleL = 0.04;
    float scaleK = -0.02;
    float height = texture(bumpTexture, textureCoord).r;
    float v = height * scaleL + scaleK;

    vec3 eye = normalize(eyeVec);
    vec2 offset = eye.xy / eye.z * v;
   return vec2(textureCoord + offset);
}
void light(vec3 position, int numberOfLight, out vec3 ambient,out vec3 diffuse, out vec3 specular){
     vec3 inNormal = normalize(outNormal);

     vec3 matDifCol = vec3(0.8, 0.9, 0.6);
     vec3 matSpecCol = vec3(1.0);
     vec3 ambientLightCol = vec3(0.3, 0.1, 0.5);
     vec3 directLightCol = vec3(1.0, 0.9, 0.9);

    vec3 dirLight, dirCamera, reflected;
    float difCoef = 0.0;
    //pro mapovani textury
    if (textureFormat > 0){
        dirLight = normalize(lightVec[numberOfLight]);
        dirCamera = normalize(eyeVec);
        vec2 texCoord = textureCoord.xy * vec2(1, -1) + vec2(0, 1);
        if (textureFormat == 1){ //1 - paralaxMapping
            texCoord = offset();
            inNormal = texture(normTexture,texCoord).xyz * 2 -1;
        }
        if (textureFormat == 2) // normalMap
            inNormal = texture(normTexture, texCoord).xyz * 2 - 1;
    }
    else {
    //smer svetla bez textury
        dirLight = normalize(lightPosArray[numberOfLight] - position);
        dirCamera = normalize(position - camera);
    }
     ambient = ambientLightCol * matDifCol;

    if (textureFormat > 0){
        difCoef = pow(max(0, dirLight.z), 0.7) * max(0, dot(inNormal, dirLight));
        reflected = reflect(- dirLight, inNormal);
    }
    else {
        difCoef = max(0, dot(inNormal, dirLight));
        reflected = reflect(normalize(position - lightPosArray[numberOfLight]), inNormal);
    }
      diffuse = directLightCol * matDifCol * difCoef;
//     vec3 difComponent = directLightCol * matDifCol * difCoef;

     float specCoef = 0.0;

     if (lightType == 1) {// phong
        specCoef = pow(max(0, dot(dirCamera, reflected)), 70);
     }
     if (lightType == 1 && textureFormat > 0){//phong s texturami
        specCoef = pow(max(0, dirLight.z), 0.7) * pow(max(0, dot(dirCamera, reflected)), 70);
     }
     specular = directLightCol * matSpecCol * specCoef;

     vec3 halfVector = normalize(dirLight + dirCamera);
     if (lightType == 2){//blinphong
        //float specCoef = pow(max(0, dot(normalize(camera-position),reflected)), 70);
        if(dot(inNormal, normalize(dirLight)) > 0.0){
            specCoef = pow(dot(inNormal, halfVector), 70);
        }
     }
     if (lightType == 2 && textureFormat > 0){
        if(dot(inNormal, normalize(dirLight)) > 0.0){
            specCoef = pow(max(0, dirLight.z), 0.7) * pow(dot(inNormal, halfVector), 70);
        }
     }

     specular = directLightCol * matSpecCol * specCoef;
     //reflektorove svetlo
     vec3 lightDirection = lightDirArray[numberOfLight];
     //uhel, pro kuzelovite svetlo, ve stupnich
     float lightCutoff = 60;

     //utlum
     float att = 0.0;
     float lightDistance = length(dirLight); // vzdalenost od svetla na povrch

    if(difCoef > 0.0){
        att = 1.0 / lightDisArray[numberOfLight].x +
         lightDisArray[numberOfLight].y * lightDistance +
         lightDisArray[numberOfLight].z * lightDistance * lightDistance;
    }

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
        if(atten == 1){
        specular *= att * specComponent;
        diffuse *= att;
     }
    }

}
void main() {

	vec3 ambientSum = vec3(0);
	vec3 diffSum = vec3(0);
	vec3 specSum = vec3(0);

	vec4 outC = vec4(0);

	vec3 ambient, diffuse, specular;
    if(lightType > 0 && lightType < 3){
	    for (int i = 0; i<LIGHTCOUNT; i++){
	     light(outPosition, i, ambient, diffuse, specular);
	     ambientSum += ambient;
	     diffSum += diffuse;
	     specSum += specular;
	    }
	    ambientSum /= LIGHTCOUNT;
	    outC = vec4(ambientSum + diffSum + specSum, 1.0);
    }

    if (textureFormat == 1) gl_FragColor = outC * texture(diffTexture, offset()); // paralaxMap
    if (textureFormat == 2) gl_FragColor = outC * texture(diffTexture, textureCoord);// normalMap
    if (textureFormat == 0 && (lightType != 3 || lightType != 4)) gl_FragColor = outC;
    if (lightType == 3 || lightType == 4) gl_FragColor = vec4(vertColor, 1.0);
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
