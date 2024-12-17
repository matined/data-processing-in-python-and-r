# Assignment no. 3
# Task 3

library(stringi)
library(mclust)

# 1.) Path to data sets and algorithms results
#     
data_path <- './clustering-data-v1'
results_path <- './clustering-results-v1/original'

# 2.) Input information

sets_collection <- c('fcps', 'graves', 'sipu', 'uci')

algorithms <- c('fastcluster_average',
                'fastcluster_complete',
                'fastcluster_ward',
                'fastcluster_centroid',
                'fastcluster_median',
                'sklearn_kmeans',
                'sklearn_spectral',
                'GenieIc', 'ITM')

# 3.) Evaluate the results

# list of correct labelling
data_files <- list.files(file.path(data_path, sets_collection), 
                        recursive = TRUE,
                        full.names = TRUE, 
                        pattern = 'labels0.gz')

# vector of data names
data_names <- stri_replace_all_fixed(basename(data_files),
                                     ".labels0.gz",
                                     "")
# empty list prepared to store ARI values for each algorithm
# on each data set
r <- vector(mode = 'list', length = length(algorithms))
names(r) <- algorithms # each element will correspond to 
                       # one, particular algorithm

for(method in algorithms){ # main loop: for each method
    
    # storage for results evaluationfor this particular method
    # on each data set
    
    r[[method]] <- numeric(length(data_files))
    names(r[[method]]) <- data_names
    
    for(f in data_files){ # secondary loop: for each data set
        # lets retrieve data identifier
        data <- stri_replace_all_fixed(basename(f),
                                       ".labels0.gz",
                                       "")
        # and the name of the collection the data came from
        collection <- stri_replace_all_fixed(dirname(f),
                                             data_path,
                                             "")
        collection <- stri_replace_all_fixed(collection,
                                             "/", "")
        # We will read correct labeling 
        y <- read.csv(f, header = FALSE)[, 1]
        # and create the path to the result file
        # acording to the naming rules
        result_path <- file.path(results_path, 
                           method, 
                           collection,
                           paste(data, 
                                 '.result', 
                                 max(y), # number of groups is retrieve from correct labeling
                                 '.gz', sep = ''))
        # If it possible we will read the data
        # and calculate the ARI index of 
        # this method on this data set
        tryCatch({
            prediction <- read.csv(result_path)[, 1]
            r[[method]][data] <- adjustedRandIndex(prediction, y)
        }, error = function(e) NA) 
        # if error occurs NA will be given instead
    }
}

R <- data.frame(r) # transform into data frame

