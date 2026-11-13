# Consulta de Receitas

Aplicativo desenvolvido em Flutter por **Leonardo Moya** e **Vinicius
Silvestre** para pesquisar receitas culinárias utilizando a API pública
[TheMealDB](https://www.themealdb.com/docs_api_guide.php).

## Funcionalidades

- Pesquisa de receitas pelo nome ou por parte dele.
- Exibição do nome e da imagem de cada receita encontrada.
- Indicador de carregamento durante a consulta.
- Mensagens para pesquisa vazia, nenhum resultado e erro de conexão.
- Interface responsiva para dispositivos móveis e web.

## Tecnologias

- Flutter e Dart
- `http` para as requisições REST
- API [TheMealDB](https://www.themealdb.com/api.php)

## Como executar

Pré-requisitos:

- Flutter instalado e configurado.
- Um dispositivo, emulador ou navegador disponível para execução.

Na pasta do projeto, execute:

```bash
flutter pub get
flutter run
```

Depois, digite o nome de uma receita no campo de pesquisa e toque em
**Pesquisar**.

## Consulta utilizada

As receitas são pesquisadas pelo endpoint:

```text
https://www.themealdb.com/api/json/v1/1/search.php?s=TERMO
```

O termo `TERMO` é substituído pelo texto digitado pelo usuário.

## Testes

Para executar os testes de widget:

```bash
flutter test
```

## Integrantes

- Leonardo Moya
- Vinicius Silvestre
