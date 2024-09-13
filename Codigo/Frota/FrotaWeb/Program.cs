using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;
using Service;
using Microsoft.AspNetCore.Identity;
using FrotaWeb.Areas.Identity.Data;
using Microsoft.AspNetCore.Authentication.Cookies;

namespace FrotaWeb
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.
            builder.Services.AddControllersWithViews();


            builder.Services.AddTransient<IPessoaService, PessoaService>();
            builder.Services.AddTransient<IFrotaService, FrotaService>();
            builder.Services.AddTransient<IMarcaPecaInsumoService, MarcaPecaInsumoService>();
            builder.Services.AddTransient<IModeloVeiculoService, ModeloVeiculoService>();
            builder.Services.AddTransient<IPecaInsumoService, PecaInsumoService>();
            builder.Services.AddTransient<IVeiculoService, VeiculoService>();
            builder.Services.AddTransient<IAbastecimentoService, AbastecimentoService>();
            builder.Services.AddTransient<IFornecedorService, FornecedorService>();
            builder.Services.AddTransient<ISolicitacaomanutencaoService, SolicitacaomanutencaoService>();

            builder.Services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());

            builder.Services.AddDbContext<FrotaContext>(
                options => options.UseMySQL(builder.Configuration.GetConnectionString("FrotaDatabase")));

            builder.Services.AddDbContext<IdentityContext>(
				options => options.UseMySQL(builder.Configuration.GetConnectionString("FrotaDatabase")));

            builder.Services.AddDefaultIdentity<UsuarioIdentity>(options =>
            {
                // SignIn settings
                options.SignIn.RequireConfirmedAccount = true;
                options.SignIn.RequireConfirmedEmail = false;
                options.SignIn.RequireConfirmedPhoneNumber = false;

                // Password settings
                options.Password.RequireDigit = true;
                options.Password.RequireLowercase = true;
                options.Password.RequireNonAlphanumeric = false;
                options.Password.RequireUppercase = true;
                options.Password.RequiredLength = 6;

                // Default User settings.
                options.User.AllowedUserNameCharacters =
                        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._@+";
                options.User.RequireUniqueEmail = false;

                // Default Lockout settings
                options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(5);
                options.Lockout.MaxFailedAccessAttempts = 5;
                options.Lockout.AllowedForNewUsers = true;
            }).AddRoles<IdentityRole>()
               .AddEntityFrameworkStores<IdentityContext>();

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

