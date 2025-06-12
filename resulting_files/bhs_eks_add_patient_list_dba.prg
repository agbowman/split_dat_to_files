CREATE PROGRAM bhs_eks_add_patient_list:dba
 DECLARE mf_prsnl_grp_id = f8 WITH noconstant(0.0), protect
 DECLARE mf_careteam = f8 WITH constant(uar_get_code_by("DISPLAYKEY",19189,"CARETEAM")), protect
 DECLARE ml_pllistcodes = i4 WITH constant(357), protect
 DECLARE ml_uptask = i4 WITH constant(600023), protect
 SET retval = - (1)
 SELECT INTO "nl:"
  FROM code_value cv,
   prsnl_group pg
  PLAN (cv
   WHERE cv.code_set=ml_pllistcodes
    AND cv.cdf_meaning="CARETEAM"
    AND cv.display=trim(replace(opt_param,'"',""),3))
   JOIN (pg
   WHERE pg.prsnl_group_type_cd=cv.code_value
    AND pg.prsnl_group_class_cd=mf_careteam)
  ORDER BY pg.prsnl_group_id
  HEAD pg.prsnl_group_id
   mf_prsnl_grp_id = pg.prsnl_group_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET log_message = "Please enter Valid display key from codeset 375 with cv.cdf_meaning = CARETEAM."
  GO TO end_run
 ENDIF
 INSERT  FROM dcp_pl_custom_entry plce
  SET plce.custom_entry_id = seq(dcp_patient_list_seq,nextval), plce.encntr_id = trigger_encntrid,
   plce.patient_list_id = 0.00,
   plce.prsnl_group_id = mf_prsnl_grp_id, plce.person_id = trigger_personid, plce.updt_applctx = 0,
   plce.updt_cnt = 0, plce.updt_dt_tm = cnvtdatetime(curdate,curtime3), plce.updt_id = 0.0,
   plce.updt_task = ml_uptask
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET retval = 0
  SET log_message = "list not updated"
 ELSEIF (curqual >= 0)
  SET retval = 100
  SET log_message = "list updated"
 ENDIF
#end_run
END GO
