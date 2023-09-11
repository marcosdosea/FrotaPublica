using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Core;
using Core.Service;

namespace Service
{
	public class ManutencaoVeiculoController : Controller
	{
		private readonly IManutencaoService _manutencaoService;

		public ManutencaoVeiculoController(IManutencaoService manutencaoService)
		{
			_manutencaoService = manutencaoService;
		}

		public IActionResult Index()
		{
			var manutencoes = _manutencaoService.ListarManutencoes();
			return View(manutencoes);
		}

		public IActionResult Detalhes(int id)
		{
			var manutencao = _manutencaoService.ObterManutencaoPorId(id);
			return View(manutencao);
		}

		public IActionResult Adicionar()
		{
			return View();
		}

		[HttpPost]
		public IActionResult Adicionar(ManutencaoVeiculo manutencao)
		{
			if (ModelState.IsValid)
			{
				_manutencaoService.AdicionarManutencao(manutencao);
				return RedirectToAction("Index");
			}
			return View(manutencao);
		}

		public IActionResult Editar(int id)
		{
			var manutencao = _manutencaoService.ObterManutencaoPorId(id);
			return View(manutencao);
		}

		[HttpPost]
		public IActionResult Editar(ManutencaoVeiculo manutencao)
		{
			if (ModelState.IsValid)
			{
				_manutencaoService.AtualizarManutencao(manutencao);
				return RedirectToAction("Index");
			}
			return View(manutencao);
		}

		public IActionResult Excluir(int id)
		{
			_manutencaoService.ExcluirManutencao(id);
			return RedirectToAction("Index");
		}
	}

}