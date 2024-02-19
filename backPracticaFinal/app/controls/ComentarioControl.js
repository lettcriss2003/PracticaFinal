"use strict";
var models = require("../models");
const BadWordsFilter = require("bad-words");
var persona = models.persona;
var rol = models.rol;
var cuenta = models.cuenta;
var comentario = models.comentario;
var noticia = models.noticia;
const filter = new BadWordsFilter();

class ComentarioControl {
    async obtener(req, res) {
        const external = req.params.external;
        var lista = await comentario.findOne({
            where: { external_id: external },
            attributes: [
                "texto",
                "fecha",
                "estado",
                "usuario",
                "latitud",
                "longitud",
                "external_id",
            ],
        });
        if (lista == undefined || lista == null) {
            res.status(404);
            res.json({ msg: "No encontrado", code: 404, datos: {} });
        } else {
            res.status(200);
            res.json({ msg: "OK", code: 200, datos: lista });
        }
    }

    async listar(req, res) {
        var lista = await comentario.findAll({
            include: [
                {
                    model: models.noticia,
                    as: "noticia",
                    attributes: ["titulo", "cuerpo", "fecha", "estado", "external_id"],
                },
            ],
            attributes: [
                "texto",
                "fecha",
                "estado",
                "usuario",
                "latitud",
                "longitud",
                "external_id",
            ],
        });
        res.status(200);
        res.json({ msg: "OK", code: 200, datos: lista });
    }

    async obtenerComentariosNoti(req, res) {
        const external = req.params.external;
        const noticiaA = await noticia.findOne({
            where: { external_id: external },
        });

        if (!noticiaA) {
            res.status(404);
            return res.json({ msg: "Noticia no encontrada", code: 404, datos: {} });
        }

        var lista = await comentario.findAll({
            where: { id_noticia: noticiaA.id },
            include: [{ model: models.noticia, as: "noticia", attributes: [] }],
            attributes: [
                "texto",
                "fecha",
                "estado",
                "usuario",
                "latitud",
                "longitud",
                "external_id",
            ],
            order: [["updatedAt", "DESC"]],
            limit: 10,
        });

        var nuevaLista = lista.map((comentario) => ({
            ...comentario.dataValues,
            user_external: comentario.usuario,
        }));
        // console.log(nuevaLista);

        for (let i = 0; i < nuevaLista.length; i++) {
            const comentario = nuevaLista[i];
            const personaA = await persona.findOne({
                where: { external_id: comentario.user_external },
            });

            if (!personaA) {
                res.status(404);
                return res.json({ msg: "Usuario no encontrado", code: 404, datos: {} });
            }

            if (!personaA) {
                comentario.usuario = "Undefined";
            } else {
                comentario.usuario = personaA.nombres + " " + personaA.apellidos;
            }
        }

        if (!nuevaLista || nuevaLista.length === 0) {
            res.status(200);
            return res.json({
                msg: "No hay comentarios para esta noticia",
                code: 200,
                datos: nuevaLista,
            });
        }

        res.status(200);
        res.json({ msg: "OK", code: 200, datos: nuevaLista });
    }

