import { useEffect, useState } from "react";

const API = "http://127.0.0.1:3001/api";

export default function Pedidos() {
  const [pedidos, setPedidos] = useState([]);
  const [estados, setEstados] = useState([]);
  const [actualizandoId, setActualizandoId] = useState(null);
  const [busqueda, setBusqueda] = useState("");
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
  async function cargarDatos() {
    try {
      const [resPedidos, resEstados] = await Promise.all([
        fetch(`${API}/pedidos`),
        fetch(`${API}/estados-pedido`)
      ]);

      if (!resPedidos.ok || !resEstados.ok) {
        throw new Error("No se pudieron cargar los datos.");
      }

      const datosPedidos = await resPedidos.json();
      const datosEstados = await resEstados.json();

      setPedidos(datosPedidos);
      setEstados(datosEstados);
    } catch (err) {
      setError(err.message);
    } finally {
      setCargando(false);
    }
  }

  cargarDatos();
}, []);

async function cambiarEstado(pedidoId, estadoId) {
  const estadoAnterior = pedidos.find(
    (pedido) => pedido.idOrden === pedidoId
  );

  setActualizandoId(pedidoId);
  setError("");

  try {
    const respuesta = await fetch(
      `${API}/pedidos/${pedidoId}/estado`,
      {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          estadoId: Number(estadoId)
        })
      }
    );

    const resultado = await respuesta.json();

    if (!respuesta.ok) {
      throw new Error(
        resultado.error || "No se pudo actualizar el pedido."
      );
    }

    const nuevoEstado = estados.find(
      (estado) => estado.id === Number(estadoId)
    );

    setPedidos((anteriores) =>
      anteriores.map((pedido) =>
        pedido.idOrden === pedidoId
          ? { ...pedido, estado: nuevoEstado.descripcion }
          : pedido
      )
    );

  } catch (err) {
    setError(err.message);
    console.error("Error al actualizar:", estadoAnterior);
  } finally {
    setActualizandoId(null);
  }
}

  const pedidosFiltrados = pedidos.filter((pedido) => {
    const texto = [
      pedido.referencia,
      pedido.cliente,
      pedido.estado
    ].join(" ").toLowerCase();

    return texto.includes(busqueda.toLowerCase().trim());
  });

  const totalVentas = pedidos.reduce(
    (total, pedido) => total + Number(pedido.total || 0),
    0
  );

  return (
    <div>
      <h1>Gestión de pedidos</h1>
      <p>Consultá los pedidos realizados por los clientes.</p>

      <div className="soporte-resumen">
        <div className="resumen-card">
          <span>Total de pedidos</span>
          <strong>{pedidos.length}</strong>
        </div>

        <div className="resumen-card">
          <span>Monto total</span>
          <strong>
            ₡{totalVentas.toLocaleString("es-CR")}
          </strong>
        </div>
      </div>

      <div className="barra-herramientas">
        <input
          type="text"
          placeholder="Buscar por referencia, cliente o estado..."
          value={busqueda}
          onChange={(e) => setBusqueda(e.target.value)}
        />

        <span>{pedidosFiltrados.length} pedidos</span>
      </div>

      {cargando && <p>Cargando pedidos...</p>}

      {error && <p className="mensaje-error">{error}</p>}

      {!cargando && !error && (
        <div className="tabla-contenedor">
          <table className="tabla-clientes">
            <thead>
              <tr>
                <th>ID</th>
                <th>Referencia</th>
                <th>Cliente</th>
                <th>Fecha</th>
                <th>Estado</th>
                <th>Total</th>
              </tr>
            </thead>

            <tbody>
              {pedidosFiltrados.map((pedido) => (
                <tr key={pedido.idOrden}>
                  <td>{pedido.idOrden}</td>
                  <td>{pedido.referencia}</td>
                  <td>{pedido.cliente}</td>
                  <td>
                    {new Date(pedido.fecha).toLocaleDateString("es-CR")}
                  </td>
                  <td>
                  <select
                    className="selector-estado"
                    value={
                      estados.find(
                        (estado) => estado.descripcion === pedido.estado
                      )?.id ?? ""
                    }
                    onChange={(e) =>
                      cambiarEstado(pedido.idOrden, e.target.value)
                    }
                    disabled={actualizandoId === pedido.idOrden}
                    aria-label={`Estado del pedido ${pedido.referencia}`}
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
                    ₡{Number(pedido.total).toLocaleString("es-CR")}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>

          {pedidosFiltrados.length === 0 && (
            <p>No se encontraron pedidos.</p>
          )}
        </div>
      )}
    </div>
  );
}