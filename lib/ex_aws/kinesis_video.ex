defmodule ExAws.KinesisVideo do
  @moduledoc """
    Represents Kinesis Video operations
  """
  require Logger

  @base_opts %{}

  @list_fragment_opts %{
    timestamp_type: :producer,
    max_results: 500,
    next_token: nil,
    stream_builder: nil
  }

  @doc """
    Kinesis Video supports listing fragments by name or by ARN. This is a light facade over
    the json
  """
  def list_fragments_by_name(stream_name, start_at, end_at, opts \\ []) do
    opts = Enum.into(opts, @list_fragment_opts)

    request = %__MODULE__.ListFragments{
      stream_name: stream_name,
      start_at: start_at,
      end_at: end_at,
      timestamp_type: opts.timestamp_type,
      max_results: opts.max_results,
      next_token: opts.next_token
    }

    list_fragments(request, stream_builder: &ExAws.KinesisVideo.ListFragments.stream!(request, &1))
  end

  def list_fragments(_, opts \\ [])

  def list_fragments(%__MODULE__.ListFragments{} = request, opts) when is_list(opts) do
    opts = Enum.into(opts, @list_fragment_opts)

    request |> list_fragments(opts)
  end

  def list_fragments(%__MODULE__.ListFragments{} = request, %{} = opts) do
    request("listFragments", request, opts)
  end

  def get_media_for_fragments_list_by_name(stream_name, fragments \\ [], _opts \\ []) do
    data = %{
      "Fragments" => fragments,
      "StreamARN" => nil,
      "StreamName" => stream_name
    }

    request("getMediaForFragmentList", data)
  end

  @supported_endpoints [
    :put_media,
    :get_media,
    :list_fragments,
    :get_media_for_fragment_list,
    :get_hls_streaming_session_url,
    :get_dash_streaming_session_url,
    :get_clip
  ]
  @doc """
    A facade for [KinesisVideoStreams/GetDataEndpoint](https://docs.aws.amazon.com/kinesisvideostreams/latest/dg/API_GetDataEndpoint.html)
    that takes an api_name and stream_name.

    `api_name`: :put_media | :get_media | :list_fragments | :get_media_for_fragment_list | :get_hls_streaming_session_url | :get_dash_streaming_session_url | :get_clip
    `stream_name`: the stream name
    `opts`: reserved for future use. Optional.
  """

  def get_data_endpoint_by_stream_name(api_name, stream_name, _opts \\ [])
      when api_name in @supported_endpoints do
    data = %__MODULE__.GetDataEndpoint{
      api_name: translate_api_name(api_name),
      stream_name: stream_name
    }

    request("getDataEndpoint", data, %{
      parser: &ExAws.KinesisVideo.Parsers.parse_data_endpoint_response/1
    })
  end

  defp translate_api_name(api_name) when is_atom(api_name) do
    to_string(api_name) |> String.upcase()
  end

  defp scrub_fragment_list(request = %{"Fragments" => fragments}) do
    scrubbed_fragments =
      Enum.map(fragments, fn %{"FragmentNumber" => fragment_number} -> fragment_number end)

    %{request | "Fragments" => scrubbed_fragments}
  end

  defp request(action, data, opts \\ @base_opts)

  defp request("getMediaForFragmentList" = action, data, opts) do
    ExAws.Operation.Chunks.new(
      :kinesisvideo,
      %{
        data: scrub_fragment_list(data),
        headers: [
          {"content-type", "application/x-amz-json-1.1"}
        ],
        path: "/#{action}",
        parser: &ExAws.KinesisVideo.Parsers.parse_media_for_fragment_list(data, &1)
      }
      |> Map.merge(opts)
    )
  end

  defp request(action, data, opts) do
    #    operation =
    #      action
    #      |> Atom.to_string
    #      |> Macro.camelize
    ExAws.Operation.JSON.new(
      :kinesisvideo,
      %{
        data: ExAws.KinesisVideo.Protocol.to_request_payload(data),
        headers: [
          {"content-type", "application/x-amz-json-1.1"}
        ],
        path: "/#{action}",
        parser: &ExAws.Utils.identity/2
      }
      |> Map.merge(opts)
    )
  end
end

defprotocol ExAws.KinesisVideo.Protocol do
  def to_request_payload(struct)
end

defimpl ExAws.KinesisVideo.Protocol, for: Map do
  def to_request_payload(map), do: map
end
