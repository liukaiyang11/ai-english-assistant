# 后端开发文档

## 目录说明

本目录包含后端开发相关的技术文档，涵盖API服务、数据库设计、系统架构等内容。

## 📚 文档列表

### 核心技术文档
- [技术实现方案.md](./技术实现方案.md) - 后端技术架构和实现方案
- [数据库设计.md](./数据库设计.md) - 完整的数据库设计文档
- [API接口文档.md](./API接口文档.md) - 详细的API接口规范

### 必读参考文档
- [项目说明](../common/项目说明.md) - 了解业务需求
- [架构设计](../architecture/) - 了解整体技术架构

## 🛠 技术栈

### 核心框架
- **语言**: Python 3.11+
- **Web框架**: FastAPI + Uvicorn
- **ORM**: SQLAlchemy + Alembic
- **异步**: asyncio + aiohttp

### 数据存储
- **关系数据库**: PostgreSQL
- **缓存**: Redis
- **向量数据库**: Qdrant
- **文件存储**: MinIO/S3

### AI集成
- **RAG框架**: LightRAG
- **Agent框架**: CrewAI
- **工作流**: LangGraph

## 🎯 开发重点

### 1. API设计
- RESTful API规范
- WebSocket实时通信
- API版本管理
- 接口文档维护

### 2. 数据管理
- 数据库设计优化
- 数据迁移脚本
- 缓存策略
- 数据备份恢复

### 3. 性能优化
- 异步处理
- 数据库查询优化
- 缓存机制
- 负载均衡

### 4. AI集成
- LLM模型集成
- 向量搜索优化
- Agent工作流设计
- 知识图谱构建

## 🔧 开发工具

- **IDE**: PyCharm, VS Code
- **API测试**: Postman, Insomnia
- **数据库**: pgAdmin, Redis Desktop Manager
- **监控**: Prometheus, Grafana
- **日志**: ELK Stack