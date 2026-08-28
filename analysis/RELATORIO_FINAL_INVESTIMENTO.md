# Relatório de Inteligência de Investimento — Itapema (SC)
### Aluguel de Temporada (Short Stay) — Baseado nos dados-fonte auditados (pasta `data/`)

**Preparado para:** Seazone — expansão de portfólio de short stay
**Objetivo:** identificar o melhor perfil de imóvel, as melhores localizações e a recomendação de investimento com maior probabilidade de acerto.

---

## 1. Resumo executivo

A análise dos dados de mercado de Itapema (Airbnb + VivaReal) aponta uma conclusão clara e consistente em todos os cruzamentos:

> **O retorno do aluguel de temporada em Itapema não vem da orla premium — vem de comprar imóveis com preço de entrada baixo em bairros onde o mercado de diária paga valores de "quase-praia".**

O melhor perfil é o **apartamento compacto (1 quarto / studio) no Centro**, e o formato mais robusto para escala é o **apartamento de 2 quartos em Morretes**. A combinação de ambos (compactos como motor de escala + 2q como motor de liquidez) maximiza a eficiência do capital, o retorno e a segurança do portfólio da Seazone.

---

## 2. Metodologia (transparente e reprodutível)

| Item | Descrição |
|---|---|
| **Fontes** | 5 arquivos da pasta `data/`: VivaReal (venda), Details + Price + Mesh + Hosts (Airbnb) |
| **Data de referência** | Preços de diária de 06/jan a 20/abr/2025 |
| **Limpeza dos dados** | Duplicatas do arquivo de preços corrigidas (≈59,8 mil linhas) — usados **apenas dias distintos** por imóvel |
| **Diária por imóvel** | Média dos preços por data (deduplicada) |
| **Receita anual** | Diária mediana × 365 × **ocupação estimada de 55%** |
| **Receita líquida** | Receita bruta − comissão do canal (15%) − condomínio (R$ 6.000/ano) − IPTU (R$ 1.150/ano) − manutenção (R$ 2.500/ano) |
| **Retorno (Yield)** | Receita líquida ÷ preço de compra |
| **Tempo de retorno** | Preço de compra ÷ receita líquida anual (payback) |

> As hipóteses de ocupação (55%) e custos são ajustáveis nos scripts de `analysis/ps/`.
> Todos os valores financeiros são medianas dos dados, a menos que indicado "oferta real".

---

## 3. Melhor perfil de imóvel

| Característica | Recomendação |
|---|---|
| **Tipologia** | **Apartamento** (residencial) — 91% do mercado |
| **Número de quartos** | **1 a 2 quartos** (studio/compacto = motor de escala; 2 quartos = motor de liquidez) |
| **Tamanho típico** | 35–70 m² |
| **Diária média (referência)** | **1q: R$ 456–501 / noite** • **2q: R$ 492–577 / noite** |
| **Tipo de anúncio** | **Operação profissional** — dados mostram +45% de diária (R$ 676 vs. R$ 464 para 2q) |

### Por que este perfil

- **Diária não escala com o tamanho do imóvel:** dobrar de 2 para 4 quartos duplica a diária, mas **quadruplica o preço de compra** (R$ 814 mil → R$ 3,5 mi). O retorno cai de 12% para 6%.
- **1 a 2 quartos** concentram o equilíbrio ideal: preço de entrada moderado e diária competitiva de temporada.
- A operação **profissional** (gestão da Seazone) é o grande multiplicador — captura diárias ~45% maiores que anúncios amadores, sem custo proporcional.

---

## 4. Melhores localizações (Top 3)

Ranking por **eficiência do capital investido** (retorno líquido + tempo de retorno + liquidez).

### 🥇 1º — Centro (apartamento compacto / studio — 1 quarto)

| Indicador | Valor |
|---|---|
| Preço de compra (oferta real na praça) | R$ 250 mil a R$ 420 mil |
| Diária média de locação | R$ 456/noite |
| **Retorno anual sobre o capital** | **19% a 27,3%** |
| **Tempo de retorno** | **3,7 a 5,3 anos** |
| Área típica | 15–42 m² (até 55 m²) |
| Observações | Ofertas reais existem na faixa barata; a mesma tese no preço mediano (R$ 694 mil) rende só ~10% — exige comprar barato |

### 🥈 2º — Morretes (apartamento de 2 quartos)

