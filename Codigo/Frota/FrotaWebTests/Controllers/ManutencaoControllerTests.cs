using AutoMapper;
using FrotaWeb.Mappers;
using Core.Service;
using Moq;
using Core;
using Microsoft.AspNetCore.Mvc;
using FrotaWeb.Models;
using Service;

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

            mockManutencaoService.Setup(service => service.GetAll()).Returns(GetTestManutencoes());
            mockManutencaoService.Setup(service => service.Get(1)).Returns(GetTestManutencao());
            mockManutencaoService.Setup(service => service.Create(It.IsAny<Manutencao>())).Verifiable();
            mockManutencaoService.Setup(service => service.Edit(It.IsAny<Manutencao>())).Verifiable();
            mockManutencaoService.Setup(service => service.Delete(1)).Verifiable();
            controller = new ManutencaoController(mockManutencaoService.Object, mapper);
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
            Assert.AreEqual(1001m, manutencaoViewModel.IdVeiculo);
            Assert.AreEqual(2001m, manutencaoViewModel.IdFornecedor);
            Assert.AreEqual(DateTime.Parse("2024-11-01"), manutencaoViewModel.DataHora);
            Assert.AreEqual(3001m, manutencaoViewModel.IdResponsavel);
            Assert.AreEqual(1500.50m, manutencaoViewModel.ValorPecas);
            Assert.AreEqual(500.75m, manutencaoViewModel.ValorManutencao);
            Assert.AreEqual("Preventiva", manutencaoViewModel.Tipo);
            Assert.IsTrue(manutencaoViewModel.Comprovante == null || manutencaoViewModel.Comprovante.Length == 0);
            Assert.AreEqual("Concluído", manutencaoViewModel.Status);
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
            Assert.AreEqual(1001m, manutencaoViewModel.IdVeiculo);
            Assert.AreEqual(2001m, manutencaoViewModel.IdFornecedor);
            Assert.AreEqual(DateTime.Parse("2024-11-01"), manutencaoViewModel.DataHora);
            Assert.AreEqual(3001m, manutencaoViewModel.IdResponsavel);
            Assert.AreEqual(1500.50m, manutencaoViewModel.ValorPecas);
            Assert.AreEqual(500.75m, manutencaoViewModel.ValorManutencao);
            Assert.AreEqual("Preventiva", manutencaoViewModel.Tipo);
            Assert.IsTrue(manutencaoViewModel.Comprovante == null || manutencaoViewModel.Comprovante.Length == 0);
            Assert.AreEqual("Concluído", manutencaoViewModel.Status);
        }

        [TestMethod()]
        public void EditTestPostValid()
        {
            // Act
            var result = controller.Edit(GetTargetManutencaoViewModel().Id, GetTargetManutencaoViewModel());
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
            Assert.AreEqual(1001m, manutencaoViewModel.IdVeiculo);
            Assert.AreEqual(2001m, manutencaoViewModel.IdFornecedor);
            Assert.AreEqual(DateTime.Parse("2024-11-01"), manutencaoViewModel.DataHora);
            Assert.AreEqual(3001m, manutencaoViewModel.IdResponsavel);
            Assert.AreEqual(1500.50m, manutencaoViewModel.ValorPecas);
            Assert.AreEqual(500.75m, manutencaoViewModel.ValorManutencao);
            Assert.AreEqual("Preventiva", manutencaoViewModel.Tipo);
            Assert.IsTrue(manutencaoViewModel.Comprovante == null || manutencaoViewModel.Comprovante.Length == 0);
            Assert.AreEqual("Concluído", manutencaoViewModel.Status);
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
                DataHora = DateTime.Parse("2024-11-01"),
                IdResponsavel = 3001,
                ValorPecas = 1500.50m,
                ValorManutencao = 500.75m,
                Tipo = "Preventiva",
                Comprovante = null,
                Status = "Concluído"
            };
        }

        private Manutencao GetTestManutencao()
        {
            return new Manutencao
            {
                Id = 1,
                IdVeiculo = 1001,
                IdFornecedor = 2001,
                DataHora = DateTime.Parse("2024-11-01"),
                IdResponsavel = 3001,
                ValorPecas = 1500.50m,
                ValorManutencao = 500.75m,
                Tipo = "Preventiva",
                Comprovante = null,
                Status = "Concluído"
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
                    DataHora = DateTime.Parse("2024-11-01"),
                    IdResponsavel = 3001,
                    ValorPecas = 1500.50m,
                    ValorManutencao = 500.75m,
                    Tipo = "Preventiva",
                    Comprovante = null,
                    Status = "Concluído"
                },
                new Manutencao
                {
                    Id = 2,
                    IdVeiculo = 1002,
                    IdFornecedor = 2002,
                    DataHora = DateTime.Parse("2024-12-01"),
                    IdResponsavel = 3002,
                    ValorPecas = 200.00m,
                    ValorManutencao = 150.25m,
                    Tipo = "Corretiva",
                    Comprovante = null,
                    Status = "Pendente"
                },
                new Manutencao
                {
                    Id = 3,
                    IdVeiculo = 1003,
                    IdFornecedor = 2003,
                    DataHora = DateTime.Parse("2024-03-01"),
                    IdResponsavel = 3003,
                    ValorPecas = 750.00m,
                    ValorManutencao = 250.00m,
                    Tipo = "Preventiva",
                    Comprovante = null,
                    Status = "Em Andamento"
                }
            };
        }
    }
}