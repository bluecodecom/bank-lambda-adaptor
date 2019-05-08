# Bank Lambda Bluecode Adapter

An example proof of concept implementation of a "Bluecode issuer adapter" for banks with PSD2 APIs.

This adapter connects to [Bank Lambda](https://github.com/bluecodecom/bank-lambda), a simulator of a PSD2-compliant bank, with a OAuth login and PSD2 APIs implemented according to Berlin Group standards.

The adapter connects to following standard APIs and components of a PSD2 compliant bank:
- OAuth login for consumers to authorize instant payments
- AISP endpoints for querying account information
- PISP endpoints for initiating payments and checking status
- AISP and PISP endpoints implemented according to Berlin Group standards

If above systems are implemented following the standards, this adapter works out of the box and only requires configuration of the API endpoints and security credentials. Otherwise further adaptions required.

The adapter has two main parts:
- Bluecode Onboarding Wizard: A small UI layer that forwards authorizes a consumer via the OAuth login of the bank and that creates bluecode contracts.
- Bluecode Clearing API: Receives payment requests by Bluecode payment gateway, and translates them into PISP API commands.

This project was developed during a hackathon organized by European Central Bank. It is meant for demonstration and informational purposes only and **in no way intended to be a production ready system**.

## Build & run

Expects following ENV variables to be set:
- `BC_DEV_DOMAIN`
- `BC_ADAPTER_USERNAME`
- `BC_ADAPTER_PASSWORD`

```elixir
mix deps.get
mix ecto.create
mix ecto.migrate
mix phx.server
```


