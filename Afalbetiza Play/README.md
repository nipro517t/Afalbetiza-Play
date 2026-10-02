# Afalbetiza Play

Coletânea de minigames de alfabetização em **Godot 4.7**, baseada no
Game Design Document do projeto. O foco aqui foi montar uma arquitetura
que não vira bagunça conforme os jogos crescem — em vez de cada
minijogo repetir a mesma lógica (pausar, mostrar recompensa, tocar som),
tudo isso mora num lugar só e cada jogo só cuida da própria mecânica.

Os 3 minijogos abaixo estão na **versão base**: mecânica funcionando de
verdade, mas com formas simples (retângulos, botões de texto) no lugar
da arte final — troque os assets quando estiverem prontos, sem precisar
mexer na lógica.

## Estrutura de pastas

```
assets/
  backgrounds/
	fundo_menu.svg          -> fundo do menu principal (céu, sol, nuvens, letrinhas flutuando)
	fundo_estourador.svg    -> fundo do Estourador de Sílabas (céu + bolhas decorativas)
	fundo_construtor.svg    -> fundo do Construtor de Palavras (chão + blocos de letra nos cantos)
	fundo_pista.svg         -> fundo da Pista das Letras (céu + colinas + árvores nas bordas)
  imagens/    -> 1 imagem por palavra dos bancos de Estourador/Construtor (ver seção "Imagens")
  fonts/, icon.svg, setas.png, balao.png
scenes/
  MenuPrincipal.tscn
  ui/
	TelaRecompensa.tscn      -> tela de fim de jogo (estrelas + botões), reaproveitada por todo minijogo
	TelaNomeJogador.tscn     -> abas "Perfil Existente" / "Novo Jogador" antes do menu (cena inicial do projeto)
	TelaRanking.tscn         -> lista nome/turma/pontos de quem já jogou, do maior pro menor
  jogos/
	PistaLetras.tscn
	EstouradorSilabas.tscn
	Balao.tscn                -> sub-cena da bolha (classe Balao), instanciada em tempo real pelo Estourador
	ConstrutorPalavras.tscn
scripts/
  MenuPrincipal.gd
  core/
	catalogo.gd               -> autoload "Catalogo": lista única de jogos que existem no app
	audio_manager.gd          -> autoload "AudioManager": ponto único por onde todo som passa
	minigame_base.gd          -> classe MinigameBase: o que é igual em todo minijogo
	perfil_jogador.gd         -> autoload "PerfilJogador": nome/turma atual + placar salvo em disco
  ui/
	tela_recompensa.gd
	tela_nome_jogador.gd
	tela_ranking.gd
  jogos/
	pista_letras.gd
	estourador_silabas.gd
	balao.gd
	construtor_palavras.gd
project.godot
PROGRESSO.md  -> documento de continuação entre sessões/contas (sempre atualizar)
```

## A ideia por trás da organização

**1. Uma lista de jogos só, em `Catalogo` (autoload).**
O menu não guarda mais a lista de jogos "na mão" — ele lê de
`Catalogo.jogos`. Pra adicionar um minijogo novo, você cadastra ele *só
ali* (nome, cena, imagem do card) e o menu já aparece atualizado. Isso
evita o problema clássico de um jogo existir mas o menu não saber, ou
vice-versa.

**2. Todo minijogo herda de `MinigameBase`, não de `Control`.**
Em vez de cada minijogo (`PistaLetras.gd`, `EstouradorSilabas.gd`,
`ConstrutorPalavras.gd`) repetir "pausar a árvore, mostrar tela de fim
de jogo, tocar som de acerto/erro", isso tudo mora uma vez só em
`scripts/core/minigame_base.gd`. Cada jogo faz:

```gdscript
extends MinigameBase
```

e só implementa `_iniciar()` (o que acontece ao abrir o jogo) e chama
`registrar_acerto()`, `registrar_erro()` e `concluir(estrelas)` durante a
partida. A tela de recompensa, por exemplo, aparece sozinha — nenhum
minijogo instancia ela na mão.

**3. `AudioManager` é o único lugar que sabe tocar som.**
Hoje ele só imprime no console (`[AudioManager] tocaria som: ...`)
porque ainda não há áudios prontos. Quando as locuções e efeitos
sonoros estiverem gravados, é só preencher as funções desse arquivo —
nenhum minijogo precisa mudar.

