CREATE PROGRAM bed_rec_quick_add_check:dba
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
 DECLARE getprivvalue(priv_cd=f8) = vc
 DECLARE copytoreply(dest_index=i4,src_index=i4) = null
 DECLARE celllist_size = i4 WITH constant(15)
 DECLARE resolution_txt = vc
 DECLARE short_desc = vc
 DECLARE powerchart_app_desc = vc
 DECLARE surginet_app_desc = vc
 DECLARE firstnet_app_desc = vc
 DECLARE temp_cnt = i4
 DECLARE detailed_cnt = i4
 DECLARE powerchart_quickadd = vc
 DECLARE surginet_quickadd = vc
 DECLARE firstnet_quickadd = vc
 DECLARE app_desc = vc
 SET detail_mode = validate(request->detail_mode)
 SET reply->run_status_flag = 1
 SET serrmsg = fillstring(132," ")
 SET resolution_txt = ""
 SET short_desc = ""
 SET updt_allergy = 0.0
 SET yes_cd = 0.0
 SET powerchart_quickadd = "-1"
 SET surginet_quickadd = "-1"
 SET firstnet_quickadd = "-1"
 SET failed_pc = 0
 SET failed_sn = 0
 SET failed_fn = 0
 SET detailed_cnt = 0
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
   AND cv.cdf_meaning="YES"
   AND cv.active_ind=1
  DETAIL
   yes_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_rec b,
   br_long_text bl
  PLAN (b
   WHERE b.rec_mean="QUICKADDCHECK")
   JOIN (bl
   WHERE bl.long_text_id=b.resolution_txt_id)
  DETAIL
   resolution_txt = trim(bl.long_text), short_desc = trim(b.short_desc)
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
  FROM view_prefs vp,
   name_value_prefs np,
   application app
  PLAN (vp
   WHERE vp.application_number IN (600005, 820000, 4250111)
    AND vp.position_cd=0
    AND vp.prsnl_id=0
    AND vp.active_ind=1
    AND vp.view_name="ALLERGY"
    AND vp.frame_type="CHART")
   JOIN (np
   WHERE np.parent_entity_name=outerjoin("VIEW_PREFS")
    AND np.parent_entity_id=outerjoin(vp.view_prefs_id)
    AND np.pvc_name=outerjoin("QUICK_ADD")
    AND np.active_ind=outerjoin(1))
   JOIN (app
   WHERE app.application_number=vp.application_number)
  ORDER BY app.description
  HEAD app.description
   pref_exist_ind = 0
  DETAIL
   IF (vp.application_number=600005)
    powerchart_quickadd = np.pvc_value, pref_exist_ind = 1
   ELSEIF (vp.application_number=820000)
    surginet_quickadd = np.pvc_value, pref_exist_ind = 2
   ELSEIF (vp.application_number=4250111)
    firstnet_quickadd = np.pvc_value, pref_exist_ind = 3
   ENDIF
  FOOT  app.description
   IF (pref_exist_ind != 0)
    IF (vp.application_number=600005
     AND powerchart_quickadd != "1")
     app_desc = powerchart_app_desc, failed_value = powerchart_quickadd, failed_pc = 1
     IF (detail_mode=1)
      CALL reportfailure("QUICK_ADD","1",failed_value,"Application",app_desc,"","","")
     ELSE
      reply->run_status_flag = 3
     ENDIF
    ELSEIF (vp.application_number=820000
     AND surginet_quickadd != "1")
     app_desc = surginet_app_desc, failed_value = surginet_quickadd, failed_sn = 1
     IF (detail_mode=1)
      CALL reportfailure("QUICK_ADD","1",failed_value,"Application",app_desc,"","","")
     ELSE
      reply->run_status_flag = 3
     ENDIF
    ELSEIF (vp.application_number=4250111
     AND firstnet_quickadd != "1")
     app_desc = firstnet_app_desc, failed_value = firstnet_quickadd, failed_fn = 1
     IF (detail_mode=1)
      CALL reportfailure("QUICK_ADD","1",failed_value,"Application",app_desc,"","","")
     ELSE
      reply->run_status_flag = 3
     ENDIF
    ENDIF
   ENDIF
   pref_exist_ind = 0
  WITH nocounter
 ;end select
 DECLARE fail_flag = i4
 SELECT INTO "NL:"
  FROM name_value_prefs np,
   view_prefs vp,
   priv_loc_reltn plr,
   privilege pv1,
   code_value cv,
   prsnl p
  PLAN (cv
   WHERE cv.code_set=88
    AND cv.active_ind=1)
   JOIN (p
   WHERE p.position_cd=cv.code_value
    AND p.active_ind=1)
   JOIN (vp
   WHERE vp.position_cd=outerjoin(p.position_cd)
    AND vp.view_name=outerjoin("ALLERGY")
    AND vp.frame_type=outerjoin("CHART")
    AND vp.active_ind=outerjoin(1))
   JOIN (np
   WHERE np.parent_entity_name=outerjoin("VIEW_PREFS")
    AND np.pvc_name=outerjoin("QUICK_ADD")
    AND np.parent_entity_id=outerjoin(vp.view_prefs_id)
    AND np.active_ind=outerjoin(1))
   JOIN (plr
   WHERE plr.position_cd=outerjoin(p.position_cd)
    AND plr.location_cd=outerjoin(0)
    AND plr.active_ind=outerjoin(1))
   JOIN (pv1
   WHERE pv1.priv_loc_reltn_id=outerjoin(plr.priv_loc_reltn_id)
    AND pv1.privilege_cd=outerjoin(updt_allergy)
    AND pv1.active_ind=outerjoin(1))
  ORDER BY p.position_cd, vp.application_number
  HEAD p.position_cd
   pc = 0, fn = 0, sn = 0
  HEAD vp.application_number
   IF (vp.application_number=600005)
    pc = 1
   ELSEIF (vp.application_number=820000)
    sn = 1
   ELSEIF (vp.application_number=4250111)
    fn = 1
   ENDIF
   fail_flag = 0
  FOOT  vp.application_number
   IF (((pv1.privilege_id < 1) OR (pv1.privilege_id > 0
    AND pv1.priv_value_cd=yes_cd)) )
    IF (((np.name_value_prefs_id < 1) OR (np.name_value_prefs_id > 0
     AND np.pvc_value != "1")) )
     IF (vp.application_number=600005)
      app_desc = powerchart_app_desc, fail_flag = 1
     ELSEIF (vp.application_number=820000)
      app_desc = surginet_app_desc, fail_flag = 1
     ELSEIF (vp.application_number=4250111)
      app_desc = firstnet_app_desc, fail_flag = 1
     ENDIF
    ENDIF
   ENDIF
   IF (fail_flag=1)
    IF (detail_mode=1)
     priv = getprivvalue(pv1.priv_value_cd),
     CALL reportfailure("QUICK_ADD","1",np.pvc_value,"Position",app_desc,cv.display,"Update Allergy",
     priv)
    ELSE
     reply->run_status_flag = 3
    ENDIF
   ENDIF
  FOOT  p.position_cd
   IF (((pv1.privilege_id < 1) OR (pv1.privilege_id > 0
    AND pv1.priv_value_cd=yes_cd)) )
    priv = getprivvalue(pv1.priv_value_cd)
    IF (detail_mode=1)
     IF (pc=0
      AND failed_pc=1)
      CALL reportfailure("QUICK_ADD","1",powerchart_quickadd,"Application",powerchart_app_desc,cv
      .display,"Update Allergy",priv)
     ENDIF
     IF (sn=0
      AND failed_sn=1)
      CALL reportfailure("QUICK_ADD","1",surginet_quickadd,"Application",surginet_app_desc,cv.display,
      "Update Allergy",priv)
     ENDIF
     IF (fn=0
      AND failed_fn=1)
      CALL reportfailure("QUICK_ADD","1",firstnet_quickadd,"Application",firstnet_app_desc,cv.display,
      "Update Allergy",priv)
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET reply->status_data.subeventstatus[1].targetobjectname =
  "Error generating a detailed report for Allergy Check"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
 ENDIF
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
 SUBROUTINE getprivvalue(priv_cd)
   SET priv_val = ""
   IF (priv_cd=yes_cd)
    SET priv_val = "YES"
   ENDIF
   RETURN(priv_val)
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
