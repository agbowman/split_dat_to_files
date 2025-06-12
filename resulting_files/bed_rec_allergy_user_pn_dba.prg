CREATE PROGRAM bed_rec_allergy_user_pn:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET tempreply
 RECORD tempreply(
   1 rowlist[*]
     2 celllist[*]
       3 date_value = dq8
       3 nbr_value = i4
       3 double_value = f8
       3 string_value = vc
       3 display_flag = i2
 )
 DECLARE reportfailure(varpref=vc,varevalue=vc,varcvalue=vc,varlevel=vc,vardesc=vc,
  vardet=vc,varpriv=vc,varprivval=vc) = null
 DECLARE copytoreply(dest_index=i4,src_index=i4) = null
 DECLARE celllist_size = i4 WITH constant(15)
 DECLARE resolution_txt = vc
 DECLARE short_desc = vc
 DECLARE pharmacy_app_desc = vc
 DECLARE retail_app_desc = vc
 SET detail_mode = validate(request->detail_mode)
 SET reply->run_status_flag = 1
 SET serrmsg = fillstring(132," ")
 DECLARE failed_ph_value = vc
 DECLARE failed_rt_value = vc
 DECLARE app_desc = vc
 DECLARE failed_value = vc
 SET the_preference = "ALLERGY_ENABLE_FILTER_BUTTON"
 SET failed_ph = 0
 SET failed_rt = 0
 SET failed_ph_value = ""
 SET failed_rt_value = ""
 SET detailed_cnt = 0
 SELECT INTO "nl:"
  FROM br_rec b,
   br_long_text bl
  PLAN (b
   WHERE b.rec_mean="ALLERGYVOCABUSERPN")
   JOIN (bl
   WHERE bl.long_text_id=b.resolution_txt_id)
  DETAIL
   resolution_txt = trim(bl.long_text), short_desc = trim(b.short_desc)
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM application a
  WHERE a.application_number IN (380000, 385000)
   AND a.active_ind=1
  DETAIL
   IF (a.application_number=380000)
    pharmacy_app_desc = a.description
   ELSEIF (a.application_number=385000)
    retail_app_desc = a.description
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM app_prefs prefs,
   name_value_prefs np,
   application app
  PLAN (prefs
   WHERE prefs.application_number IN (380000, 385000)
    AND prefs.position_cd=0
    AND prefs.prsnl_id=0
    AND prefs.active_ind=1)
   JOIN (np
   WHERE np.parent_entity_name=outerjoin("APP_PREFS")
    AND np.parent_entity_id=outerjoin(prefs.app_prefs_id)
    AND np.pvc_name=outerjoin(the_preference)
    AND np.active_ind=outerjoin(1))
   JOIN (app
   WHERE app.application_number=prefs.application_number)
  ORDER BY app.description
  DETAIL
   IF (np.name_value_prefs_id > 0
    AND np.pvc_value != "0")
    IF (detail_mode=1)
     failed_value = np.pvc_value, app_desc = app.description,
     CALL reportfailure(the_preference,"0",failed_value,"Application",app_desc,"","","")
     IF (app.application_number=380000)
      failed_ph = 1, failed_ph_value = failed_value
     ELSEIF (app.application_number=385000)
      failed_rt = 1, failed_rt_value = failed_value
     ENDIF
    ELSE
     reply->run_status_flag = 3
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET reply->status_data.subeventstatus[1].targetobjectname =
  "Error generating detailed report for Allergy Check"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
 ENDIF
 IF (detail_mode=1)
  SET reply_size = size(tempreply->rowlist,5)
  SET stat = alterlist(reply->rowlist,reply_size)
  FOR (t = 1 TO reply_size)
   SET stat = alterlist(reply->rowlist[t].celllist,celllist_size)
   CALL copytoreply(t,t)
  ENDFOR
 ENDIF
 CALL echorecord(reply)
 SUBROUTINE reportfailure(varpref,varevalue,varcvalue,varlevel,vardesc,vardet,varpriv,varprivval)
   SET detailed_cnt = (detailed_cnt+ 1)
   SET stat = alterlist(tempreply->rowlist,detailed_cnt)
   SET stat = alterlist(tempreply->rowlist[detailed_cnt].celllist,celllist_size)
   SET tempreply->rowlist[detailed_cnt].celllist[1].string_value = short_desc
   SET tempreply->rowlist[detailed_cnt].celllist[2].string_value = varpref
   SET tempreply->rowlist[detailed_cnt].celllist[3].string_value = varevalue
   SET tempreply->rowlist[detailed_cnt].celllist[4].string_value = varcvalue
   SET tempreply->rowlist[detailed_cnt].celllist[5].string_value = varlevel
   SET tempreply->rowlist[detailed_cnt].celllist[6].string_value = vardesc
   SET tempreply->rowlist[detailed_cnt].celllist[7].string_value = vardet
   SET tempreply->rowlist[detailed_cnt].celllist[8].string_value = varpriv
   SET tempreply->rowlist[detailed_cnt].celllist[9].string_value = varprivval
   SET tempreply->rowlist[detailed_cnt].celllist[14].string_value = "Cernerpracticewizard"
   SET tempreply->rowlist[detailed_cnt].celllist[15].string_value = resolution_txt
 END ;Subroutine
 SUBROUTINE copytoreply(dest_index,src_index)
   SET reply->rowlist[dest_index].celllist[1].string_value = tempreply->rowlist[src_index].celllist[1
   ].string_value
   SET reply->rowlist[dest_index].celllist[2].string_value = tempreply->rowlist[src_index].celllist[2
   ].string_value
   SET reply->rowlist[dest_index].celllist[3].string_value = tempreply->rowlist[src_index].celllist[3
   ].string_value
   SET reply->rowlist[dest_index].celllist[4].string_value = tempreply->rowlist[src_index].celllist[4
   ].string_value
   SET reply->rowlist[dest_index].celllist[5].string_value = tempreply->rowlist[src_index].celllist[5
   ].string_value
   SET reply->rowlist[dest_index].celllist[6].string_value = tempreply->rowlist[src_index].celllist[6
   ].string_value
   SET reply->rowlist[dest_index].celllist[7].string_value = tempreply->rowlist[src_index].celllist[7
   ].string_value
   SET reply->rowlist[dest_index].celllist[8].string_value = tempreply->rowlist[src_index].celllist[8
   ].string_value
   SET reply->rowlist[dest_index].celllist[9].string_value = tempreply->rowlist[src_index].celllist[9
   ].string_value
   SET reply->rowlist[dest_index].celllist[10].string_value = tempreply->rowlist[src_index].celllist[
   10].string_value
   SET reply->rowlist[dest_index].celllist[11].string_value = tempreply->rowlist[src_index].celllist[
   11].string_value
   SET reply->rowlist[dest_index].celllist[12].string_value = tempreply->rowlist[src_index].celllist[
   12].string_value
   SET reply->rowlist[dest_index].celllist[13].string_value = tempreply->rowlist[src_index].celllist[
   13].string_value
   SET reply->rowlist[dest_index].celllist[14].string_value = tempreply->rowlist[src_index].celllist[
   14].string_value
   SET reply->rowlist[dest_index].celllist[15].string_value = tempreply->rowlist[src_index].celllist[
   15].string_value
 END ;Subroutine
END GO
