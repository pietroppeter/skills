library(gt)

exibble |>
  dplyr::select(num, char, currency, date, row, group) |>
  gt(rowname_col = "row", groupname_col = "group") |>
  tab_header(title = md("**exibble**, ported"), subtitle = "gt's example table") |>
  fmt_number(columns = num, decimals = 1) |>
  fmt_currency(columns = currency, currency = "EUR") |>
  fmt_date(columns = date, date_style = "day_month_year") |>
  cols_merge(columns = c(char, date), pattern = "{1} ({2})") |>
  sub_missing(missing_text = "—") |>
  cols_label(num = "Number", char = md("*Fruit*"), currency = "Price") |>
  tab_spanner(label = "Values", columns = c(num, currency)) |>
  tab_style(
    style = cell_fill(color = "#FFF3B0"),
    locations = cells_body(columns = num, rows = num > 100)
  ) |>
  grand_summary_rows(columns = currency, fns = list(Total = ~ sum(., na.rm = TRUE))) |>
  tab_source_note("Data: gt::exibble")
