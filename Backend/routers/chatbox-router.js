import  express  from "express";
import { chatearConDistribuidoraAnita, obtenerHistorialDistribuidora, eliminarHistorialDistribuidora } from "../controllers/chatbox-controllers.js";
const router = express.Router();

router.post("/", chatearConDistribuidoraAnita);
router.get("/historial/:sesionId", obtenerHistorialDistribuidora);
router.delete("/historial/:sesionId", eliminarHistorialDistribuidora);

export default router;