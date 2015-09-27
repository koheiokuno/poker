# poker
# ポーカー判定プログラム

課題のポーカー役判定プログラムです。
Railsとありましたが、今回はsinatraで作成いたしました。現在利用しているRailsの環境が若干特殊だったため、シンプルなsinatraで作成させて頂きました。


### テストページ 

課題１用入力ページ：
http://54.92.82.73/

課題２用APIエンドポイント：
http://54.92.82.73/judgeapi

curlでのテスト結果：
#curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{"cards":["D2 S2 D2 S9 S9","H2 S2 D2 S9 S10","D8 S5 D4 S10 S1"]}' http://54.92.82.73/judgeapi



