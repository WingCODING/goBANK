# Lumo — Documento de Design (Flutter Frontend)

> **Lumo · Seu banco digital**
> Protótipo de aplicativo bancário mobile — 7 telas.
> Este documento é a fonte única de verdade para implementação do **frontend em Flutter** (somente UI, sem backend). Todas as medidas, cores, tipografia e comportamentos foram extraídos das telas de referência e devem ser reproduzidos com fidelidade.

---

## 1. Visão Geral

Lumo é um app de banco digital com estética **clean, moderna e arredondada**, fundo claro, cartões brancos flutuantes e uma cor de marca **magenta/rosa vibrante** usada em CTAs e destaques. O tom é amigável e direto ("Seu banco digital", "Leva menos de 2 minutos").

### 1.1 Telas (fluxo)

| # | Tela | Rota sugerida | Tipo |
|---|------|---------------|------|
| 01 | Login | `/login` | Autenticação |
| 02 | Cadastro | `/cadastro` | Autenticação |
| 03 | Home | `/home` | Navegação principal (tab) |
| 04 | Transferir | `/transferir` | Tab |
| 05 | Cobranças | `/cobrancas` | Tab |
| 06 | Criar cobrança (Nova cobrança) | `/cobrancas/nova` | Push |
| 07 | Empréstimo | `/emprestimo` | Tab |

> **Observação de protótipo:** o app é *somente frontend*. Não há chamadas de rede. Botões devem navegar/animar e exibir estados de sucesso simulados ("Toque nos botões pra navegar e ver as confirmações de sucesso"). Dados são *mockados* (hardcoded).

### 1.2 Plataforma alvo
- **Flutter** (Material 3 como base, fortemente customizado).
- **Mobile-first**, layout de celular (referência: iPhone com notch/Dynamic Island, status bar `9:41`).
- Orientação **retrato** apenas.
- Suporte a *safe area* (topo e bottom home indicator).

---

## 2. Design System

### 2.1 Paleta de cores

#### Marca / Primária
| Token | Hex | Uso |
|-------|-----|-----|
| `primary` | `#E91E63` → ajustar para **`#EC0B5A`** | Cor da marca. Botões primários, logo, ícones ativos, links de destaque, gradiente do cartão de saldo. |
| `primaryDark` | `#C50A4D` | Fim do gradiente do cartão de saldo / pressed state. |
| `primaryLight` | `#FCE4EC` | Fundo de item selecionado no menu lateral, chips/avatars de destaque, fundo de ícones de ação. |
| `primarySoft` | `#FDECEF` | Fundo de banner informativo (tela Nova cobrança). |
| `onPrimary` | `#FFFFFF` | Texto/ícones sobre primária. |

> A cor real nas imagens é um **rosa-magenta vibrante**. Use `#EC0B5A` como valor canônico. O gradiente do cartão de saldo vai de `#EC0B5A` (topo-esquerda) para `#C50A4D` (base-direita), aproximadamente 135°.

#### Neutros
| Token | Hex | Uso |
|-------|-----|-----|
| `background` | `#EDEFF2` | Fundo geral do app (cinza muito claro azulado). |
| `surface` | `#FFFFFF` | Cartões, campos, sheets, app bar. |
| `surfaceAlt` | `#F4F5F7` | Fundo de inputs preenchidos (Valor, CPF em alguns campos), divisores suaves. |
| `border` | `#E6E8EC` | Borda de inputs e cartões (1px). |
| `textPrimary` | `#16181D` | Títulos e valores (quase preto). |
| `textSecondary` | `#6B7280` | Subtítulos, labels, descrições. |
| `textTertiary` | `#9CA3AF` | Placeholders, metadados, texto desabilitado. |
| `iconMuted` | `#9CA3AF` | Ícones inativos da bottom bar e dentro de inputs. |

#### Semânticas
| Token | Hex | Uso |
|-------|-----|-----|
| `success` | `#16A34A` | Botão "Aprovar", valores recebidos (`+ R$ 45,90`), badge "Aprovada". |
| `successBg` | `#DCFCE7` | Fundo do badge "Aprovada". |
| `warning` | `#B45309` (texto) / `#FEF3C7` (fundo) | Badge "Pendente". |
| `danger` | `#DC2626` | Reservado para erros de validação (não aparece nas telas, mas padronizar). |
| `incomeGreen` | `#16A34A` | Avatar/ícone de Pix recebido (fundo `#D1FAE5`). |

