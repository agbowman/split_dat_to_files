CREATE PROGRAM cclocdcheck:dba
 PROMPT
  "Enter ocd number start to check if installed for environment : " = 0,
  "Enter ocd number end to check if installed for environment   : " = 999999
 SELECT
  a.*, b.*
  FROM dm_alpha_features_env a,
   dm_environment b
  PLAN (a
   WHERE a.alpha_feature_nbr BETWEEN  $1 AND  $2)
   JOIN (b
   WHERE b.environment_id=a.environment_id)
  WITH nocounter
 ;end select
END GO
