CREATE PROGRAM dcp_upd_notetype_pref_undo:dba
 DECLARE rdm_errmsg = vc WITH public, noconstant(fillstring(132," "))
 DECLARE rdm_status = c1 WITH public, noconstant("F")
 UPDATE  FROM name_value_prefs nvp
  SET nvp.pvc_value =
   (SELECT
    nt.note_type_id
    FROM note_type nt
    WHERE cnvtreal(nvp.pvc_value)=nt.event_cd), nvp.updt_id = 0, nvp.updt_applctx = 0,
   nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_task
    = 0
  WHERE nvp.pvc_name="pvNotes.DefaultNoteType"
   AND cnvtreal(nvp.pvc_value) != 0.00
   AND nvp.pvc_value != " "
   AND (nvp.pvc_value=
  (SELECT
   nt.event_cd
   FROM note_type nt
   WHERE cnvtreal(nvp.pvc_value)=nt.event_cd))
  WITH nocounter
 ;end update
 IF (error(rdm_errmsg,0) != 0)
  SET rdm_status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM name_value_prefs nvp
  WHERE nvp.pvc_name="pvNotes.DefaultNoteType"
   AND cnvtreal(nvp.pvc_value) != 0.00
   AND nvp.pvc_value != " "
   AND (nvp.pvc_value=
  (SELECT
   nt.event_cd
   FROM note_type nt
   WHERE cnvtreal(nvp.pvc_value)=nt.event_cd))
  WITH nocounter
 ;end select
 IF (((curqual != 0) OR (error(rdm_errmsg,0) != 0)) )
  SET rdm_status = "F"
 ELSE
  SET rdm_status = "S"
 ENDIF
#exit_script
 IF (rdm_status="F")
  CALL echo("Failed - name_value_prefs table update unsuccessful")
  ROLLBACK
 ELSE
  CALL echo("Success - name_value_prefs table updated successfully")
  COMMIT
 ENDIF
END GO
