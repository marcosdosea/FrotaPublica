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
	public class VistoriaControllerTests
	{
		private static VistoriaController? controller;

		[TestInitialize]
		public void Initialize()
		{
			// Arrange
			var mockVistoriaService = new Mock<IVistoriaService>();

			IMapper mapper = new MapperConfiguration(cfg =>
				cfg.AddProfile(new VistoriaProfile())).CreateMapper();
			mockVistoriaService.Setup(service => service.GetAll())
				.Returns(GetTestVistorias());
			mockVistoriaService.Setup(service => service.Get(1))
				.Returns(GetTargetVistoria());
			mockVistoriaService.Setup(service => service.Edit(It.IsAny<Vistorium>()))
				.Verifiable();
			mockVistoriaService.Setup(service => service.Create(It.IsAny<Vistorium>()))
				.Verifiable();
			controller = new VistoriaController(mockVistoriaService.Object, mapper);
		}

		[TestMethod()]
		public void IndexTestValid()
		{
			// Act
			var result = controller!.Index();
			// Assert
			Assert.IsInstanceOfType(result, typeof(ViewResult));
			ViewResult viewResult = (ViewResult)result;
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(List<VistoriaViewModel>));
			List<VistoriaViewModel>? lista = (List<VistoriaViewModel>)viewResult.ViewData.Model;
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
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(VistoriaViewModel));
			VistoriaViewModel vistoriaViewModel = (VistoriaViewModel)viewResult.ViewData.Model;
			Assert.AreEqual(DateTime.Parse("2024-11-01"), vistoriaViewModel.Data);
			Assert.AreEqual("S", vistoriaViewModel.Tipo);
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
			var result = controller!.Create(GetTargetVistoriaViewModel());
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
			controller!.ModelState.AddModelError("Data", "Campo requerido");
			// Act
			var result = controller.Create(GetTargetVistoriaViewModel());
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
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(VistoriaViewModel));
			VistoriaViewModel vistoriaViewModel = (VistoriaViewModel)viewResult.ViewData.Model;
			Assert.AreEqual(DateTime.Parse("2024-11-01"), vistoriaViewModel.Data);
			Assert.AreEqual("S", vistoriaViewModel.Tipo);
		}

		[TestMethod()]
		public void EditTestPostValid()
		{
			// Act
			var result = controller!.Edit((uint)GetTargetVistoriaViewModel().Id, GetTargetVistoriaViewModel());
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
			Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(VistoriaViewModel));
			VistoriaViewModel vistoriaViewModel = (VistoriaViewModel)viewResult.ViewData.Model;
			Assert.AreEqual(DateTime.Parse("2024-11-01"), vistoriaViewModel.Data);
			Assert.AreEqual("S", vistoriaViewModel.Tipo);
		}

		[TestMethod()]
		public void DeleteTestGetValid()
		{
			// Act
			var result = controller!.Delete(1, GetTargetVistoriaViewModel());
			// Assert
			Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
			RedirectToActionResult redirectToActionResult = (RedirectToActionResult)result;
			Assert.IsNull(redirectToActionResult.ControllerName);
			Assert.AreEqual("Index", redirectToActionResult.ActionName);
		}

		private static VistoriaViewModel GetTargetVistoriaViewModel()
		{
			return new VistoriaViewModel
			{
				Id = 1,
				Data = DateTime.Parse("2024-11-01"),
				Problemas = "Pneus desgastados e necessidade de troca de óleo",
				Tipo = "S",
				IdPessoaResponsavel = 1
			};
		}

		private static Vistorium GetTargetVistoria()
		{
			return new Vistorium
			{
				Id = 1,
				Data = DateTime.Parse("2024-11-01"),
				Problemas = "Pneus desgastados e necessidade de troca de óleo",
				Tipo = "S",
				IdPessoaResponsavel = 1
			};
		}

		private static IEnumerable<Vistorium> GetTestVistorias()
		{
			return new List<Vistorium>
			{
				new Vistorium
				{
					Id = 1,
					Data = DateTime.Parse("2024-11-01"),
					Problemas = "Pneus desgastados e necessidade de troca de óleo",
					Tipo = "S",
					IdPessoaResponsavel = 1
				},
				new Vistorium
				{
					Id = 2,
					Data = DateTime.Parse("2024-12-01"),
					Problemas = "Faróis com baixa intensidade",
					Tipo = "S",
					IdPessoaResponsavel = 1
				},
				new Vistorium
				{
					Id = 3,
					Data = DateTime.Parse("2024-12-15"),
					Problemas = "Vazamento de óleo no motor",
					Tipo = "R",
					IdPessoaResponsavel = 1
				}
			};
		}
	}
}