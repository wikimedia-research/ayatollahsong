USE wmf;
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
       is_pageview = true
AND
       month IN(06,07) AND day = 08
GROUP BY
       year, month, day, user_agent
