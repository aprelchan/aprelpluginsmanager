# Aprel Plugins Manager

The noofficial plugin manager for Aprel Gram — install, update, and manage plugins directly from pluins. Lightweight, fast, built natively on the extera plugin API.
Original - https://git.kangel.xyz/KangelPlugins/PluginManager

---
## Features

- Install and update plugins from the [Plugins Store](https://git.kangel.xyz/KangelPlugins/Plugins-Store)
- Deep-link plugin installation (`tg://apm?install=...`)
- Plugin version picker with changelog support
- Inline bot search for quick plugin discovery
- Dependency resolution with automatic install prompts
- Plugin collections — export and import plugin sets
- AI-powered plugin search
- Pill integration in the search bar
- Smart search with trigram-based fuzzy matching
- Inline search in chat
- Plugin verification — DEX/SO analysis, dangerous API detection, network call audit
- Full localization: English, Russian, Ukrainian, German, Spanish, French, Portuguese

## Building

### Requirements

- uv 
- Python 3.11

### Build

```sh
pip install elyxbuilder-cli
elyb build
```
Linux:
`./scripts/build-uv.sh`
Windows:
`./scripts/build-uv.bat`

## Community

Forum Aprel Team: [@aprelteamsupport](https://t.me/aprelteamsupport)
Plugin Channel: [Aprel Plugins](https://t.me/aprelplugins)
Plugin Channel: [Aprel Plugins Chat](https://t.me/aprelpluginschat)

## License

[GPL v3.0](LICENSE) 2026
