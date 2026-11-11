import { useEffect, useState } from "react";

const API = "http://127.0.0.1:3001/api";

export default function Soporte() {
  const [casos, setCasos] = useState([]);
  const [clientes, setClientes] = useState([]);
  const [estados, setEstados] = useState([]);

  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState("");
  const [mensaje, setMensaje] = useState("");
  const [guardando, setGuardando] = useState(false);
  const [mostrarFormulario, setMostrarFormulario] = useState(false);

  const [formulario, setFormulario] = useState({
    tipo: "Queja",
    asunto: "",
    descripcion: "",
    clienteId: "",
    responsableCedula: "EMP001",
    estadoId: "",
  });

  async function cargarDatos() {
    try {
      setError("");

      const [resCasos, resClientes, resEstados] = await Promise.all([
        fetch(`${API}/casos`),
        fetch(`${API}/clientes`),
        fetch(`${API}/estados-soporte`),
      ]);

      if (!resCasos.ok || !resClientes.ok || !resEstados.ok) {
        throw new Error("No se pudieron cargar los datos.");
      }

      const datosCasos = await resCasos.json();
      const datosClientes = await resClientes.json();
      const datosEstados = await resEstados.json();

      setCasos(datosCasos);
      setClientes(datosClientes);
      setEstados(datosEstados);

      setFormulario((anterior) => ({
        ...anterior,
        estadoId:
          anterior.estadoId ||
          String(
            datosEstados.find((e) => e.descripcion === "Pendiente")?.id ||
            datosEstados[0]?.id ||
            ""
          ),
      }));
    } catch (err) {
      setError(err.message);
    } finally {
      setCargando(false);
    }
  }

  useEffect(() => {
    cargarDatos();
  }, []);

  function actualizarCampo(e) {
    const { name, value } = e.target;

    setFormulario((anterior) => ({
      ...anterior,
      [name]: value,
    }));
  }

  async function cambiarEstado(casoId, nuevoEstadoId) {
  if (!nuevoEstadoId) return;

  try {
    setError("");
    setMensaje("");

    const respuesta = await fetch(
      `${API}/casos/${casoId}/estado`,
      {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          estadoId: Number(nuevoEstadoId)
        })
      }
    );

    const resultado = await respuesta.json();

    if (!respuesta.ok) {
      throw new Error(
        resultado.error || "No se pudo actualizar el estado."
      );
    }

    setMensaje("Estado actualizado correctamente.");
    await cargarDatos();

  } catch (err) {
    setError(err.message);
  }
}

  async function registrarCaso(e) {
    e.preventDefault();

    setGuardando(true);
    setError("");
    setMensaje("");

    const nuevoCaso = {
      tipo: formulario.tipo,
      asunto: formulario.asunto.trim(),
      descripcion: formulario.descripcion.trim(),
      clienteId: Number(formulario.clienteId),
      responsableCedula: formulario.responsableCedula,
      estadoId: Number(formulario.estadoId),
      ordenId: null,
    };

    try {
      const respuesta = await fetch(`${API}/casos`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(nuevoCaso),
      });

      const resultado = await respuesta.json();

      if (!respuesta.ok) {
        throw new Error(resultado.error || "Error al registrar el caso.");
      }

      setMensaje("Caso registrado correctamente.");

      setFormulario((anterior) => ({
        ...anterior,
        tipo: "Queja",
        asunto: "",
        descripcion: "",
        clienteId: "",
      }));

      setMostrarFormulario(false);

      await cargarDatos();
    } catch (err) {
      setError(err.message);
    } finally {
      setGuardando(false);
    }
  }

  return (
    <div>
      <div className="soporte-encabezado">
        <div>
          <h1>Gestión de soporte</h1>
          <p>Administrá las quejas y solicitudes de tus clientes.</p>
        </div>

        <button
          className="btn-accion"
          onClick={() => {
            setMostrarFormulario(!mostrarFormulario);
            setMensaje("");
            setError("");
          }}
        >
          {mostrarFormulario ? "Cancelar" : "+ Nuevo caso"}
        </button>
      </div>

      {mensaje && <p className="mensaje-exito">{mensaje}</p>}
      {error && <p className="mensaje-error">{error}</p>}

      <div className="soporte-resumen">
        <div className="resumen-card">
          <span>Total de casos</span>
          <strong>{casos.length}</strong>
        </div>

        <div className="resumen-card">
          <span>Pendientes</span>
          <strong>
            {
              casos.filter(
                (caso) => caso.estado?.toLowerCase() === "pendiente"
              ).length
            }
          </strong>
        </div>

        <div className="resumen-card">
          <span>En proceso</span>
          <strong>
            {
              casos.filter(
                (caso) => caso.estado?.toLowerCase() === "en proceso"
              ).length
            }
          </strong>
        </div>

        <div className="resumen-card">
          <span>Resueltos</span>
          <strong>
            {
              casos.filter(
                (caso) => caso.estado?.toLowerCase() === "resuelto"
              ).length
            }
          </strong>
        </div>
      </div>

      {mostrarFormulario && (
        <div className="formulario-soporte">
          <h2>Registrar nuevo caso</h2>

          <form onSubmit={registrarCaso}>
            <div className="formulario-grid">
              <div className="campo">
                <label>Cliente</label>

                <select
                  name="clienteId"
                  value={formulario.clienteId}
                  onChange={actualizarCampo}
                  required
                >
                  <option value="">Seleccionar cliente</option>

                  {clientes.map((cliente) => (
                    <option
                      key={cliente.idCliente}
                      value={cliente.idCliente}
                    >
                      {cliente.nombre}
                    </option>
                  ))}
                </select>
              </div>

              <div className="campo">
                <label>Tipo de caso</label>

                <select
                  name="tipo"
                  value={formulario.tipo}
                  onChange={actualizarCampo}
                >
                  <option value="Queja">Queja</option>
                  <option value="Solicitud">Solicitud</option>
                </select>
              </div>

              <div className="campo">
                <label>Estado</label>

                <select
                  name="estadoId"
                  value={formulario.estadoId}
                  onChange={actualizarCampo}
                  required
                >
                  <option value="">Seleccionar estado</option>

                  {estados.map((estado) => (
                    <option key={estado.id} value={estado.id}>
                      {estado.descripcion}
                    </option>
                  ))}
                </select>
              </div>

              <div className="campo">
                <label>Responsable</label>

                <input
                  type="text"
                  value="Daniel Ramirez Soto"
                  disabled
                />
              </div>
            </div>

            <div className="campo">
              <label>Asunto</label>

              <input
                type="text"
                name="asunto"
                placeholder="Ejemplo: Producto recibido en mal estado"
                value={formulario.asunto}
                onChange={actualizarCampo}
                maxLength={120}
                required
              />
            </div>

            <div className="campo">
              <label>Descripción</label>

              <textarea
                name="descripcion"
                placeholder="Describí el problema o solicitud..."
                value={formulario.descripcion}
                onChange={actualizarCampo}
                maxLength={500}
                rows={4}
                required
              />
            </div>

            <button
              type="submit"
              className="btn-accion"
              disabled={guardando}
            >
              {guardando ? "Guardando..." : "Registrar caso"}
            </button>
          </form>
        </div>
      )}

      <div className="tabla-contenedor">
        <h2>Casos registrados</h2>

        {cargando ? (
          <p>Cargando casos...</p>
        ) : casos.length === 0 ? (
          <p>No hay casos registrados todavía.</p>
        ) : (
          <table className="tabla-clientes">
            <thead>
              <tr>
                <th>ID</th>
                <th>Asunto</th>
                <th>Cliente</th>
                <th>Tipo</th>
                <th>Estado</th>
                <th>Fecha</th>
              </tr>
            </thead>

            <tbody>
              {casos.map((caso) => (
                <tr key={caso.id}>
                  <td>{caso.id}</td>
                  <td>{caso.asunto}</td>
                  <td>{caso.cliente}</td>
                  <td>{caso.tipo}</td>
                  <td>
                  <select
                    className="selector-estado"
                    value={
                      estados.find(
                        (estado) => estado.descripcion === caso.estado
                      )?.id ?? ""
                    }
                    onChange={(e) =>
                      cambiarEstado(caso.id, e.target.value)
                    }
                    aria-label={`Estado del caso ${caso.id}`}
                  >
                    <option value="" disabled>
                      Seleccionar estado
                    </option>

                    {estados.map((estado) => (
                      <option key={estado.id} value={estado.id}>
                        {estado.descripcion}
                      </option>
                    ))}
                  </select>
                </td>
                  <td>
                    {new Date(caso.fechaCreacion).toLocaleDateString(
                      "es-CR"
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}