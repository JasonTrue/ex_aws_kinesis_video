defmodule ExAws.KinesisVideo.ListFragments do
  defstruct stream_name: nil,
            stream_arn: nil,
            timestamp_type: nil,
            start_at: DateTime.utc_now(),
            end_at: DateTime.utc_now(),
            max_results: 500,
            next_token: nil

  @doc """
    Returns a sequence of fragments (rather than returning a simple JSON response)
  """
  def stream!(%__MODULE__{} = request, config) do
    request_fun = fn request, fun_opts ->
      %{"Fragments" => fragments, "NextToken" => next_token} =
        ExAws.KinesisVideo.list_fragments(request, fun_opts)
        |> ExAws.request!(config)

      {fragments, next_token}
    end

    # list_fragments or the unfold accumulator will be one of the following:
    # a tuple containing { list_with_one_or_more_items, next_token },
    # a tuple containing { [], nil = next_token } (No fragments left)
    # a tuple containing { [], next_token } (no fragments left in this unfolding operation, but AWS says we have more data)
    #
    # Also possibly an error? but I'll burn that bridge when I come to it
    Stream.unfold(request_fun.(request, config), fn
      {[head | rest], next_token} ->
        {head, {rest, next_token}}

      {[], nil} ->
        nil

      {[], next_token} ->
        {[head | rest], new_token} =
          request_fun.(%__MODULE__{request | next_token: next_token}, config)

        {head, {rest, new_token}}
    end)
  end
end

defimpl ExAws.KinesisVideo.Protocol, for: ExAws.KinesisVideo.ListFragments do
  require Logger

  @moduledoc false

  def to_request_payload(%ExAws.KinesisVideo.ListFragments{
        stream_name: stream_name,
        stream_arn: stream_arn,
        timestamp_type: timestamp_type,
        start_at: start_at,
        end_at: end_at,
        max_results: max_results,
        next_token: next_token
      }) do
    %{
      "FragmentSelector" => %{
        "FragmentSelectorType" => timestamp_type_name(timestamp_type),
        "TimestampRange" => %{
          "EndTimestamp" => end_at |> DateTime.to_unix(),
          "StartTimestamp" => start_at |> DateTime.to_unix()
        }
      },
      "MaxResults" => max_results,
      "NextToken" => next_token,
      "StreamARN" => stream_arn,
      "StreamName" => stream_name
    }
  end

  defp timestamp_type_name(:producer), do: "PRODUCER_TIMESTAMP"
  defp timestamp_type_name(:server), do: "SERVER_TIMESTAMP"

  defp timestamp_type_name(_) do
    Logger.error("Unrecognized Fragment Selector Type (timestamp_type")
  end
end