#### Cores auxiliares de avatar
- Avatares de iniciais usam fundo `#F1F2F4` com texto `textSecondary`, **exceto** quando em contexto de destaque (Transferir → contatos) onde usam fundo `primaryLight` com texto `primary`.

### 2.2 Tipografia

Fonte: **Inter** (ou similar grotesca geométrica). Fallback: system. Títulos com peso forte e leve *tight letter-spacing*.

| Estilo | Tamanho | Peso | Cor | Uso |
|--------|---------|------|-----|-----|
| `displayLarge` | 40 sp | 700 | textPrimary | Valor de empréstimo "R$ 5.000", saldo grande. |
| `headlineLarge` | 34 sp | 700 | textPrimary | Saldo "R$ 1.250,00". |
| `titleScreen` | 26 sp | 700 | textPrimary | Títulos de tela ("Criar sua conta", "Transferir", "Cobranças", "Nova cobrança", "Empréstimo"). |
| `titleBrand` | 24 sp | 700 | textPrimary | "Lumo" sob o logo. |
| `titleM` | 17 sp | 700 | textPrimary | Nomes em listas (Bruno Carvalho), "Transferência enviada". |
| `body` | 15 sp | 400 | textPrimary | Texto de campos preenchidos. |
| `label` | 14 sp | 600 | textSecondary | Labels de formulário ("E-mail", "Senha", "Valor"). |
| `caption` | 13 sp | 400 | textSecondary | Subtítulos, metadados ("Hoje · 09:12"). |
| `overline` | 12 sp | 700 | textSecondary | Seções caps ("ÚLTIMAS MOVIMENTAÇÕES", "ENVIAR PARA"), com `letter-spacing: 0.8`, UPPERCASE. |
| `button` | 16 sp | 700 | onPrimary | Texto de botões. |
| `link` | 14 sp | 600 | primary | "Esqueci minha senha", "Ver tudo", "Entrar". |

> Valores monetários: usar formato pt-BR `R$ 1.250,00` (separador de milhar `.`, decimal `,`). Configurar `intl` com locale `pt_BR`.

### 2.3 Espaçamento e grid

- Escala base de 4px: `4, 8, 12, 16, 20, 24, 32`.
- **Padding horizontal de tela:** `24px` (conteúdo) — content gutter.
- Espaçamento vertical entre blocos de formulário: `20px`.
- Gap label → input: `8px`.

### 2.4 Raios (border radius)

| Token | Valor | Uso |
|-------|-------|-----|
| `radiusInput` | 14 | Campos de texto. |
| `radiusCard` | 20 | Cartões (saldo, listas, blocos de form). |
| `radiusButton` | 16 | Botões grandes / pílulas de CTA. |
| `radiusChip` | 12 | Chips de valor (empréstimo), tabs. |
| `radiusBadge` | 8 | Badges de status. |
| `radiusLogo` | 18 | Quadrado do logo. |
| `radiusFull` | 999 | Avatares, botão "Nova", FAB de notificação. |

### 2.5 Sombras / Elevação

```dart
// Cartão padrão (branco sobre fundo claro)
shadowCard: BoxShadow(
  color: Color(0x0F16181D), // ~6% preto
  blurRadius: 24,
  offset: Offset(0, 8),
)

// Botão primário (glow rosa sutil)
shadowPrimary: BoxShadow(
  color: Color(0x33EC0B5A), // ~20% primary
  blurRadius: 24,
  offset: Offset(0, 10),
)

// Cartão de saldo (gradiente) — sombra rosa mais forte
shadowBalance: BoxShadow(
  color: Color(0x40EC0B5A),
  blurRadius: 30,
  offset: Offset(0, 14),
)
```

Inputs têm borda 1px `border`, **sem** sombra. Cartões têm sombra suave difusa.

### 2.6 Iconografia

Conjunto **outline, traço fino (~1.8px), cantos arredondados** (estilo Lucide / Feather). Tamanho padrão `20–24px`.

