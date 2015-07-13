USE wmf;
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
       is_pageview = true
AND
       month IN(06,07)
GROUP BY
       year, month, day, uri_host, CASE WHEN x_analytics RLIKE('https=1') THEN true ELSE false END;
