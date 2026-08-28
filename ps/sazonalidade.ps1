[System.Threading.Thread]::CurrentThread.CurrentCulture = [Globalization.CultureInfo]::InvariantCulture
$ErrorActionPreference = 'Stop'
$base = 'C:\Users\lucas\OneDrive\Desktop\hackathon\jovens-talentos-2026-hackathon-data'
$p = Import-Csv "$base\data\Price_AV_Itapema.csv" | Where-Object { ([double]$_.price) -ge 50 -and ([double]$_.price) -le 20000 }
$g = @{}
foreach ($r in $p) {
    $m = ([datetime]$r.date).ToString('yyyy-MM')
    if (-not $g.ContainsKey($m)) { $g[$m] = @{ n=0; sum=0; vals=@() } }
    $g[$m].n++; $g[$m].sum += [double]$r.price; $g[$m].vals += [double]$r.price
}
$rows = foreach ($m in ($g.Keys | Sort-Object)) {
    $v = @($g[$m].vals | Sort-Object)
    [pscustomobject]@{
        mes             = $m
        n_registros     = $g[$m].n
        diaria_media    = [math]::Round($g[$m].sum / $g[$m].n,1)
        diaria_mediana  = [math]::Round($v[[int](($v.Count-1)/2)],1)
    }
}
$rows | Sort-Object mes | Export-Csv "$base\analysis\6_sazonalidade_precos.csv" -NoTypeInformation
$rows | Sort-Object mes | Format-Table -AutoSize
Write-Output "SAZONALIDADE_OK"