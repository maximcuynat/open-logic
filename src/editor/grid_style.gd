class_name GridStyle
extends RefCounted
## Visual rules of the background grid: line hierarchy and zoom fading.
##
## Minor lines (every cell) fade out as cells shrink on screen so that the
## zoomed-out view stays calm; major lines (every [constant MAJOR_EVERY]
## cells) and the axes are always drawn.

enum LineKind { MINOR, MAJOR, AXIS }

const MAJOR_EVERY := 8
const MINOR_FADE_START_PX := 6.0
const MINOR_FADE_END_PX := 18.0


## Visibility of minor lines (0 = hidden, 1 = full) for a cell of
## [param cell_px] screen pixels.
static func minor_weight(cell_px: float) -> float:
	return clampf(
		(cell_px - MINOR_FADE_START_PX) / (MINOR_FADE_END_PX - MINOR_FADE_START_PX), 0.0, 1.0
	)


## Opaque colour of minor lines at that cell size (blended from the background).
static func minor_color(cell_px: float) -> Color:
	return Palette.CANVAS_BG.lerp(Palette.GRID_MINOR, minor_weight(cell_px))


static func line_kind(index: int) -> LineKind:
	if index == 0:
		return LineKind.AXIS
	if index % MAJOR_EVERY == 0:
		return LineKind.MAJOR
	return LineKind.MINOR
