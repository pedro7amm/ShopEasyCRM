import { useEffect, useState } from "react";

export default function Clientes() {
  const [clientes, setClientes] = useState([]);
  const [busqueda, setBusqueda] = useState("");
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState("");

  const [clienteSeleccionado, setClienteSeleccionado] = useState(null);
  const [pedidos, setPedidos] = useState([]);
  const [cargandoPedidos, setCargandoPedidos] = useState(false);
  const [errorPedidos, setErrorPedidos] = useState("");

  useEffect(() => {
    fetch("http://127.0.0.1:3001/api/clientes")
      .then((respuesta) => {
        if (!respuesta.ok) throw new Error("Error al obtener clientes");
        return respuesta.json();
      })
      .then((datos) => setClientes(datos))
      .catch((err) => setError(err.message))
      .finally(() => setCargando(false));
  }, []);

  const clientesFiltrados = clientes.filter((cliente) => {
    const texto = [
      cliente.nombre,
      cliente.cedula,
      cliente.correo
    ].join(" ").toLowerCase();

    return texto.includes(busqueda.toLowerCase().trim());
  });

  async function verPedidos(cliente) {
    setClienteSeleccionado(cliente);
    setPedidos([]);
    setErrorPedidos("");
    setCargandoPedidos(true);

    try {
      const respuesta = await fetch(
        `http://127.0.0.1:3001/api/clientes/${cliente.idCliente}/pedidos`
      );

      if (!respuesta.ok) {
        throw new Error("No se pudo consultar el historial");
      }

      const datos = await respuesta.json();
      setPedidos(datos);
    } catch (err) {
      setErrorPedidos(err.message);
    } finally {
      setCargandoPedidos(false);
    }
  }

  return (
    <div>
      <h1>Gestión de clientes</h1>
      <p>Consultá la información y el historial de tus clientes.</p>

      <div className="barra-herramientas">
        <input
          type="text"
          placeholder="Buscar por nombre, cédula o correo..."
          value={busqueda}
          onChange={(e) => setBusqueda(e.target.value)}
        />

        <span>{clientesFiltrados.length} clientes</span>
      </div>

      {cargando && <p>Cargando clientes...</p>}
      {error && <p style={{ color: "red" }}>{error}</p>}

      {!cargando && !error && (
        <div className="tabla-contenedor">
          <table className="tabla-clientes">
            <thead>
              <tr>
                <th>ID</th>
                <th>Nombre</th>
                <th>Cédula</th>
                <th>Correo</th>
                <th>Teléfono</th>
                <th>Acciones</th>
              </tr>
            </thead>

            <tbody>
              {clientesFiltrados.map((cliente) => (
                <tr key={cliente.idCliente}>
                  <td>{cliente.idCliente}</td>
                  <td>{cliente.nombre}</td>
                  <td>{cliente.cedula}</td>
                  <td>{cliente.correo}</td>
                  <td>{cliente.telefono}</td>
                  <td>
                    <button
                      className="btn-accion"
                      onClick={() => verPedidos(cliente)}
                    >
                      Ver pedidos
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>

          {clientesFiltrados.length === 0 && (
            <p>No se encontraron clientes.</p>
          )}
        </div>
      )}

      {clienteSeleccionado && (
        <div className="historial-panel">
          <div className="historial-encabezado">
            <h2>Historial de {clienteSeleccionado.nombre}</h2>

            <button
              className="btn-cerrar"
              onClick={() => setClienteSeleccionado(null)}
            >
              Cerrar
            </button>
          </div>

          {cargandoPedidos && <p>Cargando pedidos...</p>}

          {errorPedidos && (
            <p style={{ color: "red" }}>{errorPedidos}</p>
          )}

          {!cargandoPedidos && !errorPedidos && (
            pedidos.length === 0 ? (
              <p>Este cliente todavía no tiene pedidos registrados.</p>
            ) : (
              <div className="tabla-contenedor">
                <table className="tabla-clientes">
                  <thead>
                    <tr>
                      <th>Referencia</th>
                      <th>Fecha</th>
                      <th>Estado</th>
                      <th>Total</th>
                    </tr>
                  </thead>

                  <tbody>
                    {pedidos.map((pedido) => (
                      <tr key={pedido.idOrden}>
                        <td>{pedido.referencia}</td>
                        <td>
                          {new Date(pedido.fecha).toLocaleDateString("es-CR")}
                        </td>
                        <td>{pedido.estado}</td>
                        <td>
                          ₡{Number(pedido.total).toLocaleString("es-CR")}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )
          )}
        </div>
      )}
    </div>
  );
}