import  express  from "express";
import { chatearConDistribuidoraAnita, obtenerHistorialDistribuidora } from "../controllers/chatbox-controllers.js";

const router = express.Router();

router.post("/", chatearConDistribuidoraAnita);
router.get("/historial/:sesionId", obtenerHistorialDistribuidora);

export default router;