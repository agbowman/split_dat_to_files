CREATE PROGRAM bed_get_qm_mpage_dsrn_rpt:dba
 FREE SET reply
 RECORD reply(
   1 avail_positions[*]
     2 position_code_value = f8
     2 display = vc
     2 description = vc
     2 applications[*]
       3 number = i4
       3 description = vc
       3 reports[*]
         4 mpage = vc
         4 parameters = vc
   1 sel_positions[*]
     2 position_code_value = f8
     2 display = vc
     2 description = vc
     2 applications[*]
       3 number = i4
       3 description = vc
       3 reports[*]
         4 mpage = vc
         4 parameters = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE app_parse = vc
 DECLARE pos_parse = vc
 SET app_parse = "dp.application_number in (600005,820000,4250111)"
 SET pos_parse = "dp.position_cd > 0"
 IF ((request->application_number > 0))
  SET app_parse = "dp.application_number = request->application_number"
 ENDIF
 IF ((request->position_code_value > 0))
  SET pos_parse = "dp.position_cd = request->position_code_value"
 ENDIF
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM detail_prefs dp,
   code_value cv,
   name_value_prefs nvp,
   view_prefs vp,
   name_value_prefs nvp1,
   br_name_value br_nv
  PLAN (dp
   WHERE parser(pos_parse)
    AND parser(app_parse)
    AND dp.view_name="DISCERNRPT"
    AND dp.comp_name="DISCERNRPT"
    AND dp.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=dp.position_cd
    AND cv.active_ind=1)
   JOIN (nvp
   WHERE nvp.parent_entity_id=dp.detail_prefs_id
    AND nvp.parent_entity_name="DETAIL_PREFS"
    AND nvp.pvc_name="REPORT_PARAM")
   JOIN (vp
   WHERE vp.prsnl_id=dp.prsnl_id
    AND vp.position_cd=dp.position_cd
    AND vp.application_number=dp.application_number
    AND vp.view_name=dp.view_name
    AND vp.view_seq=dp.view_seq
    AND vp.active_ind=1)
   JOIN (nvp1
   WHERE nvp1.parent_entity_id=vp.view_prefs_id
    AND nvp1.parent_entity_name="VIEW_PREFS"
    AND trim(nvp1.pvc_name)="VIEW_CAPTION")
   JOIN (br_nv
   WHERE br_nv.br_nv_key1="QMMPAGEPARAM"
    AND br_nv.br_name="DETAIL_PREFS"
    AND br_nv.br_value=cnvtstring(dp.detail_prefs_id))
  ORDER BY dp.position_cd, dp.application_number
  HEAD dp.position_cd
   tcnt = (tcnt+ 1), acnt = 0, stat = alterlist(reply->sel_positions,tcnt),
   reply->sel_positions[tcnt].position_code_value = dp.position_cd, reply->sel_positions[tcnt].
   display = cv.display, reply->sel_positions[tcnt].description = cv.description
  HEAD dp.application_number
   acnt = (acnt+ 1), dcnt = 0, stat = alterlist(reply->sel_positions[tcnt].applications,acnt),
   reply->sel_positions[tcnt].applications[acnt].number = dp.application_number, reply->
   sel_positions[tcnt].applications[acnt].description = " "
  DETAIL
   dcnt = (dcnt+ 1), stat = alterlist(reply->sel_positions[tcnt].applications[acnt].reports,dcnt),
   reply->sel_positions[tcnt].applications[acnt].reports[dcnt].mpage = nvp1.pvc_value,
   reply->sel_positions[tcnt].applications[acnt].reports[dcnt].parameters = nvp.pvc_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO tcnt)
  SET acnt = size(reply->sel_positions[x].applications,5)
  IF (acnt > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = acnt),
     br_name_value b,
     dummyt d2
    PLAN (d)
     JOIN (b
     WHERE b.br_nv_key1="APPLICATION_NAME")
     JOIN (d2
     WHERE (cnvtreal(trim(b.br_name))=reply->sel_positions[x].applications[d.seq].number))
    HEAD d.seq
     reply->sel_positions[x].applications[d.seq].description = b.br_value
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = acnt),
     application a
    PLAN (d
     WHERE (reply->sel_positions[x].applications[d.seq].description=" "))
     JOIN (a
     WHERE (a.application_number=reply->sel_positions[x].applications[d.seq].number))
    HEAD d.seq
     reply->sel_positions[x].applications[d.seq].description = a.description
    WITH nocounter, skipbedrock = 1
   ;end select
  ENDIF
 ENDFOR
 IF ((request->load_only_sel_ind != 1))
  SET tcnt = 0
  SELECT INTO "NL:"
   FROM detail_prefs dp,
    code_value cv,
    name_value_prefs nvp,
    view_prefs vp,
    name_value_prefs nvp1
   PLAN (dp
    WHERE parser(pos_parse)
     AND parser(app_parse)
     AND dp.view_name="DISCERNRPT"
     AND dp.comp_name="DISCERNRPT"
     AND dp.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=dp.position_cd
     AND cv.active_ind=1)
    JOIN (nvp
    WHERE nvp.parent_entity_id=dp.detail_prefs_id
     AND nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.pvc_name="REPORT_PARAM")
    JOIN (vp
    WHERE vp.prsnl_id=dp.prsnl_id
     AND vp.position_cd=dp.position_cd
     AND vp.application_number=dp.application_number
     AND vp.view_name=dp.view_name
     AND vp.view_seq=dp.view_seq
     AND vp.active_ind=1)
    JOIN (nvp1
    WHERE nvp1.parent_entity_id=vp.view_prefs_id
     AND nvp1.parent_entity_name="VIEW_PREFS"
     AND trim(nvp1.pvc_name)="VIEW_CAPTION")
   ORDER BY dp.position_cd, dp.application_number
   HEAD dp.position_cd
    tcnt = (tcnt+ 1), acnt = 0, stat = alterlist(reply->avail_positions,tcnt),
    reply->avail_positions[tcnt].position_code_value = dp.position_cd, reply->avail_positions[tcnt].
    display = cv.display, reply->avail_positions[tcnt].description = cv.description
   HEAD dp.application_number
    acnt = (acnt+ 1), dcnt = 0, stat = alterlist(reply->avail_positions[tcnt].applications,acnt),
    reply->avail_positions[tcnt].applications[acnt].number = dp.application_number, reply->
    avail_positions[tcnt].applications[acnt].description = " "
   DETAIL
    dcnt = (dcnt+ 1), stat = alterlist(reply->avail_positions[tcnt].applications[acnt].reports,dcnt),
    reply->avail_positions[tcnt].applications[acnt].reports[dcnt].mpage = nvp1.pvc_value,
    reply->avail_positions[tcnt].applications[acnt].reports[dcnt].parameters = nvp.pvc_value
   WITH nocounter
  ;end select
  FOR (x = 1 TO tcnt)
   SET acnt = size(reply->avail_positions[x].applications,5)
   IF (acnt > 0)
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = acnt),
      br_name_value b,
      dummyt d2
     PLAN (d)
      JOIN (b
      WHERE b.br_nv_key1="APPLICATION_NAME")
      JOIN (d2
      WHERE (cnvtreal(trim(b.br_name))=reply->avail_positions[x].applications[d.seq].number))
     HEAD d.seq
      reply->avail_positions[x].applications[d.seq].description = b.br_value
     WITH nocounter
    ;end select
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = acnt),
      application a
     PLAN (d
      WHERE (reply->avail_positions[x].applications[d.seq].description=" "))
      JOIN (a
      WHERE (a.application_number=reply->avail_positions[x].applications[d.seq].number))
     HEAD d.seq
      reply->avail_positions[x].applications[d.seq].description = a.description
     WITH nocounter, skipbedrock = 1
    ;end select
   ENDIF
  ENDFOR
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
