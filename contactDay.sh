#!/bin/sh

#MacOSのターミナルで実行するため、gdateとgsedを使用
#gsed 行単位ではなく、ファイル全体での置き換え
#gdate 日単位の日付の足し算
#home

LISTTEXT=`date "+%Y%m%d"`
DATA=`cat /Users/home/Dropbox/EN/List/list${LISTTEXT}.txt`


echo "TimeStamp, ZIPNumber, KeyCount, ContactDay, HASH" \
     >  /Users/home/Dropbox/EN/ContactDay/cDay`date "+%Y%m%d"`.csv #タイトル記入（上書き）

declare -a ZIPNUM=()
declare -a TIMESTAMP=()
declare -a KEYCOUNT=()
declare -a HASH=()
declare -a TEKs=()
declare -a CONTACTDAYe=()
declare -a CONTACTDAYd=()
declare -a _days=()

index=0


while read line
do

    _ZIPNUM4CHECK=`echo $line | sed -e 's/.*c19r\/440\/\(.*\)\.zip.*/\1/'`


    if [ "`echo $_ZIPNUM4CHECK | grep KeyCount`" ];then

    	echo "throughTop $_index : $_ZIPNUM4CHECK]"

    elif [ "`echo $_ZIPNUM4CHECK | grep Count`" ];then

    	echo "throughBottom $_index : $_ZIPNUM4CHECK]"
	
    else

         ZIPNUM[$index]=`echo $line | sed -e 's/.*c19r\/440\/\(.*\)\.zip.*/\1/'`
    TIMESTAMP[${index}]=`echo $line | sed -e 's/.*\[\(.*\)\].*\[\(.*\)\].*\[\(.*\)\]/\1/'`
     KEYCOUNT[${index}]=`echo $line | sed -e 's/.*\[\(.*\)\].*\[\(.*\)\].*\[\(.*\)\]/\3/'`
         HASH[${index}]=`unzip -o -p /Users/home/Dropbox/EN/Zipfiles/${ZIPNUM[${index}]}.zip "export.bin" \
	                   | shasum -a 256`
	 HASH[${index}]=`echo ${HASH[${index}]} | sed -e 's/.\{2\}$//'` #最後の2文字（" -"）を削除
	 HASH[${index}]=`echo ${HASH[${index}]} | tr '[a-z]' '[A-Z]'`

	 TIMESTAMP[${index}]=`echo ${TIMESTAMP[${index}]} | sed -e 's/.\{5\}$//'` #最後の5文字("+0900")を削除。表示は日本時間

	 
         TEKs[${index}]=`/Users/home/Library/Python/3.8/bin/probeCOCOATek zip \
                         /Users/home/Dropbox/EN/Zipfiles/${ZIPNUM[${index}]}.zip`

         CONTACTDAYe[${index}]=`echo ${TEKs[${index}]} | /usr/local/bin/gsed -z 's/.*rolling_start_interval_number \]\:\[\(.\{7\}\).*/\1/'`
	 _days[${index}]=`expr ${CONTACTDAYe[${index}]} \* 60 \/ 8640`
	 CONTACTDAYd[${index}]=`/usr/local/bin/gdate --date "19700101 ${_days[${index}]} days" +%Y-%m-%d`
	 
	 echo ${TIMESTAMP[$index]},${ZIPNUM[${index}]},${KEYCOUNT[${index}]},${CONTACTDAYd[${index}]},${HASH[${index}]} \
	      >> /Users/home/Dropbox/EN/ContactDay/cDay`date "+%Y%m%d"`.csv

         echo ${TEKs[${index}]} > /Users/home/Dropbox/EN/TEKfiles/${ZIPNUM}.txt
	# echo ${TEKs[${index}]} > /Volumes/GoogleDrive/共有ドライブ/KvalPublic/ENonGoogleDrive/TEKfiles/${ZIPNUM}.txt
	 
       echo "processing $index zipNumber: ${ZIPNUM[${index}]}"
       echo "processing $index timestamp: ${TIMESTAMP[${index}]}"
       echo "processing $index keyCount: ${KEYCOUNT[${index}]}"
       echo "processing $index hash: ${HASH[${index}]}"
       echo "processing $index contactDayEpoch: ${CONTACTDAYe[${index}]}"       
       echo "processing $index contactDayJST: ${CONTACTDAYd[${index}]}"

    fi
    
    index=`expr $index + 1`
    
done <<END
$DATA
END


# Copy cDayYYYYMMDD.csv to Google Drive
cp /Users/home/Dropbox/EN/ContactDay/cDay`date "+%Y%m%d"`.csv \
   /Volumes/GoogleDrive/共有ドライブ/home/ENonGoogleDrive/ContactDay

echo ${ZIPNUM[@]}

# zip番号: _ZIPNUM、タイムスタンプ_TIMESTAMP、提供されたキーの数_KEYCOUNT、接触日_CONTACTDAY、ハッシュ値_HASH
# (CONTACTDAY*60*10^4)/86400000+date(1970,1,1)

