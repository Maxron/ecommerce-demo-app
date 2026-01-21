# Makefile for Spring Boot E-commerce Demo with Docker / Podman support

# =============================================
# 偵測容器工具：docker 或 podman
# =============================================
ifeq ($(shell command -v docker 2>/dev/null),)
    ifeq ($(shell command -v podman 2>/dev/null),)
        $(error Neither docker nor podman is installed. Please install one of them.)
    else
        CONTAINER_TOOL = podman
        COMPOSE_TOOL = podman-compose
    endif
else
    CONTAINER_TOOL = docker
    COMPOSE_TOOL = docker compose
endif

# =============================================
# 變數定義
# =============================================
COMPOSE_FILE = compose.yaml
APP_CONTAINER = ecommerce-demo-app
MYSQL_CONTAINER = ecommerce-demo-mysql

# 顏色輸出（方便閱讀）
NO_COLOR=\033[0m
GREEN=\033[32;01m
RED=\033[31;01m
YELLOW=\033[33;01m

# =============================================
# 主要目標
# =============================================

.PHONY: help up down build rebuild logs clean reset db-shell app-shell status detect

help: ## 顯示此幫助訊息
	@echo "$(GREEN)E-commerce Demo Makefile - 使用 $(CONTAINER_TOOL)$(NO_COLOR)"
	@echo "偵測到的容器工具：$(YELLOW)$(CONTAINER_TOOL)$(NO_COLOR)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NO_COLOR) %s\n", $$1, $$2}'

detect: ## 顯示目前偵測到的容器工具
	@echo "容器工具：$(CONTAINER_TOOL)"
	@echo "Compose 工具：$(COMPOSE_TOOL)"

up: ## 啟動所有服務（build + up）
	@echo "$(GREEN)使用 $(CONTAINER_TOOL) 啟動服務...$(NO_COLOR)"
	$(COMPOSE_TOOL) -f $(COMPOSE_FILE) up -d --build

down: ## 停止並移除容器（不刪 volume）
	$(COMPOSE_TOOL) -f $(COMPOSE_FILE) down

down-v: ## 停止並移除容器 + volume（清空資料庫）
	$(COMPOSE_TOOL) -f $(COMPOSE_FILE) down -v

build: ## 只 build 應用程式映像（不啟動）
	$(COMPOSE_TOOL) -f $(COMPOSE_FILE) build

rebuild: down build up ## 先 down 再完整重建並啟動

logs: ## 顯示應用程式 log（即時追蹤）
	$(CONTAINER_TOOL) logs -f $(APP_CONTAINER)

logs-mysql: ## 顯示 MySQL log
	$(CONTAINER_TOOL) logs -f $(MYSQL_CONTAINER)

clean: down-v ## 完整清理（停止 + 移除 volume + 映像）
	@echo "$(YELLOW)移除所有相關映像...$(NO_COLOR)"
	-$(CONTAINER_TOOL) rmi $$( $(CONTAINER_TOOL) images -q --filter "reference=ecommerce-be-demo*" ) 2>/dev/null || true

reset: clean up ## 完整重置（清空一切後重新啟動）

status: ## 顯示目前容器狀態
	$(CONTAINER_TOOL) ps -a --filter "name=ecommerce-demo"

db-shell: ## 進入 MySQL 容器（mysql client）
	$(CONTAINER_TOOL) exec -it $(MYSQL_CONTAINER) mysql -u ecommerce -p'ecommerce' ecommerce

app-shell: ## 進入應用程式容器（bash）
	$(CONTAINER_TOOL) exec -it $(APP_CONTAINER) /bin/sh

ps: status ## 別名：顯示容器狀態

# =============================================
# Flyway 相關（選用，如果想直接用 flyway cli）
# =============================================

flyway-repair: ## 執行 Flyway repair（需先安裝 flyway cli 或用容器）
	@echo "如需 Flyway repair，請手動執行或使用容器方式"
	@echo "或在 application.properties 暫時設定 spring.flyway.validate-on-migrate=false 後重啟"

# =============================================
# 新增：只啟動 MySQL（開發時單獨用資料庫測試 / migration 驗證）
# =============================================

dev.db: ## 只啟動 MySQL 服務（不啟動應用程式）
	@echo "$(GREEN)使用 $(CONTAINER_TOOL) 只啟動 MySQL 服務...$(NO_COLOR)"
	$(COMPOSE_TOOL) -f $(COMPOSE_FILE) up -d mysql

dev.db-down: ## 停止 MySQL 服務
	$(COMPOSE_TOOL) -f $(COMPOSE_FILE) stop mysql
	$(COMPOSE_TOOL) -f $(COMPOSE_FILE) rm -f mysql

dev.db-restart: ## 重啟 MySQL 服務
	$(COMPOSE_TOOL) -f $(COMPOSE_FILE) restart mysql

dev.db-logs: ## 查看 MySQL log（即時追蹤）
	$(CONTAINER_TOOL) logs -f $(MYSQL_CONTAINER)

dev.db-clean: ## 停止 MySQL 並移除 volume（清空資料庫）
	$(COMPOSE_TOOL) -f $(COMPOSE_FILE) down -v --remove-orphans
	@echo "$(YELLOW)MySQL 資料已完全清除，可用 dev.db 重新啟動$(NO_COLOR)"

# =============================================
# 預設目標
# =============================================
default: help