# Projeto exemplo sobre Terraform

## 1. O que é o terraform ?

Terraform é uma ferramenta IaC (infraestutura as code) que permite criar, mudar e disponibilizar recursos de infraestrutura de forma segura utilizando código.

É uma ferramenta Open Source, disponibilizada pela Hashicorp, a qual integra-se com inúmeros cloud providers.

Com o Terraform é possível definir, de maneira declarativa e usando código, a infraestrutura. Para isso, o terraform utiliza linguagem própria para as definições do código e CLI própria para gerenciar a implemantação, estado e plugins da infraestutura.

## 2. Sobre a sintaxe declarativa do terraform

O Terraform possui linguagem própria a qual permite a sua CLI utilizar o seu interpretador para realizar as implementações de infraestrutura.

O principal objetivo da linguagem é declarar recursos de infraestrutura, a qual é representada por objetos da cloud provider.

```terraform
resource "aws_vpc" "main" {
  cidr_block = var.base_cidr_block
}

<BLOCK TYPE> "<BLOCK LABEL>" "<BLOCK LABEL>" {
  # Block body
  <IDENTIFIER> = <EXPRESSION> # Argument
}
```

**A estrutura de linguagem do Terraform consistem em elementos:**

### Blocos

São definições de implementações que representam configurações da infraestrutura. Por exemplo, definir o recurso VPC, subnets e etc. 

Os blocos podem receber nenhum ou vários labels, os quais são utilizados para identificar e reutilizar o bloco em outras declarações de blocos.

### Identificadores

São representações da configurações do recurso que é implementado no bloco. Por exemplo, um ip de subnet, role de uma IAM, etc.

### Expressões

Representa a definição do identificador. A expressão é o valor do identificador.

> A ordem dos blocos não tem interferência no resultado final. O Terraform considera o relacionamento entre blocos algo implícito e explícito.


**Exemplo de configuração do Terraform**
```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 1.0.4"
    }
  }
}

variable "aws_region" {}

variable "base_cidr_block" {
  description = "A /16 CIDR range definition, such as 10.1.0.0/16, that the VPC will use"
  default = "10.1.0.0/16"
}

variable "availability_zones" {
  description = "A list of availability zones in which to create subnets"
  type = list(string)
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  # Referencing the base_cidr_block variable allows the network address
  # to be changed without modifying the configuration.
  cidr_block = var.base_cidr_block
}

resource "aws_subnet" "az" {
  # Create one subnet for each given availability zone.
  count = length(var.availability_zones)

  # For each subnet, use one of the specified availability zones.
  availability_zone = var.availability_zones[count.index]

  # By referencing the aws_vpc.main object, Terraform knows that the subnet
  # must be created only after the VPC is created.
  vpc_id = aws_vpc.main.id

  # Built-in functions and operators can be used for simple transformations of
  # values, such as computing a subnet address. Here we create a /20 prefix for
  # each subnet, using consecutive addresses for each availability zone,
  # such as 10.1.16.0/20 .
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index+1)
}
```

## 3. Tipos de valores e operações no Terraform

Por ser IaC, o Terraform tem capacidade de receber tipos de valores como outra linguagem de programação. 

Os tipos de valores que pode ser aplicados são:

- Boolean;
- Number;
- Object;
- Array;
- Null;

Desta forma, é possível realizar operações como:

- Claúsulas condicionais;
- Contar itens de uma lista;
- Realizar operações entre números;
- Concatenar strings;
- Aplicar valor null;
- etc.

## 4. Nested Block Mapping de tipos Object

O Terraform consegue interpretar estrutura simplificada de Nested Objects. Dessa forma é possível simplificar escritas como:

**De:**
```
{
  "resource": {
    "aws_instance": {
      "example": {
        "lifecycle": {
          "create_before_destroy": true
        }
      }
    }
  }
}
```
**Para:**
```
resource "aws_instance" "example" {
  lifecycle {
    create_before_destroy = true
  }
}
```

## 5. Tipos de blocos do Terraform

Blocos são estruturas que configura de recursos e outras definição de configurações do cloud provider.

Há especificidades no Terraform quanto a implementação desses blocos para que a configuração da infraestrutura seja aplicada corretamente. Para isso, o Terraform divide essas configurações em tipos de blocos no arquivo de configuração. 

Estes são os tipos de blocos do Terraform:

### Resources

Representam objetos com definições das configurações da ingraestrutura. Cada "resource" possui itens relacionado que definem o objeto que está sendo configurado para essa infraestrutura. 

A sintaxe para um block de resource:

```
resource "aws_istance" "example" {
	provider = "aws.foo"
}
```

Este trecho pode conter definições de relacionamento entre outros blocos. Algumas das definições existente e que correlacionam os blocos:

- **depends_on:** Define um array de referências a qual o bloco necessita para ser executado;
- **ignore_changes:** Define quais itens de outros blocos podem ser ignorados para que ele seja executado;

## 6. Tipos de resources

