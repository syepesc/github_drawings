defmodule GitHubPixelArt do
  @doc """
  GitHub commit heatmap is represented with 7 rows as the days of the week,
  and columns for the weeks in a year. As follows:

  ```
              Jan xxxx ... n-month
              w1 w2 w3     wn
  Sunday      [] [] [] ... []
  Monday      [] [] [] ... []
  Tuesday     [] [] [] ... []
  Wednesday   [] [] [] ... []
  Thursday    [] [] [] ... []
  Friday      [] [] [] ... []
  Saturday    [] [] [] ... []
  ```

  Your drawing must be represented as a matrix of a list of lists. With the following rules:
    - `drawing`   - Must be a list of lists with 7 rows and each row must have the same length.
                    Each element of the matrix must be an integer between (including) 0 to 15.
                    Each value represent the number of commits per day.
                    The greater the value the darkest will look in the GitHub heatmap.
    - `init_date` - Must be a sunday that represents the top-left corner of the drawing.
    - `end_date`  - Must be a saturday that represents the bottom-right corner of the drawing.

  Ideally, you should draw in the past (not sure if you can in the future),
  so, make sure your GitHub history has some empty spaces.
  """
  @spec draw_in_github(drawing :: [], init_date :: Date.t(), end_date :: Date.t()) :: :ok
  def draw_in_github(drawing, %Date{} = init_date, %Date{} = end_date) do
    # 1. Validations
    is_init_date_a_sunday?(init_date)
    is_end_date_a_saturday?(end_date)
    is_init_date_less_than_end_date?(init_date, end_date)
    does_drawing_have_seven_rows?(drawing)
    drawing_rows_have_same_length?(drawing)
    are_drawing_values_between_zero_to_fifteen?(drawing)

    # 2. Ask user if the drawing is correct
    # draw_in_console(drawing)
    IO.puts("Does it look like what you are expecting to se in GitHub heatmap?")
    IO.puts("Press 'y' to create the commits for your drawing or any other key to abort.")
    if IO.gets("> ") |> String.trim() != "y", do: raise("Aborted")

    # 3. Create commits
    drawing
    |> drawing_to_commit_dates(init_date)
    |> IO.inspect(limit: :infinity)
    |> Enum.each(&git_commit/1)

    # 4. Congrats!
    IO.puts("Commits created! Check them with `git log` and manually push them to GitHub.")
    :ok
  end

  @doc """
  Since each value of a row is one week after the previous one,
  we can add the week to the initial date to get the current date.
  Then, we add the day to the current date to get the final date.

  Basically were are doing the following:

  ```
  init_date    +0 +7 +14 ... +7n
            +0 [] []  [] ... []
            +1 [] []  [] ... []
            +2 [] []  [] ... []
            +3 [] []  [] ... []
            +4 [] []  [] ... []
            +5 [] []  [] ... []
            +6 [] []  [] ... []
  ```
  """
  def drawing_to_commit_dates(drawing, init_date) do
    drawing
    |> Enum.with_index()
    |> Enum.map(fn {row, week} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {value, day} ->
        List.duplicate(Date.add(Date.add(init_date, week), day * 7), value)
      end)
    end)
    |> List.flatten()
    |> Enum.filter(fn d -> not is_nil(d) end)
  end

  def draw_in_console(drawing) do
    for row <- drawing do
      for cell <- row do
        IO.write(if cell > 0, do: "X", else: "-")
      end

      IO.puts("")
    end
  end

  defp is_init_date_a_sunday?(init_date) do
    if Date.day_of_week(init_date) != 7 do
      raise("The initial date must be a Sunday.")
    end
  end

  defp is_end_date_a_saturday?(init_date) do
    if Date.day_of_week(init_date) != 6 do
      raise("The end date must be a Saturday.")
    end
  end

  defp is_init_date_less_than_end_date?(init_date, end_date) do
    if Date.compare(init_date, end_date) != :lt do
      raise("The initial date must be less than end date.")
    end
  end

  defp does_drawing_have_seven_rows?(drawing) do
    if Enum.count(drawing) != 7 do
      raise("The drawing must have 7 rows.")
    end
  end

  defp drawing_rows_have_same_length?([head | tail] = _drawing) do
    length = length(head)

    if not Enum.all?(tail, fn row -> length(row) == length end) do
      raise("Every row must have the same number of cells.")
    end
  end

  defp are_drawing_values_between_zero_to_fifteen?(drawing) do
    drawing
    |> List.flatten()
    |> Enum.each(fn x ->
      if x not in 0..15, do: raise("The drawing must have values (including) 0 to 15.")
    end)
  end

  defp git_commit(%Date{} = date) do
    # Create ISO date string
    iso_date = Date.to_iso8601(date)

    # Generate random milliseconds (0–9999)
    milliseconds = :rand.uniform(10000) - 1

    # Format padded values
    millisecond_str = String.pad_leading("#{milliseconds}", 4, "0")

    # Assemble ISO 8601 datetime string with random seconds and milliseconds
    iso_datetime = iso_date <> "T12:00:00.#{millisecond_str}Z"

    # Commit message
    message = "Draw a pixel on: #{iso_datetime}"

    # Edit temp file
    File.write!("tmp_commit_file.txt", message)
    File.close("tmp_commit_file.txt")

    # Create commits
    System.cmd("git", ["add", "."])

    System.cmd("git", ["commit", "--date", iso_datetime, "-m", message],
      env: [{"GIT_COMMITTER_DATE", iso_datetime}]
    )
  end
end

# The following drawing represent a boat:
#
#   XXX
#    XXX
#      X
#      X
# XXXXXXXXXXX
#  X       X
#   XXXXXXX

drawing = [
  Enum.map(1..52, fn x -> :rand.uniform(8) end),
  Enum.map(1..52, fn x -> :rand.uniform(8) end),
  Enum.map(1..52, fn x -> :rand.uniform(8) end),
  Enum.map(1..52, fn x -> :rand.uniform(8) end),
  Enum.map(1..52, fn x -> :rand.uniform(8) end),
  Enum.map(1..52, fn x -> :rand.uniform(8) end),
  Enum.map(1..52, fn x -> :rand.uniform(8) end)
]

# drawing = [
#   [5, 0],
#   [0, 2],
#   [0, 0],
#   [0, 0],
#   [0, 0],
#   [0, 0],
#   [0, 0],
# ]

# GitHubPixelArt.draw_in_github(drawing, ~D[2024-08-18], ~D[2024-08-24])
GitHubPixelArt.draw_in_github(drawing, ~D[2023-01-01], ~D[2023-12-30])
