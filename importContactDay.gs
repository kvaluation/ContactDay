function importContactDay() {
  // ContactDay.txtのfolder
  // https://drive.google.com/drive/folders/1mHlqfvVhV4zlkksRGwSDsh_tMMVsjxsw?usp=sharing

  const toAdress = "kenji.suzuki@kval.jp"; //送り先アドレス
  const subject = "ContactDay";//メールの題目
  const name = "Google Apps Script by kval";//送り主の名前
  const today = new Date();

  const folderID = '1mHlqfvVhV4zlkksRGwSDsh_tMMVsjxsw' //ContactDay.txtのfolderID
  const targetFolder = DriveApp.getFolderById(folderID); //ContactDay.txtが保存されるフォルダ
  const ContactDayFiles = targetFolder.searchFiles('title contains "cDay" and title contains "\.csv"');

  let lastCreatedDate = new Date('2020/1/1 0:0:0');
  let createdDateArray = []; //ログ用。


  if (!ContactDayFiles.hasNext()) {
    console.log('file not found')

    const body =
      "ContactDayログ\n" +
      "file not found" + "\n";

    MailApp.sendEmail({to:toAdress, subject:subject, name:name, body:body});

    return;
  }

//■■■　ダウンロードされた複数のcDayファイルから更新日が最終のcDayファイルを選定　■■■
  while (ContactDayFiles.hasNext()) {

    const cDayFile = ContactDayFiles.next();
    const fileName = cDayFile.getName();
    const createdDate = cDayFile.getDateCreated();
    const createdDateFileId = cDayFile.getId();

      if (createdDate.getTime() - lastCreatedDate.getTime() > 0) {
         console.log('上書き')
         targetFileId = cDayFile.getId();
         targetFileName = cDayFile.getName();
         lastCreatedDate = createdDate;

      }else{
         console.log('上書きせず');
        }

        createdDateArray.push(createdDate,createdDateFileId);
        console.log('FileName: ', fileName, 'Date: ', createdDate, 'Id: ', createdDateFileId);
        console.log('lastDate:', lastCreatedDate);
        console.log('lastId:', targetFileId);

  }

//■■■　選定したファイルをスプレッドシートに上書き　■■■
  // 読み書きの対象のSpreadSheetを定義
  // https://docs.google.com/spreadsheets/d/1jxO4vJMlv20JhOCqOOhCWod4hEUzNJxrYtHaA6t9DvI/edit?usp=sharing

  const ssID = '1jxO4vJMlv20JhOCqOOhCWod4hEUzNJxrYtHaA6t9DvI'
  const ssName = 'ContactDaySheet';

  const ss = SpreadsheetApp.openById(ssID);
  const sh = ss.getSheetByName(ssName);
  const lastRow = sh.getLastRow();
  let lastValues = [];

　// 最新の最終行を配列に読み込む
  lastValues = sh.getRange(lastRow, 1, 1, 4).getValues();
  console.log("lastValues:",lastValues);
  const lastZIPNUM = lastValues[0][1];
  console.log("last Zip Number", lastZIPNUM);

  // 対象のCSVファイル（cDayYYYYMMDD）
  const file = DriveApp.getFileById(targetFileId);
  const data = file.getBlob().getDataAsString(); 
  const csv = Utilities.parseCsv(data,',');
  const csvlength = csv.length;
  console.log(csvlength);

// 読み出したCSVからzip番号が新しい行を取り出してtodayCsvにいれる
  const todayCsv = [];
  let i = 0;
  let j = 0;
  while (i < csvlength) {

    if (csv[i][1] > lastZIPNUM) {
      todayCsv[j] = csv[i];
      console.log("i:", i, "j:",j, "todayCsv[i][1]",todayCsv[j])
      j++;    
    }

    i++;
  }

// todayCsvを対象スプレッドシートの最終行以下に追記
  if (todayCsv.length == "") {
    console.log('new TEK not found')

    const body =
      "ContactDayログ\n" +
      "new TEK not found" + "\n";

    MailApp.sendEmail({to:toAdress, subject:subject, name:name, body:body});


    return;
  }

  sh.getRange(lastRow+1,1,todayCsv.length,todayCsv[0].length).setValues(todayCsv);

// 追記した行にセルの書式のみコピー

const range = sh.getRange(lastRow, 1, 1, todayCsv[0].length);
range.copyFormatToRange(sh, 1, todayCsv[0].length, lastRow+1, lastRow+todayCsv.length);
// https://arukayies.com/gas/copyformattorange


// 処理内容をlogシートに書き込み
  const shLog = ss.getSheetByName('log');
  const lastRowLog = shLog.getLastRow();
  console.log("lastRowLog:", lastRowLog);
  let logData = [lastCreatedDate, targetFileId, targetFileName, j, lastZIPNUM, todayCsv[0][1], todayCsv[j-1][1]];
  console.log(logData);
  console.log('logData.length:',logData.length);

  // 元データを削除せず上書き
  shLog.getRange(lastRowLog+1, 1, 1, logData.length).setValues([logData]);

  // メール送信
    const body =
    "ContactDayログ\n" +
    logData + "\n" +
    "https://docs.google.com/spreadsheets/d/1jxO4vJMlv20JhOCqOOhCWod4hEUzNJxrYtHaA6t9DvI/edit?usp=sharing";

    MailApp.sendEmail({to:toAdress, subject:subject, name:name, body:body});

//　https://qiita.com/YusukeKameyama/items/5ae840ec8d4382a215db

}
