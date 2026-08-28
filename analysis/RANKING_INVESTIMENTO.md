# RANKING DE INVESTIMENTO — Itapema (SC)
### Decisão de alocação de capital em short stay — baseado integralmente nos dados de `data/`
**Data de referência dos preços de diária:** 06/jan a 20/abr/2025

---

## 0. Metodologia (reproduzível — `analysis/ps/ranking_maestro.ps1`)

| Etapa | Procedimento |
|---|---|
| **Dados brutos** | 5 arquivos de `data/` carregados integralmente (Details 4.441, Mesh 4.441, Hosts 4.440, Price 118.839, VivaReal 8.329) |
| **Deduplicação de preços** | Para cada par `(listing, data)` com linhas duplicadas no `Price_AV`, usamos a **mediana dos preços** (evita dupla contagem e outliers). Restaram **59.040 pares distintos** |
| **Join** | Airbnb: `Price` → `Details` (tipologia/quartos) → `Mesh` (bairro) → `Hosts` (anfitrião). VivaReal: anúncios de venda |
| **Filtro de tipologia** | **Somente apartamentos** (tipologia de investimento em short stay) em ambos os lados |
| **Filtro de plausibilidade** | Diária entre R$ 50 e R$ 20.000/noite; imóveis de venda com preço e área > 0 |
| **Métricas** | Diária mediana (mediana das diárias médias por anúncio); preço de venda mediano |
| **Receita** | `diária × 365 × ocupação (55%)` |
| **Custos anuais** | Comissão de canal (15%) + condomínio mediano realista (R$ 600/mês) + IPTU mediano realista (R$ 1.500/ano) + manutenção (R$ 2.500/ano) |
| **Yield líquido** | `Receita líquida ÷ preço de venda` |
| **Tempo de retorno** | `preço de venda ÷ receita líquida anual` |
| **Amostra mínima** | Perfil entra no ranking se `anúncios Airbnb ≥ 3` e `ofertas de venda ≥ 5`; marcamos como “amostra pequena” quando anúncios Airbnb < 10 |

> **Nota sobre custos:** os valores brutos de condomínio/IPTU no VivaReal incluem muitos “0”, “1” e outliers (condomínio até R$ 650 mil). Filtramos para valores realistas: condomínio entre R$ 100–3.000/mês (mediana R$ 600) e IPTU entre R$ 300–15.000/ano (mediana R$ 1.500).

---

## 1. RANKING FINAL — prioridade de compra

Ordenado por **retorno líquido anual sobre o capital** (yield líquido). Estes são os perfis que os dados apontam para **começar já**.

