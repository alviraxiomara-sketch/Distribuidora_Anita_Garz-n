import {
    crearPago,
    obtenerPagoPorPedido,
    obtenerPagoPorId,
    actualizarPago,
    obtenerTodosLosPagos
} from "../models/pago-model.js";

import { obtenerPedidoPorId } from "../models/pedido-model.js";

import { enviarNotificacion } from "../services/notificacion-service.js";

import { supabase } from "../config/supabase.js";


// ==========================
// CREAR PAGO
// ==========================

export const crear = async (req, res) => {

    try {

        const id_usuario =
            req.usuario.id_usuario;

        const {
            id_pedido,
            metodo_pago,
            referencia
        } = req.body;

        // ==========================
        // VALIDAR CAMPOS
        // ==========================

        if (!id_pedido) {

            return res.status(400).json({
                error:
                    "El pedido es obligatorio"
            });

        }

        if (!metodo_pago) {

            return res.status(400).json({
                error:
                    "El método de pago es obligatorio"
            });

        }

        // ==========================
        // MÉTODOS VÁLIDOS
        // ==========================

        const metodosValidos = [

            "NEQUI",
            "DAVIPLATA",
            "EFECTIVO"

        ];

        if (
            !metodosValidos.includes(
                metodo_pago
            )
        ) {

            return res.status(400).json({

                error:
                    "Método de pago inválido. Use NEQUI, DAVIPLATA o EFECTIVO"

            });

        }

        // ==========================
        // OBTENER PEDIDO
        // ==========================

        const {
            data: pedido,
            error: errorPedido
        } = await obtenerPedidoPorId(
            id_pedido
        );

        if (errorPedido) {

            return res.status(500).json({
                error:
                    errorPedido.message
            });

        }

        if (!pedido) {

            return res.status(404).json({
                error:
                    "Pedido no encontrado"
            });

        }

        // ==========================
        // VERIFICAR PROPIETARIO
        // ==========================

        if (
            Number(pedido.id_usuario) !==
            Number(id_usuario)
        ) {

            return res.status(403).json({

                error:
                    "No tiene permiso para registrar un pago para este pedido"

            });

        }

        // ==========================
        // VERIFICAR ESTADO
        // ==========================

        if (
            pedido.estado ===
            "CANCELADO"
        ) {

            return res.status(400).json({

                error:
                    "No se puede pagar un pedido cancelado"

            });

        }

        // ==========================
        // VERIFICAR SI YA TIENE PAGO
        // ==========================

        const {
            data: pagoExistente,
            error: errorPago
        } = await obtenerPagoPorPedido(
            id_pedido
        );

        if (errorPago) {

            return res.status(500).json({
                error:
                    errorPago.message
            });

        }

        if (pagoExistente) {

            return res.status(400).json({

                error:
                    "Este pedido ya tiene un pago registrado"

            });

        }

        // ==========================
        // CREAR PAGO
        // ==========================

        const nuevoPago = {

            id_pedido,

            metodo_pago,

            valor:
                Number(pedido.total),

            estado:
                "PENDIENTE",

            referencia:
                referencia || null

        };

        const {
            data,
            error
        } = await crearPago(
            nuevoPago
        );

        if (error) {

            return res.status(500).json({
                error:
                    error.message
            });

        }

        // ==========================
        // NOTIFICACIÓN
        // ==========================

        await enviarNotificacion(

            id_usuario,

            "Pago registrado",

            `Tu pago para el pedido #${id_pedido} fue registrado y está pendiente de aprobación.`

        );

        return res.status(201).json({

            mensaje:
                "Pago registrado correctamente",

            pago:
                data

        });

    } catch (error) {

        return res.status(500).json({
            error:
                error.message
        });

    }

};


// ==========================
// OBTENER PAGO DEL PEDIDO
// ==========================

