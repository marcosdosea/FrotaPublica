﻿using AutoMapper;
using Core;
using Core.Service;
using FrotaWeb.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.UI.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.EntityFrameworkCore;
using Microsoft.VisualStudio.Web.CodeGenerators.Mvc.Templates.BlazorIdentity.Pages;
using Microsoft.VisualStudio.Web.CodeGenerators.Mvc.Templates.BlazorIdentity.Pages.Manage;
using System.Text;


namespace FrotaWeb.Controllers
{

    [Authorize(Roles = "Gestor")]
    public class PessoaController : Controller
    {
        private readonly IPessoaService pessoaService;
        private readonly IMapper mapper;
        private readonly UserManager<UsuarioIdentity> userManager;


        public PessoaController(IPessoaService pessoaService, IMapper mapper)
        {
            this.pessoaService = pessoaService;
            this.mapper = mapper;
        }

        // GET: PessoaController
        [Route("Pessoa/Index/{page}")]
        [Route("Pessoa/{page}")]
        [Route("Pessoa")]
        public ActionResult Index([FromRoute] int page = 0, string search = null, string filterBy = "Nome")
        {
            int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);
            int length = 13;
            int totalResultados;
            var listaPessoas = pessoaService.GetPaged(idFrota, page, length, out totalResultados, search, filterBy).ToList();

            var totalPessoas = pessoaService.GetAll(idFrota).Count();
            var totalPages = (int)Math.Ceiling((double)totalResultados / length);

            ViewBag.CurrentPage = page;
            ViewBag.TotalPages = totalPages;
            ViewBag.Search = search;
            ViewBag.FilterBy = filterBy;
            ViewBag.Resultados = listaPessoas.Count();

            var listaPessoasModel = mapper.Map<List<PessoaViewModel>>(listaPessoas);
            foreach (var item in listaPessoasModel)
            {
                item.StatusAtivo = item.Ativo == 1 ? "Ativo" : "Desativado";
            }
            return View(listaPessoasModel);
        }

        // GET: PessoaController/Details/5
        public ActionResult Details(uint id)
        {
            Pessoa pessoa = pessoaService.Get(id);
            PessoaViewModel pessoaModel = mapper.Map<PessoaViewModel>(pessoa);
            return View(pessoaModel);
        }

        // GET: PessoaController/Create
        [Route("Pessoa/Create")]
        public ActionResult Create()
        {
            return View();
        }

        // POST: PessoaController/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("Pessoa/Create")]
        public async Task<ActionResult> Create(PessoaViewModel pessoaModel, [FromServices] IEmailSender emailSender)
        {
            if (ModelState.IsValid)
            {
                int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);
                var pessoa = mapper.Map<Pessoa>(pessoaModel);
                try
                {
                    pessoaService.Create(pessoa, idFrota);
                    await pessoaService.CreateAsync(pessoa, idFrota, pessoaService.FindPapelPessoaById(pessoaModel.IdPapelPessoa));
                    var existingUser = await pessoaService.GetUserByCpfAsync(pessoa.Cpf);
                    var confirmationToken = await pessoaService.GenerateEmailConfirmationTokenAsync(existingUser);
                    var callbackUrl = Url.Action(
                        nameof(ConfirmEmail),
                        "Account",
                        new { userId = existingUser.Id, token = confirmationToken },
                        protocol: Request.Scheme
                    );
                    await emailSender.SendEmailAsync( pessoa.Email, pessoa.Nome, callbackUrl);
                } catch (ServiceException exception)
                {
                    ModelState.AddModelError(exception.AtributoError!, "Esse dado já foi utilizado em um cadastro existente");
                    return View(pessoaModel);
                }
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: PessoaController/Edit/5
        public ActionResult Edit(uint id)
        {
            Pessoa pessoa = pessoaService.Get(id);
            PessoaViewModel pessoaModel = mapper.Map<PessoaViewModel>(pessoa);
            return View(pessoaModel);
        }

        // POST: PessoaController/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(uint id, PessoaViewModel pessoaModel)
        {
            if (ModelState.IsValid)
            {
                int.TryParse(User.Claims.FirstOrDefault(claim => claim.Type == "FrotaId").Value, out int idFrota);
                var pessoa = mapper.Map<Pessoa>(pessoaModel);
                try
                {
                    pessoaService.Edit(pessoa, idFrota);
                }
                catch (ServiceException exception)
                {
                    ModelState.AddModelError(exception.AtributoError!, "Esse dado já foi utilizado em um cadastro existente");
                    return View(pessoaModel);
                }
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: PessoaController/Delete/5
        public ActionResult Delete(uint id)
        {
            Pessoa pessoa = pessoaService.Get(id);
            PessoaViewModel pessoaModel = mapper.Map<PessoaViewModel>(pessoa);
            return View(pessoaModel);
        }

        // POST: PessoaController/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(uint id, PessoaViewModel pessoaModel)
        {
            try
            {
                pessoaService.Delete(id);
            }
            catch (ServiceException exception)
            {
                ModelState.AddModelError(exception.AtributoError!, "Não foi possível excluir o registro do banco");
            }
            return RedirectToAction(nameof(Index));
        }


       
    }
}
