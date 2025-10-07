# 🐳 Inception — Infraestrutura Containerizada do Zero (42 Rio)

Projeto de administração de sistemas e infraestrutura com **Docker** e **Docker Compose**, desenvolvido como parte do currículo da **42 Rio**.

O objetivo central do **Inception** é construir uma infraestrutura completa de microsserviços **sem utilizar imagens prontas de serviços do DockerHub** (`pull_policy: build`). Cada serviço possui seu próprio `Dockerfile` escrito do zero a partir da penúltima versão estável do **Debian (`debian:bullseye`)**, com instalação, configuração de daemons, scripts de inicialização (`PID 1`) e geração automatizada de certificados **SSL/TLS**.

---

## 🎯 Regra Fundamental do Projeto (Zero Pre-Built Images)

Diferente de projetos convencionais que fazem `docker pull nginx` ou `docker pull wordpress`, neste projeto **é estritamente proibido baixar imagens de serviços prontas do DockerHub**.

Toda a pilha foi configurada manualmente a partir do sistema operacional base (`debian:bullseye`):
- **NGINX (`nginx:inception`):** Instalação e configuração manual do servidor web, operando exclusivamente como ponto único de entrada na porta **443 (HTTPS)** com protocolo TLS e proxy reverso FastCGI para o container do WordPress.
- **WordPress + PHP-FPM (`wordpress:inception`):** Instalação do `php-fpm` e do **WP-CLI**, com script de provisionamento (`startup-wp.sh`) que baixa o core do WordPress, configura o `wp-config.php` e cria automaticamente os usuários (administrador e comum) na primeira inicialização.
- **MariaDB (`mariadb:inception`):** Instalação e configuração do servidor de banco de dados (`50-server.cnf`), com script de bootstrap (`mariadb_init_script.sh`) para criação do banco, usuários e permissões.

---

## 🏗️ Arquitetura da Solução

```text
                     [ Host / Cliente (HTTPS :443) ]
                                    │
                                    ▼ (TLSv1.2 / TLSv1.3)
                     ┌─────────────────────────────┐
                     │       nginx:inception       │
                     │   (Único ponto de entrada)  │
                     └──────────────┬──────────────┘
                                    │ Rede interna: wpnet (bridge)
                                    ▼ (FastCGI :9000)
                     ┌─────────────────────────────┐
                     │     wordpress:inception     │
                     │     (PHP-FPM + WP-CLI)      │
                     └──────────────┬──────────────┘
                                    │ Rede interna: wpnet (bridge)
                                    ▼ (TCP :3306)
                     ┌─────────────────────────────┐
                     │      mariadb:inception      │
                     │    (Banco de Dados SQL)     │
                     └─────────────────────────────┘
```

- **Orquestração com Healthchecks:** O `docker-compose.yml` utiliza `depends_on` com `condition: service_healthy`. O WordPress só inicia após o MariaDB responder ao `mysqladmin ping`, e o NGINX só sobe após o `wp core is-installed` confirmar que o WordPress está pronto.
- **Persistência com Bind Volumes:** Os dados do banco (`db_data`) e os arquivos da aplicação (`wp_data`) são persistidos localmente no host em `/home/<USER>/data/db_data` e `/home/<USER>/data/wp_data`.

---

## 📁 Estrutura de Diretórios

```text
inception/
├── Makefile                        # Automação completa (certificados, volumes e containers)
├── README.md                       # Documentação do projeto
├── auxs/                           # Scripts e anotações auxiliares de estudo/configuração
├── secrets/                        # Estrutura de referência para uso de Docker Secrets
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env                        # Arquivo de exemplo com as variáveis de ambiente
    ├── docker-compose.yml          # Definição declarativa dos serviços, redes e volumes
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile          # Build customizado do MariaDB sobre Debian Bullseye
        │   └── conf/
        │       ├── 50-server.cnf
        │       └── mariadb_init_script.sh
        ├── nginx/
        │   ├── Dockerfile          # Build customizado do NGINX sobre Debian Bullseye
        │   └── conf/
        │       ├── default
        │       ├── nginx.conf
        │       └── startup-nginx.sh
        └── wordpress/
            ├── Dockerfile          # Build customizado do PHP-FPM + WP-CLI sobre Debian Bullseye
            └── conf/
                ├── php-fpm.conf
                ├── startup-wp.sh
                ├── wp-config.php
                └── www.conf
```