**4. Poucas cenas, cada uma com um papel bem definido.**
No total: o menu, a tela de recompensa (compartilhada), 3 minijogos e 1
sub-cena (a bolha do Estourador, que precisa ser instanciada várias
vezes em tempo real). Nada de dezenas de cenas soltas — cada minijogo
é 1 cena só.

## Os minijogos (versão base)

### Pista das Letras
Arraste o carrinho (`Carro`) ao longo de uma pista (`Path2D` +
`PathFollow2D`) até o fim. Puxar pra trás não anda pra trás; soltar
antes do fim volta o carrinho pro início. A pista agora é uma curva
simples em formato de "tenda" desenhada por código
(`pista_letras.gd`) — troque os pontos por um traçado real de letra
quando tiver a arte.

### Estourador de Sílabas
Bolhas com sílabas sobem pela tela; toque na sílaba certa pra montar a
palavra-alvo mostrada no topo. Errar tira uma de 3 "vidas" (sem
punição pesada). O banco de palavras (`_banco_palavras` em
`estourador_silabas.gd`) tem 15 palavras — é só acrescentar mais
dicionários no mesmo formato (`palavra`, `prefixo`, `correta`,
`erradas`).

- **Balões sempre nascem um de cada vez** (testamos nascer em grupo e
  ficou difícil demais pra criança — foi revertido). O que ficou foi
  só deixar o intervalo entre balões mais curto: `wait_time` do
  `TimerSpawn`, na cena, caiu de `2.73` pra `1.82` (menos 1/3 do
  tempo) — aparece balão novo com mais frequência, mas sempre 1 por
  vez.

- **Sorteio sem repetição:** a cada rodada, `_gerar_ordem_sorteada()`
  embaralha os índices do banco inteiro (`_ordem_indices`) e o jogo
  percorre essa ordem — ou seja, passa por *todas* as palavras antes
  de acabar, nunca repetindo uma antes de esgotar as outras.
- **Fim de jogo:** só existem dois desfechos agora, os dois levando
  pra `TelaRecompensa` (nunca reinicia a rodada "escondido"):
  - **Vitória** — completou todas as palavras do banco com pelo
    menos 1 vida sobrando: 3, 2 ou 1 estrelas conforme as vidas
    restantes.
  - **Derrota** — zerou as 3 vidas antes de terminar: vai pra
    `TelaRecompensa` com 1 estrela (`_finalizar_por_derrota()`).

**Contrato da bolha (`Balao.tscn` / `balao.gd`):** a classe `Balao`
só cuida da aparência (sorteia uma cor, toca a animação) e do toque —
quem sobe a bolha e decide quando ela morre é sempre o
`estourador_silabas.gd`. Pra isso, `Balao` expõe:
- `configurar(silaba: String)` — chamado pelo minijogo logo após
  `instantiate()`, define só o texto exibido na bolha.
- `obter_silaba() -> String` — devolve a sílaba escrita na bolha.
- `signal tocada(balao: Balao)` — emitido quando a criança aperta a
  bolha; o minijogo escuta esse sinal.

**Certo/errado é decidido no toque, não no nascimento.** O balão
**não** sabe se é "a resposta certa" — ele só carrega a sílaba
escrita nele. Quem decide é `estourador_silabas.gd`, comparando a
sílaba do balão tocado com a palavra que está valendo **naquele
momento** (`_item_atual()`). Isso evita o bug de um balão nascer
"certo" (ou "errado") pra uma palavra, a palavra mudar enquanto ele
ainda está subindo, e ele continuar valendo ponto pra uma palavra que
já nem está mais na tela. Ao vencer ou perder a rodada,
`_encerrar_rodada()` remove qualquer balão que ainda esteja subindo,
pra não sobrar nada tocável depois do jogo já ter acabado.

**Velocidade de subida:** `VELOCIDADE_SUBIDA` em
`estourador_silabas.gd` — hoje `120.0` (dobrada a partir do valor
original de `60.0`).

