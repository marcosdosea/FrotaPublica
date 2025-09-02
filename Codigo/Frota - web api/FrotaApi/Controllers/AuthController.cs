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

        public class RefreshTokenModel
        {
            public string Token { get; set; }
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

            var result = await _signInManager.CheckPasswordSignInAsync(user, model.Password.Trim(), false);
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

            var tokenString = GenerateJwtToken(user, userRole);

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

        [HttpPost("refresh-token")]
        public async Task<ActionResult<LoginResponseModel>> RefreshToken([FromBody] RefreshTokenModel model)
        {
            if (string.IsNullOrEmpty(model.Token))
            {
                return BadRequest(new { message = "Token é obrigatório" });
            }

            // Garantir que a chave JWT tenha pelo menos 256 bits (32 bytes)
            string jwtKey = _configuration["Jwt:Key"];
            if (string.IsNullOrEmpty(jwtKey) || jwtKey.Length < 32)
            {
                jwtKey = "Ch4v3S3cR3t4Fr0t4Publ1c42023@#$%&*123456789ABCDEFGHIJKLMN";
            }

            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.UTF8.GetBytes(jwtKey);

            try
            {
                // Configurar validação do token
                var validationParameters = new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(key),
                    ValidateIssuer = true,
                    ValidIssuer = _configuration["Jwt:Issuer"] ?? "FrotaPublicaApi",
                    ValidateAudience = true,
                    ValidAudience = _configuration["Jwt:Audience"] ?? "FrotaPublicaApp",
                    ValidateLifetime = false // Importante: não validar o tempo de vida para refresh token
                };

                // Verificar se o token é válido (ignorando a expiração)
                var claimsPrincipal = tokenHandler.ValidateToken(model.Token, validationParameters, out var securityToken);
                
                // Verificar se o token é JWT
                if (!(securityToken is JwtSecurityToken jwtSecurityToken) || 
                    !jwtSecurityToken.Header.Alg.Equals(SecurityAlgorithms.HmacSha256, StringComparison.InvariantCultureIgnoreCase))
                {
                    return Unauthorized(new { message = "Token inválido" });
                }

                // Extrair identificação do usuário
                var userNameClaim = claimsPrincipal.FindFirst(ClaimTypes.Name);
                if (userNameClaim == null)
                {
                    return Unauthorized(new { message = "Token inválido" });
                }

                // Buscar usuário pelo username
                var user = await _userManager.FindByNameAsync(userNameClaim.Value);
                if (user == null)
                {
                    return Unauthorized(new { message = "Usuário não encontrado" });
                }

                // Verificar a função do usuário
                var roles = await _userManager.GetRolesAsync(user);
                string userRole = roles.FirstOrDefault() ?? "Usuario";

                // Gerar novo token
                var newTokenString = GenerateJwtToken(user, userRole);

                // Obter o nome da pessoa
                string nome;
                try
                {
                    uint idPessoa = _pessoaService.GetIdPessoaByCpf(user.UserName);
                    nome = _pessoaService.GetNomePessoa(idPessoa) ?? "Usuário";
                }
                catch (Exception)
                {
                    nome = "Usuário";
                }

                return Ok(new LoginResponseModel
                {
                    Success = true,
                    Token = newTokenString,
                    UserName = user.UserName,
                    Nome = nome,
                    Role = userRole
                });
            }
            catch (Exception ex)
            {
                return Unauthorized(new { message = "Falha ao validar o token", error = ex.Message });
            }
        }

        private string GenerateJwtToken(UsuarioIdentity user, string role)
        {
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
                    new Claim(ClaimTypes.Role, role)
                }),
                Expires = DateTime.UtcNow.AddDays(7),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature),
                Issuer = _configuration["Jwt:Issuer"] ?? "FrotaPublicaApi",
                Audience = _configuration["Jwt:Audience"] ?? "FrotaPublicaApp"
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }
    }
} 