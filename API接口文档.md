# AI英语工作助手 - API接口文档

## 接口概览

**Base URL**: `https://api.englishassistant.com/v1`

**认证方式**: Bearer Token

**请求格式**: JSON

**响应格式**: JSON

## 通用响应格式

### 成功响应
```json
{
  "success": true,
  "data": {},
  "message": "操作成功",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

### 错误响应
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "错误描述",
    "details": {}
  },
  "timestamp": "2024-01-01T00:00:00Z"
}
```

## 1. 用户认证接口

### 1.1 用户注册

**POST** `/auth/register`

**请求参数**:
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "用户姓名"
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "user_id": "uuid",
    "email": "user@example.com",
    "name": "用户姓名",
    "subscription_type": "free",
    "token": "jwt_token"
  }
}
```

### 1.2 用户登录

**POST** `/auth/login`

**请求参数**:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "user_id": "uuid",
    "email": "user@example.com",
    "name": "用户姓名",
    "subscription_type": "premium",
    "token": "jwt_token",
    "expires_at": "2024-01-01T00:00:00Z"
  }
}
```

### 1.3 刷新Token

**POST** `/auth/refresh`

**Headers**: `Authorization: Bearer {refresh_token}`

**响应**:
```json
{
  "success": true,
  "data": {
    "token": "new_jwt_token",
    "expires_at": "2024-01-01T00:00:00Z"
  }
}
```

## 2. Agent翻译接口

### 2.1 智能翻译（Agent驱动）

**POST** `/agent/translate`

**Headers**: `Authorization: Bearer {token}`

**请求参数**:
```json
{
  "text": "Hello world",
  "source_lang": "en",
  "target_lang": "zh",
  "context": "这是一个编程术语",
  "source_url": "https://example.com",
  "save_to_history": true,
  "processing_mode": "comprehensive",
  "session_id": "optional_session_id"
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "session_id": "agent_session_12345",
    "workflow_status": "completed",
    "processing_time_ms": 1250,
    "original_text": "Hello world",
    "translated_text": "你好世界",
    "source_lang": "en",
    "target_lang": "zh",
    "confidence": 0.95,
    "quality_score": 0.92,
    "context_analysis": {
      "domain": "programming",
      "formality": "informal",
      "complexity": "basic",
      "sentiment": "neutral",
      "technical_terms": ["world"]
    },
    "translation_analysis": {
      "method_used": "complex_translator",
      "grammar_check_passed": true,
      "style_consistency": "high"
    },
    "alternative_translations": [
      {
        "text": "世界你好",
        "confidence": 0.88,
        "use_case": "casual_greeting"
      },
      {
        "text": "哈喽世界",
        "confidence": 0.75,
        "use_case": "informal_tech"
      }
    ],
    "grammar_analysis": {
      "errors_found": 0,
      "suggestions": [],
      "complexity_rating": "beginner"
    },
    "learning_recommendations": [
      {
        "type": "vocabulary",
        "suggestion": "学习更多编程相关词汇",
        "priority": "medium"
      },
      {
        "type": "practice",
        "suggestion": "练习技术文档翻译",
        "priority": "low"
      }
    ],
    "related_words": [
      {
        "word": "world",
        "translation": "世界",
        "frequency": "high",
        "difficulty": 1
      }
    ],
    "pronunciation": {
      "ipa": "/həˈloʊ wɜːrld/",
      "audio_url": "https://audio.example.com/hello-world.mp3"
    },
    "usage_examples": [
      {
        "english": "Hello world program",
        "chinese": "Hello world程序",
        "context": "编程入门",
        "difficulty": 1
      }
    ],
    "agent_metadata": {
      "workflow_steps": [
        "input_validation",
        "context_analysis",
        "complex_translation",
        "grammar_check",
        "quality_assessment",
        "learning_advice"
      ],
      "processing_nodes_used": 6,
      "checkpoint_saved": true
    }
  }
}
```

