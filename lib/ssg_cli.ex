defmodule SSG.CLI do

  @version Mix.Project.config[:version]
  @all_formats ["md", "html", "pug"]

  def main(args \\ []) do
    args
    |> parse_args()
    |> response()
    |> IO.puts()
  end

  defp parse_args(args) do
    {opts, _, _} =
      args
      |> OptionParser.parse(strict: [input_path: :string, output_path: :string, verbose: :boolean, help: :boolean, formats: :string])

    formats =
      opts
      |> Keyword.get(:formats)
      |> parse_formats()


    {Keyword.put(opts, :formats, formats), []}
  end

  def parse_formats(nil), do: @all_formats
  def parse_formats(formats), do: String.split(formats, ",")

  defp response({opts, _word}) do
    IO.inspect(opts, label: "opts")
    {time_in_microseconds, response} = :timer.tc(fn -> SSG.run(opts) end)

    files_written = length(response)
    time_elapsed = :erlang.float_to_binary(time_in_microseconds / 1_000_000, decimals: 2)
    time_per_file = :erlang.float_to_binary(time_in_microseconds / (1_000 * files_written), decimals: 1)
    IO.ANSI.format([:black_background, :green, "Wrote #{files_written} files in #{time_elapsed} seconds (#{time_per_file}ms each, v#{@version})"])
  end
end