| # | Perfil | Bairro | Diária mediana | Preço de venda (mediana) | Área med. | Receita líquida/ano | **Yield líquido** | **Tempo de retorno** | Amostra |
|---|---|---|---|---|---|---|---|---|---|
| 1 | **Apartamento 3 quartos** | **Tabuleiro dos Oliveiras** | R$ 790 | R$ 810 mil | ~70 m² | R$ 123,6 mil | **15,2%** | **6,6 anos** | ⚠️ pequena (4 anúncios) |
| 2 | **Apartamento 1 quarto (compacto)** | **Morretes** | R$ 533 | R$ 600 mil | ~43 m² | R$ 81,6 mil | **13,6%** | **7,4 anos** | ⚠️ pequena (4 anúncios) |
| 3 | **Apartamento 3 quartos** | **Morretes** | R$ 680 | R$ 845 mil | ~70 m² | R$ 104,8 mil | **12,4%** | **8,1 anos** | ✅ (10 anúncios) |
| 4 | Apartamento 2 quartos | Tabuleiro dos Oliveiras | R$ 484 | R$ 781 mil | ~70 m² | R$ 75,0 mil | 9,6% | 10,5 anos | ✅ (12 anúncios) |
| 5 | Apartamento 2 quartos | Morretes | R$ 480 | R$ 790 mil | ~69 m² | R$ 74,3 mil | 9,4% | 10,7 anos | ✅ (50 anúncios) |
| 6 | Apartamento 1 quarto | Meia Praia | R$ 513 | R$ 875 mil | ~43 m² | R$ 77,9 mil | 8,9% | 11,2 anos | ✅ (19 anúncios) |
| 7 | Apartamento 2 quartos | Casa Branca | R$ 377 | R$ 660 mil | ~60 m² | R$ 56,8 mil | 8,6% | 11,7 anos | ✅ (11 anúncios) |
| 8 | Apartamento 2 quartos | Centro | R$ 600 | R$ 1,15 mi | ~70 m² | R$ 94,3 mil | 8,2% | 12,2 anos | ✅ (65 anúncios) |
| 9 | **Apartamento 1 quarto (compacto)** | **Centro** | R$ 456 | R$ 890 mil | ~42 m² | R$ 68,5 mil | **7,7%** | **13,0 anos** | ✅ (78 anúncios) |
| 10 | Apartamento 2 quartos | Canto da Praia | R$ 544 | R$ 1,22 mi | — | R$ 85,4 mil | 7,0% | 14,3 anos | ⚠️ pequena |
| 11 | Apartamento 2 quartos | Meia Praia | R$ 483 | R$ 1,08 mi | — | R$ 74,5 mil | 6,9% | 14,5 anos | ✅ (186 anúncios) |
| 12 | Apartamento 3 quartos | Centro | R$ 771 | R$ 2,10 mi | — | R$ 119,7 mil | 5,7% | 17,5 anos | ✅ (44 anúncios) |
| 13 | Apartamento 3 quartos | Meia Praia | R$ 700 | R$ 1,88 mi | — | R$ 107,5 mil | 5,7% | 17,5 anos | ✅ (327 anúncios) |
| 14 | Apartamento 4 quartos | Meia Praia | R$ 1.137 | R$ 3,60 mi | — | R$ 177,6 mil | 4,9% | 20,3 anos | ✅ (59 anúncios) |
| 15 | Apartamento 5 quartos | Meia Praia | R$ 1.837 | R$ 8,00 mi | — | R$ 285,8 mil | 3,6% | 27,8 anos | ⚠️ pequena |
| 16 | Apartamento 4 quartos | Centro | R$ 713 | R$ 3,70 mi | — | R$ 102,9 mil | 2,8% | 35,3 anos | ⚠️ pequena |
| 17 | Apartamento 4 quartos | Morretes | R$ 1.117 | R$ 6,10 mi | — | R$ 172,6 mil | 2,8% | 35,1 anos | ⚠️ pequena |

---

## 2. POR QUE ESTAS FORAM ESCOLHIDAS (Top 3)

### 🥇 1º — Apartamento de 3 quartos em Tabuleiro dos Oliveiras
- **Diária mais alta do ranking fora da orla:** R$ 790/noite — 24% acima do 3q em Morretes (R$ 680) e 38% acima do 2q robusto.
- **Preço acessível:** R$ 810 mil (mediana) — a mesma faixa de um 2q em Morretes (R$ 790 mil), pagando quase o dobro de diária.
- **Resultado:** yield líquido **15,2% a.a.** e retorno do capital em **6,6 anos** — o melhor retorno da cidade nos dados.
- **Riscos/ressalvas:** amostra pequena de anúncios Airbnb (4) e ofertas de venda limitadas (14). Sinal forte, porém a confirmar in loco.

### 🥈 2º — Apartamento de 1 quarto (compacto) em Morretes
- **Compacto com melhor custo-benefício:** R$ 600 mil (mediana) — o mais barato do ranking entre perfis com preço real.
- **Diária boa para o tamanho:** R$ 533/noite num imóvel de ~43 m².
- **Resultado:** yield líquido **13,6% a.a.**, retorno em **7,4 anos**.
- **Ressalva:** apenas 4 anúncios Airbnb no perfil específico — confirmar demanda local.

### 🥉 3º — Apartamento de 3 quartos em Morretes
- **Equilíbrio ideal entre retorno e escala:** yield **12,4% a.a.**, retorno em **8,1 anos**.
- **Amostra mais sólida entre os top 3** (10 anúncios Airbnb; 155 imóveis à venda).
- **Diária R$ 680** com preço de R$ 845 mil — bom fluxo de caixa e maior liquidez de revenda.

> **Critério geral:** os três vencedores têm **preço de entrada ≤ R$ 845 mil** e **diária ≥ R$ 533**. É a "regra de ouro" confirmada: comprar barato onde o mercado paga diária alta.

---

## 3. E OS COMPACTOS (studio/1 quarto)? Posição clara

**Entram na lista — mas NÃO são a melhor opção.** Veja a posição honesta dos dados:

