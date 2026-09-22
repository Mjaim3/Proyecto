using Gestion_Inventario.Models;
using System;
using System.Collections.Generic;
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

    // ¡DESCOMENTA ESTA LÍNEA AQUÍ ABAJO!
    [System.Web.Script.Services.ScriptService]
    public class ServiciosInventario : System.Web.Services.WebService
    {
        private ProductoDAO productoDAO = new ProductoDAO();

        // 1. Obtener y buscar productos dinámicamente
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

        // 2. Registrar Producto calculando el Hash SHA256 para integridad
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