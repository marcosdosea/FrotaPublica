using Core.Service;
using Core;
using Microsoft.EntityFrameworkCore;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Service;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Service.Tests
{
	[TestClass()]
	public class PercursoServiceTests
	{
		private FrotaContext? context;
		private IPercursoService? percursoService;

		[TestInitialize]
		public void Initialize()
		{
			// Arrange
			var builder = new DbContextOptionsBuilder<FrotaContext>();
			builder.UseInMemoryDatabase("Frota");
			var options = builder.Options;
			context = new FrotaContext(options);

			context.Database.EnsureDeleted();
			context.Database.EnsureCreated();
			var percursos = new List<Percurso>
			{
				new Percurso
				{
					Id = 1,
					IdVeiculo = 101,
					IdPessoa = 1001,
					DataHoraSaida = new DateTime(2024, 11, 1, 8, 0, 0),
					DataHoraRetorno = new DateTime(2024, 11, 1, 18, 0, 0),
					LocalPartida = "São Paulo",
					LatitudePartida = -23.5505f,
					LongitudePartida = -46.6333f,
					LocalChegada = "Rio de Janeiro",
					LatitudeChegada = -22.9068f,
					LongitudeChegada = -43.1729f,
					OdometroInicial = 50000,
					OdometroFinal = 50300,
					Motivo = "Entrega de mercadoria"
				},
				new Percurso
				{
					Id = 2,
					IdVeiculo = 102,
					IdPessoa = 1002,
					DataHoraSaida = new DateTime(2024, 11, 2, 9, 0, 0),
					DataHoraRetorno = new DateTime(2024, 11, 2, 17, 30, 0),
					LocalPartida = "Belo Horizonte",
					LatitudePartida = -19.9167f,
					LongitudePartida = -43.9345f,
					LocalChegada = "Vitória",
					LatitudeChegada = -20.3155f,
					LongitudeChegada = -40.3128f,
					OdometroInicial = 25000,
					OdometroFinal = 25250,
					Motivo = "Reunião com clientes"
				},
				new Percurso
				{
					Id = 3,
					IdVeiculo = 103,
					IdPessoa = 1003,
					DataHoraSaida = new DateTime(2024, 11, 3, 7, 30, 0),
					DataHoraRetorno = new DateTime(2024, 11, 3, 20, 15, 0),
					LocalPartida = "Curitiba",
					LatitudePartida = -25.4294f,
					LongitudePartida = -49.2719f,
					LocalChegada = "Florianópolis",
					LatitudeChegada = -27.5954f,
					LongitudeChegada = -48.5480f,
					OdometroInicial = 18000,
					OdometroFinal = 18350,
					Motivo = "Entrega de documentos"
				}
			};
			context.Percursos.AddRange(percursos);
			context.SaveChanges();
			percursoService = new PercursoService(context);
		}

		[TestMethod()]
		public void CreateTest()
		{
			// Act
			percursoService!.Create(new Percurso
			{
				Id = 4,
				IdVeiculo = 102,
				IdPessoa = 1002,
				DataHoraSaida = new DateTime(2024, 11, 1, 8, 0, 0),
				DataHoraRetorno = new DateTime(2024, 11, 1, 18, 0, 0),
				LocalPartida = "São Paulo",
				LatitudePartida = -23.5505f,
				LongitudePartida = -46.6333f,
				LocalChegada = "Rio de Janeiro",
				LatitudeChegada = -22.9068f,
				LongitudeChegada = -43.1729f,
				OdometroInicial = 50000,
				OdometroFinal = 50300,
				Motivo = "Entrega de mercadoria"
			});

			// Assert
			Assert.AreEqual(4, percursoService.GetAll().Count());
			var percurso = percursoService.Get(4);
			Assert.AreEqual(102m, percurso!.IdVeiculo);
			Assert.AreEqual(1002m, percurso.IdPessoa);
		}

		[TestMethod()]
		public void DeleteTest()
		{
			// Act
			percursoService!.Delete(2);
			// Assert
			Assert.AreEqual(2, percursoService.GetAll().Count());
			var percurso = percursoService.Get(2);
			Assert.AreEqual(null, percurso);
		}

		[TestMethod()]
		public void EditTest()
		{
			// Act
			var percurso = percursoService!.Get(3);
			percurso!.LocalPartida = "Porto Alegre";
			percursoService.Edit(percurso);
			// Assert
			percurso = percursoService.Get(3);
			Assert.AreEqual("Porto Alegre", percurso!.LocalPartida);
		}

		[TestMethod()]
		public void GetTest()
		{
			var percurso = percursoService!.Get(1);
			Assert.IsNotNull(percurso);
			Assert.AreEqual("São Paulo", percurso!.LocalPartida);
		}

		[TestMethod()]
		public void GetAllTest()
		{
			// Act
			var listaPercurso = percursoService!.GetAll();
			// Assert
			Assert.IsInstanceOfType(listaPercurso, typeof(IEnumerable<Percurso>));
			Assert.IsNotNull(listaPercurso);
			Assert.AreEqual(3, listaPercurso.Count());
			Assert.AreEqual(1m, listaPercurso.First().Id);
			Assert.AreEqual("São Paulo", listaPercurso.First().LocalPartida);
		}
	}
}