Ícones usados:
- `mail` (envelope) — campo e-mail
- `lock` — campo senha
- `eye` — toggle de senha
- `user` — nome
- `id-card` / `credit-card` — CPF
- `arrow-left` — voltar
- `bell` — notificações (com ponto vermelho)
- `eye` — esconder saldo
- `send` / `navigation` (avião de papel) — Transferir
- `hand-coins` — Cobrar / banner cobrança
- `landmark` (prédio com colunas) — Empréstimo
- `arrow-up-right` — transferência enviada
- `arrow-down-left` — Pix recebido
- `message-square` / `receipt` — pagamento de conta / Cobranças (tab)
- `home` — Início
- `shield` / `shield-check` — segurança ("Protegido com criptografia...")
- `chevron-right` (▶) — indicador de item ativo no menu lateral

---

## 3. Componentes Reutilizáveis

### 3.1 `PrimaryButton`
- Altura: `56px`, largura total (`double.infinity`).
- Fundo: `primary`, texto `onPrimary` 16/700, centralizado.
- Raio: `radiusButton (16)`. Sombra: `shadowPrimary`.
- Estados: pressed → `primaryDark`, escala 0.98; disabled → `primary` 40% opacidade, sem sombra.
- Variante **success** (`Aprovar`): fundo `success`, sem glow rosa (sombra neutra leve).

### 3.2 `SecondaryButton` / `OutlineButton`
- Mesma altura `56px`. Fundo `surface`, borda 1px `border`, texto `textPrimary` 16/700.
- Usado em "Criar conta" (Login) e "Recusar" (Cobranças).

### 3.3 `AppTextField`
- Altura `56px`, fundo `surface`, borda 1px `border`, raio `14`, padding horizontal `16`.
- Ícone leading `iconMuted` (20px) + gap `12`.
- Placeholder `textTertiary 15/400`.
- Trailing opcional (ex: `eye` no campo senha).
- Foco: borda `primary` 1.5px (sem mudar fundo).
- Variante **filled** (Valor / CPF destacado em Transferir e Nova cobrança): fundo `surfaceAlt`, mesma borda.

### 3.4 `AmountField`
- Campo grande de valor: prefixo `R$` em `textTertiary 20/700` + valor `0,00` em `textPrimary 22/700`.
- Fundo `surfaceAlt`, raio 14, altura ~64px.
- Máscara de moeda pt-BR ao digitar.

### 3.5 `FormCard`
- Container branco com `radiusCard (20)`, padding `20`, sombra `shadowCard`.
- Agrupa campos relacionados (ex: bloco "CPF + Valor" em Transferir e Nova cobrança).

### 3.6 `ActionTile` (atalhos da Home)
- Cartão quadrado branco, raio `20`, sombra `shadowCard`, padding `16`.
- Topo: círculo `48px` fundo `primaryLight` com ícone `primary` (22px).
- Base: label `13/600 textPrimary`, centralizado.
- 3 por linha, gap `12`.

### 3.7 `TransactionRow` (movimentações)
- Linha: avatar circular `40px` (ícone direcional) + textos (título 15/700 + subtítulo 12/400) + valor à direita.
- Valor: vermelho/neutro para saída (`- R$ 120,00` em textPrimary), verde para entrada (`+ R$ 45,90` em success).
- Ícones de avatar:
  - Enviada: `arrow-up-right`, fundo `#F1F2F4`.
  - Recebida: `arrow-down-left`, fundo `#D1FAE5`, ícone verde.
  - Pagamento: `message-square`/`receipt`, fundo `#F1F2F4`.
- Divisor 1px `border` entre linhas (dentro de um card branco único).

### 3.8 `StatusBadge`
- Pílula `radiusBadge (8)`, padding `4×8`, texto `12/700`.
- `Pendente`: fundo `#FEF3C7`, texto `#B45309`.
- `Aprovada`: fundo `successBg`, texto `success`.

### 3.9 `Avatar`
- Círculo `radiusFull`. Iniciais centralizadas `14/700`.
- Default: fundo `#F1F2F4`, texto `textSecondary`.
- Destaque: fundo `primaryLight`, texto `primary`.
- Tamanhos: `40` (linhas/topo home), `56` (contatos Transferir).

### 3.10 `BottomNavBar`
- Altura `64px` + safe area. Fundo `surface`, borda superior 1px `border`.
- 4 itens: **Início**, **Transferir**, **Cobranças**, **Empréstimo**.
- Ícone 24px + label 11/600. Ativo: `primary` (ícone preenchido + label). Inativo: `iconMuted`.
- Indicador de seleção: cor (sem pílula de fundo).

