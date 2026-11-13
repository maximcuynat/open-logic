# File format (`.olc`)

An open-logic circuit is a UTF-8 JSON document.

## Schema 1 (v0.1)

```json
{
  "format": "open-logic",
  "schema": 1,
  "wires": [
    { "a": [-3, 2], "b": [4, 2] }
  ]
}
```

| Field | Type | Rule |
|---|---|---|
| `format` | string | Must be `"open-logic"` |
| `schema` | integer | Must be a schema version this build supports |
| `wires` | array | Wire segments |
| `wires[].a`, `wires[].b` | `[int, int]` | Grid cells; the segment must be horizontal or vertical and non-empty |

Readers **reject** the whole file on any violation (no partial load). Writers
normalise each segment so that `a` is the smaller endpoint.

## Compatibility

Pre-1.0, a new schema may be introduced by any minor version; the loader will
migrate older schemas forward. From 1.0 on, the format is stable.
