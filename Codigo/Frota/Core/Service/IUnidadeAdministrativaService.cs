﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Core.Service
{
    public interface IUnidadeAdministrativaService
    {
        uint Create(Unidadeadministrativa unidadeadministrativa);

        void Edit(Unidadeadministrativa unidadeadministrativa);

        void Delete(uint IdUADM);

        Unidadeadministrativa? Get(uint IdUADM);

        IEnumerable<Unidadeadministrativa> GetAll();
    }
}
