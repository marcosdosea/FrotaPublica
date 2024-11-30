using Microsoft.VisualStudio.TestTools.UnitTesting;
using FrotaWeb.Controllers;
using System;
using System.Collections.Generic;
using System.Linq;
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
    public class VeiculoPecaInsumoControllerTests
    {
        private static VeiculoPecaInsumoController? controller;

        [TestInitialize]
        public void Initialize()
        {
            // Arrange
            var mockVeiculoPecaInsumoService = new Mock<IVeiculoPecaInsumoService>();
            var mockVeiculoService = new Mock<IVeiculoService>();
            var mockPecaInsumo = new Mock<IPecaInsumoService>();

            IMapper mapper = new MapperConfiguration(cfg => cfg.AddProfile(new VeiculoPecaInsumoProfile())).CreateMapper();
            mockVeiculoPecaInsumoService.Setup(service => service.GetAll()).Returns(GetTestVeiculoPecaInsumos());
            mockVeiculoPecaInsumoService.Setup(service => service.Get(1, 101)).Returns(GetTargetVeiculoPecaInsumos());
            mockVeiculoPecaInsumoService.Setup(service => service.Edit(It.IsAny<Veiculopecainsumo>())).Verifiable();
            mockVeiculoPecaInsumoService.Setup(service => service.Create(It.IsAny<Veiculopecainsumo>())).Verifiable();
            controller = new VeiculoPecaInsumoController(mockVeiculoPecaInsumoService.Object, mapper, mockVeiculoService.Object, mockPecaInsumo.Object);
        }

        [TestMethod()]
        public void IndexTestValid()
        {
            // Act
            var result = controller!.Index();
            // Assert
            Assert.IsInstanceOfType(result, typeof(ViewResult));
            ViewResult viewResult = (ViewResult)result;
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(List<VeiculoPecaInsumoViewModel>));
            List<VeiculoPecaInsumoViewModel>? lista = (List<VeiculoPecaInsumoViewModel>)viewResult.ViewData.Model;
            Assert.AreEqual(3, lista.Count);
        }

        [TestMethod()]
        public void DetailsTest()
        {
            // Act
            var result = controller!.Details(1, 101);
            // Assert
            Assert.IsInstanceOfType(result, typeof (ViewResult));
            ViewResult viewResult = (ViewResult)result;
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(VeiculoPecaInsumoViewModel));
            VeiculoPecaInsumoViewModel veiculoPecaInsumoViewModel = (VeiculoPecaInsumoViewModel)viewResult.ViewData.Model;
            Assert.AreEqual(DateTime.Parse("31-12-2025"), veiculoPecaInsumoViewModel.DataFinalGarantia);
            Assert.AreEqual(50000, veiculoPecaInsumoViewModel.KmFinalGarantia);
            Assert.AreEqual(DateTime.Parse("15-06-2024"), veiculoPecaInsumoViewModel.DataProximaTroca);
            Assert.AreEqual(30000, veiculoPecaInsumoViewModel.KmProximaTroca);
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
            var result = controller!.Create(GetTargetVeiculoPecaInsumosViewModel());
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
            controller!.ModelState.AddModelError("IdPecaInsumo", "Campo requerido");
            // Act
            var result = controller!.Create(GetTargetVeiculoPecaInsumosViewModel());
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
            var result = controller!.Edit(1, 101);
            // Asser
            Assert.IsInstanceOfType(result, typeof(ViewResult));
            ViewResult viewResult = (ViewResult)result;
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(VeiculoPecaInsumoViewModel));
            VeiculoPecaInsumoViewModel veiculoPecaInsumoViewModel = (VeiculoPecaInsumoViewModel)viewResult.ViewData.Model;
            Assert.AreEqual(DateTime.Parse("31-12-2025"), veiculoPecaInsumoViewModel.DataFinalGarantia);
            Assert.AreEqual(50000, veiculoPecaInsumoViewModel.KmFinalGarantia);
            Assert.AreEqual(DateTime.Parse("15-06-2024"), veiculoPecaInsumoViewModel.DataProximaTroca);
            Assert.AreEqual(30000, veiculoPecaInsumoViewModel.KmProximaTroca);

        }

        [TestMethod()]
        public void EditTestPostValid()
        {
            // Act
            var result = controller!.Edit(GetTargetVeiculoPecaInsumosViewModel().IdVeiculo, GetTargetVeiculoPecaInsumosViewModel().IdPecaInsumo, GetTargetVeiculoPecaInsumosViewModel());
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
            var result = controller!.Delete(1, 101);
            // Assert
            Assert.IsInstanceOfType(result, typeof (ViewResult));
            ViewResult viewResult = (ViewResult)result;
            Assert.IsInstanceOfType(viewResult.ViewData.Model, typeof(VeiculoPecaInsumoViewModel));
            VeiculoPecaInsumoViewModel veiculoPecaInsumoViewModel = (VeiculoPecaInsumoViewModel)viewResult.ViewData.Model;
            Assert.AreEqual(DateTime.Parse("31-12-2025"), veiculoPecaInsumoViewModel.DataFinalGarantia);
            Assert.AreEqual(50000, veiculoPecaInsumoViewModel.KmFinalGarantia);
            Assert.AreEqual(DateTime.Parse("15-06-2024"), veiculoPecaInsumoViewModel.DataProximaTroca);
            Assert.AreEqual(30000, veiculoPecaInsumoViewModel.KmProximaTroca);
        }

        [TestMethod()]
        public void DeleteTestGetValid()
        {
            var reusult = controller!.Delete(1, 101, GetTargetVeiculoPecaInsumosViewModel());
            //Assert
            Assert.IsInstanceOfType(reusult, typeof(RedirectToActionResult));
            RedirectToActionResult redirectToActionResult = (RedirectToActionResult)reusult;
            Assert.IsNull(redirectToActionResult.ControllerName);
            Assert.AreEqual("Index", redirectToActionResult.ActionName);
        }

        private VeiculoPecaInsumoViewModel GetTargetVeiculoPecaInsumosViewModel()
        {
            return new VeiculoPecaInsumoViewModel
            {
                IdVeiculo = 1,
                IdPecaInsumo = 101,
                DataFinalGarantia = new DateTime(2025, 12, 31),
                KmFinalGarantia = 50000,
                DataProximaTroca = new DateTime(2024, 06, 15),
                KmProximaTroca = 30000
            };
        }

        private Veiculopecainsumo GetTargetVeiculoPecaInsumos()
        {
            return new Veiculopecainsumo
            {
                IdVeiculo = 1,
                IdPecaInsumo = 101,
                DataFinalGarantia = new DateTime(2025, 12, 31),
                KmFinalGarantia = 50000,
                DataProximaTroca = new DateTime(2024, 06, 15),
                KmProximaTroca = 30000
            };
        }

        private IEnumerable<Veiculopecainsumo> GetTestVeiculoPecaInsumos()
        {
            return new List<Veiculopecainsumo>
            {
                new Veiculopecainsumo
                {
                    IdVeiculo = 1,
                    IdPecaInsumo = 101,
                    DataFinalGarantia = new DateTime(2025, 12, 31),
                    KmFinalGarantia = 50000,
                    DataProximaTroca = new DateTime(2024, 06, 15),
                    KmProximaTroca = 30000
                },
                new Veiculopecainsumo
                {
                    IdVeiculo = 2,
                    IdPecaInsumo = 102,
                    DataFinalGarantia = new DateTime(2026, 01, 15),
                    KmFinalGarantia = 60000,
                    DataProximaTroca = new DateTime(2024, 09, 20),
                    KmProximaTroca = 35000
                },
                new Veiculopecainsumo
                {
                    IdVeiculo = 3,
                    IdPecaInsumo = 103,
                    DataFinalGarantia = new DateTime(2027, 05, 10),
                    KmFinalGarantia = 75000,
                    DataProximaTroca = new DateTime(2025, 02, 28),
                    KmProximaTroca = 45000
                }
            };
        }
    }
}