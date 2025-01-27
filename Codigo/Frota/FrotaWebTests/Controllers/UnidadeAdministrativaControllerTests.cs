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
    public class UnidadeAdministrativaControllerTests
    {
        private static UnidadeAdministrativaController? controller;

        [TestInitialize]
        public void Initialize()
        {
            // Arrange
            var mockUnidadeAdministrativaService = new Mock<IUnidadeAdministrativaService>();
            IMapper mapper = new MapperConfiguration(cfg =>
                cfg.AddProfile(new UnidadeAdministrativaProfile())).CreateMapper();
            mockUnidadeAdministrativaService.Setup(service => service.GetAll(It.IsAny<uint>())).Returns(GetTestUnidadesAdministrativas());
            mockUnidadeAdministrativaService.Setup(service => service.Get(1)).Returns(GetTargetUnidadeAdministrativa());
            mockUnidadeAdministrativaService.Setup(service => service.Edit(It.IsAny<Unidadeadministrativa>(), It.IsAny<int>())).Verifiable();
            mockUnidadeAdministrativaService.Setup(service => service.Create(It.IsAny<Unidadeadministrativa>(), It.IsAny<int>())).Verifiable();
            controller = new UnidadeAdministrativaController(mockUnidadeAdministrativaService.Object, mapper);
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
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(List<UnidadeAdministrativaViewModel>));
            List<UnidadeAdministrativaViewModel>? lista = (List<UnidadeAdministrativaViewModel>)viewResult.ViewData.Model;
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
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(UnidadeAdministrativaViewModel));
            UnidadeAdministrativaViewModel unidadeViewModel = (UnidadeAdministrativaViewModel)viewResult.ViewData.Model;
            Assert.AreEqual("Logística Norte", unidadeViewModel.Nome);
            Assert.AreEqual("59625400", unidadeViewModel.Cep);
            Assert.AreEqual("Avenida Jorge Coelho de Andrade", unidadeViewModel.Rua);
            Assert.AreEqual("Presidente Costa e Silva", unidadeViewModel.Bairro);
            Assert.AreEqual("12", unidadeViewModel.Numero);
            Assert.AreEqual(null, unidadeViewModel.Complemento);
            Assert.AreEqual(null, unidadeViewModel.Cidade);
            Assert.AreEqual(null, unidadeViewModel.Estado);
            Assert.AreEqual(null, unidadeViewModel.Latitude);
            Assert.AreEqual(null, unidadeViewModel.Longitude);
            Assert.AreEqual((uint)1, unidadeViewModel.IdFrota);
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
            var result = controller!.Create(GetTargetUnidadeAdministrativaViewModel());
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
            controller!.ModelState.AddModelError("Nome", "O Nome é obrigatório");
            // Act
            var result = controller.Create(GetTargetUnidadeAdministrativaViewModel());
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
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(UnidadeAdministrativaViewModel));
            UnidadeAdministrativaViewModel unidadeViewModel = (UnidadeAdministrativaViewModel)viewResult.ViewData.Model;
            Assert.AreEqual("Logística Norte", unidadeViewModel.Nome);
            Assert.AreEqual("59625400", unidadeViewModel.Cep);
            Assert.AreEqual("Avenida Jorge Coelho de Andrade", unidadeViewModel.Rua);
            Assert.AreEqual("Presidente Costa e Silva", unidadeViewModel.Bairro);
            Assert.AreEqual("12", unidadeViewModel.Numero);
            Assert.AreEqual(null, unidadeViewModel.Complemento);
            Assert.AreEqual(null, unidadeViewModel.Cidade);
            Assert.AreEqual(null, unidadeViewModel.Estado);
            Assert.AreEqual(null, unidadeViewModel.Latitude);
            Assert.AreEqual(null, unidadeViewModel.Longitude);
            Assert.AreEqual((uint)1, unidadeViewModel.IdFrota);
        }

        [TestMethod()]
        public void EditTestPostValid()
        {
            // Act
            var result = controller!.Edit(GetTargetUnidadeAdministrativaViewModel().Id, GetTargetUnidadeAdministrativaViewModel());
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
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(UnidadeAdministrativaViewModel));
            UnidadeAdministrativaViewModel unidadeViewModel = (UnidadeAdministrativaViewModel)viewResult.ViewData.Model;
            Assert.AreEqual("Logística Norte", unidadeViewModel.Nome);
            Assert.AreEqual("59625400", unidadeViewModel.Cep);
            Assert.AreEqual("Avenida Jorge Coelho de Andrade", unidadeViewModel.Rua);
            Assert.AreEqual("Presidente Costa e Silva", unidadeViewModel.Bairro);
            Assert.AreEqual("12", unidadeViewModel.Numero);
            Assert.AreEqual(null, unidadeViewModel.Complemento);
            Assert.AreEqual(null, unidadeViewModel.Cidade);
            Assert.AreEqual(null, unidadeViewModel.Estado);
            Assert.AreEqual(null, unidadeViewModel.Latitude);
            Assert.AreEqual(null, unidadeViewModel.Longitude);
            Assert.AreEqual((uint)1, unidadeViewModel.IdFrota);
        }

        [TestMethod()]
        public void DeleteTestGetValid()
        {
            // Act
            var result = controller!.Delete(1, GetTargetUnidadeAdministrativaViewModel());
            // Assert
            Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
            RedirectToActionResult redirectToActionResult = (RedirectToActionResult)result;
            Assert.IsNull(redirectToActionResult.ControllerName);
            Assert.AreEqual("Index", redirectToActionResult.ActionName);
        }

        private UnidadeAdministrativaViewModel GetTargetUnidadeAdministrativaViewModel()
        {
            return new UnidadeAdministrativaViewModel
            {
                Id = 1,
                Nome = "Logística Norte",
                Cep = "59625400",
                Rua = "Avenida Jorge Coelho de Andrade",
                Bairro = "Presidente Costa e Silva",
                Complemento = null,
                Numero = "12",
                Cidade = null,
                Estado = null,
                Latitude = null,
                Longitude = null,
                IdFrota = 1
            };
        }

        private Unidadeadministrativa GetTargetUnidadeAdministrativa()
        {
            return new Unidadeadministrativa
            {
                Id = 1,
                Nome = "Logística Norte",
                Cep = "59625400",
                Rua = "Avenida Jorge Coelho de Andrade",
                Bairro = "Presidente Costa e Silva",
                Complemento = null,
                Numero = "12",
                Cidade = null,
                Estado = null,
                Latitude = null,
                Longitude = null,
                IdFrota = 1
            };
        }

        private IEnumerable<Unidadeadministrativa> GetTestUnidadesAdministrativas()
        {
            return new List<Unidadeadministrativa>
            {
                new Unidadeadministrativa
                {
                    Id = 1,
                    Nome = "Logística Norte",
                    Cep = "59625400",
                    Rua = "Avenida Jorge Coelho de Andrade",
                    Bairro = "Presidente Costa e Silva",
                    Complemento = null,
                    Numero = "12",
                    Cidade = null,
                    Estado = null,
                    Latitude = null,
                    Longitude = null,
                    IdFrota = 1
                },
                new Unidadeadministrativa
                {
                    Id = 2,
                    Nome = "Operacional Sul",
                    Cep = "68909166",
                    Rua = "Sérgio Mendes",
                    Bairro = "Boné Azul",
                    Complemento = "Próximo a padaria Camilinha",
                    Numero = "28",
                    Cidade = "Macapá",
                    Estado = "AP",
                    Latitude = (float) 0.082705,
                    Longitude = (float) -51.0741820,
                    IdFrota = 1
                },
                new Unidadeadministrativa
                {
                    Id = 3,
                    Nome = "Distribuição Leste",
                    Cep = null,
                    Rua = null,
                    Bairro = null,
                    Complemento = null,
                    Numero = null,
                    Cidade = null,
                    Estado = null,
                    Latitude = null,
                    Longitude = null,
                    IdFrota = 2
                },
                new Unidadeadministrativa
                {
                    Id = 4,
                    Nome = "Distribuição Leste",
                    Cep = "59072240",
                    Rua = "Santo Euzébio",
                    Bairro = "Felipe Camarão",
                    Complemento = null,
                    Numero = "12",
                    Cidade = "Natal",
                    Estado = "RN",
                    Latitude = null,
                    Longitude = null,
                    IdFrota = 2
                }
            };
        }
    }
}