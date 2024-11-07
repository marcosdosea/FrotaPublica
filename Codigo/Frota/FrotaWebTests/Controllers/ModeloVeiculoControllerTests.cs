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
	public class ModeloVeiculoControllerTests
	{
		private static ModeloVeiculoController? controller;

		[TestInitialize]
		public void Initialize()
		{
			// Arrange
			var mockModeloVeiculoService = new Mock<IModeloVeiculoService>();

			IMapper mapper = new MapperConfiguration(cfg =>
				cfg.AddProfile(new ModeloVeiculoProfile())).CreateMapper();
			mockModeloVeiculoService.Setup(service => service.GetAll())
				.Returns(GetTestModelosVeiculos());
			mockModeloVeiculoService.Setup(service => service.Get(1))
				.Returns(GetTargetModeloVeiculo());
			mockModeloVeiculoService.Setup(service => service.Edit(It.IsAny<Modeloveiculo>()))
				.Verifiable();
			mockModeloVeiculoService.Setup(service => service.Create(It.IsAny<Modeloveiculo>()))
				.Verifiable();
			controller = new ModeloVeiculoController(mockModeloVeiculoService.Object, mapper);
		}

		[TestMethod()]
		public void IndexTestValid()
		{
			// Act
			var result = controller!.Index();
			// Assert
			Assert.IsInstanceOfType(result, typeof(ViewResult));
			ViewResult viewResult = (ViewResult)result;
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(List<ModeloVeiculoViewModel>));
			List<ModeloVeiculoViewModel>? lista = (List<ModeloVeiculoViewModel>)viewResult.ViewData.Model;
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
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(ModeloVeiculoViewModel));
			ModeloVeiculoViewModel modeloVeiculoViewModel = (ModeloVeiculoViewModel)viewResult.ViewData.Model;
			Assert.AreEqual("Fiat Toro", modeloVeiculoViewModel.Nome);
			Assert.AreEqual(80, modeloVeiculoViewModel.CapacidadeTanque);
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
			var result = controller!.Create(GetTargetModeloVeiculoViewModel());
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
			var result = controller.Create(GetTargetModeloVeiculoViewModel());
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
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(ModeloVeiculoViewModel));
			ModeloVeiculoViewModel modeloVeiculoViewModel = (ModeloVeiculoViewModel)viewResult.ViewData.Model;
			Assert.AreEqual("Fiat Toro", modeloVeiculoViewModel.Nome);
			Assert.AreEqual(80, modeloVeiculoViewModel.CapacidadeTanque);
		}

		[TestMethod()]
		public void EditTestPostValid()
		{
			// Act
			var result = controller!.Edit(GetTargetModeloVeiculoViewModel());
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
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(ModeloVeiculoViewModel));
			ModeloVeiculoViewModel modeloVeiculoViewModel = (ModeloVeiculoViewModel)viewResult.ViewData.Model;
			Assert.AreEqual("Fiat Toro", modeloVeiculoViewModel.Nome);
			Assert.AreEqual(80, modeloVeiculoViewModel.CapacidadeTanque);
		}

		[TestMethod()]
		public void DeleteTestGetValid()
		{
			// Act
			var result = controller!.Delete(GetTargetModeloVeiculoViewModel(), (uint)GetTargetModeloVeiculoViewModel().Id);
			// Assert
			Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
			RedirectToActionResult redirectToActionResult = (RedirectToActionResult)result;
			Assert.IsNull(redirectToActionResult.ControllerName);
			Assert.AreEqual("Index", redirectToActionResult.ActionName);
		}

		private static ModeloVeiculoViewModel GetTargetModeloVeiculoViewModel()
		{
			return new ModeloVeiculoViewModel
			{
				Id = 1,
				IdMarcaVeiculo = 1,
				Nome = "Fiat Toro",
				CapacidadeTanque = 1,
			};
		}

		private static Modeloveiculo GetTargetModeloVeiculo()
		{
			return new Modeloveiculo
			{
				Id = 1,
				IdMarcaVeiculo = 1,
				Nome = "Fiat Toro",
				CapacidadeTanque = 80
			};
		}

		private static IEnumerable<Modeloveiculo> GetTestModelosVeiculos()
		{
			return new List<Modeloveiculo>
			{
				new Modeloveiculo
				{
					Id = 1,
					IdMarcaVeiculo = 1,
					Nome = "Fiat Toro",
					CapacidadeTanque = 80
				},
				new Modeloveiculo
				{
					Id = 2,
					IdMarcaVeiculo = 1,
					Nome = "Volkswagen Gol",
					CapacidadeTanque = 70
				},
				new Modeloveiculo
				{
					Id = 3,
					IdMarcaVeiculo = 2,
					Nome = "Chevrolet Onix",
					CapacidadeTanque = 60
				}
			};
		}
	}
}
