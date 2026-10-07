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
## - Jogo dentro do app: crie a cena em res://scenes/jogos/ e coloque
##   "cena" na entrada abaixo.
## - Jogo de navegador (link): coloque "url" no lugar de "cena" — o menu
##   abre o link direto, sem cena nenhuma.
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
		"url": "https://al3xmoreira.github.io/infantil/",
		"imagem": "res://assets/CAPAparajogos/tratorDasLetras.jpeg",
	},
	{
		"id": "trator_fases",
		"nome": "Trator das Letras — 36 Fases",
		"url": "https://al3xmoreira.github.io/trator/",
		"imagem": "res://assets/CAPAparajogos/tratorDasletras36Fasespal.jpeg",
	},
	{
		"id": "estourador_silabas",
		"nome": "Estourador de Sílabas",
		"cena": "res://scenes/jogos/EstouradorSilabas.tscn",
		"imagem": "res://assets/CAPAparajogos/estourarSilabras.jpeg",
	},
	{
		"id": "construtor_palavras",
		"nome": "Construtor de Palavras",
		"cena": "res://scenes/jogos/ConstrutorPalavras.tscn",
		"imagem": "res://assets/CAPAparajogos/formarPalavras.jpeg",
	},
]
