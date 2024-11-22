namespace Core.Service
{
	public interface IManutencaoPecaInsumoService
	{
		uint Create(Manutencaopecainsumo manutencaoPecaInsumo);
		void Edit(Manutencaopecainsumo manutencaoPecaInsumo);
		void Delete(uint id);
		Manutencaopecainsumo? Get(uint id);
		IEnumerable<Manutencaopecainsumo> GetAll();
	}
}
