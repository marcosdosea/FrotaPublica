using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Core.DTO
{

    /// <summary>
    /// classe dto modelo do veiculo, quando utilizado retorna o modelo(nome) 
    /// do veiculo e a capacidade do tanque de combustivel, 
    /// </summary>
     public class ModeloVeiculoDto
    {
        public string Nome { get; set; }
        public int CapacidadeTanque { get; set; }

    }
}
