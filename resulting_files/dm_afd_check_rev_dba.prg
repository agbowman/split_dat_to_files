CREATE PROGRAM dm_afd_check_rev:dba
 SET env_id =  $1
 SET rev_nbr = 0.000
 SELECT INTO "nl:"
  d.rev_number
  FROM dm_alpha_features d,
   dm_alpha_features_env e
  WHERE d.alpha_feature_nbr=e.alpha_feature_nbr
   AND e.environment_id=env_id
  ORDER BY d.rev_number DESC
  DETAIL
   IF (d.rev_number > rev_nbr)
    rev_nbr = d.rev_number
   ENDIF
  WITH nocounter
 ;end select
 SET to_rev = 0.000
 SELECT INTO "nl:"
  de.schema_version
  FROM dm_environment de
  WHERE de.environment_id=env_id
  DETAIL
   to_rev = de.schema_version
  WITH nocounter
 ;end select
 IF (to_rev < rev_nbr)
  SELECT
   *
   FROM dual
   DETAIL
    col 10, "***********************************************", row + 2,
    col 10, "THIS REV CANNOT BE INSTALLED .....", row + 2,
    tempstr = build("AFD REV  ",rev_nbr," IS HIGHER THAN THIS REV  ",to_rev), col 10, tempstr,
    row + 2, col 10, "***********************************************",
    row + 2
   WITH nocounter, maxcol = 132, maxrow = 1
  ;end select
 ELSE
  SELECT
   *
   FROM dual
   DETAIL
    col 10, "***********************************************", row + 2,
    col 10, "THIS REV CAN BE INSTALLED ......", row + 2,
    tempstr = build("AFD REV  ",rev_nbr," IS NOT HIGHER THAN THIS REV ",to_rev), col 10, tempstr,
    row + 2, col 10, "***********************************************",
    row + 2
   WITH nocounter, maxcol = 132, maxrow = 1
  ;end select
 ENDIF
END GO
