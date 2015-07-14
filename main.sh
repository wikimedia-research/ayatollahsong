export HADOOP_HEAPSIZE=1024 && hive -f base_query.sql > iran_data.tsv && hive -f search_query.sql > iran_search_data.tsv

hive -f user_agents.sql > iran_ua_data.tsv && hive -f search_user_agents.sql > iran_search_ua_data.tsv

R CMD BATCH main.R