### 2.2 Agent工作流状态查询

**GET** `/agent/workflow/{session_id}/status`

**Headers**: `Authorization: Bearer {token}`

**响应**:
```json
{
  "success": true,
  "data": {
    "session_id": "agent_session_12345",
    "status": "running",
    "current_step": "grammar_check",
    "progress_percentage": 75,
    "steps_completed": [
      "input_validation",
      "context_analysis",
      "complex_translation"
    ],
    "steps_remaining": [
      "quality_assessment",
      "learning_advice"
    ],
    "estimated_completion_time": "2024-01-01T00:00:30Z",
    "checkpoint_available": true
  }
}
```

### 2.3 批量智能翻译

**POST** `/agent/translate/batch`

**Headers**: `Authorization: Bearer {token}`

**请求参数**:
```json
{
  "texts": [
    {
      "text": "Hello",
      "context": "greeting",
      "priority": "high"
    },
    {
      "text": "World",
      "context": "noun",
      "priority": "normal"
    }
  ],
  "source_lang": "en",
  "target_lang": "zh",
  "processing_mode": "parallel",
  "session_id": "batch_session_67890"
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "session_id": "batch_session_67890",
    "batch_status": "completed",
    "total_processing_time_ms": 2100,
    "results": [
      {
        "original_text": "Hello",
        "translated_text": "你好",
        "confidence": 0.98,
        "quality_score": 0.95,
        "workflow_status": "completed",
        "processing_method": "simple_translator",
        "grammar_check_passed": true
      },
      {
        "original_text": "World",
        "translated_text": "世界",
        "confidence": 0.95,
        "quality_score": 0.93,
        "workflow_status": "completed",
        "processing_method": "simple_translator",
        "grammar_check_passed": true
      }
    ],
    "statistics": {
      "total_count": 2,
      "success_count": 2,
      "failed_count": 0,
      "average_confidence": 0.965,
      "average_quality_score": 0.94
    },
    "agent_metadata": {
      "parallel_workflows": 2,
      "checkpoints_saved": 2,
      "total_nodes_processed": 12
    }
  }
}
```

### 2.4 OCR智能翻译

**POST** `/agent/translate/ocr`

**Headers**: `Authorization: Bearer {token}`

**Content-Type**: `multipart/form-data`

**请求参数**:
```
image: [图片文件]
lang: en
target_lang: zh
processing_mode: comprehensive
session_id: ocr_session_11111
enhance_image: true
```

**响应**:
```json
{
  "success": true,
  "data": {
    "session_id": "ocr_session_11111",
    "workflow_status": "completed",
    "processing_time_ms": 3200,
    "ocr_analysis": {
      "detected_text": "Hello World",
      "ocr_confidence": 0.96,
      "text_regions": 2,
      "image_quality": "high"
    },
    "translation_result": {
      "translated_text": "你好世界",
      "translation_confidence": 0.92,
      "quality_score": 0.89,
      "processing_method": "complex_translator"
    },
    "bounding_boxes": [
      {
        "text": "Hello",
        "translation": "你好",
        "x": 10,
        "y": 20,
        "width": 50,
        "height": 20,
        "confidence": 0.95
      },
      {
        "text": "World",
        "translation": "世界",
        "x": 70,
        "y": 20,
        "width": 45,
        "height": 20,
        "confidence": 0.94
      }
    ],
    "context_analysis": {
      "domain": "general",
      "formality": "informal",
      "complexity": "basic"
    },
    "learning_recommendations": [
      {
        "type": "vocabulary",
        "suggestion": "学习基础问候语",
        "priority": "high"
      }
    ],
    "agent_metadata": {
      "workflow_steps": [
        "image_preprocessing",
        "ocr_extraction",
        "text_validation",
        "translation_processing",
        "quality_assessment"
      ],
      "processing_nodes_used": 5,
      "checkpoint_saved": true
    }
  }
}
```

