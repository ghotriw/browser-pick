# BrowserPick

A tiny macOS menubar utility that intercepts links and lets you pick which browser to open them in.

**~380 KB on disk · Native Swift · No Electron · No tracking · No network calls.**

Inspired by [Velja](https://sindresorhus.com/velja) and [Choosy](https://choosy.app), but minimal, open source, and lightweight.

---

## Features

- **Menubar utility:** runs quietly in the menu bar with no Dock clutter.
- **Link interception:** registers as the default `http` and `https` handler.
- **Keyboard-driven chooser:**
  - `1`–`9` keys for fast selection.
  - Custom single-letter shortcuts per browser.
  - Arrow keys + Return, or Escape to cancel.
  - Auto-dismisses when clicking outside or switching apps.
- **Settings:**
  - Add or remove any browser/app capable of opening URLs.
  - Reorder browsers via drag-and-drop or up/down buttons (sets `1`–`9` order).
  - Chooser placement: under mouse cursor (default) or center of screen.
  - Custom display names and keyboard shortcuts.
  - Launch at Login toggle.

---

## Install

### Homebrew (recommended)

```sh
brew install --cask ghotriw/tap/browserpick
```

To update later:
```sh
brew update && brew upgrade --cask browserpick
```

### Manual download

1. Download `BrowserPick.zip` from [Releases](https://github.com/ghotriw/browser-pick/releases).
2. Unzip and move `BrowserPick.app` to `/Applications`.
3. Launch BrowserPick and follow the macOS prompt to set it as your default browser.

> **First launch note (Gatekeeper):**  
> Since the build is ad-hoc signed, macOS may block the first launch. Open **System Settings → Privacy & Security → Open Anyway**, or run:
> ```sh
> xattr -dr com.apple.quarantine /Applications/BrowserPick.app
> ```

---

## Build from source

Requires macOS 15+ and Swift Command Line Tools (no full Xcode needed).

```sh
git clone https://github.com/ghotriw/browser-pick.git
cd browser-pick
./install.sh
```

`./install.sh` builds the app, copies it to `/Applications`, and launches it.

---

## License & Credits

BrowserPick is licensed under the [MIT License](LICENSE).

- Original project created by [Vladan Čolović](https://github.com/cvladan/browser-pick).
- Fork maintained and enhanced by [Andrii Honcharov](https://github.com/ghotriw).
