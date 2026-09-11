import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { conectaDB, supabase } from "./config/supabase.js";
import authRoutes from "./routers/auth-router.js";
import userRoutes from "./routers/user-router.js";
import categoriaRoutes from "./routers/categoria-router.js";
import productoRoutes from "./routers/producto-router.js";
import inventarioRoutes from "./routers/inventario-router.js";
import carritoRoutes from "./routers/carrito-router.js";
import pedidoRoutes from "./routers/pedido-router.js";
import pagoRoutes from "./routers/pago-router.js";
import notificacionRoutes from "./routers/notificacion-router.js";
import recuperarRoutes from "./routers/recuperar-router.js";
import chatRoutes from "./routers/chatbox-router.js";

// cargamos las variables
dotenv.config();
conectaDB();

// creamos la aplicacion de express
const app = express();

// middlewares globales
app.use(cors());
app.use(express.json());

// Montaje de rutas
app.use("/api/auth", authRoutes);
app.use("/api/usuarios", userRoutes);
app.use("/api/categorias", categoriaRoutes);
app.use("/api/productos", productoRoutes);
app.use("/api/inventario", inventarioRoutes);
app.use("/api/carrito", carritoRoutes);
app.use("/api/pedidos", pedidoRoutes);
app.use("/api/pagos", pagoRoutes);
app.use("/api/notificaciones", notificacionRoutes);
app.use("/api/recuperar", recuperarRoutes);
app.use("/api/chat", chatRoutes);

// ruta principal
app.get("/", (req, res) => {
    res.json({
        mensaje: "bienvenido al backend de distribuidora Anita",
        estado: "en linea.",
        vercion: "1.0.0",
    });
});

// configuramos el puerto 
const PORT = process.env.PORT || 3000;

// poner a escuchar el servidor
app.listen(PORT, () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
});