# iPhone Mirror Noctalia Plugin

A native **Noctalia V5** bar widget and control panel for [iPhone Mirror](../README.md), integrated with the **Umbriel** compositor.

The plugin provides at-a-glance mirror status, one-click start/focus/stop actions, and desktop notifications on error. It interfaces cleanly with the public `iphone-mirror` command without accessing hardware devices directly.

## Features

- **Bar Widget**:
  - Live status icon (`device-mobile`) with theme-adaptive colors:
    - **Primary / Green**: Mirror session active and running
    - **Warning / Amber**: Starting up or stopping
    - **Error / Red**: Reported error
    - **Muted**: Stopped or disconnected
  - Hover tooltip showing connection and process state.
  - Left-click opens the attached control panel.
  - Right-click triggers quick action (starts mirror if stopped, stops if running).
  - Adapts automatically to horizontal and vertical Noctalia bars.
- **Control Panel**:
  - Attached pop-up panel with status header and error diagnostics.
  - One-click **Open or focus mirror** (focuses existing MPV window in Umbriel) or **Start mirror**.
  - One-click **Stop mirror** to terminate the session and release input.
  - Close on `Escape` key or click outside.
- **Headless Service**:
  - Background state poller syncing status without blocking the UI thread.
  - Deduplicated error notifications via Noctalia's notification system.

## Prerequisites

- [iPhone Mirror](../README.md) installed (`iphone-mirror` command available).
- [Noctalia](https://github.com/noctalia-dev/noctalia) V5.0.0 or later.
- [Umbriel](https://github.com/noctalia-dev/umbriel) compositor.

## Installation

### 1. Install or link plugin into Noctalia

To install as a local plugin:

```sh
mkdir -p "$HOME/.local/share/noctalia/plugins"
ln -s "$(pwd)/noctalia-plugin" "$HOME/.local/share/noctalia/plugins/iphone-mirror"
```

Alternatively, add this directory as a Noctalia path source:

```sh
noctalia msg plugins source add iphone-mirror path "$(pwd)/noctalia-plugin"
```

### 2. Enable the plugin

```sh
noctalia msg plugins enable quantumfire/iphone-mirror
```

You can also enable it via the Noctalia Settings GUI (**Settings → Plugins**).

### 3. Add to your Noctalia Bar

Add `"quantumfire/iphone-mirror:bar"` to your bar capsule group in `~/.config/noctalia/noctalia-config.toml` (or `~/.local/state/noctalia/settings.toml`), for example:

```toml
[bar.default]
end = [ "group:status" ]

  [[bar.default.capsule_group]]
  id = "status"
  members = [ "quantumfire/iphone-mirror:bar", "volume", "clock" ]
```

Or add the widget interactively using **Settings → Bar → Add Widget**.

## Development & Verification

Validate the plugin manifest, settings schema, and Luau scripts using Noctalia's author tools:

```sh
noctalia plugins lint noctalia-plugin
```

Run plugin client tests:

```sh
python3 -m unittest discover -s noctalia-plugin/tests -v
```
