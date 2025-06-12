CREATE PROGRAM bed_get_os_notes:dba
 FREE SET reply
 RECORD reply(
   1 notes[*]
     2 text = vc
     2 order_sets[*]
       3 code_value = f8
       3 description = vc
       3 primary_synonym_mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET tnotes
 RECORD tnotes(
   1 notes[*]
     2 note_id = f8
     2 note_txt = vc
     2 os_code = f8
     2 os_desc = vc
     2 os_ps_mnem = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET list_cnt = 0
 SET cnt2 = 0
 SET list_cnt2 = 0
 SET tot_cnt = 0
 SET note_code = 0.0
 SET note_code = uar_get_code_by("MEANING",6030,"NOTE")
 SET cnt = 0
 SELECT INTO "nl:"
  FROM cs_component cs,
   order_catalog oc,
   long_text lt
  PLAN (cs
   WHERE cs.comp_type_cd=note_code
    AND cs.long_text_id > 0)
   JOIN (oc
   WHERE oc.catalog_cd=cs.catalog_cd
    AND oc.active_ind=1)
   JOIN (lt
   WHERE lt.long_text_id=cs.long_text_id
    AND lt.active_ind=1)
  ORDER BY lt.long_text_id
  HEAD REPORT
   cnt = 0, list_cnt = 0, stat = alterlist(tnotes->notes,100)
  HEAD lt.long_text
   cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
   IF (list_cnt > 100)
    stat = alterlist(tnotes->notes,(cnt+ 100)), list_cnt = 1
   ENDIF
   tnotes->notes[cnt].note_id = lt.long_text_id, tnotes->notes[cnt].note_txt = lt.long_text, tnotes->
   notes[cnt].os_code = oc.catalog_cd,
   tnotes->notes[cnt].os_desc = oc.description, tnotes->notes[cnt].os_ps_mnem = oc.primary_mnemonic
  FOOT REPORT
   stat = alterlist(tnotes->notes,cnt)
  WITH nocounter
 ;end select
 CALL echorecord(tnotes)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 DECLARE note_sort = vc
 SELECT INTO "nl:"
  note_sort = tnotes->notes[d.seq].note_txt, id_sort = tnotes->notes[d.seq].os_code
  FROM (dummyt d  WITH seq = value(cnt))
  PLAN (d)
  ORDER BY note_sort, id_sort
  HEAD REPORT
   rcnt = 0, rtcnt = 0, stat = alterlist(reply->notes,100)
  HEAD note_sort
   CALL echo(build("NOTE SORT: ",note_sort)), rcnt = (rcnt+ 1), rtcnt = (rtcnt+ 1)
   IF (rtcnt > 100)
    stat = alterlist(reply->notes,(rtcnt+ 100)), rcnt = 1
   ENDIF
   reply->notes[rtcnt].text = tnotes->notes[d.seq].note_txt, ncnt = 0, ntcnt = 0,
   stat = alterlist(reply->notes[rtcnt].order_sets,100)
  HEAD id_sort
   ncnt = (ncnt+ 1), ntcnt = (ntcnt+ 1)
   IF (ntcnt > 100)
    stat = alterlist(reply->notes[rtcnt].order_sets,(ntcnt+ 100)), ncnt = 1
   ENDIF
   reply->notes[rtcnt].order_sets[ntcnt].code_value = tnotes->notes[d.seq].os_code, reply->notes[
   rtcnt].order_sets[ntcnt].description = tnotes->notes[d.seq].os_desc, reply->notes[rtcnt].
   order_sets[ntcnt].primary_synonym_mnemonic = tnotes->notes[d.seq].os_ps_mnem
  FOOT  note_sort
   stat = alterlist(reply->notes[rtcnt].order_sets,ntcnt)
  FOOT REPORT
   stat = alterlist(reply->notes,rtcnt)
  WITH nocounter
 ;end select
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
