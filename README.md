##  ContactDay 接触日シート別冊をつくるためのコード群
[接触日シート別冊](https://datastudio.google.com/reporting/069598a2-3f01-4b51-b023-cdb478992182)は、日本の接触確認アプリCOCOAで陽性登録された際に通知サーバーに登録されるデータを整理し、推定の接触日とzipファイル単位のHASH値を付加し、統計情報として、また、広範な接触の非公式な接触日をHASH値からCOCOAユーザーご自身で求めていただくためのWebサイトです。

この接触日シートで提示しているデータを、どのように取得し、計算しているかをお示しするために、プログラム自体を公開することとしました。

プログラムの実行環境はMacです。

##  使用許諾
ご自身の責任で、対価無しに改変してご利用頂けますが、広告収入を含め有償サービスの実現のためにご利用頂く際には、事前にご相談ください。

## プログラム

### zipDownload.sh
list.jsonとzipファイルをダウンロードします。
rocazさん https://twitter.com/rocaz のprobeCOCOATekを実行しているだけです。
https://github.com/rocaz/probeCOCOATek
rocazさんに感謝申し上げます。ご利用方法はprobeCOCOATekのご案内をご参照ください。

### contactDay.sh
list.jsonのzipについて、zipファイルから接触日とHASHを算出し、表（contactDay.csv）にしています。
シェルスクリプトは読みづらいですね。

### importContactDay.gs
contactDay.csvをスプレッドシートに読み出します。


実行結果のスプレッドシートです。  
  
<img width="1005" alt="ContactDaySheet" src="https://user-images.githubusercontent.com/60703087/119214578-e0285380-bb02-11eb-9839-0ee886cb198e.png">

[接触日シート別冊](https://datastudio.google.com/reporting/069598a2-3f01-4b51-b023-cdb478992182)は、このスプレッドシートをリソースにしています。

## HASH値について
zipに含まれている export.bin のHASHです。Macのターミナル等のシェルで、shasumコマンドで求まります。
zip番号が4000であれば、zipfilesに格納されているとして、次で求まります。

```
unzip -o -p zipfiles/4000.zip "export.bin" | shasum -a 256
```
このHASH値は、iOSの「チェックの詳細」画面などに表示されるHASH値で、zipファイルと一対一に対応しています。ですので、HASH値がわかると、zip番号を特定できます。
AndroidのHASHとは異なります。

## 接触日の推定について
zipファイルには複数のTEKが格納されており、zipファイル１ファイルに含まれている複数のTEKのそれぞれのrolling_start_interval_numberは同じ値です。  
rolling_start_interval_numberは、接触確認が機能しているスマホ間でBLTで送受信されるキー（接触符号, RPI）の開始日時です。有効期間は24時間です。  
開始日時なので、スマホがすれ違った日（接触日）です。  
仕様上UTCなので仕様通りなのであれば日本時間に変換すべきですが、日本時間で出力されているように解しており、接触日シート別冊では日本時間への変換をしていません。  
そのように解しているのは、2020年８月から9月に不特定の方、100名ほどからの聴き取り結果によりますが、その後のAPIやCOCOAのバージョンアップの影響は検証しきれておりません。  
  
（cocoa_logの daysSinceLastExposure は、"output_date"を日本時間と考えて９時間戻してUTCにし、daysSinceLastExposureの値を日として減算した日時の日を（最後の）接触日とするのが現状では整合的と考えております）。  
  
HASH値からzip番号を特定い、zipに含まれるTEKのrolling_start_interval_numberは同じ値なので、HASH値から接触日を推定できています。

## ファイルの共有
上記の処理で得られているファイルも公開します。次のフォルダーからダウンロードできます。

広範な接触（キーの一致）で公費PCRを実施いただいている保健所様、病院様・クリニック様には、ご要望に応じた使いやすいデータとしてご提供できますので、ご相談ください。（スプレッドシートの共有や、Excelファイルの自動的なメール添付送信など）。　感染拡大の抑止へのご協力、ありがとうございます。

[zip files](https://drive.google.com/drive/folders/1SgJ2JU79rZ4MyMrV9CoETEzebUxeCvWd?usp=sharing)

[list.txt](https://drive.google.com/drive/folders/1-6Ly6mU3JyCgppU7MJV6PFaT044a9okW?usp=sharing)

[contactDay.csv](https://drive.google.com/drive/folders/1mHlqfvVhV4zlkksRGwSDsh_tMMVsjxsw?usp=sharing)
