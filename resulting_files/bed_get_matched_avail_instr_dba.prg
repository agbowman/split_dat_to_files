CREATE PROGRAM bed_get_matched_avail_instr:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 available_instr[*]
      2 available_instr_desc = vc
    1 completed_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE max_reply = i4 WITH constant(10000)
 DECLARE idx1 = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE req_cnt = i4 WITH protect
 SET reply->status_data.status = "F"
 SET req_cnt = size(request->items,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM pat_ed_reltn p
  PLAN (p
   WHERE expand(idx1,1,req_cnt,p.pat_ed_reltn_desc,request->items[idx1].item_mid))
  ORDER BY p.pat_ed_reltn_desc
  HEAD p.pat_ed_reltn_desc
   cnt = (cnt+ 1)
  WITH nocounter
 ;end select
 DECLARE max_cnt = i4 WITH protect
 SET max_cnt = 0
 SET max_cnt = request->last_index
 IF (((cnt - max_cnt) > max_reply))
  SET max_cnt = max_reply
  SET reply->completed_ind = 0
 ELSE
  SET max_cnt = (cnt - request->last_index)
  SET reply->completed_ind = 1
 ENDIF
 SELECT INTO "nl:"
  FROM pat_ed_reltn p
  PLAN (p
   WHERE expand(idx1,1,req_cnt,p.pat_ed_reltn_desc,request->items[idx1].item_mid))
  ORDER BY p.pat_ed_reltn_desc
  HEAD REPORT
   scnt = 0, listcount = 0, stat = alterlist(reply->available_instr,1000),
   curindex = 0
  HEAD p.pat_ed_reltn_desc
   curindex = (curindex+ 1)
   IF (scnt < max_cnt
    AND (curindex > request->last_index))
    scnt = (scnt+ 1)
    IF (listcount > 1000)
     stat = alterlist(reply->available_instr,(scnt+ 1000)), listcount = 1
    ENDIF
    stat = alterlist(reply->available_instr,scnt), reply->available_instr[scnt].available_instr_desc
     = p.pat_ed_reltn_desc
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->available_instr,scnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
