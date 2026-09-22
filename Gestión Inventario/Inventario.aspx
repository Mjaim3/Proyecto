<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Inventario.aspx.cs" Inherits="Gestion_Inventario.Inventario" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Plataforma Web de Inventario</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body class="bg-light">

    <form id="form1" runat="server">

        <!-- Barra superior con el usuario y Cerrar Sesión -->
        <nav class="navbar navbar-dark bg-dark navbar-expand-lg px-4 d-flex justify-content-between mb-4">
            <span class="navbar-brand mb-0 h1">Plataforma de Inventario</span>
            <div class="navbar-text text-light">
                Usuario: <span id="lblUsuario" runat="server">Admin</span> | 
                <asp:LinkButton ID="lnkCerrarSesion" runat="server" CssClass="text-danger text-decoration-none" OnClick="lnkCerrarSesion_Click">Cerrar Sesión</asp:LinkButton>
            </div>
        </nav>

        <div class="container py-4">
            <h2 class="mb-4 text-center">Control de Inventario</h2>

            <!-- Barra de Herramientas: Búsqueda, Filtro por Categoría y Botón Nuevo -->
            <div class="row mb-3 g-2">
                <div class="col-md-5 col-sm-12">
                    <input type="text" id="txtBuscar" class="form-control" placeholder="Buscar por código o descripción..." />
                </div>
                <div class="col-md-3 col-sm-12">
                    <asp:DropDownList ID="ddlFiltroCategoria" runat="server" CssClass="form-select" AppendDataBoundItems="true">
                        <asp:ListItem Value="">Todas las Categorías</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-md-4 col-sm-12 text-md-end">
                    <button type="button" class="btn btn-success w-100" onclick="abrirModalRegistrar()">
                        + Registrar Producto
                    </button>
                </div>
            </div>

            <!-- Tabla Dinámica Responsiva -->
            <div class="card shadow-sm">
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle" id="tablaProductos">
                            <thead class="table-dark">
                                <tr>
                                    <th>Fotografía</th>
                                    <th>Código</th>
                                    <th>Descripción</th>
                                    <th>P. Compra</th>
                                    <th>P. Venta</th>
                                    <th>Existencia</th>
                                    <th>Categoría</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal para Registro y Edición de Producto -->
        <div class="modal fade" id="modalProducto" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="modalTitulo">Nuevo Producto</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Código del Producto</label>
                            <input type="text" id="txtCodigo" class="form-control" required />
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Descripción</label>
                            <input type="text" id="txtDescripcion" class="form-control" required />
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Precio Compra</label>
                                <input type="number" step="0.01" id="txtPrecioCompra" class="form-control" required />
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Precio Venta</label>
                                <input type="number" step="0.01" id="txtPrecioVenta" class="form-control" required />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Impuesto (%)</label>
                                <input type="number" step="0.01" id="txtImpuesto" class="form-control" value="15.00" />
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Existencia</label>
                                <input type="number" id="txtExistencia" class="form-control" required />
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="ddlCategoria" class="form-label">Categoría</label>
                            <asp:DropDownList ID="ddlCategoria" runat="server" CssClass="form-control">
                            </asp:DropDownList>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Fotografía</label>
                            <input type="file" id="FileUpload1" class="form-control" accept=".jpg, .jpeg, .png" />
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                        <button type="button" id="btnGuardar" class="btn btn-primary">Guardar Producto</button>
                    </div>
                </div>
            </div>
        </div>

    </form>

    <!-- Scripts necesarios: jQuery y Bootstrap JS -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Script AJAX personalizado -->
    <script>
        var modoEdicion = false;
        var fotoActual = "";

        $(document).ready(function () {
            cargarProductos("", "");

            $("#txtBuscar").on("keyup", function () {
                var filtroTexto = $(this).val();
                var categoriaId = $("[id$='ddlFiltroCategoria']").val();
                cargarProductos(filtroTexto, categoriaId);
            });

            // Evento cuando seleccionas una categoría en el ComboBox de la barra superior
            $("[id$='ddlFiltroCategoria']").on("change", function () {
                var filtroTexto = $("#txtBuscar").val();
                var categoriaId = $(this).val();
                cargarProductos(filtroTexto, categoriaId);
            });

            $("#btnGuardar").off("click").on("click", function () {
                var codigo = $("#txtCodigo").val().trim();
                var desc = $("#txtDescripcion").val().trim();

                if (!codigo) {
                    alert("¡El campo Código del Producto es obligatorio y no puede estar vacío!");
                    $("#txtCodigo").focus();
                    return;
                }

                if (!desc) {
                    alert("Por favor, ingresa una descripción.");
                    $("#txtDescripcion").focus();
                    return;
                }

                enviarDatosProductoSaltandoJSON(fotoActual);
            });
        });

        function abrirModalRegistrar() {
            modoEdicion = false; 
            fotoActual = "";
            $("#modalTitulo").text("Nuevo Producto");

            $("#txtCodigo").val("").prop("readonly", false).focus();
            $("#txtDescripcion").val("");
            $("#txtPrecioCompra").val("");
            $("#txtPrecioVenta").val("");
            $("#txtImpuesto").val("15.00");
            $("#txtExistencia").val("");
            $("#FileUpload1").val("");

            var modalEl = document.getElementById('modalProducto');
            var myModal = bootstrap.Modal.getInstance(modalEl);
            if (!myModal) {
                myModal = new bootstrap.Modal(modalEl);
            }
            myModal.show();
        }

        function prepararEdicion(codigo, descripcion, pCompra, pVenta, existencia, categoriaId, fotografiaRuta) {
            modoEdicion = true;
            fotoActual = fotografiaRuta || "";
            $("#modalTitulo").text("Editar Producto");
            $("#txtCodigo").val(codigo).prop("readonly", true);
            $("#txtDescripcion").val(descripcion);
            $("#txtPrecioCompra").val(pCompra);
            $("#txtPrecioVenta").val(pVenta);
            $("#txtExistencia").val(existencia);
            $("[id$='ddlCategoria']").val(categoriaId);
            $("#FileUpload1").val("");

            var modalEl = document.getElementById('modalProducto');
            var myModal = bootstrap.Modal.getInstance(modalEl);
            if (!myModal) {
                myModal = new bootstrap.Modal(modalEl);
            }
            myModal.show();
        }

        function cargarProductos(filtro, categoriaId) {
            $.ajax({
                type: "POST",
                url: "ServiciosInventario.asmx/ObtenerProductos",
                data: JSON.stringify({ filtro: filtro }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var productos = response.d;
                    var filas = "";

                    var textoCategoriaSeleccionada = $("[id$='ddlFiltroCategoria'] option:selected").text().trim();
                    var filtrarPorCat = (categoriaId && categoriaId !== "" && textoCategoriaSeleccionada !== "Todas las Categorías");

                    $.each(productos, function (i, p) {
                        if (filtrarPorCat) {
                            var catProducto = (p.NombreCategoria || "").trim();
                            if (catProducto.toLowerCase() !== textoCategoriaSeleccionada.toLowerCase()) {
                                return;
                            }
                        }

                        var foto = p.FotografiaRuta ? p.FotografiaRuta : "https://via.placeholder.com/50";
                        filas += `<tr>
                                    <td><img src="${foto}" width="70" height="70" class="rounded object-fit-cover" /></td>
                                    <td>${p.Codigo}</td>
                                    <td>${p.Descripcion}</td>
                                    <td>$${p.PrecioCompra.toFixed(2)}</td>
                                    <td>$${p.PrecioVenta.toFixed(2)}</td>
                                    <td><span class="badge bg-secondary">${p.Existencia}</span></td>
                                    <td>${p.NombreCategoria}</td>
                                    <td>
                                        <button type="button" class="btn btn-warning btn-sm me-1" onclick="prepararEdicion('${p.Codigo}', '${p.Descripcion}', ${p.PrecioCompra}, ${p.PrecioVenta}, ${p.Existencia}, ${p.CategoriaId}, '${p.FotografiaRuta || ''}')">Editar</button>
                                        <button type="button" class="btn btn-danger btn-sm" onclick="eliminarProducto('${p.Codigo}')">Eliminar</button>
                                    </td>
                                </tr>`;
                    });

                    $("#tablaProductos tbody").html(filas);
                },
                error: function (err) {
                    console.log("Error al obtener productos: ", err);
                }
            });
        }

        function eliminarProducto(codigo) {
            if (confirm("¿Estás seguro de eliminar este producto con código " + codigo + "?")) {
                $.ajax({
                    type: "POST",
                    url: "ServiciosInventario.asmx/EliminarProducto",
                    data: JSON.stringify({ codigo: codigo }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var res = response.d;
                        if (res.Exitoso) {
                            alert(res.Mensaje);
                            var filtroActual = $("#txtBuscar").val();
                            var categoriaActual = $("[id$='ddlFiltroCategoria']").val();
                            cargarProductos(filtroActual, categoriaActual);
                        } else {
                            alert("Error del servidor: " + res.Mensaje);
                        }
                    },
                    error: function (xhr) {
                        alert("Error al intentar eliminar el producto.");
                    }
                });
            }
        }

        function enviarDatosProductoSaltandoJSON(rutaImagen) {
            var formData = new FormData();
            formData.append("Codigo", $("#txtCodigo").val());
            formData.append("Descripcion", $("#txtDescripcion").val());
            formData.append("PrecioCompra", $("#txtPrecioCompra").val());
            formData.append("PrecioVenta", $("#txtPrecioVenta").val());
            formData.append("Impuesto", $("#txtImpuesto").val());
            formData.append("Existencia", $("#txtExistencia").val());
            formData.append("CategoriaId", $("[id$='ddlCategoria']").val());

            var archivo = $("#FileUpload1")[0].files[0];
            if (archivo) {
                formData.append("ImagenFile", archivo);
            } else {
                formData.append("FotografiaRuta", rutaImagen);
            }

            var urlServicio = modoEdicion ? "ServiciosInventario.asmx/ActualizarProductoConFoto" : "ServiciosInventario.asmx/RegistrarProductoConFoto";

            $.ajax({
                type: "POST",
                url: urlServicio,
                data: formData,
                processData: false,
                contentType: false,
                success: function (response) {
                    var res = response.d !== undefined ? response.d : response;

                    if (typeof res === "string") {
                        try { res = JSON.parse(res); } catch (e) { }
                    }

                    if (res && (res.Exitoso === true || res.Exitoso === "true" || res.Mensaje)) {
                        alert(res.Mensaje || "¡Operación realizada con éxito!");
                    } else {
                        alert("¡Producto guardado/actualizado con éxito!");
                    }

                    var modalEl = document.getElementById('modalProducto');
                    var modalInstance = bootstrap.Modal.getInstance(modalEl);
                    if (modalInstance) {
                        modalInstance.hide();
                    }

                    var filtroActual = $("#txtBuscar").val();
                    var categoriaActual = $("[id$='ddlFiltroCategoria']").val();
                    cargarProductos(filtroActual, categoriaActual);
                },
                error: function (xhr, status, error) {
                    console.log("Error completo:", xhr.responseText);
                    alert("Error en la petición AJAX: " + xhr.statusText);
                }
            });
        }
    </script>
</body>
</html>