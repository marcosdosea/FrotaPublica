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
using Microsoft.OpenApi.Models;

namespace FrotaApi
{
    public class Program
    {
        private const string DEFAULT_JWT_KEY = "Ch4v3S3cR3t4Fr0t4Publ1c42023@#$%&*123456789ABCDEFGHIJKLMN";

        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);
            // Add services to the container.
            builder.Services.AddControllers();
            // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
            builder.Services.AddEndpointsApiExplorer();
            
            // Configuração do Swagger para suportar JWT
            builder.Services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new OpenApiInfo { Title = "Frota API", Version = "v1" });
                
                // Configuração para usar Bearer token no Swagger UI
                c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
                {
                    Description = "JWT Authorization header using the Bearer scheme. Example: \"Authorization: Bearer {token}\"",
                    Name = "Authorization",
                    In = ParameterLocation.Header,
                    Type = SecuritySchemeType.ApiKey,
                    Scheme = "Bearer"
                });

                c.AddSecurityRequirement(new OpenApiSecurityRequirement
                {
                    {
                        new OpenApiSecurityScheme
                        {
                            Reference = new OpenApiReference
                            {
                                Type = ReferenceType.SecurityScheme,
                                Id = "Bearer"
                            }
                        },
                        Array.Empty<string>()
                    }
                });
            });
            
            builder.Services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());
            builder.Services.AddHttpContextAccessor();

            // Registrando serviços
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
            builder.Services.AddTransient<IEmailSender, DummyEmailSender>();  // Implementação mock para IEmailSender

            var connectionString = builder.Configuration.GetConnectionString("FrotaDatabase");
            if (string.IsNullOrEmpty(connectionString))
            {
                throw new InvalidOperationException("A string de conexão 'FrotaDatabase' não foi encontrada ou está vazia.");
            }

            builder.Services.AddDbContext<FrotaContext>(options => options.UseMySQL(connectionString));
            builder.Services.AddDbContext<IdentityContext>(options => options.UseMySQL(connectionString));

            // Configuração do Identity
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

            // Garantir que a chave JWT tenha pelo menos 256 bits (32 bytes)
            string jwtKey = builder.Configuration["Jwt:Key"] ?? DEFAULT_JWT_KEY;
            if (jwtKey.Length < 32)
            {
                jwtKey = DEFAULT_JWT_KEY;
            }

            // Configurar autenticação JWT
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
                    ValidIssuer = builder.Configuration["Jwt:Issuer"] ?? "FrotaPublicaApi",
                    ValidAudience = builder.Configuration["Jwt:Audience"] ?? "FrotaPublicaApp",
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
                };
            });

            var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment() || app.Environment.IsProduction())
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

    // Implementação temporária de IEmailSender para satisfazer a dependência
    public class DummyEmailSender : IEmailSender
    {
        public Task SendEmailAsync(string email, string subject, string htmlMessage)
        {
            // Esta é uma implementação vazia para satisfazer a dependência
            return Task.CompletedTask;
        }
    }
}