### Construtor de Palavras
Toque nas sílabas embaralhadas na ordem certa pra formar a palavra
mostrada. A versão base assume palavras de 2 sílabas (2 espaços fixos
na cena) — pra palavras maiores, adicione mais `Label`s dentro de
`Slots` na cena.

- **Vidas e tentativa/erro**, igual ao Estourador de Sílabas: 3 vidas
  compartilhadas pra rodada inteira (não por palavra). Errar a ordem
  limpa os espaços e deixa tentar de novo a mesma palavra; zerar as 3
  vidas manda direto pra tela de recompensa com 1 estrela (derrota).
  Terminar todas as palavras com vida sobrando é vitória: 3, 2 ou 1
  estrelas conforme quantas vidas restaram.
- **Sorteio sem repetição:** igual ao Estourador de Sílabas,
  `_gerar_ordem_sorteada()` embaralha os índices do banco inteiro a
  cada rodada e o jogo percorre essa ordem — passa por todas as
  palavras antes de repetir alguma, nunca mais sequencial.

## Imagens dos minijogos (via Inspector)

`ConstrutorPalavras.tscn` e `EstouradorSilabas.tscn` agora têm um
campo exportado **"Imagens Das Palavras"**, visível no Inspector ao
selecionar o nó raiz da cena (`ConstrutorPalavras` / `EstouradorSilabas`).
É uma lista de `Texture2D` — arraste as imagens (PNG, SVG etc.) direto
pra lá.

- **A posição na lista é o que liga a imagem à palavra:** o item na
  posição 0 da lista é a imagem da palavra na posição 0 de
  `_banco_palavras` dentro do script (`GATO`), posição 1 é `BOLA`,
  posição 2 é `FOCA`, e assim por diante — a mesma ordem em que as
  palavras aparecem no array do script, **não** a ordem sorteada em
  que elas são jogadas.
- Cada jogo tem seu próprio `_banco_palavras` e sua própria lista de
  imagens — hoje os dois têm as mesmas 15 palavras na mesma ordem,
  mas são independentes (dá pra usar a mesma arte nos dois, é só
  preencher os dois Inspectors).
- Pode deixar slots vazios: se não houver imagem cadastrada pra um
  índice, o jogo simplesmente não mostra imagem nenhuma pra aquela
  palavra (sem quadrado vazio ou erro).
- A imagem some/aparece automaticamente ao trocar de palavra durante
  o jogo — não precisa mexer em código depois de preencher a lista.
- Cada cena ganhou um nó `TextureRect` (`ImagemObjeto` no Construtor,
  `ImagemPalavra` no Estourador) com posição/tamanho de exemplo — fique
  à vontade pra mover, redimensionar ou trocar o `stretch_mode` dele
  direto no editor conforme a arte final.

## Fundos dos minijogos

Os 3 minijogos tinham um `ColorRect` de cor lisa no lugar de fundo
(placeholder). Agora cada um tem um fundo de verdade — SVG desenhado no
mesmo estilo do `fundo_menu.svg` (céu em gradiente, sol, nuvens),
trocando só o tema/cor de acordo com o jogo:

- **Estourador de Sílabas** (`fundo_estourador.svg`) — céu azul claro
  com bolhas decorativas nos cantos, combinando com as bolhas de
  verdade que sobem durante o jogo.
- **Construtor de Palavras** (`fundo_construtor.svg`) — chão terroso
  (tom de madeira/oficina) com blocos de letra decorativos nos dois
  cantos inferiores, reforçando a ideia de "montar" algo.
- **Pista das Letras** (`fundo_pista.svg`) — céu + colinas verdes
  (igual ao menu) com uma arvorezinha decorativa em cada canto inferior.

Em todos os três, o nó continua se chamando `Fundo` (só trocou de
`ColorRect` pra `TextureRect`) — nenhum script referenciava esse nó
diretamente, então a troca não exige nenhuma outra mudança. As
decorações de cada SVG ficam deliberadamente nas bordas/cantos, longe
do centro da tela, onde moram o texto e os botões de cada jogo — então
dá pra trocar o fundo por uma arte final depois sem se preocupar em
"tampar" nada importante.

Pra trocar por uma arte final mais pra frente: é só substituir o
arquivo em `assets/backgrounds/` (mesmo nome) ou apontar o `texture`
do nó `Fundo`, no Inspector, pra uma imagem nova — não precisa mexer
em nenhum script.

