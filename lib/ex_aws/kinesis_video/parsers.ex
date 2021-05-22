defmodule ExAws.KinesisVideo.Parsers do
  @moduledoc """
    Parses responses from Kinesis Video endpoints.
  """

  def parse_data_endpoint_response({:ok, resp = %{body: body}}) do
    {:ok, %{resp | body: body}}
  end

  def parse_media_for_fragment_list(
        %{"Fragments" => fragments, "StreamName" => stream_name, "StreamARN" => stream_arn},
        response
      ) do
    {fragments, _byte_count} =
      fragments
      |> Enum.map_reduce(0, fn fragment, position ->
        %{"FragmentSizeInBytes" => byte_count} = fragment
        chunk = response |> :binary.part(position, byte_count)

        fragment_with_metadata =
          fragment
          |> Map.put("FragmentData", chunk)
          |> Map.put("StreamName", stream_name)
          |> Map.put("StreamArn", stream_arn)

        {fragment_with_metadata, position + byte_count}
      end)

    fragments
  end
end
