# CINExpress

Jogo para stand Campus Party 2025 do Instituto de Cidadani Digital.

## Entrega da CIN

Durante os 60 segundos iniciais, a sequencia e **digitacao -> digital -> foto**. Ao concluir um atendimento, o nome gerado na digitacao e o personagem ficam guardados para a entrega. Quando o tempo termina, aparece um aviso da rodada extra. Depois dele, comeca o cronometro de 30 segundos para entregar o maximo possivel de CINs; o aviso avanca sozinho ou com Espaco/Enter.

Abra `scenes/levels/cin_delivery.tscn` e use **F6** para experimentar. O cidadao chega ao balcao, pede sua CIN e aguarda Espaco/Enter para abrir a gaveta. O nome aparece na tela da gaveta. Na partida, a cena usa a interface geral de tempo, pontos e combo; o cronometro dos 30 segundos continua durante a chegada e a busca. Na previa, nao ha pontuacao.

| Controle | Acao |
| --- | --- |
| Setas horizontais | Trocar pastas ABC a YZ |
| Setas verticais | Trocar CIN da pasta |
| Espaco / Enter | Entregar a CIN selecionada |

Cada pasta lembra a ultima CIN selecionada. Os nomes ficam na pasta da inicial do primeiro nome, ignorando acentos; a ordem e aleatoria. Sao duas CIN por pasta no inicio, tres a partir da terceira rodada e quatro a partir da quinta. Ha uma unica CIN com nome e personagem do cidadao. Um erro quebra o combo e permite continuar. Apos cada acerto chega outro cidadao; quando a fila de atendimentos concluidos acaba, sao gerados novos cidadaos ate o tempo terminar.

A pontuacao base e `int(score_factor * (current_level + 1) / max(segundos, 1))`, contando o tempo desde a abertura da gaveta. O `PlayerManager` aplica o multiplicador de combo e atualiza os pontos; uma CIN incorreta interrompe o combo. As CINs produzidas e as entregues tem contagens separadas no resultado e no save. Quando os 30 segundos acabam, a partida e salva e segue para os resultados.

### Ajustes

Os assets estao em `assets/sprites/delivery/`; os originais foram preservados. A cena de entrega expoe posicoes, elevacao, transicoes, limites de texto e pontuacao no Inspector. `scenes/components/cin_folder.tscn` controla origem e espacamento das CIN. `scenes/components/cin_card.tscn` controla foto, nome, contorno e cor inativa. O recorte facial automatico pode ser substituido pela propriedade `portrait_region`.

### Validacao

A suite existente foi escrita para a sequencia anterior, em que a entrega era o segundo minigame, e precisa ser atualizada para a rodada extra.
