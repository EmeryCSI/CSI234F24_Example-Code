using Microsoft.AspNetCore.Mvc;
using SalesAPI.Data;
using SalesAPI.Models;

namespace SalesAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProductController : ControllerBase
    {
        private readonly MockRepository _repository;

        public ProductController(MockRepository repository)
        {
            _repository = repository;
        }

        [HttpGet]
        public ActionResult<IEnumerable<Product>> GetProducts()
        {
            return Ok(_repository.GetAllProducts());
        }

        [HttpGet("{id}")]
        public ActionResult<Product> GetProduct(int id)
        {
            var product = _repository.GetAllProducts()
                .FirstOrDefault(p => p.Id == id);

            if (product == null)
            {
                return NotFound();
            }

            return Ok(product);
        }

        [HttpGet("price/{maxPrice}")]
        public ActionResult<IEnumerable<Product>> GetProductsByPrice(decimal maxPrice)
        {
            var products = _repository.GetAllProducts()
                .Where(p => p.Price <= maxPrice)
                .ToList();

            return Ok(products);
        }

        [HttpPost]
        public ActionResult<Product> CreateProduct(Product product)
        {
            var products = _repository.GetAllProducts();

            // Generate new ID
            product.Id = products.Max(p => p.Id) + 1;

            // Add the new product to our list
            products.Add(product);

            return CreatedAtAction(
                nameof(GetProduct),
                new { id = product.Id },
                product);
        }

        [HttpPut("{id}")]
        public IActionResult UpdateProduct(int id, Product product)
        {
            if (id != product.Id)
            {
                return BadRequest();
            }

            var products = _repository.GetAllProducts();
            var existingProduct = products.FirstOrDefault(p => p.Id == id);

            if (existingProduct == null)
            {
                return NotFound();
            }

            // Update all properties
            existingProduct.Name = product.Name;
            existingProduct.Description = product.Description;
            existingProduct.Price = product.Price;

            return NoContent();
        }

        [HttpDelete("{id}")]
        public IActionResult DeleteProduct(int id)
        {
            var products = _repository.GetAllProducts();
            var product = products.FirstOrDefault(p => p.Id == id);

            if (product == null)
            {
                return NotFound();
            }

            // Actually remove the product from the list
            products.Remove(product);

            return NoContent();
        }
    }
}