namespace Core.Service;

public interface IRotaService
{
    /// <summary>
    /// Obtém a rota de um percurso. Se não existir no banco, busca no Google Maps e salva.
    /// </summary>
    /// <param name="idPercurso">ID do percurso</param>
    /// <param name="originLat">Latitude de origem</param>
    /// <param name="originLng">Longitude de origem</param>
    /// <param name="destLat">Latitude de destino</param>
    /// <param name="destLng">Longitude de destino</param>
    /// <returns>JSON da rota do Google Maps Directions API</returns>
    Task<string> ObterRotaAsync(uint idPercurso, float originLat, float originLng, float destLat, float destLng);

    /// <summary>
    /// Remove todas as rotas associadas a um percurso
    /// </summary>
    /// <param name="idPercurso">ID do percurso</param>
    void RemoverRotasPorPercurso(uint idPercurso);
}

