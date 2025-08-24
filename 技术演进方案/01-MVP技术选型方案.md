# AI英语工作助手 - MVP技术选型方案

## 概述

本文档定义了AI英语工作助手的MVP（最小可行产品）阶段技术选型方案。该方案以**零成本启动、快速验证、平滑扩展**为核心原则，确保后续技术升级对用户无感知。

## 技术架构图

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   浏览器插件     │    │   桌面应用       │    │   移动端H5      │
│  (Chrome Ext)   │    │  (Electron)     │    │  (PWA/H5)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   前端统一接口   │
                    │  (API Gateway)  │
                    └─────────────────┘
                                 │
                    ┌─────────────────┐
                    │   后端服务       │
                    │  (Node.js/python)   │
                    └─────────────────┘
                                 │
        ┌────────────────────────┼────────────────────────┐
        │                       │                        │
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  SQLite     │    │   Redis     │    │   Qdrant    │    │   MinIO     │
│ (本地数据库) │    │  (缓存)     │    │ (向量数据库) │    │ (文件存储)   │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                 │
                    ┌─────────────────┐
                    │   AI模型服务     │
                    │ (免费API组合)    │
                    └─────────────────┘
```

## 核心技术选型

### 1. 前端技术栈

#### 浏览器插件
- **技术**: Manifest V3 + React + TypeScript
- **构建工具**: Vite + CRXJS
- **UI框架**: Ant Design / Chakra UI
- **状态管理**: Zustand
- **优势**: 开发效率高，生态成熟，易于维护

#### 桌面应用
- **技术**: Electron + React + TypeScript
- **打包**: Electron Builder
- **更新**: Electron Updater
- **优势**: 代码复用，跨平台支持

#### 移动端
- **技术**: PWA + React + TypeScript
- **UI**: Ant Design Mobile
- **优势**: 无需应用商店，快速部署

### 2. 后端技术栈

#### 主服务
- **语言**: Python
- **框架**: FastAPI + Uvicorn
- **ORM**: SQLAlchemy + Alembic
- **API**: RESTful + WebSocket
- **认证**: JWT + Refresh Token
- **优势**: 与AI/ML生态系统完美集成，支持CrewAI、LangGraph等AI库，开发效率高

#### 数据存储

**关系数据库**
- **选择**: SQLite (本地文件)
- **ORM**: SQLAlchemy + Alembic
- **迁移策略**: 内置迁移脚本，支持版本升级
- **优势**: 零配置，零成本，易于备份和迁移

**缓存系统**
- **选择**: Redis (Docker部署)
- **用途**: 会话缓存、API限流、热点数据
- **配置**: 单实例，持久化开启
- **优势**: 性能优秀，功能丰富

**向量数据库**
- **选择**: Qdrant (Docker部署)
- **配置**: 单节点，本地存储
- **用途**: 词汇语义搜索、相似句子匹配
- **优势**: 轻量级，API友好，易于扩展

**文件存储**
- **选择**: MinIO (Docker部署)
- **配置**: 单节点，本地磁盘
- **用途**: 音频文件、用户头像、导出文件
- **优势**: S3兼容，易于迁移到云存储

### 3. AI模型服务

#### 多模型策略
- **主模型**: 智谱AI GLM-4-Flash (免费额度)
- **备用模型**: 讯飞星火Lite、Kimi、DeepSeek
- **负载均衡**: 轮询 + 故障转移
- **成本控制**: 免费额度监控，智能降级

#### Agent框架选择
- **主框架**: CrewAI (MVP阶段)
  - 简单易用，快速开发
  - 内置角色和任务管理
  - 与LangChain生态完美集成
- **扩展计划**: 后期渐进式引入LangGraph
  - 复杂工作流编排
  - 高级状态管理
  - 条件分支和循环

#### 功能分配
- **翻译**: GLM-4-Flash / 讯飞星火 (CrewAI翻译Agent)
- **语法检查**: DeepSeek / Kimi (CrewAI语法Agent)
- **写作建议**: GLM-4-Flash (CrewAI写作Agent)
- **语音识别**: 浏览器原生API (免费)

### 4. Agent系统实现

#### CrewAI多Agent架构
```python
# agents/english_learning_crew.py
from crewai import Agent, Task, Crew
from langchain_openai import ChatOpenAI
from typing import Dict, Any

class EnglishLearningCrew:
    def __init__(self, api_key: str):
        self.llm = ChatOpenAI(
            api_key=api_key,
            model="glm-4-flash",  # 使用免费模型
            temperature=0.1
        )
        self._setup_agents()
    
    def _setup_agents(self):
        self.translator = Agent(
            role="专业翻译师",
            goal="提供准确、地道的英语翻译",
            backstory="你是经验丰富的英语翻译专家，擅长根据语境提供最合适的翻译",
            llm=self.llm,
            verbose=True
        )
        
        self.grammar_checker = Agent(
            role="语法检查专家",
            goal="识别并纠正英语语法错误",
            backstory="你是英语语法专家，能够准确识别各种语法问题并提供改进建议",
            llm=self.llm,
            verbose=True
        )
        
        self.learning_advisor = Agent(
            role="学习顾问",
            goal="制定个性化英语学习计划",
            backstory="你是专业的语言学习顾问，能够分析用户水平并制定有效学习策略",
            llm=self.llm,
            verbose=True
        )
    
    def translate_text(self, text: str, context: str = "") -> Dict[str, Any]:
        """翻译文本"""
        task = Task(
            description=f"翻译以下文本并提供语境解释：{text}\n语境：{context}",
            agent=self.translator
        )
        
        crew = Crew(
            agents=[self.translator],
            tasks=[task],
            verbose=True
        )
        
        return crew.kickoff()
