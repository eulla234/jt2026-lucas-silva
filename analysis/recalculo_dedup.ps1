[System.Threading.Thread]::CurrentThread.CurrentCulture = [Globalization.CultureInfo]::InvariantCulture
$ErrorActionPreference = 'Stop'
$base = 'C:\Users\lucas\OneDrive\Desktop\hackathon\jovens-talentos-2026-hackathon-data'

function norm([string]$s) {
    if (-not $s) { return '<vazio>' }
    $norm = $s.Normalize([text.NormalizationForm]::FormD)
    $sb = New-Object System.Text.StringBuilder
    foreach ($ch in $norm.ToCharArray()) {
        if ([System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($ch) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) { [void]$sb.Append($ch) }
    }
    $r = (($sb.ToString()) -replace '\s+',' ').ToLowerInvariant()
    $r = $r -replace '^itapema[ -]*',''
    $r = $r -replace 'meia praia - frente mar','meia praia'
    $r = $r -replace ' jardim praia mar',' jardim praiamar'
    if ($r -eq '' -or $r -eq 'itapema') { return '<vazio>' }
    return $r
}

$a = Import-Csv "$base\analysis\1_airbnb_anuncios_consolidado.csv" | Where-Object { $_.tipo -eq 'apartamento' -and [double]$_.preco_medio -ge 50 -and [double]$_.preco_medio -le 20000 }
$v = Import-Csv "$base\data\VivaReal_Itapema.csv" | Where-Object { $_.listing_type -eq 'apartamento' -and $_.sale_price -and [double]$_.sale_price -gt 0 -and $_.usable_area -and [double]$_.usable_area -gt 0 }

$ocup = 0.55; $dias = 365; $com = 0.15

# ---------- POR BAIRRO (apartamento) ----------
$airB = @{}; foreach ($r in $a) { $k=norm $r.suburb; if(-not $airB.ContainsKey($k)){$airB[$k]=@{n=0;vals=@()}}; $airB[$k].n++; $airB[$k].vals += [double]$r.preco_medio }
$vrB = @{}; foreach ($r in $v) { $k=norm $r.suburb; $pm=[double]$r.sale_price/[double]$r.usable_area; if(-not $vrB.ContainsKey($k)){$vrB[$k]=@{n=0;pv=@();m2=@()}}; $vrB[$k].n++; $vrB[$k].pv += [double]$r.sale_price; $vrB[$k].m2 += $pm }
$byBairro = foreach ($k in ($vrB.Keys | Where-Object { $airB.ContainsKey($_) })) {
    $avS=@($airB[$k].vals|Sort-Object); $pvS=@($vrB[$k].pv|Sort-Object); $m2S=@($vrB[$k].m2|Sort-Object)
    $medD=$avS[[int](($avS.Count-1)/2)]; $medV=$pvS[[int](($pvS.Count-1)/2)]; $medM2=$m2S[[int](($m2S.Count-1)/2)]
    $rec=$medD*$dias*$ocup; $yield=($rec/$medV)*100
    [pscustomobject]@{ bairro=$k; n_venda=$vrB[$k].n; n_airbnb=$airB[$k].n; med_venda=[math]::Round($medV,0); med_m2=[math]::Round($medM2,0); med_diaria=[math]::Round($medD,0); rec_anual=[math]::Round($rec,0); yield_pct=[math]::Round($yield,1); payback=[math]::Round($medV/$rec,1) }
}
$byBairro | Sort-Object {[double]$_.yield_pct} -Descending | Export-Csv "$base\analysis\5_indicadores_por_bairro.csv" -NoTypeInformation
Write-Output "=== POR BAIRRO (apartamento) ==="
$byBairro | Sort-Object {[double]$_.yield_pct} -Descending | Format-Table -AutoSize

# ---------- POR BAIRRO x QUARTOS ----------
$airK = @{}; foreach($r in $a){ $k=(norm $r.suburb)+'|'+$r.quartos; if(-not $airK.ContainsKey($k)){$airK[$k]=@{n=0;vals=@()}}; $airK[$k].n++; $airK[$k].vals += [double]$r.preco_medio }
$vrK = @{}; foreach($r in $v){ $q=$(if($r.bedrooms -match '^\d'){[int]$r.bedrooms}else{0}); $k=(norm $r.suburb)+'|'+$q; if(-not $vrK.ContainsKey($k)){$vrK[$k]=@{n=0;pv=@()}}; $vrK[$k].n++; $vrK[$k].pv += [double]$r.sale_price }
$byQuarto = foreach ($key in ($vrK.Keys | Where-Object { $airK.ContainsKey($_) })) {
    $parts=$key -split '\|'; $sub=$parts[0]; $q=$parts[1]
    if($airK[$key].n -lt 3 -or $vrK[$key].n -lt 5){ continue }
    $avS=@($airK[$key].vals|Sort-Object); $pvS=@($vrK[$key].pv|Sort-Object)
    $medD=$avS[[int](($avS.Count-1)/2)]; $medV=$pvS[[int](($pvS.Count-1)/2)]
    $rec=$medD*$dias*$ocup; $yield=($rec/$medV)*100
    [pscustomobject]@{ bairro=$sub; quartos=$q; n_airbnb=$airK[$key].n; n_venda=$vrK[$key].n; med_diaria=[math]::Round($medD,0); med_venda=[math]::Round($medV,0); rec_anual=[math]::Round($rec,0); yield_pct=[math]::Round($yield,1); payback=[math]::Round($medV/$rec,1) }
}
$byQuarto | Sort-Object {[double]$_.yield_pct} -Descending | Export-Csv "$base\analysis\9_perfil_bairro_quartos.csv" -NoTypeInformation
Write-Output ""
Write-Output "=== POR BAIRRO x QUARTOS (top 15) ==="
$byQuarto | Sort-Object {[double]$_.yield_pct} -Descending | Select-Object -First 15 | Format-Table -AutoSize