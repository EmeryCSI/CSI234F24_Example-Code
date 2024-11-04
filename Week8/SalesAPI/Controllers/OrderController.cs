using Microsoft.AspNetCore.Mvc;
using SalesAPI.Data;
using SalesAPI.Models;

namespace SalesAPI.Controllers
{
    /// <summary>
    /// API Controller for managing orders
    /// Handles the relationship between customers and their orders
    /// Route prefix: api/orders
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class OrderController : ControllerBase
    {
        private readonly MockRepository _repository;

        public OrderController(MockRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// GET: api/orders
        /// Retrieves all orders with their customer information
        /// </summary>
        [HttpGet]
        public ActionResult<IEnumerable<Order>> GetOrders()
        {
            // Get orders and include customer information
            var orders = _repository.GetAllOrders();
            foreach (var order in orders)
            {
                // Populate customer information for each order
                order.Customer = _repository.GetAllCustomers()
                    .FirstOrDefault(c => c.Id == order.CustomerId);
            }
            return Ok(orders);
        }

        /// <summary>
        /// GET: api/orders/{id}
        /// Retrieves a specific order with its customer and order items
        /// </summary>
        [HttpGet("{id}")]
        public ActionResult<Order> GetOrder(int id)
        {
            var order = _repository.GetAllOrders()
                .FirstOrDefault(o => o.Id == id);

            if (order == null)
            {
                return NotFound();
            }

            // Populate customer information
            order.Customer = _repository.GetAllCustomers()
                .FirstOrDefault(c => c.Id == order.CustomerId);

            // Populate order items
            order.OrderItems = _repository.GetAllOrderItems()
                .Where(oi => oi.OrderId == order.Id)
                .ToList();

            return Ok(order);
        }

        /// <summary>
        /// GET: api/orders/customer/{customerId}
        /// Retrieves all orders for a specific customer
        /// </summary>
        [HttpGet("customer/{customerId}")]
        public ActionResult<IEnumerable<Order>> GetOrdersByCustomer(int customerId)
        {
            // Verify customer exists
            var customer = _repository.GetAllCustomers()
                .FirstOrDefault(c => c.Id == customerId);

            if (customer == null)
            {
                return NotFound("Customer not found");
            }

            var orders = _repository.GetAllOrders()
                .Where(o => o.CustomerId == customerId)
                .ToList();

            return Ok(orders);
        }

        /// <summary>
        /// POST: api/orders
        /// Creates a new order with order items
        /// Expects an order object with CustomerId and OrderItems array
        /// </summary>
        [HttpPost]
        public ActionResult<Order> CreateOrder(Order order)
        {
            // Verify customer exists
            var customer = _repository.GetAllCustomers()
                .FirstOrDefault(c => c.Id == order.CustomerId);

            if (customer == null)
            {
                return BadRequest("Invalid CustomerId");
            }

            var orders = _repository.GetAllOrders();
            var orderItems = _repository.GetAllOrderItems();

            // Generate new order ID
            order.Id = orders.Max(o => o.Id) + 1;
            order.OrderDate = DateTime.Now; // Set current date

            // Calculate total amount from order items
            decimal totalAmount = 0;
            if (order.OrderItems != null)
            {
                foreach (var item in order.OrderItems)
                {
                    // Verify product exists and get its price
                    var product = _repository.GetAllProducts()
                        .FirstOrDefault(p => p.Id == item.ProductId);

                    if (product == null)
                    {
                        return BadRequest($"Invalid ProductId: {item.ProductId}");
                    }

                    item.OrderId = order.Id;
                    item.Id = orderItems.Max(oi => oi.Id) + 1;
                    item.UnitPrice = product.Price;

                    totalAmount += item.UnitPrice * item.Quantity;

                    // Add order item to repository
                    orderItems.Add(item);
                }
            }

            order.TotalAmount = totalAmount;
            orders.Add(order);

            return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, order);
        }

        /// <summary>
        /// PUT: api/orders/{id}
        /// Updates an existing order
        /// Can update customer and total amount, but not order items
        /// Use OrderItems controller to modify individual items
        /// </summary>
        [HttpPut("{id}")]
        public IActionResult UpdateOrder(int id, Order order)
        {
            if (id != order.Id)
            {
                return BadRequest();
            }

            var orders = _repository.GetAllOrders();
            var existingOrder = orders.FirstOrDefault(o => o.Id == id);

            if (existingOrder == null)
            {
                return NotFound();
            }

            // Verify new customer exists if customer is changed
            if (order.CustomerId != existingOrder.CustomerId)
            {
                var customerExists = _repository.GetAllCustomers()
                    .Any(c => c.Id == order.CustomerId);

                if (!customerExists)
                {
                    return BadRequest("Invalid CustomerId");
                }
            }

            // Update order properties
            existingOrder.CustomerId = order.CustomerId;
            existingOrder.OrderDate = order.OrderDate;
            existingOrder.TotalAmount = order.TotalAmount;

            return NoContent();
        }

        /// <summary>
        /// DELETE: api/orders/{id}
        /// Deletes an order and all its associated order items
        /// </summary>
        [HttpDelete("{id}")]
        public IActionResult DeleteOrder(int id)
        {
            var orders = _repository.GetAllOrders();
            var orderItems = _repository.GetAllOrderItems();

            var order = orders.FirstOrDefault(o => o.Id == id);
            if (order == null)
            {
                return NotFound();
            }

            // Remove all associated order items first
            var itemsToRemove = orderItems.Where(oi => oi.OrderId == id).ToList();
            foreach (var item in itemsToRemove)
            {
                orderItems.Remove(item);
            }

            // Remove the order
            orders.Remove(order);

            return NoContent();
        }
    }
}