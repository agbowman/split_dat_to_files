CREATE PROGRAM dcp_upd_default_notetype_pref:dba
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
 DECLARE rdm_errmsg = vc WITH public, noconstant(fillstring(132," "))
 DECLARE rdm_status = c1 WITH public, noconstant("F")
 UPDATE  FROM name_value_prefs nvp
  SET nvp.pvc_value =
   (SELECT
    x = cnvtstring(nt.event_cd)
    FROM note_type nt
    WHERE nvp.pvc_value=cnvtstring(nt.note_type_id)), nvp.updt_id = 0, nvp.updt_applctx = 0,
   nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_task
    = 0
  WHERE nvp.pvc_name="pvNotes.DefaultNoteType"
   AND nvp.pvc_value != "0"
   AND nvp.pvc_value != " "
   AND (nvp.pvc_value=
  (SELECT
   y = cnvtstring(nt.note_type_id)
   FROM note_type nt
   WHERE nvp.pvc_value=cnvtstring(nt.note_type_id)))
  WITH nocounter
 ;end update
 IF (error(rdm_errmsg,0) != 0)
  SET rdm_status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM name_value_prefs nvp
  WHERE nvp.pvc_name="pvNotes.DefaultNoteType"
   AND nvp.pvc_value != "0"
   AND nvp.pvc_value != " "
   AND (nvp.pvc_value=
  (SELECT
   z = cnvtstring(nt.note_type_id)
   FROM note_type nt
   WHERE nvp.pvc_value=cnvtstring(nt.note_type_id)))
  WITH nocounter
 ;end select
 IF (((curqual != 0) OR (error(rdm_errmsg,0) != 0)) )
  SET rdm_status = "F"
 ELSE
  SET rdm_status = "S"
 ENDIF
#exit_script
 IF (rdm_status="F")
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed - name_value_prefs table"," update unsuccessful")
  ROLLBACK
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = concat("Success - name_value_prefs table","  updated successfully")
  COMMIT
 ENDIF
 EXECUTE dm_readme_status
END GO
