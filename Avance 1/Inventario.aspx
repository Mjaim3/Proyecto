<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Inventario.aspx.cs" Inherits="PlataformaInventario.Inventario" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Plataforma Web de Inventario y Control de Productos</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!-- FontAwesome para Iconos -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />

    <style>
        .img-preview {
            width: 80px;
            height: 80px;
            object-fit: cover;
            border-radius: 8px;
            border: 1px solid #dee2e6;
        }
        .modal-img-preview {
            width: 100%;
            max-height: 200px;
            object-fit: contain;
            border-radius: 8px;
            background-color: #f8f9fa;
        }
    </style>
</head>
<body class="bg-light">
    <form id="form1" runat="server">
        <div class="container-fluid px-4">
            <!-- Encabezado y Filtros -->
            <div class="card shadow-sm mb-4">
                <div class="card-body">
                    <div class="row g-3 align-items-center">
                        <!-- Búsqueda Instantánea -->
                        <div class="col-md-5">
                            <div class="input-group">
                                <span class="input-group-text bg-white"><i class="fa-solid fa-magnifying-glass text-muted"></i></span>
                                <input type="text" id="txtBuscar" class="form-control" placeholder="Buscar por código o descripción..." />
                            </div>
                        </div>
                        <!-- Filtro por Categoría -->
                        <div class="col-md-4">
                            <select id="ddlFiltroCategoria" class="form-select">
                                <option value="">Todas las Categorías</option>
                                <option value="Electrónica">Electrónica</option>
                                <option value="Hogar">Hogar</option>
                                <option value="Abarrotes">Abarrotes</option>
                            </select>
                        </div>
                        <!-- Botón Nuevo Producto -->
                        <div class="col-md-3 text-end">
                            <button type="button" class="btn btn-primary w-100" onclick="abrirModalCrear()">
                                <i class="fa-solid fa-plus me-1"></i> Nuevo Producto
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tabla de Productos -->
            <div class="card shadow-sm">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0" id="tablaProductos">
                            <thead class="table-light">
                                <tr>
                                    <th>Imagen</th>
                                    <th>Código</th>
                                    <th>Descripción</th>
                                    <th>Categoría</th>
                                    <th>P. Compra</th>
                                    <th>P. Venta</th>
                                    <th>Impuesto</th>
                                    <th>Existencia</th>
                                    <th class="text-center">Acciones</th>
                                </tr>
                            </thead>
                            <tbody id="tbodyProductos">
                                <!-- Filas generadas dinámicamente mediante AJAX -->
                            </tbody>
                        </table>
                    </div>
                </div>
                <!-- Paginación -->
                <div class="card-footer bg-white d-flex justify-content-between align-items-center py-3">
                    <span id="infoPaginacion" class="text-muted small">Mostrando registros</span>
                    <nav>
                        <ul class="pagination pagination-sm mb-0" id="ulPaginacion">
                            <!-- Botones de páginas generados por JS -->
                        </ul>
                    </nav>
                </div>
            </div>
        </div>

        <!-- Modal para Crear / Editar Producto -->
        <div class="modal fade" id="modalProducto" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header bg-dark text-white">
                        <h5 class="modal-title" id="lblModalTitulo"><i class="fa-solid fa-box me-2"></i>Gestión de Producto</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" id="hdnEsEdicion" value="false" />
                        <div class="row g-3">
                            <div class="col-md-4">
                                <label for="txtCodigo" class="form-label fw-bold">Código</label>
                                <input type="text" class="form-control" id="txtCodigo" maxlength="20" required />
                            </div>
                            <div class="col-md-8">
                                <label for="txtDescripcion" class="form-label fw-bold">Descripción</label>
                                <input type="text" class="form-control" id="txtDescripcion" maxlength="150" required />
                            </div>
                            <div class="col-md-4">
                                <label for="ddlCategoria" class="form-label fw-bold">Categoría</label>
                                <select class="form-select" id="ddlCategoria" required>
                                    <option value="">Seleccione...</option>
                                    <option value="Electrónica">Electrónica</option>
                                    <option value="Hogar">Hogar</option>
                                    <option value="Abarrotes">Abarrotes</option>
                                </select>
                            </div>
                            <div class="col-md-4">
                                <label for="txtPrecioCompra" class="form-label fw-bold">Precio Compra</label>
                                <input type="number" step="0.01" class="form-control" id="txtPrecioCompra" required />
                            </div>
                            <div class="col-md-4">
                                <label for="txtPrecioVenta" class="form-label fw-bold">Precio Venta</label>
                                <input type="number" step="0.01" class="form-control" id="txtPrecioVenta" required />
                            </div>
                            <div class="col-md-6">
                                <label for="txtImpuesto" class="form-label fw-bold">Impuesto (%)</label>
                                <input type="number" step="0.01" class="form-control" id="txtImpuesto" value="15.00" required />
                            </div>
                            <div class="col-md-6">
                                <label for="txtExistencia" class="form-label fw-bold">Existencia</label>
                                <input type="number" class="form-control" id="txtExistencia" required />
                            </div>
                            
                            <!-- Subida de Fotografía mediante Handler -->
                            <div class="col-md-8">
                                <label for="fileFotografia" class="form-label fw-bold">Fotografía del Producto</label>
                                <input type="file" class="form-control" id="fileFotografia" accept="image/png, image/jpeg, image/webp" />
                                <small class="text-muted">Formatos permitidos: JPG, PNG, WEBP.</small>
                            </div>
                            <div class="col-md-4 text-center">
                                <label class="form-label d-block fw-bold">Vista Previa</label>
                                <img id="imgPreviewModal" src="Uploads/default.png" class="modal-img-preview border" alt="Vista Previa" />
                                <input type="hidden" id="hdnRutaImagen" value="Uploads/default.png" />
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                        <button type="button" class="btn btn-success" id="btnGuardarProducto" onclick="guardarProducto()">
                            <i class="fa-solid fa-floppy-disk me-1"></i> Guardar Producto
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <!-- Scripts: jQuery y Bootstrap 5 -->
    <script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Lógica AJAX e Interacciones en Cliente -->
    <script>
        let paginaActual = 1;
        const registrosPorPagina = 8;
        let modalProductoBs = null;

        $(document).ready(function () {
            modalProductoBs = new bootstrap.Modal(document.getElementById('modalProducto'));

            // Carga inicial
            cargarProductos();

            // Eventos de búsqueda instantánea y filtros
            $('#txtBuscar').on('keyup', function () {
                paginaActual = 1;
                cargarProductos();
            });

            $('#ddlFiltroCategoria').on('change', function () {
                paginaActual = 1;
                cargarProductos();
            });

            // Subida asíncrona de imagen mediante Handler (.ashx)
            $('#fileFotografia').on('change', function () {
                subirImagenHandler();
            });
        });

        // Cargar Productos vía AJAX consuming WebMethod
        function cargarProductos() {
            const busqueda = $('#txtBuscar').val();
            const categoria = $('#ddlFiltroCategoria').val();

            $.ajax({
                type: "POST",
                url: "Inventario.aspx/ObtenerProductosPaginados",
                data: JSON.stringify({
                    buscar: busqueda,
                    categoria: categoria,
                    pagina: paginaActual,
                    tamanoPagina: registrosPorPagina
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const data = response.d;
                    renderizarTabla(data.Productos);
                    renderizarPaginacion(data.TotalRegistros);
                },
                error: function (xhr) {
                    console.error("Error al obtener productos:", xhr.responseText);
                }
            });
        }

        // Renderizar filas en la tabla
        function renderizarTabla(lista) {
            let html = '';
            if (!lista || lista.length === 0) {
                html = `<tr><td colspan="9" class="text-center py-4 text-muted">No se encontraron productos registrados.</td></tr>`;
            } else {
                $.each(lista, function (i, p) {
                    html += `
                        <tr>
                            <td><img src="${p.RutaImagen}" class="img-preview" alt="Foto" /></td>
                            <td class="fw-bold">${p.Codigo}</td>
                            <td>${p.Descripcion}</td>
                            <td><span class="badge bg-secondary">${p.Categoria}</span></td>
                            <td>L. ${p.PrecioCompra.toFixed(2)}</td>
                            <td>L. ${p.PrecioVenta.toFixed(2)}</td>
                            <td>${p.Impuesto}%</td>
                            <td>
                                <span class="badge ${p.Existencia > 5 ? 'bg-success' : 'bg-danger'}">
                                    ${p.Existencia}
                                </span>
                            </td>
                            <td class="text-center">
                                <button type="button" class="btn btn-sm btn-outline-warning me-1" onclick="abrirModalEditar('${p.Codigo}')">
                                    <i class="fa-solid fa-pen"></i>
                                </button>
                                <button type="button" class="btn btn-sm btn-outline-danger" onclick="eliminarProducto('${p.Codigo}')">
                                    <i class="fa-solid fa-trash"></i>
                                </button>
                            </td>
                        </tr>`;
                });
            }
            $('#tbodyProductos').html(html);
        }

        // Generar Paginación Dinámica
        function renderizarPaginacion(totalRegistros) {
            const totalPaginas = Math.ceil(totalRegistros / registrosPorPagina);
            let html = '';

            for (let i = 1; i <= totalPaginas; i++) {
                html += `
                    <li class="page-item ${i === paginaActual ? 'active' : ''}">
                        <a class="page-link" href="#" onclick="cambiarPagina(${i}); return false;">${i}</a>
                    </li>`;
            }

            $('#ulPaginacion').html(html);
            $('#infoPaginacion').text(`Total de registros: ${totalRegistros} | Página ${paginaActual} de ${totalPaginas || 1}`);
        }

        function cambiarPagina(nuevaPagina) {
            paginaActual = nuevaPagina;
            cargarProductos();
        }

        // Manejo de Subida de Archivos con Handler (.ashx)
        function subirImagenHandler() {
            const fileInput = $('#fileFotografia')[0];
            if (fileInput.files.length === 0) return;

            const formData = new FormData();
            formData.append("fileImagen", fileInput.files[0]);

            $.ajax({
                type: "POST",
                url: "UploadImageHandler.ashx",
                data: formData,
                contentType: false,
                processData: false,
                success: function (resultado) {
                    if (resultado.Exito) {
                        $('#imgPreviewModal').attr('src', resultado.Ruta);
                        $('#hdnRutaImagen').val(resultado.Ruta);
                    } else {
                        alert("Error al subir imagen: " + resultado.Mensaje);
                    }
                },
                error: function () {
                    alert("Ocurrió un error al procesar la imagen en el servidor.");
                }
            });
        }

        // Guardar (Insertar / Actualizar) Producto consumiendo WebMethod C#
        function guardarProducto() {
            const productoDto = {
                Codigo: $('#txtCodigo').val().trim(),
                Descripcion: $('#txtDescripcion').val().trim(),
                Categoria: $('#ddlCategoria').val(),
                PrecioCompra: parseFloat($('#txtPrecioCompra').val()),
                PrecioVenta: parseFloat($('#txtPrecioVenta').val()),
                Impuesto: parseFloat($('#txtImpuesto').val()),
                Existencia: parseInt($('#txtExistencia').val()),
                RutaImagen: $('#hdnRutaImagen').val()
            };

            const esEdicion = $('#hdnEsEdicion').val() === "true";
            const metodo = esEdicion ? "ActualizarProducto" : "CrearProducto";

            $.ajax({
                type: "POST",
                url: `Inventario.aspx/${metodo}`,
                data: JSON.stringify({ producto: productoDto }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d.Exito) {
                        modalProductoBs.hide();
                        cargarProductos();
                    } else {
                        alert("Error: " + response.d.Mensaje);
                    }
                }
            });
        }

        // Funciones Auxiliares para Modales y Eliminación
        function abrirModalCrear() {
            $('#hdnEsEdicion').val("false");
            $('#txtCodigo').prop('disabled', false).val('');
            $('#txtDescripcion').val('');
            $('#ddlCategoria').val('');
            $('#txtPrecioCompra').val('');
            $('#txtPrecioVenta').val('');
            $('#txtImpuesto').val('15.00');
            $('#txtExistencia').val('');
            $('#hdnRutaImagen').val('Uploads/default.png');
            $('#imgPreviewModal').attr('src', 'Uploads/default.png');
            $('#lblModalTitulo').text('Nuevo Producto');
            modalProductoBs.show();
        }

        function abrirModalEditar(codigo) {
            $.ajax({
                type: "POST",
                url: "Inventario.aspx/ObtenerProductoPorCodigo",
                data: JSON.stringify({ codigo: codigo }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const p = response.d;
                    $('#hdnEsEdicion').val("true");
                    $('#txtCodigo').prop('disabled', true).val(p.Codigo);
                    $('#txtDescripcion').val(p.Descripcion);
                    $('#ddlCategoria').val(p.Categoria);
                    $('#txtPrecioCompra').val(p.PrecioCompra);
                    $('#txtPrecioVenta').val(p.PrecioVenta);
                    $('#txtImpuesto').val(p.Impuesto);
                    $('#txtExistencia').val(p.Existencia);
                    $('#hdnRutaImagen').val(p.RutaImagen);
                    $('#imgPreviewModal').attr('src', p.RutaImagen);
                    $('#lblModalTitulo').text('Editar Producto: ' + p.Codigo);
                    modalProductoBs.show();
                }
            });
        }

        function eliminarProducto(codigo) {
            if (confirm(`¿Está seguro de eliminar el producto con código: ${codigo}?`)) {
                $.ajax({
                    type: "POST",
                    url: "Inventario.aspx/EliminarProducto",
                    data: JSON.stringify({ codigo: codigo }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        if (response.d.Exito) {
                            cargarProductos();
                        } else {
                            alert("No se pudo eliminar el producto: " + response.d.Mensaje);
                        }
                    }
                });
            }
        }
    </script>
</body>
</html>