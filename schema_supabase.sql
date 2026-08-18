-- ============================================================
-- Prime Mobile — Esquema de base de datos (Supabase / Postgres)
-- ============================================================
-- Basado en la estructura relacional real que usa el HTML
-- (ver funciones saveState() / loadState() en el archivo principal).
-- Ejecutar en un proyecto Supabase NUEVO (SQL Editor) antes de
-- pegar la URL y la anon key en el HTML.

-- ------------------------------------------------------------
-- 1) categorias
-- ------------------------------------------------------------
create table if not exists categorias (
  id serial primary key,
  nombre text not null unique
);

-- ------------------------------------------------------------
-- 2) clientes
-- ------------------------------------------------------------
create table if not exists clientes (
  id text primary key,
  nombre text not null,
  cedula text,
  telefono text,
  email text,
  direccion text
);

-- ------------------------------------------------------------
-- 3) productos
-- ------------------------------------------------------------
create table if not exists productos (
  id text primary key,
  codigo text,
  nombre text not null,
  categoria text,
  precio numeric not null default 0,
  costo numeric not null default 0,
  stock integer not null default 0,
  stock_minimo integer not null default 0,
  descripcion text
);

-- ------------------------------------------------------------
-- 4) ventas
-- ------------------------------------------------------------
create table if not exists ventas (
  id text primary key,
  fecha date not null,
  hora text,
  cliente_nombre text,
  cliente_cedula text,
  cliente_telefono text,
  vendedor text,
  notas text,
  total numeric not null default 0
);

-- ------------------------------------------------------------
-- 5) venta_items
-- ------------------------------------------------------------
create table if not exists venta_items (
  id text primary key,
  venta_id text references ventas(id) on delete cascade,
  producto_id text references productos(id) on delete set null,
  nombre text,
  imei text,
  precio numeric,
  costo numeric,
  qty integer,
  subtotal numeric
);

-- ------------------------------------------------------------
-- 6) venta_pagos
-- ------------------------------------------------------------
create table if not exists venta_pagos (
  id text primary key,
  venta_id text references ventas(id) on delete cascade,
  metodo text,
  monto numeric,
  financiera text
);

-- ------------------------------------------------------------
-- 7) cuentas_por_cobrar
-- ------------------------------------------------------------
create table if not exists cuentas_por_cobrar (
  id text primary key,
  venta_id text references ventas(id) on delete set null,
  cliente_nombre text,
  financiera text,
  es_directo boolean default false,
  monto numeric not null default 0,
  fecha_venta date,
  estado text,
  fecha_cobro date
);

-- ------------------------------------------------------------
-- 8) abonos_cxc (pagos parciales de crédito directo)
-- ------------------------------------------------------------
create table if not exists abonos_cxc (
  id text primary key,
  cxc_id text references cuentas_por_cobrar(id) on delete cascade,
  monto numeric not null default 0,
  metodo text,
  fecha date,
  hora text,
  usuario text
);

-- ------------------------------------------------------------
-- 9) movimientos (historial de inventario)
-- ------------------------------------------------------------
create table if not exists movimientos (
  id text primary key,
  fecha date not null,
  hora text,
  producto_id text references productos(id) on delete set null,
  producto_nombre text,
  tipo text,
  cantidad integer,
  referencia text,
  usuario text
);

-- ------------------------------------------------------------
-- 10) gastos
-- ------------------------------------------------------------
create table if not exists gastos (
  id text primary key,
  descripcion text,
  monto numeric not null default 0,
  fecha date not null,
  hora text
);

-- ------------------------------------------------------------
-- 11) cierres (cierre de caja)
-- ------------------------------------------------------------
create table if not exists cierres (
  id text primary key,
  fecha date not null,
  cerrado_en text,
  tipo text,
  efectivo numeric default 0,
  transferencia numeric default 0,
  tarjeta numeric default 0,
  credito numeric default 0,
  gastos numeric default 0,
  cobros_cartera numeric default 0,
  neto_caja numeric default 0,
  caja_principal numeric default 0,
  ventas_count integer default 0,
  total_ventas numeric default 0
);

-- ------------------------------------------------------------
-- 12) permisos_vendedor
-- ------------------------------------------------------------
create table if not exists permisos_vendedor (
  clave text primary key,
  activo boolean not null default false
);

-- ------------------------------------------------------------
-- 13) config (fila única id=1, incluye el contador de facturas)
-- ------------------------------------------------------------
create table if not exists config (
  id integer primary key,
  factura_counter integer not null default 1000
);
insert into config (id, factura_counter)
  values (1, 1000)
  on conflict (id) do nothing;

-- ------------------------------------------------------------
-- 14) usuarios (login: username + hash SHA-256 de la contraseña)
-- ------------------------------------------------------------
create table if not exists usuarios (
  username text primary key,
  hash text not null,
  role text not null,       -- 'admin' | 'vendedor'
  label text not null,
  activo boolean not null default true
);

-- Usuario admin por defecto: primemobile / PrimeMobile2026$
-- Usuario vendedor por defecto: vendedor1 / PMVendedor2026$
-- (Cambia estas contraseñas en producción: genera un hash SHA-256 nuevo
--  y actualiza el campo hash de cada fila.)
insert into usuarios (username, hash, role, label) values
  ('primemobile', '4d024721f0226fd0b4a70335be353582701004f1b347b34386762926b3e59ceb', 'admin', 'Administrador'),
  ('vendedor1',   'd17da977067a7f90cc2a0b6aad26246840255f6c62f59f57aa81ee79411ead48', 'vendedor', 'Vendedor')
on conflict (username) do nothing;

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
-- El sistema usa la anon key directamente desde el navegador (sin login
-- de Supabase Auth), así que por ahora se habilita RLS con una política
-- abierta a "anon" en todas las tablas -- funcionalmente igual a como
-- operaba La Ofi Ctg antes de su migración a Supabase Auth. Esto NO es
-- seguro para producción real (cualquiera con la anon key podría leer o
-- escribir datos); es un punto pendiente de "on the horizon" igual que
-- en el proyecto original. Migrar a Supabase Auth + políticas por
-- usuario cuando haya tiempo.

do $$
declare
  t text;
begin
  for t in
    select unnest(array[
      'categorias','clientes','productos','ventas','venta_items','venta_pagos',
      'cuentas_por_cobrar','abonos_cxc','movimientos','gastos','cierres',
      'permisos_vendedor','config','usuarios'
    ])
  loop
    execute format('alter table %I enable row level security;', t);
    execute format(
      'create policy if not exists "allow_all_anon_%1$s" on %1$I for all using (true) with check (true);',
      t
    );
  end loop;
end $$;
