namespace FrotaWeb.Models;

public class HomeViewModel
{
    public string NameUser { get; set; }
    public string UserType { get; set; }
    public int CoutLembretes { get; set; }
    public List<string> Lembretes { get; set; }
    public List<string> Urls { get; set; }

}
