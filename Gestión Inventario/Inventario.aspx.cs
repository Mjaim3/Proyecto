using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace Gestion_Inventario
{
    public partial class Inventario : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Validar si la variable de sesión existe; si no, redirigir al Login
            if (Session["UsuarioLogueado"] == null)
            {
                Response.Redirect("Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                CargarCategorias();
            }
        }

        private void CargarCategorias()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["ConexionDB"].ConnectionString;

            using (SqlConnection conexion = new SqlConnection(connectionString))
            {
                string query = "SELECT CategoriaId, NombreCategoria FROM Categorias";
                using (SqlCommand cmd = new SqlCommand(query, conexion))
                {
                    try
                    {
                        conexion.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            ddlCategoria.DataSource = reader;
                            ddlCategoria.DataTextField = "NombreCategoria";
                            ddlCategoria.DataValueField = "CategoriaId";
                            ddlCategoria.DataBind();
                        }
                    }
                    catch (Exception )
                    {
                        // Control de errores opcional
                    }
                }
            }

            ddlCategoria.Items.Insert(0, new ListItem("-- Seleccione una categoría --", ""));
        }
    }
}