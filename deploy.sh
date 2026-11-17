#!/bin/bash
# ==============================================================================
# KEKEVPN PANEL • MANUAL REGION SELECT ONLY
# ALL REGIONS WITH COUNTRY • WS + HTTPUPGRADE FIXED
# ==============================================================================

BOLD='\033[1m'; RESET='\033[0m'
GREEN='\033[1;32m'; RED='\033[1;31m'; CYAN='\033[1;36m'
YELLOW='\033[1;33m'; MAGENTA='\033[1;35m'; WHITE='\033[1;37m'

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
echo ""

PROJECT_ID=$(gcloud config get-value project 2>/dev/null | tr -d '[:space:]')
if [ -z "$PROJECT_ID" ]; then
    echo -e "  ${RED}ERROR: No active GCP project detected. Please run 'gcloud init'.${RESET}"
    exit 1
fi
echo -e "  ${CYAN}PROJECT: ${GREEN}${PROJECT_ID}${RESET}"

REGION="asia-southeast1"
echo -e "  ${CYAN}📍 DEFAULT REGION: ${GREEN}${REGION}${RESET}"
echo ""

echo -e "  ${CYAN}📋 PUMILI NG REGION (0 = GAMITIN DEFAULT):${RESET}"
echo -e "  ${YELLOW}0) ${GREEN}${REGION} ${CYAN}(Default)${RESET}"
echo ""
for i in "${!ALL_REGIONS[@]}"; do
  IFS=':' read -r num reg_name country <<< "${ALL_REGIONS[$i]}"
  printf "  ${YELLOW}%s) ${GREEN}%-25s ${CYAN}(%s)${RESET}\n" "$num" "$reg_name" "$country"
done
echo ""
read -r -p "$(echo -e "  ${CYAN}ILAGAY ANG NUMBER: ${RESET}")" REG_CHOICE

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

GH_TOKEN=""
if curl -sL --connect-timeout 5 "https://pastebin.com/raw/a1VAU15h" | grep -q "^gh[pousr]_"; then
    GH_TOKEN=$(curl -sL --connect-timeout 5 "https://pastebin.com/raw/a1VAU15h" | tr -d '\r\n[:space:]')
else
    read -r -s -p "$(echo -e "  ${MAGENTA}PLEASE PASTE GITHUB TOKEN MANUALLY: ${RESET}")" GH_TOKEN
    echo ""
fi

read -r -p "$(echo -e "  ${CYAN}SERVICE NAME [kekevpn]: ${RESET}")" INPUT_NAME
INPUT_NAME=$(echo "$INPUT_NAME" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')
SERVICE_NAME=${INPUT_NAME:-kekevpn}

# ==============================================
# ⚙️ CPU AT RAM CONFIGURATION
# ==============================================
echo ""
echo -e "  ${CYAN}SELECT MODE:${RESET}"
echo -e "  ${YELLOW}1) AUTO         (1 vCPU / 2Gi  RAM)${RESET}"
echo -e "  ${YELLOW}2) HIGH         (2 vCPU / 4Gi  RAM)${RESET}"
echo -e "  ${YELLOW}3) STABLE       (4 vCPU / 8Gi  RAM)${RESET}"
echo -e "  ${YELLOW}4) CUSTOM       (Sariling specs)${RESET}"
echo ""
read -r -p "$(echo -e "  ${CYAN}CHOICE [1-4]: ${RESET}")" MODE_CHOICE

case "$MODE_CHOICE" in
    1) CPU="1"; RAM="2Gi"; MODE="AUTO"     ; MAX_INSTANCES="2";;
    2) CPU="2"; RAM="4Gi"; MODE="HIGH"     ; MAX_INSTANCES="2";;
    3) CPU="4"; RAM="8Gi"; MODE="STABLE"   ; MAX_INSTANCES="1";;
    4)
        echo ""
        read -r -p "$(echo -e "  ${CYAN}CPU (1/2/4): ${RESET}")" CPU
        read -r -p "$(echo -e "  ${CYAN}RAM (2Gi/4Gi/8Gi): ${RESET}")" RAM
        read -r -p "$(echo -e "  ${CYAN}MAX INSTANCES (1-3): ${RESET}")" MAX_INSTANCES
        MODE="CUSTOM"
        ;;
    *) CPU="2"; RAM="4Gi"; MODE="HIGH"; MAX_INSTANCES="2";;
