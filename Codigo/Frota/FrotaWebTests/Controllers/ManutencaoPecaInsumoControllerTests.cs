using AutoMapper;
using Core.Service;
using Core;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Mvc;
using Moq;
using FrotaWeb.Mappers;

namespace FrotaWeb.Controllers.Tests
{
	[TestClass()]
	public class ManutencaoPecaInsumoControllerTests
	{
		private static ManutencaoPecaInsumoController? controller;

		[TestInitialize]
		public void Initialize()
		{
			// Arrange
			var mockManutencaoPecaInsumoService = new Mock<IManutencaoPecaInsumoService>();

			IMapper mapper = new MapperConfiguration(cfg =>
				cfg.AddProfile(new ManutencaoPecaInsumoProfile())).CreateMapper();
			mockManutencaoPecaInsumoService.Setup(service => service.GetAll())
				.Returns(GetTestManutencaoPecasInsumos());
			mockManutencaoPecaInsumoService.Setup(service => service.Get(1))
				.Returns(GetTargetManutencaoPecaInsumo());
			mockManutencaoPecaInsumoService.Setup(service => service.Edit(It.IsAny<Manutencaopecainsumo>()))
				.Verifiable();
			mockManutencaoPecaInsumoService.Setup(service => service.Create(It.IsAny<Manutencaopecainsumo>()))
				.Verifiable();
			controller = new ManutencaoPecaInsumoController(mockManutencaoPecaInsumoService.Object, mapper);
		}

		[TestMethod()]
		public void IndexTestValid()
		{
			// Act
			var result = controller!.Index();
			// Assert
			Assert.IsInstanceOfType(result, typeof(ViewResult));
			ViewResult viewResult = (ViewResult)result;
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(List<ManutencaoPecaInsumoViewModel>));
			List<ManutencaoPecaInsumoViewModel>? lista = (List<ManutencaoPecaInsumoViewModel>)viewResult.ViewData.Model;
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
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(ManutencaoPecaInsumoViewModel));
			ManutencaoPecaInsumoViewModel manutencaoPecaInsumoViewModel = (ManutencaoPecaInsumoViewModel)viewResult.ViewData.Model;
			Assert.AreEqual(12, manutencaoPecaInsumoViewModel.MesesGarantia);
			Assert.AreEqual(5.5f, manutencaoPecaInsumoViewModel.Quantidade);
			Assert.AreEqual(299.99m, manutencaoPecaInsumoViewModel.ValorIndividual);
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
			var result = controller!.Create(GetTargetManutencaoPecaInsumoViewModel());
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
			controller!.ModelState.AddModelError("Quantidade", "Campo requerido");
			// Act
			var result = controller.Create(GetTargetManutencaoPecaInsumoViewModel());
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
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(ManutencaoPecaInsumoViewModel));
			ManutencaoPecaInsumoViewModel manutencaoPecaInsumoViewModel = (ManutencaoPecaInsumoViewModel)viewResult.ViewData.Model;
			Assert.AreEqual(12, manutencaoPecaInsumoViewModel.MesesGarantia);
			Assert.AreEqual(5.5f, manutencaoPecaInsumoViewModel.Quantidade);
			Assert.AreEqual(299.99m, manutencaoPecaInsumoViewModel.ValorIndividual);
		}

		[TestMethod()]
		public void EditTestPostValid()
		{
			// Act
			var result = controller!.Edit(GetTargetManutencaoPecaInsumoViewModel().IdManutencao, GetTargetManutencaoPecaInsumoViewModel());
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
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(ManutencaoPecaInsumoViewModel));
			ManutencaoPecaInsumoViewModel manutencaoPecaInsumoViewModel = (ManutencaoPecaInsumoViewModel)viewResult.ViewData.Model;
			Assert.AreEqual(12, manutencaoPecaInsumoViewModel.MesesGarantia);
			Assert.AreEqual(5.5f, manutencaoPecaInsumoViewModel.Quantidade);
			Assert.AreEqual(299.99m, manutencaoPecaInsumoViewModel.ValorIndividual);
		}

		[TestMethod()]
		public void DeleteTestGetValid()
		{
			// Act
			var result = controller!.Delete(1, GetTargetManutencaoPecaInsumoViewModel());
			// Assert
			Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
			RedirectToActionResult redirectToActionResult = (RedirectToActionResult)result;
			Assert.IsNull(redirectToActionResult.ControllerName);
			Assert.AreEqual("Index", redirectToActionResult.ActionName);
		}

		private static ManutencaoPecaInsumoViewModel GetTargetManutencaoPecaInsumoViewModel()
		{
			return new ManutencaoPecaInsumoViewModel
			{
				IdManutencao = 1,
				IdPecaInsumo = 1001,
				IdMarcaPecaInsumo = 2001,
				Quantidade = 5.5f,
				MesesGarantia = 12,
				KmGarantia = 50000,
				ValorIndividual = 299.99m
			};
		}

		private static Manutencaopecainsumo GetTargetManutencaoPecaInsumo()
		{
			return new Manutencaopecainsumo
			{
				IdManutencao = 1,
				IdPecaInsumo = 1001,
				IdMarcaPecaInsumo = 2001,
				Quantidade = 5.5f,
				MesesGarantia = 12,
				KmGarantia = 50000,
				ValorIndividual = 299.99m,
				Subtotal = 5.5m * 299.99m
			};
		}

		private static IEnumerable<Manutencaopecainsumo> GetTestManutencaoPecasInsumos()
		{
			return new List<Manutencaopecainsumo>
			{
				new Manutencaopecainsumo
				{
					IdManutencao = 1,
					IdPecaInsumo = 1001,
					IdMarcaPecaInsumo = 2001,
					Quantidade = 5.5f,
					MesesGarantia = 12,
					KmGarantia = 50000,
					ValorIndividual = 299.99m,
					Subtotal = 5.5m * 299.99m
				},
				new Manutencaopecainsumo
				{
					IdManutencao = 2,
					IdPecaInsumo = 1002,
					IdMarcaPecaInsumo = 2002,
					Quantidade = 3.0f,
					MesesGarantia = 24,
					KmGarantia = 100000,
					ValorIndividual = 499.99m,
					Subtotal = 3.0m * 499.99m
				},
				new Manutencaopecainsumo
				{
					IdManutencao = 3,
					IdPecaInsumo = 1003,
					IdMarcaPecaInsumo = 2003,
					Quantidade = 10.0f,
					MesesGarantia = 6,
					KmGarantia = 30000,
					ValorIndividual = 199.99m,
					Subtotal = 10.0m * 199.99m
				}
			};
		}
	}
}