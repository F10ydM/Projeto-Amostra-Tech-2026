# 🗺️ UNImaps — Sistemas de Localização e Acessibilidade

**UNIUBE · Trabalho Integrador · Amostra Tech 2026**

O **UNImaps** é uma plataforma inteligente de localização interna (Indoor GPS) e acessibilidade, desenvolvida para transformar a experiência de navegação dentro do campus da UNIUBE (Via Centro). O sistema resolve a dificuldade de localização de calouros, visitantes e, principalmente, pessoas com mobilidade reduzida em uma infraestrutura complexa.

---

## 🎯 O Problema vs. A Solução

Universidades possuem blocos extensos, corredores interligados e múltiplos andares. Sistemas tradicionais de GPS falham em ambientes internos devido à interferência física.

O **UNImaps** soluciona isso combinando **pontos de referência físicos (QR Codes)** com **modelagem 3D Web** e algoritmos de **Pathfinding (Dijkstra/A*)**. O usuário escaneia um código na parede, seleciona o destino e é guiado em primeira pessoa pelo prédio, diretamente pelo navegador do celular.

---

## ✨ Principais Funcionalidades

* ♿ **Rotas de Acessibilidade Preditiva:** O diferencial central do projeto. Um toggle de acessibilidade recalcula a rota inteira, substituindo escadas normais ou rolantes por rampas e elevadores, garantindo autonomia para PCDs.
* 📱 **Fricção Zero (Sem Instalação):** Construído 100% com tecnologias Web. Não exige download nas lojas de aplicativos. Funciona no Android, iOS, Windows e Linux.
* 📍 **Sincronização via QR Code:** Totens físicos estrategicamente posicionados servem como nós de origem. O escaneamento abre a aplicação já com o ponto de partida definido.
* 🧭 **Navegação em Primeira Pessoa:** HUD de direcionamento, minimapa 2D sincronizado, indicadores de distância e tempo estimado de chegada.
* 🎮 **Campus em 3D:** Modelagem otimizada do 1º pavimento (prédio principal + galpão de engenharias) renderizada de forma leve.

---

## 🛠️ Arquitetura e Tecnologias

A decisão estratégica do projeto foi abandonar motores pesados em favor de uma arquitetura Web nativa e ágil:

* **Front-end & Renderização:** HTML5, CSS3, JavaScript puro e **Three.js** (para renderização 3D via WebGL/WebXR).
* **Lógica de Roteamento:** Implementação customizada dos algoritmos de **Dijkstra** e **A* (A-Star)** operando sobre um grafo de nós e arestas lógicas mapeadas em cima da planta baixa.
* **Deploy & Hospedagem:** Integração Contínua (CI/CD) via GitHub Actions diretamente para a **Vercel**, garantindo carregamento rápido e atualizações instantâneas.

---

## 👥 Equipe e Créditos

Projeto desenvolvido para a disciplina de Trabalho Integrador.

* **Desenvolvedor & Autor:** Arthur Moreira Martins
* **Desenvolvedora & Co-autora:** Maria Eduarda

**Orientadores:** Profs. Camilo, Renato, Romualdo, Maxwell e Kênia.
