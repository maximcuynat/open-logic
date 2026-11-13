class_name Palette
extends RefCounted
## Deep dark colour palette: the single source of truth for every colour in
## the app (canvas and UI).
##
## Canvas colours are fully opaque on purpose: overlapping wire rectangles
## (L corners, collinear wires) then render as one uniform shape.

# Canvas
const CANVAS_BG := Color("#0b0b0c")
const GRID_MINOR := Color("#18181a")
const GRID_MAJOR := Color("#27272b")
const GRID_AXIS := Color("#3a3a40")
const WIRE := Color("#4fc1ff")
const WIRE_HOVER := Color("#9ad9ff")
const WIRE_SELECTED := Color("#ffb454")
const WIRE_PREVIEW := Color("#2d6f93")
const CURSOR := Color("#8e8e96")

# Interface
const UI_PANEL := Color("#111113")
const UI_PANEL_RAISED := Color("#18181b")
const UI_BORDER := Color("#26262b")
const UI_HOVER := Color("#1b2730")
const UI_TEXT := Color("#d4d4d9")
const UI_TEXT_DIM := Color("#7e7e88")
const UI_ACCENT := Color("#4fc1ff")
