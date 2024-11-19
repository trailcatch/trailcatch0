-- License: This file is part of TrailCatch
-- Copyright (c) 2024 Ihar Petushkou.
-- 
-- This SQL script is for personal or educational use only.
-- Commercial use, redistribution, or modification is prohibited
-- without explicit permission. See LICENSEfor details.

DROP FUNCTION IF EXISTS tc_fnlib_rlship;
DROP FUNCTION IF EXISTS tc_fnlib_age;
DROP FUNCTION IF EXISTS tc_fnlib_subscrb;
DROP FUNCTION IF EXISTS tc_fnlib_hiddens;
DROP FUNCTION IF EXISTS tc_fnlib_unread_notifs;
DROP FUNCTION IF EXISTS tc_fnlib_trails_count;
DROP FUNCTION IF EXISTS tc_fnlib_user_likes_count;
DROP FUNCTION IF EXISTS tc_fnlib_statistics;
DROP FUNCTION IF EXISTS tc_fnlib_dogs_fetch;
DROP FUNCTION IF EXISTS tc_fnlib_likes_latest_uuids;
DROP FUNCTION IF EXISTS tc_fnlib_likes_count;
DROP FUNCTION IF EXISTS tc_fnlib_liked_by_me;
DROP FUNCTION IF EXISTS tc_fnlib_dogs_breed_ids; 
DROP FUNCTION IF EXISTS tc_fnlib_calc_utcp; 
DROP FUNCTION IF EXISTS tc_fnlib_trail_record0; 

