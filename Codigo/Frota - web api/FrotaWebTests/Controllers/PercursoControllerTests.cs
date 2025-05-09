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
    public class PercursoControllerTests
    {
        private static PercursoController? percursoController;

        [TestInitialize]
        public void Initialize()
        {
            // Arrange
            var mockPercursoService = new Mock<IPercursoService>();
            IMapper mapper = new MapperConfiguration(cfg =>
                cfg.AddProfile(new PercursoProfile())).CreateMapper();
            mockPercursoService.Setup(service => service.Edit(It.IsAny<Percurso>())).Verifiable();
            mockPercursoService.Setup(service => service.Create(It.IsAny<Percurso>())).Verifiable();
            mockPercursoService.Setup(service => service.Delete(It.IsAny<uint>()));
            mockPercursoService.Setup(service => service.Get(1)).Returns(GetTestPercurso());
            mockPercursoService.Setup(service => service.GetAll()).Returns(GetTestPercursos());
            percursoController = new PercursoController(mockPercursoService.Object, mapper);
        }

        [TestMethod()]
        public void IndexTestValid()
        {
            // Act
            var result = percursoController!.Index();
            // Assert
            Assert.IsInstanceOfType(result, typeof(ViewResult));
            ViewResult viewResult = (ViewResult)result;
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(List<PercursoViewModel>));
            List<PercursoViewModel> listaPercursoModel = (List<PercursoViewModel>)viewResult.ViewData.Model;
            Assert.AreEqual(3, listaPercursoModel.Count);

        }

        [TestMethod()]
        public void DetailsTestValid()
        {
            // Act
            var result = percursoController!.Details(1);
            // Assert
            Assert.IsInstanceOfType(result, typeof(ViewResult));
            ViewResult viewResult = (ViewResult)result;
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(PercursoViewModel));
            PercursoViewModel percursoModel = (PercursoViewModel)viewResult.ViewData.Model;
            Assert.AreEqual("São Paulo", percursoModel.LocalPartida);
            Assert.AreEqual(101m, percursoModel.IdVeiculo);
            Assert.AreEqual(1001m, percursoModel.IdPessoa);
            Assert.AreEqual("São Paulo", percursoModel.LocalPartida);
            Assert.AreEqual(-23.5505f, percursoModel.LatitudePartida);
            Assert.AreEqual(-46.6333f, percursoModel.LongitudePartida);
            Assert.AreEqual("Rio de Janeiro", percursoModel.LocalChegada);
            Assert.AreEqual(-22.9068f, percursoModel.LatitudeChegada);
            Assert.AreEqual(-43.1729f, percursoModel.LongitudeChegada);
            Assert.AreEqual(50000, percursoModel.OdometroInicial);
            Assert.AreEqual(50300, percursoModel.OdometroFinal);
            Assert.AreEqual("Entrega de mercadoria", percursoModel.Motivo);
        }

        [TestMethod()]
        public void CreateTestGetValid()
        {
            // Act
            var result = percursoController!.Create();
            // Assert
            Assert.IsInstanceOfType(result, typeof(ViewResult));
        }

        [TestMethod()]
        public void CreateTestValid()
        {
            // Act
            var result = percursoController!.Create(GetTargetPercurso());
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
            percursoController!.ModelState.AddModelError("error", "error");
            // Act
            var result = percursoController!.Create(GetTargetPercurso());
            // Assert
            Assert.AreEqual(1, percursoController.ModelState.ErrorCount);
            Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
            RedirectToActionResult redirectToActionResult = (RedirectToActionResult)result;
            Assert.IsNull(redirectToActionResult.ControllerName);
            Assert.AreEqual("Index", redirectToActionResult.ActionName);
        }


        [TestMethod()]
        public void EditTestGetValid()
        {
            // Act
            var result = percursoController!.Edit(1);
            // Assert
            Assert.IsInstanceOfType(result, typeof(ViewResult));
            ViewResult viewResult = (ViewResult)result;
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(PercursoViewModel));
            PercursoViewModel percursoModel = (PercursoViewModel)viewResult.ViewData.Model;
            Assert.AreEqual("São Paulo", percursoModel.LocalPartida);
            Assert.AreEqual(101m, percursoModel.IdVeiculo);
            Assert.AreEqual(1001m, percursoModel.IdPessoa);
            Assert.AreEqual("São Paulo", percursoModel.LocalPartida);
            Assert.AreEqual(-23.5505f, percursoModel.LatitudePartida);
            Assert.AreEqual(-46.6333f, percursoModel.LongitudePartida);
            Assert.AreEqual("Rio de Janeiro", percursoModel.LocalChegada);
            Assert.AreEqual(-22.9068f, percursoModel.LatitudeChegada);
            Assert.AreEqual(-43.1729f, percursoModel.LongitudeChegada);
            Assert.AreEqual(50000, percursoModel.OdometroInicial);
            Assert.AreEqual(50300, percursoModel.OdometroFinal);
            Assert.AreEqual("Entrega de mercadoria", percursoModel.Motivo);
        }

        [TestMethod()]
        public void EditTestPostValid()
        {
            // Act
            var result = percursoController!.Edit(GetTargetPercurso().Id, GetTargetPercurso());
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
            var result = percursoController!.Delete(1);
            // Assert
            Assert.IsInstanceOfType(result, typeof(ViewResult));
            ViewResult viewResult = (ViewResult)result;
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(PercursoViewModel));
            PercursoViewModel percursoModel = (PercursoViewModel)viewResult.ViewData.Model;
            Assert.AreEqual("São Paulo", percursoModel.LocalPartida);
            Assert.AreEqual(101m, percursoModel.IdVeiculo);
            Assert.AreEqual(1001m, percursoModel.IdPessoa);
            Assert.AreEqual("São Paulo", percursoModel.LocalPartida);
            Assert.AreEqual(-23.5505f, percursoModel.LatitudePartida);
            Assert.AreEqual(-46.6333f, percursoModel.LongitudePartida);
            Assert.AreEqual("Rio de Janeiro", percursoModel.LocalChegada);
            Assert.AreEqual(-22.9068f, percursoModel.LatitudeChegada);
            Assert.AreEqual(-43.1729f, percursoModel.LongitudeChegada);
            Assert.AreEqual(50000, percursoModel.OdometroInicial);
            Assert.AreEqual(50300, percursoModel.OdometroFinal);
            Assert.AreEqual("Entrega de mercadoria", percursoModel.Motivo);
        }

        [TestMethod()]
        public void DeleteTestGetValid()
        {
            // Act
            var result = percursoController!.Delete(GetTargetPercurso().Id, GetTargetPercurso());
            // Assert
            Assert.IsInstanceOfType(result, typeof(RedirectToActionResult));
            RedirectToActionResult redirectToActionResult = (RedirectToActionResult)result;
            Assert.IsNull(redirectToActionResult.ControllerName);
            Assert.AreEqual("Index", redirectToActionResult.ActionName);
        }

        private PercursoViewModel GetTargetPercurso()
        {
            return new PercursoViewModel
            {
                Id = 1,
                IdVeiculo = 101,
                IdPessoa = 1001,
                DataHoraSaida = new DateTime(2024, 11, 1, 8, 0, 0),
                DataHoraRetorno = new DateTime(2024, 11, 1, 18, 0, 0),
                LocalPartida = "São Paulo",
                LatitudePartida = -23.5505f,
                LongitudePartida = -46.6333f,
                LocalChegada = "Rio de Janeiro",
                LatitudeChegada = -22.9068f,
                LongitudeChegada = -43.1729f,
                OdometroInicial = 50000,
                OdometroFinal = 50300,
                Motivo = "Entrega de mercadoria"
            };
        }

        private IEnumerable<Percurso> GetTestPercursos()
        {
            return new List<Percurso>
            {
                new Percurso
                {
                    Id = 1,
                    IdVeiculo = 101,
                    IdPessoa = 1001,
                    DataHoraSaida = new DateTime(2024, 11, 1, 8, 0, 0),
                    DataHoraRetorno = new DateTime(2024, 11, 1, 18, 0, 0),
                    LocalPartida = "São Paulo",
                    LatitudePartida = -23.5505f,
                    LongitudePartida = -46.6333f,
                    LocalChegada = "Rio de Janeiro",
                    LatitudeChegada = -22.9068f,
                    LongitudeChegada = -43.1729f,
                    OdometroInicial = 50000,
                    OdometroFinal = 50300,
                    Motivo = "Entrega de mercadoria"
                },
                new Percurso
                {
                    Id = 2,
                    IdVeiculo = 102,
                    IdPessoa = 1002,
                    DataHoraSaida = new DateTime(2024, 11, 2, 9, 0, 0),
                    DataHoraRetorno = new DateTime(2024, 11, 2, 17, 30, 0),
                    LocalPartida = "Belo Horizonte",
                    LatitudePartida = -19.9167f,
                    LongitudePartida = -43.9345f,
                    LocalChegada = "Vitória",
                    LatitudeChegada = -20.3155f,
                    LongitudeChegada = -40.3128f,
                    OdometroInicial = 25000,
                    OdometroFinal = 25250,
                    Motivo = "Reunião com clientes"
                },
                new Percurso
                {
                    Id = 3,
                    IdVeiculo = 103,
                    IdPessoa = 1003,
                    DataHoraSaida = new DateTime(2024, 11, 3, 7, 30, 0),
                    DataHoraRetorno = new DateTime(2024, 11, 3, 20, 15, 0),
                    LocalPartida = "Curitiba",
                    LatitudePartida = -25.4294f,
                    LongitudePartida = -49.2719f,
                    LocalChegada = "Florianópolis",
                    LatitudeChegada = -27.5954f,
                    LongitudeChegada = -48.5480f,
                    OdometroInicial = 18000,
                    OdometroFinal = 18350,
                    Motivo = "Entrega de documentos"
                }
            };
        }

        private Percurso GetTestPercurso()
        {
            return new Percurso
            {
                Id = 1,
                IdVeiculo = 101,
                IdPessoa = 1001,
                DataHoraSaida = new DateTime(2024, 11, 1, 8, 0, 0),
                DataHoraRetorno = new DateTime(2024, 11, 1, 18, 0, 0),
                LocalPartida = "São Paulo",
                LatitudePartida = -23.5505f,
                LongitudePartida = -46.6333f,
                LocalChegada = "Rio de Janeiro",
                LatitudeChegada = -22.9068f,
                LongitudeChegada = -43.1729f,
                OdometroInicial = 50000,
                OdometroFinal = 50300,
                Motivo = "Entrega de mercadoria"
            };
        }
    }
}