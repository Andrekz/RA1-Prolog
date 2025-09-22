
% Base de Conhecimento - Fatos


trilha(inteligencia_artificial, 'Inteligência Artificial: Machine learning, redes neurais, etc.').
trilha(desenvolvimento_web, 'Desenvolvimento Web: Frontend, backend, APIs.').
trilha(seguranca_da_informacao, 'Segurança da Informação: Criptografia, pentest, redes seguras.').
trilha(ciencia_de_dados, 'Ciência de Dados: Estatística, análise de dados, visualização.').
trilha(redes_e_infraestrutura, 'Redes e Infraestrutura: Administração de redes, servidores, cloud.').
trilha(analise_de_sistemas,'Análise de Sistemas: Comunicação com o cliente e modelagem de processos').
trilha(engenharia_de_dados,'Engenharia de dados: processamento e organização de grande volume de dados').

% Características de perfil
perfil(inteligencia_artificial, logica, 5).
perfil(inteligencia_artificial, programacao, 4).
perfil(desenvolvimento_web, design_visual, 4).
perfil(desenvolvimento_web, programacao, 5).
perfil(desenvolvimento_web, trabalho_em_equipe, 3).
perfil(seguranca_da_informacao, seguranca, 5).
perfil(seguranca_da_informacao, redes, 4).
perfil(ciencia_de_dados, matematica_estatistica, 5).
perfil(ciencia_de_dados, visualizacao, 3).
perfil(redes_e_infraestrutura, redes, 5).
perfil(redes_e_infraestrutura, administracao_sistemas, 4).
perfil(analise_de_sistemas, comunicacao, 5).
perfil(analise_de_sistemas, modelagem_processos, 3).
perfil(analise_de_sistemas, programacao, 2).
perfil(analise_de_sistemas, seguranca, 1).

perfil(engenharia_de_dados, visualizacao, 4).
perfil(engenharia_de_dados, programacao, 1).
perfil(engenharia_de_dados, matematica_estatistica, 5).

% Perguntas para o usuário com ID, texto e a característica 
pergunta(1, 'Você tem afinidade com lógica?', logica).
pergunta(2, 'Você gosta de programação?', programacao).
pergunta(3, 'Você tem interesse em design visual?', design_visual).
pergunta(4, 'Você se interessa por segurança de sistemas?', seguranca).
pergunta(5, 'Você entende de redes de computadores?', redes).
pergunta(6, 'Você tem facilidade com matemática e estatística?', matematica_estatistica).
pergunta(7, 'Você gosta de analisar e visualizar dados?', visualizacao).
pergunta(8, 'Você tem experiência com administração de sistemas?', administracao_sistemas).
pergunta(9, 'Você consegue se comunicar com o usuário e entender suas necessidades?', comunicacao).
pergunta(10, 'Você tem afinidade com representações gráficas?', modelagem_processos).
pergunta(11, 'Você trabalha bem em equipe?', trabalho_em_equipe).

:- dynamic resposta/2.

%predicado para pode escolher o modo que vai ser utilizado

principal :-
    writeln('--- Sistema Especialista de Trilhas Tecnológicas ---'),
    writeln('Escolha o modo de execução:'),
    writeln('1. Interativo (responder perguntas)'),
    writeln('2. Teste automático (usar respostas já coladas no arquivo)'),
    read(Opcao),
    executar_modo(Opcao).

executar_modo(1) :- iniciar.
executar_modo(2) :-
    writeln('Executando em modo de teste... (use fatos resposta/2 colados no final do arquivo)'),
    calcular_ranking(Ranking),
    exibe_resultado(Ranking),
    limpar_respostas.
executar_modo(_) :-
    writeln('Opção inválida. Tente novamente.'),
    principal.

% Predicado principal para iniciar a interação

iniciar :-
    limpar_respostas,
    faz_perguntas,
    calcular_ranking(Ranking),
    exibe_resultado(Ranking),
    limpar_respostas.


limpar_respostas :- retractall(resposta(_, _)).
% Questionário 

faz_perguntas :-
    pergunta(Id, Texto, _),
    \+ resposta(Id, _),
    perguntar(Id, Texto),
    fail.
faz_perguntas.

perguntar(Id, Texto) :-
    format('~w (s/n): ', [Texto]),
    read(RespostaRaw),
    validar_resposta(RespostaRaw, Resposta),
    assertz(resposta(Id, Resposta)).
%validação de respostasm garantindo que a entrada seja s ou n
validar_resposta(s, s).
validar_resposta(n, n).
validar_resposta(RespostaRaw, Resposta) :-
    (RespostaRaw \= s, RespostaRaw \= n) ->
      (writeln('Resposta inválida. Por favor responda s para sim ou n para não.'),
       format('Tente novamente: '),
       read(NovaResposta),
       validar_resposta(NovaResposta, Resposta))
    ;
    Resposta = RespostaRaw.
%calcula e ordena o ranking
calcular_ranking(Ranking) :-
    findall(Pontos-Trilha-Justificativa,
        (trilha(Trilha, _),
         calcula_pontuacao(Trilha, Pontos, Justificativa)),
        Lista),
    keysort(Lista, Ordenada),
    reverse(Ordenada, Ranking).
%calcula a pontuação definindo pesos para características que são associados a trilhas
calcula_pontuacao(Trilha, Pontos, Justificativa) :-
    findall(Peso-Char,
        (perfil(Trilha, Char, Peso),
         resposta_por_caracteristica(Char, s)),
        PesosDuplicados),
    sort(PesosDuplicados, Pesos),
    ( Pesos = [] ->
        Pontos = 0, Justificativa = []
    ;
        sum_pesos(Pesos, Pontos),
        findall(Char, member(_-Char, Pesos), Justificativa)
    ).

resposta_por_caracteristica(Char, Resposta) :-
    pergunta(Id, _, Char),
    resposta(Id, Resposta).

sum_pesos(Pesos, Total) :-
    findall(P, member(P-_, Pesos), ListaPesos),
    sum_list(ListaPesos, Total).

%predicado para exibir os resultados

exibe_resultado([]) :- writeln('Nenhuma trilha encontrada.').
exibe_resultado(Ranking) :-
    writeln('\n--- Resultado das Recomendações ---'),
    forall(member(Pontos-Trilha-Just, Ranking),
        (trilha(Trilha, Desc),
         format('Trilha: ~w (~w pontos)\nDescrição: ~w\n', [Trilha, Pontos, Desc]),
         format('Justificativa: ~w\n\n', [Just]))).


recomenda(interativo, Ranking) :-
    iniciar,
    calcular_ranking(Ranking).
recomenda(automatico, Ranking) :-
    calcular_ranking(Ranking).


% Cole aqui as respostas de perfil teste


