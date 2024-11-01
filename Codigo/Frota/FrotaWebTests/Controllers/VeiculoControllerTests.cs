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
	public class VeiculoControllerTests
	{
		private static VeiculoController? controller;

		[TestInitialize]
		public void Initialize()
		{
			// Arrange
			var mockService = new Mock<IVeiculoService>();

			IMapper mapper = new MapperConfiguration(cfg =>
				cfg.AddProfile(new VeiculoProfile())).CreateMapper();
			mockService.Setup(service => service.GetAll())
				.Returns(GetTestVeiculos());
			mockService.Setup(service => service.Get(1))
				.Returns(GetTargetVeiculo());
			mockService.Setup(service => service.Edit(It.IsAny<Veiculo>()))
				.Verifiable();
			mockService.Setup(service => service.Create(It.IsAny<Veiculo>()))
				.Verifiable();
			controller = new VeiculoController(mockService.Object, mapper);
		}

		[TestMethod()]
		public void IndexTestValid()
		{
			// Act
			var result = controller!.Index();
			// Assert
			Assert.IsInstanceOfType(result, typeof(ViewResult));
			ViewResult viewResult = (ViewResult)result;
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(List<VeiculoViewModel>));
			List<VeiculoViewModel>? lista = (List<VeiculoViewModel>)viewResult.ViewData.Model;
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
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(VeiculoViewModel));
			VeiculoViewModel veiculoViewModel = (VeiculoViewModel)viewResult.ViewData.Model;
			Assert.AreEqual("ABC1234", veiculoViewModel.Placa);
			Assert.AreEqual("9BWZZZ377VT004251", veiculoViewModel.Chassi);
			Assert.AreEqual(12000, veiculoViewModel.Odometro);
			Assert.AreEqual("D", veiculoViewModel.Status);
			Assert.AreEqual(2020, veiculoViewModel.Ano);
			Assert.AreEqual(2021, veiculoViewModel.Modelo);
			Assert.AreEqual("12345678901", veiculoViewModel.Renavan);
			Assert.AreEqual(DateTime.Parse("2024-03-15"), veiculoViewModel.VencimentoIpva);
			Assert.AreEqual(45000.00m, veiculoViewModel.Valor);
			Assert.AreEqual(DateTime.Parse("2023-11-01"), veiculoViewModel.DataReferenciaValor);
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
			var result = controller!.Create(GetTargetVeiculoViewModel());
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
			controller!.ModelState.AddModelError("Placa", "Campo requerido");
			// Act
			var result = controller.Create(GetTargetVeiculoViewModel());
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
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(VeiculoViewModel));
			VeiculoViewModel veiculoViewModel = (VeiculoViewModel)viewResult.ViewData.Model;
			Assert.AreEqual("ABC1234", veiculoViewModel.Placa);
			Assert.AreEqual("9BWZZZ377VT004251", veiculoViewModel.Chassi);
			Assert.AreEqual(12000, veiculoViewModel.Odometro);
			Assert.AreEqual("D", veiculoViewModel.Status);
			Assert.AreEqual(2020, veiculoViewModel.Ano);
			Assert.AreEqual(2021, veiculoViewModel.Modelo);
			Assert.AreEqual("12345678901", veiculoViewModel.Renavan);
			Assert.AreEqual(DateTime.Parse("2024-03-15"), veiculoViewModel.VencimentoIpva);
			Assert.AreEqual(45000.00m, veiculoViewModel.Valor);
			Assert.AreEqual(DateTime.Parse("2023-11-01"), veiculoViewModel.DataReferenciaValor);
		}

		[TestMethod()]
		public void EditTestPostValid()
		{
			// Act
			var result = controller!.Edit(GetTargetVeiculoViewModel().Id, GetTargetVeiculoViewModel());
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
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(VeiculoViewModel));
			VeiculoViewModel veiculoViewModel = (VeiculoViewModel)viewResult.ViewData.Model;
			Assert.AreEqual("ABC1234", veiculoViewModel.Placa);
			Assert.AreEqual("9BWZZZ377VT004251", veiculoViewModel.Chassi);
			Assert.AreEqual(12000, veiculoViewModel.Odometro);
			Assert.AreEqual("D", veiculoViewModel.Status);
			Assert.AreEqual(2020, veiculoViewModel.Ano);
			Assert.AreEqual(2021, veiculoViewModel.Modelo);
			Assert.AreEqual("12345678901", veiculoViewModel.Renavan);
			Assert.AreEqual(DateTime.Parse("2024-03-15"), veiculoViewModel.VencimentoIpva);
			Assert.AreEqual(45000.00m, veiculoViewModel.Valor);
			Assert.AreEqual(DateTime.Parse("2023-11-01"), veiculoViewModel.DataReferenciaValor);
		}

		[TestMethod()]
		public void DeleteTestGetValid()
		{
			// Act
			var result = controller!.Delete(1, GetTargetVeiculoViewModel());
			// Assert
			Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
			RedirectToActionResult redirectToActionResult = (RedirectToActionResult)result;
			Assert.IsNull(redirectToActionResult.ControllerName);
			Assert.AreEqual("Index", redirectToActionResult.ActionName);
		}

		private VeiculoViewModel GetTargetVeiculoViewModel()
		{
			return new VeiculoViewModel
			{
				Id = 1,
				Placa = "ABC1234",
				Chassi = "9BWZZZ377VT004251",
				Cor = "Branco",
				IdModeloVeiculo = 1,
				IdFrota = 1,
				IdUnidadeAdministrativa = 1,
				Odometro = 12000,
				Status = "D",
				Ano = 2020,
				Modelo = 2021,
				Renavan = "12345678901",
				VencimentoIpva = DateTime.Parse("2024-03-15"),
				Valor = 45000.00m,
				DataReferenciaValor = DateTime.Parse("2023-11-01"),
			};

		}

		private static Veiculo GetTargetVeiculo()
		{
			return new Veiculo
			{
				Id = 1,
				Placa = "ABC1234",
				Chassi = "9BWZZZ377VT004251",
				Cor = "Branco",
				IdModeloVeiculo = 1,
				IdFrota = 1,
				IdUnidadeAdministrativa = 1,
				Odometro = 12000,
				Status = "D",
				Ano = 2020,
				Modelo = 2021,
				Renavan = "12345678901",
				VencimentoIpva = DateTime.Parse("2024-03-15"),
				Valor = 45000.00m,
				DataReferenciaValor = DateTime.Parse("2023-11-01"),
			};
		}

		private IEnumerable<Veiculo> GetTestVeiculos()
		{
			return new List<Veiculo>
			{
				new Veiculo
				{
					Id = 1,
					Placa = "ABC1234",
					Chassi = "9BWZZZ377VT004251",
					Cor = "Branco",
					IdModeloVeiculo = 2,
					IdFrota = 1,
					IdUnidadeAdministrativa = 3,
					Odometro = 12000,
					Status = "D",
					Ano = 2020,
					Modelo = 2021,
					Renavan = "12345678901",
					VencimentoIpva = DateTime.Parse("2024-03-15"),
					Valor = 45000.00m,
					DataReferenciaValor = DateTime.Parse("2023-11-01"),
				},
				new Veiculo
				{
					Id = 2,
					Placa = "XYZ5678",
					Chassi = "8AFZZZ407WT004352",
					Cor = "Preto",
					IdModeloVeiculo = 3,
					IdFrota = 2,
					IdUnidadeAdministrativa = 4,
					Odometro = 25000,
					Status = "M",
					Ano = 2019,
					Modelo = 2020,
					Renavan = "98765432109",
					VencimentoIpva = DateTime.Parse("2024-06-30"),
					Valor = 35000.00m,
					DataReferenciaValor = DateTime.Parse("2023-09-15"),
				},
				new Veiculo
				{
					Id = 3,
					Placa = "JKL9012",
					Chassi = "7FBZZZ322VT009867",
					Cor = "Prata",
					IdModeloVeiculo = 1,
					IdFrota = 3,
					IdUnidadeAdministrativa = 5,
					Odometro = 18000,
					Status = "I",
					Ano = 2021,
					Modelo = 2022,
					Renavan = "11223344556",
					VencimentoIpva = DateTime.Parse("2024-12-10"),
					Valor = 55000.00m,
					DataReferenciaValor = DateTime.Parse("2023-10-10"),
				}
			};
		}

	}
}