### 3.11 `ScreenAppBar`
- Para telas internas (push): botão circular `back` (40px, fundo `#F1F2F4`, ícone `arrow-left`) + título `titleScreen` à direita do botão.
- Para Home: linha de saudação (avatar + "Bem-vinda de volta / Olá, Marina") + sino de notificação à direita.

### 3.12 `StatusBar` (mock)
- Reproduzir barra `9:41` à esquerda + ícones sinal/wifi/bateria à direita. (Em produção real, usar a status bar do sistema; no protótipo a moldura já a inclui.)

### 3.13 `SideMenu` (apenas no mockup de apresentação)
> O painel lateral à esquerda das imagens (lista numerada 01–07 "Lumo · Protótipo · 7 telas") é o **navegador do protótipo da ferramenta de design (Figma-like), NÃO faz parte do app**. **Não implementar** no Flutter. Serve apenas como índice das telas.

---

## 4. Especificação tela a tela

### Tela 01 — Login

**Layout (centralizado verticalmente, padding 24):**
1. Logo: quadrado `64px`, fundo `primary`, raio `18`, ponto branco central (círculo `20px`). Sombra rosa.
2. `Lumo` — `titleBrand` (24/700), centralizado, margem-topo 12.
3. `Seu banco digital` — `caption textSecondary`, centralizado.
4. Espaço 32.
5. Label `E-mail` → `AppTextField` (ícone `mail`, placeholder `voce@email.com`).
6. Label `Senha` → `AppTextField` (ícone `lock`, placeholder `Digite sua senha`, trailing `eye`).
7. `Esqueci minha senha` — `link`, alinhado à **direita**, margem-topo 8.
8. `PrimaryButton` **Entrar** (margem-topo 20).
9. Divisor "ou": linha `border` + texto `ou` (`caption textTertiary`) centralizado.
10. `SecondaryButton` **Criar conta** → navega para Cadastro.
11. Rodapé: ícone `shield` + `Protegido com criptografia de ponta a ponta` (`caption textTertiary`, centralizado), ancorado na base.

**Ações:** Entrar → Home. Criar conta → Cadastro. Esqueci minha senha → (no protótipo, snackbar ou no-op).

---

### Tela 02 — Cadastro ("Criar sua conta")

**AppBar:** botão `back` (volta ao Login).
**Cabeçalho:** `Criar sua conta` (titleScreen) + `Leva menos de 2 minutos.` (caption).

**Campos (gap 20, label + field):**
1. `Nome completo` — ícone `user`, placeholder `Como no documento`.
2. `E-mail` — ícone `mail`, placeholder `voce@email.com`.
3. `CPF` — ícone `id-card`, placeholder `000.000.000-00` (máscara CPF).
4. `Senha` — ícone `lock`, placeholder `Mínimo 8 caracteres`, trailing `eye`.
5. **Checkbox** (quadrado `radius 6`, borda `border`, marcado = `primary`) + texto: `Li e aceito os ` **`Termos de uso`** ` e a Política de privacidade.` (links em `primary`, restante `caption textSecondary`).
6. `PrimaryButton` **Cadastrar** (margem-topo 24).
7. Centralizado abaixo: `Já tem conta? ` **`Entrar`** (link `primary`) → volta ao Login.

**Validação (UI only):** marcar campos vazios em vermelho ao tentar enviar; checkbox obrigatório. Cadastrar → Home (ou tela de sucesso simulada).

---

### Tela 03 — Home

**Header (sem app bar tradicional):**
- Avatar `MA` (40px) + coluna: `Bem-vinda de volta` (caption textSecondary) / `Olá, Marina` (titleM 17/700).
- À direita: botão circular branco `48px` com `bell` + ponto vermelho (notificação).

**Cartão de Saldo (gradiente):**
- Container largura total, raio `20`, padding `20`, gradiente `primary → primaryDark` (135°), sombra `shadowBalance`.
- Decoração: círculos translúcidos brancos no canto direito (overlay sutil, opacidade ~8–12%).
- `Saldo disponível` (white 13/600, ~80% opacidade) + ícone `eye` (toggle ocultar) à direita.
- `R$ 1.250,00` — `headlineLarge` em branco.
- Chip pílula: fundo branco 18% + `Conta corrente · ••••2841` (white 12/600), raio full.

