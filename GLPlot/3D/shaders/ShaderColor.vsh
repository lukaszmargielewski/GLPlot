uniform mat4 mvp;
attribute vec4 position;
attribute vec4 color;
varying lowp vec4 fragment_color;

void main()
{
    gl_Position = mvp * position;
    fragment_color = color;
}