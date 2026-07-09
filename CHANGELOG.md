# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Several changes below are breaking (default output dimensions, the
`size:` → `version:` rename, dropped PNG parameters), so the next release is a new
major.

### Security

- `as_svg` now validates `color` / `fill` / `shape_rendering`, which were
  interpolated into the markup unescaped (SVG/HTML injection). (#8)

### Fixed

- Correct four corrupted `MAX_DIGITS` capacity tables that made automatic version
  sizing reject valid data or over-size it. (#6)
- Validate `version` / `level` / `mode`, raising a typed `QRCode::ArgumentError`
  instead of leaking a bare `IndexError` / `KeyError`. (#7)
- `Utilities.get_mask` rejects out-of-range mask patterns (off-by-one), and the
  overflow message is no longer numeric-only. (#9)
- `to_s` pads the quiet zone on all four sides (was left / top / bottom only). (#10)

### Changed

- **Breaking:** `to_s` / `as_svg` / `as_png` emit a 4-module quiet zone by default
  (ISO/IEC 18004). Pass `quiet_zone_size: 0` / `offset: 0` / `border_modules: 0`
  for the previous borderless output. (#10)
- **Breaking:** the constructor argument is now `version:`; `size:` remains as a
  deprecated alias. (#11)
- `error_correction_level` returns a non-nilable `Symbol`. (#11)

### Removed

- **Breaking:** the unused `bit_depth` / `color_type` parameters on `as_png` /
  `as_canvas`, and the dead `BitBuffer#get`. (#11)

### Build

- Manage the toolchain with [mise](https://mise.jdx.dev/) and migrate CI to
  mise-based jobs (format, docs, ameba, multi-threaded and macOS test legs). (#4)
- Apply `crystal tool format` to `export/png.cr`. (#5)
- Raise the `crystal` requirement floor to `>= 1.0.0`.

## [1.0.4]

- Baseline release; see the Git history for earlier changes.