**Atalhos (3 `ActionTile`):** `Transferir` (send), `Cobrar` (hand-coins), `Empréstimo` (landmark). Tap → respectivas telas.

**Movimentações:**
- Linha de seção: `ÚLTIMAS MOVIMENTAÇÕES` (overline) à esquerda + `Ver tudo` (link) à direita.
- Card branco único com 3 `TransactionRow` + divisores:
  1. `Transferência enviada` · `Para Bruno Carvalho · Hoje · 09:12` · `- R$ 120,00`.
  2. `Pix recebido` · `De Helena Souza · Ontem · 18:40` · `+ R$ 45,90` (verde).
  3. `Pagamento de conta` · `Energia elétrica · 22 jun · 14:03` · `- R$ 134,70`.

**Bottom nav:** Início ativo.

---

### Tela 04 — Transferir

**AppBar:** `back` + `Transferir`.

**Seção contatos:**
- `ENVIAR PARA` (overline).
- Row horizontal de 3 contatos (Avatar destaque `56px` + nome abaixo `caption`): `BC Bruno C.`, `HS Helena S.`, `DM Diego M.`. (Tap preenche o CPF do destinatário.) Scrollável horizontalmente.

**`FormCard`:**
- Label `CPF do destinatário` → `AppTextField` filled, ícone `id-card`, placeholder `000.000.000-00`.
- Label `Valor` → `AmountField` `R$ 0,00`.
- Rodapé do card: ícone `wallet` + `Saldo disponível: R$ 1.250,00` (caption textTertiary).

**CTA:** `PrimaryButton` **Transferir** (fora do card, margem-topo 24).

**Ação:** Transferir → modal/tela de sucesso simulada ("Transferência realizada").

**Bottom nav:** Transferir ativo.

---

### Tela 05 — Cobranças

**AppBar (linha):** `Cobranças` (titleScreen) à esquerda + botão pílula **`Nova`** (fundo `primary`, texto branco 14/700, raio full, padding 8×16) à direita → navega para Nova cobrança.

**Tabs (segmented):**
- Container fundo `surfaceAlt`, raio `12`, padding 4.
- Duas abas: **Recebidas** (ativa: fundo branco, sombra leve, texto textPrimary 600) / **Enviadas** (inativa: texto textTertiary).

**Lista de cobranças (cards brancos, raio 20, sombra, gap 16):**

*Card com ações (Pendente):*
- Linha: Avatar (iniciais) + coluna (Nome titleM / CPF formatado caption) + à direita coluna (valor `titleM 17/700` + `StatusBadge Pendente`).
- Linha de botões: `OutlineButton` **Recusar** (50%) + gap + `PrimaryButton`(success) **Aprovar** (50%), altura ~48px.
- Conteúdos:
  1. `Bruno Carvalho` · `182.557.640-08` · `R$ 120,00` · Pendente.
  2. `Helena Souza` · `305.119.872-44` · `R$ 45,90` · Pendente.

*Card resolvido (sem botões):*
  3. `Diego Martins` · `774.203.158-90` · `R$ 300,00` · badge **Aprovada** (verde).

**Ações:** Aprovar/Recusar → atualiza badge localmente (estado em memória) e remove botões. Nova → tela 06.

**Bottom nav:** Cobranças ativo.

---

### Tela 06 — Nova cobrança ("Criar cobrança")

**AppBar:** `back` + `Nova cobrança`.

**Banner informativo:**
- Container fundo `primarySoft`, raio `16`, padding `16`.
- Ícone `hand-coins` (primary) + texto: `Gere uma cobrança e envie por Pix pra quem precisa te pagar.` (`caption`, texto `#9B2A4D`/primary-escuro sobre fundo rosa claro).

**`FormCard`:**
- Label `CPF de quem vai pagar` → `AppTextField` filled, ícone `id-card`, placeholder `000.000.000-00`.
- Label `Valor da cobrança` → `AmountField` `R$ 0,00`.

**CTA:** `PrimaryButton` **Cobrar** (margem-topo 24).

**Ação:** Cobrar → tela/modal de sucesso (ex.: "Cobrança criada · compartilhar Pix") e volta para Cobranças.

