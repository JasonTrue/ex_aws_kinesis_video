# ExAws.KinesisVideo

This library supports the [AWS Kinesis Video API](https://docs.aws.amazon.com/kinesisvideostreams/latest/dg/API_Reference.html).
It's designed to work with [ExAws 2.x](https://hexdocs.pm/ex_aws/) and, with a few exceptions, generally
behaves similarly to other JSON-based AWS APIs implemented in ExAws.

One notable difference from most ExAws libraries is that many Kinesis Video endpoints require retrieving a 
custom endpoint prior to invoking the desired endpoint.


## Installation

The package can be installed  by adding `jasontrue_ex_aws_kinesis_video` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:jasontrue_ex_aws_kinesis_video, "~> 0.1.0"}
  ]
end
```
## Developing

1. Fork it
2. Please add some tests to reflect the purpose of your change (not needed for doc changes)
3. Run `mix precommit` before committing
4. Run `mix prepush` preferably before committing, but definitely before submitting a PR 
5. Submit a pull request to https://github.com/JasonTrue/ex_aws_kinesis_video

## Publishing a release

````bash
    mix do deps.get, archive.install hex shipit, cmd test
````

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_aws_kinesis_video](https://hexdocs.pm/ex_aws_kinesis_video).

