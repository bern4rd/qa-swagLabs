# Projeto de Automação de Testes Mobile - qa-swagLabs

Este repositório contém scripts de automação de testes desenvolvidos para a análise de portabilidade entre as plataformas Android e iOS. Os testes foram implementados utilizando o Robot Framework e Appium, focando na execução paralela em ambas as plataformas.

## Requisitos

### Apenas MacOS
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
   - Python, Node.js, Robot Framework, Appium e os pacotes relacionados: Utilize os comandos abaixo para instalação. Copie e cole um a um no seu terminal:

   ```bash
   cd $HOME
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   touch .bashrc
   touch .profile
   echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> .profile
   eval "$(/opt/homebrew/bin/brew shellenv)"
   brew install python
   brew install nvm
   brew install powershell
   brew install openjdk
   brew install appium-inspector
   echo 'export PATH="/opt/homebrew/opt/python/bin:$PATH"' >> ~/.bashrc
   pip install poetry
   nvm install node
   echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
   echo '[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"' >> ~/.bashrc
   npm install -g appium
   npm install -g appium-doctor
   echo 'export JAVA_HOME=$(/usr/libexec/java_home)' >> ~/.bashrc
   echo 'export ANDROID_HOME=~/Library/Android/sdk' >> ~/.bashrc
   echo 'PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.bashrc
   echo 'PATH=$PATH:$ANDROID_HOME/tools' >> ~/.bashrc
   echo 'PATH=$PATH:$ANDROID_HOME/tools/bin' >> ~/.bashrc
   echo 'PATH=$PATH:$ANDROID_HOME/tools/lib' >> ~/.bashrc
   appium driver install uiautomator2
   appium driver install xcuitest
   ```

2. **Configuração dos Emuladores**:
   - **Android Emulator**: Configure através do Android Studio.
   - **iOS Simulator**: Configure através do Xcode.

3. **Instalação de Dependências**:

   Navegue até o diretório do projeto e instale as dependências utilizando o Pipenv:

   ```bash
   poetry install
   ```

## Estrutura do Projeto

A estrutura do projeto está organizada da seguinte forma:

```plaintext
.
├── app
│   └── Android.SauceLabs.Mobile.Sample.app.2.7.1.apk
├── logs
│   ├── Android
│   │   ├── TC01_login
│   │   │   ├── log.html
│   │   │   ├── output.xml
│   │   │   └── report.html
│   │   ├── TC02_logout
│   │   │   ├── log.html
│   │   │   ├── output.xml
│   │   │   └── report.html
│   │   └── TC03_filter_products
│   │       ├── log.html
│   │       ├── output.xml
│   │       └── report.html
│   └── iOS
│       ├── TC01_login
│       │   ├── log.html
│       │   ├── output.xml
│       │   └── report.html
│       ├── TC02_logout
│       │   ├── log.html
│       │   ├── output.xml
│       │   └── report.html
│       └── TC03_filter_products
│           ├── log.html
│           ├── output.xml
│           └── report.html
├── poetry.lock
├── pyproject.toml
├── README.md
├── resources
│   ├── 01-access
│   │   └── login-keywords.resource
│   ├── 02-filter-products
│   │   ├── filter-products-keywords.resource
│   │   └── filter-products-variables.resource
│   ├── 03-shopping-cart
│   │   ├── shopping-cart-keywords.resource
│   │   └── shopping-cart-variables.resource
│   ├── 04-checkout
│   │   ├── checkout-keywords.resource
│   │   └── checkout-variables.resource
│   ├── 05-geolocation
│   │   ├── geolocation-keywords.resource
│   │   └── geolocation-variables.resource
│   ├── base.resource
│   ├── common
│   │   ├── common-keywords.resource
│   │   └── common-variables.resource
│   └── devdata
│       ├── devices.dat
│       ├── test_tags.txt
│       └── test_tags_e2e.txt
├── run_tests.ps1
├── run_tests_old.ps1
├── run_tests_short.ps1
└── tests
    ├── 01-Login-logout
    │   └── login-logout-test.robot
    ├── 02-Filter-products
    │   └── filter-products-test.robot
    ├── 03-Shopping-cart
    │   └── shopping-cart-test.robot
    ├── 04-Checkout
    │   └── checkout-test.robot
    └── 05-Geolocation
        └── geolocation-test.robot
```

- `pyproject.toml`: Contém a lista de todas as dependências e bibliotecas necessárias.
- `resources/`: Diretório que armazena arquivos de recursos utilizados nos testes.
- `run_tests_old.ps1`: Script PowerShell utilizado para executar os testes automatizados em paralelo nos dispositivos Android e iOS.
- `tests/`: Diretório onde os casos de teste automatizados são armazenados.

## Execução dos Testes

Para executar os testes, utilize o script PowerShell `run_tests.ps1`:

```bash
pwsh ./run_tests.ps1
```

Os resultados dos testes serão organizados em diretórios separados por plataforma dentro da pasta `logs/`.

Para executar os testes via terminal, utilize o seguinte comando:

```bash
poetry run robot tests/
```

Para direcionar a execução para uma feature específica, utilize as test tags com o argumento -i Tag:

```bash
poetry run robot -i feature-tag tests/
```

### Outros argumentos

Variáveis: se quiser passar variáveis para os testes, utilize o argumento -v. Por exemplo:

```bash
poetry run robot -v VARIAVEL:valor tests/
```

Log-Level: para definir o nível de log, utilize o argumento -L. Os níveis disponíveis são: TRACE, DEBUG, INFO, WARN, ERROR e FAIL.

```bash
poetry run robot -L DEBUG tests/
```

Output-Dir: para definir o diretório de saída dos relatórios, utilize o argumento -d.

```bash
poetry run robot -d logs/ tests/
```

### RetryFailed

O listener `RetryFailed` permite reexecutar testes que falharam. Para utilizá-lo, adicione a seguinte opção ao comando:

```bash
--listener RetryFailed:1
```

## Executar todas as features

### Android
```bash
poetry run robot -v PLATFORM:Android -L DEBUG --listener RetryFailed:1 -d logs/Android/ tests/
```

### iOS
```bash
poetry run robot -v PLATFORM:iOS -L DEBUG --listener RetryFailed:1 -d logs/iOS/ tests/
```

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