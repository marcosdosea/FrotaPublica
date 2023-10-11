using Microsoft.AspNetCore.Mvc;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace FrotaApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PecaInsumoController : ControllerBase
    {
        // GET: api/<PecaInsumoController>
        [HttpGet]
        public IEnumerable<string> Get()
        {
            return new string[] { "value1", "value2" };
        }

        // GET api/<PecaInsumoController>/5
        [HttpGet("{id}")]
        public string Get(int id)
        {
            return "value";
        }

        // POST api/<PecaInsumoController>
        [HttpPost]
        public void Post([FromBody] string value)
        {
        }

        // PUT api/<PecaInsumoController>/5
        [HttpPut("{id}")]
        public void Put(int id, [FromBody] string value)
        {
        }

        // DELETE api/<PecaInsumoController>/5
        [HttpDelete("{id}")]
        public void Delete(int id)
        {
        }
    }
}
