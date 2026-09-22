using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace Gestion_Inventario.Models
{
    public class ProductoDAO
    {
        private readonly string conexionString = ConfigurationManager.ConnectionStrings["ConexionDB"].ConnectionString;

        // Método para insertar un producto
        public RespuestaDTO InsertarProducto(ProductoDTO producto)
        {
            RespuestaDTO respuesta = new RespuestaDTO();
            using (SqlConnection conexion = new SqlConnection(conexionString))
            {
                using (SqlCommand cmd = new SqlCommand("SP_InsertarProducto", conexion))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Codigo", producto.Codigo);
                    cmd.Parameters.AddWithValue("@Descripcion", producto.Descripcion);
                    cmd.Parameters.AddWithValue("@PrecioCompra", producto.PrecioCompra);
                    cmd.Parameters.AddWithValue("@PrecioVenta", producto.PrecioVenta);
                    cmd.Parameters.AddWithValue("@Impuesto", producto.Impuesto);
                    cmd.Parameters.AddWithValue("@Existencia", producto.Existencia);
                    cmd.Parameters.AddWithValue("@CategoriaId", producto.CategoriaId);
                    cmd.Parameters.AddWithValue("@FotografiaRuta", (object)producto.FotografiaRuta ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@HashProducto", (object)producto.HashProducto ?? DBNull.Value);

                    try
                    {
                        conexion.Open();
                        cmd.ExecuteNonQuery();
                        respuesta.Exitoso = true;
                        respuesta.Mensaje = "Producto registrado correctamente.";
                    }
                    catch (Exception ex)
                    {
                        respuesta.Exitoso = false;
                        respuesta.Mensaje = "Error al registrar el producto: " + ex.Message;
                    }
                }
            }
            return respuesta;
        }

        public bool ValidarUsuario(string nombreUsuario, string passwordHash)
        {
            string conexionString = ConfigurationManager.ConnectionStrings["ConexionDB"].ConnectionString;
            using (SqlConnection conexion = new SqlConnection(conexionString))
            {
                using (SqlCommand cmd = new SqlCommand("SP_ValidarUsuario", conexion))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@NombreUsuario", nombreUsuario);
                    cmd.Parameters.AddWithValue("@PasswordHash", passwordHash);

                    conexion.Open();
                    int resultado = Convert.ToInt32(cmd.ExecuteScalar());
                    return resultado > 0;
                }
            }
        }

        // Método para obtener y buscar productos dinámicamente
        public List<ProductoDTO> ObtenerProductos(string filtro)
        {
            List<ProductoDTO> lista = new List<ProductoDTO>();
            using (SqlConnection conexion = new SqlConnection(conexionString))
            {
                using (SqlCommand cmd = new SqlCommand("SP_ObtenerProductos", conexion))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Filtro", string.IsNullOrEmpty(filtro) ? "" : filtro);

                    conexion.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            lista.Add(new ProductoDTO
                            {
                                ProductoId = Convert.ToInt32(reader["ProductoId"]),
                                Codigo = reader["Codigo"].ToString(),
                                Descripcion = reader["Descripcion"].ToString(),
                                PrecioCompra = Convert.ToDecimal(reader["PrecioCompra"]),
                                PrecioVenta = Convert.ToDecimal(reader["PrecioVenta"]),
                                Impuesto = Convert.ToDecimal(reader["Impuesto"]),
                                Existencia = Convert.ToInt32(reader["Existencia"]),
                                NombreCategoria = reader["NombreCategoria"].ToString(),
                                FotografiaRuta = reader["FotografiaRuta"] != DBNull.Value ? reader["FotografiaRuta"].ToString() : string.Empty
                            });
                        }
                    }
                }
            }
            return lista;
        }
    }
}