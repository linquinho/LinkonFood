# 🚀 LinkonFood - Cloud-Native Microservices & DevOps Showcase

O **LinkonFood** é um ecossistema de delivery projetado sob a arquitetura de microsserviços. Este repositório funciona como uma demonstração prática de padrões arquiteturais modernos, unindo o desenvolvimento de software distribuído, Infraestrutura como Código (IaC) e engenharia de observabilidade automatizada na nuvem.

O objetivo deste projeto é demonstrar como orquestrar, proteger e monitorar um ambiente complexo de microsserviços de forma automatizada, eficiente e segura.

---

## 🗺️ Fluxo de Integração e Comunicação

O ecossistema foi projetado para que nenhum microsserviço ou banco de dados fique exposto diretamente à internet. A comunicação entre os componentes é dinâmica e protegida por resiliência nativa.

O diagrama abaixo ilustra o ciclo de vida completo de uma requisição — desde a ação do usuário até a persistência isolada e o mecanismo de tolerância a falhas:

<img width="720" height="720" alt="image" src="https://github.com/user-attachments/assets/187f3de3-a7cc-4034-8f41-28fe8b73fb17" />

### ⏱️ Anatomia do Fluxo:
1. **Entrada Centralizada (API Gateway):** O usuário interage exclusivamente com a borda da aplicação (Gateway). Ele centraliza a segurança e distribui o tráfego de forma inteligente.
2. **Descoberta de Serviço (Service Registry):** O Gateway consulta o catálogo de serviços para localizar dinamicamente a instância ativa do microsserviço de destino, eliminando o uso de IPs e portas fixas na aplicação.
3. **Orquestração de Pedidos:** O microsserviço de **Pedido** processa a intenção de compra, gerencia seu status interno e aciona de forma transparente o microsserviço de **Pagamento**.
4. **Resiliência e Tolerância a Falhas (Circuit Breaker):** Caso o serviço de pagamento sofra um atraso ou instabilidade temporária, o componente de **Circuit Breaker** intercepta a falha (`Timeout`). Ele aciona automaticamente um fluxo alternativo de contingência (`Fallback`), permitindo que a transação mude para o status de *Integração Pendente* sem travar a experiência do usuário.
5. **Persistência Segura:** Cada microsserviço gerencia e persiste seus dados de forma isolada em um banco de dados relacional na nuvem.

---

## 🏢 Arquitetura de Recursos na Nuvem (Cloud Infrastructure)

Toda a infraestrutura física foi modelada declarativamente, garantindo um ambiente altamente disponível, imutável e isolado.

* **Topologia de Rede Privada (VPC Multi-AZ):** Os recursos da nuvem são distribuídos geograficamente em zonas de disponibilidade distintas. Isso garante que, se uma infraestrutura física sofrer uma falha, o ecossistema permaneça online em outra zona.
* **Segregação de Acessos (Camadas de Segurança):** 
  * A aplicação roda em um servidor Linux isolado por um firewall que restringe o tráfego externo apenas para canais autorizados.
  * O banco de dados vive em uma sub-rede privada, sem endereço de internet, configurado para aceitar tráfego exclusivamente do servidor da aplicação.
 
<img width="355" height="323" alt="image" src="https://github.com/user-attachments/assets/c9899232-1771-442b-addb-2a8fc12e4420" />


---

## 📊 Visões de Monitoramento e Validação

Após a execução automatizada, a integridade e o comportamento do ecossistema são acompanhados através de três visões centrais:

* **Painel de Registro de Serviços:** Exibe em tempo real o status de saúde e a localização de cada microsserviço ativo no ecossistema.
* **Roteamento unificado:** Centraliza os pontos de consumo público das rotas de negócio de forma uniforme.
* **Métricas de Performance e APM:** Rastreia o tempo de execução de transações ponta a ponta, permitindo identificar gargalos de código ou lentidão em queries de banco de dados.

---

## 🚀 Fluxo de CI/CD e Automação (GitOps)

Este projeto utiliza pipelines inteligentes no **GitHub Actions** orientados a caminhos (*path-based triggers*). Isso garante que apenas as partes modificadas do projeto sejam processadas, otimizando o tempo de deploy e a segurança do ambiente.

O fluxo de automação funciona da seguinte forma:

---

### 🌐 1. Deploy Automatizado de Infraestrutura (Terraform)
* **Como funciona:** Sempre que um `push` é realizado na branch `main` contendo alterações **exclusivas dentro da pasta `terraform/`**, o GitHub Actions dispara automaticamente o pipeline de infraestrutura.
* **Ações executadas:** O Terraform analisa o estado atual (armazenado no S3), planeja e aplica as alterações diretamente na AWS (atualizando VPC, EC2, RDS, etc.). 
* **Benefício:** É alterado apenas o código da aplicação, a infraestrutura da AWS não será tocada, evitando riscos de queda ou recriação acidental do servidor.

---

### 📦 2. Deploy Automatizado da Aplicação (Docker)
* **Como funciona:** Sempre que um `push` é realizado na branch `main` contendo alterações **dentro das pastas dos microsserviços ou gateway** (ex: `ms-pedidos/`, `ms-pagamentos/`, `api-gateway/`), o GitHub Actions dispara apenas o pipeline de deploy da aplicação.
* **Ações executadas:** A esteira se conecta à EC2 via SSH, envia os novos arquivos via SCP e recria apenas as imagens Docker que sofreram alterações através do comando:
  ```bash
  docker compose up -d --build

---

### 💥 3. Destroy Automatizado da Aplicação (Terraform)
* **Como funciona:** Para evitar custos desnecessários após testes, não é necessário rodar nada no terminal local. Existe um workflow de disparo manual (workflow_dispatch) configurado diretamente no painel do GitHub Actions chamado AWS Destroy.
* **Ações executadas:** O próprio GitHub Actions inicializa um runner, conecta-se ao backend remoto no S3 e executa de forma totalmente automatizada o comando terraform destroy -auto-approve, eliminando 100% dos recursos ativos na AWS em poucos minutos de forma limpa e segura.

  
