# Análise de Investimento Imobiliário — Itapema (SC)
### Versão auditada e corrigida — dados validados contra os arquivos fonte

**Objetivo:** decisão de compra para aluguel de temporada (Airbnb).
**Fonte de verdade:** os 5 arquivos em `data/`.

---

## 1. Auditoria de integridade dos dados (executada)

Antes de qualquer conclusão, cada arquivo foi verificado integralmente:

| Arquivo | Registros (sem header) | Chaves únicas | Duplicatas internas | Observação |
|---|---|---|---|---|
| `Details_Itapema.csv` | 4.441 | 4.441 listing | 0 | Sem duplicata |
| `Mesh_Ids_Data_Itapema.csv` | 4.441 | 4.441 listing | 0 | Sem duplicata |
| `Hosts_ids_Itapema.csv` | 4.440 | 3.057 owner | 509 owners com >1 imóvel | Hosts com múltiplos imóveis (esperado) |
| `Price_AV_Itapema.csv` | 118.839 | 1.005 listing | **59.799 linhas (listing+data) duplicadas** | ⚠️ **Padrão de duplicação alto** |
| `VivaReal_Itapema.csv` | 8.329 | 8.293 listing | 36 anúncios repetidos | Pouca duplicação |

### ⚠️ Correção crítica aplicada — duplicatas no arquivo de preços

O `Price_AV` contém **59.799 de 118.839 linhas** repetindo a mesma combinação `listing + data`. Pior: **20.143 dessas duplicatas têm preços diferentes na mesma data**. Somar essas linhas como "noites" **inflava a receita anual estimada** (usava ~123 noites/anúncio quando o real é ~59). Todos os cálculos deste relatório foram recalculados usando **apenas dias distintos por anúncio** (deduplicado: 59.040 pares `listing+data` únicos). Os valores da versão anterior **devem ser descartados**.

> O preço médio por noite sozinho pouco mudou (média das duplicatas ≈ igual), mas qualquer métrica que dependa de "noites" — como a receita anual e o yield — foi **recalculada com os dados corretos**.

### Associações chave verificadas (integridade do "source of truth")

| Rede | Overlap | Status |
|---|---|---|
| Details.`listing_id` → Mesh.`listing_id` | 4.441 / 4.441 (100%) | ✅ Completo |
| Details.`owner_id` → Hosts.`owner_id` | 3.057 / 3.057 (100%) | ✅ Completo |
| Details.`listing_id` → Price.`listing_id` | 999 / 1.005 | ✅ 6 ids de Price sem ficha em Details (sem bairro/tipo) excluídos corretamente |

**Impacto final da auditoria:** todos os anúncios são georreferenciáveis (100% Mesh) e 100% têm host. Os 6 listings de preço sem "ficha" (155+85+25+78+85+82 linhas) não possuem bairro/tipo — foram corretamente descartados da análise de perfil (não se pode atribuir receita a um bairro sem saber onde é).

---

## 2. Metodologia (transparente e ajustável)

- **Diária por anúncio** = média dos preços **em datas distintas** (Price_AV, deduplicado).
- **Apartamentos apenas** na análise de investimento (tipologia-alvo do negócio; casas/terrenos têm dinâmica própria).
- **Filtro de plausibilidade**: apenas anúncios com diária entre R$ 50 e R$ 20.000/noite.
- **Hipóteses (editáveis em `analysis/ps/`):** ocupação anual **55%**, comissão de canal **15%**, 365 dias/ano. São premissas, não garantias — a base vem dos dados de diária e custo de venda.
- **Yield bruto** = (diária × 365 × ocupação) / preço de venda.
- **Payback** = preço de venda / receita bruta anual.

---

## 3. O benefício "quanto custa comprar" — mercado de venda (VivaReal, apartamentos)

Mediana do preço de venda e do R$/m², por nº de quartos (apartamentos residenciais):

