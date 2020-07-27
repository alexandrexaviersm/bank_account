# BankAccount
![actions](https://github.com/alexandrexaviersm/bank_account/workflows/actions/badge.svg)

Backend - Bank account opening API

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`
  
# Passo a passo para testar a API:
  Ao rodar o Setup da aplicação, um seed é rodado para criar um usuário DEMO. Esse usuário possui um "referral_code": "12345678" que deverá ser utilizado pelo Primeiro Costumer que quiser se cadastrar na aplicação.
  
  Com a aplicação rodando, utilize o POSTMAN para fazer uma requisição PATCH na rota:
  (antes é necessário configurar o HEADER -> Content-Type: application/json )
  
  localhost:4000/api/v1/customers/update
  
  com o body: 
{
    "cpf": "411.562.990-80",
    "name": "Foo Bar",
    "email": "foo@bar.com",
    "birth_date": "1994-01-01",
    "country": "BR",
    "state": "SP",
    "city": "Sao Paulo",
    "gender": "not_identify",
    "referral_code": "12345678"
}

Pronto ! Nesse momento todos os dados do usuário já foram cadastrados e sua conta está com o status Complete. Repare na resposta do servidor:

{
    "data": {
        "referral_code_to_be_shared": "LsaXdM2L",
        "status": "complete"
    },
    "status": "ok"
}

Compartilhe o referral_code_to_be_shared com outros usuários possam se cadastrar no sistema com o seu referral_code.
Nessa requisição você também recebeu um JWT Token que deverá ser utilizado caso queira ver quais os usuários que se cadastraram no sistema com o seu referral_code

Para isso, verifique o Header da resposta da requisição, ache o campo jwt_token e copie o seu valor:

Depois faça uma requisição POST na rota /customers/update, mas antes, coloque um header com o valor do TOKEN que você copiou:

Verifique a coluna Authorization no POSTMAN e selecione a Oçpão 
-> Bearer Token 
em seguida cole o seu JWT TOKEN como valor.

localhost:4000/api/v1/customers/update

RESPOTA:

{
    "data": [],
    "status": "ok"
}

Significa que nenhum usuário se cadastrou no sistema utilizando o seu referral_code. Assim que eles se cadastrarem, os nomes e IDS deles apareceram dentro da lista data.

OBS:
O CPF pode ser digitado no formato "111.222.333-44" ou "11122233344"
O sistema só aceita CPF válidos (fique a vontade para gerar alguns aleatórios para testar a aplicação)
Campo name: de 3 a 100 caracteres, caso tente algo diferente, o erro será exibido 

{
    "errors": {
        "name": [
            "should be at least 3 character(s)"
        ]
    },
    "status": "unprocessable entity"
}

Outras validações:
email: REGEX está validando o formato do email
country: Somente 2 dígitos (ex: BR ou US). Existe uma lista que verifica se o código do país existe. 
state: Somente 2 dígitos
referral_code: Precisa entrar com algum código que já foi gerado para outro usuário. Caso você seja o primeiro usuário, entre com o código DEMO "12345678"


 


# Racional por trás da modelagem da solução:
Minha principal preocupação ao desenvolver essa aplicação foi a segurança dos dados sensíveis do usuário. Acredito que esse foi o maior desafio na implementação (e o que fez alguns módulos ficarem mais extensos do que o previsto, porém me faltou tempo para fazer algumas refatorações necessárias)... Logo no início do desafio já me deparei com o requisito de que alguns dados (name, email, cpf, birth_date) deveriam ser ser criptografados, porém o nome do usuário, além de criptografado, ele poderia ser visualizado pelo usuário que forneceu o referral_code. Acredito que realizei esse feito de uma maneira super segura:
Utilizei o método "Per-user encryption", que necessita de um token para criptografar e descriptografar algum dado. Como o CPF é o único campo obrigatório, eu utilizei ele como o token, então somente o portador do CPF pode descriptografar os campos criptografados. Além disso, gerei um unique_salt para cada customer (utilizando a bilioteca :crypto do erlang). A chave para critografar um campo é uma combinação do customer_id + cpf + salt:

  def generate_unique_salt do
    :crypto.strong_rand_bytes(16)
    |> :base64.encode()
  end

  def generate_secret_key(uuid, cpf, salt) do
    digest_source = cpf <> salt <> uuid

    :crypto.hash(:sha512, digest_source)
    |> :base64.encode()
    |> String.reverse()
    |> String.slice(0, 24)
    |> String.reverse()
  end

Então para criptografar um dado, eu gero o salt (que fica salvo no banco) e depois gero a secret_key dinamicamente, e ela é sempre utilizada na criptografia e descriptografia dos dados. Os campos criptografados estão na tabela Customer com os nomes (encrypted_birth_date, encrypted_email, encrypted_name e encrypted_name_to_be_shared). Logo mais comento sobre o campo encrypted_name_to_be_shared.

Percebe que não salvo o CPF criptografado no banco. No caso do CPF, eu gero somente uma hash (cpf_hash) utilizando a lib Bcrypt que é muito ulitizada para salvar hash de senhas no banco de dados, sendo praticamente impossível alguém conseguir obter o valor real.

O campo encrypted_name_to_be_shared funciona um pouco diferente, esse campo precisa ser compartilhado com outros usuário, pois o dono do referral_code pode visualizar os nomes dos usuários que se cadastraram no sistema utilizando ele. Para isso ser possível de uma maneira segura, eu criptografei esse campo com base no referral_code. Dessa forma somente o dono do referral_code consegue visualizar os nomes desses usuários.

Além disso, a API utiliza a lib Guardian que gera um token quando um usuário se cadastra no sistema. Quando o client quiser verificar os usuários que se cadastraram utilizando o referral_code em questão, esse token gerado deve ser enviado no header na requisição, aumentando mais ainda a segurança, pois impede que qualquer outra pessoa verifique os nomes dos usuários.

Então consegui chegar nas seguintes condições:
-> CPF está salvo como uma senha, de forma super segura
-> dados sensíveis são criptografados com o CPF + salt + UUID + algoritmo :sha512
-> dados só pedem ser descriptografados quando o usuário fornece seu CPF
-> Nomes que podem ser compartilhados são salvos de outra forma, permitindo que somente usuários relacionados com o referral_code possam ver os nomes.


# RESUMO DA APLICAÇÃO: 

2 Endpoints: 
patch /api/v1/customers/update -> Rota para fazer o UPSERT dos Customers, verifica se o CPF informado já existe no sistema (como salvo apenas o hash do cpf, utilizo o método Bcrypt.verify_pass(cpf, customer.cpf_hash), então se o usuário não existe, um novo é criado, caso contrário apenas seus dados são atualizados).

post /api/v1/customers/indications -> Rota para os customers verificarem os nomes dos usuários que se cadastraram no sistema utilizando seu referral_code (rota autenticada, será necessário enviar o JWT token no header, esse token é gerado na rota anterior).

Tabelas

    create table(:customers, primary_key: false) do
      :id, :uuid, primary_key: true
      :city, :string
      :country, :string
      :encrypted_name, :string
      :encrypted_name_to_be_shared, :string
      :encrypted_email, :string
      :cpf_hash, :string, null: false
      :encrypted_birth_date, :string
      :gender, GenderType.type()
      :referral_code, :string, size: 8
      :state, :string
      :unique_salt, :string, null: false
      timestamps()
    

   create table(:accounts, primary_key: false) do
      :id, :uuid, primary_key: true

      :status, AccountStatus.type(),
        null: false,
        default: "pending"

      :referral_code_to_be_shared, :string, size: 8
      :customer_id, references(:customers, on_delete: :nothing, type: :uuid)
      timestamps()

