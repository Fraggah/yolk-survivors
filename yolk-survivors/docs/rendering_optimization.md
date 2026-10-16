# Hydrant optimization: pooling and GPU instancing

The measured bottleneck was immediate-mode drawing of three antialiased circles for each droplet, with many transform changes, across hundreds of particles. Pooling alone does not reduce the rendering submissions of those primitives.

MayonnaiseParticles now owns 1800 reusable particle records and one MultiMeshInstance2D with 5400 fixed instance slots. Each particle contributes border/body/highlight quads using one shared QuadMesh and one antialiased circle shader. Instance colors preserve every emitter's editable palette. All layers share a single instanced draw rather than hundreds of independent _draw commands. visible_instance_count hides inactive slots; records return to a free list on expiry/clear, and swap-removal avoids shifting the active array. Motion remains on CPU; drawing is GPU-instanced. This is not a GPU particle simulation.

Gameplay values, hit queries, damage frequency, particle emission counts, and particle lifetimes are preserved. Native render checked using capture_mayonnaise.gd. Automated tests verify fixed capacity, reuse, no stale instances, idempotent clear, pause, continuous damage/piercing and wave transitions.

Two post-change benchmarks, same 180 moving enemies and local RTX 3070 Ti/Mobile renderer: six complete Hydrant improved from 10.2–10.4 FPS to 29.0–33.3 FPS. Total draw calls decreased from 1785–1825 to 267–272. One Hydrant improved from 31–35 FPS to 43.8–46.2 FPS. The no-damage diagnostic drew approximately 39 total calls with particles versus 38 without them, consistent with one particle batch. Peak particle counts increased to 442–483 because the smoother frame rate keeps the configured emission cadence; emission settings were not reduced. The next bottlenecks include damage feedback and enemy processing; these results do not imply a universal FPS guarantee.

Reproduction: documentacion-local/validacion/benchmark_hydrant.gd. Before: hydrant-benchmark-run1.json and hydrant-benchmark-run2.json. After: hydrant-benchmark-optimized.json and hydrant-benchmark-optimized-run2.json.

Primary references for Godot 4.4:
- https://docs.godotengine.org/en/4.4/classes/class_multimesh.html
- https://docs.godotengine.org/en/4.4/classes/class_multimeshinstance2d.html
- https://docs.godotengine.org/en/4.4/tutorials/performance/using_multimesh.html

Apply this pattern to repeated cosmetic visuals with shared geometry/materials. Pooling addresses creation/deletion/allocation spikes; instancing/batching addresses submission overhead. Enemy AI/physics, hit-query frequency and per-hit UI need separate measurements and optimizations. MultiMesh instances share one culling region and draw order group, so independently sorted actors or interactive hitboxes should not be migrated blindly.
