package projekt1;

import com.jogamp.opengl.GL2GL3;
import com.jogamp.opengl.GLAutoDrawable;
import com.jogamp.opengl.GLEventListener;
import oglutils.*;
import transforms.*;
import utils.MeshGenerator;

import java.awt.event.*;
import java.util.ArrayList;
import java.util.List;

/**
 * GLSL sample:<br/>
 * Draw 3D geometry, use camera and projection transformations<br/>
 * Requires JOGL 2.3.0 or newer
 *
 * @author PGRF FIM UHK
 * @version 2.0
 * @since 2015-09-05
 */

public class Renderer implements GLEventListener, MouseListener,
        MouseMotionListener, KeyListener {

    int width, height, ox, oy;
    boolean boolPolygon;

    OGLBuffers buffers;
    OGLTextRenderer textRenderer;

    int shaderProgram, locMat, locLight, locCamera, locPositionLight, locTeleso, lightType, locDirectionLight, locTexture, locAttLight, locAtten, locColored, locLightParam, locMaterial;
    int typeTeleso = 1, typeLight = 0, typeTexture = 2, atten = 0, coloured = 0, lightParamType = 0;
    int COUNTLIGHT = 4, COUNTBODY = 8, COUNT_TEXUTRE = 3;

    OGLTexture texture, normTexture, bumpTexture;

    OGLTexture2D.Viewer textureViever;

    Vec3D lightPos = new Vec3D(0, 0, -10);
    List<Vec3D> lightPosArray = new ArrayList<>(); // pole vec3d pozic svetla
    List<Vec3D> lightDirArray = new ArrayList<>(); // pole smeru svitu svetla
    List<Vec3D> lightAttArray = new ArrayList<>(); // pole s utlumem pro svetlo
    List<Vec3D> lightParam = new ArrayList<>(); //parametry svetla

    Camera cam = new Camera();
    Mat4 proj; // created in reshape()

    @Override
    public void init(GLAutoDrawable glDrawable) {
        // check whether shaders are supported
        GL2GL3 gl = glDrawable.getGL().getGL2GL3();
        OGLUtils.shaderCheck(gl);

        // get and set debug version of GL class
        gl = OGLUtils.getDebugGL(gl);
        glDrawable.setGL(gl);

        OGLUtils.printOGLparameters(gl);

        textureViever = new OGLTexture2D.Viewer(gl);
        texture = new OGLTexture2D(gl, "/textures/bricks.jpg");
        normTexture = new OGLTexture2D(gl, "/textures/bricksn.png");
        bumpTexture = new OGLTexture2D(gl, "/textures/bricksh.png");

        lightPosArray.add(new Vec3D(0, 0, -10));
        lightPosArray.add(new Vec3D(0, 0, 10));

        lightDirArray.add(new Vec3D(0, 0, 3));
        lightDirArray.add(new Vec3D(0, 0, -15));

        lightAttArray.add(new Vec3D(3, 0, 0));
        lightAttArray.add(new Vec3D(3, 0, 0));

        lightParam.add(new Vec3D(0.8, 0.9, 0.6)); //matDifColor
        lightParam.add(new Vec3D(1.0));//MatSpecColor
        lightParam.add(new Vec3D(0.3, 0.1, 0.5)); //ambientLightCol
        lightParam.add(new Vec3D(1.0, 0.9, 0.9)); //directLightCol
        lightParam.add(new Vec3D(70)); //lesk - neni uplne nejidealnejsi reseni, lepsi resit pomoci matice

        lightParam.add(new Vec3D(0.714, 0.4284, 0.18144)); //matDifColor
        lightParam.add(new Vec3D(0.393548, 0.271906, 0.166721));//MatSpecColor
        lightParam.add(new Vec3D(0.2125, 0.1275, 0.054)); //ambientLightCol
        lightParam.add(new Vec3D(1.0, 0.9, 0.9)); //directLightCol
        lightParam.add(new Vec3D(25.6)); //lesk

        gl.glTexParameteri(GL2GL3.GL_TEXTURE_2D, GL2GL3.GL_TEXTURE_WRAP_S, GL2GL3.GL_REPEAT);
        gl.glTexParameteri(GL2GL3.GL_TEXTURE_2D, GL2GL3.GL_TEXTURE_WRAP_T, GL2GL3.GL_REPEAT);

        textRenderer = new OGLTextRenderer(gl, glDrawable.getSurfaceWidth(), glDrawable.getSurfaceHeight());

        // shader files are in /shaders/ directory
        // shaders directory must be set as a source directory of the project
        // e.g. in Eclipse via main menu Project/Properties/Java Build Path/Source
        shaderProgram = ShaderUtils.loadProgram(gl, "/lvl1basic/utils/simple");
        createBuffers(gl);

        locMat = gl.glGetUniformLocation(shaderProgram, "mat");
        locLight = gl.glGetUniformLocation(shaderProgram, "lightPos");
        locCamera = gl.glGetUniformLocation(shaderProgram, "camera");
        locPositionLight = gl.glGetUniformLocation(shaderProgram, "lightPosArray");
        locTeleso = gl.glGetUniformLocation(shaderProgram, "teleso");
        lightType = gl.glGetUniformLocation(shaderProgram, "lightType");
        locDirectionLight = gl.glGetUniformLocation(shaderProgram, "lightDirArray");
        locAttLight = gl.glGetUniformLocation(shaderProgram, "lightDisArray");
        locMaterial = gl.glGetUniformLocation(shaderProgram, "materials");
        locTexture = gl.glGetUniformLocation(shaderProgram, "textureFormat");
        locAtten = gl.glGetUniformLocation(shaderProgram, "atten");
        locColored = gl.glGetUniformLocation(shaderProgram, "colPos");
        locLightParam = gl.glGetUniformLocation(shaderProgram, "lightParam");

        cam = cam.withPosition(new Vec3D(5, 5, 2.5))
                .withAzimuth(Math.PI * 1.25)
                .withZenith(Math.PI * -0.125);

        gl.glEnable(GL2GL3.GL_DEPTH_TEST);
    }

    void createBuffers(GL2GL3 gl) {
        buffers = MeshGenerator.generateGrid(gl, 20, 20, "inPosition");
    }


    @Override
    public void display(GLAutoDrawable glDrawable) {
        GL2GL3 gl = glDrawable.getGL().getGL2GL3();


        gl.glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
        gl.glClear(GL2GL3.GL_COLOR_BUFFER_BIT | GL2GL3.GL_DEPTH_BUFFER_BIT);

        gl.glUseProgram(shaderProgram);
        gl.glUniformMatrix4fv(locMat, 1, false,
                ToFloatArray.convert(cam.getViewMatrix().mul(proj)), 0);
        gl.glUniform3fv(locLight, 1, ToFloatArray.convert(lightPos), 0);
        gl.glUniform3fv(locCamera, 1, ToFloatArray.convert(cam.getEye()), 0);
        gl.glUniform3fv(locPositionLight, lightPosArray.size(), ToFloatArray.convert(lightPosArray), 0);
        gl.glUniform3fv(locDirectionLight, lightDirArray.size(), ToFloatArray.convert(lightDirArray), 0);
        gl.glUniform3fv(locAttLight, lightAttArray.size(), ToFloatArray.convert(lightAttArray), 0);
        gl.glUniform3fv(locMaterial, lightParam.size(), ToFloatArray.convert(lightParam),0);
        gl.glUniform1i(locTeleso, typeTeleso);
        gl.glUniform1i(lightType, typeLight);
        gl.glUniform1i(locTexture, typeTexture);
        gl.glUniform1i(locAtten, atten);
        gl.glUniform1i(locColored, coloured);
        gl.glUniform1i(locLightParam, lightParamType);

        if (boolPolygon)
            gl.glPolygonMode(GL2GL3.GL_FRONT_AND_BACK, GL2GL3.GL_LINE); //prepinani mezi line a fill
        else gl.glPolygonMode(GL2GL3.GL_FRONT_AND_BACK, GL2GL3.GL_FILL);

        buffers.draw(GL2GL3.GL_TRIANGLES, shaderProgram);
        texture.bind(shaderProgram, "diffTexture", 0);
        normTexture.bind(shaderProgram, "normTexture", 1);
        bumpTexture.bind(shaderProgram, "bumpTexture", 2);


        String text = new String(this.getClass().getName() + ": [LMB] camera, WSAD");

        textRenderer.drawStr2D(3, height - 20, text);
        textRenderer.drawStr2D(width - 90, 3, " (c) PGRF UHK");
    }

    @Override
    public void reshape(GLAutoDrawable drawable, int x, int y, int width,
                        int height) {
        this.width = width;
        this.height = height;
        proj = new Mat4PerspRH(Math.PI / 4, height / (double) width, 0.01, 1000.0);
        textRenderer.updateSize(width, height);
    }

    @Override
    public void mouseClicked(MouseEvent e) {
    }

    @Override
    public void mouseEntered(MouseEvent e) {
    }

    @Override
    public void mouseExited(MouseEvent e) {
    }

    @Override
    public void mousePressed(MouseEvent e) {
        ox = e.getX();
        oy = e.getY();
    }

    @Override
    public void mouseReleased(MouseEvent e) {
    }

    @Override
    public void mouseDragged(MouseEvent e) {
        cam = cam.addAzimuth((double) Math.PI * (ox - e.getX()) / width)
                .addZenith((double) Math.PI * (e.getY() - oy) / width);
        ox = e.getX();
        oy = e.getY();
    }

    @Override
    public void mouseMoved(MouseEvent e) {
    }

    @Override
    public void keyPressed(KeyEvent e) {
        switch (e.getKeyCode()) {
            case KeyEvent.VK_W:
                cam = cam.forward(0.1);
                break;
            case KeyEvent.VK_D:
                cam = cam.right(0.1);
                break;
            case KeyEvent.VK_S:
                cam = cam.backward(0.1);
                break;
            case KeyEvent.VK_A:
                cam = cam.left(0.1);
                break;
            case KeyEvent.VK_CONTROL:
                cam = cam.down(0.1);
                break;
            case KeyEvent.VK_SHIFT:
                cam = cam.up(0.1);
                break;
            case KeyEvent.VK_SPACE:
                cam = cam.withFirstPerson(!cam.getFirstPerson());
                break;
            case KeyEvent.VK_R:
                cam = cam.mulRadius(0.9f);
                break;
            case KeyEvent.VK_F:
                cam = cam.mulRadius(1.1f);
                break;
            case KeyEvent.VK_L:
                typeLight = (typeLight + 1) % (COUNTLIGHT + 1);
                coloured = 0;
                System.out.println("L - " + typeLight);
                break;
            case KeyEvent.VK_P:
                boolPolygon = !boolPolygon;
                break;
            case KeyEvent.VK_Q:
                typeTeleso = (typeTeleso + 1) % COUNTBODY;
                System.out.println("Q - " + typeTeleso);
                break;
            case KeyEvent.VK_M:
                typeTexture = (typeTexture + 1) % COUNT_TEXUTRE;
                coloured = 0;
                System.out.println("M - " + typeTexture);
                break;
            case KeyEvent.VK_U:
                atten = (atten + 1) % 2;
                coloured = 0;
                System.out.println("U - " + atten);
                break;
            case KeyEvent.VK_C:
                coloured = (coloured + 1) % 4;
                System.out.println("C - " + coloured);
                break;
            case KeyEvent.VK_V:
                if (lightParamType == 5)
                    lightParamType = 0;
                else lightParamType = 5;
                System.out.println("V - " + lightParamType);
                break;
        }
    }

    @Override
    public void keyReleased(KeyEvent e) {
    }

    @Override
    public void keyTyped(KeyEvent e) {
    }

    @Override
    public void dispose(GLAutoDrawable glDrawable) {
        glDrawable.getGL().getGL2GL3().glDeleteProgram(shaderProgram);
    }

}