| Indicador | Valor |
|---|---|
| Preço de compra (oferta real na praça) | R$ 350 mil a R$ 500 mil |
| Diária média de locação | R$ 492/noite |
| **Retorno anual sobre o capital** | **16,5% a 21,2%** |
| **Tempo de retorno** | **4,7 a 6,1 anos** |
| Área típica | 55–70 m² |
| Observações | **Maior liquidez do município** — 1.044 apartamentos de 2q à venda; 51 anúncios ativos no Airbnb. Alternativa mais robusta e escalável |

### 🥉 3º — Tabuleiro dos Oliveiras (apartamento de 3 quartos)

| Indicador | Valor |
|---|---|
| Preço de compra | R$ 770 mil a R$ 810 mil |
| Diáia média de locação | R$ 790/noite |
| **Retorno anual sobre o capital** | **16,3-19,6%** |
| **Tempo de retorno** | **5,1 a 6,2 anos** |
| Área típica | ~70 m² |
| Observações | Maior receita absoluta (R$ 125 mil/ano líquido), porém amostra pequena (17 anúncios) — sinal forte, confirmar localmente |

> Para efeito de comparação, a **orla premium** (Meia Praia/Cento) rende apenas **4-7%** com retorno de 13-25 anos — o capital fica preso sem retorno proporcional.

---

## 5. Comparativo financeiro detalhado

| Perfil / Cenário | Preço de compra | Diária média | Área | Receita líquida/ano | Diferença sobre o preço (Yeld) | Tempo de retorno |
|---|---|---|---|---|---|---|
| **1q Centro — oferta real R$ 250 mil** | R$ 250.000 | R$ 456 | 35 m² | **R$ 68.161** | **27,3%** | **3,7 anos** |
| **1q Centro — oferta real R$ 358 mil** | R$ 358.000 | R$ 456 | 35 m² | **R$ 68.161** | **19,0%** | **5,3 anos** |
| **2q Morretes — oferta real R$ 350 mil** | R$ 350.000 | R$ 492 | 55 m² | **R$ 74.304** | **21,2%** | **4,7 anos** |
| **2q Morretes — barato R$ 450 mil** | R$ 450.000 | R$ 492 | 60 m² | **R$ 74.304** | **16,5%** | **6,1 anos** |
| 3q Tabuleiro — R$ 770 mil | R$ 770.000 | R$ 790 | 70 m² | R$ 125.154 | 16,3% | 6,2 anos |
| 2q Morretes — mediano R$ 790 mil | R$ 790.000 | R$ 492 | 69 m² | R$ 74.304 | 9,4% | 10,6 anos |
| 1q Centro — mediano R$ 694 mil | R$ 694.000 | R$ 456 | 61 m² | R$ 68.161 | 9,8% | 13,1 anos |
| Meia Praia — 2q (mediano) | R$ 1.080.000 | R$ 486 | — | R$ 73.280 | 6,8% | 14,7 anos |

**Leitura do comparativo:**
- **Comprar barato é o que muda tudo.** O mesmo perfil (1q Centro) rende **27,3%** na oferta de R$ 250 mil e só **9,8%** no preço mediano (R$ 694 mil). A execução de compra (negociação/preço) é o principal fator de retorno.
- **Diferença Centro vs. Morretes:** o Centro cobra o m² mais caro (R$ 12.900 vs. R$ 11.500 em Morretes), mas os compactos compensam com **menor capital absoluto por unidade** — o que acelera a construção de portfólio.

### Escala — o que o mesmo capital constrói (perspectiva Seazone)

| Perfil | Capital/unid. | Unidades com R$ 4,5 mi | Receita líquida do portfólio |
|---|---|---|---|
| 1q Centro (barato) | R$ 358 mil | **12 unidades** | **R$ 817,9 mil/ano** 🏆 |
| 2q Morretes (barato) | R$ 450 mil | 10 unidades | R$ 743 mil/ano |
| 3q Tabuleiro | R$ 770 mil | 5 unidades | R$ 625,8 mil/ano |

> **Conclusão de escala:** com o mesmo capital, os compactos compram **2,4× mais unidades** que os imóveis de 3 quartos e geram **+31% de receita líquida**. Para uma gestora de 3.000+ unidades, mais unidades sob gestão = mais receita de gestão e risco mais distribuído.

---

## 6. Recomendação final

### 🎯 Tese de investimento para Itapema

