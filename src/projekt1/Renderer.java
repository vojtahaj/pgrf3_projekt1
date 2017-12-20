package projekt1;

import com.jogamp.opengl.GL2GL3;
import com.jogamp.opengl.GLAutoDrawable;
import com.jogamp.opengl.GLEventListener;
import oglutils.*;
import transforms.Camera;
import transforms.Mat4;
import transforms.Mat4PerspRH;
import transforms.Vec3D;
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
    boolean boolPolygon, boolTexture = false;

    OGLBuffers buffers;
    OGLTextRenderer textRenderer;

    int shaderProgram, locMat, locLight, locCamera, locPositionLight, locTeleso;
    int typeTeleso = 1;

    OGLTexture2D texture;

    OGLTexture2D.Viewer textureViever;

    Vec3D lightPos = new Vec3D(0, 0, 5);
    List<Vec3D> lightPosArray = new ArrayList(); // pole vec3d pozic svetla

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

        lightPosArray.add(new Vec3D(0, 0, 10));
        lightPosArray.add(new Vec3D(0, 0, -10));

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
        locTeleso = gl.glGetUniformLocation(shaderProgram,"teleso");


        cam = cam.withPosition(new Vec3D(5, 5, 2.5))
                .withAzimuth(Math.PI * 1.25)
                .withZenith(Math.PI * -0.125);

        gl.glEnable(GL2GL3.GL_DEPTH_TEST);
    }

    void createBuffers(GL2GL3 gl) {
        buffers = MeshGenerator.generateGrid(gl, 20, 20, "inPosition");
        // vertices are not shared among triangles (and thus faces) so each face
        // can have a correct normal in all vertices
        // also because of this, the vertices can be directly drawn as GL_TRIANGLES
        // (three and three vertices form one face)
        // triangles defined in index buffer
        /*float[] cube = {
				// bottom (z-) face
				1, 0, 0,	0, 0, -1,
				0, 0, 0,	0, 0, -1,
				1, 1, 0,	0, 0, -1,
				0, 1, 0,	0, 0, -1,
				// top (z+) face
				1, 0, 1,	0, 0, 1,
				0, 0, 1,	0, 0, 1,
				1, 1, 1,	0, 0, 1,
				0, 1, 1,	0, 0, 1,
				// x+ face
				1, 1, 0,	1, 0, 0,
				1, 0, 0,	1, 0, 0,
				1, 1, 1,	1, 0, 0,
				1, 0, 1,	1, 0, 0,
				// x- face
				0, 1, 0,	-1, 0, 0,
				0, 0, 0,	-1, 0, 0,
				0, 1, 1,	-1, 0, 0,
				0, 0, 1,	-1, 0, 0,
				// y+ face
				1, 1, 0,	0, 1, 0,
				0, 1, 0,	0, 1, 0,
				1, 1, 1,	0, 1, 0,
				0, 1, 1,	0, 1, 0,
				// y- face
				1, 0, 0,	0, -1, 0,
				0, 0, 0,	0, -1, 0,
				1, 0, 1,	0, -1, 0,
				0, 0, 1,	0, -1, 0
		};

		int[] indexBufferData = new int[36];
		for (int i = 0; i<6; i++){
			indexBufferData[i*6] = i*4;
			indexBufferData[i*6 + 1] = i*4 + 1;
			indexBufferData[i*6 + 2] = i*4 + 2;
			indexBufferData[i*6 + 3] = i*4 + 1;
			indexBufferData[i*6 + 4] = i*4 + 2;
			indexBufferData[i*6 + 5] = i*4 + 3;
		}
		OGLBuffers.Attrib[] attributes = {
				new OGLBuffers.Attrib("inPosition", 3),
				new OGLBuffers.Attrib("inNormal", 3)
		};

		buffers = new OGLBuffers(gl, cube, attributes, indexBufferData);
	*/
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
        gl.glUniform1i(locTeleso,typeTeleso);

       if (boolPolygon)
           gl.glPolygonMode(GL2GL3.GL_FRONT_AND_BACK, GL2GL3.GL_FILL); //prepinani mezi line a fill
        else gl.glPolygonMode(GL2GL3.GL_FRONT_AND_BACK, GL2GL3.GL_LINE);

        buffers.draw(GL2GL3.GL_TRIANGLES, shaderProgram);
        if (boolTexture) {
            texture.bind(shaderProgram, "textureID", 0);
            textureViever.view(texture, -1, -1, 0.5); //umisteni textury
        }

        String text = new String(this.getClass().getName() + ": [LMB] camera, WSAD");

        textRenderer.drawStr2D(3, height - 20, text);
        textRenderer.drawStr2D(width - 90, 3, " (c) PGRF UHK");

        //System.out.println(typeTeleso);
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
                cam = cam.forward(1);
                break;
            case KeyEvent.VK_D:
                cam = cam.right(1);
                break;
            case KeyEvent.VK_S:
                cam = cam.backward(1);
                break;
            case KeyEvent.VK_A:
                cam = cam.left(1);
                break;
            case KeyEvent.VK_CONTROL:
                cam = cam.down(1);
                break;
            case KeyEvent.VK_SHIFT:
                cam = cam.up(1);
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
               // polygonMode = GL2GL3.GL_LINE;
                break;
            case KeyEvent.VK_P:
                boolPolygon = !boolPolygon;
                break;
            case KeyEvent.VK_X:
                boolTexture = !boolTexture;
                break;
            case KeyEvent.VK_Q:
                typeTeleso = 2;
                break;
            case KeyEvent.VK_E:
                typeTeleso = 3;
                break;
            case KeyEvent.VK_T:
                typeTeleso = 1;
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