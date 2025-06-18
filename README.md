# 🤖 Projeto A.L.I.C.E – Chatbot Inteligente com Dados do Azure DevOps

Este repositório contém o desenvolvimento da POC do projeto **A.L.I.C.E** (Assistente Lógico Inteligente para Consolidação de Estatísticas), um chatbot baseado em IA que responde a perguntas relacionadas ao ciclo de vida do desenvolvimento de software, utilizando dados extraídos via API do Azure DevOps.

---

## 📌 Objetivo do Projeto

Construir um chatbot que integre dados armazenados em nosso banco (coletados via API do Azure DevOps) e utilize modelos de linguagem (LLM) para responder a perguntas como:

- "Quantos bugs foram abertos nesta sprint?"
- "Quais pull requests estão em aprovação?"
- "Qual a média de tempo de resolução de tarefas?"

---

## 🚀 Como iniciar o desenvolvimento

### 1. Clone o repositório

```bash
git clone https://github.com/inovvatidados/projeto-alice.git
cd projeto-alice
git checkout dev
```

### 2.  Crie e Ative o Ambiente Virtual
```bash
python -m venv .venv
source .venv/bin/activate      # Linux/macOS
.venv\Scripts\activate         # Windows
```

### 3. Instale as Dependências
```bash
pip install -r requirements.txt
```

### 4. Configure as Variáveis de Ambiente
- Copie o arquivo ".env.example" para outro somente com ".env".
- Altere as informações para as reais.

### Estrutura do Projeto
```bash
projeto-alice/
│
├── data/                 # Dados tratados ou amostras para testes
├── notebooks/            # Jupyter notebooks para testes exploratórios
├── src/                  # Código-fonte do chatbot
│   ├── data_loader.py    # Carregamento e pré-processamento dos dados
│   ├── chatbot.py        # Lógica de integração com LLM
│   └── utils.py          # Funções auxiliares
├── .env.example          # Exemplo de configuração de ambiente
├── .gitignore            # Arquivos ignorados pelo Git
├── requirements.txt      # Lista de dependências Python
└── README.md             # Este arquivo
```