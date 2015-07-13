USE wmf;
ADD JAR /home/ironholds/refinery-hive-0.0.12-SNAPSHOT.jar;
CREATE TEMPORARY FUNCTION is_search AS 'org.wikimedia.analytics.refinery.hive.IsSearchRequestUDF';
SELECT
       year,
       month,
       day,
       uri_host,
       CASE WHEN x_analytics RLIKE('https=1') THEN true ELSE false END AS is_https,

       COUNT(*)
FROM
       webrequest
WHERE
       geocoded_data['country_code'] = 'IR'
AND
       webrequest_source IN('text','mobile')
AND
       is_search(uri_path, uri_query)
AND
       month IN(06,07)
GROUP BY
       year, month, day, uri_host, CASE WHEN x_analytics RLIKE('https=1') THEN true ELSE false END;
