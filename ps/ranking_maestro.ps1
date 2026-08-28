[System.Threading.Thread]::CurrentThread.CurrentCulture = [Globalization.CultureInfo]::InvariantCulture
$ErrorActionPreference = 'Stop'
$base = 'C:\Users\lucas\OneDrive\Desktop\hackathon\jovens-talentos-2026-hackathon-data'
$out = "$base\analysis\ranking"

New-Item -ItemType Directory -Path $out -Force | Out-Null

# ============ 1) CARREGAR ARQUIVOS BRUTOS ============
Write-Output "== 1. Carregando arquivos brutos =="
$D = Import-Csv "$base\data\Details_Itapema.csv"
$M = Import-Csv "$base\data\Mesh_Ids_Data_Itapema.csv"
$H = Import-Csv "$base\data\Hosts_ids_Itapema.csv"
$P = Import-Csv "$base\data\Price_AV_Itapema.csv"
$V = Import-Csv "$base\data\VivaReal_Itapema.csv"
Write-Output ("  Details=$($D.Count) Mesh=$($M.Count) Hosts=$($H.Count) Price=$($P.Count) VivaReal=$($V.Count)")

# ============ 2) DEDUP PRICE: mediana por (listing,date) ============
Write-Output "== 2. Deduplicando Price por (listing_id, date) usando mediana =="
$dayMap = @{}
foreach ($r in $P) {
    $key = $r.airbnb_listing_id + '|' + $r.date
    if (-not $dayMap.ContainsKey($key)) { $dayMap[$key] = New-Object System.Collections.Generic.List[double] }
    $dayMap[$key].Add([double]$r.price)
}
$dayMed = @{}
foreach ($k in $dayMap.Keys) {
    $list = @($dayMap[$k] | Sort-Object)
    $dayMed[$k] = $list[[int](($list.Count-1)/2)]
}
Write-Output ("  pares (listing,date) distintos=" + $dayMed.Count + " | linhas brutas=" + $P.Count)

# ============ 3) AGRUPAR POR LISTING (dias distintos) ============
Write-Output "== 3. Agregando diaria media por listing (dias distintos) =="
$listingAgg = @{}
foreach ($k in $dayMed.Keys) {
    $id = ($k -split '\|')[0]
    $pr = $dayMed[$k]
    if (-not $listingAgg.ContainsKey($id)) { $listingAgg[$id] = @{ sum=0.0; n=0 } }
    $listingAgg[$id].sum += $pr
    $listingAgg[$id].n += 1
}

# ============ 4) JOIN Details + Mesh + Hosts ============
Write-Output "== 4. Join com Details/Mesh/Hosts =="
$dmap = @{}; foreach ($r in $D) { $dmap[$r.airbnb_listing_id] = $r }
$mmap = @{}; foreach ($r in $M) { if (-not $mmap.ContainsKey($r.airbnb_listing_id)) { $mmap[$r.airbnb_listing_id] = $r } }
$hmap = @{}; foreach ($r in $H) { $hmap[$r.owner_id] = $r }

