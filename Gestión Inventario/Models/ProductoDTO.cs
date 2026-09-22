namespace Gestion_Inventario.Models
{
    public class ProductoDTO
    {
        public int ProductoId { get; set; }
        public string Codigo { get; set; }
        public string Descripcion { get; set; }
        public decimal PrecioCompra { get; set; }
        public decimal PrecioVenta { get; set; }
        public decimal Impuesto { get; set; }
        public int Existencia { get; set; }
        public int CategoriaId { get; set; }
        public string NombreCategoria { get; set; }
        public string FotografiaRuta { get; set; }
        public string HashProducto { get; set; }
    }
}