    async guardar(req, res) {
        if (
            req.body.hasOwnProperty("texto") &&
            req.body.hasOwnProperty("fecha") &&
            req.body.hasOwnProperty("usuario") &&
            req.body.hasOwnProperty("noticia") &&
            req.body.hasOwnProperty("latitud") &&
            req.body.hasOwnProperty("longitud")
        ) {
            var uuid = require("uuid");
            var noticiaA = await models.noticia.findOne({
                where: { external_id: req.body.noticia },
            });

            const personasA = await persona.findOne({
                where: { external_id: req.body.usuario },
            });
            if (personasA == undefined) {
                res.status(400);
                res.json({ msg: "ERROR", tag: "Usuario no existente", code: 400 });
            }

            if (noticiaA == undefined) {
                res.status(400);
                res.json({ msg: "ERROR", tag: "Noticia no existente", code: 400 });
            } else {
                const palabrasESP = ["cmtr", "idiota", "imbecil"];
                filter.addWords(...palabrasESP);
                const comentarioLimpio = filter.clean(req.body.texto);
                if (comentarioLimpio != req.body.texto) {
                    const cuentaA = await cuenta.findOne({
                        where: { id_persona: personasA.id },
                    });
                    const updata = {
                        estado: false,
                    };
                    await cuentaA.update(updata);
                    res.status(400);
                    res.json({
                        msg: "Ha sido baneado por comentarios inapropiados",
                        tag: "Error",
                        code: 400,
                    });
                } else {
                    var data = {
                        texto: req.body.texto,
                        fecha: req.body.fecha,
                        usuario: req.body.usuario,
                        latitud: req.body.latitud,
                        longitud: req.body.longitud,
                        external_id: uuid.v4(),
                        id_noticia: noticiaA.id,
                    };
                    let transaction = await models.sequelize.transaction();
                    try {
                        var result = await comentario.create(data, { transaction });
                        await transaction.commit();
                        if (result === null) {
                            res.status(401);
                            res.json({ msg: "ERROR", tag: "No se puede crear", code: 401 });
                        } else {
                            res.status(200);
                            res.json({ msg: "OK", code: 200 });
                        }
                    } catch (error) {
                        if (transaction) await transaction.rollback();
                        res.status(203);
                        res.json({ msg: "ERROR", code: 203, error_msg: error });
                    }
                }
            }
        } else {
            res.status(400);
            res.json({ msg: "ERROR", tag: "Datos incorrectos", code: 400 });
        }
    }

    async modificar(req, res) {
        const external = req.params.external;
        if (
            req.body.hasOwnProperty("texto") &&
            req.body.hasOwnProperty("fecha") &&
            req.body.hasOwnProperty("usuario") &&
            req.body.hasOwnProperty("noticia") &&
            req.body.hasOwnProperty("latitud") &&
            req.body.hasOwnProperty("longitud")
        ) {
            try {
                const comentarioA = await comentario.findOne({
                    where: { external_id: external },
                });
                if (!comentarioA) {
                    res.status(404);
                    return res.json({
                        msg: "ERROR",
                        tag: "Comentario no encontrado",
                        code: 404,
                    });
                }
                const noticiaA = await noticia.findOne({
                    where: { external_id: req.body.noticia },
                });
                if (noticiaA == undefined) {
                    res.status(400);
                    res.json({ msg: "ERROR", tag: "Noticia no existente", code: 400 });
                } else {
                    const palabrasESP = ["cmtr", "idiota", "imbecil"];
                    filter.addWords(...palabrasESP);
                    const comentarioLimpio = filter.clean(req.body.texto);

                    if (comentarioLimpio != req.body.texto) {
                        const cuentaA = await cuenta.findOne({
                            where: { id_persona: personasA.id },
                        });
                        const updata = {
                            estado: false,
                        };
                        await cuentaA.update(updata);
                        res.status(400);
                        res.json({
                            msg: "Ha sido baneado por comentarios inapropiados",
                            tag: "Error",
                            code: 400,
                        });
                    } else {
                        const data = {
                            texto: req.body.texto,
                            fecha: req.body.fecha,
                            estado: req.body.estado,
                            usuario: req.body.usuario,
                            latitud: req.body.latitud,
                            longitud: req.body.longitud,
                            id_noticia: noticiaA.id,
                        };
                        const transaction = await models.sequelize.transaction();
                        try {
                            await comentarioA.update(data, { transaction });
                            await transaction.commit();
                            res.status(200);
                            res.json({ msg: "OK", code: 200 });
                        } catch (error) {
                            if (transaction) await transaction.rollback();
                            res.status(203);
                            res.json({ msg: "ERROR", code: 203, error_msg: error });
                        }
                    }
                }
            } catch (error) {
                res.status(500);
                res.json({ msg: "ERROR", code: 500, error_msg: error });
            }
        } else {
            res.status(400);
            res.json({ msg: "ERROR", tag: "Datos incorrectos", code: 400 });
        }
    }
}
module.exports = ComentarioControl;
