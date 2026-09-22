using Gestion_Inventario.Models;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
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
        private ProductoDAO productoDAO = new ProductoDAO();

        // Obtener y buscar productos 
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public List<ProductoDTO> ObtenerProductos(string filtro)
        {
            try
            {
                return productoDAO.ObtenerProductos(filtro);
            }
            catch (Exception)
            {
                return new List<ProductoDTO>();
            }
        }

        // Registrar Producto calculando el Hash SHA256 para integridad
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public RespuestaDTO RegistrarProducto(ProductoDTO producto)
        {
            try
            {
                string cadenaConcatenada = $"{producto.Codigo}|{producto.Descripcion}|{producto.PrecioVenta}|{producto.Existencia}";
                producto.HashProducto = CalcularSHA256(cadenaConcatenada);

                return productoDAO.InsertarProducto(producto);
            }
            catch (Exception ex)
            {
                return new RespuestaDTO { Exitoso = false, Mensaje = "Error en el servidor: " + ex.Message };
            }
        }

        // Actualizar Producto existente
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public RespuestaDTO ActualizarProducto(ProductoDTO producto)
        {
            RespuestaDTO respuesta = new RespuestaDTO();
            try
            {
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
                                         FotografiaRuta = ISNULL(NULLIF(@FotografiaRuta, ''), FotografiaRuta),
                                         HashProducto = @HashProducto
                                     WHERE Codigo = @Codigo";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@Codigo", producto.Codigo);
                        cmd.Parameters.AddWithValue("@Descripcion", producto.Descripcion);
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
                respuesta.Mensaje = "Error al actualizar: " + ex.Message;
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