# 02_taxonomy_map.R
# Purpose: Simple keyword-based taxonomy mapping for regulatory notices

# ---- Helper: safe read text file ----
read_txt <- function(path) {
  if (!file.exists(path)) stop(paste("Missing file:", path))
  paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = " ")
}

# ---- Load metadata ----
meta_path <- file.path("data", "raw", "updates_metadata.csv")
meta <- read.csv(meta_path, stringsAsFactors = FALSE)

# ---- Load taxonomies ----
risk_tax <- read.csv(file.path("taxonomy", "risk_taxonomy.csv"), stringsAsFactors = FALSE)
obl_tax  <- read.csv(file.path("taxonomy", "obligation_tags.csv"), stringsAsFactors = FALSE)

# ---- Tokenise helper ----
count_hits <- function(text, pattern_string) {
  sum(grepl(pattern_string, text, ignore.case = TRUE))
}

# ---- Process each document ----
results <- lapply(seq_len(nrow(meta)), function(i) {
  
  txt <- read_txt(file.path("data", "raw", meta$file_name[i]))
  
  # Risk category scoring
  risk_scores <- sapply(risk_tax$example_keywords, function(p)
    count_hits(txt, p))
  
  top_idx <- order(risk_scores, decreasing = TRUE)[1:2]
  top_risks <- risk_tax$risk_category[top_idx]
  top_risks <- top_risks[risk_scores[top_idx] > 0]
  if (length(top_risks) == 0) top_risks <- "Uncategorised"
  
  # Obligation tags
  obl_hits <- sapply(obl_tax$example_keywords, function(p)
    grepl(p, txt, ignore.case = TRUE))
  obl_tags <- obl_tax$obligation_tag[obl_hits]
  if (length(obl_tags) == 0) obl_tags <- "None"
  
  # Impact score (simple & explainable)
  severity <- grepl("must|required|deadline|enforcement|sanction|penalty",
                    txt, ignore.case = TRUE)
  
  score <- 30 +
    10 * sum(obl_hits) +
    20 * as.integer(severity)
  
  score <- min(100, max(0, score))
  
  data.frame(
    doc_id = meta$doc_id[i],
    date = meta$date[i],
    source = meta$source[i],
    title = meta$title[i],
    risk_categories = paste(top_risks, collapse = "; "),
    obligation_tags = paste(obl_tags, collapse = "; "),
    impact_score = score,
    stringsAsFactors = FALSE
  )
})

change_log <- do.call(rbind, results)

# ---- Write output ----
dir.create("outputs", showWarnings = FALSE)
write.csv(change_log,
          file.path("outputs", "change_log.csv"),
          row.names = FALSE)

message("Created outputs/change_log.csv")

