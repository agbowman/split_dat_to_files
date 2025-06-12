CREATE PROGRAM bed_get_workflow_info:dba
 FREE SET reply
 RECORD reply(
   1 wlist[*]
     2 workflow_name = vc
     2 workflow_seq = i2
     2 slist[*]
       3 step_seq = i2
       3 comp1_name = vc
       3 invalid_comp1_ind = i2
       3 comp2_name = vc
       3 invalid_comp2_ind = i2
       3 layout_orientation = i2
       3 splitter_percent = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET wf_cnt = 0
 SET wfidx = 0
 SET scnt = 0
 SET sidx = 0
 SET dp_id = 0.0
 DECLARE pvcn = vc
 SET wcard = "*"
 DECLARE pvcv = vc
 SELECT INTO "nl:"
  FROM detail_prefs dp,
   name_value_prefs nvp
  PLAN (dp
   WHERE dp.application_number=961000
    AND (dp.position_cd=request->position_code_value)
    AND dp.prsnl_id=0
    AND dp.view_name="PCOFFICE"
    AND dp.view_seq=0
    AND dp.comp_name="PCOFFICE"
    AND dp.comp_seq=0
    AND dp.active_ind=1)
   JOIN (nvp
   WHERE nvp.parent_entity_id=dp.detail_prefs_id
    AND nvp.parent_entity_name="DETAIL_PREFS"
    AND nvp.pvc_name="ALL_WORKFLOW_COUNT")
  DETAIL
   dp_id = dp.detail_prefs_id, wf_cnt = cnvtint(nvp.pvc_value)
  WITH nocounter
 ;end select
 IF (wf_cnt > 0)
  SET stat = alterlist(reply->wlist,wf_cnt)
 ENDIF
 FOR (x = 1 TO wf_cnt)
   SET reply->wlist[x].workflow_name = " "
 ENDFOR
 SELECT INTO "nl:"
  FROM name_value_prefs nvp
  PLAN (nvp
   WHERE nvp.parent_entity_id=dp_id
    AND nvp.parent_entity_name="DETAIL_PREFS"
    AND nvp.pvc_name="WORKFLOW_NAME*")
  DETAIL
   wfidx = cnvtint(substring(14,2,nvp.pvc_name)), wfidx = (wfidx+ 1)
   IF (wfidx <= wf_cnt)
    reply->wlist[wfidx].workflow_name = trim(nvp.pvc_value), reply->wlist[wfidx].workflow_seq = wfidx
   ENDIF
  WITH nocounter
 ;end select
 FOR (x = 1 TO wf_cnt)
   IF ((reply->wlist[x].workflow_name=" "))
    SET reply->wlist[x].workflow_name = "Unknown Workflow Name"
   ENDIF
   SET scnt = 0
   SELECT INTO "nl:"
    FROM name_value_prefs nvp
    PLAN (nvp
     WHERE nvp.parent_entity_id=dp_id
      AND nvp.parent_entity_name="DETAIL_PREFS"
      AND nvp.pvc_name=concat("WORKFLOW_LAYOUT_COUNT",cnvtstring((x - 1))))
    DETAIL
     scnt = cnvtint(nvp.pvc_value)
     IF (scnt > 0)
      stat = alterlist(reply->wlist[x].slist,scnt)
     ENDIF
    WITH nocounter
   ;end select
   IF (scnt > 0)
    SELECT INTO "nl:"
     FROM name_value_prefs nvp
     PLAN (nvp
      WHERE nvp.parent_entity_id=dp_id
       AND nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.pvc_name="LAYOUT*_*")
     DETAIL
      pvcv = " "
      IF (substring(1,6,nvp.pvc_name)="LAYOUT")
       IF (substring(8,1,nvp.pvc_name)="_")
        wfidx = cnvtint(substring(7,1,nvp.pvc_name)), sidx = cnvtint(substring(9,2,nvp.pvc_name))
       ELSE
        wfidx = cnvtint(substring(7,2,nvp.pvc_name)), sidx = cnvtint(substring(10,2,nvp.pvc_name))
       ENDIF
       IF ((wfidx=(x - 1)))
        sidx = (sidx+ 1)
        IF (sidx <= scnt)
         reply->wlist[x].slist[sidx].step_seq = sidx
         IF (nvp.pvc_value="*Flowsheet - 2 day Lab, Rad, Vitals*")
          pvcv = replace(nvp.pvc_value,"Flowsheet - 2 day Lab, Rad, Vitals",
           "Flowsheet - 2 day Lab  Rad  Vitals",0)
         ELSE
          pvcv = trim(nvp.pvc_value)
         ENDIF
         c1idx = findstring(",",pvcv,1)
         IF (c1idx > 1)
          reply->wlist[x].slist[sidx].comp1_name = substring(1,(c1idx - 1),pvcv), c2idx = findstring(
           ",",pvcv,(c1idx+ 1))
          IF ((c2idx > (c1idx+ 1)))
           reply->wlist[x].slist[sidx].comp2_name = substring((c1idx+ 1),((c2idx - c1idx) - 1),pvcv)
          ENDIF
          reply->wlist[x].slist[sidx].layout_orientation = cnvtint(substring((c2idx+ 1),1,pvcv)),
          c3idx = findstring(",",pvcv,(c2idx+ 1))
          IF ((c3idx > (c2idx+ 1)))
           reply->wlist[x].slist[sidx].splitter_percent = cnvtreal(substring((c3idx+ 1),5,pvcv))
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    FOR (y = 1 TO scnt)
     IF ((reply->wlist[x].slist[y].comp1_name > " "))
      IF ((reply->wlist[x].slist[y].comp1_name="Flowsheet - 2 day Lab  Rad  Vitals"))
       SET reply->wlist[x].slist[y].comp1_name = "Flowsheet - 2 day Lab, Rad, Vitals"
      ENDIF
      SET reply->wlist[x].slist[y].invalid_comp1_ind = 0
      SELECT INTO "nl:"
       FROM view_prefs vp,
        name_value_prefs nvp
       PLAN (vp
        WHERE vp.application_number=961000
         AND vp.frame_type IN ("ORG", "CHART")
         AND (vp.position_cd=request->position_code_value)
         AND vp.prsnl_id=0
         AND vp.active_ind=1)
        JOIN (nvp
        WHERE nvp.parent_entity_id=vp.view_prefs_id
         AND nvp.parent_entity_name="VIEW_PREFS"
         AND nvp.pvc_name="VIEW_CAPTION"
         AND (nvp.pvc_value=reply->wlist[x].slist[y].comp1_name))
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET reply->wlist[x].slist[y].invalid_comp1_ind = 1
      ENDIF
     ENDIF
     IF ((reply->wlist[x].slist[y].comp2_name > " "))
      IF ((reply->wlist[x].slist[y].comp2_name="Flowsheet - 2 day Lab  Rad  Vitals"))
       SET reply->wlist[x].slist[y].comp2_name = "Flowsheet - 2 day Lab, Rad, Vitals"
      ENDIF
      SET reply->wlist[x].slist[y].invalid_comp2_ind = 0
      SELECT INTO "nl:"
       FROM view_prefs vp,
        name_value_prefs nvp
       PLAN (vp
        WHERE vp.application_number=961000
         AND vp.frame_type IN ("ORG", "CHART")
         AND (vp.position_cd=request->position_code_value)
         AND vp.prsnl_id=0
         AND vp.active_ind=1)
        JOIN (nvp
        WHERE nvp.parent_entity_id=vp.view_prefs_id
         AND nvp.parent_entity_name="VIEW_PREFS"
         AND nvp.pvc_name="VIEW_CAPTION"
         AND (nvp.pvc_value=reply->wlist[x].slist[y].comp2_name))
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET reply->wlist[x].slist[y].invalid_comp2_ind = 1
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
 ENDFOR
#enditnow
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
