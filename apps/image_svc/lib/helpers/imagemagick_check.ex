defmodule ImageMagick do
  # {:ok, Mcsv.UserResponse.decode(response_binary) |> dbg()}
  @doc """
  Check if ImageMagick is installed and available.

  ## Examples

      iex> ImageConverter.check_imagemagick()
      {:ok, _}
      {:error, _} -> {:error, "ImageMagick not found"}
  """
  def check do
    case System.cmd("magick", ["-version"]) do
      {output, 0} ->
        # Extract version from first line
        version =
          output
          |> String.split("\n")
          |> List.first()
          |> String.trim()

        {:ok, version}

      {_error, _} ->
        {:error, "ImageMagick not found"}
    end
  end
end
