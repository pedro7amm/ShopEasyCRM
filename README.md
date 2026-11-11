# ShopEasyCRM

Proyecto de CRM para la gestión de clientes, pedidos y casos de soporte.

## ¿Cómo ejecutar el proyecto?

**1. Base de datos**

Abrir MySQL Workbench y ejecutar el archivo `ShopEasy BD creation query.sql`, que está dentro de la carpeta `Database`.

**2. Backend**

Abrir una terminal en la carpeta `ShopEasyBE` y ejecutar:

```bash
npm install
```

Crear un archivo `.env` dentro de `ShopEasyBE` con los datos de conexión a MySQL:

```env
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=root
DB_PASSWORD=TU_CONTRASENA
DB_NAME=ShopEasy_CRM
PORT=3001
```

Después ejecutar:

```bash
npm start
```

**3. Frontend**

Abrir otra terminal en la carpeta `ShopEasyFE` y ejecutar:

```bash
npm install
npm run dev
```

**4. Abrir el proyecto**

Entrar desde el navegador a:

http://localhost:5173/

**Importante:** mantener abiertas ambas terminales mientras se utiliza el sistema.

*Nota:* Si PowerShell no permite ejecutar `npm`, utilizar `npm.cmd` en su lugar. La base de datos debe tener registros para que aparezca información en las pantallas.
