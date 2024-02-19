var express = require('express');
var router = express.Router();
let jwt =require('jsonwebtoken');
const personaC=require('../app/controls/PersonaControl')
let personaControl=new personaC();

const rolC=require('../app/controls/RolControl')
let rolControl=new rolC();

const cuentaC=require('../app/controls/CuentaControl')
let cuentaControl=new cuentaC();

const noticiaC=require('../app/controls/NoticiaControl')
let noticiaControl=new noticiaC();

const comentarioC=require('../app/controls/ComentarioControl')
let comentarioControl=new comentarioC();

const auth=function middleware(req,res,next){
    const token =req.headers['news-token'];
    console.log(token);
    if(token===undefined){
      res.status(401);
      res.json({ msg: "Falta Token", code: 401 });
    }else{
      require('dotenv').config();
      const key=process.env.KEY_SEC;
      jwt.verify(token,key,async(err,decoded)=>{
        if(err){
          res.status(401);
          res.json({ msg: "ERROR",tag:'token no valido o expirado', code: 401 });
        }else{
          console.log(decoded.external);
          const models=require('../app/models');
          const cuenta=models.cuenta;
          const aux=await cuenta.findOne({
            where: {external_id:decoded.external}
         });
         if(aux===null){
          res.status(401);
          res.json({ msg: "ERROR",tag:'token no valido', code: 401 });
         }else{
          next();
        }
        }

      });
    }
    //console.log(req.url);
    //next();
}


/* GET users listing. */
router.get('/', function(req, res, next) {
  res.send('respond with a resource');
});

router.get('/ver/roles', rolControl.listar);
router.post('/guardarRoles', rolControl.guardar);

router.post('/login', cuentaControl.inicio_sesion);


router.get('/ver/noticias', noticiaControl.listar);
router.get('/obtenerNoti/:external', noticiaControl.obtener);
router.get('/noticia/obtenerComentarios/:external', comentarioControl.obtenerComentariosNoti);
router.post('/guardarNoti', noticiaControl.guardar);
router.post('/guardarFotoNoti/:external', noticiaControl.guardarRecurso);

router.get('/obtenerPersona/:external', personaControl.obtener);
router.post('/modificarPersona/:external', personaControl.modificar);
router.get('/ver/personas', personaControl.listar);
router.post('/guardarPersona', personaControl.guardar);
router.post('/guardarUsuario', personaControl.guardarUsuario);
router.post('/modificarUsuario/:external', personaControl.modificarUsuario);
router.post('/modificarAdministrador/:external', personaControl.modificarAdministrador);

router.post('/guardarComentario', comentarioControl.guardar);
router.post('/comentario/modificar/:external', comentarioControl.modificar);
router.get('/ver/comentarios', comentarioControl.listar);
router.get('/comentario/obtener/:external', comentarioControl.obtener);


module.exports = router;
