CREATE PROGRAM dm_cm_sav_sql_long_txt:dba
 DECLARE rec_exist = vc WITH private
 DECLARE err_msg = vc WITH protect, noconstant(" ")
 DECLARE s_dmpref_id = f8 WITH protect, noconstant(0.0)
 DECLARE s_long_text_id = f8 WITH protect, noconstant(0.0)
 SET rec_exist = validate(reply->pref_value,"N")
 IF (rec_exist="N")
  FREE RECORD reply
  RECORD reply(
    1 dmpref_id = f8
    1 pref_ltr_id = f8
    1 pref_value = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->dmpref_id = 0.0
 SET reply->pref_ltr_id = 0.0
 SET reply->pref_value = " "
 SET reply->status_data.status = "F"
 SET reply->status_data.subeventstatus[1].operationname = "dm_cm_sav_sql_long_txt.prg"
 SET reply->status_data.subeventstatus[1].targetobjectname = "dm_cm_sav_sql_long_txt"
 SELECT INTO "nl:"
  dmp.pref_id, long_text_id = dmp.parent_entity_id
  FROM dm_prefs dmp
  WHERE dmp.pref_domain="CONTENT MANAGER"
   AND (dmp.pref_section=request->pref_section)
   AND (dmp.pref_name=request->pref_name)
   AND (dmp.pref_cd=request->pref_cd)
  DETAIL
   s_dmpref_id = dmp.pref_id, s_long_text_id = long_text_id
  WITH nocounter
 ;end select
 IF (error(err_msg,1) > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = err_msg
  GO TO exit_program
 ENDIF
 IF (((s_dmpref_id=0.0) OR (s_long_text_id=0.0)) )
  SET reply->status_data.status = "Z"
  IF (s_dmpref_id=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Record(s) does not exists in dm_prefs"
  ENDIF
  IF (s_long_text_id=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build2(reply->status_data.
    subeventstatus[1].targetobjectvalue," as well as long_text_reference")
  ENDIF
  SET reply->status_data.subeventstatus[1].targetobjectvalue = build2(reply->status_data.
   subeventstatus[1].targetobjectvalue,
   " table(s). Please use Script dm_cm_load_sql_long_txt to create.")
  GO TO exit_program
 ELSE
  SET reply->status_data.status = "S"
  SET reply->dmpref_id = s_dmpref_id
  SET reply->pref_ltr_id = s_long_text_id
  SET reply->pref_value = s_get_ltr_text(s_long_text_id)
 ENDIF
 SUBROUTINE (s_get_ltr_text(v_d_long_text_id=f8) =vc)
   DECLARE s_long_text = vc WITH noconstant(" "), protect
   SELECT INTO "nl:"
    FROM long_text_reference ltr
    WHERE ltr.long_text_id=v_d_long_text_id
    DETAIL
     s_long_text = ltr.long_text
    WITH nocounter
   ;end select
   IF (error(err_msg,1) > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = err_msg
    SET reply->status_data.subeventstatus[1].targetobjectname = "s_get_ltr_text"
    GO TO exit_program
   ENDIF
   RETURN(s_long_text)
 END ;Subroutine
#exit_program
END GO
