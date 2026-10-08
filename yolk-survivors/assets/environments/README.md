# Cooking environments

Original artwork generated with the built-in image_gen tool, using assets/sprites/Enemies/Enemy_1.png as a style reference. No external assets downloaded.

- coral_skillet.png and warm_kitchen.png: wave 1.
- sage_casserole.png and sage_kitchen.png: wave 2 onward.

Configuration: resources/environments/*.tres. Each ArenaEnvironment defines first_wave, textures, vessel_size/offset, movement_bounds, oval/rounded corners, and camera_zoom. Add another resource to Environment.environments in arena.tscn to extend the progression. Bounds are world coordinates for unit origins; visual margins leave room for sprites.

Generation prompts (built-in tool, stylized-concept; transparent background for vessels):

## pan

An original reusable game sprite: one large wide rounded rectangular frying skillet seen directly top-down, with a short wooden handle extending left, centered and fully visible. Entire outer background transparent alpha; interior filled matte charcoal gray with a few subtle oil marks, very quiet empty playable space. Interior occupies x 14% to 86% and y 22% to 78% of the image. Wide landscape 1536x1024 canvas. Thick near-black rounded outlines, simple flat colors, muted coral red exterior rim, warm cream metal highlights, subtle cel shading. Cute hand drawn cartoon style matching the supplied egg enemy's simple graphic art. No characters, no food, no letters, no UI. This is a battlefield surface, keep interior large and uncluttered.

## pot

An original reusable game sprite: one oval cooking casserole pot seen directly top-down, centered and fully visible with two short small handles left and right. Transparent alpha outside the pot. Oval interior fills x 16% to 84% and y 16% to 84% of canvas, empty quiet matte deep desaturated blue green cooking surface. Landscape 1536x1024 canvas. Thick near-black rounded outlines, flat colors and restrained cel shading, muted sage teal enamel outer rim, warm ivory highlights, small copper rivets. Cute hand drawn cartoon matching supplied egg enemy graphic style. No food, characters, text or UI. Large uncluttered interior for combat.

## kitchen

Original 1536x1024 landscape background texture for a top-down cartoon cooking survival game. Bird's eye orthographic view of a warm cream and dusty coral enamel gas stovetop set in a honey wood countertop. Center 65% wide by 60% high is quiet simple cream stovetop where a separate huge skillet sprite will be overlaid, with faint burner grates underneath. Restrained kitchen details near outer edges only: a folded cream tea towel, little salt jar, rounded stove knobs along bottom. Thick dark hand drawn outlines, flat muted colors, minimal cel shading, matching cute egg enemy supplied. No pan, no pot, no characters, no text, no UI. Readable quiet background, seamless graphic style, no photorealism.

## hearth

Original 1536x1024 landscape background texture for a top-down cartoon cooking survival game, second cooking environment. Orthographic bird's eye view of a cool sage teal enamel stove on a warm terracotta tiled kitchen counter with ivory grout. Center is quiet sage stovetop with a simple large circular burner grate, reserved for overlaying a separate pot sprite. Sparse props strictly near outer edges: a folded pale yellow towel and small wooden spoon, copper accents and simple ivory knobs at bottom. Thick near-black hand drawn outlines, flat muted colors, minimal cel shading, matching cute egg enemy supplied. No pot or pan, no characters, no food, no text, no UI; quiet readable center.