## 3. 词汇管理接口

### 3.1 保存词汇

**POST** `/vocabulary`

**Headers**: `Authorization: Bearer {token}`

**请求参数**:
```json
{
  "word": "algorithm",
  "translation": "算法",
  "context": "A step-by-step procedure for calculations",
  "source_url": "https://example.com",
  "tags": ["programming", "computer-science"],
  "difficulty": 3,
  "notes": "用户自定义笔记"
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "vocabulary_id": "uuid",
    "word": "algorithm",
    "translation": "算法",
    "context": "A step-by-step procedure for calculations",
    "tags": ["programming", "computer-science"],
    "difficulty": 3,
    "mastery_level": 0,
    "created_at": "2024-01-01T00:00:00Z",
    "next_review_date": "2024-01-02T00:00:00Z"
  }
}
```

### 3.2 获取词汇列表

**GET** `/vocabulary`

**Headers**: `Authorization: Bearer {token}`

**查询参数**:
- `page`: 页码 (默认: 1)
- `limit`: 每页数量 (默认: 20, 最大: 100)
- `tags`: 标签过滤 (可选)
- `difficulty`: 难度过滤 (可选)
- `mastery_level`: 掌握程度过滤 (可选)
- `search`: 搜索关键词 (可选)
- `sort`: 排序方式 (created_at, difficulty, mastery_level)
- `order`: 排序顺序 (asc, desc)

