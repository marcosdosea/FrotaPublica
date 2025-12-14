using Core;
using Core.Service;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using System.Text.Json;

namespace Service;

public class RotaService : IRotaService
{
    private readonly FrotaContext context;
    private readonly IConfiguration configuration;
    private readonly HttpClient httpClient;
    private readonly string apiKey;

    public RotaService(FrotaContext context, IConfiguration configuration, HttpClient httpClient)
    {
        this.context = context;
        this.configuration = configuration;
        this.httpClient = httpClient;
        this.apiKey = configuration["GoogleMaps:ApiKey"] ?? string.Empty;
    }

    /// <summary>
    /// Obtém a rota de um percurso. Se não existir no banco, busca no Google Maps e salva.
    /// </summary>
    public async Task<string> ObterRotaAsync(uint idPercurso, float originLat, float originLng, float destLat, float destLng)
    {
        // Verificar se já existe rota salva no banco
        var rotaExistente = await context.Rotas
            .FirstOrDefaultAsync(r => r.IdPercurso == idPercurso);

        if (rotaExistente != null)
        {
            return rotaExistente.RouteJson;
        }

        // Se não existir, buscar no Google Maps
        try
        {
            var url = $"https://maps.googleapis.com/maps/api/directions/json?" +
                     $"origin={originLat},{originLng}&" +
                     $"destination={destLat},{destLng}&" +
                     $"key={apiKey}&" +
                     $"language=pt-BR";

            var response = await httpClient.GetAsync(url);
            response.EnsureSuccessStatusCode();

            var routeJson = await response.Content.ReadAsStringAsync();

            // Verificar se a resposta é válida
            var jsonDoc = JsonDocument.Parse(routeJson);
            if (jsonDoc.RootElement.TryGetProperty("status", out var statusElement))
            {
                var status = statusElement.GetString();
                if (status == "OK" && jsonDoc.RootElement.TryGetProperty("routes", out var routes) && routes.GetArrayLength() > 0)
                {
                    // Salvar no banco
                    var rota = new Rota
                    {
                        IdPercurso = idPercurso,
                        RouteJson = routeJson,
                        DataCriacao = DateTime.Now
                    };

                    context.Rotas.Add(rota);
                    await context.SaveChangesAsync();

                    return routeJson;
                }
            }

            // Se a resposta não for válida, retornar mesmo assim (pode ser usado para fallback)
            return routeJson;
        }
        catch (Exception ex)
        {
            throw new ServiceException($"Erro ao obter rota do Google Maps: {ex.Message}", ex);
        }
    }

    /// <summary>
    /// Remove todas as rotas associadas a um percurso
    /// </summary>
    public void RemoverRotasPorPercurso(uint idPercurso)
    {
        try
        {
            var rotas = context.Rotas.Where(r => r.IdPercurso == idPercurso).ToList();
            if (rotas.Any())
            {
                context.Rotas.RemoveRange(rotas);
                context.SaveChanges();
            }
        }
        catch (Exception ex)
        {
            throw new ServiceException($"Erro ao remover rotas do percurso: {ex.Message}", ex);
        }
    }
}