export const obtenerPorPedido = async (
    req,
    res
) => {

    try {

        const {
            idPedido
        } = req.params;

        const {
            data: pedido,
            error: errorPedido
        } = await obtenerPedidoPorId(
            idPedido
        );

        if (errorPedido) {

            return res.status(500).json({
                error:
                    errorPedido.message
            });

        }

        if (!pedido) {

            return res.status(404).json({
                error:
                    "Pedido no encontrado"
            });

        }

        if (
            req.usuario.rol !== "ADMIN" &&
            Number(pedido.id_usuario) !==
            Number(req.usuario.id_usuario)
        ) {

            return res.status(403).json({

                error:
                    "No tiene permiso para consultar este pago"

            });

        }

        const {
            data,
            error
        } = await obtenerPagoPorPedido(
            idPedido
        );

        if (error) {

            return res.status(500).json({
                error:
                    error.message
            });

        }

        if (!data) {

            return res.status(404).json({

                error:
                    "Este pedido todavía no tiene un pago registrado"

            });

        }

        return res.status(200).json(data);

    } catch (error) {

        return res.status(500).json({
            error:
                error.message
        });

    }

};


// ==========================
// OBTENER TODOS LOS PAGOS
// ==========================

export const listarTodos = async (
    req,
    res
) => {

    try {

        const {
            data,
            error
        } = await obtenerTodosLosPagos();

        if (error) {

            return res.status(500).json({
                error:
                    error.message
            });

        }

        return res.status(200).json(data);

    } catch (error) {

        return res.status(500).json({
            error:
                error.message
        });

    }

};


// ==========================
// ACTUALIZAR ESTADO DEL PAGO
// ==========================

export const cambiarEstado = async (
    req,
    res
) => {

    try {

        const {
            idPago
        } = req.params;

        const {
            estado
        } = req.body;

        const estadosValidos = [

            "PENDIENTE",
            "APROBADO",
            "RECHAZADO"

        ];

        if (
            !estadosValidos.includes(
                estado
            )
        ) {

            return res.status(400).json({

                error:
                    "Estado de pago inválido"

            });

        }

        const {
            data: pago,
            error: errorPago
        } = await obtenerPagoPorId(
            idPago
        );

        if (errorPago) {

            return res.status(500).json({
                error:
                    errorPago.message
            });

        }

        if (!pago) {

            return res.status(404).json({
                error:
                    "Pago no encontrado"
            });

        }

        const datosActualizados = {

            estado

        };

        if (
            estado === "APROBADO"
        ) {

            datosActualizados.fecha_pago =
                new Date();

        }

        const {
            data,
            error
        } = await actualizarPago(
            idPago,
            datosActualizados
        );

        if (error) {

            return res.status(500).json({
                error:
                    error.message
            });

        }

        // ==========================
        // PAGO APROBADO
        // ==========================

        if (
            estado === "APROBADO"
        ) {

            const {
                error: errorPedido
            } = await supabase
                .from("pedidos")
                .update({
                    estado: "PAGADO",
                    updated_at: new Date()
                })
                .eq(
                    "id_pedido",
                    pago.id_pedido
                );

            if (errorPedido) {

                return res.status(500).json({

                    error:
                        errorPedido.message

                });

            }

            const {
                data: pedido
            } = await obtenerPedidoPorId(
                pago.id_pedido
            );

            await enviarNotificacion(

                pedido.id_usuario,

                "Pago aprobado",

                `El pago del pedido #${pedido.id_pedido} fue aprobado correctamente.`

            );

        }

        // ==========================
        // PAGO RECHAZADO
        // ==========================

        if (
            estado === "RECHAZADO"
        ) {

            const {
                data: pedido
            } = await obtenerPedidoPorId(
                pago.id_pedido
            );

            await enviarNotificacion(

                pedido.id_usuario,

                "Pago rechazado",

                `El pago del pedido #${pedido.id_pedido} fue rechazado.`

            );

        }

        return res.status(200).json({

            mensaje:
                "Estado del pago actualizado correctamente",

            pago:
                data

        });

    } catch (error) {

        return res.status(500).json({
            error:
                error.message
        });

    }

};