```

### 5. 部署架构

#### 开发环境
- **容器化**: Docker + Docker Compose
- **服务编排**: 一键启动所有服务
- **热重载**: 前后端代码变更自动重载
- **Agent调试**: CrewAI内置调试工具

#### 生产环境
- **前端**: Vercel (免费) / Cloudflare Pages
- **后端**: Railway (免费额度) / 自建VPS
- **数据库**: 本地SQLite文件
- **监控**: 简单日志 + 健康检查
- **Agent监控**: CrewAI执行日志

## 数据迁移策略

### 1. 数据库版本管理
```sql
-- 版本控制表
CREATE TABLE schema_versions (
    version INTEGER PRIMARY KEY,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description TEXT
);

-- 迁移脚本示例
-- v1_to_v2.sql
ALTER TABLE users ADD COLUMN premium_expires_at TIMESTAMP;
INSERT INTO schema_versions (version, description) 
VALUES (2, 'Add premium subscription support');
```

### 2. 数据导出/导入
```python
# 用户数据导出
from typing import Dict, Any
from sqlalchemy.ext.asyncio import AsyncSession

async def export_user_data(user_id: str, session: AsyncSession) -> Dict[str, Any]:
    """导出用户数据"""
    return {
        "profile": await get_user_profile(user_id, session),
        "vocabulary": await get_user_vocabulary(user_id, session),
        "history": await get_translation_history(user_id, session),
        "settings": await get_user_settings(user_id, session)
    }

# 数据导入（支持版本兼容）
async def import_user_data(data: Dict[str, Any], target_version: str, session: AsyncSession) -> None:
    """导入用户数据，支持版本兼容"""
    migrated_data = await migrate_data_format(data, target_version)
    await restore_user_data(migrated_data, session)

# 数据库双写迁移示例
class DatabaseMigrator:
    def __init__(self, sqlite_session: AsyncSession, postgres_session: AsyncSession):
        self.sqlite_session = sqlite_session
        self.postgres_session = postgres_session
    
    async def migrate_to_postgresql(self) -> None:
        """迁移到PostgreSQL数据库"""
        # 1. 设置双写模式
        await self.enable_dual_write()
        
        # 2. 数据同步
        await self.sync_existing_data()
        
        # 3. 验证数据一致性
        await self.validate_data_consistency()
        
        # 4. 切换读取源
        await self.switch_read_source()
        
        # 5. 停止双写，完成迁移
        await self.complete_migration()
```

### 3. 向量数据迁移
```python
# 向量数据备份
import json
from qdrant_client import QdrantClient
from typing import List, Dict, Any

async def backup_vector_data(qdrant_client: QdrantClient) -> None:
    """备份向量数据"""
    collections = await qdrant_client.get_collections()
    
    for collection in collections.collections:
        collection_name = collection.name
        points = await qdrant_client.scroll(
            collection_name=collection_name,
            limit=1000,
            with_payload=True,
            with_vectors=True
        )
        
        backup_data = {
            "collection_name": collection_name,
            "points": points[0],  # points is tuple (points, next_page_offset)
            "config": await qdrant_client.get_collection(collection_name)
        }
        
        with open(f"backup_{collection_name}.json", "w", encoding="utf-8") as f:
            json.dump(backup_data, f, ensure_ascii=False, indent=2)

# 向量数据恢复
async def restore_vector_data(qdrant_client: QdrantClient, backup_file: str) -> None:
    """恢复向量数据"""
    with open(backup_file, "r", encoding="utf-8") as f:
        backup_data = json.load(f)
    
    collection_name = backup_data["collection_name"]
    
    # 重建集合
    await qdrant_client.recreate_collection(
        collection_name=collection_name,
        vectors_config=backup_data["config"].config.params.vectors
    )
    
    # 恢复数据点
    await qdrant_client.upsert(
        collection_name=collection_name,
        points=backup_data["points"]
    )
```

## 扩展性设计

### 1. 接口抽象
```typescript
// 数据库接口抽象
interface IUserRepository {
  create(user: User): Promise<User>;
  findById(id: string): Promise<User | null>;
  update(id: string, data: Partial<User>): Promise<User>;
}

// SQLite实现
class SQLiteUserRepository implements IUserRepository {
  // 实现细节
}

// 未来PostgreSQL实现
class PostgreSQLUserRepository implements IUserRepository {
  // 实现细节
}
```

### 2. 配置驱动
```yaml
# config/mvp.yaml
database:
  type: sqlite
  path: ./data/app.db
  pool_size: 5
  max_overflow: 10
  echo: false
  
