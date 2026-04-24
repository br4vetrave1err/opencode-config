# When to Mock

Mock at **system boundaries** only:

- External APIs (payment, email, etc.)
- Databases (sometimes - prefer test DB)
- Time/randomness
- File system (sometimes)

Don't mock:

- Your own classes/modules
- Internal collaborators
- Anything you control

## Designing for Mockability

At system boundaries, design interfaces that are easy to mock:

### 1. Use dependency injection

```typescript
// TypeScript - Easy to mock
function processPayment(order, paymentClient) {
  return paymentClient.charge(order.total);
}

// TypeScript - Hard to mock
function processPayment(order) {
  const client = new StripeClient(process.env.STRIPE_KEY);
  return client.charge(order.total);
}
```

```python
# Python - Easy to mock (with protocol/ABC)
def process_payment(order, payment_client):
    return payment_client.charge(order.total)

# Python - Hard to mock
def process_payment(order):
    client = StripeClient(os.environ["STRIPE_KEY"])
    return client.charge(order.total)
```

### 2. Prefer SDK-style interfaces over generic fetchers

```typescript
// TypeScript - GOOD: Each function is independently mockable
const api = {
  getUser: (id) => fetch(`/users/${id}`),
  getOrders: (userId) => fetch(`/users/${userId}/orders`),
  createOrder: (data) => fetch('/orders', { method: 'POST', body: JSON.stringify(data) }),
};

// BAD: Mocking requires conditional logic inside the mock
const api = {
  fetch: (endpoint, options) => fetch(endpoint, options),
};
```

```python
# Python - GOOD: Each function is independently mockable
from typing import Protocol

class UserAPI(Protocol):
    def get_user(self, id: str) -> User: ...
    def get_orders(self, user_id: str) -> list[Order]: ...
    def create_order(self, data: dict) -> Order: ...

# In tests, implement simple mock:
class MockUserAPI:
    def __init__(self):
        self.calls = []
    
    def get_user(self, id: str) -> User:
        self.calls.append(("get_user", id))
        return User(id=id, name="Test")

# BAD: Mocking requires conditional logic
class BadMockAPI:
    def fetch(self, endpoint, options):
        if endpoint == "/users":
            return users
        elif endpoint == "/orders":
            return orders
```

### 3. Python: Use Protocols for typing

```python
# Define interface with Protocol
from typing import Protocol, runtime_checkable

@runtime_checkable
class PaymentGateway(Protocol):
    def charge(self, amount: Decimal) -> PaymentResult: ...
    def refund(self, transaction_id: str) -> RefundResult: ...

# Easy to mock - just implement the protocol
class MockPaymentGateway:
    def charge(self, amount: Decimal) -> PaymentResult:
        return PaymentResult(success=True, transaction_id="mock-123")
    
    def refund(self, transaction_id: str) -> RefundResult:
        return RefundResult(success=True)

# Usage with type hints
def checkout(order: Order, gateway: PaymentGateway) -> Receipt:
    result = gateway.charge(order.total)
    ...
```

## React + TypeScript: Mocking External Services

### Mock MSW (Mock Service Worker) for API calls

```typescript
// handlers.ts
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';

export const server = setupServer(
  http.get('/api/users', () => {
    return HttpResponse.json([{ id: 1, name: 'Alice' }]);
  }),
  http.post('/api/orders', () => {
    return HttpResponse.json({ id: 123, status: 'confirmed' }, { status: 201 });
  })
);

// In test
import { server } from './handlers';

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

### Mock React components

```typescript
// Mock child components when testing parent
vi.mock('./Button', () => ({
  default: ({ children, onClick }: ButtonProps) => (
    <button onClick={onClick}>{children}</button>
  )
}));

// Mock hooks
vi.mock('./useAuth', () => ({
  useAuth: () => ({ user: { id: 1 }, login: vi.fn() })
}));
```

### Don't mock what you own

```typescript
// BAD: Mock your own utility
vi.mock('../../utils/formatCurrency', () => ({
  formatCurrency: vi.fn().mockReturnValue('$100.00')
}));

// GOOD: Test the real utility, mock the boundary
import { formatCurrency } from '../../utils/formatCurrency';

test('displays formatted price', () => {
  render(<PriceDisplay amount={100} />);
  expect(screen.getByText('$100.00')).toBeInTheDocument();
  // No mock needed - formatCurrency is your code, not external
});
```