**响应**:
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "vocabulary_id": "uuid",
        "word": "algorithm",
        "translation": "算法",
        "context": "A step-by-step procedure for calculations",
        "tags": ["programming"],
        "difficulty": 3,
        "mastery_level": 2,
        "review_count": 5,
        "last_reviewed": "2024-01-01T00:00:00Z",
        "next_review_date": "2024-01-03T00:00:00Z",
        "created_at": "2024-01-01T00:00:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 10,
      "total_items": 200,
      "items_per_page": 20
    }
  }
}
```

### 3.3 更新词汇

**PUT** `/vocabulary/{vocabulary_id}`

**Headers**: `Authorization: Bearer {token}`

**请求参数**:
```json
{
  "translation": "新的翻译",
  "tags": ["updated-tag"],
  "difficulty": 4,
  "notes": "更新的笔记"
}
```

### 3.4 删除词汇

**DELETE** `/vocabulary/{vocabulary_id}`

**Headers**: `Authorization: Bearer {token}`

**响应**:
```json
{
  "success": true,
  "message": "词汇删除成功"
}
```

### 3.5 获取相关词汇

**GET** `/vocabulary/{vocabulary_id}/related`

**Headers**: `Authorization: Bearer {token}`

**响应**:
```json
{
  "success": true,
  "data": {
    "related_words": [
      {
        "word": "function",
        "translation": "函数",
        "similarity_score": 0.85,
        "relation_type": "semantic"
      }
    ]
  }
}
```

## 4. 复习系统接口

### 4.1 获取今日复习

**GET** `/review/today`

**Headers**: `Authorization: Bearer {token}`

**响应**:
```json
{
  "success": true,
  "data": {
    "total_count": 15,
    "completed_count": 5,
    "remaining_count": 10,
    "estimated_time_minutes": 8,
    "items": [
      {
        "vocabulary_id": "uuid",
        "word": "algorithm",
        "translation": "算法",
        "context": "A step-by-step procedure",
        "difficulty": 3,
        "review_type": "recognition", // recognition, recall, spelling
        "scheduled_time": "2024-01-01T09:00:00Z",
        "interval_days": 7
      }
    ]
  }
}
```

### 4.2 提交复习结果

**POST** `/review/submit`

**Headers**: `Authorization: Bearer {token}`

**请求参数**:
```json
{
  "vocabulary_id": "uuid",
  "quality": 4, // 0-5, 0=完全忘记, 5=完美记住
  "response_time_ms": 3000,
  "user_answer": "算法",
  "review_type": "recognition"
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "is_correct": true,
    "next_review_date": "2024-01-08T00:00:00Z",
    "interval_days": 14,
    "mastery_level": 3,
    "streak_count": 5,
    "feedback": "回答正确！掌握程度有所提升。"
  }
}
```

### 4.3 获取复习统计

**GET** `/review/stats`

**Headers**: `Authorization: Bearer {token}`

**查询参数**:
- `period`: 统计周期 (day, week, month, year)
- `start_date`: 开始日期 (可选)
- `end_date`: 结束日期 (可选)

**响应**:
```json
{
  "success": true,
  "data": {
    "period": "week",
    "total_reviews": 50,
    "correct_reviews": 42,
    "accuracy_rate": 0.84,
    "average_response_time_ms": 2500,
    "streak_days": 7,
    "daily_stats": [
      {
        "date": "2024-01-01",
        "reviews_count": 10,
        "correct_count": 8,
        "study_time_minutes": 15
      }
    ],
    "difficulty_breakdown": {
      "1": {"total": 10, "correct": 9},
      "2": {"total": 15, "correct": 12},
      "3": {"total": 20, "correct": 16},
      "4": {"total": 5, "correct": 3}
    }
  }
}
```

## 5. 学习分析接口

### 5.1 获取学习报告

**GET** `/analytics/report`

**Headers**: `Authorization: Bearer {token}`

**查询参数**:
- `period`: 报告周期 (week, month, quarter)

**响应**:
```json
{
  "success": true,
  "data": {
    "period": "month",
    "summary": {
      "words_learned": 120,
      "words_reviewed": 450,
      "study_days": 25,
      "total_study_time_minutes": 600,
      "average_daily_time_minutes": 24
    },
    "progress": {
      "mastery_distribution": {
        "0": 20, "1": 30, "2": 35, "3": 25, "4": 8, "5": 2
      },
      "difficulty_progress": {
        "1": {"mastered": 15, "total": 20},
        "2": {"mastered": 25, "total": 40},
        "3": {"mastered": 20, "total": 45},
        "4": {"mastered": 5, "total": 15}
      }
    },
    "weak_areas": [
      {
        "category": "技术术语",
        "accuracy_rate": 0.65,
        "suggestion": "建议增加技术术语的练习频率"
      }
    ],
    "achievements": [
      {
        "type": "streak",
        "title": "连续学习7天",
        "earned_at": "2024-01-07T00:00:00Z"
      }
    ]
  }
}
```

### 5.2 获取个性化建议

**GET** `/analytics/suggestions`

**Headers**: `Authorization: Bearer {token}`

**响应**:
```json
{
  "success": true,
  "data": {
    "learning_suggestions": [
      {
        "type": "focus_area",
        "title": "加强商务英语学习",
        "description": "您在商务英语方面的掌握率较低，建议重点学习",
        "priority": "high",
        "estimated_improvement": "20%"
      }
    ],
    "study_plan": {
      "recommended_daily_minutes": 20,
      "recommended_new_words": 5,
      "recommended_reviews": 15,
      "focus_areas": ["商务英语", "技术术语"]
    },
    "next_milestone": {
      "target": "掌握100个新单词",
      "current_progress": 75,
      "estimated_days": 10
    }
  }
}
```

## 6. 翻译历史接口

### 6.1 获取翻译历史

**GET** `/history/translations`

**Headers**: `Authorization: Bearer {token}`

**查询参数**:
- `page`: 页码
- `limit`: 每页数量
- `search`: 搜索关键词
- `date_from`: 开始日期
- `date_to`: 结束日期

**响应**:
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "uuid",
        "original_text": "Hello world",
        "translated_text": "你好世界",
        "source_url": "https://example.com",
        "context": "编程术语",
        "created_at": "2024-01-01T00:00:00Z",
        "is_saved_to_vocabulary": true
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_items": 100
    }
  }
}
```

