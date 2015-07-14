USE wmf;
ADD JAR /home/ironholds/refinery-hive-0.0.12-SNAPSHOT.jar;
CREATE TEMPORARY FUNCTION is_search AS 'org.wikimedia.analytics.refinery.hive.IsSearchRequestUDF';
SELECT
       year,
       month,
       day,
       user_agent,
       COUNT(*) AS pageviews
FROM
       webrequest
WHERE
       geocoded_data['country_code'] = 'IR'
AND
       webrequest_source IN('text','mobile')
AND
       is_search(uri_path, uri_query)
AND
       month IN(06,07) AND day = 08
GROUP BY
       year, month, day, user_agent
