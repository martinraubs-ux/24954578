

explode_list_col <- function(df, col, style = c("bracket", "comma")) {
  style <- match.arg(style)
  vec <- df[[col]]
  if (style == "bracket") {
    parts <- .parse_list_string(vec)
  } else {
    vec_chr <- ifelse(is.na(vec), "", as.character(vec))
    parts <- strsplit(vec_chr, ",\\s*")
  }
  n <- lengths(parts)
  n[n == 0] <- 1L
  parts[lengths(parts) == 0] <- NA_character_
  out <- df[rep(seq_len(nrow(df)), n), , drop = FALSE]
  out[[paste0(col, "_single")]] <- trimws(unlist(parts))
  rownames(out) <- NULL
  out
}