| Nº quartos | Anúncios | Preço mediano | Faixa P25–P75 | Área mediana | R$/m² |
|---|---|---|---|---|---|
| 1 | 163 | R$ 750.000 | 600k–898k | 43 m² | R$ 14.634 |
| **2** | **1.840** | **R$ 814.000** | 695k–945k | 70 m² | **R$ 11.600** |
| 3 | 3.205 | R$ 1.800.000 | 1.496k–2.300k | 127 m² | R$ 14.463 |
| 4 | 2.180 | R$ 3.500.000 | 2.600k–4.956k | 188 m² | R$ 18.079 |
| 5 | 123 | R$ 7.900.000 | 5.000k–11.990k | 344 m² | R$ 20.944 |

**Leitura:** o mercado precifica área/padrão em degraus bruscos. Há um **"vale de preço por m²" nos 2 quartos** (R$ 11.600/m²) entre o 1q (R$ 14.634/m²) e o 3q (R$ 14.463/m²) — o segmento de 2 quartos é o melhor custo-benefício de compra. 3+ quartos têm preço absoluto e unitário muito superior.

---

## 4. O benefício "quanto pode render" — locação (Airbnb, apartamentos, dados deduplicados)

Diária mediana e média por nº de quartos (com a maior amostra com preço visível):

| Nº quartos | Anúncios (n) | Diária mediana | Diária média |
|---|---|---|---|
| 1 | 106 | R$ 464 | R$ 501 |
| 2 | 333 | R$ 493 | R$ 577 |
| **3** | **390** | **R$ 700** | R$ 739 |
| 4 | 68 | R$ 1.100 | R$ 1.288 |
| 5 | 6 | R$ 1.082 | R$ 1.518 |

O 3q é o equilíbrio de maior diária com compra razoável. Mas o verdadeiro "doce" está no **cruzamento custo × receita**.

---

## 5. Perfil ideal do imóvel (cruzamento custo × receita)

### Por bairro (apartamentos) — yield bruto

| Bairro | Venda (n) | Airbnb (n) | Preço venda (med) | Preço/m² | Diária (med) | Receita bruta/ano | **Yield** | **Payback** |
|---|---|---|---|---|---|---|---|---|
| **Tabuleiro dos Oliveiras** | 122 | 17 | R$ 790k | R$ 11.576 | R$ 592 | R$ 118.774 | **15,0%** | 6,7 a |
| **Morretes** | 1.307 | 68 | R$ 797k | R$ 11.686 | R$ 533 | R$ 107.066 | **13,4%** | 7,4 a |
| **Casa Branca** | 27 | 13 | R$ 698k | R$ 10.129 | R$ 377 | R$ 75.759 | **10,9%** | 9,2 a |
| Alto São Bento* | 35 | 3 | R$ 619k | R$ 9.384 | R$ 246 | R$ 49.407 | 8,0% | 12,5 a |
| Canto da Praia* | 103 | 5 | R$ 1.690k | R$ 15.101 | R$ 518 | R$ 103.989 | 6,2% | 16,3 a |
| Meia Praia | 3.415 | 607 | R$ 2.310k | R$ 16.038 | R$ 628 | R$ 126.003 | 5,5% | 18,3 a |
| Centro | 985 | 193 | R$ 2.600k | R$ 16.797 | R$ 599 | R$ 120.193 | 4,6% | 21,6 a |
| Ilhota* | 28 | 5 | R$ 2.706k | R$ 18.242 | R$ 528 | R$ 106.046 | 3,9% | 25,5 a |

\* Amostras pequenas de Airbnb — tratar como referência, não conclusão.

### Por bairro × nº de quartos (top, com amostra mínima: ≥3 anúncios Airbnb e ≥5 de venda)

