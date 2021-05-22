defmodule ExAws.Operation.Chunks do
  @moduledoc """
  Datastructure representing an operation on a JSON based AWS service.

  This module is generally not used directly, but rather is constructed by one
  of the relevant AWS services.

  KinesisVideo
  """

  defstruct stream_builder: nil,
            http_method: :post,
            parser: nil,
            path: "/",
            data: %{},
            params: %{},
            headers: [],
            service: nil,
            before_request: nil

  @type t :: %__MODULE__{}

  def new(service, opts) do
    struct(%__MODULE__{service: service, parser: & &1}, opts)
  end
end

defimpl ExAws.Operation, for: ExAws.Operation.Chunks do
  @type response_t :: %{} | ExAws.Request.error_t()

  def perform(operation, config) do
    operation = handle_callbacks(operation, config)
    url = ExAws.Request.Url.build(operation, config)

    headers = [
      {"x-amz-content-sha256", ""} | operation.headers
    ]

    case ExAws.Request.request(
           operation.http_method,
           url,
           operation.data,
           headers,
           config,
           operation.service
         ) do
      {:ok, %{body: body}} ->
        body = operation.parser.(body)
        {:ok, body}

      {:error, reason} ->
        {:error, %{reason: reason}}

      error ->
        {:error, %{reason: error}}
    end
  end

  def stream!(%ExAws.Operation.Chunks{stream_builder: nil}, _) do
    raise ArgumentError, """
    This operation does not support streaming!
    """
  end

  def stream!(%ExAws.Operation.Chunks{stream_builder: stream_builder}, config_overrides) do
    stream_builder.(config_overrides)
  end

  defp handle_callbacks(%{before_request: nil} = op, _), do: op

  defp handle_callbacks(%{before_request: callback} = op, config) do
    callback.(op, config)
  end
end
