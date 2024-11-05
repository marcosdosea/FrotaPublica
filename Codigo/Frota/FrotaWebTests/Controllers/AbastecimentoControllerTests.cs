using AutoMapper;
using FrotaWeb.Mappers;
using Core.Service;
using Moq;
using Core;
using Microsoft.AspNetCore.Mvc;
using FrotaWeb.Models;

namespace FrotaWeb.Controllers.Tests
{
	[TestClass()]
	public class AbastecimentoControllerTests
	{
		private static AbastecimentoController? controller;

		[TestInitialize]
		public void Initialize()
		{
			// Arrange
			var mockAbastecimentoService = new Mock<IAbastecimentoService>();

			IMapper mapper = new MapperConfiguration(cfg =>
				cfg.AddProfile(new AbastecimentoProfile())).CreateMapper();
			mockAbastecimentoService.Setup(service => service.GetAll())
				.Returns(GetTestAbastecimentos());
			mockAbastecimentoService.Setup(service => service.Get(1))
				.Returns(GetTargetAbastecimento());
			mockAbastecimentoService.Setup(service => service.Edit(It.IsAny<Abastecimento>()))
				.Verifiable();
			mockAbastecimentoService.Setup(service => service.Create(It.IsAny<Abastecimento>()))
				.Verifiable();
			controller = new AbastecimentoController(mockAbastecimentoService.Object, mapper);
		}

		[TestMethod()]
		public void IndexTestValid()
		{
			// Act
			var result = controller!.Index();
			// Assert
			Assert.IsInstanceOfType(result, typeof(ViewResult));
			ViewResult viewResult = (ViewResult)result;
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(List<AbastecimentoViewModel>));
			List<AbastecimentoViewModel>? lista = (List<AbastecimentoViewModel>)viewResult.ViewData.Model;
			Assert.AreEqual(3, lista.Count);
		}

