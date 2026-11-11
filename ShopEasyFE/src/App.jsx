import { BrowserRouter, Routes, Route, NavLink } from "react-router-dom";
import Dashboard from "./pages/Dashboard";
import Clientes from "./pages/Clientes";
import Pedidos from "./pages/Pedidos";
import Soporte from "./pages/Soporte";
import "./App.css";

export default function App() {
  return (
    <BrowserRouter>
      <div className="app-container">
        <aside className="sidebar">
          <h2>ShopEasyCRM</h2>

          <nav>
            <NavLink to="/" end>Dashboard</NavLink>
            <NavLink to="/clientes">Clientes</NavLink>
            <NavLink to="/pedidos">Pedidos</NavLink>
            <NavLink to="/soporte">Soporte</NavLink>
          </nav>
        </aside>

        <main className="main-content">
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/clientes" element={<Clientes />} />
            <Route path="/pedidos" element={<Pedidos />} />
            <Route path="/soporte" element={<Soporte />} />
          </Routes>
        </main>
      </div>
    </BrowserRouter>
  );
}
