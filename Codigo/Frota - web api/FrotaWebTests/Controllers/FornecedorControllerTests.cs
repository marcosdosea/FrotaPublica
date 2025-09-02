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
    public class FornecedorControllerTests
    {
        private static FornecedorController? fornecedorController;

        [TestInitialize]
        public void Initialize()
        {
            // Arrange
            var mockFornecedorService = new Mock<IFornecedorService>();
            IMapper mapper = new MapperConfiguration(cfg =>
                cfg.AddProfile(new FornecedorProfile())).CreateMapper();
            mockFornecedorService.Setup(service => service.GetAll(It.IsAny<int>())).Returns(GetTestFornecedores());
            mockFornecedorService.Setup(service => service.Get(1)).Returns(GetTargetFornecedor());
            mockFornecedorService.Setup(service => service.Create(It.IsAny<Fornecedor>(), It.IsAny<int>()));
            mockFornecedorService.Setup(service => service.Edit(It.IsAny<Fornecedor>(), It.IsAny<int>()));
            mockFornecedorService.Setup(service => service.Delete(It.IsAny<uint>()));
            fornecedorController = new FornecedorController(mockFornecedorService.Object, mapper);
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
            fornecedorController.ControllerContext = new ControllerContext
            {
                HttpContext = httpContextAccessor.HttpContext
            };
        }

        [TestMethod()]
        public void IndexTestValid()
        {
            // Act
            var result = fornecedorController!.Index();
            // Assert
            Assert.IsInstanceOfType(result, typeof(ViewResult));
            ViewResult viewResult = (ViewResult)result;
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(List<FornecedorViewModel>));
            List<FornecedorViewModel>? fornecedorViewModels = (List<FornecedorViewModel>)viewResult.ViewData.Model;
            Assert.AreEqual(4, fornecedorViewModels.Count);
        }

        [TestMethod()]
        public void DetailsTestValid()
        {
            // Act
            var result = fornecedorController!.Details(1);
            // Assert
            Assert.IsInstanceOfType(result, typeof(ViewResult));
            ViewResult viewResult = (ViewResult)result;
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(FornecedorViewModel));
            FornecedorViewModel fornecedorViewModel = (FornecedorViewModel)viewResult.ViewData.Model;
            Assert.AreEqual("AutoParts Express", fornecedorViewModel.Nome);
            Assert.AreEqual("97234939000152", fornecedorViewModel.Cnpj);
            Assert.AreEqual("48770971", fornecedorViewModel.Cep);
        }

        [TestMethod()]
        public void CreateTestGetValid()
        {
            // Act
            var result = fornecedorController!.Create();
            // Assert
            Assert.IsInstanceOfType(result, typeof(ViewResult));
        }

        [TestMethod()]
        public void CreateTestValid()
        {
            // Act
            var result = fornecedorController!.Create(GetTargetFornecedorViewModel());
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
            fornecedorController!.ModelState.AddModelError("Nome", "Campo requerido");
            // Act
            var result = fornecedorController.Create(GetTargetFornecedorViewModel());
            // Assert
            Assert.AreEqual(1, fornecedorController.ModelState.ErrorCount);
            Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
            RedirectToActionResult redirectToActionResult = (RedirectToActionResult)result;
            Assert.IsNull(redirectToActionResult.ControllerName);
            Assert.AreEqual("Index", redirectToActionResult.ActionName);
        }

        [TestMethod()]
        public void EditTestGetValid()
        {
            // Act
            var result = fornecedorController!.Edit(1);
            // Assert
            Assert.IsInstanceOfType(result, typeof(ViewResult));
            ViewResult viewResult = (ViewResult)result;
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(FornecedorViewModel));
            FornecedorViewModel fornecedorViewModel = (FornecedorViewModel)viewResult.ViewData.Model;
            Assert.AreEqual("AutoParts Express", fornecedorViewModel.Nome);
            Assert.AreEqual("97234939000152", fornecedorViewModel.Cnpj);
            Assert.AreEqual("48770971", fornecedorViewModel.Cep);
        }

        [TestMethod()]
        public void EditTestPostValid()
        {
            // Act
            var result = fornecedorController!.Edit(GetTargetFornecedorViewModel().Id, GetTargetFornecedorViewModel());
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
            var result = fornecedorController!.Delete(1);
            // Assert
            Assert.IsInstanceOfType(result, typeof(ViewResult));
            ViewResult viewResult = (ViewResult)result;
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(FornecedorViewModel));
            FornecedorViewModel fornecedorViewModel = (FornecedorViewModel)viewResult.ViewData.Model;
            Assert.AreEqual("AutoParts Express", fornecedorViewModel.Nome);
            Assert.AreEqual("97234939000152", fornecedorViewModel.Cnpj);
            Assert.AreEqual("48770971", fornecedorViewModel.Cep);

        }

        [TestMethod()]
        public void DeleteTestGetValid()
        {
            // Act
            var result = fornecedorController!.Delete(1, GetTargetFornecedorViewModel());
            // Assert
            Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
            RedirectToActionResult redirectToActionResult = (RedirectToActionResult)result;
            Assert.IsNull(redirectToActionResult.ControllerName);
            Assert.AreEqual("Index", redirectToActionResult.ActionName);
        }


        private static FornecedorViewModel GetTargetFornecedorViewModel()
        {
            return new FornecedorViewModel
            {
                Id = 1,
                Nome = "AutoParts Express",
                Cnpj = "97234939000152",
                Cep = "48770971",
                Rua = "Rua Principal",
                Bairro = "Canto",
                Numero = null,
                Complemento = null,
                Cidade = "Teofilândia",
                Estado = "BA",
                Latitude = -114861,
                Longitude = -389735,
                IdFrota = 1
            };
        }
        private static Fornecedor GetTargetFornecedor()
        {
            return new Fornecedor
            {
                Id = 1,
                Nome = "AutoParts Express",
                Cnpj = "97234939000152",
                Cep = "48770971",
                Rua = "Rua Principal",
                Bairro = "Canto",
                Numero = null,
                Complemento = null,
                Cidade = "Teofilândia",
                Estado = "BA",
                Latitude = -114861,
                Longitude = -389735,
                IdFrota = 1
            };
        }

        private static IEnumerable<Fornecedor> GetTestFornecedores()
        {
            return new List<Fornecedor>
            {
                new Fornecedor
                {
                    Id = 1,
                    Nome = "AutoParts Express",
                    Cnpj = "97234939000152",
                    Cep = "48770971",
                    Rua = "Rua Principal",
                    Bairro = "Canto",
                    Numero = null,
                    Complemento = null,
                    Cidade = "Teofilândia",
                    Estado = "BA",
                    Latitude = -114861,
                    Longitude = -389735,
                    IdFrota = 1
                },
                new Fornecedor
                {
                    Id = 2,
                    Nome = "FuelPro Distribuidora",
                    Cnpj = "84555003000181",
                    Cep = "69068420",
                    Rua = "Rua 14",
                    Bairro = "Raiz",
                    Numero = "16",
                    Complemento = "Andar 2",
                    Cidade = "Manaus",
                    Estado = "AM",
                    Latitude = -312149,
                    Longitude = -599969,
                    IdFrota = 2
                },
                new Fornecedor
                {
                    Id = 3,
                    Nome = "MaxFleet Services",
                    Cnpj = "10803495000140",
                    Cep = "27960168",
                    Rua = "Travessa Matias Barbosa",
                    Bairro = "Macaé",
                    Numero = "20",
                    Complemento = null,
                    Cidade = "Macaé",
                    Estado = "RG",
                    Latitude = -22383873,
                    Longitude = -417826,
                    IdFrota = 2
                },
                new Fornecedor
                {
                    Id = 4,
                    Nome = "RoadSafe Pneus",
                    Cnpj = "53933822000191",
                    Cep = "97545050",
                    Rua = "Rua Álvaro Ignácio de Medeiros",
                    Bairro = "Atlântida",
                    Numero = "400",
                    Complemento = null,
                    Cidade = "Alegrete",
                    Estado = "RS",
                    Latitude = -255612,
                    Longitude = -463233,
                    IdFrota = 3,
                    Ativo = 0
                }
            };
        }
    }
}
