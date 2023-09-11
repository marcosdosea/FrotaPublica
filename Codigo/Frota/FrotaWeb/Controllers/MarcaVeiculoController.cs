using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;

namespace FrotaWeb.Controllers
{
    public class MarcaVeiculoController : Controller
    {
        // Esta é uma lista simulada de marcas de veículos, substitua por um banco de dados ou serviço real.
        private readonly List<string> _marcas = new List<string>
        {
            "Marca1", "Marca2", "Marca3"
        };

        // Ação para exibir a lista de marcas de veículos
        public IActionResult Index()
        {
            return View(_marcas);
        }

        // Ação para exibir o formulário de criação de uma nova marca de veículo
        public IActionResult Create()
        {
            return View();
        }

        // Ação para processar o formulário de criação
        [HttpPost]
        public IActionResult Create(string novaMarca)
        {
            if (!string.IsNullOrWhiteSpace(novaMarca))
            {
                _marcas.Add(novaMarca);
                return RedirectToAction("Index");
            }

            return View();
        }

        // Ação para exibir detalhes de uma marca de veículo
        public IActionResult Details(string nomeMarca)
        {
            var marca = _marcas.Find(m => m == nomeMarca);
            if (marca != null)
            {
                return View(marca);
            }

            return NotFound();
        }

        // Ação para exibir o formulário de edição de uma marca de veículo
        public IActionResult Edit(string nomeMarca)
        {
            var marca = _marcas.Find(m => m == nomeMarca);
            if (marca != null)
            {
                return View(marca);
            }

            return NotFound();
        }

        // Ação para processar o formulário de edição
        [HttpPost]
        public IActionResult Edit(string nomeMarca, string novaMarca)
        {
            var index = _marcas.FindIndex(m => m == nomeMarca);
            if (index != -1 && !string.IsNullOrWhiteSpace(novaMarca))
            {
                _marcas[index] = novaMarca;
                return RedirectToAction("Index");
            }

            return View(nomeMarca);
        }

        // Ação para excluir uma marca de veículo
        public IActionResult Delete(string nomeMarca)
        {
            var marca = _marcas.Find(m => m == nomeMarca);
            if (marca != null)
            {
                return View(marca);
            }

            return NotFound();
        }

        // Ação para confirmar a exclusão
        [HttpPost]
        public IActionResult DeleteConfirmed(string nomeMarca)
        {
            var marca = _marcas.Find(m => m == nomeMarca);
            if (marca != null)
            {
                _marcas.Remove(marca);
                return RedirectToAction("Index");
            }

            return NotFound();
        }
    }
}
