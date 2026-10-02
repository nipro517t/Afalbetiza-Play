# Progresso do Afalbetiza Play — documento de continuação

> **Sempre atualize este arquivo ao final de cada sessão**, antes de mandar
> o projeto pra outra conta/Claude continuar. Objetivo: quem pegar o
> projeto do zero (você ou outro Claude) entende em 2 minutos o que já
> foi feito, o que falta e por quê, sem precisar reler todo o histórico
> do chat.

## Última atualização
2026-09-22 — feito por Claude (conta atual), em cima da sua versão
corrigida do zip (`afalbetiza_play_2026-comAsFotosCertas.zip`), **não**
em cima do que o amigo fez na conta dele (aquele estava desatualizado
e nunca puxou o GitHub Desktop antes de mexer).

## O que foi feito nesta sessão (4ª rodada — ajuste no ritmo do Estourador)

Balões nascendo em grupo (2 ou 3 juntos) tinha ficado difícil demais
pra criança — **revertido**. `scripts/jogos/estourador_silabas.gd`
voltou a spawnar sempre 1 balão por disparo do timer (removida
`_ao_timer_spawn()`, timer conectado direto em `_spawnar_balao()` de
novo). Vidas do Construtor de Palavras **continuam** (não mexi nisso).

O que ficou pra tornar o jogo mais dinâmico: só encurtei o intervalo
entre balões. `wait_time` do `TimerSpawn`
(`scenes/jogos/EstouradorSilabas.tscn`) caiu de `2.73` pra `1.82`
(menos 1/3 do tempo) — balão novo aparece bem mais rápido, mas sempre
1 de cada vez.

## O que foi feito na sessão anterior (vida no Construtor + balões em grupo)

- **`scripts/jogos/construtor_palavras.gd`** + **`scenes/jogos/
  ConstrutorPalavras.tscn`**: adicionado sistema de vidas/tentativa e
  erro igual ao Estourador de Sílabas. 3 vidas compartilhadas pra
  rodada inteira; errar limpa os espaços e deixa tentar de novo a
  MESMA palavra; zerar as vidas manda pra recompensa com 1 estrela
  (derrota); vencer dá 3/2/1 estrelas conforme as vidas restantes
  (antes era sempre 3, e errar não tinha consequência nenhuma). Cena
  ganhou o mesmo indicador visual `Vidas` (3 `ColorRect`) do Estourador.
- **`scripts/jogos/estourador_silabas.gd`**: balões agora às vezes
  nascem em grupo (2 ou 3 juntos), não sempre um por vez —
  `_ao_timer_spawn()` decide isso a cada disparo do `TimerSpawn`
  (~65% um só, ~25% dois, ~10% três).

## O que foi feito na sessão anterior (bug do balão)

Seu amigo notou um problema no Estourador de Sílabas: o balão "decidia"
se era certo ou errado no momento em que nascia, e ficava com essa
marcação pra sempre — se a palavra mudasse enquanto aquele balão ainda
estava subindo, ele continuava valendo (ou não) ponto pra uma palavra
que já não estava mais na tela.

- **`scripts/jogos/balao.gd`**: o balão não guarda mais se é "certo"
  ou "errado" — só guarda a sílaba escrita nele (`obter_silaba()`).
  Sinal mudou de `tocada(balao, eh_correta)` pra `tocada(balao)`.
- **`scripts/jogos/estourador_silabas.gd`**: quem decide certo/errado
  agora é `_on_balao_tocada()`, comparando a sílaba do balão tocado
  com a palavra que está valendo **no momento do toque**
  (`_item_atual()`), não com a palavra que valia quando o balão
  nasceu. Corrige exatamente o caso que o amigo descreveu.
- Adicionado `_jogo_ativo` + `_encerrar_rodada()`: ao vencer ou perder,
  qualquer balão que ainda esteja subindo é removido da tela (antes só
  a derrota fazia isso; a vitória deixava balão solto por aí, o que
  também podia gerar toque tocando em índice já fora da rodada).
- **Velocidade dos balões dobrada**: `VELOCIDADE_SUBIDA` de `60.0`
  pra `120.0`.

## O que foi feito na sessão anterior a essa (perfil/turma/ranking)

1. **Turma/série agora é dropdown, não campo de texto livre**
   (`scripts/core/perfil_jogador.gd` → `TURMAS_DISPONIVEIS`: Maternal I,
   Maternal II, Jardim I, Jardim II, 1º/2º/3º Ano). Mais fácil pra
   criança pequena e evita "3o ano", "3º Ano ", "terceiro ano" virarem
   turmas diferentes no banco.
2. **Aba de seleção de perfil já criado**
   (`scenes/ui/TelaNomeJogador.tscn` + `scripts/ui/tela_nome_jogador.gd`):
   agora é um `TabContainer` com duas abas — "Perfil Existente" (lista
   de botões nome + turma, um clique e já cai no menu) e "Novo Jogador"
   (nome + dropdown de turma). Aparece tanto ao abrir o jogo quanto ao
   apertar "TROCAR" no menu. Se ainda não existe nenhum perfil salvo
   nesse aparelho, abre direto em "Novo Jogador" (não faz sentido
   mostrar lista vazia primeiro).
3. **Filtro de turma no Ranking**
   (`scenes/ui/TelaRanking.tscn` + `scripts/ui/tela_ranking.gd`):
   dropdown "Todas as turmas" + uma opção por turma que já tem gente
   no ranking (não usa a lista fixa de turmas pra não mostrar turma
   vazia). A posição (1º, 2º...) passa a ser relativa à lista filtrada.
4. **`PROGRESSO.md`** (este arquivo) e o `README.md` atualizados.

## Prompt original do amigo (pro Claude dele, referência)

> Poderia fazer um documento para continuar o progresso quando você
> bater o limite e eu mandar para você em outra conta, contando o que
> você fez, o que falta fazer e etc. (Sempre Atualize)
>
> Você também poderia fazer um drop-down para selecionar a série como
> Jardim II.
>
> E alguma forma de selecionar um perfil já criado como uma aba de
> seleção ao abrir o jogo e ao apertar o botão de trocar de perfil.
>
> E Fassa um Readme dentro do projeto documentando tudo. (Sempre
> Atualize)

Os 4 itens acima foram cobertos nesta sessão, na sua versão do projeto.

## O que falta / próximos passos possíveis

- **Testar no editor Godot 4.7** — essas mudanças foram feitas editando
  os arquivos `.tscn`/`.gd` diretamente (fora do editor), então abra o
  projeto e dê F5 antes de exportar pro Android, só pra conferir que o
  `TabContainer` e os `OptionButton` renderizam do jeito esperado no
  seu tema/resolução.
- **Editar a lista de turmas** se `TURMAS_DISPONIVEIS`
  (`scripts/core/perfil_jogador.gd`) não bater com as turmas reais da
  escola — hoje é Maternal I/II, Jardim I/II, 1º ao 3º Ano.
- Itens antigos que já estavam em aberto (ver README, seção "O que
  falta"): arte final dos minijogos, áudios de verdade no
  `AudioManager`, traçado real de letra na Pista das Letras,
  persistência de estrelas por minijogo.

## Como retomar em outra conta

1. Mande este arquivo (`PROGRESSO.md`) junto com o projeto.
2. Diga o que quer mudar a partir daqui — o Claude da outra conta lê
   isso e já sabe o estado atual sem precisar reexplicar tudo.
3. Peça pra ele **sempre atualizar `PROGRESSO.md` e `README.md`** ao
   fim de cada resposta que mexer no projeto, do mesmo jeito que foi
   feito aqui.
