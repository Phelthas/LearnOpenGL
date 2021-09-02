varying mediump vec2 coordinate;
uniform sampler2D texture;
                                                   
void main()
{
    gl_FragColor = texture2D(texture, coordinate);
}
