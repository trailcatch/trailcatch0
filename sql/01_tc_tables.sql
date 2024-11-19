-- License: This file is part of TrailCatch
-- Copyright (c) 2024 Ihar Petushkou.
-- 
-- This SQL script is for personal or educational use only.
-- Commercial use, redistribution, or modification is prohibited
-- without explicit permission. See LICENSEfor details.

DROP TABLE IF EXISTS tc_notifs;
DROP TABLE IF EXISTS tc_users;
DROP TABLE IF EXISTS tc_users_settings;
DROP TABLE IF EXISTS tc_dogs;
DROP TABLE IF EXISTS tc_trails_likes;
DROP TABLE IF EXISTS tc_trails;
DROP TABLE IF EXISTS tc_relationship;


--! ### ### ### > TABLE

CREATE TABLE tc_trails(
  trail_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,

  type INTEGER NOT NULL,
  datetime_at TIMESTAMPTZ NOT NULL,
  distance INTEGER NOT NULL,
  elevation INTEGER NOT NULL,
  time INTEGER NOT NULL,

  avg_pace INTEGER NOT NULL DEFAULT 0,
  avg_speed INTEGER NOT NULL DEFAULT 0,

  dogs_ids UUID[] NOT NULL DEFAULT ARRAY[]::UUID[],

  device INTEGER NOT NULL,
  device_data_id TEXT NOT NULL,
  device_data TEXT,
  device_geopoints TEXT,

  intrash BOOLEAN NOT NULL DEFAULT FALSE,
  notpub BOOLEAN NOT NULL DEFAULT FALSE,

  pub_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() at time zone 'utc')
);

CREATE INDEX tc_ix_trails_user_id_datetime_at_desc ON tc_trails (user_id, datetime_at DESC);
CREATE INDEX tc_ix_trails_user_id_device ON tc_trails (user_id, device);
CREATE INDEX tc_ix_trails_user_id_device_data_id ON tc_trails (user_id, device_data_id);
CREATE INDEX tc_ix_trails_datetime_at ON tc_trails (datetime_at DESC);
CREATE INDEX tc_ix_trails_type ON tc_trails (type);

ALTER TABLE tc_trails ENABLE ROW LEVEL SECURITY;
CREATE POLICY "all_restrict" ON tc_trails AS RESTRICTIVE FOR ALL TO anon, authenticated USING ( TRUE ); 

--! ### ### ### > TABLE 

CREATE TABLE tc_trails_likes(
  trail_id UUID NOT NULL REFERENCES tc_trails(trail_id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,

  created_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() at time zone 'utc'),
  PRIMARY KEY(trail_id, user_id)
);

CREATE INDEX tc_ix_trails_likes_trail_id_created_at ON tc_trails_likes (trail_id, created_at DESC);

ALTER TABLE tc_trails_likes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "all_restrict" ON tc_trails_likes AS RESTRICTIVE FOR ALL TO anon, authenticated USING ( TRUE ); 

--! ### ### ### > TABLE 

CREATE TABLE tc_users(
  user_id UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  
  username TEXT UNIQUE,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  gender INTEGER NOT NULL,
  birthdate DATE NOT NULL,
  uiso3 TEXT,
  contacts TEXT,

  utcp INTEGER NOT NULL DEFAULT 0,
  latest_trail_id UUID REFERENCES tc_trails (trail_id),

  PRIMARY KEY(user_id)
);

CREATE INDEX tc_ix_users_gender ON tc_users (gender);
CREATE INDEX tc_ix_users_birthdate ON tc_users (birthdate);
CREATE INDEX tc_ix_users_uiso3 ON tc_users (uiso3);
CREATE INDEX tc_ix_users_username ON tc_users USING gin (username gin_trgm_ops);
CREATE INDEX tc_ix_users_first_name ON tc_users USING gin (first_name gin_trgm_ops);
CREATE INDEX tc_ix_users_last_name ON tc_users USING gin (last_name gin_trgm_ops);

ALTER TABLE tc_users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "all_restrict" ON tc_users AS RESTRICTIVE FOR ALL TO anon, authenticated USING ( TRUE );

--! ### ### ### > TABLE 

CREATE TABLE tc_users_settings(
  user_id UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,

  lang TEXT NOT NULL DEFAULT 'en',
  msrunit INTEGER NOT NULL DEFAULT 1,
  fdayofweek INTEGER NOT NULL DEFAULT 1,
  timeformat INTEGER NOT NULL DEFAULT 24,
  faceid INTEGER NOT NULL DEFAULT -1,

  notif_push_likes BOOLEAN NOT NULL DEFAULT TRUE,
  notif_push_subscribers BOOLEAN NOT NULL DEFAULT TRUE,

  fcm_token TEXT NOT NULL DEFAULT '',
  app_tracking_transparency BOOLEAN NOT NULL DEFAULT TRUE,
  trial_at TIMESTAMPTZ,

  etc JSONB NOT NULL DEFAULT '{}'::JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() at time zone 'utc'),

  PRIMARY KEY(user_id)
);

ALTER TABLE tc_users_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "all_restrict" ON tc_users_settings AS RESTRICTIVE FOR ALL TO anon, authenticated USING ( TRUE );

--! ### ### ### > TABLE

CREATE TABLE tc_dogs(
  dog_id UUID DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,

  name TEXT NOT NULL,
  gender INTEGER NOT NULL,
  birthdate DATE NOT NULL,
  breed_id INTEGER NOT NULL DEFAULT 0,
  breed_custom_name TEXT NOT NULL DEFAULT '',
  in_our_hearts_date_at DATE,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() at time zone 'utc'),

  PRIMARY KEY(dog_id, user_id)
);

CREATE INDEX tc_ix_dogs_breed_id ON tc_dogs (breed_id);

ALTER TABLE tc_dogs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "all_restrict" ON tc_dogs AS RESTRICTIVE FOR ALL TO anon, authenticated USING ( TRUE ); 

--! ### ### ### > TABLE 

CREATE TABLE tc_relationship(
  user1_id UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  user2_id UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  rlship INTEGER NOT NULL,

  created_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() at time zone 'utc'),
  PRIMARY KEY(user1_id, user2_id)
);

CREATE INDEX tc_ix_relationship_user1_id_user2_id_rlship ON tc_relationship (user1_id, user2_id, rlship);

ALTER TABLE tc_relationship ENABLE ROW LEVEL SECURITY;
CREATE POLICY "all_restrict" ON tc_relationship AS RESTRICTIVE FOR ALL TO anon, authenticated USING ( TRUE );

--! ### ### ### > TABLE 

CREATE TABLE tc_notifs(
  notif_id BIGSERIAL PRIMARY KEY,

  user1_id UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  trail1_id UUID REFERENCES tc_trails (trail_id) ON DELETE CASCADE,
  
  user2_id UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,

  send BOOLEAN NOT NULL DEFAULT FALSE,
  read BOOLEAN NOT NULL DEFAULT FALSE,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() at time zone 'utc')
);

CREATE INDEX tc_ix_notifs_user1_id_created_at ON tc_notifs (user1_id, created_at DESC);

ALTER TABLE tc_notifs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "all_restrict" ON tc_notifs AS RESTRICTIVE FOR ALL TO anon, authenticated USING ( TRUE );