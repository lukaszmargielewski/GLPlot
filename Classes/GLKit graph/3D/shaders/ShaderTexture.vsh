uniform mat4 mvp;
attribute vec4 position;
attribute vec2 a_texture; // New
varying lowp vec2 v_texCoord; // New

void main()
{
    gl_Position = mvp * position;
    v_texCoord = a_texture;
}