### 6.2 删除翻译历史

**DELETE** `/history/translations/{history_id}`

**Headers**: `Authorization: Bearer {token}`

## 7. 用户设置接口

### 7.1 获取用户设置

**GET** `/settings`

**Headers**: `Authorization: Bearer {token}`

**响应**:
```json
{
  "success": true,
  "data": {
    "language_preferences": {
      "default_source_lang": "en",
      "default_target_lang": "zh",
      "auto_detect_language": true
    },
    "review_settings": {
      "daily_review_goal": 20,
      "review_reminder_time": "09:00",
      "weekend_reviews": true,
      "difficulty_adjustment": "auto"
    },
    "notification_settings": {
      "email_notifications": true,
      "push_notifications": true,
      "review_reminders": true,
      "weekly_reports": true
    },
    "privacy_settings": {
      "data_sharing": false,
      "analytics_tracking": true
    }
  }
}
```

### 7.2 更新用户设置

**PUT** `/settings`

**Headers**: `Authorization: Bearer {token}`

**请求参数**:
```json
{
  "review_settings": {
    "daily_review_goal": 25,
    "review_reminder_time": "08:30"
  },
  "notification_settings": {
    "email_notifications": false
  }
}
```

## 8. 订阅管理接口

### 8.1 获取订阅信息

**GET** `/subscription`

**Headers**: `Authorization: Bearer {token}`

**响应**:
```json
{
  "success": true,
  "data": {
    "subscription_type": "premium",
    "status": "active",
    "expires_at": "2024-12-31T23:59:59Z",
    "features": [
      "unlimited_translations",
      "ai_enhanced_translation",
      "advanced_analytics",
      "priority_support"
    ],
    "usage_stats": {
      "translations_this_month": 1250,
      "translations_limit": -1, // -1 表示无限制
      "vocabulary_count": 500,
      "vocabulary_limit": -1
    }
  }
}
```

### 8.2 升级订阅

**POST** `/subscription/upgrade`

**Headers**: `Authorization: Bearer {token}`

**请求参数**:
```json
{
  "plan": "premium",
  "billing_cycle": "monthly", // monthly, yearly
  "payment_method": "stripe_token_or_alipay"
}
```

## 错误代码说明

| 错误代码 | HTTP状态码 | 描述 |
|---------|-----------|------|
| AUTH_001 | 401 | 未提供认证token |
| AUTH_002 | 401 | token已过期 |
| AUTH_003 | 401 | token无效 |
| AUTH_004 | 403 | 权限不足 |
| USER_001 | 400 | 用户已存在 |
| USER_002 | 404 | 用户不存在 |
| TRANS_001 | 400 | 翻译文本为空 |
| TRANS_002 | 429 | 翻译请求过于频繁 |
| TRANS_003 | 503 | 翻译服务暂不可用 |
| VOCAB_001 | 400 | 词汇已存在 |
| VOCAB_002 | 404 | 词汇不存在 |
| REVIEW_001 | 400 | 复习质量评分无效 |
| SUB_001 | 402 | 订阅已过期 |
| SUB_002 | 429 | 超出使用限额 |
| SYSTEM_001 | 500 | 内部服务器错误 |

## 限流规则

### 免费用户
- 翻译接口: 100次/小时
- 词汇保存: 50次/小时
- 其他接口: 200次/小时

### 付费用户
- 翻译接口: 1000次/小时
- 词汇保存: 500次/小时
- 其他接口: 2000次/小时

## WebSocket接口

### 实时学习状态

**连接**: `wss://api.englishassistant.com/ws/learning`

**认证**: 连接时发送token

**消息格式**:
```json
{
  "type": "review_completed",
  "data": {
    "vocabulary_id": "uuid",
    "is_correct": true,
    "streak_count": 5
  }
}
```

---

**文档版本**: v1.0
**最后更新**: 2024年
**维护团队**: API开发组