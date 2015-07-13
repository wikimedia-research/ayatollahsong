export HADOOP_HEAPSIZE=1024 && hive -f base_query.sql > iran_data.tsv && hive -f search_query.sql > iran_search_data.tsv

R CMD BATCH main.R
