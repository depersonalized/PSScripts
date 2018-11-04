#under development test
#EventIDを2に書き換える。テストマシンでは過去24時間に発生していないので、2を指定してもエラーになるので。
$shutdowntime = get-winevent -LogName system -errorAction:silentlycontinue -FilterXPath "*[System[(EventID=7036) and TimeCreated[timediff(@SystemTime) <= 86400000]]]"
$lastshutdowntime = $shutdowntime.Get(0) | Select-Object Timecreated

#$lastshutdowntimeをUTCに変換して＞＝だけのイベントを抽出する。
$utc = (($lastshutdowntime.TimeCreated).ToUniversalTime()).tostring("yyyy-MM-ddTHH:mm:ss.fffZ")
#後でコメントアウトを戻す↓
#$errorsafterreboot =  get-winevent -LogName system -errorAction:silentlycontinue -FilterXPath "*[System[(Level=1 or Level=2 or Level=3) and TimeCreated[@SystemTime >= '$utc']]]"
$errorsafterreboot = get-winevent -LogName system -errorAction:silentlycontinue -FilterXPath "*[System[(Level=1 or Level=2 or Level=3) and TimeCreated[@SystemTime >= '2018-08-14T01:45:04.000Z']]]"

#リブート前のイベントログを180日分だけ抽出
$180days = (((Get-Date).AddDays(-180)).ToUniversalTime()).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
$errorsbeforereboot = get-winevent -LogName system -errorAction:silentlycontinue -FilterXPath "*[System[(Level=1 or Level=2 or Level=3) and TimeCreated[@SystemTime >= '$180days' and @SystemTime <= '$utc']]]"

for ($i = 0; $i -lt $errorsafterreboot.Count; $i++) {

    for ($j = 0; $j -lt $errorsbeforereboot.Count; $j++) {

        $ierror = ($errorsafterreboot.GetValue($i)).id
        $jerror = ($errorsbeforereboot.GetValue($j)).id

        if ($ierror -eq $jerror) {

            $imessage = ($errorsafterreboot.GetValue($i)).message
            $jmessage = ($errorsbeforereboot.GetValue($j)).message

            if ($imessage -eq $jmessage) {

                Write-Output "Error Check" + '$ierror:'$ierror + '$imessage:'$imessage | Out-File .\test.txt -Append
                break
                
            }

        }

    }

}