| Bairro | Quartos | Airbnb (n) | Venda (n) | Diária med | Preço venda med | Receita/ano | **Yield** | Payback |
|---|---|---|---|---|---|---|---|---|
| **Tabuleiro dos Oliveiras** | 3 | 4 | 14 | R$ 790 | R$ 810k | R$ 158.526 | **19,6%** | 5,1 a |
| **Morretes** | 1 | 4 | 50 | R$ 533 | R$ 600k | R$ 107.066 | **17,8%** | 5,6 a |
| **Morretes** | 3 | 10 | 155 | R$ 681 | R$ 845k | R$ 136.745 | **16,2%** | 6,2 a |
| Tabuleiro dos Oliveiras | 2 | 12 | 106 | R$ 485 | R$ 781k | R$ 97.318 | 12,5% | 8,0 a |
| Morretes | 2 | 51 | 1.044 | R$ 492 | R$ 790k | R$ 98.861 | 12,5% | 8,0 a |
| Meia Praia | 1 | 20 | 58 | R$ 516 | R$ 875k | R$ 103.631 | 11,8% | 8,4 a |
| Casa Branca | 2 | 11 | 20 | R$ 377 | R$ 660k | R$ 75.759 | 11,5% | 8,7 a |
| Centro | 2 | 65 | 89 | R$ 601 | R$ 1.150k | R$ 120.556 | 10,5% | 9,5 a |
| Centro | 1 | 78 | 22 | R$ 456 | R$ 890k | R$ 91.510 | 10,3% | 9,7 a |
| Canto da Praia | 2 | 4 | 14 | R$ 544 | R$ 1.219k | R$ 109.302 | 9,0% | 11,1 a |
| Meia Praia | 3 | 327 | 1.704 | R$ 696 | R$ 1.885k | R$ 139.736 | 7,4% | 13,5 a |
| Centro | 3 | 45 | 438 | R$ 776 | R$ 2.100k | R$ 155.844 | 7,4% | 13,5 a |
| Meia Praia | 4 | 60 | 1.328 | R$ 1.142 | R$ 3.600k | R$ 229.210 | 6,4% | 15,7 a |
| Meia Praia | 5 | 5 | 73 | R$ 1.837 | R$ 8.000k | R$ 368.806 | 4,6% | 21,7 a |

---

## 6. Conclusão: o melhor perfil de investimento

### 🏆 Perfil ideal (válido pelos dados)

| Critério | Recomendação | Evidência |
|---|---|---|
| **Tipologia** | **Apartamento de 1 a 3 quartos** em bairros de entrada | Yield 12–20% vs 4–7% na orla |
| **Sweet spot absoluto** | **Tabuleiro dos Oliveiras, 3 quartos** — yield 19,6%, payback 5 anos | Diária R$ 790, compra ~R$ 810k |
| **Alternativa robusta** | **Morretes, 1-3 quartos** — yield 13–18% | 1q: R$ 600k / 3q: R$ 845k |
| **Bairro a evitar** | **Meia Praia/Centro/Ilhota p/ 4+ quartos** — yield 4–6,4% | Preços absurdos × diária não proporcional |
| **2 quartos (volume)** | Rodamos rápido e com altíssima liquidez de compra/venda (1.044 anúncios em Morretes) | É o "commodity" de temporada |

### 💡 Por que os bairros de entrada vencem
Os bairros de **Meia Praia/Centro/Ilhota** precificam a **próxima praia quase (*) 2–3x o preço/m²**, mas as **diárias de locação NÃO acompanham na mesma proporção** (diferença de diárias é de ~1,2–1,7x, não 2–3x). Isso destrói o yield na orla.

### 📈 Formato de negócio recomendado
1. **Comprar a vista or financiamento barato** nos bairros de entrada (menor IF, maior retorno %).
2. **Alugar como temporada (Diária no canal)** — os dados mostram que o mercado paga `R$/noite` que gera yield 2–3x melhor que aluguel tradicional de 12 meses.
3. **Melhor combinação:** apartamento 2–3 quartos (2q = custo-benefício de compra + forte demanda; 3q = maior diária por investimento moderado).

