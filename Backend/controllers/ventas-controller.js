import { supabase } from "../config/supabase.js";

// Estados que NO cuentan como venta
const ESTADOS_NO_VENTA = ["PENDIENTE", "CANCELADO", "RECHAZADO"];

// Colombia es UTC-5 todo el año (no tiene horario de verano)
const OFFSET_COLOMBIA_MS = -5 * 60 * 60 * 1000;

// Convierte una fecha a "hora Colombia" para poder agrupar por día/mes correctamente
const aFechaColombia = (valor) => new Date(new Date(valor).getTime() + OFFSET_COLOMBIA_MS);
const claveDia = (d) => d.toISOString().slice(0, 10); // 2026-11-12
const claveMes = (d) => d.toISOString().slice(0, 7);  // 2026-11

// Trae todos los pedidos que cuentan como venta desde una fecha (con paginación)
const obtenerPedidosVenta = async (desdeISO) => {
    const tamanoPagina = 1000;
    let desde = 0;
    const todos = [];

    while (true) {
        const { data, error } = await supabase
            .from("pedidos")
            .select("id_pedido, total, fecha_pedido")
            .not("estado", "in", `(${ESTADOS_NO_VENTA.join(",")})`)
            .gte("fecha_pedido", desdeISO)
            .order("fecha_pedido", { ascending: true })
            .range(desde, desde + tamanoPagina - 1);

        if (error) return { error };

        todos.push(...data);
        if (data.length < tamanoPagina) break;
        desde += tamanoPagina;
    }

    return { data: todos };
};

// ==========================
// RESUMEN DE VENTAS (SOLO ADMIN)
// ==========================
export const resumenVentas = async (req, res) => {
    try {
        const ahora = aFechaColombia(Date.now());
        const anio = ahora.getUTCFullYear();
        const mes = ahora.getUTCMonth();
        const dia = ahora.getUTCDate();

        // Inicio (hora Colombia) del mes de hace 11 meses -> total 12 meses
        const inicioLocal = Date.UTC(anio, mes - 11, 1);
        const desdeISO = new Date(inicioLocal - OFFSET_COLOMBIA_MS).toISOString();

        const { data: pedidos, error } = await obtenerPedidosVenta(desdeISO);

        if (error) {
            return res.status(500).json({ error: error.message });
        }

        // Prepara los últimos 30 días y los últimos 12 meses (en 0 por defecto)
        const diarias = new Map();
        for (let i = 29; i >= 0; i--) {
            const d = new Date(Date.UTC(anio, mes, dia - i));
            diarias.set(claveDia(d), { fecha: claveDia(d), total: 0, pedidos: 0 });
        }

        const mensuales = new Map();
        for (let i = 11; i >= 0; i--) {
            const d = new Date(Date.UTC(anio, mes - i, 1));
            mensuales.set(claveMes(d), { mes: claveMes(d), total: 0, pedidos: 0 });
        }

        // Acumula cada pedido en su día y en su mes
        for (const p of pedidos) {
            const fechaLocal = aFechaColombia(p.fecha_pedido);
            const total = Number(p.total) || 0;

            const itemDia = diarias.get(claveDia(fechaLocal));
            if (itemDia) {
                itemDia.total += total;
                itemDia.pedidos += 1;
            }

            const itemMes = mensuales.get(claveMes(fechaLocal));
            if (itemMes) {
                itemMes.total += total;
                itemMes.pedidos += 1;
            }
        }

        const listaDiarias = [...diarias.values()];
        const listaMensuales = [...mensuales.values()];

        const hoy = listaDiarias[listaDiarias.length - 1];
        const mesActual = listaMensuales[listaMensuales.length - 1];

        return res.status(200).json({
            total_periodo: listaMensuales.reduce((acc, m) => acc + m.total, 0),
            pedidos_periodo: listaMensuales.reduce((acc, m) => acc + m.pedidos, 0),
            total_hoy: hoy.total,
            pedidos_hoy: hoy.pedidos,
            total_mes: mesActual.total,
            pedidos_mes: mesActual.pedidos,
            diarias: listaDiarias,
            mensuales: listaMensuales
        });

    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};