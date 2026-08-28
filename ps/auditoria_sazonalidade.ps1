[System.Threading.Thread]::CurrentThread.CurrentCulture = [Globalization.CultureInfo]::InvariantCulture
$ErrorActionPreference = 'Stop'
$base = 'C:\Users\lucas\OneDrive\Desktop\hackathon\jovens-talentos-2026-hackathon-data'
$p = Import-Csv "$base\data\Price_AV_Itapema.csv"
$g = @{}
foreach ($r in $p) {
    $pr = [double]$r.price
    if ($pr -lt 50 -or $pr -gt 20000) { continue }
    $m = ([datetime]$r.date).ToString('MM')
    if (-not $g.ContainsKey($m)) { $g[$m] = [System.Collections.Generic.List[double]]::new() }
    $g[$m].Add($pr)
}
Write-Output "=== PREÇO POR MÊS ============================================="
foreach ($m in ('01','02','03','04','05','06','07','08','09','10','11','12')) {
    if ($g.ContainsKey($m)) {
        $v = @($g[$m] | Sort-Object)
        $n = $v.Count
        $med = $v[[int](($n-1)/2)]
        $avg = ($g[$m] | Measure-Object -Average).Average
        Write-Output ("Mes $m | n={0,7} | media={1,7} | mediana={2,7}" -f $n,[math]::Round($avg,0),[math]::Round($med,0))
    } else {
        Write-Output "Mes $m | SEM DADOS"
    }
}
# índices por dia da semana (janela alta temporada vs não)
Write-Output ""
Write-Output "=== PREÇO POR DIA DA SEMANA (todo período) ==="
$wk = @{}
foreach ($r in $p) {
    $pr = [double]$r.price
    if ($pr -lt 50 -or $pr -gt 20000) { continue }
    $d = ([datetime]$r.date).DayOfWeek.ToString()
    if (-not $wk.ContainsKey($d)) { $wk[$d] = [System.Collections.Generic.List[double]]::new() }
    $wk[$d].Add($pr)
}
foreach ($d in ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')) {
    if ($wk.ContainsKey($d)) {
        $v = @($wk[$d] | Sort-Object); $n=$v.Count
        Write-Output ("{0,-10} | n={1,7} | mediana={2,7} | media={3,7}" -f $d,$n,[math]::Round($v[[int](($n-1)/2)],0),[math]::Round(($wk[$d]|Measure-Object -Average).Average,0))
    }
}