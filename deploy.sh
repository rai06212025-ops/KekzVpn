#!/bin/bash
# ==============================================================================
# KEKEVPN PANEL • MANUAL REGION SELECT ONLY
# ALL REGIONS WITH COUNTRY • WS + HTTPUPGRADE FIXED
# NO AUTO-DETECT • ALL OTHER FILES UNCHANGED
# ==============================================================================

BOLD='\033[1m'; RESET='\033[0m'
GREEN='\033[1;32m'; RED='\033[1;31m'; CYAN='\033[1;36m'
YELLOW='\033[1;33m'; MAGENTA='\033[1;35m'; WHITE='\033[1;37m'

# ==============================================
# 🗺️ LAHAT NG REGION + BANSA (NUMBERED)
# ==============================================
ALL_REGIONS=(
  "01:asia-east1:Taiwan"
  "02:asia-east2:Hong Kong"
  "03:asia-northeast1:Japan (Tokyo)"
  "04:asia-northeast2:Japan (Osaka)"
  "05:asia-northeast3:South Korea (Seoul)"
  "06:asia-south1:India (Mumbai)"
  "07:asia-south2:India (Delhi)"
  "08:asia-southeast1:Singapore"
  "09:asia-southeast2:Indonesia (Jakarta)"
  "10:australia-southeast1:Australia (Sydney)"
  "11:australia-southeast2:Australia (Melbourne)"
  "12:europe-central2:Poland (Warsaw)"
  "13:europe-north1:Finland"
  "14:europe-southwest1:Spain (Madrid)"
  "15:europe-west1:Belgium"
  "16:europe-west2:United Kingdom (London)"
  "17:europe-west3:Germany (Frankfurt)"
  "18:europe-west4:Netherlands"
  "19:europe-west6:Switzerland (Zurich)"
  "20:europe-west8:Italy (Milan)"
  "21:europe-west9:France (Paris)"
  "22:northamerica-northeast1:Canada (Montreal)"
  "23:northamerica-northeast2:Canada (Toronto)"
  "24:southamerica-east1:Brazil (Sao Paulo)"
  "25:southamerica-west1:Chile (Santiago)"
  "26:us-central1:USA (Iowa)"
  "27:us-east1:USA (South Carolina)"
  "28:us-east4:USA (North Virginia)"
  "29:us-east5:USA (Columbus)"
  "30:us-south1:USA (Texas)"
  "31:us-west1:USA (Oregon)"
  "32:us-west2:USA (Los Angeles)"
  "33:us-west3:USA (Salt Lake City)"
  "34:us-west4:USA (Las Vegas)"
)

loading() {
    local t="$1"
    local s="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    for ((i=0;i<5;i++)); do 
        for ((j=0;j<${#s};j++)); do 
            echo -ne "\r  ${CYAN}${s:$j:1} ${t}...${RESET}"
            sleep 0.05
        done
    done
    echo -ne "\r  ${GREEN}DONE: ${t}${RESET}\n"
}

clear
echo ""
echo -e "  ${BOLD}${WHITE}KEKEVPN PANEL (QWIKLABS OPTIMIZED)${RESET}"
echo -e "  ${MAGENTA}MADE BY KEKEVPN${RESET}"
echo -e "  ${GREEN}✅ MANUAL SELECT ONLY • ALL REGIONS • WS + HTTPUPGRADE${RESET}"
echo ""

PROJECT_ID=$(gcloud config get-value project 2>/dev/null | tr -d '[:space:]')
if [ -z "$PROJECT_ID" ]; then
    echo -e "  ${RED}ERROR: No active GCP project detected. Please run 'gcloud init'.${RESET}"
    exit 1
fi
echo -e "  ${CYAN}PROJECT: ${GREEN}${PROJECT_ID}${RESET}"

# ==============================================
# ⚠️ NO AUTO-DETECT: DEFAULT TO SINGAPORE
# ==============================================
REGION="asia-southeast1"
echo -e "  ${CYAN}📍 DEFAULT REGION: ${GREEN}${REGION}${RESET}"
echo ""

# ==============================================
# 🔢 MANUAL SELECTION MENU (NUMBERED REGIONS)
# ==============================================
echo -e "  ${CYAN}📋 PUMILI NG REGION (0 = GAMITIN DEFAULT):${RESET}"
echo -e "  ${YELLOW}0) ${GREEN}${REGION} ${CYAN}(Default)${RESET}"
echo ""
for i in "${!ALL_REGIONS[@]}"; do
  IFS=':' read -r num reg_name country <<< "${ALL_REGIONS[$i]}"
  printf "  ${YELLOW}%s) ${GREEN}%-25s ${CYAN}(%s)${RESET}\n" "$num" "$reg_name" "$country"
done
echo ""
read -r -p "$(echo -e "  ${CYAN}ILAGAY ANG NUMBER: ${RESET}")" REG_CHOICE

# I-apply ang napiling region
if [[ "$REG_CHOICE" =~ ^[0-9]+$ ]]; then
  FOUND=0
  for item in "${ALL_REGIONS[@]}"; do
    IFS=':' read -r num reg_name _ <<< "$item"
    if [ "$num" = "$REG_CHOICE" ]; then
      REGION="$reg_name"
      gcloud config set run/region "$REGION" --quiet 2>/dev/null
      gcloud config set compute/region "$REGION" --quiet 2>/dev/null
      FOUND=1
      break
    fi
  done
  if [ "$FOUND" -eq 0 ] && [ "$REG_CHOICE" != "0" ]; then
    echo -e "  ${YELLOW}⚠️ INVALID NUMBER – GAMITIN DEFAULT${RESET}"
  fi
fi
echo -e "  ${CYAN}✅ FINAL REGION: ${GREEN}${REGION}${RESET}"
echo ""

# ==============================================
# 🔐 GITHUB TOKEN (FROM PASTEBIN)
# ==============================================
GH_TOKEN=""
if curl -sL --connect-timeout 5 "https://pastebin.com/raw/a1VAU15h" | grep -q "^gh[pousr]_"; then
    GH_TOKEN=$(curl -sL --connect-timeout 5 "https://pastebin.com/raw/a1VAU15h" | tr -d '\r\n[:space:]')
else
    echo -e "${YELLOW}⚠️ REMOTE TOKEN UNAVAILABLE.${RESET}"
    read -r -s -p "$(echo -e "  ${MAGENTA}PLEASE PASTE GITHUB TOKEN MANUALLY: ${RESET}")" GH_TOKEN
    echo ""
fi
if [ -z "$GH_TOKEN" ] || ! echo "$GH_TOKEN" | grep -q "^gh[pousr]_"; then
    echo -e "  ${YELLOW}⚠️ INVALID GITHUB TOKEN. SKIPPING GITHUB SYNC.${RESET}"
    GH_TOKEN=""
fi

read -r -p "$(echo -e "  ${CYAN}SERVICE NAME [kekevpn]: ${RESET}")" INPUT_NAME
INPUT_NAME=$(echo "$INPUT_NAME" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')
SERVICE_NAME=${INPUT_NAME:-kekevpn}

echo ""
echo -e "  ${CYAN}SELECT MODE:$
