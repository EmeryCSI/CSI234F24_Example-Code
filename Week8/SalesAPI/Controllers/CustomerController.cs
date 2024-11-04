using Microsoft.AspNetCore.Mvc;
using SalesAPI.Data;
using SalesAPI.Models;

namespace SalesAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CustomerController : ControllerBase
    {
        private readonly MockRepository _repository;

        public CustomerController(MockRepository repository)
        {
            _repository = repository;
        }

        [HttpGet]
        public ActionResult<IEnumerable<Customer>> GetCustomers()
        {
            return Ok(_repository.GetAllCustomers());
        }

        [HttpGet("{id}")]
        public ActionResult<Customer> GetCustomer(int id)
        {
            var customer = _repository.GetAllCustomers()
                .FirstOrDefault(c => c.Id == id);

            if (customer == null)
            {
                return NotFound();
            }

            return Ok(customer);
        }

        [HttpPost]
        public ActionResult<Customer> CreateCustomer(Customer customer)
        {
            // Generate a new ID (in a real app, the database would handle this)
            var customers = _repository.GetAllCustomers();
            customer.Id = customers.Max(c => c.Id) + 1;

            // Add the new customer to our list
            customers.Add(customer);

            return CreatedAtAction(
                nameof(GetCustomer),
                new { id = customer.Id },
                customer);
        }

        [HttpPut("{id}")]
        public IActionResult UpdateCustomer(int id, Customer customer)
        {
            if (id != customer.Id)
            {
                return BadRequest();
            }

            var customers = _repository.GetAllCustomers();
            var existingCustomer = customers.FirstOrDefault(c => c.Id == id);

            if (existingCustomer == null)
            {
                return NotFound();
            }

            // Update all properties
            existingCustomer.FirstName = customer.FirstName;
            existingCustomer.LastName = customer.LastName;
            existingCustomer.Email = customer.Email;

            return NoContent();
        }

        [HttpDelete("{id}")]
        public IActionResult DeleteCustomer(int id)
        {
            var customers = _repository.GetAllCustomers();
            var customer = customers.FirstOrDefault(c => c.Id == id);

            if (customer == null)
            {
                return NotFound();
            }

            // Actually remove the customer from the list
            customers.Remove(customer);

            return NoContent();
        }
    }
}