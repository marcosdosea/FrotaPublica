using Core.Service;

namespace Service
{
    internal interface IUnidadeAdministrativaRepository
    {
        Task<UnidadeAdministrativa> AddAsync(UnidadeAdministrativa unidadeAdministrativa);
        Task DeleteAsync(object existingUnidadeAdministrativa);
        Task<IEnumerable<UnidadeAdministrativa>> GetAllAsync();
        Task GetByIdAsync(int id);
        Task<UnidadeAdministrativa> UpdateAsync(object existingUnidadeAdministrativa);
    }
}