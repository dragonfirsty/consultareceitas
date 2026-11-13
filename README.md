# Consulta de Receitas

Aplicativo Flutter desenvolvido por **Leonardo Moya** e **Vinicius Silvestre**
para consultar receitas culinárias na API pública
[TheMealDB](https://www.themealdb.com/docs_api_guide.php).

## Como executar

1. Instale o Flutter e um dispositivo ou emulador.
2. Na pasta do projeto, execute `flutter pub get`.
3. Execute `flutter run`.

Digite o nome ou parte do nome de uma receita e toque em **Pesquisar**. O
aplicativo apresenta o nome e a imagem das receitas encontradas e informa os
estados de carregamento, ausência de resultados e erro de consulta.

## Sugestão de commits para a entrega

Faça os commits separadamente, durante o desenvolvimento:

1. `chore: criar estrutura inicial do projeto Flutter`
   - Registre o projeto Flutter inicial e os arquivos de configuração.
2. `feat: criar tela de busca de receitas`
   - Registre a AppBar com os nomes, o campo de pesquisa, o botão e o layout.
3. `feat: integrar consulta com TheMealDB`
   - Registre a chamada HTTP, a leitura do JSON e a lista com imagens.
4. `test: adicionar estados e testes da tela`
   - Registre as mensagens de carregamento, erro e nenhum resultado, além dos
     testes de widget e desta documentação.

Se o projeto já estiver pronto, os commits podem ser feitos em sequência
separando os arquivos conforme os grupos acima; não é necessário alterar o
histórico de commits já existentes.