		[TestMethod()]
		public void DetailsTestValid()
		{
			// Act
			var result = controller!.Details(1);
			// Assert
			Assert.IsInstanceOfType(result, typeof(ViewResult));
			ViewResult viewResult = (ViewResult)result;
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(AbastecimentoViewModel));
			AbastecimentoViewModel abastecimentoViewModel = (AbastecimentoViewModel)viewResult.ViewData.Model;
			Assert.AreEqual(DateTime.Parse("2021-07-02"), abastecimentoViewModel.DataHora);
			Assert.AreEqual(10000, abastecimentoViewModel.Odometro);
			Assert.AreEqual(50, abastecimentoViewModel.Litros);
		}

		[TestMethod()]
		public void CreateTestGetValid()
		{
			// Act
			var result = controller!.Create();
			// Assert
			Assert.IsInstanceOfType(result, typeof(ViewResult));
		}

		[TestMethod()]
		public void CreateTestValid()
		{
			// Act
			var result = controller!.Create(GetTargetAbastecimentoViewModel());
			// Assert
			Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
			RedirectToActionResult redirectToActionResult = (RedirectToActionResult)result;
			Assert.IsNull(redirectToActionResult.ControllerName);
			Assert.AreEqual("Index", redirectToActionResult.ActionName);
		}

		[TestMethod()]
		public void CreatePostInvalid()
		{
			// Arrange
			controller!.ModelState.AddModelError("Odomentro", "Campo requerido");
			// Act
			var result = controller.Create(GetTargetAbastecimentoViewModel());
			// Assert
			Assert.AreEqual(1, controller.ModelState.ErrorCount);
			Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
			RedirectToActionResult redirectToActionResult = (RedirectToActionResult)result;
			Assert.IsNull(redirectToActionResult.ControllerName);
			Assert.AreEqual("Index", redirectToActionResult.ActionName);
		}

		[TestMethod()]
		public void EditTestGetValid()
		{
			// Act
			var result = controller!.Edit(1);
			// Assert
			Assert.IsInstanceOfType(result, typeof(ViewResult));
			ViewResult viewResult = (ViewResult)result;
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(AbastecimentoViewModel));
			AbastecimentoViewModel abastecimentoViewModel = (AbastecimentoViewModel)viewResult.ViewData.Model;
			Assert.AreEqual(DateTime.Parse("2021-07-02"), abastecimentoViewModel.DataHora);
			Assert.AreEqual(10000, abastecimentoViewModel.Odometro);
			Assert.AreEqual(50, abastecimentoViewModel.Litros);
		}

		[TestMethod()]
		public void EditTestPostValid()
		{
			// Act
			var result = controller!.Edit(GetTargetAbastecimentoViewModel().Id, GetTargetAbastecimentoViewModel());
			// Assert
			Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
			RedirectToActionResult redirectToActionResult = (RedirectToActionResult)result;
			Assert.IsNull(redirectToActionResult.ControllerName);
			Assert.AreEqual("Index", redirectToActionResult.ActionName);
		}

		[TestMethod()]
		public void DeleteTestPostValid()
		{
			// Act
			var result = controller!.Delete(1);

			// Assert
			Assert.IsInstanceOfType(result, typeof(ViewResult));
			ViewResult viewResult = (ViewResult)result;
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(AbastecimentoViewModel));
			AbastecimentoViewModel abastecimentoViewModel = (AbastecimentoViewModel)viewResult.ViewData.Model;
			Assert.AreEqual(DateTime.Parse("2021-07-02"), abastecimentoViewModel.DataHora);
			Assert.AreEqual(10000, abastecimentoViewModel.Odometro);
			Assert.AreEqual(50, abastecimentoViewModel.Litros);
		}

		[TestMethod()]
		public void DeleteTestGetValid()
		{
			// Act
			var result = controller!.Delete(1, GetTargetAbastecimentoViewModel());
			// Assert
			Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
			RedirectToActionResult redirectToActionResult = (RedirectToActionResult)result;
			Assert.IsNull(redirectToActionResult.ControllerName);
			Assert.AreEqual("Index", redirectToActionResult.ActionName);
		}

		private static AbastecimentoViewModel GetTargetAbastecimentoViewModel()
		{
			return new AbastecimentoViewModel
			{
				Id = 1,
				IdVeiculoPercurso = 1,
				IdPessoaPercurso = 1,
				DataHora = DateTime.Parse("2021-07-02"),
				Odometro = 10000,
				Litros = 50,
				IdFornecedor = 1
			};
		}
		
		private static Abastecimento GetTargetAbastecimento()
		{
			return new Abastecimento
			{
				Id = 1,
				IdVeiculoPercurso = 1,
				IdPessoaPercurso = 1,
				DataHora = DateTime.Parse("2021-07-02"),
				Odometro = 10000,
				Litros = 50,
				IdFornecedor = 1	
			};
		}

		private static IEnumerable<Abastecimento> GetTestAbastecimentos()
		{
			return new List<Abastecimento>
			{
				new Abastecimento
				{
					Id = 1,
					IdVeiculoPercurso = 1,
					IdPessoaPercurso = 1,
					DataHora = DateTime.Parse("2021-07-02"),
					Odometro = 10000,
					Litros = 50,
					IdFornecedor = 1
				},
				new Abastecimento
				{
					Id = 2,
					IdVeiculoPercurso = 2,
					IdPessoaPercurso = 1,
					DataHora = DateTime.Parse("2021-06-11"),
					Odometro = 20000,
					Litros = 60,
					IdFornecedor = 1
				},
				new Abastecimento
				{
					Id = 3,
					IdVeiculoPercurso = 1,
					IdPessoaPercurso = 2,
					DataHora = DateTime.Parse("2021-08-12"),
					Odometro = 25000,
					Litros = 100,
					IdFornecedor = 1
				}
			};
		}
	}
}