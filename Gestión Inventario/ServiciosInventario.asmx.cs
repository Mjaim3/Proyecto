using Gestion_Inventario.Models;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;

namespace Gestion_Inventario
{
    /// <summary>
    /// Descripción breve de ServiciosInventario
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]

    [System.Web.Script.Services.ScriptService]
    public class ServiciosInventario : System.Web.Services.WebService
    {
        private ProductoDAO ProductoDAO = new ProductoDAO();

        // Obtener y buscar productos 
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public List<ProductoDTO> ObtenerProductos(string filtro)
        {
            try
            {
                return ProductoDAO.ObtenerProductos(filtro);
            }
            catch (Exception)
            {
                return new List<ProductoDTO>();
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public RespuestaDTO RegistrarProductoConFoto()
        {
            RespuestaDTO respuesta = new RespuestaDTO();
            try
            {
                var context = HttpContext.Current;
                string codigo = context.Request.Form["Codigo"];
                string descripcion = context.Request.Form["Descripcion"];

                decimal.TryParse(context.Request.Form["PrecioCompra"], System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out decimal precioCompra);
                decimal.TryParse(context.Request.Form["PrecioVenta"], System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out decimal precioVenta);
                decimal.TryParse(context.Request.Form["Impuesto"], System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out decimal impuesto);
                int.TryParse(context.Request.Form["Existencia"], out int existencia);
                int.TryParse(context.Request.Form["CategoriaId"], out int categoriaId);

                string rutaRelativa = string.Empty;

                if (context.Request.Files.Count > 0)
                {
                    HttpPostedFile archivo = context.Request.Files["ImagenFile"];
                    if (archivo != null && archivo.ContentLength > 0)
                    {
                        string nombreArchivo = Guid.NewGuid().ToString() + System.IO.Path.GetExtension(archivo.FileName);
                        string directorio = context.Server.MapPath("~/Uploads/");

                        if (!System.IO.Directory.Exists(directorio))
                        {
                            System.IO.Directory.CreateDirectory(directorio);
                        }

                        archivo.SaveAs(directorio + nombreArchivo);
                        rutaRelativa = "Uploads/" + nombreArchivo;
                    }
                }

                ProductoDTO producto = new ProductoDTO
                {
                    Codigo = codigo,
                    Descripcion = descripcion,
                    PrecioCompra = precioCompra,
                    PrecioVenta = precioVenta,
                    Impuesto = impuesto,
                    Existencia = existencia,
                    CategoriaId = categoriaId,
                    FotografiaRuta = rutaRelativa
                };

                string cadenaConcatenada = $"{producto.Codigo}|{producto.Descripcion}|{producto.PrecioVenta}|{producto.Existencia}";
                producto.HashProducto = CalcularSHA256(cadenaConcatenada);

                return ProductoDAO.InsertarProducto(producto);
            }
            catch (Exception ex)
            {
                respuesta.Exitoso = false;
                respuesta.Mensaje = "Error al Registrar: " + ex.Message;
                return respuesta;
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public RespuestaDTO ActualizarProductoConFoto()
        {
            RespuestaDTO respuesta = new RespuestaDTO();
            try
            {
                var context = HttpContext.Current;
                string codigo = context.Request.Form["Codigo"];
                string descripcion = context.Request.Form["Descripcion"];

                decimal.TryParse(context.Request.Form["PrecioCompra"], System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out decimal precioCompra);
                decimal.TryParse(context.Request.Form["PrecioVenta"], System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out decimal precioVenta);
                decimal.TryParse(context.Request.Form["Impuesto"], System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out decimal impuesto);
                int.TryParse(context.Request.Form["Existencia"], out int existencia);
                int.TryParse(context.Request.Form["CategoriaId"], out int categoriaId);
                string rutaRelativa = context.Request.Form["FotografiaRuta"]; // Mantiene la ruta anterior si no se sube una nueva

                if (context.Request.Files.Count > 0)
                {
                    HttpPostedFile archivo = context.Request.Files["ImagenFile"];
                    if (archivo != null && archivo.ContentLength > 0)
                    {
                        string nombreArchivo = Guid.NewGuid().ToString() + System.IO.Path.GetExtension(archivo.FileName);
                        string directorio = context.Server.MapPath("~/Uploads/");

                        if (!System.IO.Directory.Exists(directorio))
                        {
                            System.IO.Directory.CreateDirectory(directorio);
                        }

                        archivo.SaveAs(directorio + nombreArchivo);
                        rutaRelativa = "Uploads/" + nombreArchivo;
                    }
                }

                ProductoDTO producto = new ProductoDTO
                {
                    Codigo = codigo,
                    Descripcion = descripcion,
                    PrecioCompra = precioCompra,
                    PrecioVenta = precioVenta,
                    Impuesto = impuesto,
                    Existencia = existencia,
                    CategoriaId = categoriaId,
                    FotografiaRuta = rutaRelativa
                };

                string cadenaConcatenada = $"{producto.Codigo}|{producto.Descripcion}|{producto.PrecioVenta}|{producto.Existencia}";
                producto.HashProducto = CalcularSHA256(cadenaConcatenada);

                using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["GestionInventario"].ConnectionString))
                {
                    con.Open();
                    string query = @"UPDATE Productos 
                                     SET Descripcion = @Descripcion, 
                                         PrecioCompra = @PrecioCompra, 
                                         PrecioVenta = @PrecioVenta, 
                                         Impuesto = @Impuesto, 
                                         Existencia = @Existencia, 
                                         CategoriaId = @CategoriaId, 
                                         FotografiaRuta = @FotografiaRuta,
                                         HashProducto = @HashProducto
                                     WHERE Codigo = @Codigo";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@Codigo", (object)producto.Codigo ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@Descripcion", (object)producto.Descripcion ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@PrecioCompra", producto.PrecioCompra);
                        cmd.Parameters.AddWithValue("@PrecioVenta", producto.PrecioVenta);
                        cmd.Parameters.AddWithValue("@Impuesto", producto.Impuesto);
                        cmd.Parameters.AddWithValue("@Existencia", producto.Existencia);
                        cmd.Parameters.AddWithValue("@CategoriaId", producto.CategoriaId);
                        cmd.Parameters.AddWithValue("@FotografiaRuta", (object)producto.FotografiaRuta ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@HashProducto", (object)producto.HashProducto ?? DBNull.Value);

                        cmd.ExecuteNonQuery();
                    }
                }

                respuesta.Exitoso = true;
                respuesta.Mensaje = "Producto actualizado correctamente.";
            }
            catch (Exception ex)
            {
                respuesta.Exitoso = false;
                respuesta.Mensaje = "Error al Actualizar: " + ex.Message;
            }
            return respuesta;
        }

        // Eliminar Producto
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public RespuestaDTO EliminarProducto(string codigo)
        {
            RespuestaDTO respuesta = new RespuestaDTO();
            try
            {
                bool eliminado = ProductoDAO.Eliminar(codigo); 

                if (eliminado)
                {
                    respuesta.Exitoso = true;
                    respuesta.Mensaje = "Producto eliminado correctamente.";
                }
                else
                {
                    respuesta.Exitoso = false;
                    respuesta.Mensaje = "No se encontró el producto a eliminar.";
                }
            }
            catch (Exception ex)
            {
                respuesta.Exitoso = false;
                respuesta.Mensaje = "Error al eliminar: " + ex.Message;
            }
            return respuesta;
        }


        private string CalcularSHA256(string texto)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(texto));
                StringBuilder builder = new StringBuilder();
                foreach (byte b in bytes)
                {
                    builder.Append(b.ToString("x2"));
                }
                return builder.ToString();
            }
        }
    }
}