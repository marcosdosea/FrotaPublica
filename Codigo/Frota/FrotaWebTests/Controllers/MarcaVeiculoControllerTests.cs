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
	public class MarcaVeiculoControllerTests
	{
		private static MarcaVeiculoController? controller;

		[TestInitialize]
		public void Initialize()
		{
			// Arrange
			var mockMarcaVeiculoService = new Mock<IMarcaVeiculoService>();

			IMapper mapper = new MapperConfiguration(cfg =>
				cfg.AddProfile(new MarcaVeiculoProfile())).CreateMapper();
			mockMarcaVeiculoService.Setup(service => service.GetAll())
				.Returns(GetTestMarcasVeiculos());
			mockMarcaVeiculoService.Setup(service => service.Get(1))
				.Returns(GetTargetMarcaVeiculo());
			mockMarcaVeiculoService.Setup(service => service.Edit(It.IsAny<Marcaveiculo>()))
				.Verifiable();
			mockMarcaVeiculoService.Setup(service => service.Create(It.IsAny<Marcaveiculo>()))
				.Verifiable();
			controller = new MarcaVeiculoController(mockMarcaVeiculoService.Object, mapper);
		}

		[TestMethod()]
		public void IndexTestValid()
		{
			// Act
			var result = controller!.Index();
			// Assert
			Assert.IsInstanceOfType(result, typeof(ViewResult));
			ViewResult viewResult = (ViewResult)result;
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(List<MarcaVeiculoViewModel>));
			List<MarcaVeiculoViewModel>? lista = (List<MarcaVeiculoViewModel>)viewResult.ViewData.Model;
			Assert.AreEqual(4, lista.Count);
		}

		[TestMethod()]
		public void DetailsTestValid()
		{
			// Act
			var result = controller!.Details(1);
			// Assert
			Assert.IsInstanceOfType(result, typeof(ViewResult));
			ViewResult viewResult = (ViewResult)result;
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(MarcaVeiculoViewModel));
			MarcaVeiculoViewModel marcaVeiculoViewModel = (MarcaVeiculoViewModel)viewResult.ViewData.Model;
			Assert.AreEqual("Fiat", marcaVeiculoViewModel.Nome);
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
			var result = controller!.Create(GetTargetMarcaVeiculoViewModel());
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
			controller!.ModelState.AddModelError("Nome", "Campo requerido");
			// Act
			var result = controller.Create(GetTargetMarcaVeiculoViewModel());
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
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(MarcaVeiculoViewModel));
			MarcaVeiculoViewModel marcaVeiculoViewModel = (MarcaVeiculoViewModel)viewResult.ViewData.Model;
			Assert.AreEqual("Fiat", marcaVeiculoViewModel.Nome);
		}

		[TestMethod()]
		public void EditTestPostValid()
		{
			// Act
			var result = controller!.Edit((uint)GetTargetMarcaVeiculoViewModel().Id, GetTargetMarcaVeiculoViewModel());
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
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(MarcaVeiculoViewModel));
			MarcaVeiculoViewModel marcaVeiculoViewModel = (MarcaVeiculoViewModel)viewResult.ViewData.Model;
			Assert.AreEqual("Fiat", marcaVeiculoViewModel.Nome);
		}

		[TestMethod()]
		public void DeleteTestGetValid()
		{
			// Act
			var result = controller!.Delete(1, GetTargetMarcaVeiculoViewModel());
			// Assert
			Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
			RedirectToActionResult redirectToActionResult = (RedirectToActionResult)result;
			Assert.IsNull(redirectToActionResult.ControllerName);
			Assert.AreEqual("Index", redirectToActionResult.ActionName);
		}

		private static MarcaVeiculoViewModel GetTargetMarcaVeiculoViewModel()
		{
			return new MarcaVeiculoViewModel
			{
				Id = 1,
				Nome = "Fiat",
			};
		}

		private static Marcaveiculo GetTargetMarcaVeiculo()
		{
			return new Marcaveiculo
			{
				Id = 1,
				Nome = "Fiat",
			};
		}

		private static IEnumerable<Marcaveiculo> GetTestMarcasVeiculos()
		{
			return new List<Marcaveiculo>
			{
				new Marcaveiculo
				{
					Id = 1,
					Nome = "Fiat",
				},
				new Marcaveiculo
				{
					Id = 2,
					Nome = "Volkswagen",
				},
				new Marcaveiculo
				{
					Id = 3,
					Nome = "Chevrolet",
				},
				new Marcaveiculo
				{
					Id = 4,
					Nome = "Toyota",
				}
			};
		}
	}
}