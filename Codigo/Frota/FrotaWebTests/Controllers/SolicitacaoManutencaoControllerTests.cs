using System.Security.Claims;
using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Mappers;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Moq;

namespace FrotaWeb.Controllers.Tests
{
    [TestClass()]
    public class SolicitacaoManutencaoControllerTests
    {
        private static SolicitacaoManutencaoController? controller;

        [TestInitialize]
        public void Initialize()
        {
            // Arrange
            var mockSolicitacaoService = new Mock<ISolicitacaoManutencaoService>();

            IMapper mapper = new MapperConfiguration(cfg =>
                cfg.AddProfile(new SolicitacaoManutencaoProfile())).CreateMapper();
            mockSolicitacaoService.Setup(service => service.GetAll(It.IsAny<int>()))
                .Returns(GetTargetSolicitacaoManutencoes());
            mockSolicitacaoService.Setup(service => service.Get(1))
                .Returns(GetTargetSolicitacaoManutencao());
            mockSolicitacaoService.Setup(service => service.Edit(It.IsAny<Solicitacaomanutencao>(), It.IsAny<int>()))
                .Verifiable();
            mockSolicitacaoService.Setup(service => service.Create(It.IsAny<Solicitacaomanutencao>(), It.IsAny<int>()))
                .Verifiable();
            controller = new SolicitacaoManutencaoController(mockSolicitacaoService.Object, mapper);
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
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(List<SolicitacaoManutencaoViewModel>));
            List<SolicitacaoManutencaoViewModel>? lista = (List<SolicitacaoManutencaoViewModel>)viewResult.ViewData.Model;
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
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(SolicitacaoManutencaoViewModel));
            SolicitacaoManutencaoViewModel solicitacaoManutencaoViewModel = (SolicitacaoManutencaoViewModel)viewResult.ViewData.Model;
            Assert.AreEqual(DateTime.Parse("2023-11-01"), solicitacaoManutencaoViewModel.DataSolicitacao);
            Assert.AreEqual("Troca de pneus", solicitacaoManutencaoViewModel.DescricaoProblema);

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
            var result = controller!.Create(GetTargetSolicitacaoViewModel());
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
            controller!.ModelState.AddModelError("DataSolicitacao", "Campo requerido");
            // Act
            var result = controller.Create(GetTargetSolicitacaoViewModel());
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
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(SolicitacaoManutencaoViewModel));
            SolicitacaoManutencaoViewModel solicitacaoViewModel = (SolicitacaoManutencaoViewModel)viewResult.ViewData.Model;
            Assert.AreEqual(DateTime.Parse("2023-11-01"), solicitacaoViewModel.DataSolicitacao);
            Assert.AreEqual("Troca de pneus", solicitacaoViewModel.DescricaoProblema);
        }

        [TestMethod()]
        public void EditTestPostValid()
        {
            // Act
            var result = controller!.Edit(GetTargetSolicitacaoViewModel().Id, GetTargetSolicitacaoViewModel());
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
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(SolicitacaoManutencaoViewModel));
            SolicitacaoManutencaoViewModel solicitacaoViewModel = (SolicitacaoManutencaoViewModel)viewResult.ViewData.Model;
            Assert.AreEqual(DateTime.Parse("2023-11-01"), solicitacaoViewModel.DataSolicitacao);
            Assert.AreEqual("Troca de pneus", solicitacaoViewModel.DescricaoProblema);
        }

        [TestMethod()]
        public void DeleteTestGetValid()
        {
            // Act
            var result = controller!.Delete(1, GetTargetSolicitacaoViewModel());
            // Assert
            Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
            RedirectToActionResult redirectToActionResult = (RedirectToActionResult)result;
            Assert.IsNull(redirectToActionResult.ControllerName);
            Assert.AreEqual("Index", redirectToActionResult.ActionName);
        }

        private SolicitacaoManutencaoViewModel GetTargetSolicitacaoViewModel()
        {
            return new SolicitacaoManutencaoViewModel
            {
                Id = 1,
                IdVeiculo = 1,
                IdPessoa = 2,
                DataSolicitacao = DateTime.Parse("2023-11-01"),
                DescricaoProblema = "Troca de pneus",
                IdFrota = 1
            };

        }

        private static Solicitacaomanutencao GetTargetSolicitacaoManutencao()
        {
            return new Solicitacaomanutencao
            {
                Id = 1,
                IdVeiculo = 1,
                IdPessoa = 2,
                DataSolicitacao = DateTime.Parse("2023-11-01"),
                DescricaoProblema = "Troca de pneus",
                IdFrota = 1
            };
        }

        private IEnumerable<Solicitacaomanutencao> GetTargetSolicitacaoManutencoes()
        {
            return new List<Solicitacaomanutencao>
            {
                new Solicitacaomanutencao
                {
                    Id = 1,
                    IdVeiculo = 1,
                    IdPessoa = 2,
                    DataSolicitacao = DateTime.Parse("2023-11-01"),
                    DescricaoProblema = "Troca de pneus",
                    IdFrota = 1
                },
                new Solicitacaomanutencao
                {
                    Id = 2,
                    IdVeiculo = 1,
                    IdPessoa = 1,
                    DataSolicitacao = DateTime.Parse("2023-11-05"),
                    DescricaoProblema = "Troca de oléo",
                    IdFrota = 2
                },
                new Solicitacaomanutencao
                {
                    Id = 3,
                    IdVeiculo = 1,
                    IdPessoa = 2,
                    DataSolicitacao = DateTime.Parse("2023-11-08"),
                    DescricaoProblema = "Revisão geral",
                    IdFrota = 3
                }
            };
        }
    }
}