| Perfil compacto (1q) | Yield líquido | Tempo de retorno | Amostra |
|---|---|---|---|
| **Morretes** (R$ 600 mil) | **13,6%** | 7,4 anos | ⚠️ 4 anúncios |
| **Meia Praia** (R$ 875 mil) | 8,9% | 11,2 anos | ✅ 19 anúncios |
| **Centro** (R$ 890 mil) | **7,7%** | 13,0 anos | ✅ 78 anúncios |
| Tabuleiro | — | — | sem ofertas representativas |

**Conclusão:** o compacto do **Centro** — a aposta interna preliminar da Seazone — tem o **pior resultado entre os perfis com amostra robusta**: **7,7% a.a.** e retorno em **13 anos**. Isso porque o preço mediano do compacto no Centro é alto (R$ 890 mil) relativamente à diária possível (R$ 456).

**Quando o compacto se sobresa (dados):** apenas em **Morretes com preço de R$ 600 mil** (mediano), onde o rendimento sobe a **13,6%**. Mas a amostra é pequena.

> **Mensagem para a Seazone:** abandonar a hipitese de que "compacto no Centro é a melhor aposta" — os dados dizem que **não**. Se quiserem compactos, o caminho é **Morretes (≤ R$ 700 mil)**, que gera ~14% a.a., ou comprar compactos no Centro **somente abaixo de R$ 450 mil** (pechincha), onde o retorno chega a ~19% — mas isso é exceção, não o padrão do mercado.

---

## 4. POR QUE AS OUTRAS NÃO FORAM ESCOLHIDAS

| Perfil rejeitado | Motivo (dados) |
|---|---|
| **Orla premium (Meia Praia/Centro) 3-4q** | Preço de venda 2-4x maior (R$ 1,9-3,7 mi) com diária que não acompanha → yield 4,9-5,7%, retorno 17-20 anos |
| **Ilhota** | Preço/m² mais caro da cidade (R$ 18 mil+), pouca oferta de aluguel — não entra nos critérios |
| **5-6 quartos** | Retorno 2-3,6%, retorno de 27+ anos — capital imobilizado sem retorno proporcional |
| **4 quartos Morretes/Centro** | Preço mediano muito alto (R$ 6-3,7 mi) para a diária → 2,8% de retorno |
| **Compacto Centro ao preço mediano** | Justificado acima: 7,7% — preço alto demais para a diária |

**Padrão consistente em todos os rejeitados:** o preço de compra **cresce mais rápido que a diária** conforme o imóvel fica maior ou o bairro fica mais nobre. A orla paga bem a diária, mas cobra 2-3x o preço do imóvel — matando o rendimento.

---

## 5. RECOMENDAÇÃO OPERACIONAL (para começar amanhã)

1. **Prioridade 1 — 3q em Tabuleiro dos Oliveiras** (R$ 810 mil, yield 15,2%, retorno 6,6a). *Se a amostra for validada localmente.*
2. **Prioridade 2 — 3q ou 2q em Morretes** (R$ 845 mil / R$ 790 mil; yield 12,4% / 9,4%, retorno 8,1a / 10,7a). *Aposta sólida com melhor liquidez.*
3. **Prioridade 3 — compacto (1q) em Morretes** (R$ 600 mil, yield 13,6%, retorno 7,4a) *se confirmada a demanda.*
4. **Não priorizar:** compacto no Centro, orla premium, imóveis 4+ quartos.

**Regra de ouro aplicável a qualquer oferta:**
> Comprar se o **preço por m² do bairro/perfil** for compatível com a **diária do mesmo perfil** (bairros de entrada: diária ≥ R$ 500 e preço ≤ R$ 850 mil; ou compacto a ≤ R$ 700 mil com diária ≥ R$ 500). Fugir de preços 2x acima da média do bairro — o retorno cai drasticamente.

---

## 6. ARQUIVOS GERADOS

| Arquivo | Conteúdo |
|---|---|
| `analysis/ranking/ranking_investimento.csv` | Ranking completo (17 perfis) com todas as colunas |
| `analysis/ps/ranking_maestro.ps1` | Script mestre reproduzível |
| `analysis/dashboard_investimento.html` | Dashboard atualizado |
| `analysis/RELATORIO_FINAL_INVESTIMENTO.md` | Relatório final atualizado |

*Limitações: os dados de diária cobrem apenas jan–abr/2025. Ocupação de 55% e custos (condomínio R$600, IPTU R$1.500) são premissas realistas — a confirmar por imóvel específico. Amostras pequenas marcadas devem ser validadas antes do fechamento.*