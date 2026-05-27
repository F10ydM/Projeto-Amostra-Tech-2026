-- =====================================================================
-- UNIUBE Via Centro · Supabase · Setup completo
-- Trabalho Integrador · Amostra Tech 2026
--
-- ▶ COMO USAR:
--   1. Acesse https://app.supabase.com → seu projeto
--   2. Menu lateral → SQL Editor → New query
--   3. Cole TODO o conteúdo deste arquivo e clique em RUN (ou Ctrl+Enter)
--   4. Verifique em Table Editor: rooms, checkpoints, edges, nav_logs criadas
--   5. Pegue as credenciais em Settings → API:
--        • Project URL  → vai em SUPABASE_CONFIG.url no HTML
--        • anon public  → vai em SUPABASE_CONFIG.anonKey no HTML
--   6. Mude `enabled: false` para `enabled: true` no HTML
--   7. Commit + push pro GitHub → Vercel publica em 30s
-- =====================================================================

-- =====================================================================
-- LIMPEZA (caso esteja rodando segunda vez)
-- =====================================================================
DROP VIEW  IF EXISTS dashboard_uso;
DROP TABLE IF EXISTS nav_logs    CASCADE;
DROP TABLE IF EXISTS edges       CASCADE;
DROP TABLE IF EXISTS checkpoints CASCADE;
DROP TABLE IF EXISTS rooms       CASCADE;

-- =====================================================================
-- 1. TABELAS
-- =====================================================================

-- Salas e ambientes
CREATE TABLE rooms (
  id          text PRIMARY KEY,
  name        text NOT NULL,
  num         text,
  category    text NOT NULL CHECK (category IN
              ('admin','aula','lab_eng','biblio','wc','apoio','elev','circ')),
  floor       smallint NOT NULL DEFAULT 1,
  x           real NOT NULL,
  z           real NOT NULL,
  w           real NOT NULL,
  d           real NOT NULL,
  is_external boolean DEFAULT false,
  created_at  timestamptz DEFAULT now()
);

COMMENT ON TABLE  rooms IS 'Ambientes do campus Via Centro · coordenadas em metros';
COMMENT ON COLUMN rooms.x IS 'Canto sudoeste (origem) eixo X em metros';
COMMENT ON COLUMN rooms.z IS 'Canto sudoeste (origem) eixo Z em metros';

