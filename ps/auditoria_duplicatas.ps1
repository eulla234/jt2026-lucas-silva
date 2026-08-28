[System.Threading.Thread]::CurrentThread.CurrentCulture = [Globalization.CultureInfo]::InvariantCulture
$ErrorActionPreference = 'Stop'
$base = 'C:\Users\lucas\OneDrive\Desktop\hackathon\jovens-talentos-2026-hackathon-data'

$p = Import-Csv "$base\data\Price_AV_Itapema.csv"

# verificar duplicatas com valores DIFERENTES (mesmo listing+date, preco diverge?)
$map = @{}
$mismatch = 0
$checked = 0
foreach ($r in $p) {
    $key = $r.airbnb_listing_id + '|' + $r.date
    $pr = [double]$r.price
    if ($map.ContainsKey($key)) {
        $checked++
        if ([math]::Abs($map[$key] - $pr) -gt 0.01) { $mismatch++ }
    } else {
        $map[$key] = $pr
    }
}
Write-Output "duplicatas (listing,date) conferidas: $checked"
Write-Output "delas, com PRECO DIFERENTE na mesma data: $mismatch"
Write-Output ""

# quantas datuns únicos por listing (para corrigir n_noites)
$per = @{}
foreach ($r in $p) {
    $id = $r.airbnb_listing_id
    if (-not $per.ContainsKey($id)) { $per[$id] = [System.Collections.Generic.HashSet[string]]::new() }
    [void]$per[$id].Add($r.date)
}
# e o preco medio CORRETO por listing = soma(preco de dias distintos) / dias distintos
$sumToday = @{}
foreach ($r in $p) {
    $id = $r.airbnb_listing_id
    $key = $id + '|' + $r.date
    if (-not $sumToday.ContainsKey($key)) { $sumToday[$key] = [double]$r.price }
}
$agg = @{}
foreach ($k in $sumToday.Keys) {
    $id = ($k -split '\|')[0]
    $pr = $sumToday[$k]
    if (-not $agg.ContainsKey($id)) { $agg[$id] = @{ sum=$pr; n=1 } }
    else { $agg[$id].sum += $pr; $agg[$id].n++ }
}
Write-Output "RESUMO CORRIGIDO (dias distintos):"
Write-Output ("  listings: " + $agg.Count)
$pm = @($agg.Values | ForEach-Object { $_.sum/$_.n } | Sort-Object)
Write-Output ("  diaria media (por listing, corrigida): " + [math]::Round(($pm|Measure-Object -Average).Average,2))
Write-Output ("  diaria mediana: " + [math]::Round($pm[[int](($pm.Count-1)/2)],2))
# noites distintas médias
$nd = @($per.Values | ForEach-Object { $_.Count } | Sort-Object)
Write-Output ("  noites distintas med por listing: " + [math]::Round(($nd|Measure-Object -Average).Average,1))