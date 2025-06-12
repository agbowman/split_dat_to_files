CREATE PROGRAM bed_get_ord_sent_by_format:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 order_sentence_id[*]
      2 order_sentence_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 completed_ind = i2
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE max_reply = i4 WITH constant(65000)
 SET req_cnt = size(request->order_entry_format_id,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 DECLARE usage_flag_parser = vc WITH noconstant(" ")
 IF (validate(request->usage_flags) != 0)
  IF (size(request->usage_flags,5)=0)
   SET usage_flag_parser = "os.usage_flag >= 0 "
  ELSE
   FOR (i = 1 TO size(request->usage_flags,5))
     IF (i=1)
      SET usage_flag_parser = build2("os.usage_flag = ",value(request->usage_flags[i].flag))
      IF ((request->usage_flags[i].flag=1))
       SET usage_flag_parser = build2(usage_flag_parser," or os.usage_flag = ",0)
      ENDIF
     ELSE
      SET usage_flag_parser = build2(usage_flag_parser," or os.usage_flag = ",value(request->
        usage_flags[i].flag))
      IF ((request->usage_flags[i].flag=1))
       SET usage_flag_parser = build2(usage_flag_parser," or os.usage_flag = ",0)
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
 ELSE
  IF ((request->usage_flag=0))
   SET usage_flag_parser = "os.usage_flag = 1 or os.usage_flag = 2 "
  ELSE
   SET usage_flag_parser = build2("os.usage_flag = ",value(request->usage_flag))
  ENDIF
 ENDIF
 DECLARE idx1 = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM order_sentence os,
   order_sentence_detail osd
  PLAN (os
   WHERE expand(idx1,1,req_cnt,os.oe_format_id,request->order_entry_format_id[idx1].
    order_entry_format_id)
    AND parser(usage_flag_parser))
   JOIN (osd
   WHERE osd.order_sentence_id=os.order_sentence_id)
  ORDER BY os.order_sentence_id
  HEAD os.order_sentence_id
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
  FROM order_sentence os,
   order_sentence_detail osd
  PLAN (os
   WHERE expand(idx1,1,req_cnt,os.oe_format_id,request->order_entry_format_id[idx1].
    order_entry_format_id)
    AND parser(usage_flag_parser))
   JOIN (osd
   WHERE osd.order_sentence_id=os.order_sentence_id)
  ORDER BY os.order_sentence_id
  HEAD REPORT
   scnt = 0, listcount = 0, stat = alterlist(reply->order_sentence_id,1000),
   curindex = 0
  HEAD os.order_sentence_id
   curindex = (curindex+ 1)
   IF (scnt < max_cnt
    AND (curindex > request->last_index))
    scnt = (scnt+ 1)
    IF (listcount > 1000)
     stat = alterlist(reply->order_sentence_id,(scnt+ 1000)), listcount = 1
    ENDIF
    stat = alterlist(reply->order_sentence_id,scnt), reply->order_sentence_id[scnt].order_sentence_id
     = os.order_sentence_id
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->order_sentence_id,scnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
