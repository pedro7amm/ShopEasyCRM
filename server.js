// Proyecto de laboratorio: endpoints SIN autenticacion. No usar en produccion.
require('dotenv').config();
const express = require('express');
const mysql = require('mysql2/promise');

const app = express();
app.use(express.json());

const pool = mysql.createPool({
  host: process.env.DB_HOST || '127.0.0.1',
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'ShopEasy_CRM',
  waitForConnections: true,
  connectionLimit: 5
});

function errorServidor(res, error) {
  console.error('Error de MySQL:', error.code || error.message);
  if (error.code === 'ER_NO_REFERENCED_ROW_2') {
    return res.status(400).json({ error: 'No existe el cliente, responsable, estado u orden referenciado.' });
  }
  return res.status(500).json({ error: 'Ocurrio un error al consultar la base de datos.' });
}

// 1. Verificar que el backend responda y MySQL este disponible.
app.get('/api/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ ok: true, servicio: 'ShopEasy CRM', baseDatos: 'conectada' });
  } catch (error) {
    errorServidor(res, error);
  }
});

// 2. Listar clientes uniendo las tablas Cliente y Persona.
app.get('/api/clientes', async (req, res) => {
  try {
    const [filas] = await pool.query(`
      SELECT c.idCliente,
             p.Cedula AS cedula,
             CONCAT_WS(' ', p.Nombre, p.Apellido1, p.Apellido2) AS nombre,
             p.Correo AS correo,
             p.Telefono AS telefono,
             c.Acepta_Marketing AS aceptaMarketing,
             c.Fecha_Alta AS fechaAlta
      FROM Cliente c
      INNER JOIN Persona p ON p.Cedula = c.Persona_Cedula
      WHERE p.Activo = 1
      ORDER BY c.idCliente DESC
    `);
    res.json(filas);
  } catch (error) {
    errorServidor(res, error);
  }
});

// 3. Consultar los pedidos de un cliente (historial de compras).
app.get('/api/clientes/:id/pedidos', async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id <= 0) {
    return res.status(400).json({ error: 'El ID del cliente debe ser un numero positivo.' });
  }
  try {
    const [filas] = await pool.execute(`
      SELECT o.idOrden AS idOrden,
             o.Codigo_Referencia AS referencia,
             o.Fecha_Orden AS fecha,
             o.Total AS total,
             e.Descripcion_Estado_Orden AS estado
      FROM Orden o
      INNER JOIN Estado_Orden e ON e.idEstado_Orden = o.Estado_Orden_idEstado_Orden
      WHERE o.Cliente_idCliente = ?
      ORDER BY o.Fecha_Orden DESC
    `, [id]);
    res.json(filas);
  } catch (error) {
    errorServidor(res, error);
  }
});

// 4. Consultar estados disponibles antes de registrar un caso.
app.get('/api/estados-soporte', async (req, res) => {
  try {
    const [filas] = await pool.query(`
      SELECT idCatalogo_EstadosSoporte AS id,
             descripcionEstado AS descripcion
      FROM Catalogo_EstadosSoporte
      WHERE Activo = 1
      ORDER BY idCatalogo_EstadosSoporte
    `);
    res.json(filas);
  } catch (error) {
    errorServidor(res, error);
  }
});

// 5. Listar quejas y solicitudes con el cliente y su estado.
app.get('/api/casos', async (req, res) => {
  try {
    const [filas] = await pool.query(`
      SELECT cs.idCaso_Soporte AS id,
             cs.Tipo AS tipo,
             cs.Asunto AS asunto,
             cs.Descripcion AS descripcion,
             cs.Fecha_Creacion AS fechaCreacion,
             cs.Cliente_idCliente AS clienteId,
             CONCAT_WS(' ', pc.Nombre, pc.Apellido1) AS cliente,
             es.descripcionEstado AS estado,
             cs.Persona_Cedula AS responsableCedula,
             cs.Orden_idOrden AS ordenId
      FROM Caso_Soporte cs
      INNER JOIN Cliente cl ON cl.idCliente = cs.Cliente_idCliente
      INNER JOIN Persona pc ON pc.Cedula = cl.Persona_Cedula
      INNER JOIN Catalogo_EstadosSoporte es
        ON es.idCatalogo_EstadosSoporte = cs.Catalogo_EstadosSoporte_idCatalogo_EstadosSoporte
      ORDER BY cs.Fecha_Creacion DESC, cs.idCaso_Soporte DESC
    `);
    res.json(filas);
  } catch (error) {
    errorServidor(res, error);
  }
});

// 6. Crear un caso: cliente, responsable y estado deben existir en MySQL.
app.post('/api/casos', async (req, res) => {
  const { tipo, asunto, descripcion, clienteId, responsableCedula, estadoId, ordenId = null } = req.body || {};
  const textoValido = (valor, max) => typeof valor === 'string' && valor.trim().length > 0 && valor.trim().length <= max;
  const enteroPositivo = valor => Number.isInteger(valor) && valor > 0;

  if (!textoValido(tipo, 30) || !textoValido(asunto, 120) ||
      !textoValido(descripcion, 500) || !textoValido(responsableCedula, 25) ||
      !enteroPositivo(clienteId) || !enteroPositivo(estadoId) ||
      (ordenId !== null && !enteroPositivo(ordenId))) {
    return res.status(400).json({
      error: 'Datos invalidos. Verifica tipo, asunto, descripcion, clienteId, responsableCedula, estadoId y ordenId opcional.'
    });
  }

  try {
    const [resultado] = await pool.execute(`
      INSERT INTO Caso_Soporte
        (Tipo, Asunto, Descripcion, Fecha_Creacion,
         Cliente_idCliente, Orden_idOrden, Persona_Cedula,
         Catalogo_EstadosSoporte_idCatalogo_EstadosSoporte)
      VALUES (?, ?, ?, NOW(), ?, ?, ?, ?)
    `, [tipo.trim(), asunto.trim(), descripcion.trim(), clienteId,
        ordenId, responsableCedula.trim(), estadoId]);

    res.status(201).json({ mensaje: 'Caso registrado correctamente', id: resultado.insertId });
  } catch (error) {
    errorServidor(res, error);
  }
});

// Escuchar solamente en el equipo local para esta practica.
const port = Number(process.env.PORT || 3001);
(async () => {
  try {
    await pool.query('SELECT 1');
    app.listen(port, '127.0.0.1', () => {
      console.log(`ShopEasy CRM listo en http://127.0.0.1:${port}`);
    });
  } catch (error) {
    console.error('No se pudo conectar a MySQL. Revisa el archivo .env:', error.message);
    process.exitCode = 1;
    await pool.end();
  }
})();
