CREATE TABLE  short_names (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    status INTEGER
);

DO $$
DECLARE
    i INT;
    random_status INTEGER;
BEGIN
    FOR i IN 1..700000 LOOP
        random_status := CASE WHEN RANDOM() < 0.9 THEN 1 ELSE 0 END;

        INSERT INTO short_names (name, status)
        VALUES (FORMAT('nazvanie' || i), random_status);
    END LOOP;
END $$;
CREATE INDEX idx_short_names_name ON short_names(name);

CREATE TABLE full_names (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    status INTEGER
);

DO $$
DECLARE
    i INT;
    ext TEXT;
    EXTENSIONS TEXT[] := ARRAY['wav', 'mp3', 'song', 'ogg', 'flac', 'aiff', 'm4a'];
BEGIN
    FOR i IN 1..500000 LOOP
        ext := EXTENSIONS[1 + FLOOR(RANDOM() * ARRAY_LENGTH(EXTENSIONS, 1))];

        INSERT INTO full_names (name, status)
        VALUES ('nazvanie' || i || '.' || ext, NULL);
    END LOOP;
END $$;
CREATE INDEX idx_full_names_name ON full_names(name);
