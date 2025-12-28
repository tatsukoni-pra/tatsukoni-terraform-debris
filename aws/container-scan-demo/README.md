# Container Scan Demo

## 概要

このプロジェクトは、AWS Inspector2のコンテナスキャン結果に対する脆弱性サプレッション（抑制）を自動化するためのインフラストラクチャです。S3バケットにサプレッション情報を含むJSONファイルをアップロードすると、EventBridgeとStep Functionsを通じて自動的にInspector2の抑制ルールが作成されます。

## アーキテクチャ

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  1. S3バケットにJSONファイルアップロード                          │
│     (tatsukoni-pra-container-scan-demo)                         │
│     ファイルパターン: */suppression_detail.json                  │
│                                                                 │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     │ S3 EventBridge通知
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  2. EventBridge Rule                                            │
│     (EventRule-ContainerScanDemo)                               │
│     - イベントパターン: Object Created                           │
│     - フィルター: suffix = "/suppression_detail.json"            │
│                                                                 │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     │ ターゲット起動
                     │ (IAM Role: Amazon_EventBridge_Invoke_StepFunctions)
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  3. Step Functions State Machine                                │
│     (SfnContainerScanDemo)                                      │
│                                                                 │
│     ┌─────────────────────────────────────────┐                │
│     │ State 1: GetObject                      │                │
│     │ - S3からJSONファイルを取得               │                │
│     │ - JSONをパース                          │                │
│     └──────────┬──────────────────────────────┘                │
│                │                                                │
│                ▼                                                │
│     ┌─────────────────────────────────────────┐                │
│     │ State 2: CreateFilter                   │                │
│     │ - Inspector2の抑制ルールを作成          │                │
│     │ - Action: SUPPRESS                      │                │
│     │ - 抑制ルール条件:                       │                │
│     │   * ECRイメージリポジトリ名              │                │
│     │   * CVE ID                              │                │
│     └─────────────────────────────────────────┘                │
│                                                                 │
│  IAM Role: SfnContainerScanDemo                                 │
│  - S3:GetObject 権限                                            │
│  - Inspector2:CreateFilter 権限                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 構成リソース

### S3
| リソース | 名前 | 説明 |
|---------|------|------|
| S3 Bucket | `tatsukoni-pra-container-scan-demo` | サプレッション情報を格納するバケット |
| Bucket Notification | EventBridge通知 | バケット内の全イベントをEventBridgeに送信 |
| Encryption | AES256 | サーバーサイド暗号化（bucket_key有効） |
| Public Access Block | 有効 | パブリックアクセスを全てブロック |

### EventBridge
| リソース | 名前 | 説明 |
|---------|------|------|
| Event Rule | `EventRule-ContainerScanDemo` | S3のObject Createdイベントを検知 |
| Event Target | StepFunctions | ターゲット: SfnContainerScanDemo |

### Step Functions
| リソース | 名前 | 説明 |
|---------|------|------|
| State Machine | `SfnContainerScanDemo` | サプレッション処理のワークフロー |
| Query Language | JSONata | ステートマシンの変数処理に使用 |

### IAM

#### EventBridge用
| リソース | 名前 | 説明 |
|---------|------|------|
| IAM Role | `Amazon_EventBridge_Invoke_StepFunctions_1822831248` | EventBridgeがStepFunctionsを起動するためのロール |
| IAM Policy | 同上 | `states:StartExecution` 権限を付与 |

#### StepFunctions用
| リソース | 名前 | 説明 |
|---------|------|------|
| IAM Role | `SfnContainerScanDemo` | StepFunctionsの実行ロール |
| Inline Policy | `SfnContainerScanDemoPolicy` | S3とInspector2の権限を付与 |

## 処理フロー

1. **JSONファイルのアップロード**
   - S3バケット `tatsukoni-pra-container-scan-demo` に、サプレッション情報を含むJSONファイルをアップロードします
   - ファイル名は `/suppression_detail.json` で終わる必要があります

2. **イベント検知**
   - S3のEventBridge通知が有効化されているため、オブジェクト作成イベントがEventBridgeに送信されます
   - EventBridge Rule `EventRule-ContainerScanDemo` がイベントをキャッチします

3. **StepFunctions起動**
   - EventBridgeがStepFunctions `SfnContainerScanDemo` を起動します
   - IAM Role `Amazon_EventBridge_Invoke_StepFunctions_1822831248` を使用

4. **S3オブジェクト取得**
   - StepFunctionsの最初のステート `GetObject` が実行されます
   - S3からJSONファイルを取得し、パースします

5. **Inspector2抑制ルール作成**
   - 2つ目のステート `CreateFilter` が実行されます
   - 取得したJSON情報を基に、Inspector2の抑制ルールを作成します

## JSONファイルフォーマット

サプレッション情報のJSONファイルは以下のフォーマットである必要があります：

```json
{
  "image_name": "my-ecr-repository",
  "cve": "CVE-2024-12345",
  "team": "セキュリティチーム",
  "created_at": "2025-12-29",
  "reason": "誤検知のため",
  "lift_condition": "次回の脆弱性スキャン時に再評価"
}
```

### フィールド説明
- `image_name`: ECRイメージリポジトリ名
- `cve`: 抑制するCVE ID
- `team`: 担当チーム名
- `created_at`: 抑制実施日
- `reason`: 抑制理由
- `lift_condition`: 抑制解除タイミング

## ファイル構成

```
aws/container-scan-demo/
├── README.md                  # このファイル
├── main.tf                    # プロバイダー設定など
├── s3.tf                      # S3関連リソース
├── eventbridge_rule.tf        # EventBridge Rule/Target
├── stepfunctions.tf           # StepFunctions State Machine
├── iam.tf                     # IAMロール/ポリシー
└── import.tf                  # 既存リソースのインポート定義
```

## 使用方法

### 初期セットアップ

```bash
cd aws/container-scan-demo
terraform init
terraform plan
terraform apply
```

### サプレッションの追加

https://github.com/tatsukoni-pra/container-scan-demo/actions/workflows/create_suppress_rule.yml を実行する。

その後、StepFunctionsが自動的に実行され、Inspector2の抑制ルールが作成されます

### 実行状況の確認

```bash
# StepFunctionsの実行履歴を確認
aws stepfunctions list-executions \
  --state-machine-arn arn:aws:states:ap-northeast-1:083636136646:stateMachine:SfnContainerScanDemo

# Inspector2の抑制ルールを確認
aws inspector2 list-filters
```

## 注意事項

- S3バケットにアップロードするファイル名は `/suppression_detail.json` で終わる必要があります
- JSONファイルのフォーマットが正しくない場合、StepFunctionsの実行が失敗します
- 同じイメージ名とCVEの組み合わせで複数回実行すると、抑制ルールの作成が失敗する可能性があります

## リージョン

- ap-northeast-1 (東京)
