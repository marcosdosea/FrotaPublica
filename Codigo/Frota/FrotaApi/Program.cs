using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;
using Service;
using System.Globalization;
using Microsoft.AspNetCore.Localization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Identity.UI.Services;
using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;

namespace FrotaApi
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);
            // Add services to the container.
            builder.Services.AddControllers();
            // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();
            builder.Services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());
            builder.Services.AddHttpContextAccessor();

            // Registrando servi�os
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
            builder.Services.AddTransient<IEmailSender, DummyEmailSender>();  // Implementa��o mock para IEmailSender

            var connectionString = builder.Configuration.GetConnectionString("FrotaDatabase");
            if (string.IsNullOrEmpty(connectionString))
            {
                throw new InvalidOperationException("A string de conex�o 'FrotaDatabase' n�o foi encontrada ou est� vazia.");
            }

            builder.Services.AddDbContext<FrotaContext>(options => options.UseMySQL(connectionString));
            builder.Services.AddDbContext<IdentityContext>(options => options.UseMySQL(connectionString));

            // Configura��o do Identity
            builder.Services.AddIdentity<UsuarioIdentity, IdentityRole>(options =>
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
            })
            .AddEntityFrameworkStores<IdentityContext>()
            .AddDefaultTokenProviders();

            // Configurar autentica��o JWT
            builder.Services.AddAuthentication(options =>
            {
                options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
            })
            .AddJwtBearer(options =>
            {
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true,
                    ValidIssuer = builder.Configuration["Jwt:Issuer"],
                    ValidAudience = builder.Configuration["Jwt:Audience"],
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"] ?? "ChaveTemporariaParaDesenvolvimento123456789"))
                };
            });

            var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI();
            }

            app.UseHttpsRedirection();

            app.UseAuthentication();
            app.UseAuthorization();

            app.MapControllers();

            app.Run();
        }
    }

    // Implementa��o tempor�ria de IEmailSender para satisfazer a depend�ncia
    public class DummyEmailSender : IEmailSender
    {
        public Task SendEmailAsync(string email, string subject, string htmlMessage)
        {
            // Esta � uma implementa��o vazia para satisfazer a depend�ncia
            return Task.CompletedTask;
        }
    }
}