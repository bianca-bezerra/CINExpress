shader_type canvas_item;

uniform float flash : hint_range(0.0, 1.0) = 0.0;
uniform float brilho_pos = -1.0;
uniform float brilho_largura : hint_range(0.0, 1.0) = 0.12;
uniform vec4 brilho_cor : source_color = vec4(1.0, 1.0, 1.0, 0.7);

void fragment() {
	vec4 tex = COLOR;

	vec3 cor = mix(tex.rgb, vec3(1.0), flash);

	vec2 tamanho = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 texel = floor(UV * tamanho);
	float diagonal = (texel.x + texel.y) / (tamanho.x + tamanho.y);

	float faixa = step(brilho_pos - brilho_largura * 0.5, diagonal)
			* step(diagonal, brilho_pos + brilho_largura * 0.5);

	cor = mix(cor, brilho_cor.rgb, faixa * brilho_cor.a);

	COLOR = vec4(cor, tex.a);
}
