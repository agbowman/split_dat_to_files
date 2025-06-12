CREATE PROGRAM bed_rec_allergy_vocab_user:dba
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
 DECLARE powerchart_app_desc = vc
 DECLARE surginet_app_desc = vc
 DECLARE firstnet_app_desc = vc
 SET detail_mode = validate(request->detail_mode)
 SET reply->run_status_flag = 1
 SET serrmsg = fillstring(132," ")
 DECLARE failed_fn_value = vc
 DECLARE failed_sn_value = vc
 DECLARE failed_pc_value = vc
 DECLARE app_desc = vc
 DECLARE failed_value = vc
 SET the_preference = "ALLERGY_ENABLE_FILTER_BUTTON"
 SET updt_allergy = 0.0
 SET no_cd = 0.0
 SET failed_pc = 0
 SET failed_sn = 0
 SET failed_fn = 0
 SET failed_fn_value = ""
 SET failed_sn_value = ""
 SET failed_pc_value = ""
 SET detailed_cnt = 0
 SELECT INTO "nl:"
  FROM br_rec b,
   br_long_text bl
  PLAN (b
   WHERE b.rec_mean="ALLERGYVOCABUSER")
   JOIN (bl
   WHERE bl.long_text_id=b.resolution_txt_id)
  DETAIL
   resolution_txt = trim(bl.long_text), short_desc = trim(b.short_desc)
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6016
   AND cv.cdf_meaning="UPDTALLERGY"
   AND cv.active_ind=1
  DETAIL
   updt_allergy = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6017
   AND cv.cdf_meaning="NO"
   AND cv.active_ind=1
  DETAIL
   no_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM application a
  WHERE a.application_number IN (600005, 820000, 4250111)
   AND a.active_ind=1
  DETAIL
   IF (a.application_number=600005)
    powerchart_app_desc = a.description
   ELSEIF (a.application_number=820000)
    surginet_app_desc = a.description
   ELSEIF (a.application_number=4250111)
    firstnet_app_desc = a.description
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM app_prefs prefs,
   name_value_prefs np,
   application app
  PLAN (prefs
   WHERE prefs.application_number IN (600005, 820000, 4250111)
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
     IF (app.application_number=600005)
      failed_pc = 1, failed_pc_value = failed_value
     ELSEIF (app.application_number=820000)
      failed_sn = 1, failed_sn_value = failed_value
     ELSEIF (app.application_number=4250111)
      failed_fn = 1, failed_fn_value = failed_value
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
 SELECT INTO "NL:"
  FROM name_value_prefs np,
   app_prefs ap,
   priv_loc_reltn plr,
   privilege pv1,
   code_value cv,
   code_value cv2,
   prsnl p
  PLAN (cv
   WHERE cv.code_set=88
    AND cv.active_ind=1)
   JOIN (p
   WHERE p.position_cd=cv.code_value
    AND p.active_ind=1)
   JOIN (ap
   WHERE ap.application_number IN (600005, 820000, 4250111)
    AND ap.position_cd=outerjoin(p.position_cd)
    AND ap.active_ind=outerjoin(1))
   JOIN (np
   WHERE np.parent_entity_name=outerjoin("APP_PREFS")
    AND np.pvc_name=outerjoin(the_preference)
    AND np.parent_entity_id=outerjoin(ap.app_prefs_id)
    AND np.active_ind=outerjoin(1))
   JOIN (plr
   WHERE plr.position_cd=outerjoin(p.position_cd)
    AND plr.location_cd=outerjoin(0)
    AND plr.active_ind=outerjoin(1))
   JOIN (pv1
   WHERE pv1.priv_loc_reltn_id=outerjoin(plr.priv_loc_reltn_id)
    AND pv1.privilege_cd=outerjoin(updt_allergy)
    AND pv1.active_ind=outerjoin(1))
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(pv1.priv_value_cd))
  ORDER BY cv.code_value, ap.application_number
  HEAD cv.code_value
   pc = 0, fn = 0, sn = 0
  HEAD ap.application_number
   pos_fail = 0
   IF (ap.application_number=600005)
    pc = 1
   ELSEIF (ap.application_number=820000)
    sn = 1
   ELSEIF (ap.application_number=4250111)
    fn = 1
   ENDIF
  DETAIL
   IF (np.name_value_prefs_id > 0)
    IF (np.pvc_value != "0"
     AND pv1.priv_value_cd != no_cd)
     IF (detail_mode=1)
      failed_value = np.pvc_value
      IF (ap.application_number=600005)
       app_desc = powerchart_app_desc
      ELSEIF (ap.application_number=820000)
       app_desc = surginet_app_desc
      ELSEIF (ap.application_number=4250111)
       app_desc = firstnet_app_desc
      ENDIF
      CALL reportfailure(the_preference,"0",failed_value,"Position",app_desc,cv.display,
      "Update Allergy",cv2.display)
     ELSE
      reply->run_status_flag = 3
     ENDIF
     pos_fail = 1
    ENDIF
   ENDIF
  FOOT  ap.application_number
   IF (pos_fail=0
    AND np.name_value_prefs_id < 1
    AND pv1.priv_value_cd != no_cd)
    loc_inheret = 0
    IF (ap.application_number=600005
     AND failed_pc=1)
     loc_inheret = 1, app_desc = powerchart_app_desc, failed_value = failed_pc_value
    ELSEIF (ap.application_number=820000
     AND failed_sn=1)
     loc_inheret = 1, app_desc = surginet_app_desc, failed_value = failed_sn_value
    ELSEIF (ap.application_number=4250111
     AND failed_fn=1)
     loc_inheret = 1, app_desc = firstnet_app_desc, failed_value = failed_fn_value
    ENDIF
    IF (loc_inheret=1)
     IF (detail_mode=1)
      CALL reportfailure(the_preference,"0",failed_value,"Application",app_desc,cv.display,"","")
     ELSE
      reply->run_status_flag = 3
     ENDIF
    ENDIF
   ENDIF
  FOOT  cv.code_value
   IF (pc=0
    AND failed_pc
    AND pv1.priv_value_cd != no_cd)
    IF (detail_mode=1)
     CALL echo(build("pc = 0 : ",cv.display)),
     CALL reportfailure(the_preference,"0",failed_pc_value,"Application",powerchart_app_desc,cv
     .display,"","")
    ENDIF
   ENDIF
   IF (sn=0
    AND failed_sn
    AND pv1.priv_value_cd != no_cd)
    IF (detail_mode=1)
     CALL echo(build("sn = 0 : ",cv.display)),
     CALL reportfailure(the_preference,"0",failed_sn_value,"Application",surginet_app_desc,cv.display,
     "","")
    ENDIF
   ENDIF
   IF (fn=0
    AND failed_fn
    AND pv1.priv_value_cd != no_cd)
    IF (detail_mode=1)
     CALL echo(build("fn = 0 : ",cv.display)),
     CALL reportfailure(the_preference,"0",failed_fn_value,"Application",firstnet_app_desc,cv.display,
     "","")
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (detail_mode=1)
  SET reply_size = size(tempreply->rowlist,5)
  SET stat = alterlist(reply->rowlist,reply_size)
  SET index = 0
  SET app_failures_count = ((failed_fn+ failed_pc)+ failed_sn)
  FOR (t = 1 TO app_failures_count)
    SET index = (index+ 1)
    SET stat = alterlist(reply->rowlist[index].celllist,celllist_size)
    CALL copytoreply(index,t)
  ENDFOR
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = value(reply_size))
   WHERE (tempreply->rowlist[d.seq].celllist[7].string_value != "")
   ORDER BY tempreply->rowlist[d.seq].celllist[6].string_value, tempreply->rowlist[d.seq].celllist[5]
    .string_value, tempreply->rowlist[d.seq].celllist[7].string_value
   DETAIL
    index = (index+ 1), stat = alterlist(reply->rowlist[index].celllist,celllist_size),
    CALL copytoreply(index,d.seq)
   WITH nocounter
  ;end select
 ENDIF
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
   SET tempreply->rowlist[detailed_cnt].celllist[14].string_value = "PrefMaint"
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
