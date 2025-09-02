using Core;
using Core.Service;
using Service;
using System.Globalization;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Localization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Identity.UI.Services;
using FrotaWeb.Helpers;

namespace FrotaWeb
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.
            builder.Services.AddControllersWithViews();

            builder.Services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());
            builder.Services.AddTransient<IPessoaService, PessoaService>();
            builder.Services.AddTransient<IFrotaService, FrotaService>();
            builder.Services.AddTransient<IMarcaPecaInsumoService, MarcaPecaInsumoService>();
            builder.Services.AddTransient<IModeloVeiculoService, ModeloVeiculoService>();
            builder.Services.AddTransient<IPecaInsumoService, PecaInsumoService>();
            builder.Services.AddTransient<IVeiculoService, VeiculoService>();
            builder.Services.AddTransient<IAbastecimentoService, AbastecimentoService>();
            builder.Services.AddTransient<IFornecedorService, FornecedorService>();
            builder.Services.AddTransient<ISolicitacaoManutencaoService, SolicitacaoManutencaoService>();
            builder.Services.AddTransient<IMarcaVeiculoService, MarcaVeiculoService>();
            builder.Services.AddTransient<IManutencaoService, ManutencaoService>();
            builder.Services.AddTransient<IVistoriaService, VistoriaService>();
            builder.Services.AddTransient<IUnidadeAdministrativaService, UnidadeAdministrativaService>();
            builder.Services.AddTransient<IPercursoService, PercursoService>();
            builder.Services.AddTransient<IManutencaoPecaInsumoService, ManutencaoPecaInsumoService>();
            builder.Services.AddTransient<IEmailSender, EmailSender>();
            builder.Services.AddHttpContextAccessor();

            var connectionString = builder.Configuration.GetConnectionString("FrotaDatabase");
            if (string.IsNullOrEmpty(connectionString))
            {
                throw new InvalidOperationException("A string de conexão 'FrotaDatabase' não foi encontrada ou está vazia.");
            }
            builder.Services.AddDbContext<FrotaContext>(options => options.UseMySQL(connectionString));
            builder.Services.AddDbContext<IdentityContext>(options => options.UseMySQL(connectionString));


            builder.Services.AddDefaultIdentity<UsuarioIdentity>(options =>
            {
                // SignIn settings
                options.SignIn.RequireConfirmedAccount = true;
                options.SignIn.RequireConfirmedEmail = false;
                options.SignIn.RequireConfirmedPhoneNumber = false;

                // Password settings
                options.Password.RequireDigit = true;
                options.Password.RequireLowercase = true;
                options.Password.RequireNonAlphanumeric = true;
                options.Password.RequireUppercase = true;
                options.Password.RequiredLength = 8;

                // Default User settings.
                options.User.AllowedUserNameCharacters =
                        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._@+!^ ";
                options.User.RequireUniqueEmail = false;

                // Default Lockout settings
                options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(5);
                options.Lockout.MaxFailedAccessAttempts = 5;
                options.Lockout.AllowedForNewUsers = true;
            }).AddRoles<IdentityRole>()
            .AddEntityFrameworkStores<IdentityContext>();

            builder.Services.AddSession(options =>
            {
                options.IdleTimeout = TimeSpan.FromMinutes(30);
                options.Cookie.HttpOnly = true;
                options.Cookie.IsEssential = true;
            });

            builder.Services.ConfigureApplicationCookie(options =>
            {
                options.AccessDeniedPath = "/Identity/Account/AccessDenied";
                options.Cookie.Name = "FrotaWebCookie";
                options.Cookie.HttpOnly = true;
                options.ExpireTimeSpan = TimeSpan.FromMinutes(60);
                options.LoginPath = "/Identity/Account/Login";
                // ReturnUrlParameter requires 
                options.ReturnUrlParameter = CookieAuthenticationDefaults.ReturnUrlParameter;
                options.SlidingExpiration = true;
            });


            builder.Services.Configure<RequestLocalizationOptions>(options =>
            {
                var supportedCultures = new[] { new CultureInfo("pt-BR") };
                options.DefaultRequestCulture = new RequestCulture("pt-BR");
                options.SupportedCultures = supportedCultures;
                options.SupportedUICultures = supportedCultures;
            });

            var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (!app.Environment.IsDevelopment())
            {
                app.UseExceptionHandler("/Home/Error");
                // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
                app.UseHsts();
            }

            app.UseHttpsRedirection();
            app.UseStaticFiles();

            app.UseRouting();

            app.UseSession();

            app.UseAuthentication();
            app.UseAuthorization();

            app.MapRazorPages();

            app.MapControllerRoute(
                name: "default",
                pattern: "{controller=Home}/{action=Index}/{id?}");

            app.Run();
        }
    }
}
