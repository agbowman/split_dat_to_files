CREATE PROGRAM cp_def_chart_temp:dba
 SET errormsg = fillstring(255," ")
 SET error_check = error(errormsg,1)
 SELECT INTO "nl:"
  *
  FROM dprotect
  WHERE object_name="CHART_D1"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  DROP DATABASE chart_d1 WITH deps_deleted
  DROP TABLE chart_d1
 ENDIF
 SELECT INTO TABLE "chart_temp"
  e.encntr_id, e.person_id, e.loc_facility_cd,
  e.loc_building_cd, e.loc_nurse_unit_cd, e.loc_room_cd,
  e.loc_bed_cd, e.organization_id, e.create_dt_tm,
  e.encntr_type_cd
  FROM encounter e
  WHERE e.encntr_id=0
 ;end select
 SET error_check = error(errormsg,0)
 IF (error_check != 0)
  CALL echo("FAILURE")
  ROLLBACK
 ELSE
  CALL echo("SUCCESSFUL")
  COMMIT
 ENDIF
END GO
