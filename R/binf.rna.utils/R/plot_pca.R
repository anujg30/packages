#' plot_pca_deseq2
#'
#' This function allows to perform deseq2 diff exp analysis
#' @param gene_set_groups
#' @keywords GSEA gmt
#' @export
#' @examples
#' plot_pca_deseq2()

plot_pca_deseq2 <- function(rld){
  data <- plotPCA(rld, intgroup=c("Subject", "Status"), returnData=TRUE)
  percentVar <- round(100 * attr(data, "percentVar"))
  p <- ggplot(data, aes(PC1, PC2, color=Status)) +
    geom_point(size=3) +
    xlab(paste0("PC1: ",percentVar[1],"% variance")) +
    ylab(paste0("PC2: ",percentVar[2],"% variance"))

  ### geom_label_repel
  q <- p +
    geom_label_repel(aes(label = name),
                     box.padding   = 0.15,
                     point.padding = 0.3,
                     segment.color = 'grey50') +
    theme_classic()
  return(q)
}

#pca with labels
plot_pca_df <- function(df,samples){
  pc <- prcomp(t(df))
  df_out <- as.data.frame(pc$x)
  df_out$group <- samples$Status
  df_out$group2 <- samples$Exp
  df_out$name <- samples$name

  percentage <- round(pc$sdev / sum(pc$sdev) * 100, 2)
  percentage <- paste( colnames(df_out), "(", paste( as.character(percentage), "%", ")", sep="") )

  p<-ggplot(df_out,aes(x=PC1,y=PC2,color=group,shape=group2))
  p<-p+geom_point(size= 3) + xlab(percentage[1]) + ylab(percentage[2])
  ### geom_label_repel
  p <- p +
    geom_label_repel(aes(label = name),
                     box.padding   = 0.15,
                     point.padding = 0.3,
                     segment.color = 'grey50') +
    theme_classic()
  return(p)
}

#pca without labels
plot_pca_df.2 <- function(df,samples,col=NULL,shape=NULL){
  pc <- prcomp(t(df))
  df_out <- as.data.frame(pc$x)
  df_out$group <- samples$Status
  df_out$group2 <- samples$Exp
  df_out$group3 <- paste0(samples$Exp,samples$Status)
  df_out$name <- samples$name

  eigs <- pc$sdev^2
  per_table <- rbind(
    SD = sqrt(eigs),
    Proportion = eigs/sum(eigs),
    Cumulative = cumsum(eigs)/sum(eigs))
  percentage <- round(per_table["Proportion",]*100,2)
  percentage <- paste( colnames(df_out), "(", paste( as.character(percentage), "%", ")", sep="") )
  
  if(is.null(col)){
    mypal = pal_npg("nrc", alpha = 0.9)(6)
    col = mypal[c(6,4,4,5,1,1)]
  }
  
  if(is.null(shape)){
    shape = c(16, 2, 17, 2)
  }
  
  
  p <- ggplot(df_out,aes(x=PC1,y=PC2,color=group3,shape=group)) +
    scale_shape_manual(values=shape)+
    scale_color_manual(values=col)
  p <- p + geom_point(size= 3) + xlab(percentage[1]) + ylab(percentage[2])
  ### geom_label_repel
  p <- p +
    theme_classic()
  return(p)
}

#get features that contribute to principal components
get_features <- function(df, samples){
  pc <- prcomp(t(df))
  # Compute Coordinates
  loadings <- pc$rotation
  sdev <- pc$sdev
  var.coord <- t(apply(loadings, 1, var_coord_func, sdev)) 
  # Compute Cos2
  var.cos2 <- var.coord^2
  # Compute contributions
  comp.cos2 <- apply(var.cos2, 2, sum)
  contrib <- function(var.cos2, comp.cos2){var.cos2*100/comp.cos2}
  var.contrib <- t(apply(var.cos2,1, contrib, comp.cos2))
  return(var.contrib)
}

# Helper function 
var_coord_func <- function(loadings, comp.sdev){
  loadings*comp.sdev
}
