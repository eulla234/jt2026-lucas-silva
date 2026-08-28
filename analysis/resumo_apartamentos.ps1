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

# resumo por bairro (Airbnb apartamento)
$out = foreach ($k in ($a | Group-Object suburb)) {
    $o = $k.Group; $pv = @($o | ForEach-Object {[double]$_.preco_medio} | Sort-Object)
    $dc = @($o | ForEach-Object {[int]$_.dias_calendario} | Sort-Object)
    [pscustomobject]@{
        suburb          = $k.Name
        n_anuncios      = $k.Count
        diaria_mediana  = [math]::Round($pv[[int](($pv.Count-1)/2)],0)
        diaria_media    = [math]::Round(($pv|Measure-Object -Average).Average,0)
        dias_mediana    = [math]::Round($dc[[int](($dc.Count-1)/2)],0)
        quartos_medio   = [math]::Round((@($o|ForEach-Object{[int]$_.quartos})|Measure-Object -Average).Average,1)
        hospedes_medio  = [math]::Round((@($o|ForEach-Object{[int]$_.hospedes})|Measure-Object -Average).Average,1)
    }
}
$out | Sort-Object n_anuncios -Descending | Export-Csv "$base\analysis\2_airbnb_resumo_por_bairro.csv" -NoTypeInformation
Write-Output "=== AIRBNB (APARTAMENTO) POR BAIRRO ==="
$out | Sort-Object n_anuncios -Descending | Format-Table -AutoSize

# resumo por quartos
$q = $a | Group-Object quartos | ForEach-Object {
    $o=$_.Group; $pv=@($o|ForEach-Object{[double]$_.preco_medio}|Sort-Object)
    [pscustomobject]@{ quartos=$_.Name; n=$_.Count; diaria_mediana=[math]::Round($pv[[int](($pv.Count-1)/2)],0); diaria_media=[math]::Round(($pv|Measure-Object -Average).Average,0); avg_hosp=[math]::Round((@($o|ForEach-Object{[int]$_.hospedes})|Measure-Object -Average).Average,1) }
}
$q | Sort-Object {[int]$_.quartos} | Export-Csv "$base\analysis\10_airbnb_apartamentos_por_quartos.csv" -NoTypeInformation
Write-Output ""
Write-Output "=== AIRBNB APARTAMENTO POR QUARTOS ==="
$q | Sort-Object {[int]$_.quartos} | Format-Table -AutoSize