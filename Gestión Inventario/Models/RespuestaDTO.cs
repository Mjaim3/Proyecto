using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Gestion_Inventario.Models
{
    public class RespuestaDTO
    {
        public bool Exitoso { get; set; }
        public string Mensaje { get; set; }
        public int IdGenerado { get; set; }
    }
}