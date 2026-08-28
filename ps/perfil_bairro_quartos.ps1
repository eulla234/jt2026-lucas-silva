[System.Threading.Thread]::CurrentThread.CurrentCulture = [Globalization.CultureInfo]::InvariantCulture
$ErrorActionPreference = 'Stop'
$base = 'C:\Users\lucas\OneDrive\Desktop\hackathon\jovens-talentos-2026-hackathon-data'

function norm([string]$s) {
    if (-not $s) { return '<vazio>' }
    $s = $s.Trim()
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

$d = Import-Csv "$base\data\Details_Itapema.csv"
$m = Import-Csv "$base\data\Mesh_Ids_Data_Itapema.csv"
$p = Import-Csv "$base\data\Price_AV_Itapema.csv"
$v = Import-Csv "$base\data\VivaReal_Itapema.csv"

$agg = @{}
foreach ($r in $p) {
    $pr = [double]$r.price; if ([double]::IsNaN($pr)) { continue }
    $id = $r.airbnb_listing_id
    if ($agg.ContainsKey($id)) { $agg[$id].sum += $pr; $agg[$id].n += 1 } else { $agg[$id] = @{ sum=$pr; n=1 } }
}
$dmap = @{}; foreach ($r in $d) { $dmap[$r.airbnb_listing_id] = $r }
$mmap = @{}; foreach ($r in $m) { if (-not $mmap.ContainsKey($r.airbnb_listing_id)) { $mmap[$r.airbnb_listing_id] = $r } }

# Airbnb apartments por bairro+quartos
$air = @{}
foreach ($k in $agg.Keys) {
    if (-not $dmap.ContainsKey($k)) { continue }
    $det = $dmap[$k]; $mes = $mmap[$k]
    if ($det.listing_type -ne 'apartamento') { continue }
    $q = $(if($det.number_of_bedrooms -match '^\d'){[int]$det.number_of_bedrooms}else{0})
    $avg = $agg[$k].sum / $agg[$k].n
    if ($avg -lt 50 -or $avg -gt 20000) { continue }
    $sub = norm $(if($mes){$mes.suburb}else{'<sem>'})
    $key = "$sub|$q"
    if (-not $air.ContainsKey($key)) { $air[$key] = @{ n=0; vals=@() } }
    $air[$key].n++; $air[$key].vals += $avg
}

# Venda apartments por bairro+quartos
$vr = @{}
foreach ($r in $v) {
    if ($r.listing_type -ne 'apartamento') { continue }
    if (-not $r.sale_price -or -not $r.usable_area) { continue }
    if ([double]$r.sale_price -le 0 -or [double]$r.usable_area -le 0) { continue }
    $q = $(if($r.bedrooms -match '^\d'){[int]$r.bedrooms}else{0})
    $sub = norm $r.suburb
    $key = "$sub|$q"
    $pv = [double]$r.sale_price
    if (-not $vr.ContainsKey($key)) { $vr[$key] = @{ n=0; pv=@() } }
    $vr[$key].n++; $vr[$key].pv += $pv
}

$ocup = 0.55; $dias = 365; $com = 0.15
$out = foreach ($key in ($vr.Keys | Where-Object { $air.ContainsKey($_) })) {
    $parts = $key -split '\|'; $sub=$parts[0]; $q=[int]$parts[1]
    if ($air[$key].n -lt 3 -or $vr[$key].n -lt 5) { continue }   # amostra mínima
    $avS = @($air[$key].vals | Sort-Object); $pvS = @($vr[$key].pv | Sort-Object)
    $medDiaria = $avS[[int](($avS.Count-1)/2)]
    $medVenda  = $pvS[[int](($pvS.Count-1)/2)]
    $rec = $medDiaria * $dias * $ocup
    $yield = ($rec/$medVenda)*100
    [pscustomobject]@{
        bairro=$sub; quartos=$q
        n_airbnb=$air[$key].n; n_venda=$vr[$key].n
        med_diaria=[math]::Round($medDiaria,0)
        med_venda=[math]::Round($medVenda,0)
        rec_anual=[math]::Round($rec,0)
        yield_pct=[math]::Round($yield,1)
        payback=[math]::Round($medVenda/$rec,1)
    }
}
$out | Sort-Object {[int]$_.quartos}, {[double]$_.yield_pct} -Descending | Export-Csv "$base\analysis\9_perfil_bairro_quartos.csv" -NoTypeInformation
$out | Sort-Object {[double]$_.yield_pct} -Descending | Format-Table -AutoSize
Write-Output "PERFIL_BAIRRO_QUARTOS_OK"