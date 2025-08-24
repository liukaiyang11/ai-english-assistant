# Git工作流规范

## 🌿 分支结构

### 当前分支设置
```
📦 main (生产分支) - 稳定代码，用于部署
└── 🚀 develop (开发分支) - 日常开发，集成最新功能
```

## 🔄 分支合并机制

### 1. 合并策略

**develop → main 合并机制：**
- ✅ **Pull Request (推荐)** - 通过GitHub PR进行代码审查
- ✅ **Fast-forward合并** - 保持线性历史
- ✅ **Squash合并** - 将多个提交压缩为一个

**GitHub Actions触发：**
- `develop` 分支推送 → 自动部署到开发环境
- `main` 分支合并 → 自动部署到生产环境

### 2. 分支保护规则

**main分支保护 (建议设置)：**
```bash
# 在GitHub仓库设置中配置
- 要求Pull Request审查
- 要求状态检查通过 (CI/CD)
- 要求分支为最新状态
- 限制推送到匹配分支
```

**develop分支：**
- 允许直接推送 (个人开发阶段)
- 团队协作时可设置PR要求

## 📋 个人开发阶段工作流规范

### 🎯 日常开发流程

#### 1. 功能开发
```bash
# 1. 切换到develop分支
git checkout develop
git pull origin develop

# 2. 日常开发和提交
git add .
git commit -m "feat: 添加用户认证功能"
git push origin develop

# 3. 功能稳定后合并到main
git checkout main
git pull origin main
git merge develop
git push origin main
```

#### 2. 大功能开发 (可选)
```bash
# 1. 创建功能分支
git checkout develop
git checkout -b feature/user-authentication

# 2. 开发功能
git add .
git commit -m "feat: 实现JWT认证"
git push origin feature/user-authentication

# 3. 合并回develop
git checkout develop
git merge feature/user-authentication
git push origin develop

# 4. 删除功能分支
git branch -d feature/user-authentication
git push origin --delete feature/user-authentication
```

### 🛡️ 避免混乱的规则

#### ✅ 好的实践

1. **明确分支用途**
   - `main`: 只放稳定、可部署的代码
   - `develop`: 日常开发，可以有小bug
   - `feature/*`: 大功能开发，完成后删除

2. **提交规范**
   ```bash
   # 使用语义化提交信息
   feat: 新功能
   fix: 修复bug
   docs: 文档更新
   style: 代码格式
   refactor: 重构
   test: 测试
   chore: 构建/工具
   ```

3. **合并前检查**
   ```bash
   # 合并前确保代码质量
   git status          # 检查工作区状态
   git log --oneline   # 查看提交历史
   git diff main       # 查看与main的差异
   ```

4. **定期同步**
   ```bash
   # 每天开始工作前
   git checkout develop
   git pull origin develop
   git pull origin main  # 同步main的更新
   ```

#### ❌ 避免的问题

1. **不要直接在main分支开发**
   ```bash
   # ❌ 错误做法
   git checkout main
   # 直接在main上修改代码
   
   # ✅ 正确做法
   git checkout develop
   # 在develop上开发
   ```

2. **不要强制推送**
   ```bash
   # ❌ 危险操作
   git push --force
   
   # ✅ 安全做法
   git pull --rebase
   git push
   ```

3. **不要忘记拉取最新代码**
   ```bash
   # ❌ 可能导致冲突
   git commit -m "新功能"
   git push
   
   # ✅ 先同步再推送
   git pull
   git commit -m "新功能"
   git push
   ```

## 🚀 团队协作准备

### 扩展分支策略
当团队成员加入时，可以扩展为：

```
📦 main (生产分支)
├── 🚀 develop (集成分支)
├── 🔧 feature/frontend-ui (张三开发)
├── 🔧 feature/ai-integration (李四开发)
├── 🐛 hotfix/critical-bug (紧急修复)
└── 📋 release/v1.0.0 (发布准备)
```

### Pull Request工作流
```bash
# 1. 创建功能分支
git checkout -b feature/new-feature

# 2. 开发并推送
git push origin feature/new-feature

# 3. 在GitHub创建PR
# develop ← feature/new-feature

# 4. 代码审查通过后合并
# 5. 删除功能分支
```

## 📊 分支状态监控

### 常用命令
```bash
# 查看所有分支
git branch -a

# 查看分支关系
git log --graph --oneline --all

# 查看远程分支状态
git remote show origin

# 清理已删除的远程分支
git remote prune origin
```

### GitHub Actions集成
- `develop` 推送 → 开发环境部署
- `main` 推送 → 生产环境部署
- PR创建 → 自动化测试

## 🎯 总结

**个人开发阶段核心规则：**
1. 日常开发在 `develop` 分支
2. 稳定功能合并到 `main` 分支
3. 使用语义化提交信息
4. 合并前先拉取最新代码
5. 保持 `main` 分支随时可部署

**这样既保证了代码质量，又为未来团队协作打好了基础！**