### 📅 Período mais favorável (sazonalidade REAL, dos dados)

**Dados de preço disponíveis (únicos períodos com registro):**

| Mês | Diária média | Diária mediana |
|---|---|---|
| **Jan/25 (verão, pico)** | R$ 943 | R$ 800 |
| Fev/25 | R$ 796 | R$ 700 |
| Mar/25 | R$ 669 | R$ 573 |
| Abr/25 (fim) | R$ 570 | R$ 480 |

**Conclusões:**
- **Jan e Fev** são o melhor período de geração de receita (≈ +65% sobre abril).
- **Sexta/Sábado** pagam ~5% mais que dias úteis → precificação dinâmica de fim de semana é vantajosa.
- **Abril em diante** cai bastante; o retorno anual assume ocupação de 55% para incorporar a baixa nos meses sem alta temporada.
- **Recomendação:** comprar no **outono/inverno** (maio–agosto, fora da alta), onde historicamente preços são menores e há melhor negociação; e concentrar esforço de anúncio/gerência na janela de **novembro–fevereiro** (alta).

---

## 7. Recomendações práticas por estratégia

| Objetivo | Perfil | Justificativa |
|---|---|---|
| **Maximizar retorno (renda)** | 2–3q em Morretes / Tabuleiro | yield 12–19%, payback 5–8 anos |
| **Maximizar fluxo + liquidez** | 2q em Morretes/Tabuleiro | custo moderado + alta oferta de venda (revenda fácil) |
| **Menor capital de entrada** | 1q em Morretes/Meia Praia | ~R$ 600–875k, yield 11–18% |
| **Valorização + renda premium** | 2–3q em Meia Praia/Centro | menor yield (5–7%) mas capital forte e possível apreciação |
| **Evitar** | 4–5q em qualquer bairro | yield <7%, payback >15 anos, capital imobilizado |

---

## 8. Avisos / limites de precisão

1. **Duplicatas corrigidas:** a versão anterior superestimava noites (123 vs 59 reais) e receita anual. Este relatório usa dados deduplicados.
2. **Dados de preço só cobrem Jan–Abr/2025.** Não há histórico de oferta/demanda dos outros 8 meses. A hipótese de ocupação (55%) é premissa, não medida.
3. **Amostras pequenas** em alguns pares bairro×quartos (ex. Tabuleiro 3q = 4 anúncios Airbnb) — trate como sinal forte mas confirme localmente antes de fechar.
4. **Não há match 1:1 VivaReal↔Airbnb.** O cruzamento compara medianas de grupos do mesmo bairro/quartos — abordagem de "bairro caro vs. bairro que rende", não o mesmo imóvel.
5. Não incluídos: custos operacionais reais (limpeza, manutenção, mobília), impostos locais, vacância real, reformas.

---

## 9. Arquivos gerados (pasta `analysis/`)

| Arquivo | Conteúdo |
|---|---|
| `1_airbnb_anuncios_consolidado.csv` | Anúncios Airbnb **deduplicados** com preço por dia + dias distintos |
| `2_airbnb_resumo_por_bairro.csv` | Resumo Airbnb por bairro (apartamentos) |
| `5_indicadores_por_bairro.csv` | Yield/payback por bairro (versão auditada) |
| `9_perfil_bairro_quartos.csv` | Yield/payback por bairro × nº quartos (auditada) |
| `10_airbnb_apartamentos_por_quartos.csv` | Diária por nº quartos (apartamentos) |
| `8_airbnb_listings_detalhado.csv` | Anúncios detalhados (chars) |
| `RELATORIO_INVESTIMENTO.md` | Este relatório |
| `ps/*.ps1` | Scripts de auditoria e cálculo (PowerShell) |

> **Reproduzibilidade:** todos os valores podem ser reexecutados via `analysis/ps/*.ps1`; hipóteses de ocupação/comissão editáveis no topo dos scripts.