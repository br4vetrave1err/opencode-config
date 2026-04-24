# Good and Bad Tests

## Good Tests

**Integration-style**: Test through real interfaces, not mocks of internal parts.

```typescript
// TypeScript/JS - GOOD: Tests observable behavior
test("user can checkout with valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

```python
# Python/pytest - GOOD: Tests observable behavior
def test_user_can_checkout_with_valid_cart():
    cart = create_cart()
    cart.add(product)
    result = checkout(cart, payment_method)
    assert result.status == "confirmed"
```

Characteristics:

- Tests behavior users/callers care about
- Uses public API only
- Survives internal refactors
- Describes WHAT, not HOW
- One logical assertion per test

## Bad Tests

**Implementation-detail tests**: Coupled to internal structure.

```typescript
// TypeScript - BAD: Tests implementation details
test("checkout calls paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});
```

```python
# Python - BAD: Tests implementation details
def test_checkout_calls_payment_service_process(mocker):
    mock_payment = mocker.patch("payment_service.process")
    checkout(cart, payment)
    mock_payment.assert_called_once_with(cart.total)
```

Red flags:

- Mocking internal collaborators
- Testing private methods
- Asserting on call counts/order
- Test breaks when refactoring without behavior change
- Test name describes HOW not WHAT
- Verifying through external means instead of interface

```typescript
// TypeScript - BAD: Bypasses interface to verify
test("createUser saves to database", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// GOOD: Verifies through interface
test("createUser makes user retrievable", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});
```

```python
# Python - BAD: Bypasses interface to verify
def test_create_user_saves_to_database():
    create_user({"name": "Alice"})
    row = db.query("SELECT * FROM users WHERE name = ?", ("Alice",))
    assert row is not None

# GOOD: Verifies through interface
def test_create_user_makes_user_retrievable():
    user = create_user({"name": "Alice"})
    retrieved = get_user(user.id)
    assert retrieved.name == "Alice"
```

## React + TypeScript Testing

Use **React Testing Library** (not enzyme) - test user interactions, not implementation:

```typescript
// GOOD: Tests user behavior
test("user can submit form", async () => {
  render(<LoginForm />);
  
  await userEvent.type(screen.getByLabelText(/email/), "test@example.com");
  await userEvent.click(screen.getByRole("button", { name: /submit/i }));
  
  expect(onSubmit).toHaveBeenCalledWith({ email: "test@example.com" });
});

// BAD: Tests internal state
test("form submits when submitted is true", () => {
  const { getState } = render(<LoginForm />);
  act(() => { getState().submit(); });
  expect(getState().submitted).toBe(true);
});
```

Key principles:
- Query by role, label, or text (not testid)
- Test what the user sees and interacts with
- Avoid testing component internals
- Use `user-event` for interactions, not `fireEvent`