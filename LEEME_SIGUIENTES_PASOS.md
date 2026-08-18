# Prime Mobile — Sistema de Gestión — Próximos pasos

Este proyecto se creó copiando la base de código de **La Ofi Ctg** (con todos
sus fixes: sync multi-dispositivo, cierre de caja, crédito directo, seguridad,
etc.) y cambiándole:

- ✅ Nombre del negocio → **Prime Mobile**
- ✅ Logo (extraído de tu archivo de referencia)
- ✅ Paleta de colores → verde `#15803d` / dorado `#b8860b` (antes rojo/negro)
- ✅ Datos de facturación → Centro Comercial Los Ejecutivos, Local 23B, Cartagena · WhatsApp 304 302 0341
- ✅ Usuario admin → `primemobile` (contraseña temporal: `PrimeMobile2026$`)
- ✅ Usuario vendedor → `vendedor1` (contraseña temporal: `PMVendedor2026$`)
- ⚠️ **Cambia estas dos contraseñas** apenas puedas — son temporales para el primer arranque.

## Lo que falta (te ayudo a hacerlo cuando me des los accesos)

### 1. Supabase (proyecto nuevo, separado del de La Ofi Ctg)
1. Crea un proyecto nuevo en https://supabase.com
2. Ve a **SQL Editor** y pega el contenido de `schema_supabase.sql` (crea las 14 tablas + usuarios + RLS)
3. Ve a **Settings → API** y copia:
   - Project URL
   - anon public key
4. Pégalos en el HTML, reemplazando estas dos líneas (actualmente vacías a propósito):
   ```js
   const SUPABASE_URL = "";
   const SUPABASE_ANON_KEY = "";
   ```

### 2. GitHub (repo nuevo)
Cuando quieras subirlo, dame:
- El nombre que quieres para el repo (ej. `tu-usuario/PrimeMobile`)
- Un GitHub Personal Access Token (classic, con permiso `repo`)

Yo hago el `git init`, primer commit y push.

### 3. Vercel (cuenta diferente a la tuya personal)
Dijiste que quieres desplegarlo en una cuenta de Vercel distinta. Para eso necesito
que tú conectes ese repo de GitHub nuevo desde esa cuenta de Vercel (Vercel →
Add New Project → importa el repo) — es la forma más simple porque no tengo
acceso a esa cuenta. Una vez conectado, cada push a `main` se despliega solo.

Si prefieres que yo lo haga por ti, dame el token de esa cuenta de Vercel y lo hago,
pero ojo: quedará guardado el token en la sesión, solo hazlo si estás cómodo con eso.

## Archivos en esta carpeta
- `PrimeMobile_Sistema_de_Gestion.html` — el sistema completo, listo para subir
- `schema_supabase.sql` — crea las 14 tablas necesarias en el Supabase nuevo
- `LEEME_SIGUIENTES_PASOS.md` — este archivo
