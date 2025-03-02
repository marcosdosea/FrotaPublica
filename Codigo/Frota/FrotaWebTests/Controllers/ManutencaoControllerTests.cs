using AutoMapper;
using FrotaWeb.Mappers;
using Moq;
using Core;
using Microsoft.AspNetCore.Mvc;
using FrotaWeb.Models;
using Service;
using Microsoft.AspNetCore.Http;
using System.Security.Claims;
using Microsoft.AspNetCore.Mvc.ViewFeatures;

namespace FrotaWeb.Controllers.Tests
{
    [TestClass()]
    public class ManutencaoControllerTests
    {
        private static ManutencaoController? controller;

        [TestInitialize]
        public void Initialize()
        {
            // Arrange
            var mockManutencaoService = new Mock<IManutencaoService>();
            IMapper mapper = new MapperConfiguration(cfg =>
                cfg.AddProfile(new ManutencaoProfile())).CreateMapper();

            mockManutencaoService.Setup(service => service.GetAll(It.IsAny<uint>())).Returns(GetTestManutencoes());
            mockManutencaoService.Setup(service => service.Get(1)).Returns(GetTestManutencao());
            mockManutencaoService.Setup(service => service.Create(It.IsAny<Manutencao>())).Verifiable();
            mockManutencaoService.Setup(service => service.Edit(It.IsAny<Manutencao>())).Verifiable();
            mockManutencaoService.Setup(service => service.Delete(1)).Verifiable();
            controller = new ManutencaoController(mockManutencaoService.Object, mapper);
            var httpContextAccessor = new HttpContextAccessor
            {
                HttpContext = new DefaultHttpContext()
            };
            httpContextAccessor.HttpContext.User = new ClaimsPrincipal(
                new ClaimsIdentity(
                    [
                        new Claim("FrotaId", "1")
                    ],
                    "TesteAutenticacao"
                )
            );
            controller.ControllerContext = new ControllerContext
            {
                HttpContext = httpContextAccessor.HttpContext
            };
            controller.TempData = new TempDataDictionary(httpContextAccessor.HttpContext, Mock.Of<ITempDataProvider>());
        }

        [TestMethod()]
        public void IndexTestValid()
        {
            // Act
            var result = controller!.Index();
            // Assert
            Assert.IsInstanceOfType(result, typeof(ViewResult));
            ViewResult viewResult = (ViewResult)result;
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(List<ManutencaoViewModel>));
            List<ManutencaoViewModel>? manutencao = (List<ManutencaoViewModel>)viewResult.ViewData.Model;
            Assert.AreEqual(3, manutencao.Count);
        }

