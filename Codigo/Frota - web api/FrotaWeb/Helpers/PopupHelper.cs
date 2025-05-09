using Microsoft.AspNetCore.Mvc;

namespace FrotaWeb.Helpers;

public static class PopupHelper
{
    /// <summary>
    /// Define o popup a ser exibido referente a alguma operação feita (Tipos: success,error,warning)
    /// </summary>
    /// <param name="controller"></param>
    /// <param name="type">success,error,warning</param>
    /// <param name="title"></param>
    /// <param name="message"></param>
    public static void AddPopup(Controller controller, string type, string title, string message)
    {
        controller.TempData["PopupType"] = type; 
        controller.TempData["PopupTitle"] = title;
        controller.TempData["PopupMessage"] = message;
    }
}
