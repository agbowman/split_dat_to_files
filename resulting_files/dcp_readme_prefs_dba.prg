CREATE PROGRAM dcp_readme_prefs:dba
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
 SET readme_data->status = "F"
 RECORD temprec(
   1 qual[*]
     2 nvp_name_value_pref_id = f8
     2 nvp_pvc_value = vc
     2 new_nvp_parent_entity_id = f8
     2 ap_app_pref_id = f8
     2 df_prsnl_id = f8
     2 df_position_cd = f8
     2 df_applicationid = i4
     2 upd_flag = i2
 )
 DECLARE count = i4 WITH noconstant(0)
 DECLARE count2 = i4 WITH noconstant(0)
 DECLARE upd_flag = i2 WITH noconstant(0)
 SET count3 = 0
 SET insert_flag = 1
 SELECT INTO "nl:"
  FROM name_value_prefs nvp,
   detail_prefs df
  WHERE nvp.pvc_name="pvNotes.SignPassword"
   AND nvp.parent_entity_name="DETAIL_PREFS"
   AND df.detail_prefs_id=outerjoin(nvp.parent_entity_id)
  DETAIL
   count = (count+ 1), stat = alterlist(temprec->qual,count), temprec->qual[count].
   nvp_name_value_pref_id = nvp.name_value_prefs_id,
   temprec->qual[count].nvp_pvc_value = nvp.pvc_value, temprec->qual[count].df_prsnl_id = df.prsnl_id,
   temprec->qual[count].df_position_cd = df.position_cd,
   temprec->qual[count].df_applicationid = df.application_number, temprec->qual[count].upd_flag = 0,
   temprec->qual[count].ap_app_pref_id = 0,
   temprec->qual[count].new_nvp_parent_entity_id = 0
  WITH counter
 ;end select
 IF (curqual=0)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Preference pvNotes.SignPassword does not exist.  Preference conversion not required."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM app_prefs ap
  WHERE expand(count2,1,count,ap.application_number,temprec->qual[count2].df_applicationid)
   AND (temprec->qual[count2].df_prsnl_id=ap.prsnl_id)
   AND (temprec->qual[count2].df_position_cd=ap.position_cd)
  DETAIL
   count3 = (count3+ 1), temprec->qual[count2].upd_flag = 1, temprec->qual[count2].ap_app_pref_id =
   ap.app_prefs_id,
   upd_flag = 1
  WITH counter
 ;end select
 IF (count3 >= count)
  SET insert_flag = 0
 ENDIF
 CALL addapppref(count,insert_flag)
 CALL addnamevalue(upd_flag,count,insert_flag)
 CALL deletenamepref(count)
 CALL echo(build("#################  HERE 1 #################"))
 SET readme_data->status = "S"
 GO TO exit_script
 SUBROUTINE addapppref(local_count,local_insert_flag)
   DECLARE private_idx = i4 WITH noconstant(1)
   SET private_idx = 1
   IF (local_count < 1)
    SET readme_data->message = "no items found in app_prefs"
    GO TO exit_script
   ENDIF
   CALL echo(build("local count,",local_count))
   WHILE (private_idx <= local_count)
    SELECT INTO "nl:"
     j = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      temprec->qual[private_idx].new_nvp_parent_entity_id = cnvtreal(j)
     WITH nocounter
    ;end select
    SET private_idx = (private_idx+ 1)
   ENDWHILE
   IF (local_insert_flag)
    INSERT  FROM app_prefs ap,
      (dummyt d1  WITH seq = value(local_count))
     SET ap.app_prefs_id = temprec->qual[d1.seq].new_nvp_parent_entity_id, ap.application_number =
      temprec->qual[d1.seq].df_applicationid, ap.position_cd = temprec->qual[d1.seq].df_position_cd,
      ap.prsnl_id = temprec->qual[d1.seq].df_prsnl_id, ap.active_ind = 1, ap.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      ap.updt_id = 0, ap.updt_task = 0, ap.updt_applctx = 0,
      ap.updt_cnt = 0
     PLAN (d1
      WHERE (temprec->qual[d1.seq].upd_flag=0)
       AND (((temprec->qual[d1.seq].df_applicationid > 0)) OR ((((temprec->qual[d1.seq].
      df_position_cd > 0)) OR ((temprec->qual[d1.seq].df_prsnl_id > 0))) )) )
      JOIN (ap)
     WITH counter
    ;end insert
    IF (curqual=0)
     SET readme_data->message = "unable to inset data to app_prefs - AddAppPref"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE addnamevalue(local_upd_flag,local_count,local_insert_flag)
  IF (local_insert_flag)
   INSERT  FROM name_value_prefs nvp,
     (dummyt d1  WITH seq = value(local_count))
    SET nvp.seq = 1, nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name =
     "APP_PREFS",
     nvp.parent_entity_id = temprec->qual[d1.seq].new_nvp_parent_entity_id, nvp.pvc_name =
     "SIGN_PASSWORD", nvp.pvc_value = trim(cnvtupper(temprec->qual[d1.seq].nvp_pvc_value)),
     nvp.merge_id = 0.0, nvp.active_ind = 1, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     nvp.updt_id = 0, nvp.updt_task = 0, nvp.updt_applctx = 0,
     nvp.updt_cnt = 0
    PLAN (d1
     WHERE (temprec->qual[d1.seq].upd_flag=0))
     JOIN (nvp)
    WITH counter
   ;end insert
   CALL echo(build("#################### 4 ###################"))
   IF (curqual=0)
    SET readme_data->message = "unable to inset data to name_value_prefs - AddNameValue"
    GO TO exit_script
   ENDIF
  ENDIF
  IF (local_upd_flag)
   INSERT  FROM name_value_prefs nvp,
     (dummyt d1  WITH seq = value(local_count))
    SET nvp.seq = 1, nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name =
     "APP_PREFS",
     nvp.parent_entity_id = temprec->qual[d1.seq].ap_app_pref_id, nvp.pvc_name = "SIGN_PASSWORD", nvp
     .pvc_value = trim(cnvtupper(temprec->qual[d1.seq].nvp_pvc_value)),
     nvp.merge_id = 0.0, nvp.active_ind = 1, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     nvp.updt_id = 0, nvp.updt_task = 0, nvp.updt_applctx = 0,
     nvp.updt_cnt = 0
    PLAN (d1
     WHERE (temprec->qual[d1.seq].upd_flag=1))
     JOIN (nvp)
    WITH counter
   ;end insert
   IF (curqual=0)
    SET readme_data->message = "unable to inset data to name_value_prefs - AddNameValue"
    GO TO exit_script
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE deletenamepref(local_count)
   DECLARE private_idx1 = i4 WITH noconstant(1)
   SET private_idx1 = 0
   FOR (private_idx1 = 1 TO local_count)
     DELETE  FROM name_value_prefs nvp
      WHERE (nvp.name_value_prefs_id=temprec->qual[private_idx1].nvp_name_value_pref_id)
      WITH nocounter
     ;end delete
   ENDFOR
 END ;Subroutine
#exit_script
 CALL echo(build("#################  EXIT #################"))
 IF ((readme_data->status="S"))
  SELECT INTO "nl:"
   FROM name_value_prefs nvp
   WHERE nvp.pvc_name="pvNotes.SignPassword"
    AND nvp.parent_entity_name="DETAIL_PREFS"
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET readme_data->message = "unable to remove all pvnotes.signpassword from name_value_pref"
   SET readme_data->status = "F"
  ENDIF
 ENDIF
 IF ((readme_data->status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
