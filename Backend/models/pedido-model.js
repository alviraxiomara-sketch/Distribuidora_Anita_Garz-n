import { supabase } from "../config/supabase.js";

// ==========================
// CREAR PEDIDO
// ==========================

export const crearPedido = async (pedido) => {

    const { data, error } =
        await supabase
            .from("pedidos")
            .insert(pedido)
            .select()
            .single();

    return { data, error };
};


// ==========================
// CREAR DETALLE DEL PEDIDO
// ==========================

export const crearDetallePedido = async (detalle) => {

    const { data, error } =
        await supabase
            .from("detalle_pedido")
            .insert(detalle)
            .select()
            .single();

    return { data, error };
};


// ==========================
// OBTENER PEDIDOS DEL USUARIO
// ==========================

export const obtenerPedidosPorUsuario = async (id_usuario) => {

    const { data, error } =
        await supabase
            .from("pedidos")
            .select(`
                id_pedido,
                id_usuario,
                direccion_entrega,
                telefono_contacto,
                estado,
                total,
                fecha_pedido,
                created_at,
                updated_at,
                detalle_pedido (
                    id_detalle_pedido,
                    id_producto,
                    cantidad,
                    precio_unitario,
                    subtotal,
                    created_at,
                    productos (
                        id_producto,
                        nombre,
                        presentacion,
                        imagen_url
                    )
                )
            `)
            .eq("id_usuario", id_usuario)
            .order("fecha_pedido", {
                ascending: false
            });

    return { data, error };
};


// ==========================
// OBTENER TODOS LOS PEDIDOS
// ==========================

export const obtenerTodosLosPedidos = async () => {

    const { data, error } =
        await supabase
            .from("pedidos")
            .select(`
                id_pedido,
                id_usuario,
                direccion_entrega,
                telefono_contacto,
                estado,
                total,
                fecha_pedido,
                created_at,
                updated_at,
                usuarios (
                    id_usuario,
                    nombre,
                    correo,
                    telefono
                ),
                detalle_pedido (
                    id_detalle_pedido,
                    id_producto,
                    cantidad,
                    precio_unitario,
                    subtotal,
                    created_at,
                    productos (
                        id_producto,
                        nombre,
                        presentacion,
                        imagen_url
                    )
                )
            `)
            .order("fecha_pedido", {
                ascending: false
            });

    return { data, error };
};


// ==========================
// OBTENER PEDIDO POR ID
// ==========================

export const obtenerPedidoPorId = async (id_pedido) => {

    const { data, error } =
        await supabase
            .from("pedidos")
            .select(`
                id_pedido,
                id_usuario,
                direccion_entrega,
                telefono_contacto,
                estado,
                total,
                fecha_pedido,
                created_at,
                updated_at,
                usuarios (
                    id_usuario,
                    nombre,
                    correo,
                    telefono
                ),
                detalle_pedido (
                    id_detalle_pedido,
                    id_producto,
                    cantidad,
                    precio_unitario,
                    subtotal,
                    created_at,
                    productos (
                        id_producto,
                        nombre,
                        presentacion,
                        imagen_url
                    )
                )
            `)
            .eq("id_pedido", id_pedido)
            .maybeSingle();

    return { data, error };
};


// ==========================
// ACTUALIZAR ESTADO
// ==========================

export const actualizarEstadoPedido = async (
    id_pedido,
    estado
) => {

    const { data, error } =
        await supabase
            .from("pedidos")
            .update({
                estado,
                updated_at: new Date()
            })
            .eq("id_pedido", id_pedido)
            .select()
            .single();

    return { data, error };
};