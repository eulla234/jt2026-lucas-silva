[System.Threading.Thread]::CurrentThread.CurrentCulture = [Globalization.CultureInfo]::InvariantCulture
$ErrorActionPreference = 'Stop'
$base = 'C:\Users\lucas\OneDrive\Desktop\hackathon\jovens-talentos-2026-hackathon-data'

function norm([string]$s) {
    if (-not $s) { return '<vazio>' }
    $s = $s.Trim()
    $norm = $s.Normalize([text.NormalizationForm]::FormD)
    $sb = New-Object System.Text.StringBuilder
    foreach ($ch in $norm.ToCharArray()) {
        $t = [System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($ch)
        if ($t -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) { [void]$sb.Append($ch) }
    }
    $r = (($sb.ToString()) -replace '\s+',' ').ToLowerInvariant()
    $r = $r -replace '^itapema[ -]*',''
    $r = $r -replace 'meia praia - frente mar','meia praia'
    $r = $r -replace ' jardim praia mar',' jardim praiamar'
    if ($r -eq '' -or $r -eq 'itapema') { return '<vazio>' }
    return $r
}

# ---- load ----
$a = Import-Csv "$base\analysis\1_airbnb_anuncios_consolidado.csv" | Where-Object { ([double]$_.preco_medio_noite) -ge 50 -and ([double]$_.preco_medio_noite) -le 20000 }
$v = Import-Csv "$base\analysis\3_vivareal_anuncios_venda.csv" | Where-Object { $_.sale_price -and ([double]$_.sale_price) -gt 0 }

# aggregates airbnb per bairro
$air = @{}
foreach ($r in $a) {
    $k = norm $r.suburb
    $pm = [double]$r.preco_medio_noite
    $nights = [int]$r.n_noites
    if (-not $air.ContainsKey($k)) { $air[$k] = @{ n=0; sum=0; sumN=0 } }
    $air[$k].n++; $air[$k].sum += $pm; $air[$k].sumN += $nights
}
foreach ($k in $air.Keys) { $air[$k].avgNoite = $air[$k].sum / $air[$k].n; $air[$k].avgNights = $air[$k].sumN / $air[$k].n }

# aggregates vivareal per bairro
$vr = @{}
foreach ($r in $v) {
    $k = norm $r.suburb
    $pv = [double]$r.sale_price
    $m2 = [double]$r.preco_m2
    if (-not $vr.ContainsKey($k)) { $vr[$k] = @{ n=0; sumPv=0; sumM2=0 } }
    $vr[$k].n++; $vr[$k].sumPv += $pv; $vr[$k].sumM2 += $m2
}
foreach ($k in $vr.Keys) { $vr[$k].avgPv = $vr[$k].sumPv/$vr[$k].n; $vr[$k].avgM2 = $vr[$k].sumM2/$vr[$k].n }

# join bairros com dados nos dois lados e n>0
$joined = foreach ($k in ($air.Keys | Where-Object { $vr.ContainsKey($_) })) {
    $airNights = ($a | Where-Object { (norm $_.suburb) -eq $k } | ForEach-Object { [double]$_.preco_medio_noite } | Sort-Object)
    [pscustomobject]@{
        bairro           = $k
        n_venda          = $vr[$k].n
        preco_medio_venda= [math]::Round($vr[$k].avgPv,0)
        preco_m2_medio   = [math]::Round($vr[$k].avgM2,0)
        n_air_if         = $air[$k].n
        diaria_media_receita_media = $air[$k].avgNoite
        noites_med_airbnb = $air[$k].avgNights
    }
}
$joined | Sort-Object n_venda -Descending | Export-Csv "$base\analysis\4_cruzamento_bairro.csv" -NoTypeInformation
$joined | Format-Table -AutoSize
Write-Output "CRUZAMENTO_OK"