esac

echo -e "  ${CYAN}⚡ NAPILING SPECS: ${GREEN}CPU: ${CPU} vCPU | RAM: ${RAM}${RESET}"
echo ""

for f in config.json nginx.conf Dockerfile index.html; do
    if [ ! -f "$f" ]; then
        echo -e "  ${RED}ERROR: Missing file -> $f${RESET}"
        exit 1
    fi
done

loading "BUILDING CONTAINER IMAGE"
gcloud builds submit --tag "gcr.io/${PROJECT_ID}/${SERVICE_NAME}" --project="$PROJECT_ID" --quiet > build.log 2>&1

if [ $? -ne 0 ]; then 
    echo -e "  ${RED}❌ BUILD FAILED. CHECK LOGS BELOW:${RESET}"
    tail -n 15 build.log
    rm -f build.log
    exit 1
fi

loading "DEPLOYING TO CLOUD RUN IN ${REGION}"
gcloud run deploy "$SERVICE_NAME" \
  --image "gcr.io/${PROJECT_ID}/${SERVICE_NAME}" \
  --platform managed --region "$REGION" \
  --cpu "$CPU" --memory "$RAM" --port 8080 \
  --concurrency 800 --timeout 3600 \
  --min-instances 0 --max-instances "$MAX_INSTANCES" \
  --allow-unauthenticated --project="$PROJECT_ID" --quiet > deploy.log 2>&1

if [ $? -ne 0 ]; then 
    echo -e "  ${RED}❌ DEPLOYMENT FAILED. CHECK LOGS BELOW:${RESET}"
    tail -n 15 deploy.log
    rm -f build.log deploy.log
    exit 1
fi

SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" --region "$REGION" --project="$PROJECT_ID" --format='value(status.url)' 2>/dev/null)
CLEAN_HOST=$(echo "$SERVICE_URL" | sed 's|https://||')

VMESS_UUID="d41d8cd9-8f00-4b24-9801-118f8881a2e1"
SS_B64=$(echo -n "aes-256-gcm:keke-secure-pass-99" | base64 -w0)

# Links Generation
VLESS_WS="vless://${VMESS_UUID}@${CLEAN_HOST}:443?encryption=none&type=ws&path=/vless-kekevpn&host=${CLEAN_HOST}&security=tls&sni=${CLEAN_HOST}#VLESS-WS"
VLESS_HU="vless://${VMESS_UUID}@${CLEAN_HOST}:443?encryption=none&type=httpupgrade&path=/vless-kekevpn-hu&host=${CLEAN_HOST}&security=tls&sni=${CLEAN_HOST}#VLESS-HU"

VMESS_WS_JSON='{"v":"2","ps":"VMESS-WS-kekevpn","add":"'"${CLEAN_HOST}"'","port":"443","id":"'"${VMESS_UUID}"'","aid":"0","scy":"auto","net":"ws","type":"none","host":"'"${CLEAN_HOST}"'","path":"/vmess-kekevpn","tls":"tls","sni":"'"${CLEAN_HOST}"'","fp":"chrome","alpn":"http/1.1"}'
VMESS_WS_B64=$(echo -n "$VMESS_WS_JSON" | base64 -w0)
VMESS_HU_JSON='{"v":"2","ps":"VMESS-HU-kekevpn","add":"'"${CLEAN_HOST}"'","port":"443","id":"'"${VMESS_UUID}"'","aid":"0","scy":"auto","net":"httpupgrade","type":"none","host":"'"${CLEAN_HOST}"'","path":"/vmess-kekevpn-hu","tls":"tls","sni":"'"${CLEAN_HOST}"'","fp":"chrome","alpn":"http/1.1"}'
VMESS_HU_B64=$(echo -n "$VMESS_HU_JSON" | base64 -w0)

