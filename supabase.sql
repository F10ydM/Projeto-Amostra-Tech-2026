-- =====================================================================
-- UniMaps · Via Centro Uniube · 1º pavimento
-- Schema + seed para Supabase (Postgres).
-- Rode no SQL Editor do Supabase (cole tudo e execute).
-- =====================================================================

-- ---------- TABELAS ----------
create table if not exists blocos (
  id    text primary key,
  nome  text not null,
  x     real not null,
  y     real not null,
  w     real not null,
  h     real not null,
  cat   text not null default 'neutro'   -- predio | entrada | neutro | vertical | amarela | destino
);

create table if not exists nos (
  id        text primary key,
  nome      text,
  x         real not null,
  y         real not null,
  tipo      text default 'corredor',     -- corredor | entrada | destino | escada | rampa | elevador
  acessivel boolean default true
);

create table if not exists arestas (
  id        bigint generated always as identity primary key,
  de        text not null references nos(id),
  para      text not null references nos(id),
  peso      real not null default 1,
  tipo      text default 'corredor',     -- corredor | escada | rampa | elevador
  acessivel boolean default true
);

-- QR físico -> nó de origem (o "você está aqui")
create table if not exists qr (
  codigo      text primary key,
  no_origem   text not null references nos(id)
);

-- ---------- SEED: blocos (planta) ----------
insert into blocos (id,nome,x,y,w,h,cat) values
  ('predio','Prédio (1º pavimento)',2,2,48,38,'predio'),
  ('portaria','Portaria principal',36,36.5,8,3,'entrada'),
  ('unitecne','Unitecne / Nupeia',31,23,4.5,16.5,'neutro'),
  ('coord','Coordenadores de cursos',44.5,23,4.5,16.5,'neutro'),
  ('multi','Multiatendimento',36,16.5,10,3.5,'neutro'),
  ('escada','Escadas rolantes',28.5,15,6,2.5,'vertical'),
  ('via159','Via 159 · Sala de estudos',19.5,12.5,8.5,7.5,'neutro'),
  ('via161','Via 161 · depósito',14,14,4,5,'neutro'),
  ('amarela','Parede amarela',2,15.5,2,13,'amarela'),
  ('via158','Sala de Docentes · Via 158',5,13.5,7.5,6.5,'destino'),
  ('s1','Sala de aula',6,25,2.5,6,'neutro'),
  ('s2','Sala de aula',9.5,25,2.5,6,'neutro'),
  ('s3','Sala de aula',15.5,25,2.5,6,'neutro'),
  ('s4','Sala de aula',19,25,2.5,6,'neutro'),
  ('s5','Sala de aula',25,25,2.5,6,'neutro'),
  ('s6','Sala de aula',28,25,2.5,6,'neutro')
on conflict (id) do update set nome=excluded.nome,x=excluded.x,y=excluded.y,w=excluded.w,h=excluded.h,cat=excluded.cat;

-- ---------- SEED: nós (grafo do A*) ----------
insert into nos (id,nome,x,y,tipo,acessivel) values
  ('portaria','Portaria principal',40,37.5,'entrada',true),
  ('n_j',null,40,22,'corredor',true),
  ('n_a',null,31,22,'corredor',true),
  ('n_b',null,23,22,'corredor',true),
  ('n_c',null,16,22,'corredor',true),
  ('n_d',null,8.5,22,'corredor',true),
  ('via158','Sala de Docentes · Via 158',8.75,16.8,'destino',true),
  ('n_esc','Escadas rolantes',31,17,'escada',false)
on conflict (id) do update set nome=excluded.nome,x=excluded.x,y=excluded.y,tipo=excluded.tipo,acessivel=excluded.acessivel;

-- ---------- SEED: arestas (corredor bidirecional; escada = mão única) ----------
delete from arestas;
insert into arestas (de,para,peso,tipo,acessivel) values
  ('portaria','n_j',15.5,'corredor',true),
  ('n_j','n_a',9,'corredor',true),
  ('n_a','n_b',8,'corredor',true),
  ('n_b','n_c',7,'corredor',true),
  ('n_c','n_d',7.5,'corredor',true),
  ('n_d','via158',5.2,'corredor',true),
  ('n_a','n_esc',5,'escada',false);   -- sobe ao 2º piso (não acessível)

-- ---------- SEED: QR (um por ponto físico) ----------
insert into qr (codigo,no_origem) values
  ('portaria','portaria'),
  ('via158','via158')
on conflict (codigo) do update set no_origem=excluded.no_origem;

-- ---------- RLS: leitura pública (a app só lê) ----------
alter table blocos  enable row level security;
alter table nos     enable row level security;
alter table arestas enable row level security;
alter table qr      enable row level security;

create policy "leitura publica blocos"  on blocos  for select using (true);
create policy "leitura publica nos"      on nos     for select using (true);
create policy "leitura publica arestas"  on arestas for select using (true);
create policy "leitura publica qr"       on qr      for select using (true);