--
--
--

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fnlib_rlship(
  f_user1_id UUID,
  f_user2_id UUID
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  IF (f_user1_id = f_user2_id AND f_user1_id = auth.uid()) THEN
    RETURN NULL;
  END IF;

  RETURN (
    SELECT tcr.rlship FROM public.tc_relationship AS tcr 
      WHERE tcr.user1_id = f_user1_id AND tcr.user2_id = f_user2_id
  );
END;
$$;

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fnlib_age(
  f_birthdate DATE
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  RETURN DATE_PART('YEAR', AGE(CURRENT_DATE, f_birthdate));
END;
$$;

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fnlib_subscrb(
  f_user_id UUID,
  f_subscriptions BOOLEAN
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  IF (f_subscriptions IS NULL) THEN 
    f_subscriptions := FALSE;
  END IF;

  IF (f_subscriptions IS TRUE) THEN
    RETURN (
      SELECT count(tcr.user1_id) FROM public.tc_relationship AS tcr 
        WHERE tcr.user1_id = f_user_id AND tcr.rlship = 1
    );
  ELSEIF (f_subscriptions IS FALSE) THEN
    RETURN (
      SELECT count(tcr.user1_id) FROM public.tc_relationship AS tcr 
        WHERE tcr.user2_id = f_user_id AND tcr.rlship = 1
    );
  END IF;
END;
$$;

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fnlib_hiddens()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  RETURN (
    SELECT count(tcr.user1_id) FROM public.tc_relationship AS tcr 
      WHERE tcr.user1_id = auth.uid() AND tcr.rlship = 0
  );
END;
$$;

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fnlib_unread_notifs(
  f_user_id UUID
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  RETURN (
    SELECT count(*) FROM (
      SELECT 
        count(*) as count,
        tcn.trail1_id,
        DATE_TRUNC('day', tcn.created_at) AS created_at
      FROM public.tc_notifs AS tcn 
        WHERE tcn.user1_id = f_user_id AND tcn.read IS FALSE
        GROUP BY tcn.trail1_id, DATE_TRUNC('day', tcn.created_at)
    ) as count
  );
END;
$$;

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fnlib_trails_count(
  f_user_id UUID
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  RETURN (
    SELECT count(tct.trail_id) FROM public.tc_trails AS tct 
      WHERE tct.user_id = f_user_id
        AND tct.intrash IS FALSE AND tct.notpub IS FALSE
  );
END;
$$;

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fnlib_user_likes_count(
  f_user_id UUID
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  RETURN (
    SELECT count(tct.trail_id) FROM public.tc_trails_likes AS ttl 
    INNER JOIN public.tc_trails AS tct ON tct.trail_id = ttl.trail_id
      WHERE tct.user_id = f_user_id
        AND tct.intrash IS FALSE AND tct.notpub IS FALSE
  );
END;
$$;

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fnlib_statistics(
  f_user_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  RETURN (
   SELECT array_to_json(array_agg(row_to_json(jsn))) FROM(
    SELECT 
      tct.type AS type,
      tct.dogs_ids AS dogs_ids,
      --
      count(tct.trail_id) AS count, 
      sum(tct.distance) AS distance, 
      sum(tct.elevation) AS elevation, 
      sum(tct.time) AS time, 
      avg(tct.avg_pace) AS avg_pace, 
      avg(tct.avg_speed) AS avg_speed, 
      --
      DATE_TRUNC('day', tct.datetime_at) AS date_at
        FROM public.tc_trails AS tct
          WHERE tct.user_id = f_user_id
            AND tct.intrash IS FALSE AND tct.notpub IS FALSE
          GROUP BY tct.type, dogs_ids, DATE_TRUNC('day', tct.datetime_at)
    ) AS jsn
  );
END;
$$;

--! ### ### ### > FUNCTION 

CREATE FUNCTION tc_fnlib_dogs_fetch(
  f_user_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  RETURN(SELECT array_to_json(array_agg(row_to_json(jsn))) FROM(
    SELECT tcd.*
      FROM public.tc_dogs AS tcd
        WHERE tcd.user_id = f_user_id
  ) AS jsn);
END;
$$;

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fnlib_likes_latest_uuids(
  f_trail_id UUID,
  f_limit INTEGER
)
RETURNS TEXT[]
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  IF (f_limit IS NULL) THEN
    f_limit := 1;
  END IF;

  RETURN(ARRAY(
    SELECT ttl.user_id FROM public.tc_trails_likes AS ttl
      WHERE ttl.trail_id = f_trail_id
      ORDER BY ttl.created_at DESC
      LIMIT f_limit
  ));
END;
$$;

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fnlib_likes_count(
  f_trail_id UUID
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  RETURN(
    SELECT COUNT(ttl.trail_id) FROM public.tc_trails_likes AS ttl
      WHERE ttl.trail_id = f_trail_id
  );
END;
$$;

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fnlib_liked_by_me(
  f_trail_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  RETURN((
    SELECT ttl.user_id FROM public.tc_trails_likes AS ttl
      WHERE ttl.trail_id = f_trail_id AND ttl.user_id = auth.uid()
  ) IS NOT NULL);
END;
$$;

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fnlib_dogs_breed_ids(
  f_dogs_ids UUID[]
)
RETURNS INTEGER[]
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  RETURN(
    SELECT DISTINCT(tcd.breed_id) FROM public.tc_dogs AS tcd WHERE tcd.dog_id = ANY(f_dogs_ids)
  );
END;
$$;

--! ### ### ### > FUNCTION 

CREATE FUNCTION tc_fnlib_calc_utcp(
  f_user_id UUID
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  RETURN(
    SELECT SUM(tct.distance) FROM public.tc_trails AS tct 
      WHERE tct.user_id = f_user_id
      AND tct.intrash IS FALSE AND tct.notpub IS FALSE
  );
END;
$$;

--! ### ### ### > FUNCTION 

CREATE FUNCTION tc_fnlib_trail_record0(
  f_trail_record RECORD
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
DECLARE
  secret0 TEXT;
BEGIN
  SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = '***' INTO secret0;

  RETURN (
   SELECT row_to_json(jsn) FROM(
      SELECT 
        f_trail_record.*,
        extensions.pgp_sym_decrypt(f_trail_record.device_data::bytea, secret0)::JSONB AS device_data,
        extensions.pgp_sym_decrypt(f_trail_record.device_geopoints::bytea, secret0) AS device_geopoints
    ) AS jsn
  );
END;
$$;

--
--
--

REVOKE EXECUTE ON FUNCTION public.tc_fnlib_rlship FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fnlib_rlship TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fnlib_age FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fnlib_age TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fnlib_subscrb FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fnlib_subscrb TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fnlib_hiddens FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fnlib_hiddens TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fnlib_unread_notifs FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fnlib_unread_notifs TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fnlib_trails_count FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fnlib_trails_count TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fnlib_user_likes_count FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fnlib_user_likes_count TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fnlib_statistics FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fnlib_statistics TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fnlib_dogs_fetch FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fnlib_dogs_fetch TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fnlib_likes_latest_uuids FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fnlib_likes_latest_uuids TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fnlib_likes_count FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fnlib_likes_count TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fnlib_liked_by_me FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fnlib_liked_by_me TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fnlib_dogs_breed_ids FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fnlib_dogs_breed_ids TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fnlib_calc_utcp FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fnlib_calc_utcp TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fnlib_trail_record0 FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fnlib_trail_record0 TO authenticated;
