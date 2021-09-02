uniform mat4 projectionMatrix;
attribute vec4 position;
attribute mediump vec4 inputCoordinate;
varying mediump vec2 coordinate;

void main()
{
    gl_Position = projectionMatrix * position;
    coordinate = inputCoordinate.xy;
}
