#' Critical t-statistic
#'
#' This function calculates the critical t-statistic to limit the false discovery
#' rate (Benjamini and Hochberg 1995) for a marginal effects plot to a specified level.
#'
#' @param me.vec A vector of marginal effects.
#' @param me.sd.vec A vector of standard deviations for the marginal effects.
#' @param df Degrees of freedom.
#' @param type Should the BH (Benjamini and Hochberg 1999) or BY (Benjamini and Yekutieli 2000) correction be used? Options are "BH" (the default) or "BY".
#' @param level The level of confidence. Defaults to 0.95.
#'
#' @examples
#' \dontrun{ 
#' data(legfig)                # Clark and Golder 2006 replication data
#' 
#' # limit to established democracies from the 1990s
#' dat<-subset(legfig, subset=(nineties==1 & old==1))
#' 
#' lin.mod <- lm(enep1 ~ eneg + logmag + logmag_eneg + uppertier_eneg + uppertier +
#' proximity1 + proximity1_enpres + enpres, data=dat)
#' 
#' # save betas
#' beta.mod <- coefficients(lin.mod)
#' # save vcv
#' vcv.mod <- vcov(lin.mod)
#' 
#' # calculate MEs
#' mag <- seq(from=0.01, to=5, by=0.01)
#' me.vec <- beta.mod[2] + beta.mod[4]*mag
#' me.se <- sqrt( vcv.mod[2,2] + (mag^2)*vcv.mod[4,4] + 2*(mag)*(vcv.mod[2,4]) )
#' 
#' ci.hi <- me.vec + 1.697 * me.se
#' ci.lo <- me.vec - 1.697 * me.se
#' 
#' plot(me.vec ~ mag, type="l", ylim = c(-4, 6))
#' lines(ci.hi ~ mag, lty=2)
#' lines(ci.lo ~ mag, lty=2)
#' 
#' fdrInteraction(me.vec, me.se, df=lin.mod$df, level=0.90)                  # 4.233986
#' 
#' ci.hi <- me.vec + 4.233986 * me.se
#' ci.lo <- me.vec - 4.233986 * me.se
#' 
#' lines(ci.hi ~ mag, lty=2, lwd=2)
#' lines(ci.lo ~ mag, lty=2, lwd=2)
#' 
#' abline(h=0, lty=1, col="gray")
#' legend("topleft", lwd=c(1,2), lty=c(1,2), legend=c("90% CI", "90% FDR CI"))
#' }
#' @return The critical t-statistic for the interaction.
#' @author Justin Esarey and Jane Lawrence Sumner
#' @references Benjamini, Yoav, and Yosef Hochberg. 1995. "Controlling the False Discovery Rate: A Practical and Powerful Approach to Multiple Testing." \emph{Journal of the Royal Statistical Society, Series B} 57(1): 289-300.
#' @references Benjamini, Yoav, and Daniel Yekutieli. 2001. "The Control of the False Discovery Rate in Multiple Testing Under Dependency." \emph{The Annals of Statistics} 29(4): 1165-1188.
#' @references Clark, William R., and Matt Golder. 2006. "Rehabilitating Duverger's Theory." \emph{Comparative Political Studies} 39(6): 679-708.
#' @references Esarey, Justin, and Jane Lawrence Sumner. 2017. "Marginal Effects in Interaction Models: Determining and Controlling the False Positive Rate." \emph{Comparative Political Studies} 51(9): 1144-1176.
#' @references Esarey, Justin, and Jane Lawrence Sumner. 2018. "Corrigendum to 'Marginal Effects in Interaction Models: Determining and Controlling the False Positive Rate.'"
#' @importFrom stats pt qt
#' @export


fdrInteraction <- function(me.vec, me.sd.vec, df, type="BH", level=0.95){
  
  alpha <- (1-level)
  
  t.vals <- (me.vec / me.sd.vec)
  p.vals <- 2*pmin( pt(t.vals, df=df), (1-pt(t.vals, df=df)) )
  
  if(type=="BH"){multiplier <- (1:length(me.vec)) / length(me.vec)}
  if(type=="BY"){multiplier <- ((1:length(me.vec)) / length(me.vec))*(1/sum(1/(1:length(me.vec))))}
  if(type %in% c("BH","BY")==F){stop("type must be BH or BY")}
  
  o <- order(p.vals)
  
  test <- 0
  i <- 1 + length(me.vec)
  
  while(test==0 & i > 1){
    
    i <- i - 1
    test <- min( p.vals[o][1:i] <= multiplier[i]*(alpha) )
    
  }
  
  if(i==1){cat("Note: hit end of process w/o detecting statistically significant relationship", "\n", "\n")}
  
  critical.t <- abs( qt(multiplier[i]*(alpha/2), df) )
  return(critical.t)
  
}