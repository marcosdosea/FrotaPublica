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
    public class VeiculoControllerTests
    {
        private static VeiculoController? controller;

        [TestInitialize]
        public void Initialize()
        {
            // Arrange
            var mockVeiculoService = new Mock<IVeiculoService>();
            var mockUnidadeService = new Mock<IUnidadeAdministrativaService>();
            var mockFrotaService = new Mock<IFrotaService>();
            var mockModeloService = new Mock<IModeloVeiculoService>();

            IMapper mapper = new MapperConfiguration(cfg =>
                cfg.AddProfile(new VeiculoProfile())).CreateMapper();
            mockVeiculoService.Setup(service => service.GetAll(It.IsAny<uint>()))
                .Returns(GetTestVeiculos());
            mockVeiculoService.Setup(service => service.Get(1))
                .Returns(GetTargetVeiculo());
            mockVeiculoService.Setup(service => service.Edit(It.IsAny<Veiculo>()))
                .Verifiable();
            mockVeiculoService.Setup(service => service.Create(It.IsAny<Veiculo>()))
                .Verifiable();
            controller = new VeiculoController(mockVeiculoService.Object, mapper, mockUnidadeService.Object, mockFrotaService.Object, mockModeloService.Object);
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
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(List<VeiculoViewModel>));
            List<VeiculoViewModel>? lista = (List<VeiculoViewModel>)viewResult.ViewData.Model;
            Assert.IsTrue(lista.Count <= 15, "O número de itens na lista de veículos deve ser menor ou igual a 15.");
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
            Assert.AreEqual("JSD8135", veiculoViewModel.Placa);
            Assert.AreEqual("9BWZZZ377VT004251", veiculoViewModel.Chassi);
            Assert.AreEqual("Branco", veiculoViewModel.Cor);
            Assert.AreEqual((uint)2, veiculoViewModel.IdModeloVeiculo);
            Assert.AreEqual("76697382320", veiculoViewModel.Renavan);
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
            Assert.AreEqual("JSD8135", veiculoViewModel.Placa);
            Assert.AreEqual("9BWZZZ377VT004251", veiculoViewModel.Chassi);
            Assert.AreEqual("Branco", veiculoViewModel.Cor);
            Assert.AreEqual((uint)2, veiculoViewModel.IdModeloVeiculo);
            Assert.AreEqual("76697382320", veiculoViewModel.Renavan);
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
            Assert.AreEqual("JSD8135", veiculoViewModel.Placa);
            Assert.AreEqual("9BWZZZ377VT004251", veiculoViewModel.Chassi);
            Assert.AreEqual("Branco", veiculoViewModel.Cor);
            Assert.AreEqual((uint)2, veiculoViewModel.IdModeloVeiculo);
            Assert.AreEqual("76697382320", veiculoViewModel.Renavan);
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
                Placa = "JSD8135",
                Chassi = "9BWZZZ377VT004251",
                Cor = "Branco",
                IdModeloVeiculo = 2,
                IdFrota = 1,
                IdUnidadeAdministrativa = 3,
                Odometro = 12000,
                Status = "D",
                Ano = 2020,
                Modelo = 2021,
                Renavan = "76697382320",
                VencimentoIpva = DateTime.Parse("2024-03-15"),
                Valor = 45000.00m,
                DataReferenciaValor = DateTime.Parse("2023-11-01")
            };

        }

        private static Veiculo GetTargetVeiculo()
        {
            return new Veiculo
            {
                Id = 1,
                Placa = "JSD8135",
                Chassi = "9BWZZZ377VT004251",
                Cor = "Branco",
                IdModeloVeiculo = 2,
                IdFrota = 1,
                IdUnidadeAdministrativa = 3,
                Odometro = 12000,
                Status = "D",
                Ano = 2020,
                Modelo = 2021,
                Renavan = "76697382320",
                VencimentoIpva = DateTime.Parse("2024-03-15"),
                Valor = 45000.00m,
                DataReferenciaValor = DateTime.Parse("2023-11-01")
            };
        }

        private IEnumerable<Veiculo> GetTestVeiculos()
        {
            return new List<Veiculo>
            {
                new Veiculo
                {
                    Id = 1,
                    Placa = "JSD8135",
                    Chassi = "9BWZZZ377VT004251",
                    Cor = "Branco",
                    IdModeloVeiculo = 2,
                    IdFrota = 1,
                    IdUnidadeAdministrativa = 3,
                    Odometro = 12000,
                    Status = "D",
                    Ano = 2020,
                    Modelo = 2021,
                    Renavan = "76697382320",
                    VencimentoIpva = DateTime.Parse("2024-03-15"),
                    Valor = 45000.00m,
                    DataReferenciaValor = DateTime.Parse("2023-11-01")
                },
                new Veiculo
                {
                    Id = 2,
                    Placa = "MTM7627",
                    Chassi = "8AFZZZ407WT004352",
                    Cor = "Preto",
                    IdModeloVeiculo = 3,
                    IdFrota = 1,
                    IdUnidadeAdministrativa = 4,
                    Odometro = 25000,
                    Status = "M",
                    Ano = 2019,
                    Modelo = 2020,
                    Renavan = "20995281259",
                    VencimentoIpva = DateTime.Parse("2024-06-30"),
                    Valor = 35000.00m,
                    DataReferenciaValor = DateTime.Parse("2023-09-15")
                },
                new Veiculo
                {
                    Id = 3,
                    Placa = "HPQ8748",
                    Chassi = "7FBZZZ322VT009867",
                    Cor = "Prata",
                    IdModeloVeiculo = 1,
                    IdFrota = 2,
                    IdUnidadeAdministrativa = 5,
                    Odometro = 18000,
                    Status = "D",
                    Ano = 2021,
                    Modelo = 2022,
                    Renavan = "89592407448",
                    VencimentoIpva = DateTime.Parse("2024-12-10"),
                    Valor = 55000.00m,
                    DataReferenciaValor = DateTime.Parse("2023-10-10")
                }
            };
        }

    }
}