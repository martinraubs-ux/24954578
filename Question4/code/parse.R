.parse_list_string <- function(x) {
  x <- as.character(x)
  x[is.na(x)] <- "[]"
  cleaned <- gsub("\\[|\\]|'", "", x)
  cleaned <- trimws(cleaned)
  out <- strsplit(cleaned, ",\\s*")
  out <- lapply(out, function(v) v[v != ""])
  out
}