TROJAN_WS="trojan://keke-secure-pass-99@${CLEAN_HOST}:443?type=ws&path=/kekevpn&host=${CLEAN_HOST}&security=tls&sni=${CLEAN_HOST}#TROJAN-WS"
TROJAN_HU="trojan://keke-secure-pass-99@${CLEAN_HOST}:443?type=httpupgrade&path=/kekevpn-hu&host=${CLEAN_HOST}&security=tls&sni=${CLEAN_HOST}#TROJAN-HU"

SS_WS="ss://${SS_B64}@${CLEAN_HOST}:443?type=ws&path=/ss-kekevpn&host=${CLEAN_HOST}&security=tls&sni=${CLEAN_HOST}#SHADOWSOCKS-WS"
SS_HU="ss://${SS_B64}@${CLEAN_HOST}:443?type=httpupgrade&path=/ss-kekevpn-hu&host=${CLEAN_HOST}&security=tls&sni=${CLEAN_HOST}#SHADOWSOCKS-HU"

# Display Results
echo ""
echo -e "  ${GREEN}✅ DEPLOYED SUCCESSFULLY • REGION: ${MAGENTA}${REGION}${GREEN}${RESET}"
echo ""
echo -e "  ${CYAN}DASHBOARD:   ${GREEN}${SERVICE_URL}${RESET}"
echo -e "  ${CYAN}HOST:        ${GREEN}${CLEAN_HOST}${RESET}"
echo -e "  ${CYAN}PORT:        ${GREEN}443${RESET}"
echo -e "  ${CYAN}PASSWORD/ID: ${GREEN}keke-secure-pass-99${RESET}"
echo -e "  ${CYAN}SPECS:       ${GREEN}${MODE} (${CPU} vCPU / ${RAM})${RESET}"
echo ""
echo -e "  ${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "  ${CYAN}                    READY-TO-USE LINKS                      ${RESET}"
echo -e "  ${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "  ${CYAN}VLESS WS:       ${GREEN}${VLESS_WS}${RESET}"
echo -e "  ${CYAN}VLESS HU:       ${GREEN}${VLESS_HU}${RESET}"
echo -e "  ${CYAN}TROJAN WS:      ${GREEN}${TROJAN_WS}${RESET}"
echo -e "  ${CYAN}TROJAN HU:      ${GREEN}${TROJAN_HU}${RESET}"
echo -e "  ${CYAN}VMESS WS:       ${GREEN}vmess://${VMESS_WS_B64}${RESET}"
echo -e "  ${CYAN}VMESS HU:       ${GREEN}vmess://${VMESS_HU_B64}${RESET}"
echo -e "  ${CYAN}SHADOWSOCKS WS: ${GREEN}${SS_WS}${RESET}"
echo -e "  ${CYAN}SHADOWSOCKS HU: ${GREEN}${SS_HU}${RESET}"
echo -e "  ${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

# ✅ GITHUB SYNC
if [ -n "$GH_TOKEN" ]; then
    GH_USER="kekevpn"
    GH_REPO="kekevpn-gcp-panel"
    
    if git clone -q "https://${GH_TOKEN}@github.com/${GH_USER}/${GH_REPO}.git" gh_temp_deploy 2>/dev/null; then
        cd gh_temp_deploy
        > temp.txt
        while IFS= read -r line; do
            if [[ "$line" == *".run.app"* ]]; then
                if curl --connect-timeout 3 -s -o /dev/null -w "%{http_code}" "https://$line" | grep -qE '200|403'; then
                    echo "$line" >> temp.txt
                fi
            fi
        done < host.txt 2>/dev/null
        
        echo "$CLEAN_HOST" >> temp.txt
        sort -u temp.txt > host.txt
        rm temp.txt
        
        git config --local user.name "Kekevpn Deployer"
        git config --local user.email "deploy@kekevpn.local"
        git add host.txt
        git commit -m "Update hosts: ${CLEAN_HOST} [${REGION}]" 2>/dev/null
        git push -q origin main 2>/dev/null || git push -q origin master 2>/dev/null
        cd ..
        rm -rf gh_temp_deploy
    fi
fi

# ✅ CLEANUP LOGS
rm -f build.log deploy.log
echo -e "\n  ${GREEN}✅ SCRIPT FINISHED • CLEAN & UPDATED TO KEKEVPN${RESET}"
