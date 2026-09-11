//variables de entorno
import "dotenv/config";
import { createClient } from "@supabase/supabase-js";


//creacion de conexion a supabase
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;

//variables de conexion 
if (!supabaseUrl || !supabaseKey) {
    console.error("❌ error: las variables de entorno SUPABASE_URL y SUPABASE_KEY son requeridas");
    process.exit(1);
}
//conexion a supabase
export const supabase = createClient(supabaseUrl, supabaseKey);
export const conectaDB=()=>{
    console.log("✅ conexion a Supabase establecida correctamente");
};