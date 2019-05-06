defmodule BluecodeConnector.Bluecode.ContractsApiClient do
  require Logger
  use Tesla

  @type t :: %Tesla.Client{}

  defmodule Contract do
    @derive Jason.Encoder
    defstruct member_id: "",
              contract_number: UUID.uuid4(),
              state: "active",
              currency: "EUR",
              country: "DE",
              bic: "",
              blz: "",
              bank_code: "",
              bank_name: "",
              utc_offset: "+01:00",
              birth_date: "",
              limit_transaction: nil,
              value_limits: nil,
              velocity_limits: nil
  end

  def new(username, password) do
    config = Application.get_env(:sdd_solaris, __MODULE__) || %{}

    Tesla.client(
      [
        {Tesla.Middleware.BaseUrl, "https://contracts-api.#{System.get_env("BC_DEV_DOMAIN")}"},
        {Tesla.Middleware.BasicAuth, username: username, password: password},
        Tesla.Middleware.JSON,
        Tesla.Middleware.Logger
      ] ++
        case Mix.env() do
          :test -> []
          _ -> [{Tesla.Middleware.Timeout, timeout: config[:timeout] || 5_000}]
        end ++
        [
          {Tesla.Middleware.Opts,
           adapter: [ssl_options: [cacertfile: "/etc/bluecode/certs/ca-bundle.pem"]]}
        ]
    )
  end

  def create_contract(%Tesla.Client{} = client, %Contract{} = contract) do
    post(client, "/v1/contracts", contract)
    |> unpack_result
  end

  def create_card(%Tesla.Client{} = client, %{contract_number: _, card_request_token: _} = card) do
    post(client, "/v1/cards", card)
    |> unpack_result
  end

  def create_card(%Tesla.Client{} = client, %{contract_number: _, wallet_id: _} = card) do
    post(client, "/v1/cards", card)
    |> unpack_result
  end

  defp unpack_result(post_result) do
    with {:ok, %{body: body, url: url, status: status}} <- post_result do
      Logger.info("<- Contract API #{url} (status #{status}): #{inspect(body)}")
    end

    case post_result do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %{status: 400, body: body}} ->
        {:invalid_parameters, body}

      {:ok, %{status: 401, body: body}} ->
        {:unauthorized, body}

      {:ok, %{status: 404, body: %{"result" => "ERROR", "code" => code}}}
      when code in [
             "INVALID_CARD_REQUEST_TOKEN",
             "CONTRACT_NOT_FOUND",
             "WALLET_NOT_FOUND",
             "CARD_NOT_FOUND"
           ] ->
        code |> String.downcase() |> String.to_atom()

      {:ok, %{status: 422, body: body}} ->
        case body do
          %{"errors" => [%{"source" => %{"parameter" => index}}]} ->
            case index do
              # on card calls
              "wallet_id_contract_id" -> {:card_exists_for_wallet, body}
              # on contract calls
              "issuer_contract_number" -> {:contract_already_taken, body}
              # "not allowed to have more than 2 SDD contracts"
              "wallet_id" -> {:contract_limit, body}
            end

          _ ->
            {:exists, body}
        end

      {:ok, %{status: 500, body: body}} ->
        {:system_failure, body}

      {:ok, %{status: 503, body: body}} ->
        {:system_failure, body}

      {:error, error} ->
        Logger.error("While calling the Contract API: #{inspect(error)}")

        {:connection_error, error}
    end
  end
end
