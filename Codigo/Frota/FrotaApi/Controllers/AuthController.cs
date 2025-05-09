using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Core;
using Core.Service;

namespace FrotaApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly UserManager<UsuarioIdentity> _userManager;
        private readonly SignInManager<UsuarioIdentity> _signInManager;
        private readonly IConfiguration _configuration;
        private readonly IPessoaService _pessoaService;

        public AuthController(
            UserManager<UsuarioIdentity> userManager,
            SignInManager<UsuarioIdentity> signInManager,
            IConfiguration configuration,
            IPessoaService pessoaService)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _configuration = configuration;
            _pessoaService = pessoaService;
        }

        public class LoginModel
        {
            public string UserName { get; set; }
            public string Password { get; set; }
        }

        public class LoginResponseModel
        {
            public string Token { get; set; }
            public string UserName { get; set; }
            public string Nome { get; set; }
            public string Role { get; set; }
            public bool Success { get; set; }
            public string Message { get; set; }
        }

        [HttpPost("login")]
        public async Task<ActionResult<LoginResponseModel>> Login([FromBody] LoginModel model)
        {
            var username = model.UserName.Trim().Replace(".", "").Replace("/", "").Replace("-", "");
            var user = await _userManager.FindByNameAsync(username);
            if (user == null)
            {
                return Ok(new LoginResponseModel
                {
                    Success = false,
                    Message = "Usuário ou senha inválidos"
                });
            }

            var result = await _signInManager.CheckPasswordSignInAsync(user, model.Password, false);
            if (!result.Succeeded)
            {
                return Ok(new LoginResponseModel
                {
                    Success = false,
                    Message = "Usuário ou senha inválidos"
                });
            }

            var roles = await _userManager.GetRolesAsync(user);
            string userRole = roles.FirstOrDefault() ?? "Usuario";

            // Verificar se o usuário é motorista
            if (userRole != "Motorista")
            {
                return Ok(new LoginResponseModel
                {
                    Success = false,
                    Message = "Acesso permitido apenas para motoristas"
                });
            }

            // Garantir que a chave JWT tenha pelo menos 256 bits (32 bytes)
            string jwtKey = _configuration["Jwt:Key"];
            if (string.IsNullOrEmpty(jwtKey) || jwtKey.Length < 32)
            {
                jwtKey = "Ch4v3S3cR3t4Fr0t4Publ1c42023@#$%&*123456789ABCDEFGHIJKLMN";
            }

            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.UTF8.GetBytes(jwtKey);
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new Claim[]
                {
                    new Claim(ClaimTypes.Name, user.UserName),
                    new Claim(ClaimTypes.NameIdentifier, user.Id),
                    new Claim(ClaimTypes.Role, userRole)
                }),
                Expires = DateTime.UtcNow.AddDays(7),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature),
                Issuer = _configuration["Jwt:Issuer"] ?? "FrotaPublicaApi",
                Audience = _configuration["Jwt:Audience"] ?? "FrotaPublicaApp"
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            var tokenString = tokenHandler.WriteToken(token);

            // Obter o ID e nome da pessoa pelo CPF/username
            string nome;
            try
            {
                uint idPessoa = _pessoaService.GetIdPessoaByCpf(username);
                nome = _pessoaService.GetNomePessoa(idPessoa) ?? "Usuário";
            }
            catch (Exception)
            {
                nome = "Usuário";
            }

            return Ok(new LoginResponseModel
            {
                Success = true,
                Token = tokenString,
                UserName = user.UserName,
                Nome = nome,
                Role = userRole
            });
        }
    }
} 