using System;
using System.IO;
using System.Web;
using System.Web.Script.Serialization;

namespace Gestion_Inventario
{
    public class UploadProductoHandler : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            var serializer = new JavaScriptSerializer();

            try
            {
                if (context.Request.Files.Count > 0)
                {
                    HttpPostedFile archivo = context.Request.Files[0];
                    string carpeta = context.Server.MapPath("~/Uploads/");

                    if (!Directory.Exists(carpeta))
                    {
                        Directory.CreateDirectory(carpeta);
                    }

                    string extension = Path.GetExtension(archivo.FileName);
                    string nombreUnico = Guid.NewGuid().ToString() + extension;
                    string rutaCompleta = Path.Combine(carpeta, nombreUnico);

                    archivo.SaveAs(rutaCompleta);

                    string rutaRelativa = "Uploads/" + nombreUnico;
                    var respuestaExito = new { exitoso = true, ruta = rutaRelativa, mensaje = "Imagen subida correctamente" };
                    context.Response.Write(serializer.Serialize(respuestaExito));
                }
                else
                {
                    var respuestaError = new { exitoso = false, ruta = "", mensaje = "No se adjuntó ningún archivo." };
                    context.Response.Write(serializer.Serialize(respuestaError));
                }
            }
            catch (Exception ex)
            {
                var respuestaExcepcion = new { exitoso = false, ruta = "", mensaje = ex.Message };
                context.Response.Write(serializer.Serialize(respuestaExcepcion));
            }
        }

        public bool IsReusable => false;
    }
}