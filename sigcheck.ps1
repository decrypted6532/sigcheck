Clear-Host

Write-Host @"
 ▄████▄  ▓█████  ██▀███   ▒█████   ██▒   █▓ ██▓ ███▄    █  ▄▄▄      
▒██▀ ▀█  ▓█   ▀ ▓██ ▒ ██▒▒██▒  ██▒▓██░   █▒▓██▒ ██ ▀█   █ ▒████▄    
▒▓█    ▄ ▒███   ▓██ ░▄█ ▒▒██░  ██▒ ▓██  █▒░▒██▒▓██  ▀█ ██▒▒██  ▀█▄  
▒▓▓▄ ▄██▒▒▓█  ▄ ▒██▀▀█▄  ▒██   ██░  ▒██ █░░░██░▓██▒  ▐▌██▒░██▄▄▄▄██ 
▒ ▓███▀ ░░▒████▒░██▓ ▒██▒░ ████▓▒░   ▒▀█░  ░██░▒██░   ▓██░ ▓█   ▓██▒
░ ░▒ ▒  ░░░ ▒░ ░░ ▒▓ ░▒▓░░ ▒░▒░▒░    ░ ▐░  ░▓  ░ ▒░   ▒ ▒  ▒▒   ▓▒█░
  ░  ▒    ░ ░  ░  ░▒ ░ ▒░  ░ ▒ ▒░    ░ ░░   ▒ ░░ ░░   ░ ▒░  ▒   ▒▒ ░
░           ░     ░░   ░ ░ ░ ░ ▒       ░░   ▒ ░   ░   ░ ░   ░   ▒   
░ ░         ░  ░   ░         ░ ░        ░   ░           ░       ░  ░
░                                      ░                            
                                                                       

...........*UHWHН!hhhhН!?M88WHXХWWWWSW$o
.......X*#M@$Н!eeeeНXНM$$$$$$WWxХWWW9S0
…...ХН!Н!Н!?HН..ХН$Н$$$$$$$$$$8XХDDFDFW9W$
....Н!f$$$$gХhН!jkgfХ~Н$Н#$$$$$$$$$$8XХKKW9W$,
....ХНgХ:НHНHHHfg~iU$XН?R$$$$$$$$MMНGG$9$R$$
....~НgН!Н!df$$$$$JXW$$$UН!?$$$$$$RMMНLFG$9$$$
......НХdfgdfghtХНM"T#$$$$WX??#MRRMMMН$$$$99$$
......~?W…fiW*`........`"#$$$$8Н!Н!?WWW?Н!J$99999$$$
...........M$$$$.............`"T#$T~Н8$WUXUQ$$$$$99$9$$
...........~#$$$mХ.............~Н~$$$?$$$$$$$F$$$990$0
..............~T$$$$8xx......xWWFW~##*"''""''"I**9999о
...............$$$.P$T#$$@@W@*/**$$.............,,*90о
.............$$$L!?$$.XXХXUW....../....$$,,,,....,,ХJ;09*
............$$$.......LM$$$$Ti......../.....n+НHFG$9$*
..........$$$H.Нu....""$$B$$MEb!MХUНT$$0
............W$@WTL...""*$$$W$TH$Н$$0
..............?$$$B$Wu,,''***PF~***$/ ***0
...................*$$g$$$B$$eeeХWP0
........................"*0$$$$M$$00F''


"@ -ForegroundColor Red
Write-Host ""
Write-Host "Balkan School Community - " -ForegroundColor Blue -NoNewline
Write-Host -ForegroundColor Red "cerovina$"

Write-Host ""
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if (!(Test-Admin)) {
    Write-Warning "Molimo pokrenite skriptu sa admin privilegijama."
    Start-Sleep 10
    Exit
}

Start-Sleep -s 3

Clear-Host

$host.privatedata.ProgressForegroundColor = "red";
$host.privatedata.ProgressBackgroundColor = "black";

$pathsFilePath = "paths.txt"
if(-Not(Test-Path -Path $pathsFilePath)){
    Write-Warning "Fajl $pathsFilePath ne postoji."
    Start-Sleep 10
    Exit
}

$paths = Get-Content "paths.txt"
$stopwatch = [Diagnostics.Stopwatch]::StartNew()

$results = @()
$count = 0
$totalCount = $paths.Count
$progressID = 1

foreach ($line in $paths) {
    # Remove non-path information and extract the path
    if ($line -match "^\s*0x[0-9a-f]+ \(.*\):\s*(.*)$") {
        $path = $matches[1]
    } else {
        $path = $line
    }

    $progress = [int]($count / $totalCount * 100)
    Write-Progress -Activity "Provera je u toku..." -Status "$progress% Progress:" -PercentComplete $progress -Id $progressID
    $count++

    Try {
        if ([string]::IsNullOrWhiteSpace($path)) {
            throw "Path is empty or whitespace"
        }

        $fileName = Split-Path $path -Leaf
        if (Test-Path -Path $path) {
            $signatureStatus = (Get-AuthenticodeSignature $path 2>$null).Status
        } else {
            $signatureStatus = "FileMissing"
        }

        $fileDetails = New-Object PSObject
        $fileDetails | Add-Member Noteproperty Name $fileName
        $fileDetails | Add-Member Noteproperty Path $path
        $fileDetails | Add-Member Noteproperty SignatureStatus $signatureStatus

        $results += $fileDetails
    } Catch {
        $fileDetails = New-Object PSObject
        if ([string]::IsNullOrWhiteSpace($path)) {
            $fileName = "Unknown"
        } else {
            $fileName = Split-Path $path -Leaf
        }
        $fileDetails | Add-Member Noteproperty Name $fileName
        $fileDetails | Add-Member Noteproperty Path $path
        $fileDetails | Add-Member Noteproperty SignatureStatus "Error"
        $results += $fileDetails
    }
}

$stopwatch.Stop()

$time = $stopwatch.Elapsed.Hours.ToString("00") + ":" + $stopwatch.Elapsed.Minutes.ToString("00") + ":" + $stopwatch.Elapsed.Seconds.ToString("00") + "." + $stopwatch.Elapsed.Milliseconds.ToString("000")

Write-Host ""
Write-Host "Skeniraje je trajalo: $time ukupno." -ForegroundColor Yellow

$results | Out-GridView -PassThru -Title 'Rezultati provere:'
