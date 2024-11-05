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
    public class PessoaControllerTests
    {
        private static PessoaController? controller;

        [TestInitialize]
        public void Initialize()
        {
            // Arrange
            var mockPessoaService = new Mock<IPessoaService>();
            IMapper mapper = new MapperConfiguration(cfg =>
                cfg.AddProfile(new PessoaProfile())).CreateMapper();
            mockPessoaService.Setup(service => service.GetAll()).Returns(GetTestPessoas());
            mockPessoaService.Setup(service => service.Get(1)).Returns(GetTargetPessoa());
            mockPessoaService.Setup(service => service.Edit(It.IsAny<Pessoa>())).Verifiable();
            mockPessoaService.Setup(service => service.Create(It.IsAny<Pessoa>())).Verifiable();
            controller = new PessoaController(mockPessoaService.Object, mapper);
        }

        [TestMethod()]
        public void IndexTestValid()
        {
            // Act
            var result = controller!.Index();
            // Assert
            Assert.IsInstanceOfType(result, typeof(ViewResult));
            ViewResult viewResult = (ViewResult)result;
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(List<PessoaViewModel>));
            List<PessoaViewModel>? lista = (List<PessoaViewModel>)viewResult.ViewData.Model;
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
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(PessoaViewModel));
            PessoaViewModel pessoaViewModel = (PessoaViewModel)viewResult.ViewData.Model;
            Assert.AreEqual("Pessoa A", pessoaViewModel.Nome);
            Assert.AreEqual("12345678901", pessoaViewModel.Cpf);
            Assert.AreEqual("12345000", pessoaViewModel.Cep);
            Assert.AreEqual("Rua A", pessoaViewModel.Rua);
            Assert.AreEqual("Bairro A", pessoaViewModel.Bairro);
            Assert.AreEqual("100", pessoaViewModel.Numero);
            Assert.AreEqual("Casa 1", pessoaViewModel.Complemento);
            Assert.AreEqual("Cidade A", pessoaViewModel.Cidade);
            Assert.AreEqual("SP", pessoaViewModel.Estado);
            Assert.AreEqual(101m, pessoaViewModel.IdFrota);
            Assert.AreEqual(201m, pessoaViewModel.IdPapelPessoa);
            Assert.AreEqual(1, pessoaViewModel.Ativo);

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
            var result = controller!.Create(GetTargetPessoaViewModel());
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
            controller!.ModelState.AddModelError("Nome", "Campo obrigatório");
            // Act
            var result = controller!.Create(GetTargetPessoaViewModel());
            // Assert
            Assert.AreEqual(1, controller.ModelState.ErrorCount);
            Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
            RedirectToActionResult redirectResult = (RedirectToActionResult)result;
            Assert.IsNull(redirectResult.ControllerName);
            Assert.AreEqual("Index", redirectResult.ActionName);
        }

        [TestMethod()]
        public void EditTest()
        {
            // Act
            var result = controller!.Edit(1);
            // Assert
            Assert.IsInstanceOfType(result, typeof(ViewResult));
            ViewResult viewResult = (ViewResult)result;
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(PessoaViewModel));
            PessoaViewModel pessoaViewModel = (PessoaViewModel)viewResult.ViewData.Model;
            Assert.AreEqual("Pessoa A", pessoaViewModel.Nome);
            Assert.AreEqual("12345678901", pessoaViewModel.Cpf);
            Assert.AreEqual("12345000", pessoaViewModel.Cep);
            Assert.AreEqual("Rua A", pessoaViewModel.Rua);
            Assert.AreEqual("Bairro A", pessoaViewModel.Bairro);
            Assert.AreEqual("100", pessoaViewModel.Numero);
            Assert.AreEqual("Casa 1", pessoaViewModel.Complemento);
            Assert.AreEqual("Cidade A", pessoaViewModel.Cidade);
            Assert.AreEqual("SP", pessoaViewModel.Estado);
            Assert.AreEqual(101m, pessoaViewModel.IdFrota);
            Assert.AreEqual(201m, pessoaViewModel.IdPapelPessoa);
            Assert.AreEqual(1, pessoaViewModel.Ativo);
        }

        [TestMethod()]
        public void EditTestPostValid()
        {
            // Act
            var result = controller!.Edit(GetTargetPessoaViewModel().Id, GetTargetPessoaViewModel());
            // Assert
            Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
            RedirectToActionResult redirectResult = (RedirectToActionResult)result;
            Assert.IsNull(redirectResult.ControllerName);
            Assert.AreEqual("Index", redirectResult.ActionName);
        }

        [TestMethod()]
        public void DeleteTestPostValid()
        {
            // Act
            var result = controller!.Delete(1);
            // Assert
            Assert.IsInstanceOfType(result, typeof(ViewResult));
            ViewResult viewResult = (ViewResult)result;
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(PessoaViewModel));
            PessoaViewModel pessoaViewModel = (PessoaViewModel)viewResult.ViewData.Model;
            Assert.AreEqual("Pessoa A", pessoaViewModel.Nome);
            Assert.AreEqual("12345678901", pessoaViewModel.Cpf);
            Assert.AreEqual("12345000", pessoaViewModel.Cep);
            Assert.AreEqual("Rua A", pessoaViewModel.Rua);
            Assert.AreEqual("Bairro A", pessoaViewModel.Bairro);
            Assert.AreEqual("100", pessoaViewModel.Numero);
            Assert.AreEqual("Casa 1", pessoaViewModel.Complemento);
            Assert.AreEqual("Cidade A", pessoaViewModel.Cidade);
            Assert.AreEqual("SP", pessoaViewModel.Estado);
            Assert.AreEqual(101m, pessoaViewModel.IdFrota);
            Assert.AreEqual(201m, pessoaViewModel.IdPapelPessoa);
            Assert.AreEqual(1, pessoaViewModel.Ativo);
        }

        [TestMethod()]
        public void DeleteTestGetValid()
        {
            // Act
            var result = controller!.Delete(1, GetTargetPessoaViewModel());
            // Assert
            Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
            RedirectToActionResult redirectResult = (RedirectToActionResult)result;
            Assert.IsNull(redirectResult.ControllerName);
            Assert.AreEqual("Index", redirectResult.ActionName);
        }

        private PessoaViewModel GetTargetPessoaViewModel()
        {
            return new PessoaViewModel
            {
                Id = 1,
                Cpf = "12345678901",
                Nome = "Pessoa A",
                Cep = "12345000",
                Rua = "Rua A",
                Bairro = "Bairro A",
                Numero = "100",
                Complemento = "Casa 1",
                Cidade = "Cidade A",
                Estado = "SP",
                IdFrota = 101,
                IdPapelPessoa = 201,
                Ativo = 1
            };
        }

        private Pessoa GetTargetPessoa()
        {
            return new Pessoa
            {
                Id = 1,
                Cpf = "12345678901",
                Nome = "Pessoa A",
                Cep = "12345000",
                Rua = "Rua A",
                Bairro = "Bairro A",
                Numero = "100",
                Complemento = "Casa 1",
                Cidade = "Cidade A",
                Estado = "SP",
                IdFrota = 101,
                IdPapelPessoa = 201,
                Ativo = 1
            };
        }

        private IEnumerable<Pessoa> GetTestPessoas()
        {
            return new List<Pessoa>
            {
                new Pessoa
                {
                    Id = 1,
                    Cpf = "12345678901",
                    Nome = "Pessoa A",
                    Cep = "12345000",
                    Rua = "Rua A",
                    Bairro = "Bairro A",
                    Numero = "100",
                    Complemento = "Casa 1",
                    Cidade = "Cidade A",
                    Estado = "SP",
                    IdFrota = 101,
                    IdPapelPessoa = 201,
                    Ativo = 1
                },
                new Pessoa
                {
                    Id = 2,
                    Cpf = "23456789012",
                    Nome = "Pessoa B",
                    Cep = "54321000",
                    Rua = "Rua B",
                    Bairro = "Bairro B",
                    Numero = "200",
                    Complemento = "Apartamento 2",
                    Cidade = "Cidade B",
                    Estado = "RJ",
                    IdFrota = 102,
                    IdPapelPessoa = 202,
                    Ativo = 1
                },
                new Pessoa
                {
                    Id = 3,
                    Cpf = "34567890123",
                    Nome = "Pessoa C",
                    Cep = "67890000",
                    Rua = "Rua C",
                    Bairro = "Bairro C",
                    Numero = "300",
                    Complemento = "Prédio 3",
                    Cidade = "Cidade C",
                    Estado = "MG",
                    IdFrota = 103,
                    IdPapelPessoa = 203,
                    Ativo = 0
                },
                new Pessoa
                {
                    Id = 4,
                    Cpf = "45678901234",
                    Nome = "Pessoa D",
                    Cep = "98765000",
                    Rua = "Rua D",
                    Bairro = "Bairro D",
                    Numero = "400",
                    Complemento = "Bloco 4",
                    Cidade = "Cidade D",
                    Estado = "BA",
                    IdFrota = 104,
                    IdPapelPessoa = 204,
                    Ativo = 1
                }
            };
        }
    }
}