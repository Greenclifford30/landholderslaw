-- Draft reservation primitive. Caller MUST commit this in a separate transaction
-- before exposing a reference or attempting matter creation. No authorization,
-- timezone choice, or automatic commit is provided by this function.
CREATE FUNCTION reserve_matter_number(requested_year integer, requested_token uuid)
RETURNS TABLE(allocation_id bigint, reference_year integer, sequence_value bigint)
LANGUAGE plpgsql AS $$
DECLARE existing matter_number_allocations%ROWTYPE; next_value bigint;
BEGIN
 IF requested_token IS NULL OR requested_year IS NULL OR requested_year NOT BETWEEN 1 AND 9999 THEN
  RAISE EXCEPTION 'valid year and allocation token are required' USING ERRCODE='22023';
 END IF;
 -- The same token always takes the same lock; collisions only serialize work.
 PERFORM pg_advisory_xact_lock(hashtextextended(requested_token::text, 467412));
 SELECT * INTO existing FROM matter_number_allocations a WHERE a.allocation_token=requested_token;
 IF FOUND THEN
  IF existing.reference_year <> requested_year THEN
   RAISE EXCEPTION 'allocation token is already bound to another year' USING ERRCODE='22023';
  END IF;
  RETURN QUERY SELECT existing.id,existing.reference_year,existing.sequence_value;
  RETURN;
 END IF;
 INSERT INTO matter_number_counters AS c(reference_year,last_value) VALUES(requested_year,1)
 ON CONFLICT ON CONSTRAINT matter_number_counters_pkey DO UPDATE SET last_value=c.last_value+1
 RETURNING last_value INTO next_value;
 INSERT INTO matter_number_allocations AS a(reference_year,sequence_value,allocation_token)
 VALUES(requested_year,next_value,requested_token)
 RETURNING a.* INTO existing;
 RETURN QUERY SELECT existing.id,existing.reference_year,existing.sequence_value;
END $$;
