#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

trap 'echo "[valhalla] Installation failed near line $LINENO." >&2' ERR

VERBOSE=0
CHECK_ONLY=0
DRY_RUN=0
ORIGINAL_ARGS=()
DOMAIN_NAME_VALUE="${DOMAIN_NAME_VALUE:-${VALHALLA_DOMAIN:-valhalla}}"

usage() {
  cat <<'EOF'

ᚠᚪᛚᚻᚪᛚᛚᚪ - A self-hosted homelab stack for Linux servers

Usage: ./install.sh [options]

Options:
  -h, --help        Show this help message and exit 𓊝
  -v, --verbose     Show detailed installation steps and commands ⚔︎
  -c, --check       Verify whether the stack appears installed and working
  --dry-run         Show the actions that would be taken without changing the host
EOF
}

log() {
  echo "[valhalla] $*"
}

verbose_log() {
  if [[ "$VERBOSE" -eq 1 ]]; then
    echo "[valhalla][verbose] $*"
  fi
}

run_logged() {
  if [[ "$VERBOSE" -eq 1 ]]; then
    printf '+ '
    printf '%q ' "$@"
    printf '\n'
  fi
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[valhalla][dry-run] $*"
    return 0
  fi
  "$@"
}

run_privileged() {
  if [[ -n "$SUDO" ]]; then
    run_logged "$SUDO" "$@"
  else
    run_logged "$@"
  fi
}

detect_hostname() {
  hostnamectl --static 2>/dev/null || hostname 2>/dev/null || uname -n 2>/dev/null || echo "valhalla"
}

detect_username() {
  if [[ -n "${SUDO_USER:-}" ]]; then
    echo "$SUDO_USER"
  elif [[ -n "${USER:-}" ]]; then
    echo "$USER"
  else
    whoami 2>/dev/null || echo "valhalla"
  fi
}

detect_primary_ip() {
  local ip=""
  ip="$(hostname -I 2>/dev/null | awk '{for (i = 1; i <= NF; i++) if ($i !~ /^127\./) { print $i; exit } }')"
  if [[ -z "$ip" ]]; then
    ip="$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}')"
  fi
  if [[ -z "$ip" ]]; then
    ip="127.0.0.1"
  fi
  echo "$ip"
}

detect_package_manager() {
  case "${ID:-}" in
    debian|ubuntu|raspbian|linuxmint|pop|kali|zorin|elementary|parrot)
      echo "apt"
      ;;
    *)
      echo "unsupported"
      ;;
  esac
}

detect_tailscale_ip() {
  local ip=""
  if command -v tailscale >/dev/null 2>&1; then
    ip="$(tailscale ip -4 2>/dev/null | head -n 1 || true)"
  fi
  if [[ -z "$ip" ]]; then
    ip="${IP_VALUE:-}"
  fi
  if [[ -z "$ip" ]]; then
    ip="100.127.100.1"
  fi
  echo "$ip"
}

wait_for_stack() {
  local compose_file="$1"
  local stack_name="$2"
  local timeout="${3:-180}"
  local start_time elapsed

  start_time="$(date +%s)"
  while true; do
    if docker compose -f "$compose_file" ps --services --status running 2>/dev/null | grep -q .; then
      return 0
    fi

    elapsed=$(( $(date +%s) - start_time ))
    if (( elapsed >= timeout )); then
      log "Stack $stack_name did not report running services within ${timeout}s."
      return 1
    fi

    sleep 5
  done
}

confirm_yes() {
  local prompt="$1"
  local default_value="${2:-n}"
  local answer=""

  if [[ ! -t 0 ]]; then
    return 1
  fi

  while true; do
    read -r -p "$prompt " answer
    answer="${answer:-$default_value}"
    case "$answer" in
      [Yy]|[Yy][Ee][Ss]) return 0 ;;
      [Nn]|[Nn][Oo]|"") return 1 ;;
      *) echo "Please answer yes or no." ;;
    esac
  done
}

