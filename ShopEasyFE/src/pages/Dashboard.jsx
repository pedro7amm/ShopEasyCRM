import { useEffect, useState } from "react";
import { Link } from "react-router-dom";

const API = "http://127.0.0.1:3001/api";

export default function Dashboard() {
  const [clientes, setClientes] = useState([]);
  const [pedidos, setPedidos] = useState([]);
  const [casos, setCasos] = useState([]);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    async function cargarDatos() {
      try {
        const respuestas = await Promise.all([
          fetch(`${API}/clientes`),
          fetch(`${API}/pedidos`),
          fetch(`${API}/casos`)
        ]);

        if (respuestas.some((respuesta) => !respuesta.ok)) {
          throw new Error("No se pudieron cargar las estadísticas.");
        }

        const [datosClientes, datosPedidos, datosCasos] =
          await Promise.all(respuestas.map((respuesta) => respuesta.json()));

        setClientes(datosClientes);
        setPedidos(datosPedidos);
        setCasos(datosCasos);
      } catch (err) {
        setError(err.message);
      } finally {
        setCargando(false);
      }
    }

    cargarDatos();
  }, []);

  const totalVentas = pedidos.reduce(
    (total, pedido) => total + Number(pedido.total || 0),
    0
  );

  const casosPendientes = casos.filter(
    (caso) => caso.estado?.toLowerCase() === "pendiente"
  ).length;

  const pedidosRecientes = [...pedidos]
    .sort((a, b) => new Date(b.fecha) - new Date(a.fecha))
    .slice(0, 5);

  const formatoMoneda = (valor) =>
    "₡" + Number(valor).toLocaleString("es-CR");

  if (cargando) return <p>Cargando dashboard...</p>;

  if (error) return <p className="mensaje-error">{error}</p>;

  return (
    <div>
      <div className="dashboard-encabezado">
        <h1>Panel principal</h1>
        <p>Resumen general de la actividad de ShopEasyCRM.</p>
      </div>

      <div className="dashboard-estadisticas">
        <div className="resumen-card">
          <span>Clientes registrados</span>
          <strong>{clientes.length}</strong>
        </div>

        <div className="resumen-card">
          <span>Pedidos registrados</span>
          <strong>{pedidos.length}</strong>
        </div>

        <div className="resumen-card">
          <span>Monto total de pedidos</span>
          <strong>{formatoMoneda(totalVentas)}</strong>
        </div>

        <div className="resumen-card">
          <span>Casos pendientes</span>
          <strong>{casosPendientes}</strong>
        </div>
      </div>

      <div className="dashboard-seccion">
        <div className="dashboard-titulo">
          <h2>Pedidos recientes</h2>
          <Link to="/pedidos" className="btn-accion">
            Ver todos
          </Link>
        </div>

        {pedidosRecientes.length === 0 ? (
          <p>No hay pedidos registrados.</p>
        ) : (
          <div className="tabla-scroll">
            <table className="tabla-clientes">
              <thead>
                <tr>
                  <th>Referencia</th>
                  <th>Cliente</th>
                  <th>Fecha</th>
                  <th>Estado</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                {pedidosRecientes.map((pedido) => (
                  <tr key={pedido.idOrden}>
                    <td>{pedido.referencia}</td>
                    <td>{pedido.cliente}</td>
                    <td>
                      {new Date(pedido.fecha).toLocaleDateString("es-CR")}
                    </td>
                    <td>
                      <span className="estado-etiqueta">
                        {pedido.estado}
                      </span>
                    </td>
                    <td>{formatoMoneda(pedido.total)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      <div className="dashboard-seccion">
        <div className="dashboard-titulo">
          <h2>Resumen de soporte</h2>
          <Link to="/soporte" className="btn-accion">
            Ir a soporte
          </Link>
        </div>

        <div className="dashboard-soporte">
          <div>
            <span>Total de casos</span>
            <strong>{casos.length}</strong>
          </div>

          <div>
            <span>Pendientes</span>
            <strong>{casosPendientes}</strong>
          </div>

          <div>
            <span>En proceso</span>
            <strong>
              {casos.filter(
                (caso) => caso.estado?.toLowerCase() === "en proceso"
              ).length}
            </strong>
          </div>

          <div>
            <span>Resueltos</span>
            <strong>
              {casos.filter(
                (caso) => caso.estado?.toLowerCase() === "resuelto"
              ).length}
            </strong>
          </div>
        </div>
      </div>
    </div>
  );
}