> 💡 **Nota sobre a pasta `secrets/`:** Neste projeto todas as variáveis sensíveis foram centralizadas no arquivo `srcs/.env`. A pasta `secrets/` na raiz não é consumida ativamente pelo `docker-compose.yml`, tendo sido mantida apenas como referência de estudo sobre onde e como estruturar arquivos para **Docker Secrets** em ambientes que exigem gerenciamento de credenciais via arquivos montados em `/run/secrets/`.

---

## ⚙️ Configuração do Ambiente (`srcs/.env` e Volumes)

Dentro de `srcs/.env` já existe um arquivo de exemplo pré-configurado. Antes de subir o projeto, **ajuste os valores do `srcs/.env` conforme a sua necessidade** (credenciais do banco, usuários do WordPress e domínio):

```ini
[wordpress]
WORDPRESS_DB_HOST=mariadb:3306
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=teste123
WORDPRESS_DB_PASSWORD=teste123

WORDPRESS_ADMIN_USER=erick-super
WORDPRESS_ADMIN_PASSWORD=senha123
WORDPRESS_ADMIN_EMAIL=erramos@gmail.com

WORDPRESS_USER=erick
WORDPRESS_PASSWORD=senha123
WORDPRESS_EMAIL=erickramos@gmail.com

[mariadb]
MYSQL_ROOT_PASSWORD=Senha123
MYSQL_DATABASE=wordpress
MYSQL_USER=teste123
MYSQL_PASSWORD=teste123

SERVER_NAME=erramos.42.fr
```

### Ajustes adicionais ao rodar na sua máquina:
1. **Resolução de Domínio Local (`/etc/hosts`):** Adicione o domínio configurado em `SERVER_NAME` apontando para o seu `localhost` no arquivo `/etc/hosts`:
   ```text
   127.0.0.1   erramos.42.fr
   ```
2. **Caminho dos Volumes no `srcs/docker-compose.yml`:** Na seção `volumes`, ajuste o caminho `/home/erramos/data/...` para o nome do seu usuário no Linux, se necessário.

---

## 🚀 Como Executar (via `Makefile`)

Todo o ciclo de vida do projeto (incluindo verificação do `.env`, geração automática do certificado SSL autoassinado via OpenSSL e criação das pastas de volume) é gerenciado pelo **`Makefile`** na raiz:

### 1. Construir as imagens e iniciar os containers
```bash
# Gera os certificados SSL (se não existirem), cria os diretórios de dados e sobe os containers
make up
```

### 2. Acessar a aplicação
- **Site WordPress:** `https://erramos.42.fr` *(ou o `SERVER_NAME` definido no `.env`)*
- **Painel Admin:** `https://erramos.42.fr/wp-admin`

---

## 🛠️ Comandos Disponíveis no `Makefile`

| Comando | Descrição |
| :--- | :--- |
| `make up` | Gera os certificados SSL (`certs`), cria as pastas de dados em `/home/$USER/data` e inicia os serviços em background |
| `make build` | Valida o `.env`, gera os certificados e constrói/reconstrói as imagens Docker a partir dos `Dockerfile`s |
| `make down` | Para e remove os containers da aplicação |
| `make restart` | Reinicia todos os containers em execução |
| `make logs` | Exibe e acompanha os logs de todos os serviços em tempo real |
| `make shell SERVICE=<nome>` | Abre um terminal interativo (`bash`) dentro do container especificado (ex: `make shell SERVICE=mariadb`, `wordpress` ou `nginx`) |
| `make clean` | Para os containers e remove todas as imagens e volumes criados |
| `make fclean` | Executa limpeza completa: remove containers, imagens, volumes, certificados SSL gerados e apaga os diretórios de dados em `/home/$USER/data` |
| `make re` | Recompila tudo do zero executando `fclean` seguido de `up` |
| `make help` | Lista todos os comandos disponíveis no terminal |

---

## 👤 Autor

**Erick Ramos** — [@erickramosxp](https://github.com/erickramosxp)