-- QR-Codes físicos espalhados pelo campus
CREATE TABLE checkpoints (
  id       text PRIMARY KEY,
  name     text NOT NULL,
  room_id  text REFERENCES rooms(id) ON DELETE SET NULL,
  x        real NOT NULL,
  z        real NOT NULL,
  y        real NOT NULL DEFAULT 1.5,
  floor    smallint NOT NULL DEFAULT 1,
  qr_url   text UNIQUE,
  active   boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

COMMENT ON TABLE checkpoints IS 'Pontos físicos com QR-Code · usuário escaneia para se localizar';
COMMENT ON COLUMN checkpoints.qr_url IS 'URL embarcada no QR-Code impresso';
COMMENT ON COLUMN checkpoints.active IS 'Desative aqui se o QR estiver indisponível (reforma, etc.)';

-- Arestas do grafo de pathfinding
CREATE TABLE edges (
  id          bigserial PRIMARY KEY,
  from_node   text NOT NULL,
  to_node     text NOT NULL,
  distance    real NOT NULL CHECK (distance >= 0),
  accessible  boolean NOT NULL DEFAULT true,
  is_vertical boolean NOT NULL DEFAULT false
);
CREATE INDEX edges_from_idx ON edges(from_node);
CREATE INDEX edges_to_idx   ON edges(to_node);

COMMENT ON TABLE  edges IS 'Conexões do grafo · usadas pelo Dijkstra';
COMMENT ON COLUMN edges.accessible IS 'false = escada rolante (PCD bloqueado)';
COMMENT ON COLUMN edges.is_vertical IS 'true = transição entre pavimentos';

-- Telemetria anônima de uso
CREATE TABLE nav_logs (
  id          bigserial PRIMARY KEY,
  from_qr     text,
  to_room     text,
  accessible  boolean,
  distance    real,
  duration_ms integer,
  device_type text CHECK (device_type IN ('mobile','desktop','tablet')),
  ts          timestamptz DEFAULT now()
);
CREATE INDEX nav_logs_ts_idx     ON nav_logs(ts DESC);
CREATE INDEX nav_logs_to_idx     ON nav_logs(to_room);

COMMENT ON TABLE nav_logs IS 'Telemetria 100%% anônima (sem IP, sem user-id) · LGPD-compliant';

-- =====================================================================
-- 2. ROW LEVEL SECURITY (RLS)
-- =====================================================================
ALTER TABLE rooms       ENABLE ROW LEVEL SECURITY;
ALTER TABLE checkpoints ENABLE ROW LEVEL SECURITY;
ALTER TABLE edges       ENABLE ROW LEVEL SECURITY;
ALTER TABLE nav_logs    ENABLE ROW LEVEL SECURITY;

-- Leitura pública (qualquer um pode consultar)
CREATE POLICY "public_read_rooms"       ON rooms       FOR SELECT USING (true);
CREATE POLICY "public_read_checkpoints" ON checkpoints FOR SELECT USING (active = true);
CREATE POLICY "public_read_edges"       ON edges       FOR SELECT USING (true);

-- Logs: anyone pode INSERIR (telemetria anônima), mas NINGUÉM lê via anon
CREATE POLICY "public_insert_logs"      ON nav_logs    FOR INSERT WITH CHECK (true);

-- (Para escritas em rooms/checkpoints/edges, usar service_role no painel)

-- =====================================================================
-- 3. SEED · ROOMS (28 ambientes)
-- =====================================================================
INSERT INTO rooms (id, name, num, category, floor, x, z, w, d) VALUES
-- Setor sul · entrada e administrativo
('biblio',   'Biblioteca',                '163',     'biblio', 1,  1,  1, 23,  6),
('cac',      'CAC',                       NULL,      'admin',  1, 25,  1,  6,  3),
('guich',    'Guichês 6-9',               NULL,      'apoio',  1, 31,  1,  6,  3),
('banh_s',   'Banheiros (Sul)',           NULL,      'wc',     1, 37,  1,  6,  3),
('planej',   'Planejamento + TI',         '145',     'aula',   1, 43,  1,  6,  3),
('coord',    'Coord. Cursos',             NULL,      'admin',  1, 25,  4,  6,  3),
('unitec',   'Unitecne / Itec',           NULL,      'admin',  1, 31,  4,  6,  3),
('multijr',  'Multi JR',                  NULL,      'admin',  1, 37,  4,  6,  3),
('ead',      'EaD UNIUBE',                NULL,      'admin',  1, 43,  4,  6,  3),
-- Faixa central
('banh_n',   'Banheiros (Norte)',         NULL,      'wc',     1,  1, 14, 11,  7),
('deposito', 'Depósito',                  '118',     'apoio',  1, 13, 14, 11,  7),
('multi',    'Multiatendimento',          NULL,      'admin',  1, 25, 14, 13,  7),
('xerox',    'Xerox / Reprografia',       '111',     'apoio',  1, 25,  8, 13,  6),
('esctec',   'Escola Técnica',            '112',     'admin',  1, 39,  8,  7,  6),
('escemerg', 'Escada Enclausurada',       NULL,      'circ',   1, 39, 14,  7,  7),
('elev',     'Elevador',                  NULL,      'elev',   1, 46, 14,  3,  3),
('npj',      'Núcleo Práticas Jurídicas', '148',     'apoio',  1, 46,  8,  3,  6),
-- Setor norte · salas 147-156
('s147',     'Sala de Aula',              '147',     'aula',   1,  1, 24,  7, 11),
('s149',     'Sala de Aula',              '149',     'aula',   1,  8, 24,  6, 11),
('s150',     'Docentes Tempo Integral',   '150',     'aula',   1, 14, 24,  6, 11),
('s151',     'Sala de Aula',              '151',     'aula',   1, 20, 24,  5, 11),
('s152',     'Sala de Aula',              '152',     'aula',   1, 25, 24,  5, 11),
('s153',     'Sala dos Docentes',         '153',     'aula',   1, 30, 24,  6, 11),
('s156',     'Sala de Aula',              '156',     'aula',   1, 36, 24,  6, 11),
('conviv',   'Convivência (Pufes)',       NULL,      'circ',   1, 42, 22,  7, 13),
-- Galpão das Engenharias
('lab116a',  'Materiais/Amb./Metrologia', '116-A',   'lab_eng',1, 51,  5, 20,  8),
('lab116b',  'Quím./Física/Bio',          '116-B',   'lab_eng',1, 51, 14, 20,  8),
('lab116cd', 'Oficina Mecânica',          '116-C/D', 'lab_eng',1, 51, 23, 20,  8);

-- =====================================================================
-- 4. SEED · CHECKPOINTS (9 QR-Codes físicos)
-- =====================================================================
-- ⚠ IMPORTANTE: ajuste a URL base abaixo pro domínio real do site na Vercel
INSERT INTO checkpoints (id, name, room_id, x, z, y, qr_url) VALUES
('qr_saguao',  'Saguão Entrada Principal',  'cac',     25.0,  3.0, 1.5, 'https://projeto-amostra-tech-2026-nrqt.vercel.app/?from=qr_saguao'),
('qr_biblio',  'Biblioteca 163',            'biblio',  12.0,  4.0, 1.5, 'https://projeto-amostra-tech-2026-nrqt.vercel.app/?from=qr_biblio'),
('qr_multi',   'Multiatendimento',          'multi',   31.0, 17.0, 1.5, 'https://projeto-amostra-tech-2026-nrqt.vercel.app/?from=qr_multi'),
('qr_xerox',   'Xerox 111',                 'xerox',   31.0, 11.0, 1.5, 'https://projeto-amostra-tech-2026-nrqt.vercel.app/?from=qr_xerox'),
('qr_elev',    'Elevador',                  'elev',    47.5, 15.5, 1.5, 'https://projeto-amostra-tech-2026-nrqt.vercel.app/?from=qr_elev'),
('qr_s147',    'Salas 147-156',             's147',     4.0, 23.0, 1.5, 'https://projeto-amostra-tech-2026-nrqt.vercel.app/?from=qr_s147'),
('qr_conviv',  'Convivência (Setor Norte)', 'conviv',  45.0, 28.0, 1.5, 'https://projeto-amostra-tech-2026-nrqt.vercel.app/?from=qr_conviv'),
('qr_lab_eng', 'Galpão Engenharias 116',    'lab116b', 52.0, 18.0, 1.5, 'https://projeto-amostra-tech-2026-nrqt.vercel.app/?from=qr_lab_eng'),
('qr_npj',     'Núcleo Práticas Jur. 148',  'npj',     47.5, 11.0, 1.5, 'https://projeto-amostra-tech-2026-nrqt.vercel.app/?from=qr_npj');

-- =====================================================================
-- 5. SEED · EDGES (grafo de pathfinding · 18 arestas)
-- =====================================================================
-- Corredor central norte-sul
INSERT INTO edges (from_node, to_node, distance, accessible) VALUES
('c_4',  'c_11', 7.0, true),
('c_11', 'c_17', 6.0, true),
('c_17', 'c_22', 5.0, true),
('c_22', 'c_29', 7.0, true);

-- Corredor leste-oeste em z=17
INSERT INTO edges (from_node, to_node, distance, accessible) VALUES
('cew_4',  'cew_12', 8.0, true),
('cew_12', 'cew_19', 7.0, true),
('cew_19', 'c_17',   5.5, true),
('c_17',   'cew_32', 7.5, true),
('cew_32', 'cew_39', 7.0, true),
('cew_39', 'cew_45', 6.0, true);

-- Núcleo vertical (transições entre pavimentos)
INSERT INTO edges (from_node, to_node, distance, accessible, is_vertical) VALUES
('escal_base', 'c_11',      2.0, false, true),   -- escada rolante NÃO acessível
('rampa_base', 'c_11',      2.5, true,  true),   -- rampa em U (acessível)
('elev_pad',   'room_elev', 1.0, true,  true),   -- elevador
('room_elev',  'cew_45',    2.0, true,  false);

-- Acesso externo (esplanada)
INSERT INTO edges (from_node, to_node, distance, accessible) VALUES
('saguao_ext', 'c_4', 6.0, true);

-- =====================================================================
-- 6. VIEW · Dashboard de uso (lê últimos 7 dias)
-- =====================================================================
CREATE VIEW dashboard_uso AS
SELECT
  to_room AS sala_destino,
  COUNT(*) AS total_rotas,
  ROUND(AVG(distance)::numeric, 1) AS distancia_media_m,
  ROUND(100.0 * SUM(CASE WHEN accessible THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0), 1) AS pct_acessivel,
  ROUND(AVG(duration_ms)::numeric / 1000, 1) AS tempo_medio_s,
  COUNT(*) FILTER (WHERE device_type = 'mobile')  AS via_mobile,
  COUNT(*) FILTER (WHERE device_type = 'desktop') AS via_desktop
FROM nav_logs
WHERE ts > NOW() - INTERVAL '7 days'
GROUP BY to_room
ORDER BY total_rotas DESC
LIMIT 20;

COMMENT ON VIEW dashboard_uso IS 'Top destinos da última semana · útil para próximas apresentações';

-- =====================================================================
-- 7. CONFIRMAÇÃO
-- =====================================================================
SELECT
  'rooms'       AS tabela, COUNT(*) AS registros FROM rooms
UNION ALL SELECT 'checkpoints', COUNT(*) FROM checkpoints
UNION ALL SELECT 'edges',       COUNT(*) FROM edges
UNION ALL SELECT 'nav_logs',    COUNT(*) FROM nav_logs;
-- Esperado: rooms=28, checkpoints=9, edges=18, nav_logs=0