function Norm([string]$s) {
    if (-not $s) { return '<vazio>' }
    $n = $s.Normalize([text.NormalizationForm]::FormD)
    $sb = New-Object System.Text.StringBuilder
    foreach ($ch in $n.ToCharArray()) {
        if ([System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($ch) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) { [void]$sb.Append($ch) }
    }
    $r = (($sb.ToString()) -replace '\s+',' ').ToLowerInvariant()
    $r = $r -replace '^itapema[ -]*','' -replace 'meia praia - frente mar','meia praia' -replace ' jardim praia mar',' jardim praiamar'
    if ($r -eq '' -or $r -eq 'itapema') { return '<vazio>' }
    return $r
}

$listings = @()
foreach ($k in $listingAgg.Keys) {
    if (-not $dmap.ContainsKey($k)) { continue }
    $det = $dmap[$k]; $mes = $mmap[$k]
    $hostRec = if ($det.owner_id -and $hmap.ContainsKey($det.owner_id)) { $hmap[$det.owner_id] } else { $null }
    $quartos = if ($det.number_of_bedrooms -match '^\d+') { [int]$det.number_of_bedrooms } else { -1 }
    $hosp = if ($det.number_of_guests -match '^\d+') { [int]$det.number_of_guests } else { -1 }
    $tipo = $det.listing_type
    $diaria = $listingAgg[$k].sum / $listingAgg[$k].n
    # TIPOLOGIA: somente apartamentos (analise de investimento)
    if ($tipo -ne 'apartamento') { continue }
    # plausible filter
    if ($diaria -lt 50 -or $diaria -gt 20000) { continue }
    $listings += [pscustomobject]@{
        listing_id = $k
        suburb     = $(if($mes){$mes.suburb}else{'<sem>'})
        suburb_norm = Norm $(if($mes){$mes.suburb}else{'<sem>'})
        tipo       = $tipo
        quartos    = $quartos
        hospedes   = $hosp
        dias       = $listingAgg[$k].n
        diaria     = [math]::Round($diaria,2)
        min_noites = $det.min_nights
        n_reviews  = if ($det.number_of_reviews -match '^\d+') { [int][double]$det.number_of_reviews } else { 0 }
        prof       = $det.is_professional
        superhost  = if($hostRec){$hostRec.is_superhost}else{''}
    }
}
Write-Output ("  listings validos (preco plausivel)=" + $listings.Count)

# ============ 5) VIVAREAL - somente apartamentos c/ preco e area ============
Write-Output "== 5. VivaReal: apartamentos com preco e area =="
$vapt = @($V | Where-Object {
    $_.listing_type -eq 'apartamento' -and
    $_.sale_price -and [double]$_.sale_price -gt 0 -and
    $_.usable_area -and [double]$_.usable_area -gt 0
})
Write-Output ("  ofertas validadas=" + $vapt.Count)

# medianas de custos por quartos (condominio mensal, IPTU anual) - somente valores realistas
$custoMedia = @{}
foreach ($q in 0..8) {
    $sel = @($vapt | Where-Object {
        $_.bedrooms -eq "$q" -and $_.monthly_condo_fee -and
        [double]($_.monthly_condo_fee) -ge 100 -and [double]($_.monthly_condo_fee) -le 3000
    })
    $iptu = @($vapt | Where-Object {
        $_.bedrooms -eq "$q" -and $_.yearly_iptu -and
        [double]($_.yearly_iptu) -ge 300 -and [double]($_.yearly_iptu) -le 15000
    })
    $condSel = @($sel | ForEach-Object {[double]$_.monthly_condo_fee} | Sort-Object)
    $condMed = if($condSel.Count){ $condSel[[int]((($condSel.Count-1)/2))] } else { 600 }
    $iptuSel = @($iptu | ForEach-Object {[double]$_.yearly_iptu} | Sort-Object)
    $iptuMed = if($iptuSel.Count){ $iptuSel[[int]((($iptuSel.Count-1)/2))] } else { 1500 }
    if (-not $condMed) { $condMed = 600 }
    if (-not $iptuMed) { $iptuMed = 1500 }
    $custoMedia["$q"] = @{ condMes = $condMed; iptuAno = $iptuMed }
}

# ============ 6) AGREGAR POR BAIRRO x QUARTOS ============
Write-Output "== 6. Agregando perfis bairro x quartos =="
$airAgg = @{}
foreach ($L in $listings) {
    $key = $L.suburb_norm + '|' + $L.quartos
    if (-not $airAgg.ContainsKey($key)) { $airAgg[$key] = @{ n=0; dias=@(); diarias=@() } }
    $airAgg[$key].n++
    $airAgg[$key].diarias += $L.diaria
}
$vrAgg = @{}
foreach ($vA in $vapt) {
    $qA = if ($vA.bedrooms -match '^\d+') { [int]$vA.bedrooms } else { -1 }
    $key = (Norm $vA.suburb) + '|' + $qA
    if (-not $vrAgg.ContainsKey($key)) { $vrAgg[$key] = @{ n=0; precos=@(); m2=@(); areas=@() } }
    $vrAgg[$key].n++
    $vrAgg[$key].precos += [double]$vA.sale_price
    $vrAgg[$key].m2 += ([double]$vA.sale_price/[double]$vA.usable_area)
    $vrAgg[$key].areas += [double]$vA.usable_area
}

function Mediana($arr) { $a = @($arr | Sort-Object); if($a.Count -eq 0){return $null}; return $a[[int](($a.Count-1)/2)] }

# ============ 7) RANKING ============
Write-Output "== 7. Calculando ranking (yield liquido) =="
$ocup = 0.55; $dias = 365
$comissao = 0.15
$manutAnual = 2500.0

$rank = @()
$keySet = @($airAgg.Keys | Where-Object { $vrAgg.ContainsKey($_) })
foreach ($key in $keySet) {
    $parts = $key -split '\|'; $sub = $parts[0]; $q = [int]$parts[1]
    $nA = $airAgg[$key].n; $nV = $vrAgg[$key].n
    if ($nA -lt 3 -or $nV -lt 5) { continue }
    # remover outliers de diaria (acima de 3x mediana do perfil) para nao viciar a mediana
    $ddRaw = @($airAgg[$key].diarias)
    $ddMedTmp = Mediana $ddRaw
    if ($ddMedTmp) {
        $airAgg[$key].diarias = @($ddRaw | Where-Object { $_ -le ($ddMedTmp*3) })
        $airAgg[$key].n = $airAgg[$key].diarias.Count
        $nA = $airAgg[$key].n
    }
    $diariaMed = Mediana $airAgg[$key].diarias
    $precoMed  = Mediana $vrAgg[$key].precos
    $m2Med     = Mediana $vrAgg[$key].m2
    $areaMed   = Mediana $vrAgg[$key].areas
    $diasMed   = Mediana $airAgg[$key].dias
    if (-not $diariaMed -or -not $precoMed) { continue }
    $bruta = $diariaMed * $dias * $ocup
    $c = $custoMedia["$q"]
    $custAnual = ($c.condMes*12) + $c.iptuAno + $manutAnual + ($bruta*$comissao)
    $liq = $bruta - $custAnual
    if ($liq -le 0) { $liq = 0 }
    $yieldBruto = ($bruta/$precoMed)*100
    $yieldLiq = ($liq/$precoMed)*100
    $payback = if($liq -gt 0){ $precoMed/$liq } else { 999 }
    $rotulo_quartos = switch($q){ 1{'1 quarto (studio/compacto)'} 2{'2 quartos'} 3{'3 quartos'} 4{'4 quartos'} default{"$q quartos"} }
    $rank += [pscustomobject]@{
        bairro = $sub
        quartos = $q
        perfil = "Apartamento de $rotulo_quartos"
        n_airbnb = $nA
        n_venda = $nV
        diaria_mediana = [math]::Round($diariaMed,0)
        dias_calend_med = [math]::Round($diasMed,0)
        preco_venda_mediana = [math]::Round($precoMed,0)
        preco_m2 = [math]::Round($m2Med,0)
        area_mediana_m2 = [math]::Round($areaMed,0)
        receita_bruta_anual = [math]::Round($bruta,0)
        receita_liquida_anual = [math]::Round($liq,0)
        yield_bruto_pct = [math]::Round($yieldBruto,1)
        yield_liquido_pct = [math]::Round($yieldLiq,1)
        payback_anos = [math]::Round($payback,1)
        amostra_robusta = if($nA -ge 10){'sim'}else{'pequena'}
    }
}

$rank = @($rank | Sort-Object {[double]$_.yield_liquido_pct} -Descending)
$rank | Export-Csv "$out\ranking_investimento.csv" -NoTypeInformation

Write-Output ""
Write-Output "========================================================================"
Write-Output " RANKING FINAL - MELHORES OPCOES (yield liquido, apartamentos, min nA>=3 nV>=5)"
Write-Output "========================================================================"
$rank | ForEach-Object {
    $tag = if($_.amostra_robusta -eq 'sim'){''}else{' **amostra pequena**'}
    $msg = ('# ' + ('{0,2}' -f $_.quartos) + 'q | ' + $_.bairro).PadRight(34)
    $msg += (' | ' + $_.yield_liquido_pct.ToString('N1') + '% liq').PadRight(16)
    $msg += (' | ' + $_.payback_anos.ToString('N1') + 'a').PadRight(12)
    $msg += (' | venda R$' + $_.preco_venda_mediana.ToString('N0')).PadRight(20)
    $msg += (' | diaria R$' + $_.diaria_mediana.ToString('N0')).PadRight(16)
    $msg += (' | nA=' + $_.n_airbnb + ' nV=' + $_.n_venda).PadRight(16)
    $msg += $tag
    Write-Output $msg
}
Write-Output ""
Write-Output ("REGISTROS RANKING=" + $rank.Count)