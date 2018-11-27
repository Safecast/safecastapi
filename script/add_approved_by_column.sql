-- Adds the column approved_by to the table measurement_imports
-- and fills it with 'before this feature' for all files
-- that where approved up to this day

ALTER TABLE measurement_imports ADD COLUMN approved_by character varying(255);
Update measurement_imports set approved_by = 'before this feature' where approved = true;
