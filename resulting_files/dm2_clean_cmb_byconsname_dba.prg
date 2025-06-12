CREATE PROGRAM dm2_clean_cmb_byconsname:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 DECLARE dccb_err_cd = i2
 DECLARE dccb_err_msg = c100
 DECLARE dccb_debug = i2
 DECLARE dccb_ndx = i4
 SET dccb_debug = 0
 SET dccb_err_cd = 0
 SET dccb_ndx = 0
 SET dccb_err_msg = fillstring(100,"")
 IF (validate(dm2_debug_flag,0) > 0)
  SET dccb_debug = 1
 ENDIF
 FREE RECORD dccb_obscons
 RECORD dccb_obscons(
   1 cnt = i4
   1 qual[*]
     2 constraint_name = vc
 )
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting dm2_clean_cmb_byconsname script"
 SELECT INTO "nl:"
  FROM dm_info a,
   dm_cmb_children b
  WHERE a.info_domain="OBSOLETE_CONSTRAINT"
   AND ((trim(a.info_name,3)=b.child_cons_name) OR (concat(trim(substring(1,28,a.info_name)),"$C")=b
  .child_cons_name))
  DETAIL
   dccb_obscons->cnt = (dccb_obscons->cnt+ 1)
   IF (mod(dccb_obscons->cnt,10)=1)
    stat = alterlist(dccb_obscons->qual,(dccb_obscons->cnt+ 9))
   ENDIF
   dccb_obscons->qual[dccb_obscons->cnt].constraint_name = a.info_name
  WITH nocounter
 ;end select
 SET dccb_err_cd = error(dccb_err_msg,1)
 IF (dccb_err_cd > 0)
  SET readme_data->message = "Failure getting list of constraints from dm_cmb_children."
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info a,
   dm_cmb_children2 b
  WHERE a.info_domain="OBSOLETE_CONSTRAINT"
   AND ((trim(a.info_name,3)=b.child_cons_name) OR (concat(trim(substring(1,28,a.info_name)),"$C")=b
  .child_cons_name))
  DETAIL
   IF (locateval(dccb_ndx,1,value(dccb_obscons->cnt),a.info_name,dccb_obscons->qual[dccb_ndx].
    constraint_name)=0)
    dccb_obscons->cnt = (dccb_obscons->cnt+ 1)
    IF (mod(dccb_obscons->cnt,10)=1)
     stat = alterlist(dccb_obscons->qual,(dccb_obscons->cnt+ 9))
    ENDIF
    dccb_obscons->qual[dccb_obscons->cnt].constraint_name = a.info_name
   ENDIF
  WITH nocounter
 ;end select
 SET dccb_err_cd = error(dccb_err_msg,1)
 IF (dccb_err_cd > 0)
  SET readme_data->message = "Failure getting list of constraints from dm_cmb_children2."
  GO TO exit_program
 ENDIF
 SET stat = alterlist(dccb_obscons->qual,dccb_obscons->cnt)
 IF (dccb_debug > 0)
  CALL echorecord(dccb_obscons)
 ENDIF
 FOR (dccb_cnt = 1 TO dccb_obscons->cnt)
   EXECUTE dm_drop_obsolete_objects value(dccb_obscons->qual[dccb_cnt].constraint_name), "CONSTRAINT",
   1
   SET dccb_err_cd = error(dccb_err_msg,1)
   IF (dccb_err_cd > 0)
    SET readme_data->message = concat("FAILURE Running DM_DROP_OBSOLETE_OBJECTS for ",dccb_obscons->
     qual[dccb_cnt].constraint_name)
    GO TO exit_program
   ENDIF
 ENDFOR
 SET readme_data->message = "Dm2_clean_cmb_byconsname completed."
 SET readme_data->status = "S"
 GO TO exit_program
#exit_program
 IF (dccb_err_cd > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(trim(dccb_err_msg),":",readme_data->message)
 ENDIF
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echorecord(readme_data)
 ENDIF
END GO
