CREATE PROGRAM dm_move_cmb_to_downtime:dba
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
 FREE RECORD cmb_components
 RECORD cmb_components(
   1 list[*]
     2 script_name = vc
     2 di_ind = i2
 )
 DECLARE dm_comp_cnt = i4
 DECLARE dm_rec_size = i4
 DECLARE dm_di_cnt = i4
 DECLARE dm_err_msg = c132
 SET readme_data->status = "F"
 SET dm_di_cnt = 0
 SELECT INTO "nl:"
  FROM dm_cmb_exception dce,
   ocd_readme_component orc
  PLAN (dce
   WHERE dce.script_name != "NONE")
   JOIN (orc
   WHERE cnvtupper(orc.end_state)=cnvtupper(dce.script_name))
  DETAIL
   dm_comp_cnt = (dm_comp_cnt+ 1)
   IF (mod(dm_comp_cnt,10)=1)
    stat = alterlist(cmb_components->list,(dm_comp_cnt+ 9))
   ENDIF
   cmb_components->list[dm_comp_cnt].script_name = cnvtupper(dce.script_name), cmb_components->list[
   dm_comp_cnt].di_ind = 0
  FOOT REPORT
   stat = alterlist(cmb_components->list,dm_comp_cnt), dm_rec_size = size(cmb_components->list,5)
  WITH nocounter
 ;end select
 IF (error(dm_err_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("FAIL: ",dm_err_msg)
  GO TO exit_script
 ENDIF
 IF (((curqual=0) OR (dm_rec_size=0)) )
  SET readme_data->status = "S"
  SET readme_data->message = "SUCCESS: No cmb rows exist on ocd_readme_component"
  GO TO exit_script
 ENDIF
 DELETE  FROM ocd_readme_component orc,
   (dummyt d  WITH seq = dm_rec_size)
  SET orc.seq = 1
  PLAN (d)
   JOIN (orc
   WHERE (cnvtupper(orc.end_state)=cmb_components->list[d.seq].script_name))
  WITH nocounter
 ;end delete
 IF (error(dm_err_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("FAIL: ",dm_err_msg)
  ROLLBACK
  GO TO exit_script
 ENDIF
 IF (curqual > 0)
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di,
   (dummyt d  WITH seq = dm_rec_size)
  PLAN (d)
   JOIN (di
   WHERE di.info_domain="DATA MANAGEMENT"
    AND di.info_char="Do not include in mini-dictionary during mass move"
    AND (di.info_name=cmb_components->list[d.seq].script_name))
  DETAIL
   cmb_components->list[d.seq].di_ind = 1
  WITH nocounter
 ;end select
 IF (error(dm_err_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("FAIL: ",dm_err_msg)
  GO TO exit_script
 ENDIF
 INSERT  FROM dm_info di,
   (dummyt d  WITH seq = dm_rec_size)
  SET di.info_domain = "DATA MANAGEMENT", di.info_char =
   "Do not include in mini-dictionary during mass move", di.info_name = cmb_components->list[d.seq].
   script_name
  PLAN (d
   WHERE (cmb_components->list[d.seq].di_ind=0))
   JOIN (di)
  WITH nocounter
 ;end insert
 IF (error(dm_err_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("FAIL: ",dm_err_msg)
  ROLLBACK
  GO TO exit_script
 ENDIF
 IF (curqual > 0)
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di,
   (dummyt d  WITH seq = dm_rec_size)
  PLAN (d)
   JOIN (di
   WHERE di.info_domain="DATA MANAGEMENT"
    AND di.info_char="Do not include in mini-dictionary during mass move"
    AND (di.info_name=cmb_components->list[d.seq].script_name))
  DETAIL
   dm_di_cnt = (dm_di_cnt+ 1)
  WITH nocounter
 ;end select
 IF (error(dm_err_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("FAIL: ",dm_err_msg)
  GO TO exit_script
 ENDIF
 IF (dm_rec_size != dm_di_cnt)
  SET readme_data->status = "F"
  SET readme_data->message = "FAIL: rows were not properly inserted into dm_info."
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "SUCCESS: cmb rows successfully removed from ocd_readme_component."
#exit_script
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echorecord(readme_data)
 ENDIF
END GO
