# ⚙️ Documentação Técnica — UNImaps

Este documento detalha a infraestrutura de código e a lógica matemática por trás do sistema de roteamento do UNImaps.

## 1. Topologia e Grafo
O mapa do campus não é apenas um modelo 3D estático; ele possui uma camada invisível de dados lógicos (um Grafo).
* **Nós (Nodes):** Representam cruzamentos de corredores, portas de salas, bases de escadas e entradas de elevadores.
* **Arestas (Edges):** Conectam os nós, contendo o peso (distância física real) e uma flag booleana de acessibilidade (`accessible: true/false`).

## 2. O Algoritmo de Pathfinding (Dijkstra)
A busca pelo menor caminho é executada no lado do cliente (client-side) para garantir resposta imediata. 

**Como funciona a adaptação para Acessibilidade:**
Quando o usuário ativa o modo PCD (Pessoa com Deficiência), o algoritmo ignora completamente todas as arestas do grafo onde `accessible === false` (ex: a escada rolante do Gaudium Hall). O cálculo de relaxamento dos nós é forçado a encontrar o caminho ótimo utilizando apenas a rampa em "L" ou o elevador, protegendo o usuário de barreiras físicas.

## 3. Desempenho e Three.js
Para rodar em navegadores de celulares modestos sem travar:
* Geometrias primitivas do `Three.js` (BoxGeometry, PlaneGeometry) são utilizadas no lugar de importações pesadas (como `.obj` ou `.gltf`).
* Materiais básicos (`MeshBasicMaterial` e `MeshLambertMaterial`) para reduzir o custo computacional de cálculo de luz e sombra em tempo real.
* `InstancedMesh` é utilizado de forma agressiva em elementos repetitivos (como os degraus da escada rolante e os pingentes do forro) para manter as chamadas de desenho (draw calls) mínimas na GPU.

## 4. Integração QR Code
A URL contida nos QR Codes físicos carrega parâmetros (ex: `unimaps.vercel.app/?from=qr_saguao`). O script JavaScript lê esse parâmetro via `URLSearchParams` ao inicializar, injeta o ponto de partida no algoritmo de Dijkstra e move a câmera 3D para as coordenadas exatas do totem no mundo virtual.
