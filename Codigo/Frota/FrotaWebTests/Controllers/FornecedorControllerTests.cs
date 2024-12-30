using AutoMapper;
using FrotaWeb.Mappers;
using Core.Service;
using Moq;
using Core;
using Microsoft.AspNetCore.Mvc;
using FrotaWeb.Models;

namespace FrotaWeb.Controllers.Tests
{
    [TestClass()]
    public class FornecedorControllerTests
    {
        private static FornecedorController? fornecedorController;

        [TestInitialize]
        public void Initializ()
        {
            // Arrange
            var mockFornecedorService = new Mock<IFornecedorService>();
            IMapper mapper = new MapperConfiguration(cfg =>
                cfg.AddProfile(new FornecedorProfile())).CreateMapper();
            mockFornecedorService.Setup(service => service.GetAll()).Returns(GetTestFornecedores());
            mockFornecedorService.Setup(service => service.Get(1)).Returns(GetTargetFornecedor());
            mockFornecedorService.Setup(service => service.Create(It.IsAny<Fornecedor>()));
            mockFornecedorService.Setup(service => service.Edit(It.IsAny<Fornecedor>()));
            mockFornecedorService.Setup(service => service.Delete(It.IsAny<uint>()));
            fornecedorController = new FornecedorController(mockFornecedorService.Object, mapper);
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
            Assert.AreEqual("Fornecedor 1", fornecedorViewModel.Nome);
            Assert.AreEqual("12345678901234", fornecedorViewModel.Cnpj);
            Assert.AreEqual("12345000", fornecedorViewModel.Cep);
            Assert.AreEqual("Rua 1", fornecedorViewModel.Rua);
            Assert.AreEqual("Bairro 1", fornecedorViewModel.Bairro);
            Assert.AreEqual("100", fornecedorViewModel.Numero);
            Assert.AreEqual("Sala 1", fornecedorViewModel.Complemento);
            Assert.AreEqual("Cidade 1", fornecedorViewModel.Cidade);
            Assert.AreEqual("SP", fornecedorViewModel.Estado);
            Assert.AreEqual(-23571234, fornecedorViewModel.Latitude);
            Assert.AreEqual(-46453333, fornecedorViewModel.Longitude);
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
            Assert.AreEqual("Fornecedor 1", fornecedorViewModel.Nome);
            Assert.AreEqual("12345678901234", fornecedorViewModel.Cnpj);
            Assert.AreEqual("12345000", fornecedorViewModel.Cep);
            Assert.AreEqual("Rua 1", fornecedorViewModel.Rua);
            Assert.AreEqual("Bairro 1", fornecedorViewModel.Bairro);
            Assert.AreEqual("100", fornecedorViewModel.Numero);
            Assert.AreEqual("Sala 1", fornecedorViewModel.Complemento);
            Assert.AreEqual("Cidade 1", fornecedorViewModel.Cidade);
            Assert.AreEqual("SP", fornecedorViewModel.Estado);
            Assert.AreEqual(-23571234, fornecedorViewModel.Latitude);
            Assert.AreEqual(-46453333, fornecedorViewModel.Longitude);
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
            Assert.AreEqual("Fornecedor 1", fornecedorViewModel.Nome);
            Assert.AreEqual("12345678901234", fornecedorViewModel.Cnpj);
            Assert.AreEqual("12345000", fornecedorViewModel.Cep);

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

        [TestMethod()]
        public async Task ConsultaCnpjValid()
        {
            // Arrange
            string cnpj = "10409486000170";
            // Act
            var result = await fornecedorController!.ConsultaCnpj(cnpj);
            if (result is not BadRequestObjectResult)
            {
                // Assert
                Assert.IsInstanceOfType(result, typeof(ContentResult));
                ContentResult contentResult = (ContentResult)result;
                Assert.IsNotNull(contentResult.Content);
                Assert.IsTrue(contentResult.Content.Contains("ITATECH GROUP JR."));
            }
        }

        [TestMethod()]
        public async Task ConsultaCnpjInvalid()
        {
            // Arrang
            string cnpj = "12345678923230";
            // Act
            var result = await fornecedorController!.ConsultaCnpj(cnpj);
            if (result is not BadRequestObjectResult)
            {
                // Assert
                Assert.IsInstanceOfType(result, typeof(ContentResult));
                ContentResult contentResult = (ContentResult)result;
                Assert.IsNotNull(contentResult.Content);
                Assert.IsTrue(contentResult.Content.Contains("CNPJ inválido"));
            }
        }

        private static FornecedorViewModel GetTargetFornecedorViewModel()
        {
            return new FornecedorViewModel
            {
                Id = 1,
                Nome = "Fornecedor 1",
                Cnpj = "12345678901234",
                Cep = "12345000",
                Rua = "Rua 1",
                Bairro = "Bairro 1",
                Numero = "100",
                Complemento = "Sala 1",
                Cidade = "Cidade 1",
                Estado = "SP",
                Latitude = -23571234,
                Longitude = -46453333
            };
        }
        private static Fornecedor GetTargetFornecedor()
        {
            return new Fornecedor
            {
                Id = 1,
                Nome = "Fornecedor 1",
                Cnpj = "12345678901234",
                Cep = "12345000",
                Rua = "Rua 1",
                Bairro = "Bairro 1",
                Numero = "100",
                Complemento = "Sala 1",
                Cidade = "Cidade 1",
                Estado = "SP",
                Latitude = -23571234,
                Longitude = -46453333
            };
        }

        private static IEnumerable<Fornecedor> GetTestFornecedores()
        {
            return new List<Fornecedor>
            {
                new Fornecedor
                {
                    Id = 1,
                    Nome = "Fornecedor A",
                    Cnpj = "12345678901234",
                    Cep = "12345000",
                    Rua = "Rua A",
                    Bairro = "Bairro A",
                    Numero = "100",
                    Complemento = "Sala 1",
                    Cidade = "Cidade A",
                    Estado = "SP",
                    Latitude = -23571234,
                    Longitude = -46453333
                },
                new Fornecedor
                {
                    Id = 2,
                    Nome = "Fornecedor B",
                    Cnpj = "98765432109876",
                    Cep = "54321000",
                    Rua = "Rua B",
                    Bairro = "Bairro B",
                    Numero = "200",
                    Complemento = "Andar 2",
                    Cidade = "Cidade B",
                    Estado = "RJ",
                    Latitude = -22561234,
                    Longitude = -44323333
                },
                new Fornecedor
                {
                    Id = 3,
                    Nome = "Fornecedor C",
                    Cnpj = "11223344556677",
                    Cep = "67890000",
                    Rua = "Rua C",
                    Bairro = "Bairro C",
                    Numero = "300",
                    Complemento = "Prédio 3",
                    Cidade = "Cidade C",
                    Estado = "MG",
                    Latitude = -24561234,
                    Longitude = -45323333
                },
                new Fornecedor
                {
                    Id = 4,
                    Nome = "Fornecedor D",
                    Cnpj = "22334455667788",
                    Cep = "98765000",
                    Rua = "Rua D",
                    Bairro = "Bairro D",
                    Numero = "400",
                    Complemento = "Bloco 4",
                    Cidade = "Cidade D",
                    Estado = "BA",
                    Latitude = -25561234,
                    Longitude = -46323333
                }
            };
        }
    }
}