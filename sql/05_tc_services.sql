-- License: This file is part of TrailCatch
-- Copyright (c) 2024 Ihar Petushkou.
-- 
-- This SQL script is for personal or educational use only.
-- Commercial use, redistribution, or modification is prohibited
-- without explicit permission. See LICENSEfor details.

DROP FUNCTION IF EXISTS tc_fn_users_username_exists;
DROP FUNCTION IF EXISTS tc_fn_users_create;
DROP FUNCTION IF EXISTS tc_fn_users_fetch;
DROP FUNCTION IF EXISTS tc_fn_users_settings_fetch;
DROP FUNCTION IF EXISTS tc_fn_users_update;
DROP FUNCTION IF EXISTS tc_fn_users_dogs_upsert;
DROP FUNCTION IF EXISTS tc_fn_users_dogs_delete;
DROP FUNCTION IF EXISTS tc_fn_users_relationship;
DROP FUNCTION IF EXISTS tc_fn_users_notifs_fetch;
DROP FUNCTION IF EXISTS tc_fn_users_notifs_fetch_for_push;
DROP FUNCTION IF EXISTS tc_fn_users_notifs_mark_all_as_read;
DROP FUNCTION IF EXISTS tc_fn_users_update_latest_trail;

-- -- --

DROP FUNCTION IF EXISTS tc_fn_trails_exists;
DROP FUNCTION IF EXISTS tc_fn_trails_insert;
DROP FUNCTION IF EXISTS tc_fn_trails_update;
DROP FUNCTION IF EXISTS tc_fn_trails_intrash;
DROP FUNCTION IF EXISTS tc_fn_trails_delete;
DROP FUNCTION IF EXISTS tc_fn_trails_fetch;
DROP FUNCTION IF EXISTS tc_fn_trails_fetch0;
DROP FUNCTION IF EXISTS tc_fn_trails_fetch_feed;
DROP FUNCTION IF EXISTS tc_fn_trails_fetch_subscriptions;
DROP FUNCTION IF EXISTS tc_fn_trails_fetch_subscribers;
DROP FUNCTION IF EXISTS tc_fn_trails_fetch_nearest;
DROP FUNCTION IF EXISTS tc_fn_trails_fetch_people;
DROP FUNCTION IF EXISTS tc_fn_trails_likes_fetch;
DROP FUNCTION IF EXISTS tc_fn_trails_likes_top_fetch;
DROP FUNCTION IF EXISTS tc_fn_trails_like;

--
--
--

--! ### ### ### > FUNCTION 