## Como abrir

1. Instale o [Godot 4.7](https://godotengine.org/download).
2. Abra a pasta pelo Project Manager (arquivo `project.godot`).
3. Rode com F5 — cai direto no menu, e o carrossel já lista os 3 jogos.

## Changelog (Estourador de Sílabas)

- Banco de palavras expandido de 4 para 15 entradas (e corrigida uma
  entrada quebrada que tinha `"AM"` / `"__ OR"` — virou `"AMOR"`).
- Sorteio de palavras agora é aleatório e sem repetição (antes era
  sequencial, na ordem do array).
- Zerar as vidas agora encerra o minijogo direto na tela de
  recompensa (1 estrela) em vez de reiniciar a rodada em segundo
  plano — só existe "vitória" e "derrota", os dois via `concluir()`.
- **Corrigido `Balao.tscn` / `balao.gd`**, que ainda estava na versão
  antiga e não batia com o que `estourador_silabas.gd` espera dele
  (era a causa dos erros ao rodar):
  - Adicionado `configurar(silaba, eh_correta)` e o sinal
    `tocada(balao, eh_correta)` — antes não existiam, então
    `balao.configurar(...)` e `balao.tocada.connect(...)` no
    minijogo falhavam.
  - Adicionado `class_name Balao` e corrigido o tipo do parâmetro em
    `_on_balao_tocada` (estava `Button`, deveria ser `Balao`) — esse
    descompasso de tipos era outra fonte de erro em tempo de
    execução.
  - Removida a movimentação própria da bolha (`_process` com
    `position.y -= 150 * delta` e o antigo sinal `bolha_estourada`
    via `_on_input_event`, que nem chegava a ser chamado nesse tipo
    de nó): quem sobe e remove a bolha da tela é só o
    `estourador_silabas.gd`, evitando a bolha "andar" duas vezes ao
    mesmo tempo.
  - Removida a conexão duplicada do botão (existia uma no `.tscn` e
    outra sendo feita por script) e o texto de placeholder `"ggg"`
    do botão.
  - O `Label` interno ficou oculto (o próprio `Button`, com a fonte
    pixelada, já mostra a sílaba) — evita o texto duplicado por cima.

## Changelog (Construtor de Palavras + Imagens)

- **Construtor de Palavras agora sorteia a ordem das palavras**, igual
  ao Estourador de Sílabas (antes era sequencial, sempre `GATO` →
  `BOLA` → `FOCA`... na ordem do array).
- **Suporte a imagem por palavra, configurável pelo Inspector**, nos
  dois jogos (Construtor de Palavras e Estourador de Sílabas): novo
  campo exportado `imagens_das_palavras` (`Array[Texture2D]`) e um novo
  nó `TextureRect` em cada cena (`ImagemObjeto` / `ImagemPalavra`).
  Ver seção "Imagens dos minijogos" acima pra detalhes de como
  preencher.

## Changelog (correção das imagens MALA/VACA)

Ao revisar as duas cenas depois de preenchidas, `mala.png` e
`vaca.png` (posições 6 e 7 de `imagens_das_palavras`, nos dois jogos)
estavam referenciadas de um jeito frágil: em vez de um `ext_resource`
normal apontando pro arquivo em `assets/imagens/`, o `.tscn` apontava
direto pro cache interno do Godot
(`res://.godot/imported/mala.png-<hash>.ctex`). Isso costuma
acontecer quando se arrasta a textura pro slot do Inspector a partir
de uma aba/lugar errado no editor.

O problema: a pasta `.godot/` é gerada automaticamente e está no
`.gitignore` do projeto — ou seja, **não é enviada em zips nem
versionada**. Funcionava só na máquina onde o cache já existia com
aquele hash exato; em qualquer outra (inclusive ao reabrir este zip
do zero), Godot não acha o arquivo e as imagens de `MALA` e `VACA`
ficam sem textura.

Corrigido nos dois arquivos (`EstouradorSilabas.tscn` e
`ConstrutorPalavras.tscn`): `mala.png` e `vaca.png` agora são
`ext_resource` apontando pro arquivo fonte em `assets/imagens/`
(usando o `uid` do respectivo `.import`), igual às outras 13 imagens.
Testei a lista completa das 15 posições contra o `_banco_palavras` de
cada script — todas batem certinho agora.

## Changelog (vida no Construtor + ritmo do Estourador ajustado)

- **Construtor de Palavras ganhou vidas e tentativa/erro**, igual ao
  Estourador de Sílabas: 3 vidas compartilhadas pra rodada inteira
  (não por palavra). Errar limpa os espaços e deixa tentar de novo a
  MESMA palavra; zerar as vidas manda direto pra tela de recompensa
  (derrota, 1 estrela). Terminar todas as palavras com vida sobrando é
  vitória: 3, 2 ou 1 estrelas conforme quantas vidas restaram (antes
  era sempre 3 estrelas fixas, e errar nunca tinha consequência).
  Cena ganhou o mesmo indicador visual (`Vidas` com 3 `ColorRect`) que
  já existia no Estourador.
- **Balões em grupo (2 ou 3 juntos) revertido** — deixava difícil
  demais pra criança. O que ficou: `wait_time` do `TimerSpawn`
  (`EstouradorSilabas.tscn`) caiu de `2.73` pra `1.82` (menos 1/3 do
  tempo), então balão novo aparece mais rápido, mas sempre 1 por vez,
  como era originalmente.

## Changelog (correção do balão "certo por engano" + velocidade)

- **Corrigido bug em que um balão podia valer ponto (ou tirar vida)
  pra uma palavra que já não estava mais na tela.** Antes, `Balao`
  decidia se era "certo" ou "errado" no momento em que nascia
  (`configurar(silaba, eh_correta)`) e guardava isso pra sempre; se a
  palavra-alvo mudasse enquanto aquele balão específico ainda estava
  subindo, ele continuava com a marcação antiga.
  - `balao.gd`: o balão não recebe mais `eh_correta` — só a sílaba
    (`configurar(silaba)`), exposta via `obter_silaba()`. O sinal
    virou `tocada(balao)`, sem o booleano.
  - `estourador_silabas.gd`: `_on_balao_tocada()` agora compara a
    sílaba do balão tocado com `_item_atual()["correta"]` — ou seja,
    com a palavra que está valendo **no momento do toque**, sempre
    atualizada.
  - Vencer a rodada agora também chama `_encerrar_rodada()` (antes só
    a derrota fazia isso), removendo qualquer balão que ainda esteja
    subindo — evita balão solto tocável depois do jogo já ter
    terminado.
- **Velocidade dos balões dobrada** (`VELOCIDADE_SUBIDA`: `60.0` →
  `120.0`).

## Perfil da criança, pontos e ranking (persistente)

Antes de cair no menu, o app agora sempre passa por uma tela de
identificação (`TelaNomeJogador.tscn` / `tela_nome_jogador.gd`) — é a
cena inicial do projeto (`run/main_scene` no `project.godot`). Sem
isso, `PerfilJogador` não sabe pra quem salvar os pontos.

- **Autoload: `PerfilJogador`** (`scripts/core/perfil_jogador.gd`).
  Guarda `nome_atual` / `turma_atual` (quem está jogando agora) e o
  placar de toda criança que já jogou nesse aparelho.
- **Persistência de verdade, não só em memória:** os dados vão pra
  `user://perfis_jogadores.json` via `FileAccess`/`JSON.stringify`.
  `user://` é a pasta de dados do próprio Godot pro projeto — sobrevive
  a fechar o app, reiniciar o aparelho etc. (No Windows fica em algo
  como `%APPDATA%/Godot/app_userdata/Afalbetiza Play/`; no Android, na
  pasta privada do app.) Esse arquivo é lido uma vez no `_ready()` do
  autoload e regravado a cada ponto novo salvo.
- **Nenhum minijogo precisa saber que isso existe.** `MinigameBase.
  concluir()` já chama `PerfilJogador.adicionar_pontos(scene_file_path,
  pontos)` sozinho, reaproveitando a variável `pontos` que cada jogo já
  vinha somando com `registrar_acerto()`. `scene_file_path` identifica
  de qual minijogo veio aquele ponto (dá pra ver quanto cada criança
  fez em cada jogo, não só o total).
- **Chave da criança = nome + turma** (`"nome|turma"`, sem diferenciar
  maiúsculas/minúsculas): duas crianças com o mesmo nome em turmas
  diferentes não se misturam; a mesma criança jogando de novo continua
  somando em cima do placar antigo, em vez de criar um perfil duplicado.

### Turma/série: sempre dropdown, nunca texto livre

`TURMAS_DISPONIVEIS`, em `scripts/core/perfil_jogador.gd`, é a lista
fixa que alimenta o dropdown (`OptionButton`) na tela de novo jogador
— hoje: Maternal I, Maternal II, Jardim I, Jardim II, 1º Ano, 2º Ano,
3º Ano. A criança nunca mais digita a turma: escolhe da lista. Isso
evita "3o ano" / "3º Ano " / "terceiro ano" virarem turmas diferentes
no banco (o que quebraria tanto o agrupamento de perfil quanto o
filtro do Ranking). Pra mudar as opções (nome da escola, outras
séries), edite só essa constante.

### Tela de identificação: perfil existente ou novo jogador

`TelaNomeJogador.tscn` agora é um `TabContainer` com duas abas:

- **"Perfil Existente"** — lista (via `PerfilJogador.
  obter_lista_perfis()`) todo perfil já criado nesse aparelho como um
  botão "Nome — Turma"; um toque já loga esse perfil e cai no menu,
  sem digitar nada de novo.
- **"Novo Jogador"** — campo de nome + dropdown de turma (ver acima) +
  botão "COMEÇAR", pra quem ainda não tem perfil nesse aparelho.

Essa tela é usada nos dois pontos de entrada: ao abrir o app pela
primeira vez na sessão, e ao apertar o botão **"TROCAR"** no menu
principal. Em ambos os casos, se já existir pelo menos um perfil
salvo, a aba "Perfil Existente" abre primeiro sozinha; se o aparelho
é novo (zero perfis), abre direto em "Novo Jogador".

O menu também mostra "Jogando como: NOME (TURMA)" no canto, só pra
confirmar visualmente quem tá valendo ponto no momento.

### Tela de Ranking com filtro por turma

`TelaRanking.tscn` / `tela_ranking.gd`, acessível pelo botão "RANKING"
no menu: lista todo mundo que já jogou, ordenado do maior pro menor
total de pontos, mostrando posição, nome, turma e pontos. Lê tudo de
`PerfilJogador.obter_ranking()` — a tela em si não guarda nada.

Um dropdown (`FiltroTurma`) no topo deixa filtrar por turma: "Todas as
turmas" (padrão) + uma opção por turma que já tem alguém no ranking
(gerado dos dados reais, não da lista fixa — não aparece turma vazia
no filtro). Com um filtro escolhido, a posição (1º, 2º...) passa a ser
relativa só àquela turma, não ao ranking geral.

## Changelog (fundos dos minijogos)

- Os 3 minijogos ganharam fundo de verdade (SVG, mesmo estilo visual
  do menu) no lugar do `ColorRect` de cor lisa. Ver seção "Fundos dos
  minijogos" acima.
- Corrigido um item desatualizado nesta lista de pendências: ela ainda
  dizia "nada é salvo entre sessões", mas a seção "Perfil da criança,
  pontos e ranking" (acima) já documentava `PerfilJogador` salvando
  pontos em disco — a sessão que implementou isso não tinha voltado
  aqui pra atualizar esse item.

## O que falta (de propósito, pra vocês decidirem o rumo)

- Arte final de cada jogo (carrinho, bolhas, ícones dos cards no
  `Catalogo`) — os fundos (céu/cenário) já têm uma versão de verdade
  (ver "Fundos dos minijogos"), mas os elementos *dentro* de cada jogo
  (carrinho, bolha, botões) ainda são formas simples.
- Áudios de verdade no `AudioManager` (locução e efeitos sonoros).
- Ajustar o traçado da `Curve2D` da Pista das Letras pra imitar o
  formato real de cada letra (ela também ainda não tem as 26 letras,
  só a curva genérica em formato de "tenda").
- Persistência de **estrelas por minijogo** (hoje `PerfilJogador` salva
  pontos por cena jogada, mas não a quantidade de estrelas/resultado de
  cada partida).
