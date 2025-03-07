defmodule GitHubPixelArt do
  @doc """
  GitHub commit heatmap is represented with 7 rows as the days of the week,
  and columns for the weeks in a year. As follows:

                Jan             Dec
  Sunday      [1][8][][][] ... [][][][][]
  Monday      [2][9][][][] ... [][][][][]
  Tuesday     [3][.][][][] ... [][][][][]
  Wednesday   [4][.][][][] ... [][][][][]
  Thursday    [5][.][][][] ... [][][][][]
  Friday      [6][.][][][] ... [][][][][]
  Saturday    [7][.][][][] ... [][][][][]

  Your drawing must be represented as a matrix of, a list of lists.
  Each element in a row (inner list) represent the same day of the week in different weeks.
  e.i.
  [
     w1 w2 w3 w4 w5
    [1, 0, 1, 0, 1],  # Sunday
    [1, 1, 1, 0, 1],  # Monday
    [1, 0, 1, 0, 1]   # Tuesday
  ]

  Each cell in the drawing must be filled with either a 1 or a 0.
  A value of 1 represents a filled cell (commit), while a value of 0 represents an empty cell.

  Ideally, you should draw in the past, so make sure your GitHub history has some empty spaces.
  """
  @spec draw_in_github(drawing :: [], init_date :: Date.t(), end_date :: Date.t()) :: :ok
  def draw_in_github(drawing, %Date{} = init_date, %Date{} = end_date) do
    # 1. Validations
    init_date_is_less_or_equal_than_end_date?(init_date, end_date)

    # 2. Ask user if the drawing is correct
    draw_in_console(drawing)
    IO.puts("Does it look like what you are expecting?")
    IO.puts("Press 'y' to create the commits for your drawing or any other key to abort.")
    if IO.gets("> ") |> String.trim() != "y", do: raise("Aborted")

    # 3. Create commits
    # dates = list_dates(init_date, end_date)
    # Enum.zip(List.flatten(drawing), dates) |> IO.inspect(limit: :infinity)

    # 4. Congrats!
    # IO.puts("Commits created! Check them with `git log` and manually push them to GitHub.")

    :ok
  end

  def draw_in_console(drawing) do
    for row <- drawing do
      for cell <- row do
        IO.write(if cell == 1, do: "X", else: "-")
      end

      IO.puts("")
    end
  end

  defp init_date_is_less_or_equal_than_end_date?(init_date, end_date) do
    if Date.compare(init_date, end_date) not in [:lt, :eq],
      do: raise("The initial date must be less or equal to the end date.")
  end

  defp list_dates(init_date, end_date) do
    Date.range(init_date, end_date) |> Enum.to_list()
  end
end

# The following drawing represent a boat:
#
#    XXX
#    XXX
#      X
#      X
# XXXXXXXXXXX
#  X       X
#   XXXXXXX

# drawing = [
#   [0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0],
#   [0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
#   [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
#   [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
#   [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0],
#   [0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0]
# ]

# GitHubPixelArt.draw_in_github(drawing, ~D[2024-03-24], ~D[2024-06-08])

# drawing = [
#   [0, 1],
#   [0]
# ]

# GitHubPixelArt.draw_in_console(drawing)
