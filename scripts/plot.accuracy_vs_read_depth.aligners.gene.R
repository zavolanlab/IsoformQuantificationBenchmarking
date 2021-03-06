#!/usr/bin/Rscript

############
## Header ##
############
# Created: Jan 04, 2015
# Author: Alexander Kanitz
# Company: Zavolan Group, Biozentrum, University of Basel

###################
## CLI arguments ##
###################
args <- commandArgs(trailingOnly = TRUE)
root <- args[1]

################
## Parameters ##
################
plot_function_source <- file.path(root, "scripts", "plotting_functions.accuracy_vs_read_depth.R")
source(plot_function_source)
in_path <- file.path(root, "analyzed_data")
prefix_all <- file.path(root, "plots", "sim.gene.mappers.accuracy_vs_read_depth.all")
prefix_expressed <- file.path(root, "plots", "sim.gene.mappers.accuracy_vs_read_depth.expressed")
col_all <- 2
col_expressed <- 4
col_names <- c("sim_1", "sim_3", "sim_10", "sim_30", "sim_100")
select_all <- select_expressed <- c("CEM", "CEM_tophat", "Cufflinks", "Cufflinks_tophat", "MMSEQ", "MMSEQ_bowtie", "RSEM", "RSEM_bowtie", "Scripture", "Scripture_tophat")
colors <- c(rep("#B58900", 2), rep("#DC322f", 2), rep("#A300A3", 2), rep("#268BD2", 2), rep("#009914", 2))
chars <- rep(1:2, 5)

###############
## Functions ##
###############
## Merge multiple dataframes from list
merge_df_from_ls <- function(ls, by=0, all=TRUE) {
        mdf <- ls[[1]]
        for (df in 2:length(ls)) {
                mdf <- merge(mdf, ls[[df]], by=by, all=all)
                rownames(mdf) <- mdf$Row.names
                mdf <- mdf[,-1]
        }
        return(mdf)
}
## Rename methods
rename_methods <- function(names) {
        segemehl <- grep("_", names, invert=TRUE)
        names[segemehl] <- paste(names[segemehl], "(segemehl custom)")
        names <- gsub("_bowtie", " (Bowtie)", names)
        names <- gsub("_tophat", " (TopHat)", names)
        return(names)
}

###############
## Load data ##
###############
feature <- list()
feature$sim_1 <- read.table(file.path(in_path, "reference_comparison_Ground_truth.sim_1.gene.spearman.tab"))
feature$sim_3 <- read.table(file.path(in_path, "reference_comparison_Ground_truth.sim_3.gene.spearman.tab"))
feature$sim_10 <- read.table(file.path(in_path, "reference_comparison_Ground_truth.sim_10.gene.spearman.tab"))
feature$sim_30 <- read.table(file.path(in_path, "reference_comparison_Ground_truth.sim_30.gene.spearman.tab"))
feature$sim_100 <- read.table(file.path(in_path, "reference_comparison_Ground_truth.sim_100.gene.spearman.tab"))

################
## Merge data ##
################
all_features_ls <- mapply(function (element, name) {
        colnames(element)[[col_all]] <- name
        return(element[,col_all,drop=FALSE])
}, feature, col_names, SIMPLIFY=FALSE)
all_features <- merge_df_from_ls(all_features_ls)
expressed_features_ls <- mapply(function (element, name) {
        colnames(element)[[col_expressed]] <- name
        return(element[,col_expressed,drop=FALSE])
}, feature, col_names, SIMPLIFY=FALSE)
expressed_features <- merge_df_from_ls(expressed_features_ls)

#######################
## Write data tables ##
#######################
all_filename <- paste0(prefix_all, ".tab")
write.table(all_features, all_filename, quote=FALSE, sep='\t')
expressed_filename <- paste0(prefix_expressed, ".tab")
write.table(expressed_features, expressed_filename, quote=FALSE, sep='\t')

###############################
## Select methods/conditions ##
###############################
all_features <- all_features[select_all, ]
expressed_features <- expressed_features[select_expressed, ]

###############################
## Rename methods/conditions ##
###############################
rownames(all_features) <- rename_methods(rownames(all_features))
rownames(expressed_features) <- rename_methods(rownames(expressed_features))

####################
## Generate plots ##
####################
plot_accuracy_depth(all_features, prefix_all, 0.6, colors=colors, chars=chars)
plot_accuracy_depth(expressed_features, prefix_expressed, 0.8, colors=colors, chars=chars)
