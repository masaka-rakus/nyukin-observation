# ログ可視化システム（Grafana, Loki, Promtail）

このリポジトリには、Grafana、Loki、Promtailを使用したログ可視化システムが含まれています。このシステムを使用して、ログファイルを集約し、視覚的に分析することができます。

## システム構成

- **Grafana**: ログデータを視覚化するためのダッシュボードを提供（ポート3000）
- **Loki**: ログ集約システム（ポート3100）
- **Promtail**: ログファイルを収集してLokiに転送するエージェント

## セットアップと実行方法

以下のコマンドでシステムを起動します：

```bash
cd /Users/masahiro.kawakami/repositories/tools/observer
docker-compose up -d
```

### 前提条件

- Docker と Docker Compose がインストールされていること

## Grafanaへのアクセス方法

1. ブラウザで http://localhost:3000 にアクセス
2. デフォルトの認証情報でログイン：
   - ユーザー名: `admin`
   - パスワード: `admin`
3. 初回ログイン時にパスワード変更を促されることがあります（スキップ可能）

## ログの閲覧方法

1. 左側のサイドバーから「Explore」をクリック
2. データソースとして「Loki」が選択されていることを確認
3. クエリフィールドに以下のLogQLクエリを入力：
   ```
   {job="access_logs"}
   ```
4. 「Run Query」をクリックするか、Shift+Enterを押す

## 高度なログクエリ

LogQL（Lokiのクエリ言語）を使用して、より高度なフィルタリングが可能です：

- 特定のテキストを含むログをフィルタリング：
  ```
  {job="access_logs"} |= "ERROR"
  ```

- 正規表現でログをフィルタリング：
  ```
  {job="access_logs"} |~ "GET /api/.*"
  ```

- フィールドを抽出してメトリクスを作成：
  ```
  {job="access_logs"} | pattern `<logfile>:<ip> - - [<date>:<timestamp> <offset>] <responsetime> "<method> <path> HTTP/1.1" <status> <size> "<referrer> "<agent>"`
  ```

## ディレクトリ構造

```
observer/
├── docker-compose.yml      # Dockerコンテナの設定
├── loki/                   # Loki設定ディレクトリ
│   └── local-config.yaml   # Lokiの設定ファイル
├── promtail-config.yml     # Promtailの設定ファイル
├── grafana/                # Grafana設定ディレクトリ
│   └── provisioning/       # Grafana自動設定
│       ├── dashboards/     # ダッシュボード設定
│       └── datasources/    # データソース設定
└── sample_log/             # サンプルログディレクトリ
    └── 2025_access_log_all # サンプルログファイル
```

## カスタマイズ

- さらにログファイルを追加する場合は、`promtail-config.yml`の`__path__`フィールドを更新し、スタックを再起動してください。
- リアルタイムログモニタリングのために、Grafanaの「Explore」ビューの自動更新機能を有効にすることができます。

## トラブルシューティング

- コンテナが起動しない場合は、`docker-compose logs`コマンドでログを確認してください。
- Lokiにデータが表示されない場合は、Promtailのログを確認してログ収集が正しく行われているか確認してください。
- 権限の問題がある場合は、マウントされたボリュームの権限を確認してください。

## 停止方法

システムを停止するには以下のコマンドを実行します：

```bash
cd /Users/masahiro.kawakami/repositories/tools/observer
docker-compose down
```

データを完全に削除する場合は、作成されたボリュームも削除してください：

```bash
docker-compose down -v
```


## Grafanaをサブパス付きで公開する

ポートではなく、Apacheなどで`example.com/grafana/`などで公開し、localhost:3000にproxyする

この場合、grafanaがリダイレクトをはじめリンクURLを生成する関係で、grafana側の設定もいじる必要がある

例：
```
https://example.com/grafana/ にアクセス
↓
grafanaがログイン画面へのリダイレクトURL生成
↓
http://127.0.0.1:3000/login へのリダイレクトが返ってきてしまう
```

そのため、grafana側でも`https://example.com/grafana/login`のURLを生成するように設定する必要がある

- apacheのconf
```
SSLProxyEngine on

ProxyPreserveHost On
ProxyRequests     Off

<Proxy "http://127.0.0.1:3000/">
  Require all granted
</Proxy>

# サブパス /grafana/ → Grafana (localhost:3000)
ProxyPass        /grafana/ http://127.0.0.1:3000/grafana/ retry=0
ProxyPassReverse /grafana/ http://127.0.0.1:3000/grafana/
```

- grafanaのiniファイル(/etc/grafana.ini)
```
[server]
root_url = https://example.com/grafana
serve_from_sub_path = true
```