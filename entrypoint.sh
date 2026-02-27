#!/bin/sh
set -e

DATA_DIR="/opt/openlist/data"
# 若有其他需要写入的目录，可在此添加，例如：
# CONFIG_DIR="/opt/openlist/config"
# LOGS_DIR="/opt/openlist/logs"

echo "Fixing permissions for Railway volume..."

# 确保数据目录存在
mkdir -p "$DATA_DIR"

if [ "$(id -u)" = "0" ]; then
    echo "Running as root, fixing permissions for UID 1001..."

    # 更改数据目录所有者为 1001:1001
    chown -R 1001:1001 "$DATA_DIR"

    # 设置目录权限为 755，文件权限为 644
    find "$DATA_DIR" -type d -exec chmod 755 {} \;
    find "$DATA_DIR" -type f -exec chmod 644 {} \;

    # 如有其他目录，同样处理
    # if [ -d "$CONFIG_DIR" ]; then
    #     chown -R 1001:1001 "$CONFIG_DIR"
    #     find "$CONFIG_DIR" -type d -exec chmod 755 {} \;
    #     find "$CONFIG_DIR" -type f -exec chmod 644 {} \;
    # fi

    echo "Permissions fixed. Switching to user 1001 to execute command."

    if command -v su-exec >/dev/null 2>&1; then
        exec su-exec 1001:1001 "$@"
    else
        echo "su-exec not found, cannot switch user. Please install su-exec or run as user 1001."
        exit 1
    fi
else
    CURRENT_UID=$(id -u)
    if [ "$CURRENT_UID" = "1001" ]; then
        echo "Running as UID 1001, no need to switch. Executing command directly."
        exec "$@"
    else
        echo "Warning: Not running as root and current UID is $CURRENT_UID (expected 1001)."
        echo "This may cause permission issues if OpenList requires UID 1001."
        echo "Attempting to execute command as current user. If it fails, please run the container as root or ensure UID 1001 is used."
        exec "$@"
    fi
fi
