using AutoMapper;
using FrotaWeb.Mappers;
using Core.Service;
using Moq;
using Core;
using Microsoft.AspNetCore.Mvc;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Http;
using System.Security.Claims;


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
            mockAbastecimentoService.Setup(service => service.GetAll(1))
                .Returns(GetTestAbastecimentos());
            mockAbastecimentoService.Setup(service => service.Get(1))
                .Returns(GetTargetAbastecimento());
            mockAbastecimentoService.Setup(service => service.Edit(It.IsAny<Abastecimento>(), 1))
                .Verifiable();
            mockAbastecimentoService.Setup(service => service.Create(It.IsAny<Abastecimento>(), 1))
                .Verifiable();
            controller = new AbastecimentoController(mockAbastecimentoService.Object, mapper);
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
            Assert.IsTrue(lista.Count <= 15, "O número de itens na lista de abastecimentos deve ser menor ou igual a 15.");
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
            Assert.AreEqual(DateTime.Parse("2021-06-11 14:30:00"), abastecimentoViewModel.DataHora);
            Assert.AreEqual(15000, abastecimentoViewModel.Odometro);
            Assert.AreEqual(80, abastecimentoViewModel.Litros);
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
            Assert.AreEqual(DateTime.Parse("2021-06-11 14:30:00"), abastecimentoViewModel.DataHora);
            Assert.AreEqual(15000, abastecimentoViewModel.Odometro);
            Assert.AreEqual(80, abastecimentoViewModel.Litros);
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
            Assert.AreEqual(DateTime.Parse("2021-06-11 14:30:00"), abastecimentoViewModel.DataHora);
            Assert.AreEqual(15000, abastecimentoViewModel.Odometro);
            Assert.AreEqual(80, abastecimentoViewModel.Litros);
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
                IdFornecedor = 1,
                IdVeiculo = 1,
                IdFrota = 1,
                IdPessoa = 2,
                DataHora = DateTime.Parse("2021-06-11 14:30:00"),
                Odometro = 15000,
                Litros = 80
            };
        }

        private static Abastecimento GetTargetAbastecimento()
        {
            return new Abastecimento
            {
                Id = 1,
                IdFornecedor = 1,
                IdVeiculo = 1,
                IdFrota = 1,
                IdPessoa = 2,
                DataHora = DateTime.Parse("2021-06-11 14:30:00"),
                Odometro = 15000,
                Litros = 80
            };
        }

        private static IEnumerable<Abastecimento> GetTestAbastecimentos()
        {
            return new List<Abastecimento>
            {
                new Abastecimento
                {
                    Id = 1,
                    IdFornecedor = 1,
                    IdVeiculo = 1,
                    IdFrota = 1,
                    IdPessoa = 2,
                    DataHora = DateTime.Parse("2021-06-11 14:30:00"),
                    Odometro=15000,
                    Litros=80,
                },
                new Abastecimento
                {
                    Id = 2,
                    IdFornecedor = 2,
                    IdVeiculo = 4,
                    IdFrota = 15,
                    IdPessoa = 46,
                    DataHora = DateTime.Parse("2021-06-15 19:45:28"),
                    Odometro=20000,
                    Litros=60,
                },
                new Abastecimento
                {
                    Id = 3,
                    IdFornecedor = 12,
                    IdVeiculo = 3,
                    IdFrota = 15,
                    IdPessoa = 31,
                    DataHora = DateTime.Parse("2021-06-20 10:00:45"),
                    Odometro=15000,
                    Litros=70,
                }
            };
        }
    }
}