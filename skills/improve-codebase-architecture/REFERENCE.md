# Reference

## Dependency Categories

When assessing a candidate for deepening, classify its dependencies:

### 1. In-process

Pure computation, in-memory state, no I/O. Always deepenable — just merge the modules and test directly.

### 2. Local-substitutable

Dependencies that have local test stand-ins (e.g., PGLite for Postgres, in-memory filesystem). Deepenable if the test substitute exists. The deepened module is tested with the local stand-in running in the test suite.

### 3. Remote but owned (Ports & Adapters)

Your own services across a network boundary (microservices, internal APIs). Define a port (interface) at the module boundary. The deep module owns the logic; the transport is injected. Tests use an in-memory adapter. Production uses the real HTTP/gRPC/queue adapter.

Recommendation shape: "Define a shared interface (port), implement an HTTP adapter for production and an in-memory adapter for testing, so the logic can be tested as one deep module even though it's deployed across a network boundary."

### 4. True external (Mock)

Third-party services (Stripe, Twilio, etc.) you don't control. Mock at the boundary. The deepened module takes the external dependency as an injected port, and tests provide a mock implementation.

## Testing Strategy

The core principle: **replace, don't layer.**

- Old unit tests on shallow modules are waste once boundary tests exist — delete them
- Write new tests at the deepened module's interface boundary
- Tests assert on observable outcomes through the public interface, not internal state
- Tests should survive internal refactors — they describe behavior, not implementation

## Language-Specific Patterns

### Python: Pydantic for Deep Modules

Use Pydantic for clean interfaces with validation:

```python
from pydantic import BaseModel, Field
from decimal import Decimal
from typing import Protocol, runtime_checkable

# Deep module with small interface
class PaymentGateway(Protocol):
    def charge(self, amount: Decimal, currency: str) -> PaymentResult: ...
    def refund(self, transaction_id: str) -> RefundResult: ...

class OrderProcessor:
    def __init__(self, gateway: PaymentGateway):
        self._gateway = gateway  # Injected, testable
    
    def process(self, order: Order) -> Receipt:
        # Deep implementation hidden behind simple interface
        result = self._gateway.charge(order.total, order.currency)
        return Receipt(order_id=order.id, transaction=result.transaction_id)

# Easy to test with protocol
class MockGateway:
    def charge(self, amount: Decimal, currency: str) -> PaymentResult:
        return PaymentResult(success=True, transaction_id="mock-123")
    
    def refund(self, transaction_id: str) -> RefundResult:
        return RefundResult(success=True)

# Test
def test_order_processor():
    processor = OrderProcessor(MockGateway())
    receipt = processor.process(Order(id="1", total=Decimal("100")))
    assert receipt.transaction == "mock-123"
```

### TypeScript/React: Deep Components

```typescript
// Deep module: simple props interface, complex internal logic
interface ButtonProps {
  children: React.ReactNode;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
}

// Implementation hides complexity:
- Loading states
- Debouncing
- Accessibility handling
- Animation
- Error boundaries
```

## Issue Template

<issue-template>

## Problem

Describe the architectural friction:

- Which modules are shallow and tightly coupled
- What integration risk exists in the seams between them
- Why this makes the codebase harder to navigate and maintain

## Proposed Interface

The chosen interface design:

- Interface signature (types, methods, params)
- Usage example showing how callers use it
- What complexity it hides internally

## Dependency Strategy

Which category applies and how dependencies are handled:

- **In-process**: merged directly
- **Local-substitutable**: tested with [specific stand-in]
- **Ports & adapters**: port definition, production adapter, test adapter
- **Mock**: mock boundary for external services

## Testing Strategy

- **New boundary tests to write**: describe the behaviors to verify at the interface
- **Old tests to delete**: list the shallow module tests that become redundant
- **Test environment needs**: any local stand-ins or adapters required

## Implementation Recommendations

Durable architectural guidance that is NOT coupled to current file paths:

- What the module should own (responsibilities)
- What it should hide (implementation details)
- What it should expose (the interface contract)
- How callers should migrate to the new interface

</issue-template>