check_hardware_requirements() {
  local cpu_cores mem_kb disk_gb arch issues=() issue
  arch="$(uname -m)"
  cpu_cores="$(nproc 2>/dev/null || echo 0)"
  mem_kb="$(awk '/MemTotal:/ {print $2}' /proc/meminfo 2>/dev/null || echo 0)"
  disk_gb="$(df -Pk / 2>/dev/null | awk 'NR==2 {print int($4/1024/1024)}' || echo 0)"

  verbose_log "Hardware probe: arch=$arch cpu_cores=$cpu_cores mem_mb=$((mem_kb/1024)) disk_gb=$disk_gb"

  if [[ "$arch" != "x86_64" && "$arch" != "aarch64" && "$arch" != "arm64" ]]; then
    issues+=("Architecture $arch is not one of the common 64-bit targets")
  fi

  if (( cpu_cores < 2 )); then
    issues+=("CPU cores $cpu_cores is below the recommended minimum of 2")
  fi

  if (( mem_kb < 2097152 )); then
    issues+=("RAM $((mem_kb/1024)) MB is below the recommended minimum of 2048 MB")
  fi

  if (( disk_gb < 16 )); then
    issues+=("Disk space $disk_gb GB is below the recommended minimum of 16 GB")
  fi

  if (( ${#issues[@]} > 0 )); then
    log "Hardware preflight found the following concerns:"
    for issue in "${issues[@]}"; do
      log "  - $issue"
    done

    if ! confirm_yes "Continue with installation anyway?" "n"; then
      log "Aborting installation because the host appears below the recommended minimum hardware."
      exit 1
    fi
  else
    log "Hardware preflight passed."
  fi
}

prompt_for_configuration() {
  local detected_hostname detected_username detected_ip default_domain
  detected_hostname="$(detect_hostname)"
  detected_username="$(detect_username)"
  detected_ip="$(detect_primary_ip)"
  default_domain="${DOMAIN_NAME_VALUE:-valhalla}"

  echo
  log "Detected host configuration:"
  printf '  Hostname : %s\n' "$detected_hostname"
  printf '  User     : %s\n' "$detected_username"
  printf '  IP       : %s\n' "$detected_ip"
  echo
  log "Recommended internal domain: $default_domain"
  log "Valhalla is the original project name and is recommended to keep as the default internal domain unless you have a specific reason to change it."
  echo

  if [[ ! -t 0 ]]; then
    HOSTNAME_VALUE="$detected_hostname"
    USERNAME_VALUE="$detected_username"
    IP_VALUE="$detected_ip"
    DOMAIN_NAME_VALUE="$default_domain"
    return 0
  fi

  if confirm_yes "Use hostname '$detected_hostname'?" "y"; then
    HOSTNAME_VALUE="$detected_hostname"
  else
    read -r -p "Enter hostname [$detected_hostname]: " HOSTNAME_VALUE
    HOSTNAME_VALUE="${HOSTNAME_VALUE:-$detected_hostname}"
  fi

  if confirm_yes "Use username '$detected_username'?" "y"; then
    USERNAME_VALUE="$detected_username"
  else
    read -r -p "Enter username [$detected_username]: " USERNAME_VALUE
    USERNAME_VALUE="${USERNAME_VALUE:-$detected_username}"
  fi

  if confirm_yes "Use IP '$detected_ip'?" "y"; then
    IP_VALUE="$detected_ip"
  else
    read -r -p "Enter IP [$detected_ip]: " IP_VALUE
    IP_VALUE="${IP_VALUE:-$detected_ip}"
  fi

  read -r -p "Enter internal domain [$default_domain]: " DOMAIN_NAME_VALUE
  DOMAIN_NAME_VALUE="${DOMAIN_NAME_VALUE:-$default_domain}"

  TAILSCALE_IP_VALUE="${TAILSCALE_IP_VALUE:-$IP_VALUE}"

  log "Configuration selected:"
  log "  Hostname: $HOSTNAME_VALUE"
  log "  Username: $USERNAME_VALUE"
  log "  IP: $IP_VALUE"
  log "  Domain: $DOMAIN_NAME_VALUE"
  verbose_log "Configuration values prepared for deployment."
}

apply_configuration() {
  local compose_env_path="/etc/valhalla/compose.env"
  local domain_value="${DOMAIN_NAME_VALUE:-valhalla}"

  if [[ -n "${HOSTNAME_VALUE:-}" ]]; then
    local current_hostname="$(hostname 2>/dev/null || true)"
    if [[ "$HOSTNAME_VALUE" != "$current_hostname" ]]; then
      log "Updating hostname to $HOSTNAME_VALUE"
      verbose_log "Hostname change requested: $current_hostname -> $HOSTNAME_VALUE"
      if command -v hostnamectl >/dev/null 2>&1; then
        run_privileged hostnamectl set-hostname "$HOSTNAME_VALUE"
      else
        run_privileged hostname "$HOSTNAME_VALUE"
      fi
    fi
  fi

  if [[ -n "${USERNAME_VALUE:-}" ]] && [[ "$USERNAME_VALUE" != "root" ]] && id "$USERNAME_VALUE" >/dev/null 2>&1; then
    log "Applying ownership to /srv for user $USERNAME_VALUE"
    run_privileged chown -R "$USERNAME_VALUE:$USERNAME_VALUE" /srv 2>/dev/null || true
  fi

  run_privileged mkdir -p /etc/valhalla
  verbose_log "Writing deployment metadata to /etc/valhalla/install.env"
  run_privileged bash -c "printf 'HOSTNAME=%s\nUSERNAME=%s\nIP=%s\nDOMAIN=%s\nVALHALLA_DOMAIN=%s\n' '$HOSTNAME_VALUE' '$USERNAME_VALUE' '$IP_VALUE' '$domain_value' '$domain_value' > /etc/valhalla/install.env"
  verbose_log "Writing compose environment defaults to $compose_env_path"
  run_privileged bash -c "printf 'VALHALLA_HOST_IP=%s\nVALHALLA_TAILSCALE_IP=%s\nVALHALLA_DOMAIN=%s\nHOMEPAGE_ALLOWED_HOSTS=homepage.%s,%s:3000,%s:3000\n' '$IP_VALUE' '${TAILSCALE_IP_VALUE:-$IP_VALUE}' '$domain_value' '$domain_value' '$IP_VALUE' '${TAILSCALE_IP_VALUE:-$IP_VALUE}' > '$compose_env_path'"
}

check_installation() {
  local failures=0
  local container_names=()

  log "Checking installation state..."

  if ! command -v docker >/dev/null 2>&1; then
    log "Docker is not installed."
    failures=1
  fi

  if ! docker compose version >/dev/null 2>&1; then
    log "Docker Compose is not available."
    failures=1
  fi

  if ! command -v tailscale >/dev/null 2>&1; then
    log "Tailscale is not installed."
    failures=1
  fi

  for dir in /srv/docker /srv/media /srv/backups /srv/certificates; do
    if [[ ! -d "$dir" ]]; then
      log "Directory missing: $dir"
      failures=1
    fi
  done

  for stack in infra proxy network security media; do
    if [[ ! -f "/srv/docker/$stack/compose.yml" ]]; then
      log "Compose file missing: /srv/docker/$stack/compose.yml"
      failures=1
    fi
  done

  if command -v docker >/dev/null 2>&1 && ! docker info >/dev/null 2>&1; then
    log "Docker daemon is not reachable."
    failures=1
  fi

  if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    container_names=( $(docker ps --format '{{.Names}}' 2>/dev/null || true) )
    if [[ ${#container_names[@]} -gt 0 ]]; then
      log "Detected running containers: ${container_names[*]}"
    else
      log "No running containers were detected."
    fi
  fi

  if [[ $failures -eq 0 ]]; then
    log "Installation check passed."
    return 0
  fi

  log "Installation check failed."
  return 1
}

print_banner() {
  cat <<'RAW'

    ▄   ██   █     ▄  █ ██   █    █    ██   
     █  █ █  █    █   █ █ █  █    █    █ █  
█     █ █▄▄█ █    ██▀▀█ █▄▄█ █    █    █▄▄█ 
 █    █ █  █ ███▄ █   █ █  █ ███▄ ███▄ █  █ 
  █  █     █     ▀   █     █     ▀    ▀   █ 
   █▐     █         ▀     █              █  
   ▐     ▀               ▀              ▀   

            by @k4rkarov

RAW
}


ORIGINAL_ARGS=("$@")

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -v|--verbose)
      VERBOSE=1
      ;;
    -c|--check)
      CHECK_ONLY=1
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "This installer is intended for Linux hosts." >&2
  exit 1
fi

if [[ -f /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  case "$(detect_package_manager)" in
    apt)
      ;;
    *)
      echo "Unsupported distribution: ${PRETTY_NAME:-unknown}. This script targets Debian/Ubuntu/Raspberry Pi OS-like systems and other apt-based variants." >&2
      exit 1
      ;;
  esac
else
  echo "Unable to detect your Linux distribution." >&2
  exit 1
fi

if [[ "$CHECK_ONLY" -eq 0 ]]; then
  check_hardware_requirements
fi

if [[ "$CHECK_ONLY" -eq 0 ]]; then
  if [[ $EUID -eq 0 ]]; then
    SUDO=""
  elif command -v sudo >/dev/null 2>&1; then
    echo "This script needs root privileges. Re-running with sudo..." >&2
    exec sudo "$0" "${ORIGINAL_ARGS[@]}"
  else
    echo "This script needs root privileges. Run it with sudo or as root." >&2
    exit 1
  fi
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"

if [[ ! -d "$REPO_ROOT/config/docker-compose-stacks" ]]; then
  for candidate in "$HOME/valhalla-homelab" "$HOME/Documents/github/valhalla-homelab" "$PWD"; do
    if [[ -d "$candidate/config/docker-compose-stacks" ]]; then
      REPO_ROOT="$candidate"
      break
    fi
  done
fi

if [[ ! -d "$REPO_ROOT/config/docker-compose-stacks" ]]; then
  echo "Unable to locate the Valhalla repository. Place this script inside the repository and try again." >&2
  exit 1
fi

require_command() {
  command -v "$1" >/dev/null 2>&1
}

ensure_package() {
  local pkg="$1"
  if dpkg -s "$pkg" >/dev/null 2>&1; then
    log "$pkg is already installed."
  else
    log "Installing missing package: $pkg"
    run_privileged apt-get update
    run_privileged apt-get install -y "$pkg"
  fi
}

install_base_packages() {
  log "Checking base packages..."
  verbose_log "Package manager: apt"
  verbose_log "Base package set: curl wget git vim htop btop tree ncdu zip unzip ca-certificates gnupg lsb-release software-properties-common apt-transport-https"
  run_privileged apt-get update

  local packages=(
    curl wget git vim htop btop tree ncdu zip unzip
    ca-certificates gnupg lsb-release software-properties-common
    apt-transport-https
  )
  local missing_packages=()
  local pkg

  for pkg in "${packages[@]}"; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
      missing_packages+=("$pkg")
    fi
  done

  if [[ ${#missing_packages[@]} -gt 0 ]]; then
    log "Installing required packages: ${missing_packages[*]}"
    verbose_log "Installing missing packages: ${missing_packages[*]}"
    run_privileged apt-get install -y "${missing_packages[@]}"
  else
    log "All base packages are already installed."
  fi
}

install_docker() {
  verbose_log "Preparing Docker installation and service startup."
  if require_command docker; then
    log "Docker is already installed."
  else
    log "Installing Docker..."
    run_privileged apt-get install -y docker.io
  fi

  if ! getent group docker >/dev/null 2>&1; then
    run_privileged groupadd docker || true
  fi

  if [[ -n "${SUDO_USER:-}" ]] && id "$SUDO_USER" >/dev/null 2>&1; then
    run_privileged usermod -aG docker "$SUDO_USER" || true
  fi

  run_privileged systemctl enable docker >/dev/null 2>&1 || true
  run_privileged systemctl start docker >/dev/null 2>&1 || true

  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "Dry run: Docker Compose availability was not checked."
  elif docker compose version >/dev/null 2>&1; then
    log "Docker Compose plugin is available."
  elif run_privileged apt-get install -y docker-compose-plugin >/dev/null 2>&1; then
    log "Installed Docker Compose plugin."
  elif run_privileged apt-get install -y docker-compose >/dev/null 2>&1; then
    log "Installed legacy Docker Compose."
  else
    echo "Unable to install Docker Compose automatically." >&2
    exit 1
  fi
}

install_tailscale() {
  verbose_log "Preparing Tailscale installation from https://tailscale.com/install.sh"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "Dry run: Tailscale installation was skipped."
    return 0
  fi
  if require_command tailscale; then
    log "Tailscale is already installed."
  else
    log "Installing Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | run_privileged sh
  fi
}

prepare_directories() {
  log "Creating persistent directories..."
  verbose_log "Creating /srv directories for Docker data, media, backups, and certificates"
  run_privileged mkdir -p \
    /srv/docker/infra \
    /srv/docker/proxy \
    /srv/docker/network \
    /srv/docker/security \
    /srv/docker/media \
    /srv/media/movies \
    /srv/media/series \
    /srv/media/music \
    /srv/backups \
    /srv/certificates \
    /srv/jellyfin/config \
    /srv/jellyfin/cache \
    /srv/navidrome/data

  if [[ -n "${USERNAME_VALUE:-}" ]] && [[ "$USERNAME_VALUE" != "root" ]] && id "$USERNAME_VALUE" >/dev/null 2>&1; then
    run_privileged chown -R "$USERNAME_VALUE:$USERNAME_VALUE" /srv 2>/dev/null || true
  fi
}

render_compose_template() {
  local source="$1"
  local target="$2"
  local content
  content="$(cat "$source")"
  content="${content//__VALHALLA_HOST_IP__/$IP_VALUE}"
  content="${content//__VALHALLA_TAILSCALE_IP__/$TAILSCALE_IP_VALUE}"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    verbose_log "Dry run: would render compose file $target"
    return 0
  fi
  printf '%s\n' "$content" > "$target"
}

prepare_compose_files() {
  log "Copying stack definitions into /srv/docker/..."
  verbose_log "Using host IP $IP_VALUE and Tailscale IP ${TAILSCALE_IP_VALUE:-$(detect_tailscale_ip)}"
  TAILSCALE_IP_VALUE="${TAILSCALE_IP_VALUE:-$(detect_tailscale_ip)}"
  for stack in infra proxy network security media; do
    run_privileged mkdir -p "/srv/docker/$stack"
    target="/srv/docker/$stack/compose.yml"
    if [[ -f "$target" ]]; then
      backup="${target}.bak.$(date +%s)"
      log "Backing up existing compose file to $backup"
      run_logged mv "$target" "$backup"
    fi
    render_compose_template "$REPO_ROOT/config/docker-compose-stacks/${stack}.yaml" "$target"
  done
}

compose_up() {
  local compose_file="$1"
  local stack_name="$2"
  log "Starting $stack_name stack..."
  verbose_log "Deploying compose file $compose_file for stack $stack_name"
  if docker compose version >/dev/null 2>&1; then
    run_logged docker compose --env-file /etc/valhalla/compose.env -f "$compose_file" config >/dev/null
    run_logged docker compose --env-file /etc/valhalla/compose.env -f "$compose_file" up -d
  else
    run_logged docker-compose --env-file /etc/valhalla/compose.env -f "$compose_file" config >/dev/null
    run_logged docker-compose --env-file /etc/valhalla/compose.env -f "$compose_file" up -d
  fi
}

deploy_stacks() {
  compose_up /srv/docker/infra/compose.yml infra
  compose_up /srv/docker/proxy/compose.yml proxy
  compose_up /srv/docker/network/compose.yml network
  compose_up /srv/docker/security/compose.yml security
  compose_up /srv/docker/media/compose.yml media
}

verify_installation() {
  log "Verifying deployment..."
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "Dry run: deployment verification was skipped."
    return 0
  fi
  verbose_log "Checking container status and waiting for each stack to report running services"
  run_logged docker ps --format 'table {{.Names}}\t{{.Status}}' | head

  for stack in infra proxy network security media; do
    if wait_for_stack "/srv/docker/$stack/compose.yml" "$stack" 120; then
      log "Stack $stack is reporting running services."
    else
      log "Stack $stack did not report running services."
    fi
  done

  log "Install checks complete."
}

main() {
  if [[ "$CHECK_ONLY" -eq 1 ]]; then
    check_installation
    exit $?
  fi

  if [[ "$VERBOSE" -eq 1 ]]; then
    print_banner
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "Dry run enabled. No changes will be made to the host."
  fi

  verbose_log "Verbose mode enabled. The installer will print detailed package, Docker, compose, and deployment information."

  prompt_for_configuration
  apply_configuration

  install_base_packages
  install_docker
  install_tailscale
  prepare_directories
  prepare_compose_files
  deploy_stacks
  verify_installation

  log "Installation complete."
  log "Repository root: $REPO_ROOT"
  log "Stacks deployed under /srv/docker"
  log "Configuration saved in /etc/valhalla/install.env"
  log "Next steps:"
  log "  - Review the service docs in $REPO_ROOT/config"
  log "  - Finish Tailscale authentication with: sudo tailscale up"
  log "  - Open the services through your local DNS and reverse proxy setup"
}

main "$@"
