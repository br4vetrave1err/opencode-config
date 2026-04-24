# Interface Design for Testability

Good interfaces make testing natural:

## 1. Accept dependencies, don't create them

```typescript
// TypeScript - Testable
function processOrder(order, paymentGateway) {}

// TypeScript - Hard to test
function processOrder(order) {
  const gateway = new StripeGateway();
}
```

```python
# Python - Testable (with Protocol)
from typing import Protocol

class PaymentGateway(Protocol):
    def charge(self, amount: Decimal) -> PaymentResult: ...

def process_order(order: Order, gateway: PaymentGateway) -> Receipt:
    result = gateway.charge(order.total)
    ...

# Python - Hard to test (hardcoded dependency)
def process_order(order: Order) -> Receipt:
    gateway = StripeGateway()  # Can't inject mock
    result = gateway.charge(order.total)
    ...
```

## 2. Return results, don't produce side effects

```typescript
// TypeScript - Testable
function calculateDiscount(cart): Discount {}

// TypeScript - Hard to test
function applyDiscount(cart): void {
  cart.total -= discount;
}
```

```python
# Python - Testable
def calculate_discount(cart: Cart) -> Discount:
    ...

# Python - Hard to test (mutates input)
def apply_discount(cart: Cart, discount: Decimal) -> None:
    cart.total -= discount  # Mutates, returns None
```

## 3. Small surface area

- Fewer methods = fewer tests needed
- Fewer params = simpler test setup

## 4. Python: Use Pydantic for static typing

Pydantic provides runtime validation + type hints:

```python
from pydantic import BaseModel, Field, validator
from datetime import datetime
from decimal import Decimal
from typing import Optional

class Order(BaseModel):
    id: str
    items: list[OrderItem]
    total: Decimal = Field(ge=0)
    status: str = "pending"
    created_at: datetime = Field(default_factory=datetime.now)
    
    @validator("total")
    def total_must_be_positive(cls, v):
        if v <= 0:
            raise ValueError("total must be positive")
        return v
    
    class Config:
        frozen = True  # Immutable (easier to test)

class OrderItem(BaseModel):
    product_id: str
    quantity: int = Field(gt=0)
    price: Decimal

# Testing with Pydantic is straightforward:
def test_order_creation():
    order = Order(
        id="order-123",
        items=[OrderItem(product_id="prod-1", quantity=2, price=Decimal("29.99"))],
        total=Decimal("59.98")
    )
    assert order.id == "order-123"
    assert order.status == "pending"
    
def test_order_validation_fails():
    with pytest.raises(ValidationError):
        Order(id="123", items=[], total=Decimal("-10"))
```

Benefits:
- **Type safety**: Mypy validates at static analysis time
- **Validation**: Pydantic validates at runtime
- **Immutability**: Use `frozen=True` for hashable, thread-safe models
- **Serialization**: Built-in `.model_dump_json()`, `.model_copy()`
- **Testing**: Easy to construct valid/invalid instances

## 5. React + TypeScript: Component Interface Design

```typescript
// Good: Props define clear contract
interface ButtonProps {
  children: React.ReactNode;
  onClick: () => void;
  variant?: 'primary' | 'secondary' | 'danger';
  disabled?: boolean;
}

// Good: Hooks return typed interfaces
interface UseAuthReturn {
  user: User | null;
  isAuthenticated: boolean;
  login: (credentials: LoginCredentials) => Promise<void>;
  logout: () => Promise<void>;
}

// Usage in test
const mockAuth: UseAuthReturn = {
  user: { id: 1, name: 'Alice' },
  isAuthenticated: true,
  login: vi.fn(),
  logout: vi.fn(),
};
```