extends Node
## Autoload "PerfilJogador".
##
## Guarda quem está jogando agora (nome + turma) e o placar de cada
## criança que já usou o app nesse aparelho — persistido em disco, na
## pasta de dados do Godot (`user://`), então continua salvo mesmo
## fechando o app (não é só cache de memória). No Windows/Linux/Mac
## isso mora na pasta de dados do usuário (ex: AppData no Windows); no
## Android, na pasta privada do app.
##
## Nenhum minijogo precisa chamar nada daqui na mão: MinigameBase.
## concluir() já chama adicionar_pontos() sozinho, usando a variável
## "pontos" que cada minijogo já vinha somando o tempo todo.

const CAMINHO_SALVAMENTO := "user://perfis_jogadores.json"

## Nome e turma da criança jogando agora nesta sessão. Ficam vazios até
## TelaNomeJogador chamar definir_jogador() — nesse caso,
## adicionar_pontos() não salva nada (evita pontos "órfãos").
var nome_atual: String = ""
var turma_atual: String = ""

## chave (nome+turma normalizados) -> {
##   "nome": String, "turma": String,
##   "pontos_totais": int,
##   "por_jogo": { <caminho da cena do minijogo>: int },
## }
var _perfis: Dictionary = {}


func _ready() -> void:
	_carregar()


## Chame ao pedir o nome/turma pra criança (TelaNomeJogador.gd). Cria o
## perfil na primeira vez dessa combinação nome+turma; se já existir,
## continua somando em cima do que já tinha.
func definir_jogador(nome: String, turma: String) -> void:
	nome_atual = nome.strip_edges()
	turma_atual = turma.strip_edges()
	var chave := _chave(nome_atual, turma_atual)
	if not _perfis.has(chave):
		_perfis[chave] = {
			"nome": nome_atual,
			"turma": turma_atual,
			"pontos_totais": 0,
			"por_jogo": {},
		}
		_salvar()


## Chamado automaticamente por MinigameBase.concluir() ao fim de cada
## minijogo. "identificador_jogo" é só uma chave pra separar o placar
## por jogo (ex: o caminho da cena) — não precisa existir em nenhuma
## lista antes, é criado sozinho na primeira vez.
func adicionar_pontos(identificador_jogo: String, pontos_da_partida: int) -> void:
	if nome_atual.is_empty() or pontos_da_partida <= 0:
		return # ninguém logado ainda, ou nada pra somar
	var chave := _chave(nome_atual, turma_atual)
	if not _perfis.has(chave):
		definir_jogador(nome_atual, turma_atual)
	var perfil: Dictionary = _perfis[chave]
	perfil["pontos_totais"] = int(perfil.get("pontos_totais", 0)) + pontos_da_partida
	var por_jogo: Dictionary = perfil.get("por_jogo", {})
	por_jogo[identificador_jogo] = int(por_jogo.get(identificador_jogo, 0)) + pontos_da_partida
	perfil["por_jogo"] = por_jogo
	_perfis[chave] = perfil
	_salvar()


## Pronta pra tela de ranking: [{ "nome", "turma", "pontos_totais" }, ...]
## já ordenada da maior pontuação pra menor.
func obter_ranking() -> Array:
	var lista: Array = []
	for chave in _perfis:
		var perfil: Dictionary = _perfis[chave]
		lista.append({
			"nome": perfil.get("nome", "?"),
			"turma": perfil.get("turma", "?"),
			"pontos_totais": int(perfil.get("pontos_totais", 0)),
		})
	lista.sort_custom(func(a, b): return a["pontos_totais"] > b["pontos_totais"])
	return lista


func _chave(nome: String, turma: String) -> String:
	return "%s|%s" % [nome.to_lower(), turma.to_lower()]


func _salvar() -> void:
	var arquivo := FileAccess.open(CAMINHO_SALVAMENTO, FileAccess.WRITE)
	if arquivo == null:
		push_warning("PerfilJogador: não consegui salvar em " + CAMINHO_SALVAMENTO)
		return
	arquivo.store_string(JSON.stringify(_perfis, "\t"))
	arquivo.close()


func _carregar() -> void:
	if not FileAccess.file_exists(CAMINHO_SALVAMENTO):
		return
	var arquivo := FileAccess.open(CAMINHO_SALVAMENTO, FileAccess.READ)
	if arquivo == null:
		return
	var texto := arquivo.get_as_text()
	arquivo.close()
	var resultado = JSON.parse_string(texto)
	if typeof(resultado) == TYPE_DICTIONARY:
		_perfis = resultado
	else:
		push_warning("PerfilJogador: arquivo de save corrompido, começando do zero")
