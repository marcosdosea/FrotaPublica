using AutoMapper;
using FrotaWeb.Mappers;
using Core.Service;
using Moq;
using Core;
using Microsoft.AspNetCore.Mvc;
using FrotaWeb.Models;
using static System.Runtime.InteropServices.JavaScript.JSType;
using System.Runtime.ConstrainedExecution;
using System.Security.Cryptography;

namespace FrotaWeb.Controllers.Tests
{
    [TestClass()]
    public class FrotaControllerTests
    {
        private static FrotaController? controller;

        [TestInitialize]
        public void Initialize()
        {
            // Arrange
            var mockFrotaService = new Mock<IFrotaService>();
            IMapper mapper = new MapperConfiguration(cfg =>
                cfg.AddProfile(new FrotaProfile())).CreateMapper();
            mockFrotaService.Setup(service => service.GetAll())
                .Returns(GetTestFrotas());
            mockFrotaService.Setup(service => service.Get(1))
                .Returns(GetTargetFrota());
            mockFrotaService.Setup(service => service.Edit(It.IsAny<Frotum>()))
                .Verifiable();
            mockFrotaService.Setup(service => service.Create(It.IsAny<Frotum>()))
                .Verifiable();
            controller = new FrotaController(mockFrotaService.Object, mapper);
        }

