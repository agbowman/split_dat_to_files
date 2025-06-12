CREATE PROGRAM afc_cvt_tier_matrix:dba
 RECORD tier_matrix(
   1 tier_matrix_qual = i4
   1 tier_matrix[*]
     2 tier_cell_type_cd = f8
     2 tier_cell_id = f8
     2 tier_cell_value = f8
 )
 SET g_price_sched_cd = 0.0
 SET code_set = 13036
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=code_set
   AND a.cdf_meaning="PRICESCHED"
   AND a.active_ind=1
  DETAIL
   g_price_sched_cd = a.code_value
  WITH nocounter
 ;end select
 CALL echo(build("Price Sched cd: ",g_price_sched_cd))
 SET g_org_cd = 0.0
 SET code_set = 13036
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=code_set
   AND a.cdf_meaning="ORG"
   AND a.active_ind=1
  DETAIL
   g_org_cd = a.code_value
  WITH nocounter
 ;end select
 CALL echo(build("Org cd: ",g_org_cd))
 SET g_interface_cd = 0.0
 SET code_set = 13036
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=code_set
   AND a.cdf_meaning="INTERFACE"
   AND a.active_ind=1
  DETAIL
   g_interface_cd = a.code_value
  WITH nocounter
 ;end select
 CALL echo(build("Interface Cd: ",g_interface_cd))
 SET g_flat_disc_cd = 0.0
 SET code_set = 13036
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=code_set
   AND a.cdf_meaning="FLAT_DISC"
   AND a.active_ind=1
  DETAIL
   g_flat_disc_cd = a.code_value
  WITH nocounter
 ;end select
 CALL echo(build("FLAT DISC Cd: ",g_flat_disc_cd))
 SET g_diagreqd_cd = 0.0
 SET code_set = 13036
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=code_set
   AND a.cdf_meaning="DIAGREQD"
   AND a.active_ind=1
  DETAIL
   g_diagreqd_cd = a.code_value
  WITH nocounter
 ;end select
 CALL echo(build("DIAGREQD Cd: ",g_diagreqd_cd))
 SET g_physreqd_cd = 0.0
 SET code_set = 13036
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=code_set
   AND a.cdf_meaning="PHYSREQD"
   AND a.active_ind=1
  DETAIL
   g_physreqd_cd = a.code_value
  WITH nocounter
 ;end select
 CALL echo(build("PHYSREQD Cd: ",g_physreqd_cd))
 SET count1 = 0
 SELECT INTO "nl:"
  t.tier_cell_id, t.tier_cell_type_cd, t.tier_cell_value
  FROM tier_matrix t
  DETAIL
   count1 = (count1+ 1), stat = alterlist(tier_matrix->tier_matrix,count1), tier_matrix->tier_matrix[
   count1].tier_cell_type_cd = t.tier_cell_type_cd,
   tier_matrix->tier_matrix[count1].tier_cell_id = t.tier_cell_id, tier_matrix->tier_matrix[count1].
   tier_cell_value = evaluate(t.tier_cell_value_id,0.00,t.tier_cell_value,t.tier_cell_value_id)
  WITH nocounter
 ;end select
 SET tier_matrix->tier_matrix_qual = count1
 UPDATE  FROM tier_matrix t,
   (dummyt d1  WITH seq = value(tier_matrix->tier_matrix_qual))
  SET t.updt_id = 950000, t.updt_task = 950000, t.updt_applctx = 950000,
   t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.tier_cell_value_id =
   IF ((tier_matrix->tier_matrix[d1.seq].tier_cell_type_cd=g_price_sched_cd)) tier_matrix->
    tier_matrix[d1.seq].tier_cell_value
   ELSEIF ((tier_matrix->tier_matrix[d1.seq].tier_cell_type_cd=g_org_cd)) tier_matrix->tier_matrix[d1
    .seq].tier_cell_value
   ELSEIF ((tier_matrix->tier_matrix[d1.seq].tier_cell_type_cd=g_interface_cd)) tier_matrix->
    tier_matrix[d1.seq].tier_cell_value
   ELSEIF ((tier_matrix->tier_matrix[d1.seq].tier_cell_type_cd=g_flat_disc_cd)) 0
   ELSEIF ((tier_matrix->tier_matrix[d1.seq].tier_cell_type_cd=g_diagreqd_cd)) 0
   ELSEIF ((tier_matrix->tier_matrix[d1.seq].tier_cell_type_cd=g_physreqd_cd)) 0
   ELSE tier_matrix->tier_matrix[d1.seq].tier_cell_value
   ENDIF
   , t.tier_cell_entity_name =
   IF ((tier_matrix->tier_matrix[d1.seq].tier_cell_type_cd=g_price_sched_cd)) "PRICE_SCHED"
   ELSEIF ((tier_matrix->tier_matrix[d1.seq].tier_cell_type_cd=g_org_cd)) "ORGANIZATION"
   ELSEIF ((tier_matrix->tier_matrix[d1.seq].tier_cell_type_cd=g_interface_cd)) "INTERFACE_FILE"
   ELSEIF ((tier_matrix->tier_matrix[d1.seq].tier_cell_type_cd=g_flat_disc_cd)) " "
   ELSEIF ((tier_matrix->tier_matrix[d1.seq].tier_cell_type_cd=g_diagreqd_cd)) " "
   ELSEIF ((tier_matrix->tier_matrix[d1.seq].tier_cell_type_cd=g_physreqd_cd)) " "
   ELSE "CODE_VALUE"
   ENDIF
  PLAN (d1)
   JOIN (t
   WHERE (t.tier_cell_id=tier_matrix->tier_matrix[d1.seq].tier_cell_id))
  WITH nocounter
 ;end update
 COMMIT
 FREE SET tier_matrix
END GO
