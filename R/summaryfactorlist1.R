#' Summarise a set of factors by a dependent variable
#'
#' Internal function, not called directly.
#'
#' @param .data Dataframe.
#' @param dependent Character vector of length 1:  name of depdendent variable
#'   (2 to 5 factor levels).
#' @param explanatory Character vector of any length: name(s) of explanatory
#'   variables.
#' @param cont Summary for continuous variables: mean (standard deviation) or
#'   median (interquartile range).
#' @param p Logical: Include statistical test (see
#'   \code{\link[Hmisc]{summary.formula}}).
#' @param na_include Logical: include missing data in summary (\code{NA}).
#' @param column Logical: Compute margins by column rather than row.
#' @param total_col Logical: include a total column summing across factor
#'   levels.
#' @param orderbytotal Logical: order final table by total column high to low.
#' @param fit_id Logical: not used directly, allows merging via
#'   \code{\link{finalfit_merge}}.
#' @param na_to_missing Logical: convert \code{NA} to 'Missing' when
#'   \code{na_include=TRUE}.
#' @param add_dependent_label Add the name of the dependent label to the top
#'   left of table
#' @param dependent_label_prefix Add text before dependent label
#' @param dependent_label_suffix Add text after dependent label
#' @return Returns a \code{factorlist} dataframe.
#' @export
#'
#' @keywords internal
summary_factorlist1 <- function(.data, dependent, explanatory,  cont="mean", p=FALSE, na_include=FALSE,
                                column=FALSE, total_col=FALSE, orderbytotal=FALSE, fit_id=FALSE,
                                na_to_missing = TRUE, add_dependent_label=FALSE,
                                dependent_label_prefix="Dependent: ", dependent_label_suffix=""){

  s <- summary_formula(as.formula(paste(dependent, "~", paste(explanatory, collapse="+"))), data = .data,
                               method="reverse", overall=FALSE,
                               test=TRUE,na.include=na_include, continuous=5)
  df.out = plyr::ldply(s$stats, function(x){
    if(dim(x)[2] == 13){ #hack to get continuous vs categorical. Wouldn't work for factor with 13 levels
      # Continuous variables
      # Mean (SD)
      if (cont == "mean"){
        a = paste0(round(x[1,12], 1), " (", round(x[1,13], 1), ")")
        row1_name = dimnames(x)[[2]][12]
        row2_name = dimnames(x)[[2]][13]
      }

      # Median (IQR)
      if (cont == "median"){
        a = paste0(x[1,6], " (", x[1,8]-x[1,4], ")")
        row1_name = "Median"
        row2_name = "IQR"}

      col1_name = dimnames(x)[[1]][1]
      df.out = data.frame(paste0(row1_name, " (", row2_name, ")"), a)
      names(df.out) = c("levels", col1_name)
      return(df.out)

    } else {
      # Factor variables
      row_name = dimnames(x)$w
      col1_name = dimnames(x)$g[1]
      col1 = x[,1]
      total = col1
      if (column == FALSE) {
        col1_prop = (col1/apply(x, 1, sum))*100 # row margin
      } else {
        col1_prop = (col1/sum(col1))*100 # column margin
        total_prop = (total/sum(total))*100
      }
      a = paste0(col1, " (", sprintf("%.1f", round(col1_prop, 1)), ")") #sprintf to keep trailing zeros
      if (total_col == FALSE){
        df.out = data.frame(row_name, a)
        names(df.out) = c("levels", col1_name)
      } else if (total_col == TRUE & column == FALSE) {
        df.out = data.frame(row_name, a, total, total)
        names(df.out) = c("levels", col1_name, "Total", "index_total")
      } else if (total_col == TRUE & column == TRUE) {
        df.out = data.frame(row_name, a, paste0(total, " (", sprintf("%.1f", round(total_prop, 1)), ")"), total)
        names(df.out) = c("levels", col1_name, "Total", "index_total")
      }
    }
    return(df.out)
  })
  # Keep original order
  df.out$index = 1:dim(df.out)[1]

  if (p == TRUE){
    a = plyr::ldply(s$testresults, function(x) sprintf("%.3f",round(x[[1]], 3)))
    names(a) = c(".id", "p")
    df.out = merge(df.out, a, by=".id")
  }

  # Add back in actual labels
  df.labels = data.frame(".id" = names(s$stats), "label" = s$labels)
  df.out.labels = merge(df.out, df.labels, by = ".id")
  if (orderbytotal==FALSE){
    df.out.labels = df.out.labels[order(df.out.labels$index),] # reorder columns
  } else {
    df.out.labels = df.out.labels[order(-df.out.labels$index_total),] # reorder columns
  }

  # Reorder columns
  label_index = which(names(df.out.labels) == "label")
  not_label_index = which(names(df.out.labels) != "label")
  df.out.labels = df.out.labels[,c(label_index,not_label_index)]

  # Add glm levels name
  if (fit_id){
    levels = as.character(df.out.labels$levels)
    levels[levels == "Mean (SD)"] = ""
    levels[levels == "Median (IQR)"] = ""
    df.out.labels$fit_id = paste0(df.out.labels$.id, levels)
  }

  # Remove
  if (!fit_id) {
    index_index = which(names(df.out.labels) == "index")
  }else{
    index_index = 0
  }
  id_index = which(names(df.out.labels) == ".id")
  index_total_index = which(names(df.out.labels) == "index_total")
  df.out.labels = df.out.labels[,-c(id_index, index_total_index, index_index)]

  # Remove duplicate labels
  df.out.labels = rm_duplicate_labels(df.out.labels, na_to_missing = na_to_missing)

  # Add dependent name label
  if(add_dependent_label){
    df.out.labels = dependent_label(df.out=df.out.labels, .data=.data, dependent,
                                    prefix=dependent_label_prefix, suffix = dependent_label_suffix)
  }

  return(df.out.labels)
}
