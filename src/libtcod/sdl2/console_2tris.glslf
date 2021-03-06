R"(
uniform ivec2 v_tiles_shape; // Size of the tileset.
uniform sampler2D t_tileset;

uniform ivec2 v_console_shape; // Size of the console.
uniform sampler2D t_console_tile; // Packed tileset coordinates.
uniform sampler2D t_console_fg;
uniform sampler2D t_console_bg;

varying vec2 v_coord; // Simple 0-1 quad coordinate.

void main(void)
{
  // The sample coordinate for per-tile console variables.
  vec2 console_pos = floor(v_coord * v_console_shape);
  console_pos += vec2(0.5, 0.5); // Offset to the center (for sampling.)
  console_pos /= v_console_shape; // Scale to fit in t_console_X textures.

  // Coordinates within a tile.
  vec2 tile_interp = fract(v_coord * v_console_shape);

  vec4 tile_encoded = vec4(texture2D(t_console_tile, console_pos));

  // Unpack tileset index.
  vec2 tile_address = vec2(tile_encoded.x * 0xff + tile_encoded.y * 0xff00,
                           tile_encoded.z * 0xff + tile_encoded.w * 0xff00);

  // Apply tile_interp and scale to fix within the tileset.
  tile_address = (tile_address + tile_interp) / v_tiles_shape;

  vec4 tile_color = texture2D(t_tileset, tile_address);

  vec4 bg = texture2D(t_console_bg, console_pos);
  vec4 fg = texture2D(t_console_fg, console_pos);
  fg.rgb *= tile_color.rgb;

  gl_FragColor = mix(bg, fg, tile_color.a);
}
)"
