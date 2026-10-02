extends Node
## Autoload "Catalogo".
##
## Fonte única de verdade sobre quais minijogos existem no app. O menu
## principal lê essa lista pra montar o carrossel — assim você cadastra
## um jogo novo em UM lugar só, e não corre o risco de o menu e o jogo
## ficarem "desincronizados" (um script achando que existe um jogo que
## o outro não conhece).
##
## Para adicionar um jogo novo:
## 1. Crie a cena em res://scenes/jogos/
## 2. Acrescente uma entrada aqui embaixo.
## Não precisa mexer no MenuPrincipal.gd.

## Pista das Letras saiu da lista (jogo de arrastar carrinho, nunca
## chegou a ser terminado) — no lugar entraram os dois jogos de trator
## abaixo. A cena (PistaLetras.tscn) e o script continuam no projeto,
## só não aparecem mais no menu; apague os dois se tiver certeza que
## não vai mais usar.
var jogos: Array = [
	{
		"id": "trator_infantil",
		"nome": "Trator das Letras",
		"cena": "res://scenes/jogos/TratorInfantil.tscn",
		"imagem": null,
	},
	{
		"id": "trator_fases",
		"nome": "Trator das Letras — 36 Fases",
		"cena": "res://scenes/jogos/TratorFases.tscn",
		"imagem": null,
	},
	{
		"id": "estourador_silabas",
		"nome": "Estourador de Sílabas",
		"cena": "res://scenes/jogos/EstouradorSilabas.tscn",
		"imagem": null,
	},
	{
		"id": "construtor_palavras",
		"nome": "Construtor de Palavras",
		"cena": "res://scenes/jogos/ConstrutorPalavras.tscn",
		"imagem": null,
	},
]
