defmodule ExAws.KinesisVideo.GetDataEndpoint do
  @moduledoc false

  defstruct api_name: :get_media, stream_name: nil, stream_arn: nil
end

defimpl ExAws.KinesisVideo.Protocol, for: ExAws.KinesisVideo.GetDataEndpoint do
  def to_request_payload(%ExAws.KinesisVideo.GetDataEndpoint{
        api_name: api_name,
        stream_name: stream_name,
        stream_arn: stream_arn
      }) do
    %{
      "APIName" => api_name,
      "StreamName" => stream_name,
      "StreamARN" => stream_arn
    }
  end
end
