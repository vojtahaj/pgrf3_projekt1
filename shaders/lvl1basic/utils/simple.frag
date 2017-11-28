#version 150
in vec2 inPosition;
in vec3 vertColor;
in vec3 outPosition;
in vec3 outNormal;

uniform vec3 lightPos;
uniform vec3 camera;

vec3 phong(vec3 position){
     vec3 inNormal = outNormal;

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
vec3 blinPhong(vec3 position){
    vec3 inNormal = outNormal;

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
    vec3 specComponent = matSpecCol * directLightCol * specCoef;

    return ambiComponent + difComponent + specComponent;
}
void main() {
//	gl_FragColor = vec4(vertColor, 1.0);
	//gl_FragColor = vec4(phong(outPosition),1.0);
	gl_FragColor = vec4(vertColor, 1.0);
	//gl_FragColor = vec4(blinPhong(outPosition),1.0);
}
