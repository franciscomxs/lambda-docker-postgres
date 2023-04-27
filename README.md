## Setup de desenvolvimento local:

Serão necessárias algumas envs:

```bash
export AWS_ACCOUNT_ID=000000000000
export ARN=arn:aws:iam::$AWS_ACCOUNT_ID:role/AwsLambdaFullAccess
export AWS_REGION=sa-east-1
export APP=MyAppName
```

Para execução do projeto local, faremos uso do docker compose, de modo a criar um banco de dados postgres acessível para a aplicação e permitindo a execução em ambiente similar ao de produção.

Para executar o serviço execute:

```bash
make run
```

Para acessar o bash do container em execução, execute:

```bash
make bash
# Aqui são acessíveis comandos como `irb` ou `psql`:
psql postgres://user:password@db:5432/app_db
```
Segue a lista de comandos disponíveis:


## Ambiente de Desenvolvimento
### Comandos:

- `make bash`: Abre um interactive shell no container da aplicação.
- `make run`: Inicia a aplicação na porta 9000.
- `make test`: Faz uma requisição local.

## Ambiente de Produção

### Versionamento


[Referência](https://semver.org/) - Dado um número de versão `MAJOR`.`MINOR`.`PATCH`, incremente:

- `MAJOR` quando ocorrerem mudanças na API que as tornem incompatíveis;
- `MINOR` quando adicionar novas funcionalidades que mantém a compatibilidade;
- `PATCH` para bugfixes que mantém a compatibilidade;

### Comandos

- `make setup VERSION=0.0.1`: Faz o setup do AWS ECR e AWS Lambda.
- `make release VERSION=1.0.0`: Faz uma nova release.

## Testing:

```bash
docker-compose -f docker-compose-dev.yml run app bundle exec rspec
```

## Migrations:

Inside container:

```bash
# Up
bundle exec sequel -m db/migrations $DATABASE_URL

# Down
bundle exec sequel -m db/migrations -M 0 $DATABASE_URL
```