**Bottom nav:** Cobranças ativo (continua no contexto de cobranças).

---

### Tela 07 — Empréstimo

**AppBar:** `back` + `Empréstimo`.

**Seletor de valor (centralizado):**
- `Quanto você precisa?` (caption textSecondary, centralizado).
- `R$ 5.000` — `displayLarge` (40/700), centralizado (reflete o chip selecionado).
- `Crédito pré-aprovado · até R$ 10.000` (caption textTertiary, centralizado).

**Chips de valor:**
- Row de 4 chips (`radiusChip 12`, altura ~44, borda `border`): `R$ 1.000`, `R$ 3.000`, **`R$ 5.000`** (selecionado: fundo `primary`, texto branco), `R$ 10.000`.
- Selecionar atualiza o valor grande e a simulação abaixo.

**Card de simulação (`FormCard`, 3 linhas com divisores):**
| Esquerda (textSecondary) | Direita (textPrimary 700) |
|---|---|
| Taxa de juros | 2,9% a.m. |
| Parcelas | 12x de R$ 499,32 |
| 1ª parcela | em 30 dias |

> A simulação (parcela) deve recalcular conforme o valor selecionado. Fórmula de prestação (Price): `PMT = PV · i / (1 − (1+i)^−n)`, com `i = 0,029`, `n = 12`. (Pode usar valores mockados por chip se preferir simplicidade.)

**CTA:** `PrimaryButton` **Solicitar empréstimo** (margem-topo 24).

**Rodapé:** ícone `shield` + `Sujeito a análise de crédito · CET 38,4% a.a.` (caption textTertiary, centralizado).

**Ação:** Solicitar → sucesso simulado.

**Bottom nav:** Empréstimo ativo.

---

## 5. Navegação e estado

### 5.1 Estrutura
- `MaterialApp` com rotas nomeadas.
- **Shell com `BottomNavBar`** envolvendo: Home, Transferir, Cobranças, Empréstimo (4 tabs). Use `IndexedStack` ou `go_router` `StatefulShellRoute` para preservar estado entre abas.
- Login e Cadastro **fora** do shell (sem bottom bar).
- Nova cobrança é **push** sobre o shell (mostra back, mantém tab Cobranças ativa).

### 5.2 Gerenciamento de estado
- Como é só frontend, usar estado local simples: `setState` / `ValueNotifier` / `Provider` leve.
- Dados mockados em um `mock_data.dart` (usuário "Marina", saldo, contatos, movimentações, cobranças).
- Estado mutável necessário:
  - Toggle de visibilidade de senha (Login, Cadastro).
  - Toggle de ocultar saldo (Home) → exibe `R$ ••••••`.
  - Tab selecionada em Cobranças (Recebidas/Enviadas).
  - Status das cobranças (Pendente → Aprovada/Recusada).
  - Chip de empréstimo selecionado.
  - Aba ativa da bottom bar.

### 5.3 Feedback de sucesso (protótipo)
Conforme nota do mockup ("ver as confirmações de sucesso"), cada CTA principal deve mostrar um **bottom sheet / dialog de sucesso** com:
- Ícone de check em círculo `primary` ou `success`.
- Título (ex.: "Transferência realizada!").
- Botão "Concluir" que retorna à Home.

---

## 6. Detalhes de implementação Flutter

### 6.1 Tema (`ThemeData`)
```dart
final theme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFFEDEFF2),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFEC0B5A),
    primary: const Color(0xFFEC0B5A),
    surface: Colors.white,
    background: const Color(0xFFEDEFF2),
  ),
  fontFamily: 'Inter',
  // sobrescrever textTheme, inputDecorationTheme, etc.
);
```

### 6.2 Pacotes sugeridos
- `intl` — formatação de moeda/data pt-BR (registrar locale).
- `google_fonts` (Inter) ou fonte empacotada em `assets/fonts`.
- `lucide_icons` ou `flutter_feather_icons` para o conjunto outline (ou SVGs próprios via `flutter_svg`).
- `go_router` (opcional) para navegação declarativa com shell.
- `mask_text_input_formatter` — máscaras de CPF e moeda.

