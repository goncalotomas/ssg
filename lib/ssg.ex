defmodule SSG do
  @moduledoc """
  Documentation for `SSG`.
  """

  require Logger

  def run(opts) do
    files =
      opts
      |> get_file_extensions()
      |> get_workable_files()
    IO.inspect(files, label: "files")

    output_directory = "./_site"
    File.mkdir(output_directory)

    tasks =
      for file <- files do
        Task.async(fn ->
          # generated = Earmark.as_html!(File.read!(file))
          # file_directory = Path.expand("#{output_directory}/#{Path.dirname(file)}")
          # IO.inspect("writing to #{file_directory}")
          # directory_result = File.mkdir_p(file_directory)
          # IO.inspect("mkdir -p result: #{directory_result}")
          # file_path = Path.expand("#{file_directory}/#{Path.basename(file, Path.extname(file))}.html")
          # IO.inspect("writing to #{file_path}")
          # write_result = File.write(file_path, generated)
          # IO.inspect("write result: #{write_result}")
          # :ok
          generate_file(file, output_directory, Path.extname(file))
        end)
      end

    for task <- tasks do
      Task.await(task)
    end
  end

  def generate_file(input_path, output_path, extname) do
    Logger.debug("reading: #{input_path}")
    generated = template_to_html(input_path, extname)

    # create full directory path
    file_directory = "#{output_path}/#{Path.basename(input_path, extname)}"

    Logger.debug("creating path: #{file_directory}")

    file_directory
      |> Path.expand()
      |> File.mkdir_p()

    file_path =
      "#{file_directory}/index.html"

    Logger.debug("writing: #{file_path} from #{input_path} (#{extension_parser(extname)})")

    :ok = File.write(file_path, generated)
  end

  def template_to_html(path, ".md") do
    path
    |> File.read!()
    |> Earmark.as_html!()
  end

  def template_to_html(path, ".html") do
    path
    |> File.read!()
    |> Earmark.as_html!()
  end

  def template_to_html(path, ".pug") do
    path
    |> File.read!()
    |> Expug.to_eex!()
  end

  def get_workable_files(extensions) do
    Path.wildcard("./**/*.*", match_dot: false)
    |> Enum.filter(&(not String.starts_with?(&1, ["_"])))
    # |> Enum.map(&Path.expand/1)
    |> Enum.filter(&(Path.extname(&1) in extensions))
  end

  defp get_file_extensions(opts) do
    opts
    |> Keyword.fetch!(:formats)
    |> Enum.map(&file_extension_name/1)
  end

  defp file_extension_name("md"), do: ".md"
  defp file_extension_name("html"), do: ".html"
  defp file_extension_name("pug"), do: ".pug"
  defp file_extension_name(format), do: raise "unknown format #{format}"

  defp extension_parser(".md"), do: :earmark
  defp extension_parser(".pug"), do: :expug
end
