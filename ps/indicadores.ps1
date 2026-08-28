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

$a = Import-Csv "$base\analysis\1_airbnb_anuncios_consolidado.csv" | Where-Object { ([double]$_.preco_medio_noite) -ge 50 -and ([double]$_.preco_medio_noite) -le 20000 }
$v = Import-Csv "$base\analysis\3_vivareal_anuncios_venda.csv" | Where-Object { $_.sale_price -and ([double]$_.sale_price) -gt 0 }

$air = @{}
foreach ($r in $a) {
    $k = norm $r.suburb
    if (-not $air.ContainsKey($k)) { $air[$k] = @{ n=0; sum=0; nights=0 } }
    $air[$k].n++; $air[$k].sum += [double]$r.preco_medio_noite; $air[$k].nights += [int]$r.n_noites
}
$vr = @{}
foreach ($r in $v) {
    $k = norm $r.suburb
    if (-not $vr.ContainsKey($k)) { $vr[$k] = @{ n=0; sumPv=0; sumM2=0 } }
    $vr[$k].n++; $vr[$k].sumPv += [double]$r.sale_price; $vr[$k].sumM2 += [double]$r.preco_m2
}

# Parâmetros de hipótese (transparentes / ajustáveis)
$ocupAnual = 0.55        # 55% de ocupação média anual (Itapema é altamente sazonal)
$diasAno   = 365
$comissaoPlatform = 0.15 # comissão estimada do canal

$rows = foreach ($k in ($air.Keys | Where-Object { $vr.ContainsKey($_) })) {
    $diariaMedia  = $air[$k].sum / $air[$k].n
    $noitesMed    = $air[$k].nights / $air[$k].n
    $precoMedVenda= $vr[$k].sumPv / $vr[$k].n
    $precoM2      = $vr[$k].sumM2 / $vr[$k].n
    # receita bruta anual = diaria * dias ocupados estimados
    $recBrutaAnual = $diariaMedia * $diasAno * $ocupAnual
    $recLiquida    = $recBrutaAnual * (1 - $comissaoPlatform)
    # custo anual de propriedade (IPTU+condominio estimados) - usamos media por anúncio de venda quando disponível
    $yieldBruto    = if ($precoMedVenda -gt 0) { ($recBrutaAnual / $precoMedVenda) * 100 } else { 0 }
    $yieldLiquido  = if ($precoMedVenda -gt 0) { ($recLiquida / $precoMedVenda) * 100 } else { 0 }
    # payback da receita bruta sobre preço de venda
    $paybackAnos   = if ($recBrutaAnual -gt 0) { $precoMedVenda / $recBrutaAnual } else { 0 }
    [pscustomobject]@{
        bairro            = $k
        n_imoveis_venda    = $vr[$k].n
        n_anuncios_airbnb  = $air[$k].n
        preco_medio_venda  = [math]::Round($precoMedVenda,0)
        preco_m2_medio     = [math]::Round($precoM2,0)
        diaria_media       = [math]::Round($diariaMedia,0)
        noites_calendario_med = [math]::Round($noitesMed,1)
        rec_bruta_anual_est= [math]::Round($recBrutaAnual,0)
        rec_liquida_anual_est=[math]::Round($recLiquida,0)
        yield_bruto_pct    = [math]::Round($yieldBruto,1)
        yield_liquido_pct  = [math]::Round($yieldLiquido,1)
        payback_anos       = [math]::Round($paybackAnos,1)
    }
}
$rows | Sort-Object yield_bruto_pct -Descending | Export-Csv "$base\analysis\5_indicadores_por_bairro.csv" -NoTypeInformation
$rows | Sort-Object yield_bruto_pct -Descending | Format-Table -AutoSize
Write-Output "INDICADORES_OK"