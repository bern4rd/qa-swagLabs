# Projeto de Automação de Testes Mobile - qa-swagLabs

Este repositório contém scripts de automação de testes desenvolvidos para a análise de portabilidade entre as plataformas Android e iOS. Os testes foram implementados utilizando o Robot Framework e Appium, focando na execução paralela em ambas as plataformas.

## Requisitos

Para executar este projeto, você precisará das seguintes ferramentas:

- **Xcode**: Necessário para simulação de dispositivos iOS.
- **Android Studio**: Necessário para simulação de dispositivos Android.
- **Python**: Linguagem de programação utilizada como base para o Robot Framework.
- **Node.js**: Utilizado para a instalação e operação do Appium.
- **Robot Framework**: Framework utilizado para criar e gerenciar os scripts de teste.
- **Appium**: Ferramenta para automação de aplicativos móveis.

## Configuração do Ambiente

1. **Instalação das Ferramentas**:
   - Xcode: [Instalação via App Store](https://apps.apple.com/us/app/xcode/id497799835?mt=12)
   - Android Studio: [Baixe o Android Studio](https://developer.android.com/studio?hl=pt-br)
   - Python, Node.js, Robot Framework, Appium: Utilize os comandos abaixo para instalação:

   ```bash
   brew install python
   brew install nvm
   pip install pipenv
   nvm install node
   npm install -g appium
   npm install -g appium-doctor
   ```

2. **Configuração dos Emuladores**:
   - **Android Emulator**: Configure através do Android Studio.
   - **iOS Simulator**: Configure através do Xcode.

3. **Instalação de Dependências**:

   Navegue até o diretório do projeto e instale as dependências utilizando o Pipenv:

   ```bash
   pipenv install
   ```

## Estrutura do Projeto

A estrutura do projeto está organizada da seguinte forma:

```plaintext
.
├── requirements.txt
├── resources/
│   ├── base_keywords.resource
│   ├── base_variables.resource
│   └── devdata/
│       ├── path_tests.bkp
│       └── path_tests.txt
├── run_tests.ps1
└── tests/
```

- `requirements.txt`: Contém a lista de todas as dependências e bibliotecas necessárias.
- `resources/`: Diretório que armazena arquivos de recursos utilizados nos testes.
- `run_tests.ps1`: Script PowerShell utilizado para executar os testes automatizados em paralelo nos dispositivos Android e iOS.
- `tests/`: Diretório onde os casos de teste automatizados são armazenados.

## Execução dos Testes

Para executar os testes, utilize o script PowerShell `run_tests.ps1`:

```bash
pwsh ./run_tests.ps1
```

Os resultados dos testes serão organizados em diretórios separados por plataforma dentro da pasta `logs/`.

## Análise dos Resultados

Os resultados são documentados automaticamente em formato HTML e XML, permitindo uma análise detalhada de cada execução. Eles estão organizados em:

```plaintext
logs/
├── android/
│   ├── TC01_login/
│   ├── TC02_logout/
│   └── TC03_filters/
└── ios/
    ├── TC01_login/
    ├── TC02_logout/
    └── TC03_filters/
```

## Mapeamento de Elementos e Criação de Scripts

Os scripts de teste foram criados utilizando as keywords definidas no Robot Framework, com suporte para a interação com as interfaces de usuário de ambas as plataformas.

## Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests com melhorias e correções.

## Licença

Este projeto está licenciado sob os termos da licença MIT.
