# Inception - Docker Containerization Project

Um projeto completo de containerização Docker que demonstra a criação de imagens customizadas e orquestração de serviços usando Docker Compose.

## 📋 Visão Geral

Este projeto implementa uma arquitetura de microserviços containerizada com três componentes principais:

- **WordPress** - CMS personalizado em container próprio
- **MySQL** - Banco de dados em container isolado
- **NGINX** - Servidor web reverso como ponto de entrada único

### 🏗️ Arquitetura

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│                 │    │                 │    │                 │
│     NGINX       │◄───┤   WordPress     │◄───┤     MySQL       │
│  (Port 80/443)  │    │   (Internal)    │    │   (Internal)    │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        ▲
        │
   Acesso Host
```

## 🐋 Sobre as Imagens Docker

### Base das Imagens

Todas as imagens são construídas a partir do **Debian 11 (Bullseye)**, a versão penúltima do Debian, garantindo:

- Estabilidade comprovada
- Amplo suporte da comunidade
- Compatibilidade com pacotes essenciais
- Base sólida para containers de produção

### Imagens Customizadas

#### 🌐 NGINX

- **Base**: `debian:bullseye`
- **Função**: Servidor web reverso e ponto de entrada único
- **Portas Expostas**: 80, 443 (única imagem com portas expostas ao host)
- **Responsabilidades**:
  - Servir conteúdo estático
  - Proxy reverso para WordPress
  - Terminação SSL/TLS
  - Load balancing (se necessário)

#### 📝 WordPress

- **Base**: `debian:bullseye`
- **Função**: Sistema de gerenciamento de conteúdo
- **Rede**: Comunicação interna apenas
- **Responsabilidades**:
  - Processamento PHP
  - Interface de administração
  - Geração de conteúdo dinâmico
  - Conexão com banco de dados

#### 🗄️ MySQL

- **Base**: `debian:bullseye`
- **Função**: Sistema de gerenciamento de banco de dados
- **Rede**: Comunicação interna apenas
- **Responsabilidades**:
  - Armazenamento de dados persistente
  - Gerenciamento de transações
  - Backup e recuperação de dados

## 🚀 Configuração e Uso

### Pré-requisitos

- Docker Engine 20.10+
- Docker Compose 2.0+
- Git

### Instalação

1. **Clone o repositório**

   ```bash
   git clone https://github.com/erickramosxp/inception.git
   cd inception
   ```
2. **Construa as imagens**

   ```bash
   make build
   ```
3. **Inicie os serviços**

   ```bash
   make up
   ```
4. **Acesse a aplicação**

   - WordPress: `http://<SERVER_NAME>`
   - Admin WordPress: `http://<SERVER_NAME>/wp-admin`

### Comandos Úteis

```bash
# Visualizar logs dos containers
make logs

# Parar todos os serviços
make down

# Reconstruir e reiniciar
docker-compose down && docker-compose build && docker-compose up -d

# Acessar shell de um container
make shell SERVICE=nginx
make shell SERVICE=wordpress
make shell SERVICE=mysql

# Verificar status dos containers
docker-compose ps

# Visualizar recursos utilizados
docker stats
```

## 📁 Estrutura do Projeto

```
inception/
├── Makefile
├── README.md
├── create_folders.sh
├── secrets
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs
    ├── docker-compose.yml		# Orquestração dos serviços
    ├── .env 				# Variáveis de ambiente
    └── requirements
        ├── mariadb
        │   ├── Dockerfile		# Imagem customizada MySQL
        │   ├── conf
        │   │   ├── 50-server.cnf
        │   │   ├── mariadb.cnf
        │   │   ├── mariadb_init_script.sh
        │   │   └── requirements.txt
        │   └── tools
        ├── nginx
        │   ├── Dockerfile		# Imagem customizada NGINX
        │   ├── conf
        │   │   ├── default
        │   │   ├── nginx.conf		# Configuração do servidor
        │   │   └── startup-nginx.sh
        │   └── tools
        ├── tools
        └── wordpress
            ├── Dockerfile		# Imagem customizada WordPress
            ├── conf
            │   ├── php-fpm.conf
            │   ├── startup-wp.sh
            │   ├── wp-config.php	# Configuração WordPress
            │   └── www.conf
            └── tools
                └── wait-for-it.sh
```

