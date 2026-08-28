[System.Threading.Thread]::CurrentThread.CurrentCulture = [Globalization.CultureInfo]::InvariantCulture
$ErrorActionPreference = 'Stop'
$base = 'C:\Users\lucas\OneDrive\Desktop\hackathon\jovens-talentos-2026-hackathon-data'

$d = Import-Csv "$base\data\Details_Itapema.csv"
$m = Import-Csv "$base\data\Mesh_Ids_Data_Itapema.csv"
$h = Import-Csv "$base\data\Hosts_ids_Itapema.csv"
$p = Import-Csv "$base\data\Price_AV_Itapema.csv"
$v = Import-Csv "$base\data\VivaReal_Itapema.csv"

# ---- 1) DEDUP: para cada (listing,date) único guarda o preço; se houver linha duplicada, mantém a primeira ----
$dayPrice = @{}
foreach ($r in $p) {
    $key = $r.airbnb_listing_id + '|' + $r.date
    if (-not $dayPrice.ContainsKey($key)) { $dayPrice[$key] = [double]$r.price }
}

# ---- 2) agregar por listing (dias distintos) ----
$agg = @{}
foreach ($k in $dayPrice.Keys) {
    $id = ($k -split '\|')[0]
    $pr = $dayPrice[$k]
    if (-not $agg.ContainsKey($id)) { $agg[$id] = @{ sum=$pr; n=1 } }
    else { $agg[$id].sum += $pr; $agg[$id].n++ }
}

$dmap = @{}; foreach ($r in $d) { $dmap[$r.airbnb_listing_id] = $r }
$mmap = @{}; foreach ($r in $m) { if (-not $mmap.ContainsKey($r.airbnb_listing_id)) { $mmap[$r.airbnb_listing_id] = $r } }
$hmap = @{}; foreach ($r in $h) { $hmap[$r.owner_id] = $r }
function num([object]$x){ if($x -and $x -ne '<NA>' -and $x -ne ''){ try{ return [double]$x }catch{} }; return $null }

$rows = foreach ($k in $agg.Keys) {
    if (-not $dmap.ContainsKey($k)) { continue }
    $det = $dmap[$k]; $mes = $mmap[$k]
    $hostRec = if ($det.owner_id -and $hmap.ContainsKey($det.owner_id)) { $hmap[$det.owner_id] } else { $null }
    [pscustomobject]@{
        listing_id        = $k
        suburb            = $(if($mes){$mes.suburb}else{'<sem>'})
        tipo              = $det.listing_type
        quartos           = $(if($det.number_of_bedrooms -match '^\d'){[int]$det.number_of_bedrooms}else{0})
        banheiros         = $(if($det.number_of_bathrooms -match '^\d'){[int][math]::Round([double]$det.number_of_bathrooms)}else{0})
        camas             = $(if($det.number_of_beds -match '^\d'){[int]$det.number_of_beds}else{0})
        hospedes          = $(if($det.number_of_guests -match '^\d'){[int]$det.number_of_guests}else{0})
        dias_calendario   = $agg[$k].n
        preco_medio       = [math]::Round($agg[$k].sum/$agg[$k].n,2)
        limpeza           = $(if($det.cleaning_fee -match '^\d'){[math]::Round([double]$det.cleaning_fee,0)}else{0})
        min_noites        = $(if($det.min_nights -match '^\d'){[int]$det.min_nights}else{0})
        n_reviews         = $(if($det.number_of_reviews -match '^\d'){[int][double]$det.number_of_reviews}else{0})
        guest_favorite    = $det.is_guest_favorite
        instant_book      = $det.can_instant_book
        professional      = $det.is_professional
        superhost         = $(if($hostRec){$hostRec.is_superhost}else{'<NA>'})
        star_rating       = $(if((num $det.star_rating)){[math]::Round((num $det.star_rating),2)}else{0})
        months_host       = $(if($hostRec){$hostRec.months_host}else{'<NA>'})
    }
}
$rows | Export-Csv "$base\analysis\1_airbnb_anuncios_consolidado.csv" -NoTypeInformation
Write-Output ("CONSOLIDADO_DEDUP=" + $rows.Count)