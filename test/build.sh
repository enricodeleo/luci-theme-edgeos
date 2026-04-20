#!/bin/bash
# Build and run an OpenWrt test container with luci-theme-edgeos
# Uses rootless podman — no privileges needed, just port forwarding
set -e

OPENWRT_VERSION="${1:-24.10.0}"
MIRROR="https://downloads.openwrt.org"
IMAGE_NAME="openwrt-edgeos-test"
CONTAINER_NAME="openwrt-edgeos"
HOST_PORT="${2:-8080}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
THEME_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== luci-theme-edgeos test container ==="
echo "OpenWrt version: ${OPENWRT_VERSION}"
echo "LuCI will be at: http://localhost:${HOST_PORT}"
echo ""

# Step 1: Download OpenWrt rootfs if not cached
ROOTFS_DIR="${SCRIPT_DIR}/.cache"
ROOTFS_FILE="${ROOTFS_DIR}/openwrt-${OPENWRT_VERSION}-x86-64-rootfs.tar.gz"
ROOTFS_URL="${MIRROR}/releases/${OPENWRT_VERSION}/targets/x86/64/openwrt-${OPENWRT_VERSION}-x86-64-rootfs.tar.gz"

mkdir -p "${ROOTFS_DIR}"

if [ ! -f "${ROOTFS_FILE}" ]; then
    echo "[1/4] Downloading OpenWrt ${OPENWRT_VERSION} rootfs..."
    curl -fSL -o "${ROOTFS_FILE}" "${ROOTFS_URL}"
else
    echo "[1/4] Using cached rootfs: ${ROOTFS_FILE}"
fi

# Step 2: Import into podman
echo "[2/4] Importing into podman..."
podman rm -f "${CONTAINER_NAME}" 2>/dev/null || true
podman rmi "${IMAGE_NAME}" 2>/dev/null || true
podman import "${ROOTFS_FILE}" "${IMAGE_NAME}" >/dev/null

# Step 3: Create container with theme files mounted
echo "[3/4] Creating container..."
podman run -d \
    --name "${CONTAINER_NAME}" \
    -p "${HOST_PORT}:80" \
    -v "${THEME_DIR}/htdocs/luci-static/edgeos:/www/luci-static/edgeos:ro" \
    -v "${THEME_DIR}/ucode/template/themes/edgeos:/usr/share/ucode/template/themes/edgeos:ro" \
    "${IMAGE_NAME}" \
    /bin/true

# Step 4: Start the services inside the container
echo "[4/4] Starting LuCI services..."
podman exec "${CONTAINER_NAME}" sh -c '
    # Initialize OpenWrt environment
    export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

    # Create required directories
    mkdir -p /tmp/run /tmp/lock /tmp/log

    # Create ubus socket directory
    mkdir -p /var/run

    # Start ubus daemon
    ubusd &
    sleep 1

    # Start rpcd (LuCI backend)
    rpcd &
    sleep 1

    # Configure uhttpd for our port
    sed -i "s/listen_http\t0.0.0.0:80/listen_http\t0.0.0.0:80/" /etc/config/uhttpd 2>/dev/null || true
    sed -i "s/listen_http\t\[::\]:80/listen_http\t0.0.0.0:80/" /etc/config/uhttpd 2>/dev/null || true

    # Start uhttpd (LuCI web server)
    uhttpd -f -p 0.0.0.0:80 -h /www -I /index.html -x /cgi-bin -t 60 -T 30 -A 1 -n 3 -N 200 -R -D -C /etc/uhttpd.crt -K /etc/uhttpd.key 2>/dev/null || \
    uhttpd -f -p 0.0.0.0:80 -h /www &
    sleep 1

    # Set the theme
    uci set luci.main.mediaurlbase="/luci-static/edgeos" 2>/dev/null || true
    uci commit luci 2>/dev/null || true

    echo "Services started"
'

# Give uhttpd a moment
sleep 2

echo ""
echo "=== Ready! ==="
echo "Open http://localhost:${HOST_PORT} in your browser"
echo ""
echo "Login: root (no password)"
echo ""
echo "To select the EdgeOS theme:"
echo "  podman exec ${CONTAINER_NAME} uci set luci.main.mediaurlbase='/luci-static/edgeos'"
echo "  Then reload the browser"
echo ""
echo "To stop:  podman rm -f ${CONTAINER_NAME}"
echo "To shell: podman exec -it ${CONTAINER_NAME} sh"
