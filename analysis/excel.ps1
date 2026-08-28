[System.Threading.Thread]::CurrentThread.CurrentCulture = [Globalization.CultureInfo]::InvariantCulture
$ErrorActionPreference = 'Stop'
$base = 'C:\Users\lucas\OneDrive\Desktop\hackathon\jovens-talentos-2026-hackathon-data'

function Write-Sheet($ws, $data, [string[]]$headers) {
    for ($c=0; $c -lt $headers.Count; $c++) { $ws.Cells.Item(1,$c+1) = $headers[$c] }
    $row = 2
    foreach ($obj in $data) {
        for ($c=0; $c -lt $headers.Count; $c++) {
            $v = $obj.($headers[$c])
            if ($null -ne $v) { $ws.Cells.Item($row,$c+1) = $v }
        }
        $row++
    }
    $range = $ws.Range("A1", $ws.Cells.Item(1,$headers.Count)).Font; $range.Bold = $true
}

$resumo = @(
    [pscustomobject]@{ Info='Apartamentos com preço (Airbnb)'; Valor=911 },
    [pscustomobject]@{ Info='Anúncios de venda (apartamento)'; Valor=7529 },
    [pscustomobject]@{ Info='Diária média apart. (R$/noite)'; Valor=693 },
    [pscustomobject]@{ Info='Melhor yield (Tabuleiro 3q)'; Valor='19,6%' },
    [pscustomobject]@{ Info='Melhor payback (anos)'; Valor=5.1 },
    [pscustomobject]@{ Info='Hipótese ocupação anual'; Valor='55%' },
    [pscustomobject]@{ Info='Comissão canal'; Valor='15%' },
    [pscustomobject]@{ Info='Bairro top renda (apart.)'; Valor='Tabuleiro dos Oliveiras' }
)
$byAir = @(Import-Csv "$base\analysis\2_airbnb_resumo_por_bairro.csv")
$byVenda = @(Import-Csv "$base\analysis\3_vivareal_resumo_por_bairro.csv")
$indic = @(Import-Csv "$base\analysis\5_indicadores_por_bairro.csv")
$saz = @(Import-Csv "$base\analysis\6_sazonalidade_precos.csv")
$perfil = @(Import-Csv "$base\analysis\9_perfil_bairro_quartos.csv")
$porQuarto = @(Import-Csv "$base\analysis\10_airbnb_apartamentos_por_quartos.csv")

$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false; $excel.DisplayAlerts = $false
$wb = $excel.Workbooks.Add()

$ws1 = $wb.Worksheets.Item(1); $ws1.Name = 'Resumo'; Write-Sheet $ws1 $resumo @('Info','Valor')
$ws2 = $wb.Worksheets.Add(); $ws2.Name = 'Airbnb por bairro'; Write-Sheet $ws2 $byAir (($byAir[0] | Get-Member -MemberType NoteProperty).Name)
$ws3 = $wb.Worksheets.Add(); $ws3.Name = 'Venda por bairro'; Write-Sheet $ws3 $byVenda (($byVenda[0] | Get-Member -MemberType NoteProperty).Name)
$ws4 = $wb.Worksheets.Add(); $ws4.Name = 'Indicadores'; Write-Sheet $ws4 $indic (($indic[0] | Get-Member -MemberType NoteProperty).Name)
$ws5 = $wb.Worksheets.Add(); $ws5.Name = 'Sazonalidade'; Write-Sheet $ws5 $saz (($saz[0] | Get-Member -MemberType NoteProperty).Name)
$ws6 = $wb.Worksheets.Add(); $ws6.Name = 'Perfil bairro x quartos'; Write-Sheet $ws6 $perfil (($perfil[0] | Get-Member -MemberType NoteProperty).Name)
$ws7 = $wb.Worksheets.Add(); $ws7.Name = 'Diaria por quartos'; Write-Sheet $ws7 $porQuarto (($porQuarto[0] | Get-Member -MemberType NoteProperty).Name)

foreach ($ws in @($ws1,$ws2,$ws3,$ws4,$ws5,$ws6,$ws7)) { $ws.Columns.AutoFit() | Out-Null }

$path = "$base\analysis\Consolidado_Itapema.xlsx"
$wb.SaveAs($path, 51)
$wb.Close($false)
$excel.Quit()
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
Write-Output "EXCEL_OK $path"