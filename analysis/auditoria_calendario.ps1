[System.Threading.Thread]::CurrentThread.CurrentCulture = [Globalization.CultureInfo]::InvariantCulture
$ErrorActionPreference = 'Stop'
$base = 'C:\Users\lucas\OneDrive\Desktop\hackathon\jovens-talentos-2026-hackathon-data'

$p = Import-Csv "$base\data\Price_AV_Itapema.csv"
$seen = [System.Collections.Generic.HashSet[string]]::new()
$dup = 0
$distinct = 0
foreach ($r in $p) {
    $key = $r.airbnb_listing_id + '|' + $r.date
    if ($seen.Add($key)) { $distinct++ } else { $dup++ }
}
Write-Output "linhas price: $($p.Count)"
Write-Output "pares (listing,date) distintos: $distinct"
Write-Output "linhas duplicadas (mesmo listing+date): $dup"

# dias distintos POR listing (cobertura real do calendário)
$days = @{}
foreach ($r in $p) {
    $key = $r.airbnb_listing_id + '|' + $r.date
    # evita recontar a mesma data duas vezes para um listing
    if (-not $seen.Contains($key)) { continue } # já marcado acima; aqui conta por hash diferente
}
# alternativa: per-listing set de datas
$per = @{}
foreach ($r in $p) {
    $id = $r.airbnb_listing_id
    if (-not $per.ContainsKey($id)) { $per[$id] = [System.Collections.Generic.HashSet[string]]::new() }
    [void]$per[$id].Add($r.date)
}
$cd = @($per.Values | ForEach-Object { $_.Count } | Sort-Object)
Write-Output ""
Write-Output "DISTRIBUICAO DE DIAS NO CALENDARIO POR LISTING (distintos):"
Write-Output ("  min={0} p25={1} mediana={2} p75={3} max={4} media={5}" -f $cd[0],$cd[[int]($cd.Count*0.25)],$cd[[int]($cd.Count/2)],$cd[[int]($cd.Count*0.75)],$cd[-1],[math]::Round(($cd|Measure-Object -Average).Average,1))
Write-Output ("  listings com >=105 dias (cupre todo periodo): " + (@($per.Values|Where-Object{$_.Count -ge 105}).Count))
Write-Output ("  listings com <60 dias: " + (@($per.Values|Where-Object{$_.Count -lt 60}).Count))
Write-Output ("  listings 60-104: " + (@($per.Values|Where-Object{$_.Count -ge 60 -and $_.Count -lt 105}).Count))