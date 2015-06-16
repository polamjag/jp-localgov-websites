# jp-localgov-websites

## これは何

[地方公共団体情報システム機構 全国自治体マップ検索](https://www.j-lis.go.jp/map-search/cms_1069.html) から、日本全国の地方自治体のウェブサイトの一覧を作成するための Ruby スクリプトです。

件のウェブページは、残念ながらデータの再利用性が高いとはいいがたいため、JSON のようなプログラマブルな形式で一覧をまとめることを目標とします。

## 使用法

以下のようなコマンドを実行することで `list.json` に一覧の JSON が出力されます。

```
$ bundle install --path vendor/bundle
$ bundle exec ruby fetch.rb list.json
```

## ライセンス

MIT License とします。

レポジトリに含まれている `out.json` は、[地方公共団体情報システム機構](https://www.j-lis.go.jp/index.html) の Web サイトから開発者が取得したデータにより構成されています。
