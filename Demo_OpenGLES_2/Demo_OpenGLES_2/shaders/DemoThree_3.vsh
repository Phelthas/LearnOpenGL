uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;
attribute vec4 position;
attribute mediump vec4 inputCoordinate;
varying mediump vec2 coordinate;

void main()
{
    gl_Position = projectionMatrix * viewMatrix * modelMatrix * position;
    coordinate = inputCoordinate.xy;
}
