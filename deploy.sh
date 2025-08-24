#!/bin/bash

# AI English Assistant 部署脚本
# 使用方法: ./deploy.sh [dev|prod|stop|logs|backup]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查Docker是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose 未安装，请先安装 Docker Compose"
        exit 1
    fi
    
    log_success "Docker 环境检查通过"
}

# 检查环境变量文件
check_env() {
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            log_warning ".env 文件不存在，正在从 .env.example 复制..."
            cp .env.example .env
            log_warning "请编辑 .env 文件并设置正确的配置值"
        else
            log_error ".env 和 .env.example 文件都不存在"
            exit 1
        fi
    fi
    log_success "环境变量文件检查通过"
}

# 创建必要的目录
create_directories() {
    log_info "创建必要的目录..."
    mkdir -p logs
    mkdir -p backups
    mkdir -p data/{postgres,redis,qdrant,prometheus,grafana}
    mkdir -p nginx/logs
    mkdir -p monitoring
    log_success "目录创建完成"
}

# 开发环境部署
deploy_dev() {
    log_info "部署开发环境..."
    check_docker
    check_env
    create_directories
    
    # 停止现有容器
    docker-compose down
    
    # 构建并启动服务
    docker-compose up --build -d
    
    # 等待服务启动
    log_info "等待服务启动..."
    sleep 10
    
    # 检查服务状态
    check_services
    
    log_success "开发环境部署完成！"
    log_info "API服务: http://localhost:8000"
    log_info "API文档: http://localhost:8000/docs"
    log_info "数据库: localhost:5432"
    log_info "Redis: localhost:6379"
    log_info "Qdrant: http://localhost:6333"
}

# 生产环境部署
deploy_prod() {
    log_info "部署生产环境..."
    check_docker
    check_env
    create_directories
    
    # 检查必要的环境变量
    if [ -z "$OPENAI_API_KEY" ]; then
        log_error "请在 .env 文件中设置 OPENAI_API_KEY"
        exit 1
    fi
    
    # 拉取最新镜像
    log_info "拉取最新镜像..."
    docker-compose -f docker-compose.prod.yml pull
    
    # 停止现有容器
    docker-compose -f docker-compose.prod.yml down
    
    # 启动生产服务
    docker-compose -f docker-compose.prod.yml up -d
    
    # 等待服务启动
    log_info "等待服务启动..."
    sleep 15
    
    # 检查服务状态
    check_services_prod
    
    log_success "生产环境部署完成！"
    log_info "应用访问地址: http://localhost"
    log_info "监控面板: http://localhost:3001 (admin/admin)"
    log_info "Prometheus: http://localhost:9090"
}

# 检查服务状态
check_services() {
    log_info "检查服务状态..."
    
    services=("api" "db" "redis" "qdrant")
    
    for service in "${services[@]}"; do
        if docker-compose ps | grep -q "${service}.*Up"; then
            log_success "$service 服务运行正常"
        else
            log_error "$service 服务启动失败"
        fi
    done
    
    # 检查API健康状态
    log_info "检查API健康状态..."
    for i in {1..30}; do
        if curl -f http://localhost:8000/health &>/dev/null; then
            log_success "API服务健康检查通过"
            return 0
        fi
        sleep 2
    done
    log_warning "API服务健康检查超时"
}

# 检查生产服务状态
check_services_prod() {
    log_info "检查生产服务状态..."
    
    services=("api" "db" "redis" "qdrant" "nginx")
    
    for service in "${services[@]}"; do
        if docker-compose -f docker-compose.prod.yml ps | grep -q "${service}.*Up"; then
            log_success "$service 服务运行正常"
        else
            log_error "$service 服务启动失败"
        fi
    done
}

# 停止服务
stop_services() {
    log_info "停止服务..."
    
    if [ -f "docker-compose.prod.yml" ]; then
        docker-compose -f docker-compose.prod.yml down
    fi
    
    docker-compose down
    
    log_success "服务已停止"
}

# 查看日志
view_logs() {
    if [ -n "$2" ]; then
        # 查看特定服务的日志
        docker-compose logs -f "$2"
    else
        # 查看所有服务的日志
        docker-compose logs -f
    fi
}

