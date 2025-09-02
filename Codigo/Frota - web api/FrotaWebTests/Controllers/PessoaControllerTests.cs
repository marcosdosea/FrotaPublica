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
            mockPessoaService.Setup(service => service.GetAll(It.IsAny<int>())).Returns(GetTestPessoas());
            mockPessoaService.Setup(service => service.Get(1)).Returns(GetTargetPessoa());
            mockPessoaService.Setup(service => service.Edit(It.IsAny<Pessoa>(), It.IsAny<int>())).Verifiable();
            mockPessoaService.Setup(service => service.Create(It.IsAny<Pessoa>(), It.IsAny<int>())).Verifiable();
            controller = new PessoaController(mockPessoaService.Object, mapper);
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
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(List<PessoaViewModel>));
            List<PessoaViewModel>? lista = (List<PessoaViewModel>)viewResult.ViewData.Model;
            Assert.IsTrue(lista.Count <= 13, "O número de itens na lista de pessoas deve ser menor ou igual a 13.");
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
            Assert.AreEqual("Guilherme Lima", pessoaViewModel.Nome);
            Assert.AreEqual("78766537070", pessoaViewModel.Cpf);
            Assert.AreEqual("16203585068", pessoaViewModel.Cep);
            Assert.AreEqual("Francisco Gomes", pessoaViewModel.Rua);
            Assert.AreEqual("Nova Cidade", pessoaViewModel.Bairro);
            Assert.AreEqual("12", pessoaViewModel.Numero);
            Assert.AreEqual(null, pessoaViewModel.Complemento);
            Assert.AreEqual("Itaboraí", pessoaViewModel.Cidade);
            Assert.AreEqual("RJ", pessoaViewModel.Estado);
            Assert.AreEqual((uint)1, pessoaViewModel.IdFrota);
            Assert.AreEqual((uint)1, pessoaViewModel.IdPapelPessoa);
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
            Assert.AreEqual("Guilherme Lima", pessoaViewModel.Nome);
            Assert.AreEqual("78766537070", pessoaViewModel.Cpf);
            Assert.AreEqual("16203585068", pessoaViewModel.Cep);
            Assert.AreEqual("Francisco Gomes", pessoaViewModel.Rua);
            Assert.AreEqual("Nova Cidade", pessoaViewModel.Bairro);
            Assert.AreEqual("12", pessoaViewModel.Numero);
            Assert.AreEqual(null, pessoaViewModel.Complemento);
            Assert.AreEqual("Itaboraí", pessoaViewModel.Cidade);
            Assert.AreEqual("RJ", pessoaViewModel.Estado);
            Assert.AreEqual((uint)1, pessoaViewModel.IdFrota);
            Assert.AreEqual((uint)1, pessoaViewModel.IdPapelPessoa);
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
            Assert.AreEqual("Guilherme Lima", pessoaViewModel.Nome);
            Assert.AreEqual("78766537070", pessoaViewModel.Cpf);
            Assert.AreEqual("16203585068", pessoaViewModel.Cep);
            Assert.AreEqual("Francisco Gomes", pessoaViewModel.Rua);
            Assert.AreEqual("Nova Cidade", pessoaViewModel.Bairro);
            Assert.AreEqual("12", pessoaViewModel.Numero);
            Assert.AreEqual(null, pessoaViewModel.Complemento);
            Assert.AreEqual("Itaboraí", pessoaViewModel.Cidade);
            Assert.AreEqual("RJ", pessoaViewModel.Estado);
            Assert.AreEqual((uint)1, pessoaViewModel.IdFrota);
            Assert.AreEqual((uint)1, pessoaViewModel.IdPapelPessoa);
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
                Cpf = "78766537070",
                Nome = "Guilherme Lima",
                Cep = "16203585068",
                Rua = "Francisco Gomes",
                Bairro = "Nova Cidade",
                Complemento = null,
                Numero = "12",
                Cidade = "Itaboraí",
                Estado = "RJ",
                IdFrota = 1,
                IdPapelPessoa = 1,
                Ativo = 1
            };
        }

        private Pessoa GetTargetPessoa()
        {
            return new Pessoa
            {
                Id = 1,
                Cpf = "78766537070",
                Nome = "Guilherme Lima",
                Cep = "16203585068",
                Rua = "Francisco Gomes",
                Bairro = "Nova Cidade",
                Complemento = null,
                Numero = "12",
                Cidade = "Itaboraí",
                Estado = "RJ",
                IdFrota = 1,
                IdPapelPessoa = 1,
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
                    Cpf = "78766537070",
                    Nome = "Guilherme Lima",
                    Cep = "16203585068",
                    Rua = "Francisco Gomes",
                    Bairro = "Nova Cidade",
                    Complemento = null,
                    Numero = "12",
                    Cidade = "Itaboraí",
                    Estado = "RJ",
                    IdFrota = 1,
                    IdPapelPessoa = 1,
                    Ativo = 1
                },
                new Pessoa
                {
                    Id = 2,
                    Cpf = "06130691025",
                    Nome = "Kauã Oliveira",
                    Cep = "79002800",
                    Rua = null,
                    Bairro = null,
                    Numero = null,
                    Complemento = null,
                    Cidade = null,
                    Estado = "MS",
                    IdFrota = 1,
                    IdPapelPessoa = 1,
                    Ativo = 1
                },
                new Pessoa
                {
                    Id = 3,
                    Cpf = "20551985054",
                    Nome = "Igor Andrade",
                    Cep = null,
                    Rua = null,
                    Bairro = null,
                    Numero = null,
                    Complemento = null,
                    Cidade = null,
                    Estado = "MG",
                    IdFrota = 2,
                    IdPapelPessoa = 1,
                    Ativo = 0
                },
                new Pessoa
                {
                    Id = 4,
                    Cpf = "95832085078",
                    Nome = "Marcos Santana",
                    Cep = null,
                    Rua = null,
                    Bairro = null,
                    Numero = null,
                    Complemento = null,
                    Cidade = "Aiquara",
                    Estado = "BA",
                    IdFrota = 3,
                    IdPapelPessoa = 1,
                    Ativo = 1
                }
            };
        }
    }
}