CREATE FUNCTION tc_fn_users_username_exists(
  f_username TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  RETURN(
    SELECT (
      SELECT tcu.username FROM public.tc_users AS tcu
        WHERE tcu.username = f_username
    ) IS NOT NULL
  );
END;
$$;

--! ### ### ### > FUNCTION 

CREATE FUNCTION tc_fn_users_create(
  f_username TEXT,
  f_first_name TEXT,
  f_last_name TEXT,
  f_gender INTEGER,
  f_birthdate DATE,
  f_uiso3 TEXT,
  f_contacts JSONB,
  --
  f_lang TEXT,
  f_msrunit INTEGER,
  f_fdayofweek INTEGER,
  f_timeformat INTEGER,
  f_fcm_token TEXT
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
DECLARE
  secret0 TEXT;
BEGIN
  SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = '***' INTO secret0;

  INSERT INTO public.tc_users VALUES (
    auth.uid(),
    --
    f_username,
    f_first_name,
    f_last_name,
    f_gender,
    f_birthdate,
    f_uiso3,
    extensions.pgp_sym_encrypt(f_contacts::TEXT, secret0)
  );

  INSERT INTO public.tc_users_settings (
    user_id,
    --
    lang,
    msrunit,
    fdayofweek,
    timeformat,
    fcm_token
  )
  VALUES (
    auth.uid(),
    --
    f_lang,
    f_msrunit,
    f_fdayofweek,
    f_timeformat,
    f_fcm_token
  );

  RETURN auth.uid();
END;
$$;

--! ### ### ### > FUNCTION 

CREATE FUNCTION tc_fn_users_fetch(
  f_user_id UUID
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
  
  RETURN(SELECT row_to_json(jsn) FROM(
    SELECT 
      tcu.*,
      '' AS birthdate,
      extensions.pgp_sym_decrypt(tcu.contacts::bytea, secret0)::JSONB AS contacts,
      --
      public.tc_fnlib_age(tcu.birthdate) AS age,
      public.tc_fnlib_rlship(auth.uid(), tcu.user_id) AS rlship,
      public.tc_fnlib_subscrb(tcu.user_id, FALSE) AS subscribers,
      public.tc_fnlib_subscrb(tcu.user_id, TRUE) AS subscriptions,
      public.tc_fnlib_trails_count(tcu.user_id) AS trails,
      public.tc_fnlib_user_likes_count(tcu.user_id) AS user_likes,
      public.tc_fnlib_statistics(tcu.user_id) AS statistics,
      public.tc_fnlib_dogs_fetch(tcu.user_id) AS dogs
    FROM public.tc_users AS tcu
      WHERE tcu.user_id = f_user_id
  ) AS jsn);
END;
$$;

--! ### ### ### > FUNCTION 

CREATE FUNCTION tc_fn_users_settings_fetch()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  RETURN(SELECT row_to_json(jsn) FROM(
    SELECT 
      tcu.birthdate,
      tcus.*,
      public.tc_fnlib_hiddens() AS hiddens,
      public.tc_fnlib_unread_notifs(auth.uid()) AS unread_notifs
    FROM public.tc_users AS tcu
      INNER JOIN public.tc_users_settings AS tcus ON tcus.user_id = tcu.user_id
        WHERE tcu.user_id = auth.uid()
  ) AS jsn);
END;
$$;

--! ### ### ### > FUNCTION 

CREATE FUNCTION tc_fn_users_update(
  f_username TEXT,
  f_first_name TEXT,
  f_last_name TEXT,
  f_gender INTEGER,
  f_birthdate DATE,
  f_uiso3 TEXT,
  f_contacts JSONB,
  --
  f_lang TEXT,
  f_msrunit INTEGER,
  f_fdayofweek INTEGER,
  f_timeformat INTEGER,
  f_faceid INTEGER,
  --
  f_notif_push_likes BOOLEAN,
  f_notif_push_subscribers BOOLEAN,
  --
  f_app_tracking_transparency BOOLEAN,
  f_fcm_token TEXT,
  f_trial_at TIMESTAMPTZ
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
DECLARE
  secret0 TEXT;
BEGIN
  SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = '***' INTO secret0;

  UPDATE public.tc_users AS tcu SET
    username = f_username,
    first_name = f_first_name,
    last_name = f_last_name,
    gender = f_gender,
    birthdate = f_birthdate,
    uiso3 = f_uiso3,
    contacts = extensions.pgp_sym_encrypt(f_contacts::TEXT, secret0)
  WHERE tcu.user_id = auth.uid();

  UPDATE public.tc_users_settings AS tcus SET
    lang = f_lang,
    msrunit = f_msrunit,
    fdayofweek = f_fdayofweek,
    timeformat = f_timeformat,
    faceid = f_faceid,
    --
    notif_push_likes = f_notif_push_likes,
    notif_push_subscribers = f_notif_push_subscribers,
    --
    app_tracking_transparency = f_app_tracking_transparency,
    fcm_token = f_fcm_token,
    trial_at = f_trial_at
  WHERE tcus.user_id = auth.uid();
END;
$$;

--! ### ### ### > FUNCTION 

CREATE FUNCTION tc_fn_users_dogs_upsert(
  f_dog_id UUID,
  --
  f_name TEXT,
  f_gender INTEGER,
  f_birthdate DATE,
  f_breed_id INTEGER,
  f_breed_custom_name TEXT,
  f_in_our_hearts_date_at DATE
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
DECLARE
  d_dog_id UUID;
BEGIN
  IF (f_dog_id IS NULL) THEN
    INSERT INTO public.tc_dogs VALUES(
      DEFAULT,
      auth.uid(),
      --
      f_name,
      f_gender,
      f_birthdate,
      f_breed_id,
      f_breed_custom_name
    ) RETURNING dog_id INTO d_dog_id;
  ELSE 
    UPDATE public.tc_dogs AS tcd
      SET 
        name = f_name,
        gender = f_gender,
        birthdate = f_birthdate,
        breed_id = f_breed_id,
        breed_custom_name = f_breed_custom_name,
        in_our_hearts_date_at = f_in_our_hearts_date_at
      WHERE tcd.dog_id = f_dog_id AND tcd.user_id = auth.uid();
  END IF;

  RETURN d_dog_id;
END;
$$;

--! ### ### ### > FUNCTION 

CREATE FUNCTION tc_fn_users_dogs_delete(
  f_dog_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  IF (f_dog_id IS NOT NULL) THEN
    DELETE FROM public.tc_dogs AS tcd
      WHERE tcd.dog_id = f_dog_id AND tcd.user_id = auth.uid();
  END IF;
END;
$$;

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fn_users_relationship(
  f_user_id UUID,
  f_rlship INTEGER
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  IF (f_rlship = 0 OR f_rlship = 1) THEN
    INSERT INTO public.tc_relationship (
      user1_id,
      user2_id,
      rlship
    ) VALUES (
      auth.uid(),
      f_user_id,
      f_rlship
    );

    IF (f_rlship = 1) THEN
      INSERT INTO public.tc_notifs VALUES(
        DEFAULT,
        f_user_id,
        NULL,
        auth.uid()
      );
    END IF;

  ELSEIF (f_rlship IS NULL) THEN
    DELETE FROM public.tc_relationship AS tcr 
      WHERE tcr.user1_id = auth.uid() AND tcr.user2_id = f_user_id;

    DELETE FROM public.tc_notifs AS tcn
      WHERE tcn.user1_id = f_user_id AND tcn.user2_id = auth.uid()
        AND tcn.trail1_id = NULL AND tcn.send IS FALSE AND tcn.read IS FALSE;
  END IF;
END;
$$;

--! ### ### ### > FUNCTION 

CREATE FUNCTION tc_fn_users_notifs_fetch(
  f_created_from TIMESTAMPTZ,
  f_limit INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  IF (f_limit IS NULL) THEN
    f_limit := 30;
  END IF;

  RETURN(SELECT array_to_json(array_agg(row_to_json(jsn))) FROM(
    SELECT 
      row_to_json(tcn.*) AS notif,
      public.tc_fn_trails_fetch0(tcn.trail1_id) AS trail1,
      public.tc_fn_users_fetch(tcn.user2_id) AS user2,
      public.tc_fnlib_trail_record0(tct.*) AS latest_trail2
    FROM public.tc_users AS tcu
    INNER JOIN public.tc_notifs AS tcn ON tcu.user_id = tcn.user2_id
    LEFT JOIN public.tc_trails AS tct ON tcu.user_id = tct.user_id
    WHERE tcn.user1_id = auth.uid()
      AND (tct.trail_id IS NULL OR tct.trail_id = tcu.latest_trail_id)
      AND (f_created_from IS NULL OR tcn.created_at::timestamp < f_created_from::timestamp)
    ORDER BY tcn.created_at DESC
    LIMIT f_limit
  ) AS jsn);
END;
$$;

--! ### ### ### > FUNCTION 

CREATE FUNCTION tc_fn_users_notifs_fetch_for_push()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
DECLARE
  d_result JSONB;
BEGIN
  SELECT array_to_json(array_agg(row_to_json(jsn))) FROM(
    SELECT 
      tcn.notif_id,
      tcn.user1_id,
      tcn.trail1_id,
      tcn.user2_id,
      tcus.notif_push_likes AS notif_push_likes1,
      tcus.notif_push_subscribers AS notif_push_subscribers1,
      tcus.lang AS lang1,
      tcus.fcm_token AS fcm_token1,
      public.tc_fnlib_unread_notifs(tcn.user1_id) AS unread_notifs
    FROM public.tc_notifs AS tcn
    INNER JOIN public.tc_users_settings AS tcus ON tcus.user_id = tcn.user1_id
    INNER JOIN auth.users AS auth_users ON auth_users.id = tcn.user1_id 
    WHERE tcn.read IS FALSE AND tcn.send IS FALSE
      AND auth_users.last_sign_in_at >= NOW() - INTERVAL '30 days'
  ) AS jsn INTO d_result;

  UPDATE public.tc_notifs AS tcn SET send = TRUE
    WHERE tcn.user1_id IS NOT NULL;

  DELETE FROM public.tc_notifs AS tcn 
    WHERE tcn.created_at < NOW() - INTERVAL '365 days';

  RETURN d_result;
END;
$$;

--! ### ### ### > FUNCTION 

CREATE FUNCTION tc_fn_users_notifs_mark_all_as_read()
RETURNS VOID
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  UPDATE public.tc_notifs AS tcn SET read = TRUE
    WHERE tcn.user1_id = auth.uid();
END;
$$;

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fn_users_update_latest_trail()
RETURNS VOID
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
DECLARE
  d_trail_id UUID;
BEGIN
  SELECT tct.trail_id FROM public.tc_trails AS tct
    WHERE tct.user_id = auth.uid()
        AND tct.intrash IS FALSE AND tct.notpub IS FALSE
      ORDER BY tct.datetime_at DESC LIMIT 1
        INTO d_trail_id;

  UPDATE public.tc_users AS tcu SET
    latest_trail_id = d_trail_id,
    utcp = public.tc_fnlib_calc_utcp(auth.uid())
  WHERE tcu.user_id = auth.uid();
END;
$$;



-- -- -- 
-- -- -- 
-- -- --


--! ### ### ### > FUNCTION 

CREATE FUNCTION tc_fn_trails_exists(
  f_device_data_id TEXT
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  RETURN(
    SELECT tct.trail_id FROM public.tc_trails AS tct
      WHERE tct.device_data_id = f_device_data_id AND tct.user_id = auth.uid()
        LIMIT 1
  );
END;
$$;


--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fn_trails_insert(
  f_type INTEGER,
  f_datetime_at TIMESTAMPTZ,
  f_distance INTEGER,
  f_elevation INTEGER,
  f_time INTEGER,
  --
  f_avg_pace INTEGER,
  f_avg_speed INTEGER,
  --
  f_dogs_ids UUID[],
  --
  f_device INTEGER,
  f_device_data_id TEXT,
  f_device_data JSONB,
  f_device_geopoints TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
DECLARE 
  secret0 TEXT;
  d_row RECORD;
BEGIN
  IF (f_avg_pace IS NULL) THEN 
    f_avg_pace := 0;
  END IF;

   IF (f_avg_speed IS NULL) THEN 
    f_avg_speed := 0;
  END IF;

  SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = '***' INTO secret0;

  INSERT INTO public.tc_trails (
    trail_id,
    user_id,
    --
    type,
    datetime_at,
    distance,
    elevation,
    time,
    --
    avg_pace,
    avg_speed,
    --
    dogs_ids,
    --
    device,
    device_data_id,
    device_data,
    device_geopoints,
    --
    intrash,
    notpub,
    --
    pub_at,
    created_at
  ) VALUES (
    DEFAULT,
    auth.uid(),
    --
    f_type,
    f_datetime_at,
    f_distance,
    f_elevation,
    f_time,
    --
    f_avg_pace,
    f_avg_speed,
    --
    f_dogs_ids,
    --
    f_device,
    f_device_data_id,
    extensions.pgp_sym_encrypt(f_device_data::TEXT, secret0),
    extensions.pgp_sym_encrypt(f_device_geopoints, secret0),
    --
    FALSE,
    TRUE,
    --
    DEFAULT,
    DEFAULT
  ) RETURNING * INTO d_row;

  RETURN public.tc_fn_trails_fetch0(d_row.trail_id);
END;
$$;

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fn_trails_update(
  f_trail_id UUID,
  f_type INTEGER,
  --
  f_avg_pace INTEGER,
  f_avg_speed INTEGER,
  --
  f_dogs_ids UUID[],
  --
  f_device_data JSONB,
  f_device_geopoints TEXT,
  --
  f_intrash BOOLEAN,
  f_notpub BOOLEAN,
  f_pub_at TIMESTAMPTZ
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
DECLARE 
  secret0 TEXT;
  d_row RECORD;
BEGIN
  IF (f_avg_pace IS NULL) THEN 
    f_avg_pace := 0;
  END IF;

  IF (f_avg_speed IS NULL) THEN 
    f_avg_speed := 0;
  END IF;

  SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = '***' INTO secret0;

  IF (f_trail_id IS NOT NULL AND f_type IS NOT NULL) THEN
    UPDATE public.tc_trails AS tct SET 
      type = f_type,
      avg_pace = f_avg_pace,
      avg_speed = f_avg_speed,
      --
      dogs_ids = f_dogs_ids,
      --
      device_data = extensions.pgp_sym_encrypt(f_device_data::TEXT, secret0),
      device_geopoints = extensions.pgp_sym_encrypt(f_device_geopoints, secret0),
      --
      intrash = f_intrash,
      notpub = f_notpub,
      pub_at = f_pub_at
    WHERE tct.trail_id = f_trail_id AND tct.user_id = auth.uid();
  END IF;

  IF (f_notpub IS NOT TRUE) THEN
    PERFORM public.tc_fn_users_update_latest_trail();
  END IF;
END;
$$;

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fn_trails_intrash(
  f_trail_ids UUID[]
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  IF (f_trail_ids IS NOT NULL) THEN
    UPDATE public.tc_trails AS tct SET
      intrash = TRUE,
      notpub = FALSE
    WHERE tct.trail_id = ANY(f_trail_ids) AND tct.user_id = auth.uid();

    PERFORM public.tc_fn_users_update_latest_trail();
  END IF;
END;
$$;

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fn_trails_delete(
  f_trail_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  DELETE FROM public.tc_trails AS tct
    WHERE tct.trail_id = f_trail_id AND tct.user_id = auth.uid();
END;
$$;

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fn_trails_fetch0(
  f_trail_id UUID
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

  RETURN(SELECT row_to_json(jsn) FROM(
    SELECT 
      tct.*,
      extensions.pgp_sym_decrypt(tct.device_data::bytea, secret0)::JSONB AS device_data,
      extensions.pgp_sym_decrypt(tct.device_geopoints::bytea, secret0) AS device_geopoints
    FROM public.tc_trails AS tct
    WHERE tct.trail_id = f_trail_id
  ) AS jsn);
END;
$$;

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fn_trails_fetch(
  f_user_id UUID,
  f_trail_id UUID,
  f_device INTEGER,
  f_type INTEGER,
  f_with_dogs BOOLEAN,
  f_intrash_notpub BOOLEAN,
  f_datetime_from TIMESTAMPTZ,
  f_datetime_to TIMESTAMPTZ,
  f_limit INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  IF (f_limit IS NULL AND f_user_id != auth.uid()) THEN
    f_limit := 30;
  END IF;

  RETURN(SELECT array_to_json(array_agg(row_to_json(jsn))) FROM(
    SELECT 
      public.tc_fn_users_fetch(tcu.user_id) AS user,
      -- trail
      public.tc_fnlib_trail_record0(tct.*) AS trail,
      -- trail ext
      public.tc_fnlib_likes_count(tct.trail_id) AS likes,
      public.tc_fnlib_liked_by_me(tct.trail_id) AS liked_by_me,
      public.tc_fnlib_likes_latest_uuids(tct.trail_id, 4) AS likes_latest_4
    FROM public.tc_trails AS tct
      INNER JOIN public.tc_users AS tcu ON tcu.user_id = tct.user_id
      WHERE 
        (f_user_id IS NULL OR tcu.user_id = f_user_id)
        AND (f_trail_id IS NULL OR tct.trail_id = f_trail_id)
        AND (f_type IS NULL OR tct.type = f_type) 
        AND (f_with_dogs IS NULL OR (
          f_with_dogs IS TRUE AND array_length(tct.dogs_ids, 1) IS NOT NULL
        ) OR (
          f_with_dogs IS FALSE AND array_length(tct.dogs_ids, 1) IS NULL
        ))
        AND (f_device IS NULL OR tct.device = f_device)
        AND (f_datetime_from IS NULL OR tct.datetime_at::timestamp < f_datetime_from::timestamp)
        AND (f_datetime_to IS NULL OR tct.datetime_at::timestamp > f_datetime_to::timestamp)
        AND (f_intrash_notpub IS NULL OR tct.intrash = f_intrash_notpub AND tct.notpub = f_intrash_notpub)
      ORDER BY tct.datetime_at DESC
      LIMIT f_limit
  ) AS jsn);
END;
$$;

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fn_trails_fetch_feed(
  f_type INTEGER,
  f_with_dogs BOOLEAN,
  f_users_genders INTEGER[],
  f_users_ages INTEGER[],
  f_users_uiso3 TEXT[],
  f_dogs_breed INTEGER[],
  f_datetime_from TIMESTAMPTZ,
  f_limit INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  IF (f_limit IS NULL) THEN
    f_limit := 30;
  END IF;

  RETURN(SELECT array_to_json(array_agg(row_to_json(jsn))) FROM(
    SELECT 
      public.tc_fn_users_fetch(tcu.user_id) AS user,
      -- trail
      public.tc_fnlib_trail_record0(tct.*) AS trail,
      -- trail ext
      public.tc_fnlib_likes_count(tct.trail_id) AS likes,
      public.tc_fnlib_liked_by_me(tct.trail_id) AS liked_by_me,
      public.tc_fnlib_likes_latest_uuids(tct.trail_id, 4) AS likes_latest_4
    FROM public.tc_trails AS tct
      INNER JOIN public.tc_users AS tcu ON tcu.user_id = tct.user_id
      INNER JOIN public.tc_relationship AS tcr ON tcr.user2_id = tct.user_id AND tcr.rlship = 1
      WHERE tcr.user1_id = auth.uid()
        AND (f_type IS NULL OR tct.type = f_type) 
        AND (f_with_dogs IS NULL OR (
          f_with_dogs IS TRUE AND array_length(tct.dogs_ids, 1) IS NOT NULL
        ) OR (
          f_with_dogs IS FALSE AND array_length(tct.dogs_ids, 1) IS NULL
        ))
        AND (array_length(f_users_genders, 1) IS NULL OR tcu.gender = ANY(f_users_genders))
        AND (array_length(f_users_ages, 1) IS NULL OR public.tc_fnlib_age(tcu.birthdate) = ANY(f_users_ages))
        AND (array_length(f_users_uiso3, 1) IS NULL OR tcu.uiso3 = ANY(f_users_uiso3))
        AND (array_length(f_dogs_breed, 1) IS NULL OR f_dogs_breed <@ public.tc_fnlib_dogs_breed_ids(tct.dogs_ids))
        AND (f_datetime_from IS NULL OR tct.datetime_at::timestamp < f_datetime_from::timestamp)
        AND tct.intrash IS FALSE AND tct.notpub IS FALSE
      ORDER BY tct.datetime_at DESC
      LIMIT f_limit
  ) AS jsn);
END;
$$;

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fn_trails_fetch_subscriptions(
  f_user_id UUID,
  f_datetime_from TIMESTAMPTZ,
  f_hiddens BOOLEAN,
  f_limit INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
DECLARE
  d_rlship INTEGER;
BEGIN
  IF (f_limit IS NULL) THEN
    f_limit := 30;
  END IF;

  d_rlship := 1;
  IF (f_hiddens IS TRUE) THEN
    d_rlship := 0;
  END IF;

  RETURN(SELECT array_to_json(array_agg(row_to_json(jsn))) FROM(
    SELECT 
      public.tc_fn_users_fetch(tcu.user_id) AS user,
      -- trail
      public.tc_fnlib_trail_record0(tct.*) AS trail,
      -- trail ext
      public.tc_fnlib_likes_count(tct.trail_id) AS likes,
      public.tc_fnlib_liked_by_me(tct.trail_id) AS liked_by_me,
      public.tc_fnlib_likes_latest_uuids(tct.trail_id, 4) AS likes_latest_4
    FROM public.tc_users AS tcu
    INNER JOIN public.tc_relationship AS tcr ON tcr.user2_id = tcu.user_id AND tcr.rlship = d_rlship
    LEFT JOIN public.tc_trails AS tct ON tcu.user_id = tct.user_id
      WHERE tcr.user1_id = f_user_id
        AND (tct.trail_id IS NULL OR tct.trail_id = tcu.latest_trail_id)
        AND (f_datetime_from IS NULL OR tct.datetime_at::timestamp < f_datetime_from::timestamp)
      ORDER BY tct.datetime_at DESC
      LIMIT f_limit
  ) AS jsn);
END;
$$;

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fn_trails_fetch_subscribers(
  f_user_id UUID,
  f_datetime_from TIMESTAMPTZ,
  f_limit INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  IF (f_limit IS NULL) THEN
    f_limit := 30;
  END IF;

  RETURN(SELECT array_to_json(array_agg(row_to_json(jsn))) FROM(
    SELECT 
      public.tc_fn_users_fetch(tcu.user_id) AS user,
      -- trail
      public.tc_fnlib_trail_record0(tct.*) AS trail,
      -- trail ext
      public.tc_fnlib_likes_count(tct.trail_id) AS likes,
      public.tc_fnlib_liked_by_me(tct.trail_id) AS liked_by_me,
      public.tc_fnlib_likes_latest_uuids(tct.trail_id, 4) AS likes_latest_4
    FROM public.tc_users AS tcu
    INNER JOIN public.tc_relationship AS tcr ON tcr.user1_id = tcu.user_id AND tcr.rlship = 1
    LEFT JOIN public.tc_trails AS tct ON tcu.user_id = tct.user_id
      WHERE tcr.user2_id = f_user_id
        AND (tct.trail_id IS NULL OR tct.trail_id = tcu.latest_trail_id)
        AND (f_datetime_from IS NULL OR tct.datetime_at::timestamp < f_datetime_from::timestamp)
      ORDER BY tct.datetime_at DESC
      LIMIT f_limit
  ) AS jsn);
END;
$$;

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fn_trails_fetch_nearest(
  f_geopoint TEXT,
  f_type INTEGER,
  f_with_dogs BOOLEAN,
  f_users_genders INTEGER[],
  f_users_ages INTEGER[],
  f_users_uiso3 TEXT[],
  f_dogs_breed INTEGER[],
  f_stranges_only BOOLEAN,
  f_offset INTEGER,
  f_limit INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
DECLARE
  secret0 TEXT;
BEGIN
  IF (f_limit IS NULL) THEN
    f_limit := 30;
  END IF;

  SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = '***' INTO secret0;

  RETURN(SELECT array_to_json(array_agg(row_to_json(jsn))) FROM(
    SELECT 
      public.tc_fn_users_fetch(tcu.user_id) AS user,
      -- trail
     public.tc_fnlib_trail_record0(tct.*) AS trail,
      -- trail ext
      public.tc_fnlib_likes_count(tct.trail_id) AS likes,
      public.tc_fnlib_liked_by_me(tct.trail_id) AS liked_by_me,
      public.tc_fnlib_likes_latest_uuids(tct.trail_id, 4) AS likes_latest_4
    FROM public.tc_trails AS tct
      INNER JOIN public.tc_users AS tcu ON tcu.user_id = tct.user_id
      LEFT JOIN public.tc_relationship AS tcr ON tcr.user2_id = tct.user_id
      WHERE 
        tcu.user_id != auth.uid()
        AND (tcr.user1_id IS NULL OR (tcr.user1_id = auth.uid() AND tcr.rlship != 0))
        AND (f_stranges_only IS NULL OR f_stranges_only IS TRUE AND tcr.rlship IS NULL)
        AND tct.trail_id = tcu.latest_trail_id
        AND (f_type IS NULL OR tct.type = f_type) 
        AND (f_with_dogs IS NULL OR (
          f_with_dogs IS TRUE AND array_length(tct.dogs_ids, 1) IS NOT NULL
        ) OR (
          f_with_dogs IS FALSE AND array_length(tct.dogs_ids, 1) IS NULL
        ))
        AND (array_length(f_users_genders, 1) IS NULL OR tcu.gender = ANY(f_users_genders))
        AND (array_length(f_users_ages, 1) IS NULL OR public.tc_fnlib_age(tcu.birthdate) = ANY(f_users_ages))
        AND (array_length(f_users_uiso3, 1) IS NULL OR tcu.uiso3 = ANY(f_users_uiso3))
        AND (array_length(f_dogs_breed, 1) IS NULL OR f_dogs_breed <@ public.tc_fnlib_dogs_breed_ids(tct.dogs_ids))
        AND tct.intrash IS FALSE AND tct.notpub IS FALSE
        AND tct.device_geopoints IS NOT NULL
      ORDER BY extensions.ST_Distance(
          f_geopoint::extensions.geography, 
          extensions.ST_AsText(extensions.pgp_sym_decrypt(tct.device_geopoints::bytea, secret0))::extensions.geography,
          false
      ) ASC
      LIMIT f_limit
      OFFSET f_offset
  ) AS jsn);
END;
$$;

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fn_trails_fetch_people(
  f_offset INTEGER,
  f_limit INTEGER,
  f_search_q TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  IF (f_limit IS NULL) THEN
    f_limit := 30;
  END IF;

  IF (length(f_search_q) <= 2) THEN
    f_search_q := NULL;
  END IF;

  RETURN(SELECT array_to_json(array_agg(row_to_json(jsn))) FROM(
    SELECT 
      public.tc_fn_users_fetch(tcu.user_id) AS user,
      -- trail
     public.tc_fnlib_trail_record0(tct.*) AS trail,
      -- trail ext
      public.tc_fnlib_likes_count(tct.trail_id) AS likes,
      public.tc_fnlib_liked_by_me(tct.trail_id) AS liked_by_me,
      public.tc_fnlib_likes_latest_uuids(tct.trail_id, 4) AS likes_latest_4
    FROM public.tc_trails AS tct
      INNER JOIN public.tc_users AS tcu ON tcu.user_id = tct.user_id
      WHERE 
        (tct.trail_id IS NULL OR tct.trail_id = tcu.latest_trail_id)
        AND (f_search_q IS NULL
          OR tcu.username ILIKE '%' || f_search_q || '%' 
          OR tcu.first_name ILIKE '%' || f_search_q || '%'
          OR tcu.last_name ILIKE '%' || f_search_q || '%'
        )
      LIMIT f_limit
      OFFSET f_offset
  ) AS jsn);
END;
$$;

--! ### ### ### > FUNCTION 

CREATE FUNCTION tc_fn_trails_likes_fetch(
  f_trail_id UUID,
  --
  f_created_at TIMESTAMPTZ,
  f_limit INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  IF (f_limit IS NULL) THEN
    f_limit := 30;
  END IF;

  RETURN(SELECT array_to_json(array_agg(row_to_json(jsn))) FROM(
      SELECT 
        public.tc_fn_users_fetch(tcu.user_id) AS user,
        --
        ttl.created_at AS like_created_at,
        -- trail
        public.tc_fnlib_trail_record0(tct.*) AS trail,
        -- trail ext
        public.tc_fnlib_likes_count(tct.trail_id) AS likes,
        public.tc_fnlib_liked_by_me(tct.trail_id) AS liked_by_me,
        public.tc_fnlib_likes_latest_uuids(tct.trail_id, 4) AS likes_latest_4
      FROM public.tc_users AS tcu
      INNER JOIN public.tc_trails_likes AS ttl ON tcu.user_id = ttl.user_id
      LEFT JOIN public.tc_trails AS tct ON tcu.user_id = tct.user_id
        WHERE ttl.trail_id = f_trail_id
          AND (tct.trail_id IS NULL OR tct.trail_id = tcu.latest_trail_id)
          AND (f_created_at IS NULL OR ttl.created_at::timestamp < f_created_at::timestamp)
        ORDER BY ttl.created_at DESC
        LIMIT f_limit
  ) AS jsn);
END;
$$;

--! ### ### ### > FUNCTION 

CREATE FUNCTION tc_fn_trails_likes_top_fetch(
  f_user_id UUID,
  --
  f_limit INTEGER,
  f_offset INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  IF (f_limit IS NULL) THEN
    f_limit := 30;
  END IF;

  RETURN(SELECT array_to_json(array_agg(row_to_json(jsn))) FROM(
    SELECT 
      count(ttl.trail_id) AS trail_likes_count, 
      public.tc_fn_users_fetch(tcu.user_id) AS user,
      -- trail
      public.tc_fnlib_trail_record0(tct.*) AS trail,
      -- trail ext
      public.tc_fnlib_likes_count(tct.trail_id) AS likes,
      public.tc_fnlib_liked_by_me(tct.trail_id) AS liked_by_me,
      public.tc_fnlib_likes_latest_uuids(tct.trail_id, 4) AS likes_latest_4
    FROM public.tc_trails_likes AS ttl
    INNER JOIN public.tc_trails AS tct ON tct.trail_id = ttl.trail_id
    INNER JOIN public.tc_users AS tcu ON tcu.user_id = tct.user_id
      WHERE tct.user_id = f_user_id
        AND tct.intrash IS FALSE AND tct.notpub IS FALSE
      GROUP BY ttl.trail_id, tcu.user_id, trail, tct.trail_id
      ORDER BY trail_likes_count DESC
      LIMIT f_limit
      OFFSET f_offset
  ) AS jsn);
END;
$$;

--! ### ### ### > FUNCTION

CREATE FUNCTION tc_fn_trails_like(
  f_user_id UUID,
  f_trail_id UUID,
  f_like BOOLEAN
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY definer SET search_path = ''
AS 
$$
BEGIN
  IF (f_like IS TRUE) THEN
    INSERT INTO public.tc_trails_likes VALUES (
      f_trail_id,
      auth.uid()
    );

    INSERT INTO public.tc_notifs VALUES(
      DEFAULT,
      f_user_id,
      f_trail_id,
      auth.uid()
    );
  ELSE
    DELETE FROM public.tc_trails_likes AS tctl 
      WHERE tctl.trail_id = f_trail_id AND tctl.user_id = auth.uid();

    DELETE FROM public.tc_notifs AS tcn
      WHERE tcn.user1_id = f_user_id AND tcn.user2_id = auth.uid()
        AND tcn.trail1_id = f_trail_id AND tcn.send IS FALSE AND tcn.read IS FALSE;
  END IF;
END;
$$;

--
--
--


REVOKE EXECUTE ON FUNCTION public.tc_fn_trails_exists FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_trails_exists TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_users_username_exists FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_users_username_exists TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_users_create FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_users_create TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_users_fetch FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_users_fetch TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_users_settings_fetch FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_users_settings_fetch TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_users_update FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_users_update TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_users_dogs_upsert FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_users_dogs_upsert TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_users_dogs_delete FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_users_dogs_delete TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_users_relationship FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_users_relationship TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_users_notifs_fetch FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_users_notifs_fetch TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_users_notifs_fetch_for_push FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_users_notifs_fetch_for_push TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_users_notifs_mark_all_as_read FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_users_notifs_mark_all_as_read TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_users_update_latest_trail FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_users_update_latest_trail TO authenticated;

-- -- --

REVOKE EXECUTE ON FUNCTION public.tc_fn_trails_insert FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_trails_insert TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_trails_update FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_trails_update TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_trails_intrash FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_trails_intrash TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_trails_delete FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_trails_delete TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_trails_fetch FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_trails_fetch TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_trails_fetch0 FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_trails_fetch0 TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_trails_fetch_feed FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_trails_fetch_feed TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_trails_fetch_subscriptions FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_trails_fetch_subscriptions TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_trails_fetch_subscribers FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_trails_fetch_subscribers TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_trails_fetch_nearest FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_trails_fetch_nearest TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_trails_fetch_people FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_trails_fetch_people TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_trails_likes_fetch FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_trails_likes_fetch TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_trails_likes_top_fetch FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_trails_likes_top_fetch TO authenticated;

REVOKE EXECUTE ON FUNCTION public.tc_fn_trails_like FROM public, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.tc_fn_trails_like TO authenticated;