# 备份数据
backup_data() {
    log_info "开始数据备份..."
    
    timestamp=$(date +"%Y%m%d_%H%M%S")
    backup_dir="backups/backup_$timestamp"
    
    mkdir -p "$backup_dir"
    
    # 备份数据库
    log_info "备份数据库..."
    docker-compose exec -T db pg_dump -U user english_assistant > "$backup_dir/database.sql"
    
    # 备份Redis数据
    log_info "备份Redis数据..."
    docker-compose exec -T redis redis-cli BGSAVE
    docker cp $(docker-compose ps -q redis):/data/dump.rdb "$backup_dir/redis.rdb"
    
    # 备份Qdrant数据
    log_info "备份Qdrant数据..."
    docker cp $(docker-compose ps -q qdrant):/qdrant/storage "$backup_dir/qdrant_storage"
    
    # 压缩备份
    tar -czf "backups/backup_$timestamp.tar.gz" -C "backups" "backup_$timestamp"
    rm -rf "$backup_dir"
    
    log_success "数据备份完成: backups/backup_$timestamp.tar.gz"
}

# 恢复数据
restore_data() {
    if [ -z "$2" ]; then
        log_error "请指定备份文件: ./deploy.sh restore backup_file.tar.gz"
        exit 1
    fi
    
    backup_file="$2"
    
    if [ ! -f "$backup_file" ]; then
        log_error "备份文件不存在: $backup_file"
        exit 1
    fi
    
    log_warning "数据恢复将覆盖现有数据，请确认操作 (y/N)"
    read -r confirm
    
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        log_info "操作已取消"
        exit 0
    fi
    
    log_info "开始数据恢复..."
    
    # 解压备份文件
    temp_dir="/tmp/restore_$(date +%s)"
    mkdir -p "$temp_dir"
    tar -xzf "$backup_file" -C "$temp_dir"
    
    # 恢复数据库
    if [ -f "$temp_dir/*/database.sql" ]; then
        log_info "恢复数据库..."
        docker-compose exec -T db psql -U user -d english_assistant < "$temp_dir/*/database.sql"
    fi
    
    # 清理临时文件
    rm -rf "$temp_dir"
    
    log_success "数据恢复完成"
}

# 更新应用
update_app() {
    log_info "更新应用..."
    
    # 拉取最新代码
    git pull origin main
    
    # 重新部署
    if [ -f "docker-compose.prod.yml" ]; then
        deploy_prod
    else
        deploy_dev
    fi
}

# 显示帮助信息
show_help() {
    echo "AI English Assistant 部署脚本"
    echo ""
    echo "使用方法:"
    echo "  ./deploy.sh dev              - 部署开发环境"
    echo "  ./deploy.sh prod             - 部署生产环境"
    echo "  ./deploy.sh stop             - 停止所有服务"
    echo "  ./deploy.sh logs [service]   - 查看日志"
    echo "  ./deploy.sh backup           - 备份数据"
    echo "  ./deploy.sh restore <file>   - 恢复数据"
    echo "  ./deploy.sh update           - 更新应用"
    echo "  ./deploy.sh status           - 查看服务状态"
    echo "  ./deploy.sh help             - 显示帮助信息"
    echo ""
    echo "示例:"
    echo "  ./deploy.sh dev              # 启动开发环境"
    echo "  ./deploy.sh logs api         # 查看API服务日志"
    echo "  ./deploy.sh backup           # 备份数据"
}

# 查看服务状态
show_status() {
    log_info "服务状态:"
    docker-compose ps
    
    if [ -f "docker-compose.prod.yml" ]; then
        log_info "生产服务状态:"
        docker-compose -f docker-compose.prod.yml ps
    fi
}

# 主函数
main() {
    case "$1" in
        "dev")
            deploy_dev
            ;;
        "prod")
            deploy_prod
            ;;
        "stop")
            stop_services
            ;;
        "logs")
            view_logs "$@"
            ;;
        "backup")
            backup_data
            ;;
        "restore")
            restore_data "$@"
            ;;
        "update")
            update_app
            ;;
        "status")
            show_status
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        "")
            log_error "请指定操作类型"
            show_help
            exit 1
            ;;
        *)
            log_error "未知操作: $1"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"