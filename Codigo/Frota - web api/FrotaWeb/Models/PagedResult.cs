namespace FrotaWeb.Models
{
    /// <summary>
    /// Classe genérica para paginação de resultados
    /// </summary>
    /// <typeparam name="T">Tipo do item na lista</typeparam>
    public class PagedResult<T>
    {
        /// <summary>
        /// Lista de itens da página atual
        /// </summary>
        public List<T> Items { get; set; } = new List<T>();

        /// <summary>
        /// Número da página atual (baseado em 0)
        /// </summary>
        public int CurrentPage { get; set; }

        /// <summary>
        /// Quantidade de itens por página
        /// </summary>
        public int ItemsPerPage { get; set; }

        /// <summary>
        /// Quantidade total de páginas
        /// </summary>
        public int TotalPages { get; set; }

        /// <summary>
        /// Quantidade total de itens
        /// </summary>
        public int TotalItems { get; set; }

        /// <summary>
        /// Construtor padrão
        /// </summary>
        public PagedResult()
        {
        }

        /// <summary>
        /// Construtor com parâmetros
        /// </summary>
        public PagedResult(List<T> items, int currentPage, int itemsPerPage, int totalItems)
        {
            Items = items;
            CurrentPage = currentPage;
            ItemsPerPage = itemsPerPage;
            TotalItems = totalItems;
            TotalPages = (int)Math.Ceiling((double)totalItems / itemsPerPage);
        }

        /// <summary>
        /// Verifica se há página anterior
        /// </summary>
        public bool HasPreviousPage => CurrentPage > 0;

        /// <summary>
        /// Verifica se há próxima página
        /// </summary>
        public bool HasNextPage => CurrentPage < TotalPages - 1;
    }
}

