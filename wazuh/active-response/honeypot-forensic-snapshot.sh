#!/bin/bash
# Honeypot Deployer - Forensic Snapshot Active Response Script
#
# This script is triggered by Wazuh Active Response when a honeypot alert fires.
# It captures forensic data about the process/user that accessed the honeypot artifact.
#
# Install to: /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
# Permissions: chmod 750, owned by root:wazuh
#
# Usage: Called automatically by Wazuh Active Response engine.
# Input: JSON from Wazuh via stdin (active response protocol)

set -euo pipefail

LOCAL=$(dirname "$0")
FORENSICS_DIR="/var/ossec/logs/forensics"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="/var/ossec/logs/active-responses.log"

# Read Wazuh active response input
read -r INPUT_JSON

# Extract alert details from Wazuh AR input
ALERT_ID=$(echo "$INPUT_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('parameters',{}).get('alert',{}).get('id','unknown'))" 2>/dev/null || echo "unknown")
RULE_ID=$(echo "$INPUT_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('parameters',{}).get('alert',{}).get('rule',{}).get('id','unknown'))" 2>/dev/null || echo "unknown")
SRC_USER=$(echo "$INPUT_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('parameters',{}).get('alert',{}).get('syscheck',{}).get('audit',{}).get('user',{}).get('name','unknown'))" 2>/dev/null || echo "unknown")
PROCESS_NAME=$(echo "$INPUT_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('parameters',{}).get('alert',{}).get('syscheck',{}).get('audit',{}).get('process',{}).get('name','unknown'))" 2>/dev/null || echo "unknown")
PROCESS_PID=$(echo "$INPUT_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('parameters',{}).get('alert',{}).get('syscheck',{}).get('audit',{}).get('process',{}).get('id','unknown'))" 2>/dev/null || echo "unknown")

# Create forensics output directory
SNAPSHOT_ID="snapshot-${TIMESTAMP}-${ALERT_ID}"
SNAPSHOT_DIR="${FORENSICS_DIR}/${SNAPSHOT_ID}"
mkdir -p "$SNAPSHOT_DIR"

echo "$(date) - Honeypot forensic snapshot started: ${SNAPSHOT_ID}" >> "$LOG_FILE"
echo "$(date) - Alert ID: ${ALERT_ID}, Rule: ${RULE_ID}, User: ${SRC_USER}, Process: ${PROCESS_NAME} (PID: ${PROCESS_PID})" >> "$LOG_FILE"

# ============================================
# Capture forensic data
# ============================================

# 1. Full process list
echo "=== Process List ===" > "${SNAPSHOT_DIR}/processes.txt"
echo "Captured at: $(date -u)" >> "${SNAPSHOT_DIR}/processes.txt"
echo "" >> "${SNAPSHOT_DIR}/processes.txt"
ps auxf >> "${SNAPSHOT_DIR}/processes.txt" 2>&1 || true

# 2. Network connections
echo "=== Network Connections ===" > "${SNAPSHOT_DIR}/network.txt"
echo "Captured at: $(date -u)" >> "${SNAPSHOT_DIR}/network.txt"
echo "" >> "${SNAPSHOT_DIR}/network.txt"
ss -tunap >> "${SNAPSHOT_DIR}/network.txt" 2>&1 || true

# 3. Process details for the triggering PID
if [ "$PROCESS_PID" != "unknown" ] && [ -d "/proc/${PROCESS_PID}" ]; then
    echo "=== Triggering Process Details (PID: ${PROCESS_PID}) ===" > "${SNAPSHOT_DIR}/trigger-process.txt"
    echo "Captured at: $(date -u)" >> "${SNAPSHOT_DIR}/trigger-process.txt"
    echo "" >> "${SNAPSHOT_DIR}/trigger-process.txt"

    echo "--- Command Line ---" >> "${SNAPSHOT_DIR}/trigger-process.txt"
    tr '\0' ' ' < "/proc/${PROCESS_PID}/cmdline" >> "${SNAPSHOT_DIR}/trigger-process.txt" 2>/dev/null || echo "(unavailable)" >> "${SNAPSHOT_DIR}/trigger-process.txt"
    echo "" >> "${SNAPSHOT_DIR}/trigger-process.txt"

    echo "--- Environment (first 50 lines) ---" >> "${SNAPSHOT_DIR}/trigger-process.txt"
    tr '\0' '\n' < "/proc/${PROCESS_PID}/environ" 2>/dev/null | head -50 >> "${SNAPSHOT_DIR}/trigger-process.txt" || echo "(unavailable)" >> "${SNAPSHOT_DIR}/trigger-process.txt"
    echo "" >> "${SNAPSHOT_DIR}/trigger-process.txt"

    echo "--- Open File Descriptors ---" >> "${SNAPSHOT_DIR}/trigger-process.txt"
    ls -la "/proc/${PROCESS_PID}/fd/" >> "${SNAPSHOT_DIR}/trigger-process.txt" 2>&1 || echo "(unavailable)" >> "${SNAPSHOT_DIR}/trigger-process.txt"
    echo "" >> "${SNAPSHOT_DIR}/trigger-process.txt"

    echo "--- Memory Maps ---" >> "${SNAPSHOT_DIR}/trigger-process.txt"
    cat "/proc/${PROCESS_PID}/maps" >> "${SNAPSHOT_DIR}/trigger-process.txt" 2>/dev/null || echo "(unavailable)" >> "${SNAPSHOT_DIR}/trigger-process.txt"
    echo "" >> "${SNAPSHOT_DIR}/trigger-process.txt"

    echo "--- Process Status ---" >> "${SNAPSHOT_DIR}/trigger-process.txt"
    cat "/proc/${PROCESS_PID}/status" >> "${SNAPSHOT_DIR}/trigger-process.txt" 2>/dev/null || echo "(unavailable)" >> "${SNAPSHOT_DIR}/trigger-process.txt"
