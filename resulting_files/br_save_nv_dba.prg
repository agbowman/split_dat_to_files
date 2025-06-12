CREATE PROGRAM br_save_nv:dba
 INSERT  FROM br_name_value_temp
  (br_name_value_id, br_client_id, br_nv_key1,
  br_name, br_value)(SELECT
   b.br_name_value_id, b.br_client_id, b.br_nv_key1,
   b.br_name, b.br_value
   FROM br_name_value b
   WHERE b.br_client_id > 0
    AND b.br_nv_key1 IN ("STEP_CAT_MEAN", "LICENSE")
   WITH nocounter, skipbedrock = 1)
 ;end insert
END GO
