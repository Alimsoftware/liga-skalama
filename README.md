# LIGA SKALAMA

Site responsivo para organizar a noite de futsal: lista individual de 20 jogadores, quatro times sorteados, sequência ilimitada de partidas, cronômetro, artilharia acumulada, rankings de score, goleiros, histórico e regras.

## Rodar localmente

Abra `index.html` no navegador. Sem configuração Supabase, o site guarda os dados apenas nesse navegador. Para sincronizar os participantes, publique em HTTPS e conecte um projeto Supabase.

## Ativar sincronização compartilhada

1. Crie um projeto Supabase.
2. Abra o SQL Editor e execute o conteúdo atualizado de `schema.sql`.
3. Em Project Settings / API, copie a Project URL e a chave pública `anon`/publishable (nunca use `service_role` no site).
4. Preencha esses dois valores em `config.js`:

```js
window.LIGA_CONFIG = {
  supabaseUrl: "https://SEU-PROJETO.supabase.co",
  supabaseAnonKey: "SUA_CHAVE_PUBLICA"
};
```

5. Publique a pasta `liga-skalama` como site HTTPS. Para GitHub Pages, coloque seu conteúdo na raiz de um repositório exclusivo e habilite Pages.

O site publicado deve ser público para leitura. Somente contas autenticadas e cadastradas pelo administrador em `league_admins` podem editar; as permissões são aplicadas pelo RLS no banco e também pela interface. Não compartilhe a chave `service_role`. Use somente a chave pública anon/publishable no `config.js`.

## Organização dos jogos

O primeiro jogo é **Time Águia × Time Sol**. O vencedor segue contra **Verde**, depois **Azul** e, em seguida, contra os times derrotados, em uma fila contínua sem limite de partidas. Se um time precisar jogar antes, selecione-o na fila e use **Trocar ordem**; o jogo adiantado assume a próxima posição e a sequência restante é preservada. O placar começa em zero para cada partida.

Cada gol fica ligado à partida, com autor e minuto registrados. O placar separa o time do autor do time que recebe o ponto em um gol contra. O score de jogadores e goleiros é calculado automaticamente após cada partida; os rankings mostram as médias individuais e os gols sofridos por goleiro.

O botão **Fundo claro** alterna entre o tema claro e o tema escuro padrão. A escolha fica salva no dispositivo.

## Regras e punições

A seção **Regras oficiais da SKALAMA** fica na tela principal. As ocorrências podem ser registradas durante a partida; para mão intencional, o site mostra a punição de 60 segundos.

**Banco Supabase já existente:** execute novamente `schema.sql` para adicionar as colunas `minute` e `game_id` à tabela de gols. `game_id` isola o placar de cada partida e impede que gols anteriores apareçam no novo placar.

## Cronômetro, goleiros e pontuação

Antes de cada jogo, selecione Modo Liga (8 minutos com até 1 minuto acumulado de pausa) ou Modo Coca (cronômetro crescente sem limite de duração, com até 2 minutos acumulados de pausa). O jogo termina quando o organizador encerra a partida.

Defina um goleiro para cada equipe antes de iniciar. Jogadores marcados com asterisco são atribuídos automaticamente; nos demais times, escolha um jogador da escalação.

Ao registrar um gol contra, selecione quem fez o gol e marque Gol contra. O gol soma no placar do adversário, mas não aumenta a artilharia individual do autor. O histórico mostra o autor, o minuto e o time que recebeu o gol.

Cada jogador começa cada partida com score 7,0. Após o encerramento, o sistema aplica os bônus e descontos definidos para vitória, empate, derrota, gols, gols sofridos e gols contra, limita o resultado de 0 a 10 e calcula a média individual. A tela principal separa ranking de score de jogadores, ranking de goleiros e ranking de gols sofridos por goleiros. O histórico guarda as estatísticas de cada partida.

Se o Supabase já estiver configurado, execute novamente schema.sql para acrescentar score_team_name e own_goal à tabela goals.



## Destaques da rodada

A tela principal apresenta Jogador da noite e Goleiro da noite a partir da média de score das partidas concluídas desde o último sorteio. Um novo sorteio inicia uma nova rodada para esses destaques, sem apagar o histórico ou os rankings acumulados. Os dados e registros antigos de votação não são exibidos nem usados por essa seção.


## Ajustes de escalação antes da partida

No painel do jogo ao vivo, o organizador pode marcar ausentes e puxar jogadores de outros times para preencher vagas. Cada transferência abre uma vaga no time que cedeu o jogador, permitindo continuar a cadeia de ajustes. A partida só pode começar quando cada equipe tiver pelo menos cinco jogadores. No Modo Liga, o limite é cinco por equipe; no Modo Coca, até oito. Um jogador disponível pode preencher a última vaga, inclusive em um time diferente daquele em que começou. O jogador escolhido pode ser qualquer integrante de outro time, inclusive quem vai atuar pela equipe que recebe. A escalação ajustada vale até o próximo sorteio; cada partida guarda a escalação usada para manter as estatísticas históricas corretas.

## Publicação online com edição restrita

O projeto usa Supabase para mostrar o mesmo conteúdo para todas as pessoas. Sem a URL e a chave pública do projeto Supabase, o site funciona somente no navegador atual.

1. Crie um projeto no Supabase e abra o **SQL Editor**.
2. Execute o arquivo `schema.sql`. As políticas liberam leitura pública e exigem uma conta cadastrada em `league_admins` para qualquer escrita.
3. Preencha `config.js` com a Project URL e a chave pública anon/publishable. Essa chave é pública por definição; a segurança vem das políticas RLS do banco. Nunca publique uma chave `service_role`.
4. Em **Authentication → URL Configuration**, adicione o endereço final do GitHub Pages à lista de URLs autorizadas.
5. Publique a pasta em um repositório GitHub próprio e ative GitHub Pages usando o workflow `pages.yml`.
6. Abra o site, escolha **Entrar como organizador** e solicite um link mágico para seu e-mail. Depois de entrar uma vez, adicione sua conta como administradora no SQL Editor:

```sql
insert into public.league_admins (user_id)
select id from auth.users where lower(email) = lower('SEU-EMAIL-AUTORIZADO')
on conflict (user_id) do nothing;
```

7. Atualize o site. A conta cadastrada verá a opção de edição; demais visitantes verão o conteúdo em modo somente leitura. Para remover o acesso, exclua a linha correspondente de `league_admins`.

A primeira conta autorizada precisa executar a consulta acima no Supabase. A conta comum não consegue conceder privilégios a si mesma. A identidade do administrador é definida no banco, e não pelo botão ou por uma configuração no navegador.
