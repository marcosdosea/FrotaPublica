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
	public class MarcaPecaInsumoControllerTests
	{
		private static MarcaPecaInsumoController? controller;

		[TestInitialize]
		public void Initialize()
		{
			// Arrange
			var mockMarcaPecaInsumoService = new Mock<IMarcaPecaInsumoService>();

			IMapper mapper = new MapperConfiguration(cfg =>
				cfg.AddProfile(new MarcaPecaInsumoProfile())).CreateMapper();
			mockMarcaPecaInsumoService.Setup(service => service.GetAll())
				.Returns(GetTestMarcasPecasInsumos());
			mockMarcaPecaInsumoService.Setup(service => service.Get(1))
				.Returns(GetTargetMarcaPecaInsumo());
			mockMarcaPecaInsumoService.Setup(service => service.Edit(It.IsAny<Marcapecainsumo>()))
				.Verifiable();
			mockMarcaPecaInsumoService.Setup(service => service.Create(It.IsAny<Marcapecainsumo>()))
				.Verifiable();
			controller = new MarcaPecaInsumoController(mockMarcaPecaInsumoService.Object, mapper);
		}

		[TestMethod()]
		public void IndexTestValid()
		{
			// Act
			var result = controller!.Index();
			// Assert
			Assert.IsInstanceOfType(result, typeof(ViewResult));
			ViewResult viewResult = (ViewResult)result;
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(List<MarcaPecaInsumoViewModel>));
			List<MarcaPecaInsumoViewModel>? lista = (List<MarcaPecaInsumoViewModel>)viewResult.ViewData.Model;
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
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(MarcaPecaInsumoViewModel));
			MarcaPecaInsumoViewModel marcaPecaInsumoViewModel = (MarcaPecaInsumoViewModel)viewResult.ViewData.Model;
			Assert.AreEqual("Cofap", marcaPecaInsumoViewModel.Descricao);
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
			var result = controller!.Create(GetTargetMarcaPecaInsumoViewModel());
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
			var result = controller.Create(GetTargetMarcaPecaInsumoViewModel());
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
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(MarcaPecaInsumoViewModel));
			MarcaPecaInsumoViewModel marcaPecaInsumoViewModel = (MarcaPecaInsumoViewModel)viewResult.ViewData.Model;
			Assert.AreEqual("Cofap", marcaPecaInsumoViewModel.Descricao);
		}

		[TestMethod()]
		public void EditTestPostValid()
		{
			// Act
			var result = controller!.Edit(GetTargetMarcaPecaInsumoViewModel());
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
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(MarcaPecaInsumoViewModel));
			MarcaPecaInsumoViewModel marcaPecaInsumoViewModel = (MarcaPecaInsumoViewModel)viewResult.ViewData.Model;
			Assert.AreEqual("Cofap", marcaPecaInsumoViewModel.Descricao);
		}

		[TestMethod()]
		public void DeleteTestGetValid()
		{
			// Act
			var result = controller!.Delete(1, GetTargetMarcaPecaInsumoViewModel());
			// Assert
			Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
			RedirectToActionResult redirectToActionResult = (RedirectToActionResult)result;
			Assert.IsNull(redirectToActionResult.ControllerName);
			Assert.AreEqual("Index", redirectToActionResult.ActionName);
		}

		private MarcaPecaInsumoViewModel GetTargetMarcaPecaInsumoViewModel()
		{
			return new MarcaPecaInsumoViewModel
			{
				Id = 1,
				Descricao = "Cofap",
			};

		}

		private static Marcapecainsumo GetTargetMarcaPecaInsumo()
		{
			return new Marcapecainsumo
			{
				Id = 1,
				Descricao = "Cofap",
			};
		}

		private IEnumerable<Marcapecainsumo> GetTestMarcasPecasInsumos()
		{
			return new List<Marcapecainsumo>
			{
				new Marcapecainsumo
				{
					Id = 1,
					Descricao = "Cofap",
				},
				new Marcapecainsumo
				{
					Id = 2,
					Descricao = "Bosch",
				},
				new Marcapecainsumo
				{
					Id = 3,
					Descricao = "Metal Leve",
				}
			};
		}
	}
}