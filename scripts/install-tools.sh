#!/usr/bin/env bash
# ============================================================
# scripts/install-tools.sh — Install all required tools via Homebrew
# ============================================================
# Run: make install-tools  (or: bash scripts/install-tools.sh)
# Platform: Mac M1 (darwin/arm64)
# ============================================================
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

check_or_install() {
    local tool="$1"
    local brew_name="${2:-$1}"
    local tap="${3:-}"

    if command -v "$tool" &>/dev/null; then
        printf "  ${GREEN}✓${RESET} %-20s %s\n" "$tool" "$(command -v "$tool")"
    else
        echo -e "  ${YELLOW}→${RESET} Installing $tool..."
        if [ -n "$tap" ]; then
            brew tap "$tap" 2>/dev/null || true
        fi
        brew install "$brew_name"
        printf "  ${GREEN}✓${RESET} %-20s installed\n" "$tool"
    fi
}

echo ""
echo -e "${CYAN}==> tch-mac-prep: Installing all required tools (Mac M1 + Homebrew)${RESET}"
echo ""

# ── Infrastructure ────────────────────────────────────────────────────────
echo "Infrastructure tools:"
check_or_install "terraform"   "hashicorp/tap/terraform"   "hashicorp/tap"
check_or_install "vault"       "hashicorp/tap/vault"        "hashicorp/tap"
check_or_install "ansible"     "ansible"
check_or_install "ansible-playbook" "ansible"

# ── Security Scanners ─────────────────────────────────────────────────────
echo ""
echo "Security scanning tools:"
check_or_install "checkov"   "checkov"
check_or_install "tfsec"     "tfsec"
check_or_install "trivy"     "trivy"     "aquasecurity/trivy"

# ── AWS CLI (for LocalStack verification) ────────────────────────────────
echo ""
echo "AWS CLI (for LocalStack verification):"
check_or_install "aws"       "awscli"

# ── Container runtime ─────────────────────────────────────────────────────
echo ""
echo "Container runtime:"
if command -v "orb" &>/dev/null; then
    printf "  ${GREEN}✓${RESET} %-20s %s\n" "orbstack" "$(orb version 2>/dev/null | head -1)"
else
    echo -e "  ${YELLOW}→${RESET} OrbStack not found."
    echo "    Install from: https://orbstack.dev"
    echo "    (Provides Docker + Kubernetes on Mac M1, faster than Docker Desktop)"
fi

if command -v "docker" &>/dev/null; then
    printf "  ${GREEN}✓${RESET} %-20s %s\n" "docker" "$(docker --version 2>/dev/null)"
else
    echo "  ✗ docker not found — install OrbStack first"
fi

# ── Python packages (for vault test-creds.sh) ────────────────────────────
echo ""
echo "Python packages:"
if python3 -c "import json" 2>/dev/null; then
    printf "  ${GREEN}✓${RESET} %-20s %s\n" "python3+json" "$(python3 --version)"
fi

# ── Version summary ───────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}==> Installed versions:${RESET}"
printf "  %-20s %s\n" "terraform:"  "$(terraform version -json 2>/dev/null | python3 -c 'import sys,json; print(json.load(sys.stdin).get("terraform_version","?"))' 2>/dev/null || echo 'not found')"
printf "  %-20s %s\n" "vault:"      "$(vault version 2>/dev/null || echo 'not found')"
printf "  %-20s %s\n" "ansible:"    "$(ansible --version 2>/dev/null | head -1 || echo 'not found')"
printf "  %-20s %s\n" "checkov:"    "$(checkov --version 2>/dev/null || echo 'not found')"
printf "  %-20s %s\n" "tfsec:"      "$(tfsec --version 2>/dev/null || echo 'not found')"
printf "  %-20s %s\n" "trivy:"      "$(trivy --version 2>/dev/null | head -1 || echo 'not found')"
printf "  %-20s %s\n" "aws cli:"    "$(aws --version 2>/dev/null || echo 'not found')"
echo ""
echo -e "${GREEN}✓ All tools installed. Next: make setup${RESET}"
echo ""
