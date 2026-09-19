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

var jogos: Array = [
	{
		"id": "pista_letras",
		"nome": "Pista das Letras",
		"cena": "res://scenes/jogos/PistaLetras.tscn",
		"imagem": null, # troque por preload("res://assets/....png") quando tiver a arte
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