Cada resource é associado a um tipo. Este tipo determina o objeto de configuração de infraestrutura a qual o terraform irá gerenciar.

### Providers

Determina a configuração e premisas da infraestrtura a ser implementada. Os providers podem ser do tipo:

**Requirements** 

Declara os providers e os módulos que é utilizada.

```
terraform "required_providers" "my_cloud" {
	source = 'mycorp/mycloud'
	version = '~> 1.0'
}

terraform "required_providers" "hashicorp-http" {
	source = 'mycorp/http'
	version = '~> 1.0'
}

terraform "required_providers" "mycorp-http" {
	source = 'mycorp/http'
	version = '~> 1.0'
} 
```

**Configuration**

Provê as configurações de provider para cada resource.

```
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}
```

### Meta arguments

São tipos de recursos utilizados no terraform language para executar trecho dos block. Os meta-argumentos são:

- `[depends_on`, for specifying hidden dependencies](https://www.terraform.io/language/meta-arguments/depends_on)
- `[count`, for creating multiple resource instances according to a count](https://www.terraform.io/language/meta-arguments/count)
- `[for_each`, to create multiple instances according to a map, or set of strings](https://www.terraform.io/language/meta-arguments/for_each)
- `[provider`, for selecting a non-default provider configuration](https://www.terraform.io/language/meta-arguments/resource-provider)
- `[lifecycle`, for lifecycle customizations](https://www.terraform.io/language/meta-arguments/lifecycle)
- `[provisioner`, for taking extra actions after resource creation](https://www.terraform.io/language/resources/provisioners/syntax)


### Variables
Variables são definições de valores as quais podem ser aplicadas aos resourcers. As variables podem ser reutilizadas entre arquivos de configuração do Terraform.

As variables possuem “tipo”, "valor padrão” e descrição. Podem ser implementadas da seguinte forma:

```
variable "example" {
	type = "string"
  default = "Hello"
	description = "Aqui vai a descrição da variável"
}
```

### Outputs

São definições de saída após a implantação do arquivo de configuração na infraestrutura.

Esses outputs são ids, endereços de rede, regras implatadas e etc. Os outputs são escritos pelo próprio Terraform durante a implementação do arquivo de configuração.

São implementados da seguinte forma:

```
resouce "aws_instace" "create" {
	instance_type = "t2.micro"
}

output "example" {
	value = aws_instace.create.id
}
```

### Locals

Representam valores locais que podem ser utilizados em outros blocos.

São implementados da seguinte forma:

```
locals {
	instance_name = "${var.instance_name}_aws_instance"
}

resouce "aws_instace" "create" {
	instance_type = "t2.micro"
  name = local.instance_name
}
```

### Modules

Módulos são blocos compactados de configurações de resources. São utilizados para executar resources criados em outras partes da configuração de infraestrutura.

```
module "example" {
	source = 'hashicorp/consul/azurecrm'
	version = '1.0.0'
	providers.aws = 'aws.usw1'
}
```

### Providers

Providers referem-se ao alias e versão da cloud que está sendo implementada pelo projeto.

```
provider "aws" {
	region = 'us-east-1'
}
```

### Terraform

Refere-se a configuração e versão do terraform que está sendo utilizado no projeto, assim como o local onde o tfstate é armazenado e versionado.
```
terraform {
    required_version = ">=0.13.1"
    required_providers {
      aws = ">=3.54.0"
      local = ">=2.1.0"
    }
    backend "s3" {
      bucket = "myfcbucket"
      key    = "terraform.tfstate"
      region = "us-east-1"
    }
}
```

## 7. Verificações customizadas de implantação
Durante a implantação da infraestrutura é possível realizar verificações para confirmar se as configurações a ser implantadas seguem uma lista pré-determinada de condições.

```
resource "aws_instance" "example" {
  instance_type = "t2.micro"
  ami           = "ami-abc123"

  lifecycle {
    precondition {
      condition     = data.aws_ami.example.architecture == "x86_64"
      error_message = "The selected AMI must be for the x86_64 architecture."
    }
  }
}
```
Isso facilita o entendimento sobre recursos mínimos, ajudar futuros mantenedores e aplicar o design de configuração.

### Timeouts

Alguns recursos necessitam ter um prazo máximo de operação. Baseado nisso, o terraform permite definir, para cada bloco de recurso, o tempo máximo de execução para operações "create", "update" e "delete". 

Veja como é aplicado:
```
resource "aws_db_instance" "example" {
  timeouts {
    create = "60m"
    delete = "2h"
  }
}
```

## 8. Arquivos e configurações necessárias

O terraform tem estrutura e organização própria para utilização dos seus arquivos de configuração.

Os arquivos do terraform possuem as seguintes extensões:

- **Arquivos de configuração**: É utilizado o `.tf`
- **Arquivos de variáveis**: É utilizado o `.tfvars`
- **State da infraestrutura**: É utilizado o `.tfstate`
- **Arquivo Lock que possui o versionamento das configurações e plugins**: É utilizado o `.lock.hct`