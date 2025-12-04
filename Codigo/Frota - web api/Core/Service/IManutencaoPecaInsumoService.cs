namespace Core.Service
{
	public interface IManutencaoPecaInsumoService
	{
		uint Create(Manutencaopecainsumo manutencaoPecaInsumo);
		void Edit(Manutencaopecainsumo manutencaoPecaInsumo);
		void Delete(uint idManutencao, uint idPecaInsumo);
		Manutencaopecainsumo? Get(uint idManutencao, uint idPecaInsumo);
		IEnumerable<Manutencaopecainsumo> GetAll();
	}
}
