#version 460 core

layout(location = 0) in vec3 aPos;
layout(location = 1) in vec2 aTexCoord;

out vec2 TexCoord;

uniform mat4 uProjection;
uniform mat4 uView;

void main() {
  mat4 model = mat4(1.0);

  gl_Position = uProjection * uView * model * vec4(aPos, 1.0);
  TexCoord = aTexCoord;
}
