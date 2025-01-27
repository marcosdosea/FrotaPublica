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
            Assert.AreEqual("26243946000172", frotaViewModel.Cnpj);
            Assert.AreEqual("79080170", frotaViewModel.Cep);
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
            Assert.AreEqual("26243946000172", frotaViewModel.Cnpj);
            Assert.AreEqual("79080170", frotaViewModel.Cep);
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
            Assert.AreEqual("26243946000172", frotaViewModel.Cnpj);
            Assert.AreEqual("79080170", frotaViewModel.Cep);
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
                Cnpj = "26243946000172",
                Cep = "79080170",
                Rua = "Américo Carlos da Costa",
                Bairro = "Jardim América",
                Numero = "103",
                Complemento = null,
                Cidade = "Campo Grande",
                Estado = "MS"
            };
        }

        private Frotum GetTargetFrota()
        {
            return new Frotum
            {
                Id = 1,
                Nome = "Transportes Oliveira",
                Cnpj = "26243946000172",
                Cep = "79080170",
                Rua = "Américo Carlos da Costa",
                Bairro = "Jardim América",
                Numero = "103",
                Complemento = null,
                Cidade = "Campo Grande",
                Estado = "MS"
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
                    Cnpj = "26243946000172",
                    Cep = "79080170",
                    Rua = "Américo Carlos da Costa",
                    Bairro = "Jardim América",
                    Numero = "103",
                    Complemento = null,
                    Cidade = "Campo Grande",
                    Estado = "MS"
                },
                new Frotum
                {
                    Id = 2,
                    Nome = "Logística Santos",
                    Cnpj = "98103198000133",
                    Cep = null,
                    Rua = null,
                    Bairro = null,
                    Numero = null,
                    Complemento = null,
                    Cidade = null,
                    Estado = "RJ"
                },
                new Frotum
                {
                    Id = 3,
                    Nome = "Expresso Litoral",
                    Cnpj = "50806346000150",
                    Cep = "81460090",
                    Rua = null,
                    Bairro = null,
                    Numero = null,
                    Complemento = null,
                    Cidade = "Curitiba",
                    Estado = "PR"
                },
                new Frotum
                {
                    Id = 4,
                    Nome = "Carga Pesada Ltda",
                    Cnpj = "39612223000145",
                    Cep = "60832120",
                    Rua = "Nova Olímpia",
                    Bairro = null,
                    Numero = null,
                    Complemento = null,
                    Cidade = "Fortaleza",
                    Estado = "CE"
                }
            };
        }
    }
}