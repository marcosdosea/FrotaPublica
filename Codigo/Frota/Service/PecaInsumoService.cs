﻿using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Service
{
    public class PecaInsumoService : IPecaInsumoService
    {
        private readonly FrotaContext context;

        public PecaInsumoService(FrotaContext context)
        {
            context = context;
        }


        public uint Create(Pecainsumo pecainsumo)
        {
            context.Add(pecainsumo);
            context.SaveChanges();
            return pecainsumo.Id;
        }

        public void Delete(uint IdPeca)
        {
            var peca = context.Pecainsumos.Find(IdPeca);
        }

        public void Edit (Pecainsumo pecainsumo)
        {
            context.Update(pecainsumo);
            context.SaveChanges();
        }
        public Pecainsumo? Get(uint IdPeca)
        {
            return context.Pecainsumos.Find(IdPeca);
        }

        public IEnumerable<Pecainsumo> GetAll()
        {
            return context.Pecainsumos.AsNoTracking(); 
        }

        
    }
}
   