### 6.3 Estrutura de pastas sugerida
```
lib/
  main.dart
  theme/
    app_colors.dart
    app_typography.dart
    app_theme.dart
  data/
    mock_data.dart
    models/ (user, transaction, charge, contact)
  widgets/
    primary_button.dart
    secondary_button.dart
    app_text_field.dart
    amount_field.dart
    form_card.dart
    action_tile.dart
    transaction_row.dart
    status_badge.dart
    avatar.dart
    bottom_nav_bar.dart
    screen_app_bar.dart
    success_sheet.dart
  screens/
    login_screen.dart
    signup_screen.dart
    home_screen.dart
    transfer_screen.dart
    charges_screen.dart
    new_charge_screen.dart
    loan_screen.dart
  shell/
    main_shell.dart
```

### 6.4 Responsividade e acessibilidade
- Conteúdo dentro de `SafeArea`; CTAs respeitam o home indicator inferior.
- Telas com formulários: `SingleChildScrollView` para evitar overflow com teclado aberto; CTA pode "subir" com o teclado ou ficar fixo.
- Toques mínimos `48×48`. Contraste AA para texto sobre primária (branco) e textos cinza.
- `Semantics` em ícones-ação (back, sino, eye).
- Suporte a *text scaling* (não fixar alturas que cortem texto; usar min-height).

### 6.5 Microinterações
- Botões: escala `0.98` + leve mudança de cor no pressed (`AnimatedScale` / `InkWell` custom).
- Cartão de saldo: animação de fade ao ocultar/mostrar valor.
- Tabs Cobranças: `AnimatedContainer` deslizando o indicador branco.
- Chips empréstimo: transição de cor `200ms easeOut`; valor grande com `AnimatedSwitcher`.
- Transições de tela: `300ms` slide (push) / fade (tabs).

---

## 7. Conteúdo / dados mockados

```dart
// Usuário
name: "Marina", initials: "MA"
balance: 1250.00, accountMask: "Conta corrente · ••••2841"

// Contatos (Transferir)
[ {BC, "Bruno C."}, {HS, "Helena S."}, {DM, "Diego M."} ]

// Movimentações (Home)
[
  {tipo: enviada, titulo: "Transferência enviada", sub: "Para Bruno Carvalho · Hoje · 09:12", valor: -120.00},
  {tipo: recebida, titulo: "Pix recebido", sub: "De Helena Souza · Ontem · 18:40", valor: +45.90},
  {tipo: pagamento, titulo: "Pagamento de conta", sub: "Energia elétrica · 22 jun · 14:03", valor: -134.70},
]

// Cobranças (Recebidas)
[
  {nome: "Bruno Carvalho", cpf: "182.557.640-08", valor: 120.00, status: pendente},
  {nome: "Helena Souza",   cpf: "305.119.872-44", valor: 45.90,  status: pendente},
  {nome: "Diego Martins",  cpf: "774.203.158-90", valor: 300.00, status: aprovada},
]

// Empréstimo
opcoes: [1000, 3000, 5000, 10000], selecionado: 5000
taxaMes: 0.029, parcelas: 12, primeiraParcelaDias: 30
preAprovadoAte: 10000, cet: "38,4% a.a."
```

---

## 8. Checklist de fidelidade (Definition of Done)

- [ ] Cor primária `#EC0B5A` aplicada em CTAs, logo, ícones ativos, gradiente do saldo.
- [ ] Fundo geral `#EDEFF2`; cartões brancos com sombra suave difusa.
- [ ] Tipografia Inter com pesos e tamanhos da seção 2.2; valores monetários pt-BR.
- [ ] Raios: inputs 14, cards 20, botões 16, badges 8, avatares/chips redondos.
- [ ] 7 telas implementadas conforme seção 4 (sem o menu lateral do mockup).
- [ ] Bottom nav de 4 itens com estado ativo correto por tela.
- [ ] Estados interativos: toggle senha, ocultar saldo, tabs cobranças, status cobrança, chips empréstimo.
- [ ] Sheets de sucesso ao acionar CTAs principais.
- [ ] Máscaras de CPF e moeda funcionando.
- [ ] SafeArea, scroll com teclado e contraste de acessibilidade verificados.
- [ ] Microinterações (pressed, tabs, chips) presentes.

---

*Documento gerado a partir das 7 telas de referência do protótipo Lumo. Implementação: somente frontend Flutter.*