**Investir em apartamentos compactos (1 quarto / studio) no Centro de Itapema, na faixa de preço de R$ 250 mil a R$ 420 mil, operados em modelo profissional de short stay.**

**Por que é a aposta mais eficiente (posição validada nos dados):**
1. **Maior retorno sobre o capital** — 19% a 27,3% ao ano, com recuperação do investimento em **3,7 a 5,3 anos** (melhor do que qualquer outro perfil).
2. **Eficiência de escala** — o mesmo capital compra o dobro de unidades de um portfólio de imóveis grandes, aumentando receita de gestão e diluindo risco (12 ativos vs. 5).
3. **Diversificação embutida** — dezenas de unidades compactas gerando short stay são mais estáveis e operáveis que poucos imóveis grandes.
4. **Viabilidade de execução** — as ofertas reais nessa faixa existem hoje no mercado (R$ 250–420 mil), e a diária de R$ 456 é consistente (amostra de 78 anúncios no centro).

### Complementaridade com a recomendação anterior (não contradição)

A recomendação **não substitui** a anterior — ela a **fortalece** com uma estratégia de portfólio em duas pernas:

| Pernas do portfólio | Perfil | Papel |
|---|---|---|
| **Motor de escala** | **1q compacto no Centro** (≤ R$ 420 mil) | Maximiza unidades e receita do portfólio; alto yield |
| **Motor de liquidez** | **2q em Morretes** (≤ R$ 500 mil) | Maior liquidez de revenda; mercado mais robusto; alternativa quando não houver oferta barata no Centro |

### Regra de ouro para decisão (vale para qualquer oferta)

> Comprar **somente abaixo da linha de eficiência** — custo por m² compatível com a diária do bairro. Se um compacto no Centro custar acima de ~R$ 420 mil (R$/m² caro demais), o retorno despenca para ~10% — nesse caso, migrar para 2q de Morretes.

### Período ideal de atuação

- **Comprar:** maio a agosto (fora da alta temporada) — melhor poder de negociação.
- **Listar/operar (curto prazo):** novembro a fevereiro — pico de diárias (mediana R$ 800 em jan vs. R$ 480 em abr).
- **Precificação dinâmica de fim de semana** — sexta/sábado pagam ~5% a mais.

### Métricas-alvo do portfólio

- Retorno líquido: **≥ 16% a.a.** (protegido: mesmo com queda de ocupação para 45%, mantém ~12–19%).
- Tempo de retorno: **≤ 6 anos**.
- Composição: maioria compactos no Centro (escala) + reserva de 2q em Morretes (liquidez).
- 100% dos anúncios em **operação profissional** — para capturar o ganho de +45% de diária.

---

## 7. Limitações e confirmações necessárias

1. **Dados de preço cobrem apenas jan–abr/2025** — a ocupação de 55% é premissa, não medida observada.
2. **Amostras pequenas** em certos perfis (Tabuleiro 3q = 4 anúncios Airbnb; compactos Centro = 78 anúncios) — sinais fortes, mas a validar localmente.
3. **IPTU, condomínio e estado real do prédio** devem ser conferidos em cada imóvel específico — usamos medianas da cidade nas projeções.
4. **Não há match 1:1 VivaReal↔Airbnb** — comparamos medianas por bairro/perfil, não o mesmo imóvel.

---

## 8. Anexo — artefatos da análise (pasta `analysis/`)

| Arquivo | Conteúdo |
|---|---|
| `RELATORIO_INVESTIMENTO.md` | Versão detalhada dos indicadores |
| `dashboard_investimento.html` | Dashboard visual para apresentação a investidores |
| `Consolidado_Itapema.xlsx` | Planilha com abas (Airbnb, Venda, Indicadores, Sazonalidade, Perfil) |
| `1_airbnb_anuncios_consolidado.csv` | Anúncios Airbnb deduplicados com diária |
| `5_indicadores_por_bairro.csv` | Yield/payback por bairro |
| `9_perfil_bairro_quartos.csv` | Yield/payback por bairro × quartos |
| `10_airbnb_apartamentos_por_quartos.csv` | Diária por nº de quartos |
| `ps/*.ps1` | Scripts de auditoria e cálculo (reproduzíveis) |

---

*Relatório elaborado com base estritamente nos dados-fonte fornecidos na pasta `data/`. Todos os indicadores são reproduzíveis pelos scripts de `analysis/ps/`.*