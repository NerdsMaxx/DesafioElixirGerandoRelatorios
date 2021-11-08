defmodule GenReport do
  alias GenReport.Parser

  # construir relatório
  def build(filename) do
    list =
      filename
      |> Parser.parse_file()

    Enum.reduce(list, initialize_report_acc(list), fn line, report_acc ->
      sum_values(line, report_acc)
    end)
  end

  def build() do
    {:error, "Insira o nome de um arquivo"}
  end

  # somar valores e atualizar o map
  def sum_values([name, hours, _day, month, year], %{
        "all_hours" => people_hours,
        "hours_per_month" => people_month,
        "hours_per_year" => people_year
      }) do

    %{
      "all_hours" => people_hours |> sum_people_hours(name, hours),
      "hours_per_month" => people_month |> sum_people_month(name, hours, month),
      "hours_per_year" => people_year |> sum_people_year(name, hours, year)
    }
  end

  defp sum_people_hours(people_hours, name, hours) do
    Map.put(people_hours, name, people_hours[name] + hours)
  end

  defp sum_people_month(people_month, name, hours, month) do
    Map.put(people_month, name, update_value(people_month[name], month, hours))
  end

  defp sum_people_year(people_year, name, hours, year) do
    Map.put(people_year, name, update_value(people_year[name], year, hours))
  end

  defp update_value(map, key, value) do
    Map.put(map, key, map[key] + value)
  end

  # inicializar acumulador antes de construir relatório
  defp initialize_list_name(list, value) do
    Enum.reduce(list, %{}, fn [name, _, _, _, _], acc -> Map.put(acc, name, value) end)
  end

  defp initialize_report_acc(list) do
    %{
      "all_hours" => initialize_report_acc(list, "hours"),
      "hours_per_month" => initialize_report_acc(list, "months"),
      "hours_per_year" => initialize_report_acc(list, "years")
    }
  end

  defp initialize_report_acc(list, "hours" = _option) do
    initialize_list_name(list, 0)
  end

  defp initialize_report_acc(list, "months" = _option) do
    months = Enum.reduce(list, %{}, fn [_, _, _, month, _], acc -> Map.put(acc, month, 0) end)
    initialize_list_name(list, months)
  end

  defp initialize_report_acc(list, "years" = _option) do
    years = Enum.reduce(list, %{}, fn [_, _, _, _, year], acc -> Map.put(acc, year, 0) end)
    initialize_list_name(list, years)
  end
end
