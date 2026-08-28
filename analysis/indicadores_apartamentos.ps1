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

# ---- Sources ----
$d = Import-Csv "$base\data\Details_Itapema.csv"
$m = Import-Csv "$base\data\Mesh_Ids_Data_Itapema.csv"
$h = Import-Csv "$base\data\Hosts_ids_Itapema.csv"
$p = Import-Csv "$base\data\Price_AV_Itapema.csv"
$v = Import-Csv "$base\data\VivaReal_Itapema.csv"

# --- Airbnb: agregar preço por listing ---
$agg = @{}
foreach ($r in $p) {
    $pr = [double]$r.price
    if ([double]::IsNaN($pr)) { continue }
    $id = $r.airbnb_listing_id
    if ($agg.ContainsKey($id)) { $agg[$id].sum += $pr; $agg[$id].n += 1 }
    else { $agg[$id] = @{ sum = $pr; n = 1 } }
}

$dmap = @{}; foreach ($r in $d) { $dmap[$r.airbnb_listing_id] = $r }
$mmap = @{}; foreach ($r in $m) { if (-not $mmap.ContainsKey($r.airbnb_listing_id)) { $mmap[$r.airbnb_listing_id] = $r } }
$hmap = @{}; foreach ($r in $h) { $hmap[$r.owner_id] = $r }

$airListings = foreach ($k in $agg.Keys) {
    if (-not $dmap.ContainsKey($k)) { continue }
    $det = $dmap[$k]; $mes = $mmap[$k]
    [pscustomobject]@{
        listing_id        = $k
        suburb            = $(if($mes){$mes.suburb}else{'<sem>'})
        tipo              = $det.listing_type
        quartos           = $(if($det.number_of_bedrooms -match '^\d'){[int]$det.number_of_bedrooms}else{0})
        hospedes          = $(if($det.number_of_guests -match '^\d'){[int]$det.number_of_guests}else{0})
        n_noites          = $agg[$k].n
        preco_medio_noite = [math]::Round($agg[$k].sum/$agg[$k].n,2)
    }
}
$airValid = @($airListings | Where-Object { [double]$_.preco_medio_noite -ge 50 -and [double]$_.preco_medio_noite -le 20000 })
Write-Output ("AIRBNB apartamentos com preco valido: " + (@($airValid | Where-Object { $_.tipo -eq 'apartamento' }).Count))

# --- VivaReal: apartamentos SOMENTE (tipologia de investimento) ---
$vAptVenda = @($v | Where-Object { $_.listing_type -eq 'apartamento' -and $_.sale_price -and [double]$_.sale_price -gt 0 -and $_.usable_area -and [double]$_.usable_area -gt 0 })
Write-Output ("VIVAREAL apartamentos venda com p/m2: " + $vAptVenda.Count)

# --- Agregação por bairro (só aptos) ---
$airAgg = @{}
foreach ($r in $airValid) {
    if ($r.tipo -ne 'apartamento') { continue }
    $k = norm $r.suburb
    if (-not $airAgg.ContainsKey($k)) { $airAgg[$k] = @{ n=0; vals=@() } }
    $airAgg[$k].n++; $airAgg[$k].vals += [double]$r.preco_medio_noite
}
$vrAgg = @{}
foreach ($r in $vAptVenda) {
    $k = norm $r.suburb
    $pm = [double]$r.sale_price/[double]$r.usable_area
    if (-not $vrAgg.ContainsKey($k)) { $vrAgg[$k] = @{ n=0; pv=@(); m2=@() } }
    $vrAgg[$k].n++; $vrAgg[$k].pv += [double]$r.sale_price; $vrAgg[$k].m2 += $pm
}

$ocupAnual = 0.55
$com = 0.15

$rows = foreach ($k in ($vrAgg.Keys | Where-Object { $airAgg.ContainsKey($_) })) {
    $pvS = @($vrAgg[$k].pv | Sort-Object); $m2S = @($vrAgg[$k].m2 | Sort-Object)
    $avS = @($airAgg[$k].vals | Sort-Object)
    $medVenda = $pvS[[int](($pvS.Count-1)/2)]
    $medM2    = $m2S[[int](($m2S.Count-1)/2)]
    $medDiaria= $avS[[int](($avS.Count-1)/2)]
    $recBruta = $medDiaria * 365 * $ocupAnual
    $yield    = if($medVenda -gt 0){ ($recBruta/$medVenda)*100 } else { 0 }
    [pscustomobject]@{
        bairro              = $k
        n_venda_apt         = $vrAgg[$k].n
        n_airbnb_apt        = $airAgg[$k].n
        med_preco_venda     = [math]::Round($medVenda,0)
        med_preco_m2        = [math]::Round($medM2,0)
        med_diaria          = [math]::Round($medDiaria,0)
        rec_bruta_anual_est = [math]::Round($recBruta,0)
        yield_bruto_pct     = [math]::Round($yield,1)
        payback_anos        = [math]::Round($medVenda/$recBruta,1)
    }
}
$rows | Sort-Object yield_bruto_pct -Descending | Export-Csv "$base\analysis\7_indicadores_apartamentos_por_bairro.csv" -NoTypeInformation
$rows | Sort-Object yield_bruto_pct -Descending | Format-Table -AutoSize
Write-Output "APT_INDICADORES_OK"