        [TestMethod()]
        public void IndexTestValid()
        {
            // Act
            var result = controller!.Index();
            // Assert
            Assert.IsInstanceOfType(result, typeof(ViewResult));
            ViewResult viewResult = (ViewResult)result;
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(List<FrotaViewModel>));
            List<FrotaViewModel>? lista = (List<FrotaViewModel>)viewResult.ViewData.Model;
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
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(FrotaViewModel));
            FrotaViewModel frotaViewModel = (FrotaViewModel)viewResult.ViewData.Model;
            Assert.AreEqual("Transportes Oliveira", frotaViewModel.Nome);
            Assert.AreEqual("12345678000199", frotaViewModel.Cnpj);
            Assert.AreEqual("12345678", frotaViewModel.Cep);
            Assert.AreEqual("Avenida Principal", frotaViewModel.Rua);
            Assert.AreEqual("Centro", frotaViewModel.Bairro);
            Assert.AreEqual("100", frotaViewModel.Numero);
            Assert.AreEqual("Sala 201", frotaViewModel.Complemento);
            Assert.AreEqual("São Paulo", frotaViewModel.Cidade);
            Assert.AreEqual("SP", frotaViewModel.Estado);
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
            var result = controller!.Create(GetTargetFrotaViewModel());
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
            controller!.ModelState.AddModelError("Nome", "Required");
            // Act
            var result = controller!.Create(GetTargetFrotaViewModel());
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
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(FrotaViewModel));
            FrotaViewModel frotaViewModel = (FrotaViewModel)viewResult.ViewData.Model;
            Assert.AreEqual("Transportes Oliveira", frotaViewModel.Nome);
            Assert.AreEqual("12345678000199", frotaViewModel.Cnpj);
            Assert.AreEqual("12345678", frotaViewModel.Cep);
            Assert.AreEqual("Avenida Principal", frotaViewModel.Rua);
            Assert.AreEqual("Centro", frotaViewModel.Bairro);
            Assert.AreEqual("100", frotaViewModel.Numero);
            Assert.AreEqual("Sala 201", frotaViewModel.Complemento);
            Assert.AreEqual("São Paulo", frotaViewModel.Cidade);
            Assert.AreEqual("SP", frotaViewModel.Estado);
        }

        [TestMethod()]
        public void EditTestPostValid()
        {
            // Act
            var result = controller!.Edit(1, GetTargetFrotaViewModel());
            // Assert
            Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
            RedirectToActionResult redirectToActionResult = (RedirectToActionResult)result;
            Assert.IsNull(redirectToActionResult.ControllerName);
            Assert.AreEqual("Index", redirectToActionResult.ActionName);
        }

        [TestMethod()]
        public void DeleteTest()
        {
            // Act
            var result = controller!.Delete(1);
            // Assert
            Assert.IsInstanceOfType(result, typeof(ViewResult));
            ViewResult viewResult = (ViewResult)result;
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(FrotaViewModel));
            FrotaViewModel frotaViewModel = (FrotaViewModel)viewResult.ViewData.Model;
            Assert.AreEqual("Transportes Oliveira", frotaViewModel.Nome);
            Assert.AreEqual("12345678000199", frotaViewModel.Cnpj);
            Assert.AreEqual("12345678", frotaViewModel.Cep);
            Assert.AreEqual("Avenida Principal", frotaViewModel.Rua);
            Assert.AreEqual("Centro", frotaViewModel.Bairro);
            Assert.AreEqual("100", frotaViewModel.Numero);
            Assert.AreEqual("Sala 201", frotaViewModel.Complemento);
            Assert.AreEqual("São Paulo", frotaViewModel.Cidade);
            Assert.AreEqual("SP", frotaViewModel.Estado);
        }

        [TestMethod()]
        public void DeleteTestGetValid()
        {
            // Act
            var result = controller!.Delete(1, GetTargetFrotaViewModel());
            // Assert
            Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
            RedirectToActionResult redirectToActionResult = (RedirectToActionResult)result;
            Assert.IsNull(redirectToActionResult.ControllerName);
            Assert.AreEqual("Index", redirectToActionResult.ActionName);
        }

        private FrotaViewModel GetTargetFrotaViewModel()
        {
            return new FrotaViewModel
            {
                Id = 1,
                Nome = "Transportes Oliveira",
                Cnpj = "12345678000199",
                Cep = "12345678",
                Rua = "Avenida Principal",
                Bairro = "Centro",
                Numero = "100",
                Complemento = "Sala 201",
                Cidade = "São Paulo",
                Estado = "SP"
            };
        }

        private Frotum GetTargetFrota()
        {
            return new Frotum
            {
                Id = 1,
                Nome = "Transportes Oliveira",
                Cnpj = "12345678000199",
                Cep = "12345678",
                Rua = "Avenida Principal",
                Bairro = "Centro",
                Numero = "100",
                Complemento = "Sala 201",
                Cidade = "São Paulo",
                Estado = "SP"
            };
        }

        private IEnumerable<Frotum> GetTestFrotas()
        {
            return new List<Frotum>
            {
                new Frotum
                {
                    Id = 1,
                    Nome = "Transportes Oliveira",
                    Cnpj = "12345678000199",
                    Cep = "12345678",
                    Rua = "Avenida Principal",
                    Bairro = "Centro",
                    Numero = "100",
                    Complemento = "Sala 201",
                    Cidade = "São Paulo",
                    Estado = "SP"
                },
                new Frotum
                {
                    Id = 2,
                    Nome = "Logística Santos",
                    Cnpj = "98765432000188",
                    Cep = "98765432",
                    Rua = "Rua das Flores",
                    Bairro = "Vila Nova",
                    Numero = "250",
                    Complemento = "Galpão 3",
                    Cidade = "Rio de Janeiro",
                    Estado = "RJ"
                },
                new Frotum
                {
                    Id = 3,
                    Nome = "Expresso Litoral",
                    Cnpj = "45612378000122",
                    Cep = "54321098",
                    Rua = "Avenida Atlântica",
                    Bairro = "Boa Vista",
                    Numero = "300",
                    Complemento = null,
                    Cidade = "Salvador",
                    Estado = "BA"
                },
                new Frotum
                {
                    Id = 4,
                    Nome = "Carga Pesada Ltda",
                    Cnpj = "32165498000177",
                    Cep = "67890123",
                    Rua = "Rua do Porto",
                    Bairro = "Industrial",
                    Numero = "75",
                    Complemento = "Bloco B",
                    Cidade = "Curitiba",
                    Estado = "PR"
                }
            };
        }
    }
}