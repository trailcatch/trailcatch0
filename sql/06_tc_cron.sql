-- License: This file is part of TrailCatch
-- Copyright (c) 2024 Ihar Petushkou.
-- 
-- This SQL script is for personal or educational use only.
-- Commercial use, redistribution, or modification is prohibited
-- without explicit permission. See LICENSEfor details.


DO
$$
DECLARE 
  d_is BOOLEAN;
BEGIN
  SELECT jobname IS NOT NULL INTO d_is FROM cron.job
    WHERE jobname = 'tc_cron_every_5th_minute';

  IF (d_is IS TRUE) THEN
    SELECT cron.unschedule('tc_cron_every_5th_minute');
  END IF;

  PERFORM 
  cron.schedule(
    'tc_cron_every_5th_minute',
    '*/5 * * * *',
    $CRON$
      SELECT
        net.http_post(
            url:='https://<project>.supabase.co/functions/v1/fn_push',
            headers:='{"Content-Type": "application/json", "Authorization": "Bearer ***"}'::jsonb,
            body:='{}'::JSONB
        ) AS request_id;
    $CRON$
    );
END;
$$;