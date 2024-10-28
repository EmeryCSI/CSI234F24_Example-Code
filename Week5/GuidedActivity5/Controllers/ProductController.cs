using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using GuidedActivity5.Models;

namespace GuidedActivity5.Controllers
{
    //
    // - /api/products
    [Route("api/[controller]")]
    [ApiController]
    public class ProductsController : ControllerBase
    {
        private readonly GA5Context _context;

        // Constructor: Dependency injection of GA5Context
        public ProductsController(GA5Context context)
        {
            _context = context;
        }

        // GET: api/Products
        // Retrieves all products from the database
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Product>>> GetProducts()
        {
            // Use AsNoTracking for read-only operations to improve performance
            return await _context.Products.ToListAsync();
        }

        // GET: api/Products/5
        // Retrieves a specific product by id
        [HttpGet("{id}")]
        public async Task<ActionResult<Product>> GetProduct(int id)
        {
            var product = await _context.Products.FindAsync(id);

            if (product == null)
            {
                return NotFound(); // Returns 404 if product is not found
            }

            return product;
        }

        // POST: api/Products
        // Creates a new product
        [HttpPost]
        public async Task<ActionResult<Product>> PostProduct(Product product)
        {
            _context.Products.Add(product);
            await _context.SaveChangesAsync();

            // Returns 201 Created status code along with the created product
            return CreatedAtAction(nameof(GetProduct), new { id = product.ProductId }, product);
        }

        // PUT: api/Products/5
        // Updates an existing product
        [HttpPut("{id}")]
        public async Task<IActionResult> PutProduct(int id, Product product)
        {
            if (id != product.ProductId)
            {
                return BadRequest(); // Returns 400 if ids don't match
            }

            _context.Entry(product).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!ProductExists(id))
                {
                    return NotFound(); // Returns 404 if product doesn't exist
                }
                else
                {
                    throw;
                }
            }

            return NoContent(); // Returns 204 No Content if update is successful
        }

        // DELETE: api/Products/5
        // Deletes a specific product
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteProduct(int id)
        {
            var product = await _context.Products.FindAsync(id);
            if (product == null)
            {
                return NotFound(); // Returns 404 if product is not found
            }

            _context.Products.Remove(product);
            await _context.SaveChangesAsync();

            return NoContent(); // Returns 204 No Content if deletion is successful
        }

        // Helper method to check if a product exists
        private bool ProductExists(int id)
        {
            return _context.Products.Any(e => e.ProductId == id);
        }
    }
}