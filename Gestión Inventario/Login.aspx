<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="Gestion_Inventario.Login" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Iniciar Sesión - Inventario</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body class="bg-secondary d-flex align-items-center py-4" style="height: 100vh;">
    <main class="form-signin w-100 m-auto" style="max-width: 400px;">
        <form runat="server" class="card p-4 shadow">
            <h2 class="h3 mb-3 fw-normal text-center">Control de Inventario</h2>
            
            <div class="mb-3">
                <label for="txtUsuario" class="form-label">Usuario</label>
                <asp:TextBox ID="txtUsuario" runat="server" CssClass="form-control" placeholder="Ingrese su usuario" required="required"></asp:TextBox>
            </div>
            
            <div class="mb-3">
                <label for="txtPassword" class="form-label">Contraseña</label>
                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Contraseña" required="required"></asp:TextBox>
            </div>

            <div class="mb-3 form-check">
                <asp:CheckBox ID="chkRecuerdame" runat="server" CssClass="form-check-input" />
                <label class="form-check-label" for="chkRecuerdame">Recordar usuario</label>
            </div>

            <asp:Button ID="btnIngresar" runat="server" Text="Iniciar Sesión" CssClass="w-100 btn btn-primary py-2" OnClick="btnIngresar_Click" />
            
            <asp:Label ID="lblMensaje" runat="server" CssClass="text-danger mt-3 d-block text-center" />
        </form>
    </main>
</body>
</html>