## 🔒 Segurança

### Isolamento de Rede

- Apenas o NGINX tem portas expostas ao host
- WordPress e MySQL comunicam através de rede interna Docker
- Containers isolados em rede bridge customizada

### Variáveis de Ambiente

- Senhas e chaves em arquivo `.env`
- Credenciais não expostas em código
- Rotação periódica recomendada

### Volumes Persistentes

- Dados MySQL em volume dedicado
- Arquivos WordPress em volume separado
- Backup regular dos volumes recomendado

## 🔧 Docker Compose

O Docker Compose é utilizado para:

### Orquestração de Serviços

- Definição declarativa da infraestrutura
- Gerenciamento de dependências entre containers
- Configuração de rede interna
- Mapeamento de volumes persistentes

### Benefícios

- **Simplicidade**: Um comando para todo o ambiente
- **Reprodutibilidade**: Ambiente idêntico em qualquer máquina
- **Escalabilidade**: Fácil adição de novos serviços
- **Manutenibilidade**: Configuração centralizada

### Exemplo de Configuração

```yaml
version: '3.8'
services:
  nginx:
    build: ./nginx
    ports:
      - "443:443"
    depends_on:
      - wordpress
    networks:
      - inception

  wordpress:
    build: ./wordpress
    depends_on:
      - mysql
    networks:
      - inception

  mysql:
    build: ./mysql
    networks:
      - inception
    volumes:
      - mysql_data:/var/lib/mysql

networks:
  inception:
    driver: bridge

volumes:
  mysql_data:
  wordpress_data:
```

## 📊 Monitoramento

### Logs

- Logs centralizados via Docker Compose
- Rotação automática de logs
- Níveis de log configuráveis

### Métricas

- Uso de CPU e memória via `docker stats`
- Monitoramento de disco dos volumes
- Health checks para cada serviço

## 🛠️ Desenvolvimento

### Ambiente de Desenvolvimento

```bash
# Modo desenvolvimento com hot reload
docker-compose -f docker-compose.dev.yml up

# Debug de um serviço específico
docker-compose up nginx mysql
docker-compose exec wordpress bash
```

### Testes

```bash
# Teste de conectividade
docker-compose exec nginx curl -I http://wordpress

# Teste de banco de dados
docker-compose exec mysql mysqladmin ping

# Teste de performance
docker-compose exec nginx ab -n 100 -c 10 http://wordpress/
```

## 🚨 Solução de Problemas

### Problemas Comuns

#### Container não inicia

```bash
# Verificar logs
docker-compose logs [service_name]

# Verificar configuração
docker-compose config

# Reconstruir imagem
docker-compose build --no-cache [service_name]
```

#### Problemas de conectividade

```bash
# Verificar rede
docker network ls
docker network inspect inception_default

# Testar conectividade interna
docker-compose exec nginx ping wordpress
docker-compose exec wordpress ping mysql
```

#### Problemas de performance

```bash
# Monitorar recursos
docker stats

# Verificar logs de erro
docker-compose logs nginx | grep error
docker-compose logs wordpress | grep error
docker-compose logs mysql | grep error
```

## 🔄 Backup e Recuperação

### Backup dos Dados

```bash
# Backup MySQL
docker-compose exec mysql mysqldump -u root -p wordpress > backup.sql

# Backup volumes
docker run --rm -v inception_mysql_data:/data -v $(pwd):/backup ubuntu tar czf /backup/mysql_backup.tar.gz /data
```

### Recuperação

```bash
# Restaurar MySQL
docker-compose exec -T mysql mysql -u root -p wordpress < backup.sql

# Restaurar volumes
docker run --rm -v inception_mysql_data:/data -v $(pwd):/backup ubuntu tar xzf /backup/mysql_backup.tar.gz -C /
```

## 📚 Recursos Adicionais

### Documentação

- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Debian Official Images](https://hub.docker.com/_/debian)

### Melhores Práticas

- [Docker Best Practices](https://docs.docker.com/develop/best-practices/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Security Best Practices](https://docs.docker.com/engine/security/)

## 👥 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## ✨ Autor

**Erick Ramos**

- GitHub: [@erickramosxp](https://github.com/erickramosxp)

---

⭐ **Se este projeto foi útil para você, considere dar uma estrela!**