fi

# 4. Login sessions
echo "=== Active Login Sessions ===" > "${SNAPSHOT_DIR}/sessions.txt"
echo "Captured at: $(date -u)" >> "${SNAPSHOT_DIR}/sessions.txt"
echo "" >> "${SNAPSHOT_DIR}/sessions.txt"
echo "--- Current sessions (w) ---" >> "${SNAPSHOT_DIR}/sessions.txt"
w >> "${SNAPSHOT_DIR}/sessions.txt" 2>&1 || true
echo "" >> "${SNAPSHOT_DIR}/sessions.txt"
echo "--- Recent logins (last -20) ---" >> "${SNAPSHOT_DIR}/sessions.txt"
last -20 >> "${SNAPSHOT_DIR}/sessions.txt" 2>&1 || true

# 5. User's bash history (if accessible)
if [ "$SRC_USER" != "unknown" ] && [ "$SRC_USER" != "root" ]; then
    USER_HOME=$(getent passwd "$SRC_USER" | cut -d: -f6 2>/dev/null || echo "")
    if [ -n "$USER_HOME" ] && [ -f "${USER_HOME}/.bash_history" ]; then
        echo "=== Bash History (last 100 lines) ===" > "${SNAPSHOT_DIR}/bash-history.txt"
        echo "User: ${SRC_USER}" >> "${SNAPSHOT_DIR}/bash-history.txt"
        echo "Captured at: $(date -u)" >> "${SNAPSHOT_DIR}/bash-history.txt"
        echo "" >> "${SNAPSHOT_DIR}/bash-history.txt"
        tail -100 "${USER_HOME}/.bash_history" >> "${SNAPSHOT_DIR}/bash-history.txt" 2>/dev/null || echo "(unavailable)" >> "${SNAPSHOT_DIR}/bash-history.txt"
    fi
fi

# 6. System info
echo "=== System Information ===" > "${SNAPSHOT_DIR}/system-info.txt"
echo "Captured at: $(date -u)" >> "${SNAPSHOT_DIR}/system-info.txt"
echo "" >> "${SNAPSHOT_DIR}/system-info.txt"
echo "Hostname: $(hostname)" >> "${SNAPSHOT_DIR}/system-info.txt"
echo "Uptime: $(uptime)" >> "${SNAPSHOT_DIR}/system-info.txt"
echo "Kernel: $(uname -a)" >> "${SNAPSHOT_DIR}/system-info.txt"

# 7. Create summary JSON for Wazuh ingestion
cat > "${SNAPSHOT_DIR}/summary.json" << EOF
{
  "source": "honeypot-forensics",
  "snapshot_id": "${SNAPSHOT_ID}",
  "alert_id": "${ALERT_ID}",
  "rule_id": "${RULE_ID}",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "hostname": "$(hostname)",
  "user": "${SRC_USER}",
  "process": {
    "name": "${PROCESS_NAME}",
    "pid": "${PROCESS_PID}"
  },
  "snapshot_path": "${SNAPSHOT_DIR}",
  "files_captured": $(ls -1 "$SNAPSHOT_DIR" | wc -l)
}
EOF

# Set permissions
chmod -R 640 "$SNAPSHOT_DIR"
chown -R root:wazuh "$SNAPSHOT_DIR"

echo "$(date) - Honeypot forensic snapshot completed: ${SNAPSHOT_DIR}" >> "$LOG_FILE"

exit 0