        [TestMethod()]
        public void DetailsTestValid()
        {
            // Act
            var result = controller!.Details(1);
            // Assert
            Assert.IsInstanceOfType(result, typeof(ViewResult));
            ViewResult viewResult = (ViewResult)result;
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(ManutencaoViewModel));
            ManutencaoViewModel manutencaoViewModel = (ManutencaoViewModel)viewResult.ViewData.Model;
            Assert.AreEqual((uint)1001, manutencaoViewModel.IdVeiculo);
            Assert.AreEqual((uint)2001, manutencaoViewModel.IdFornecedor);
            Assert.AreEqual(DateTime.Now.Date, manutencaoViewModel.DataHora.Date);
            Assert.AreEqual((uint)3001, manutencaoViewModel.IdResponsavel);
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
            var result = controller!.Create(GetTargetManutencaoViewModel());
            // Assert
            Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
            RedirectToActionResult redirectResult = (RedirectToActionResult)result;
            Assert.IsNull(redirectResult.ControllerName);
            Assert.AreEqual("Index", redirectResult.ActionName);
        }

        [TestMethod()]
        public void CreatePostInvalid()
        {
            // Arrange
            controller!.ModelState.AddModelError("error", "some error");
            // Act
            var result = controller.Create(GetTargetManutencaoViewModel());
            // Assert
            Assert.AreEqual(1, controller.ModelState.ErrorCount);
            Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
            RedirectToActionResult redirectToActionResult = (RedirectToActionResult)result;
            Assert.IsNull(redirectToActionResult.ControllerName);
            Assert.AreEqual("Index", redirectToActionResult.ActionName);
        }

        [TestMethod()]
        public void EditTest()
        {
            // Act
            var result = controller!.Edit(1);
            // Assert
            Assert.IsInstanceOfType(result, typeof(ViewResult));
            ViewResult viewResult = (ViewResult)result;
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(ManutencaoViewModel));
            ManutencaoViewModel manutencaoViewModel = (ManutencaoViewModel)viewResult.ViewData.Model;
            Assert.AreEqual((uint)1001, manutencaoViewModel.IdVeiculo);
            Assert.AreEqual((uint)2001, manutencaoViewModel.IdFornecedor);
            Assert.AreEqual(DateTime.Now.Date, manutencaoViewModel.DataHora.Date);
            Assert.AreEqual((uint)3001, manutencaoViewModel.IdResponsavel);
        }

        [TestMethod()]
        public void EditTestPostValid()
        {
            // Act
            var result = controller?.Edit(GetTargetManutencaoViewModel().Id, GetTargetManutencaoViewModel());
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
            Assert.IsInstanceOfType(viewResult.Model, typeof(ManutencaoViewModel));
            ManutencaoViewModel manutencaoViewModel = (ManutencaoViewModel)viewResult.Model;
            Assert.AreEqual((uint)1001, manutencaoViewModel.IdVeiculo);
            Assert.AreEqual((uint)2001, manutencaoViewModel.IdFornecedor);
            Assert.AreEqual(DateTime.Now.Date, manutencaoViewModel.DataHora.Date);
            Assert.AreEqual((uint)3001, manutencaoViewModel.IdResponsavel);
        }

        [TestMethod()]
        public void DeleteTestGetValid()
        {
            // Act
            var result = controller!.Delete(1, GetTargetManutencaoViewModel());
            // Assert
            Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
            RedirectToActionResult redirectToActionResult = (RedirectToActionResult)result;
            Assert.IsNull(redirectToActionResult.ControllerName);
            Assert.AreEqual("Index", redirectToActionResult.ActionName);
        }
        private ManutencaoViewModel GetTargetManutencaoViewModel()
        {
            return new ManutencaoViewModel
            {
                Id = 1,
                IdVeiculo = 1001,
                IdFornecedor = 2001,
                DataHora = DateTime.Now,
                IdResponsavel = 3001,
                ValorPecas = "1500.50",
                ValorManutencao = "500.75",
                Tipo = "P",
                Comprovante = null,
                Status = "F",
                IdFrota = 1
            };
        }

        private Manutencao GetTestManutencao()
        {
            return new Manutencao
            {
                Id = 1,
                IdVeiculo = 1001,
                IdFornecedor = 2001,
                DataHora = DateTime.Now,
                IdResponsavel = 3001,
                ValorPecas = 1500.50m,
                ValorManutencao = 500.75m,
                Tipo = "P",
                Comprovante = null,
                Status = "F",
                IdFrota = 1
            };
        }

        private IEnumerable<Manutencao> GetTestManutencoes()
        {
            return new List<Manutencao>
            {
                new Manutencao
                {
                    Id = 1,
                    IdVeiculo = 1001,
                    IdFornecedor = 2001,
                    DataHora = DateTime.Now,
                    IdResponsavel = 3001,
                    ValorPecas = 1500.50m,
                    ValorManutencao = 500.75m,
                    Tipo = "P",
                    Comprovante = null,
                    Status = "F",
                    IdFrota = 1
                },
                new Manutencao
                {
                    Id = 2,
                    IdVeiculo = 1002,
                    IdFornecedor = 2002,
                    DataHora = DateTime.Now.AddDays(-7),
                    IdResponsavel = 3002,
                    ValorPecas = 200.00m,
                    ValorManutencao = 150.25m,
                    Tipo = "C",
                    Comprovante = null,
                    Status = "O",
                    IdFrota = 1
                },
                new Manutencao
                {
                    Id = 3,
                    IdVeiculo = 1003,
                    IdFornecedor = 2003,
                    DataHora = DateTime.Now.AddMonths(-1),
                    IdResponsavel = 3003,
                    ValorPecas = 750.00m,
                    ValorManutencao = 250.00m,
                    Tipo = "P",
                    Comprovante = null,
                    Status = "E",
                    IdFrota = 2
                }
            };
        }
    }
}