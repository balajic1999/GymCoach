# 3D Asset Pipeline

## Overview

The 3D system uses a single reusable rigged human character with swappable exercise animations and equipment models. All assets are in GLB (binary glTF) format rendered via `flutter_3d_controller`.

## Architecture

```
Character Model (GLB)
    +
Exercise Animation (embedded or separate GLB)
    +
Equipment Model(s) (GLB)
    =
Exercise Visualization
```

## Asset Sources

### Human Character — Mixamo (Adobe)

- **Source**: https://www.mixamo.com
- **License**: Free for commercial use with Adobe account
- **Format**: FBX → converted to GLB via Blender
- **Requirements**: A-pose, fitness clothing, clean topology

### Animations — Mixamo

- **Source**: https://www.mixamo.com
- **Available**: Squat, deadlift, push-up, and many exercise-adjacent animations
- **Custom**: Blender for exercises not available on Mixamo
- **Format**: FBX → retargeted to character → exported as GLB

### Equipment — Sketchfab / Custom

- **Source**: https://sketchfab.com (CC-licensed or purchased)
- **Custom**: Blender for simple equipment (barbell, dumbbell, bench)
- **Format**: GLB with Draco compression

## Processing Pipeline

```
1. Download FBX from Mixamo
        ↓
2. Import into Blender
        ↓
3. Retarget animation to character (if needed)
        ↓
4. Optimize:
   - Reduce polygon count (target: <50K)
   - Reduce texture size (max: 1024×1024)
   - Remove unused bones/meshes
        ↓
5. Export as GLB with Draco compression
        ↓
6. Test in flutter_3d_controller
        ↓
7. Upload to Supabase Storage
        ↓
8. Register in exercises table
```

## Asset Specifications

| Property | Requirement |
|----------|-------------|
| Format | GLB (binary glTF 2.0) |
| Max polygons | 50,000 per model |
| Max texture size | 1024×1024 px |
| Max file size | 5 MB per exercise bundle |
| Animation | Embedded in GLB |
| Compression | Draco mesh compression |
| Skeleton | Standard humanoid rig |

## Asset Status Workflow

```
DRAFT → REVIEW → APPROVED → PUBLISHED
                          ↘ REJECTED → (fix) → REVIEW
```

- **DRAFT**: Asset created/generated, not reviewed
- **REVIEW**: Submitted for quality/accuracy check
- **APPROVED**: Passed review, ready to publish
- **PUBLISHED**: Live in the app
- **REJECTED**: Failed review, needs fixes

## Muscle Highlighting

Muscle highlighting is achieved via:

1. **Overlay approach**: 2D SVG/image overlay showing highlighted muscles alongside the 3D model
2. **Future**: Shader-based highlighting on the 3D model itself (requires custom WebGL or Unity)

For MVP, a 2D muscle map image alongside the 3D model provides clear visual feedback without 3D shader complexity.

## Runtime Loading Strategy

1. **Core assets** (character model): Bundled with app (always available offline)
2. **Exercise animations**: Downloaded on first view, cached locally
3. **Equipment models**: Downloaded on first view, cached locally
4. **Cache management**: LRU cache with configurable size limit (default: 200MB)

## Future: AI Asset Generation Pipeline

```
Exercise Name
    ↓
AssetGenerationProvider (abstracted interface)
    ↓
3D Model Generation (provider-specific)
    ↓
Automatic Rigging
    ↓
Animation Application
    ↓
Optimization
    ↓
Preview
    ↓
Human Review
    ↓
Approval/Rejection
    ↓
Publish
```

The `AssetGenerationProvider` interface allows swapping providers without app changes.
