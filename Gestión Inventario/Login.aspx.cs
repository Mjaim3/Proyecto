using Gestion_Inventario.Models;
using System;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.UI;

namespace Gestion_Inventario { 
public partial class Login : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Recuperar cookie si existe para rellenar el usuario automáticamente
            if (Request.Cookies["UsuarioRecuerdame"] != null)
            {
                txtUsuario.Text = Request.Cookies["UsuarioRecuerdame"].Value;
                chkRecuerdame.Checked = true;
            }
        }
    }

    protected void btnIngresar_Click(object sender, EventArgs e)
    {
        string usuario = txtUsuario.Text.Trim();
        string passwordPlano = txtPassword.Text.Trim();

        // 1. Cifrar la contraseña usando SHA256
        string passwordHash = CalcularSHA256(passwordPlano);

        // 2. Validar con la base de datos
        ProductoDAO dao = new ProductoDAO();
        bool esValido = dao.ValidarUsuario(usuario, passwordHash);

        if (esValido)
        {
            // 3. Crear Variable de Sesión (Seguridad de acceso)
            Session["UsuarioLogueado"] = usuario;

            // 4. Manejo de Cookies (Recordar usuario si se marcó la opción)
            if (chkRecuerdame.Checked)
            {
                HttpCookie cookie = new HttpCookie("UsuarioRecuerdame", usuario);
                cookie.Expires = DateTime.Now.AddDays(7); // Expira en 7 días
                Response.Cookies.Add(cookie);
            }
            else
            {
                // Si desmarcó, eliminar cookie previa
                if (Request.Cookies["UsuarioRecuerdame"] != null)
                {
                    HttpCookie cookie = new HttpCookie("UsuarioRecuerdame", "");
                    cookie.Expires = DateTime.Now.AddDays(-1);
                    Response.Cookies.Add(cookie);
                }
            }

            // Redirigir a la ventana principal
            Response.Redirect("Inventario.aspx");
        }
        else
        {
            lblMensaje.Text = "Usuario o contraseña incorrectos.";
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