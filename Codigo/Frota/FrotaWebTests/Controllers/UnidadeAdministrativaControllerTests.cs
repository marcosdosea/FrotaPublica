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
            mockUnidadeAdministrativaService.Setup(service => service.GetAll()).Returns(GetTestUnidadesAdministrativas());
            mockUnidadeAdministrativaService.Setup(service => service.Get(1)).Returns(GetTargetUnidadeAdministrativa());
            mockUnidadeAdministrativaService.Setup(service => service.Edit(It.IsAny<Unidadeadministrativa>())).Verifiable();
            mockUnidadeAdministrativaService.Setup(service => service.Create(It.IsAny<Unidadeadministrativa>())).Verifiable();
            controller = new UnidadeAdministrativaController(mockUnidadeAdministrativaService.Object, mapper);

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
            Assert.AreEqual("Unidade A", unidadeViewModel.Nome);
            Assert.AreEqual("12345000", unidadeViewModel.Cep);
            Assert.AreEqual("Rua A", unidadeViewModel.Rua);
            Assert.AreEqual("Bairro A", unidadeViewModel.Bairro);
            Assert.AreEqual("100", unidadeViewModel.Numero);
            Assert.AreEqual("Prédio 1", unidadeViewModel.Complemento);
            Assert.AreEqual("Cidade A", unidadeViewModel.Cidade);
            Assert.AreEqual("SP", unidadeViewModel.Estado);
            Assert.AreEqual(-23.571234f, unidadeViewModel.Latitude);
            Assert.AreEqual(-46.453333f, unidadeViewModel.Longitude);
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
            Assert.AreEqual("Unidade A", unidadeViewModel.Nome);
            Assert.AreEqual("12345000", unidadeViewModel.Cep);
            Assert.AreEqual("Rua A", unidadeViewModel.Rua);
            Assert.AreEqual("Bairro A", unidadeViewModel.Bairro);
            Assert.AreEqual("100", unidadeViewModel.Numero);
            Assert.AreEqual("Prédio 1", unidadeViewModel.Complemento);
            Assert.AreEqual("Cidade A", unidadeViewModel.Cidade);
            Assert.AreEqual("SP", unidadeViewModel.Estado);
            Assert.AreEqual(-23.571234f, unidadeViewModel.Latitude);
            Assert.AreEqual(-46.453333f, unidadeViewModel.Longitude);
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
            Assert.AreEqual("Unidade A", unidadeViewModel.Nome);
            Assert.AreEqual("12345000", unidadeViewModel.Cep);
            Assert.AreEqual("Rua A", unidadeViewModel.Rua);
            Assert.AreEqual("Bairro A", unidadeViewModel.Bairro);
            Assert.AreEqual("100", unidadeViewModel.Numero);
            Assert.AreEqual("Prédio 1", unidadeViewModel.Complemento);
            Assert.AreEqual("Cidade A", unidadeViewModel.Cidade);
            Assert.AreEqual("SP", unidadeViewModel.Estado);
            Assert.AreEqual(-23.571234f, unidadeViewModel.Latitude);
            Assert.AreEqual(-46.453333f, unidadeViewModel.Longitude);
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
                Nome = "Unidade A",
                Cep = "12345000",
                Rua = "Rua A",
                Bairro = "Bairro A",
                Numero = "100",
                Complemento = "Prédio 1",
                Cidade = "Cidade A",
                Estado = "SP",
                Latitude = -23.571234f,
                Longitude = -46.453333f
            };
        }

        private Unidadeadministrativa GetTargetUnidadeAdministrativa()
        {
            return new Unidadeadministrativa
            {
                Id = 1,
                Nome = "Unidade A",
                Cep = "12345000",
                Rua = "Rua A",
                Bairro = "Bairro A",
                Numero = "100",
                Complemento = "Prédio 1",
                Cidade = "Cidade A",
                Estado = "SP",
                Latitude = -23.571234f,
                Longitude = -46.453333f
            };
        }

        private IEnumerable<Unidadeadministrativa> GetTestUnidadesAdministrativas()
        {
            return new List<Unidadeadministrativa>
            {
                new Unidadeadministrativa
                {
                    Id = 1,
                    Nome = "Unidade A",
                    Cep = "12345000",
                    Rua = "Rua A",
                    Bairro = "Bairro A",
                    Numero = "100",
                    Complemento = "Prédio 1",
                    Cidade = "Cidade A",
                    Estado = "SP",
                    Latitude = -23.571234f,
                    Longitude = -46.453333f
                },
                new Unidadeadministrativa
                {
                    Id = 2,
                    Nome = "Unidade B",
                    Cep = "54321000",
                    Rua = "Rua B",
                    Bairro = "Bairro B",
                    Numero = "200",
                    Complemento = "Andar 2",
                    Cidade = "Cidade B",
                    Estado = "RJ",
                    Latitude = -22.561234f,
                    Longitude = -44.323333f
                },
                new Unidadeadministrativa
                {
                    Id = 3,
                    Nome = "Unidade C",
                    Cep = "67890000",
                    Rua = "Rua C",
                    Bairro = "Bairro C",
                    Numero = "300",
                    Complemento = "Prédio 3",
                    Cidade = "Cidade C",
                    Estado = "MG",
                    Latitude = -24.561234f,
                    Longitude = -45.323333f
                },
                new Unidadeadministrativa
                {
                    Id = 4,
                    Nome = "Unidade D",
                    Cep = "98765000",
                    Rua = "Rua D",
                    Bairro = "Bairro D",
                    Numero = "400",
                    Complemento = "Bloco 4",
                    Cidade = "Cidade D",
                    Estado = "BA",
                    Latitude = -25.561234f,
                    Longitude = -46.323333f
                }
            };
        }
    }
}