cache:
  type: redis
  url: redis://localhost:6379
  max_connections: 10
  retry_on_timeout: true
  
vector:
  type: qdrant
  url: http://localhost:6333
  timeout: 30
  prefer_grpc: false
  
ai:
  providers:
    - name: zhipu
      model: glm-4-flash
      api_key: ${ZHIPU_API_KEY}
      base_url: https://open.bigmodel.cn/api/paas/v4/
      priority: 1
      rate_limit: 100  # requests per minute
    - name: spark
      model: lite
      api_key: ${SPARK_API_KEY}
      priority: 2
      rate_limit: 200
    - name: deepseek
      model: deepseek-chat
      api_key: ${DEEPSEEK_API_KEY}
      priority: 3
      rate_limit: 150

# config/production.yaml
database:
  type: postgresql
  url: ${DATABASE_URL}
  pool_size: 20
  max_overflow: 30
  
cache:
  type: redis
  url: ${REDIS_URL}
  max_connections: 50
```

### 3. 微服务预留
```python
# 服务接口定义
from abc import ABC, abstractmethod
from typing import Dict, Any, Optional
from dataclasses import dataclass

@dataclass
class TranslateOptions:
    source_lang: str
    target_lang: str
    context: Optional[str] = None
    style: Optional[str] = None

@dataclass
class Translation:
    text: str
    confidence: float
    alternatives: list[str]
    metadata: Dict[str, Any]

class ITranslationService(ABC):
    """翻译服务接口"""
    
    @abstractmethod
    async def translate(self, text: str, options: TranslateOptions) -> Translation:
        """翻译文本"""
        pass

# 当前单体实现
class LocalTranslationService(ITranslationService):
    """本地翻译服务实现"""
    
    def __init__(self, ai_client):
        self.ai_client = ai_client
    
    async def translate(self, text: str, options: TranslateOptions) -> Translation:
        # 本地AI模型调用实现
        result = await self.ai_client.translate(text, options)
        return Translation(
            text=result.text,
            confidence=result.confidence,
            alternatives=result.alternatives,
            metadata={"provider": "local", "model": result.model}
        )

# 未来微服务实现
class RemoteTranslationService(ITranslationService):
    """远程翻译服务实现"""
    
    def __init__(self, service_url: str, api_key: str):
        self.service_url = service_url
        self.api_key = api_key
    
    async def translate(self, text: str, options: TranslateOptions) -> Translation:
        # 远程服务调用实现
        import httpx
        
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.service_url}/translate",
                json={
                    "text": text,
                    "options": options.__dict__
                },
                headers={"Authorization": f"Bearer {self.api_key}"}
            )
            result = response.json()
            return Translation(**result)
```

## 性能优化

### 1. 缓存策略
- **翻译缓存**: 相同文本24小时内直接返回
- **用户会话**: Redis存储，30分钟过期
- **静态资源**: 浏览器缓存 + CDN

### 2. 数据库优化
```sql
-- 关键索引
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_translations_user_created ON translations(user_id, created_at);
CREATE INDEX idx_vocabulary_user_status ON vocabulary(user_id, status);
```

### 3. API限流
```javascript
const rateLimit = {
  translation: '100/hour',
  vocabulary: '1000/hour',
  export: '10/day'
};
```

## 监控与日志

### 1. 基础监控
- **健康检查**: `/health` 端点
- **性能指标**: 响应时间、错误率
- **资源监控**: CPU、内存、磁盘使用

### 2. 日志策略
```javascript
const logger = {
  level: 'info',
  format: 'json',
  outputs: ['console', 'file'],
  rotation: 'daily'
};
```

## 成本估算

### 开发阶段（月成本）
- **AI模型**: $0 (免费额度)
- **部署**: $0 (Vercel + Railway免费)
- **存储**: $0 (本地存储)
- **监控**: $0 (基础监控)
- **总计**: **$0/月**

### 用户增长预期
- **0-100用户**: 完全免费
- **100-1000用户**: $0-20/月
- **1000-5000用户**: $20-100/月

## 风险控制

### 1. 技术风险
- **单点故障**: 本地备份 + 云端同步
- **API限制**: 多模型轮询 + 降级策略
- **数据丢失**: 定期备份 + 版本控制

### 2. 成本风险
- **免费额度耗尽**: 自动降级到基础功能
- **用户增长**: 分阶段付费升级
- **存储成本**: 数据清理 + 压缩策略

## 下一阶段准备

### 1. 架构预留
- 数据库连接池配置
- 负载均衡器接口
- 微服务通信协议
- 分布式缓存支持

### 2. 数据准备
- 用户数据导出API
- 配置文件版本管理
- 数据库迁移脚本
- 向量数据备份工具

### 3. 监控准备
- 性能基线建立
- 关键指标定义
- 告警阈值设置
- 日志格式标准化

## 总结

MVP阶段技术选型以**零成本、快速验证、平滑扩展**为核心，通过合理的架构设计和接口抽象，确保后续升级对用户透明。重点关注数据迁移能力和配置驱动设计，为中期扩展奠定坚实基础。