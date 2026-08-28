[System.Threading.Thread]::CurrentThread.CurrentCulture = [Globalization.CultureInfo]::InvariantCulture
$ErrorActionPreference = 'Stop'
$base = 'C:\Users\lucas\OneDrive\Desktop\hackathon\jovens-talentos-2026-hackathon-data'

$prices = Import-Csv "$base\data\Price_AV_Itapema.csv"
$details = @{}
foreach ($r in Import-Csv "$base\data\Details_Itapema.csv") { $details[$r.airbnb_listing_id] = $r }
$meshMap = @{}
foreach ($r in Import-Csv "$base\data\Mesh_Ids_Data_Itapema.csv") { if (-not $meshMap.ContainsKey($r.airbnb_listing_id)) { $meshMap[$r.airbnb_listing_id] = $r } }
$hostsMap = @{}
foreach ($r in Import-Csv "$base\data\Hosts_ids_Itapema.csv") { $hostsMap[$r.owner_id] = $r }

# agregacao de precos por anuncio
$agg = @{}
foreach ($r in $prices) {
    $pr = [double]$r.price
    if ([double]::IsNaN($pr)) { continue }
    $id = $r.airbnb_listing_id
    if ($agg.ContainsKey($id)) { $agg[$id].sum += $pr; $agg[$id].n += 1 }
    else { $agg[$id] = [pscustomobject]@{ sum = $pr; n = 1 } }
}

function num([object]$v) { if ($v -and $v -ne '<NA>' -and $v -ne '') { return [double]$v } else { return $null } }

$rows = foreach ($k in $agg.Keys) {
    $a = $agg[$k]; $det = $details[$k]
    if (-not $det) { continue }
    $mes = if ($meshMap.ContainsKey($k)) { $meshMap[$k] } else { $null }
    $hostRec = if ($det.owner_id -and $hostsMap.ContainsKey($det.owner_id)) { $hostsMap[$det.owner_id] } else { $null }
    $estrela = num $det.star_rating
    [pscustomobject]@{
        listing_id        = $k
        suburb            = $(if($mes){$mes.suburb}else{'<sem>'})
        tipo              = $det.listing_type
        qtd_quartos       = $(if($det.number_of_bedrooms -match '^\d'){[int]$det.number_of_bedrooms}else{''})
        qtd_hospedes      = $(if($det.number_of_guests -match '^\d'){[int]$det.number_of_guests}else{''})
        n_reviews         = $(if($det.number_of_reviews -match '^\d'){[int][double]$det.number_of_reviews}else{0})
        star_rating       = $(if($estrela){[math]::Round($estrela,2)}else{''})
        n_noites          = $a.n
        preco_medio_noite = [math]::Round($a.sum/$a.n,2)
        receita_bruta_per = [math]::Round($a.sum,2)
        superhost         = $(if($hostRec){$hostRec.is_superhost}else{'<NA>'})
        anos_host         = $(if($hostRec){$hostRec.years_host}else{'<NA>'})
        is_professional   = $det.is_professional
        min_noites        = $det.min_nights
    }
}
$rows | Export-Csv "$base\analysis\1_airbnb_anuncios_consolidado.csv" -NoTypeInformation
Write-Output ("ANUNCIOS_CONSOLIDADOS=" + $rows.Count)

$valid = $rows | Where-Object { ([double]$_.preco_medio_noite) -ge 50 -and ([double]$_.preco_medio_noite) -le 20000 }
$sub = $valid | Group-Object suburb | ForEach-Object {
    $o = $_.Group
    $pv = @(($o | ForEach-Object { [double]$_.preco_medio_noite }) | Sort-Object)
    [pscustomobject]@{
        suburb              = $(if($_.Name){$_.Name}else{'<sem>'})
        n_anuncios          = $_.Count
        n_apartamentos      = (@($o | Where-Object { $_.tipo -eq 'apartamento' })).Count
        n_casas             = (@($o | Where-Object { $_.tipo -eq 'casa' })).Count
        preco_mediana_noite = [math]::Round($pv[[int](($pv.Count-1)/2)],0)
        preco_media_noite   = [math]::Round(($pv | Measure-Object -Average).Average,1)
        qtd_quartos_medio   = [math]::Round((@($o | ForEach-Object {[double]$_.qtd_quartos}) | Measure-Object -Average).Average,1)
        hospedes_medio      = [math]::Round((@($o | ForEach-Object {[double]$_.qtd_hospedes}) | Measure-Object -Average).Average,1)
    }
}
$sub | Sort-Object n_anuncios -Descending | Export-Csv "$base\analysis\2_airbnb_resumo_por_bairro.csv" -NoTypeInformation
Write-Output "RESUMO_BAIRROS_EXPORTADO"