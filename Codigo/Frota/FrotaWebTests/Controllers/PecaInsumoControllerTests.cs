﻿using AutoMapper;
using Core.Service;
using Core;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Mvc;
using Moq;
using FrotaWeb.Mappers;

namespace FrotaWeb.Controllers.Tests
{
	[TestClass()]
	public class PecaInsumoControllerTests
	{
		private static PecaInsumoController? controller;

		[TestInitialize]
		public void Initialize()
		{
			// Arrange
			var mockPecaInsumoService = new Mock<IPecaInsumoService>();

			IMapper mapper = new MapperConfiguration(cfg =>
				cfg.AddProfile(new PecaInsumoProfile())).CreateMapper();
			mockPecaInsumoService.Setup(service => service.GetAll())
				.Returns(GetTestPecasInsumos());
			mockPecaInsumoService.Setup(service => service.Get(1))
				.Returns(GetTestPecaInsumo());
			mockPecaInsumoService.Setup(service => service.Edit(It.IsAny<Pecainsumo>()))
				.Verifiable();
			mockPecaInsumoService.Setup(service => service.Create(It.IsAny<Pecainsumo>()))
				.Verifiable();
			controller = new PecaInsumoController(mockPecaInsumoService.Object, mapper);
		}

		[TestMethod()]
		public void IndexTestValid()
		{
			// Act
			var result = controller!.Index();
			// Assert
			Assert.IsInstanceOfType(result, typeof(ViewResult));
			ViewResult viewResult = (ViewResult)result;
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(List<PecaInsumoViewModel>));
			List<PecaInsumoViewModel>? lista = (List<PecaInsumoViewModel>)viewResult.ViewData.Model;
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
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(PecaInsumoViewModel));
			PecaInsumoViewModel pecaInsumoViewModel = (PecaInsumoViewModel)viewResult.ViewData.Model;
			Assert.AreEqual("Pastilha desgastada", pecaInsumoViewModel.Descricao);
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
			var result = controller!.Create(GetTestPecaInsumoViewModel());
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
			controller!.ModelState.AddModelError("Descricao", "Campo requerido");
			// Act
			var result = controller.Create(GetTestPecaInsumoViewModel());
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
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(PecaInsumoViewModel));
			PecaInsumoViewModel pecaInsumoViewModel = (PecaInsumoViewModel)viewResult.ViewData.Model;
			Assert.AreEqual("Pastilha desgastada", pecaInsumoViewModel.Descricao);
		}

		[TestMethod()]
		public void EditTestPostValid()
		{
			// Act
			var result = controller!.Edit((uint)GetTestPecaInsumoViewModel().Id, GetTestPecaInsumoViewModel());
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
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(PecaInsumoViewModel));
			PecaInsumoViewModel pecaInsumoViewModel = (PecaInsumoViewModel)viewResult.ViewData.Model;
			Assert.AreEqual("Pastilha desgastada", pecaInsumoViewModel.Descricao);
		}

		[TestMethod()]
		public void DeleteTestGetValid()
		{
			// Act
			var result = controller!.Delete(1, GetTestPecaInsumoViewModel());
			// Assert
			Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
			RedirectToActionResult redirectToActionResult = (RedirectToActionResult)result;
			Assert.IsNull(redirectToActionResult.ControllerName);
			Assert.AreEqual("Index", redirectToActionResult.ActionName);
		}

		private static PecaInsumoViewModel GetTestPecaInsumoViewModel()
		{
			return new PecaInsumoViewModel
			{
				Id = 1,
				Descricao = "Pastilha desgastada"
			};
		}

		private static Pecainsumo GetTestPecaInsumo()
		{
			return new Pecainsumo
			{
				Id = 1,
				Descricao = "Pastilha desgastada"
			};
		}

		private static IEnumerable<Pecainsumo> GetTestPecasInsumos()
		{
			return new List<Pecainsumo>
			{
				new Pecainsumo
				{
					Id = 1,
					Descricao = "Pastilha desgastada"
				},
				new Pecainsumo
				{
					Id = 2,
					Descricao = "Pneu careca"
				},
				new Pecainsumo
				{
					Id = 3,
					Descricao = "Filtro de ar sujo"
				}
			};
		}
	}
}