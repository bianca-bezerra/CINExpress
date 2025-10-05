extends Control


var nomes: Array[String] = [
	"Ana Carolina de Souza", "Bruno dos Santos Oliveira", "Carlos Eduardo Pereira",
	"Daniela Ferreira Lima", "Eduardo Almeida Costa", "Fernanda Gonçalves Ribeiro",
	"Gustavo Rodrigues Martins", "Helena Barbosa Gomes", "Igor de Castro Alves"
]

var nome_atual: String = ""
var pontuacao: int = 0
var tempo_inicio_rodada: float = 0.0

const FATOR_PONTUACAO = 1000 

@onready var prompt_label: Label = $VBoxContainer/PromptLabel
@onready var input_line_edit: LineEdit = $VBoxContainer/InputLineEdit
@onready var feedback_label: Label = $VBoxContainer/FeedbackLabel


func _ready() -> void:
	input_line_edit.text_submitted.connect(_on_input_submitted)
	input_line_edit.editable = false
	start_game()


func start_game() -> void:
	pontuacao = 0
	nome_atual = ""
	input_line_edit.editable = true 
	
	
	print("Pontuação: 0")
	feedback_label.text = ""
	
	proxima_rodada()


func proxima_rodada() -> void:
	if nomes.is_empty():
		# Se a lista de nomes acabar
		feedback_label.text = "Parabéns! Você completou todos os nomes!"
		input_line_edit.editable = false
		return

	
	nome_atual = nomes.pick_random()
	nomes.erase(nome_atual) 
	
	prompt_label.text = nome_atual
	
	input_line_edit.text = ""
	input_line_edit.grab_focus()
	
	tempo_inicio_rodada = Time.get_ticks_msec()



func _on_input_submitted(texto_digitado: String) -> void:
	if texto_digitado.strip_edges() == nome_atual:
		var tempo_gasto_ms = Time.get_ticks_msec() - tempo_inicio_rodada
		var tempo_gasto_seg = tempo_gasto_ms / 1000.0

		var pontos_ganhos = int((len(nome_atual) * FATOR_PONTUACAO) / tempo_gasto_seg)
		
		pontuacao += pontos_ganhos
				
		print("Pontuação: %d" % pontuacao) 
		feedback_label.text = "Correto! +%d pontos (%.2f seg)" % [pontos_ganhos, tempo_gasto_seg]
		
		proxima_rodada()
	else:
		feedback_label.text = "Incorreto! Tente novamente."
		input_line_edit.text = ""
		input_line_edit.grab_focus()
