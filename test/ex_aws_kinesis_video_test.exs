defmodule ExAws.KinesisVideoTest do
  use ExUnit.Case

  alias ExAws.KinesisVideo

  test "Entry module exists" do
    assert is_list(ExAws.KinesisVideo.module_info())
  end

  test "get_data_endpoint_by_stream_name/2 list_fragments" do
    assert %ExAws.Operation.JSON{
             data: %{
               "APIName" => "LIST_FRAGMENTS",
               "StreamName" => "my_stream",
               "StreamARN" => nil
             },
             path: "/getDataEndpoint"
           } = KinesisVideo.get_data_endpoint_by_stream_name(:list_fragments, "my_stream")
  end

  test "get_data_endpoint_by_stream_name/2 fails with unsupported_endpoint" do
    assert_raise FunctionClauseError,
                 ~r/no function clause matching/,
                 fn ->
                   KinesisVideo.get_data_endpoint_by_stream_name(
                     :unsupported_endpoint,
                     "my_stream"
                   )
                 end
  end
end
