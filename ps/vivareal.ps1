[System.Threading.Thread]::CurrentThread.CurrentCulture = [Globalization.CultureInfo]::InvariantCulture
$ErrorActionPreference = 'Stop'
$base = 'C:\Users\lucas\OneDrive\Desktop\hackathon\jovens-talentos-2026-hackathon-data'

$vr = Import-Csv "$base\data\VivaReal_Itapema.csv"

function num([object]$v) { if ($v -and $v -ne '<NA>' -and $v -ne '') { return [double]$v } else { return $null } }

# so anuncios de venda
$vend = $vr | Where-Object { $_.business_types -eq 'Venda' -or $_.business_types -in @('Venda','Ambos') }

# preco/m2 por anuncio
$vend2 = foreach ($v in $vend) {
    $preco = num $v.sale_price
    $area  = num $v.usable_area
    $qtd  = num $v.bedrooms
    $iptu = num $v.yearly_iptu
    $cond = num $v.monthly_condo_fee
    $pm2 = if ($preco -and $area -and $area -gt 0) { $preco/$area } else { $null }
    [pscustomobject]@{
        listing_id   = $v.listing_id
        suburb       = $(if($v.suburb){$v.suburb}else{'<vazio>'})
        tipo         = $v.property_type
        listing_type = $v.listing_type
        sale_price   = $preco
        usable_area  = $area
        bedrooms     = $q
        bathrooms    = $(if($v.bathrooms -match '^\d'){[int]$v.bathrooms}else{''})
        parking      = $(if($v.parking_spaces -match '^\d'){[int]$v.parking_spaces}else{''})
        iptu         = $iptu
        condominio   = $cond
        preco_m2     = $pm2
    }
}
$vend2 | Export-Csv "$base\analysis\3_vivareal_anuncios_venda.csv" -NoTypeInformation
Write-Output ("ANUNCIOS_VENDA=" + $vend2.Count)

$rote = $vend2 | Where-Object { $_.sale_price -and $_.sale_price -gt 0 -and $_.preco_m2 -and $_.preco_m2 -gt 0 }
$sub = $rote | Group-Object suburb | ForEach-Object {
    $o = $_.Group
    $pp = @(($o | ForEach-Object { [double]$_.sale_price }) | Sort-Object)
    $pm = @(($o | ForEach-Object { [double]$_.preco_m2 }) | Sort-Object)
    [pscustomobject]@{
        suburb             = $(if($_.Name){$_.Name}else{'<vazio>'})
        n_anuncios         = $_.Count
        n_apartamentos     = (@($o | Where-Object { $_.listing_type -eq 'apartamento' })).Count
        n_casas            = (@($o | Where-Object { $_.listing_type -eq 'casa' })).Count
        mediana_preco_venda= [math]::Round($pp[[int](($pp.Count-1)/2)],0)
        media_preco_venda  = [math]::Round(($pp | Measure-Object -Average).Average,0)
        mediana_preco_m2   = [math]::Round($pm[[int](($pm.Count-1)/2)],0)
        media_preco_m2     = [math]::Round(($pm | Measure-Object -Average).Average,0)
        area_media_m2      = [math]::Round((@($o | ForEach-Object {[double]$_.usable_area}) | Measure-Object -Average).Average,1)
        quartos_medio      = [math]::Round((@($o | ForEach-Object {[double]$_.bedrooms}) | Measure-Object -Average).Average,1)
        iptu_medio_anual   = [math]::Round((@($o | Where-Object { $null -ne $_.iptu } | ForEach-Object {[double]$_.iptu}) | Measure-Object -Average).Average,0)
        condominio_medio   = [math]::Round((@($o | Where-Object { $null -ne $_.condominio } | ForEach-Object {[double]$_.condominio}) | Measure-Object -Average).Average,0)
    }
}
$sub | Sort-Object n_anuncios -Descending | Export-Csv "$base\analysis\3_vivavra_resumo_por_bairro.csv" -NoTypeInformation
Write-Output "RESUMO_VIVAREAL_EXPORTADO"