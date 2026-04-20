# luci-theme-edgeos

An [EdgeOS 3+](https://ui.isArray.com/edgeos)-inspired theme for [OpenWrt](https://openwrt.org/) 24.x [LuCI](https://github.com/openwrt/luci) web interface.

Dark sidebar navigation, top status bar, card-based content area — the look and feel of Ubiquiti's EdgeRouter dashboard on your OpenWrt device.

## Preview

```
┌──────────────────────────────────────────────────┐
│  ◉ myrouter        CPU  MEM  UPTIME    logout ▸  │
├─────────┬────────────────────────────────────────┤
│  Status │  Interfaces                              │
│  System │                                          │
│  Network│  ┌──────────────┐  ┌──────────────┐     │
│  WiFi   │  │  WAN         │  │  LAN         │     │
│  DHCP   │  │  ■ Active    │  │  ■ Active    │     │
│  FW     │  │  192.168.1.1 │  │  10.0.0.1    │     │
│         │  └──────────────┘  └──────────────┘     │
│         │                                          │
│         │  ┌──────────────────────────────────┐    │
│         │  │  Wireless Configuration           │    │
│         │  │                                    │    │
│         │  │  Interface  [ wlan0          ▾ ]   │    │
│         │  │  SSID       [ MyNetwork        ]   │    │
│         │  │  Channel    [ 6             ▾ ]     │    │
│         │  │                                    │    │
│         │  │           [ Save ]  [ Apply ]      │    │
│         │  └──────────────────────────────────┘    │
└─────────┴────────────────────────────────────────┘
```

## Features

- **EdgeOS 3+ layout** — dark sidebar with icon navigation, top status bar, card-based content
- **Fully responsive** — sidebar collapses on tablet/mobile with hamburger toggle
- **Login page** — centered card with dark background, matching EdgeOS auth screen
- **CBI compatible** — all standard LuCI pages (firewall, wireless, DHCP, etc.) render correctly
- **No external dependencies** — vanilla CSS + JS, lightweight for embedded devices
- **CSS custom properties** — easy to customize colors, spacing, and radii via `:root` variables

## Requirements

- OpenWrt 24.x (or any LuCI release using ucode templates)
- `luci-base`

## Installation

### Option A: Pre-built .ipk

```bash
# Transfer the .ipk to your router
scp luci-theme-edgeos_*.ipk root@192.168.1.1:/tmp/

# Install
ssh root@192.168.1.1
opkg install /tmp/luci-theme-edgeos_*.ipk
```

### Option B: Build from source

```bash
# Clone into your OpenWrt buildroot feeds directory
git clone https://github.com/YOUR_USERNAME/luci-theme-edgeos.git feeds/luci-theme-edgeos

# Add to feeds.conf
echo "src-link luci-theme-edgeos feeds/luci-theme-edgeos" >> feeds.conf

# Update feeds and build
./scripts/feeds update luci-theme-edgeos
./scripts/feeds install luci-theme-edgeos
make package/luci-theme-edgeos/compile V=s
```

### Option C: Quick drop-in (no compilation)

Copy files directly to a running OpenWrt device:

```bash
# CSS + JS
scp -r htdocs/luci-static root@192.168.1.1:/www/

# Templates
scp -r ucode/template root@192.168.1.1:/usr/share/ucode/
```

> Note: Drop-in requires LuCI restart: `/etc/init.d/uhttpd restart`

## Activating

After installation, go to **System → System → Language and Style** and select **EdgeOS** from the theme dropdown.

## Customization

All visual properties are CSS custom variables in `cascade.css`:

```css
:root {
    --sidebar-bg: #1a1a2e;      /* Sidebar background */
    --sidebar-active: #3b82f6;   /* Active item accent */
    --topbar-bg: #16213e;        /* Top bar background */
    --primary: #3b82f6;          /* Primary blue */
    --success: #10b981;          /* Green */
    --warning: #f59e0b;          /* Amber */
    --danger: #ef4444;           /* Red */
    --sidebar-width: 220px;      /* Sidebar width */
}
```

Edit these variables to create your own color scheme without touching the rest of the CSS.

## File Structure

```
luci-theme-edgeos/
├── Makefile                                    # OpenWrt package definition
├── htdocs/luci-static/edgeos/
│   ├── cascade.css                             # All visual styling
│   └── sidebar.js                              # Mobile sidebar toggle
├── ucode/template/themes/edgeos/
│   ├── header.ut                               # Sidebar + top bar + page wrapper
│   └── footer.ut                               # Page wrapper close + scripts
└── root/usr/share/rpcd/acl.d/
    └── luci-theme-edgeos.json                  # ACL permissions
```

## License

MIT
