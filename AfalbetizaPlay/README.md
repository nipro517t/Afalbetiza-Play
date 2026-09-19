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
assets/     -> arte, fonte, tema (só o do menu por enquanto)
scenes/
  MenuPrincipal.tscn
  ui/
	TelaRecompensa.tscn      -> tela de fim de jogo (estrelas + botões), reaproveitada por todo minijogo
	TelaNomeJogador.tscn     -> pede nome + turma antes do menu (cena inicial do projeto)
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
- `configurar(silaba: String, eh_correta: bool)` — chamado pelo
  minijogo logo após `instantiate()`, define o texto exibido e se
  aquela bolha é a resposta certa.
- `signal tocada(balao: Balao, eh_correta: bool)` — emitido quando a
  criança aperta a bolha; o minijogo escuta esse sinal pra somar
  ponto, tirar vida ou avançar de palavra.

### Construtor de Palavras
Toque nas sílabas embaralhadas na ordem certa pra formar a palavra
mostrada. Errar a ordem só limpa os espaços de novo. A versão base
assume palavras de 2 sílabas (2 espaços fixos na cena) — pra palavras
maiores, adicione mais `Label`s dentro de `Slots` na cena.

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

## Perfil da criança, pontos e ranking (persistente)

Antes de cair no menu, o app agora sempre passa por uma tela pedindo
**nome** e **turma/série** da criança (`TelaNomeJogador.tscn` /
`tela_nome_jogador.gd`) — é a nova cena inicial do projeto
(`run/main_scene` no `project.godot`). Sem isso, `PerfilJogador` não
sabe pra quem salvar os pontos.

- **Autoload novo: `PerfilJogador`** (`scripts/core/perfil_jogador.gd`).
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
- **Tela de Ranking** (`TelaRanking.tscn` / `tela_ranking.gd`), acessível
  pelo botão "RANKING" no menu: lista todo mundo que já jogou, ordenado
  do maior pro menor total de pontos, mostrando posição, nome, turma e
  pontos. Lê tudo de `PerfilJogador.obter_ranking()` — a tela em si não
  guarda nada.
- **Botão "TROCAR" no menu** volta pra tela de nome/turma — útil porque
  o aparelho costuma ser usado por várias crianças; ninguém fica
  "logado" pro resto do dia sem querer. O menu também mostra "Jogando
  como: NOME (TURMA)" no canto, só pra confirmar visualmente quem tá
  valendo ponto no momento.

## O que falta (de propósito, pra vocês decidirem o rumo)

- Arte final de cada jogo (carrinho, bolhas, cenário, ícones dos cards).
- Áudios de verdade no `AudioManager` (locução e efeitos sonoros).
- Ajustar o traçado da `Curve2D` da Pista das Letras pra imitar o
  formato real de cada letra.
- Persistência de progresso (quantas estrelas em cada jogo) — hoje
  nada é salvo entre sessões.
