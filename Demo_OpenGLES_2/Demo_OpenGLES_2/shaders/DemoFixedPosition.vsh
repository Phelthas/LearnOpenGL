attribute vec4 position;
uniform mat4 projectionMatrix;

void main()
{
    gl_Position = projectionMatrix * position;
}
