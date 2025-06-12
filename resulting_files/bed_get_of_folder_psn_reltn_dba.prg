CREATE PROGRAM bed_get_of_folder_psn_reltn:dba
 FREE SET reply
 RECORD reply(
   1 alist[*]
     2 assigned_ind = i2
     2 plist[*]
       3 position_code_value = f8
       3 position_display = c40
       3 powerorders_root_or_home = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET req_cnt = size(request->flist,5)
 SET stat = alterlist(reply->alist,req_cnt)
 IF ((request->component_flag=1))
  IF (req_cnt > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = req_cnt),
     name_value_prefs nvp,
     detail_prefs dp,
     code_value cv
    PLAN (d)
     JOIN (nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.pvc_name="ES_TAB_ID_3_*"
      AND nvp.pvc_value=cnvtstring(request->flist[d.seq].folder_id)
      AND nvp.active_ind=1)
     JOIN (dp
     WHERE (dp.application_number=request->application_number)
      AND dp.detail_prefs_id=nvp.parent_entity_id
      AND dp.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=dp.position_cd
      AND cv.active_ind=1)
    ORDER BY d.seq
    HEAD d.seq
     stat = alterlist(reply->alist[d.seq].plist,20), pcnt = 0, alterlist_pcnt = 0,
     reply->alist[d.seq].assigned_ind = 0
    DETAIL
     reply->alist[d.seq].assigned_ind = 1, alterlist_pcnt = (alterlist_pcnt+ 1)
     IF (alterlist_pcnt > 20)
      stat = alterlist(reply->alist[d.seq].plist,(pcnt+ 20)), alterlist_pcnt = 1
     ENDIF
     pcnt = (pcnt+ 1), reply->alist[d.seq].plist[pcnt].position_code_value = cv.code_value, reply->
     alist[d.seq].plist[pcnt].position_display = cv.display
    FOOT  d.seq
     stat = alterlist(reply->alist[d.seq].plist,pcnt)
    WITH nocounter
   ;end select
  ENDIF
 ELSEIF ((request->component_flag=2))
  IF (req_cnt > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = req_cnt),
     name_value_prefs nvp,
     app_prefs ap,
     code_value cv
    PLAN (d)
     JOIN (nvp
     WHERE nvp.parent_entity_name="APP_PREFS"
      AND nvp.pvc_name IN ("INPT_CATALOG_BROWSER_ROOT", "INPT_CATALOG_BROWSER_HOME")
      AND nvp.pvc_value=cnvtstring(request->flist[d.seq].folder_id)
      AND nvp.active_ind=1)
     JOIN (ap
     WHERE (ap.application_number=request->application_number)
      AND ap.app_prefs_id=nvp.parent_entity_id
      AND ap.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=ap.position_cd
      AND cv.active_ind=1)
    ORDER BY d.seq
    HEAD d.seq
     stat = alterlist(reply->alist[d.seq].plist,20), pcnt = 0, alterlist_pcnt = 0,
     reply->alist[d.seq].assigned_ind = 0
    DETAIL
     reply->alist[d.seq].assigned_ind = 1, alterlist_pcnt = (alterlist_pcnt+ 1)
     IF (alterlist_pcnt > 20)
      stat = alterlist(reply->alist[d.seq].plist,(pcnt+ 20)), alterlist_pcnt = 1
     ENDIF
     pcnt = (pcnt+ 1), reply->alist[d.seq].plist[pcnt].position_code_value = cv.code_value, reply->
     alist[d.seq].plist[pcnt].position_display = cv.display
     IF (nvp.pvc_name="INPT_CATALOG_BROWSER_ROOT")
      reply->alist[d.seq].plist[pcnt].powerorders_root_or_home = "R"
     ELSEIF (nvp.pvc_name="INPT_CATALOG_BROWSER_HOME")
      reply->alist[d.seq].plist[pcnt].powerorders_root_or_home = "H"
     ENDIF
    FOOT  d.seq
     stat = alterlist(reply->alist[d.seq].plist,pcnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
