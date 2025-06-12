CREATE PROGRAM dcp_get_ref_text_by_version:dba
 SET modify = predeclare
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 ref_text_version[*]
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 text_type_cd = f8
      2 text_type_disp = c40
      2 text_type_mean = c12
      2 refr_text_id = f8
      2 ref_text_reltn_id = f8
      2 ref_text_active_ind = i2
      2 text_type_flag = i2
      2 text_locator = vc
      2 long_blob_id = f8
      2 long_blob_updt_cnt = i4
      2 long_blob = gvc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE log_status(operationname=vc,operationstatus=vc,targetobjectname=vc,targetobjectvalue=vc) =
 null
 DECLARE log_count = i4 WITH noconstant(0)
 SUBROUTINE log_status(operationname,operationstatus,targetobjectname,targetobjectvalue)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET log_count = size(reply->status_data.subeventstatus,5)
   IF (log_count=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET log_count = (log_count+ 1)
    ENDIF
   ELSE
    SET log_count = (log_count+ 1)
   ENDIF
   SET stat = alter(reply->status_data.subeventstatus,log_count)
   SET reply->status_data.subeventstatus[log_count].operationname = operationname
   SET reply->status_data.subeventstatus[log_count].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[log_count].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[log_count].targetobjectvalue = targetobjectvalue
 END ;Subroutine
 DECLARE where_cond = vc
 DECLARE offset = i4 WITH noconstant(0)
 DECLARE retlen = i4 WITH noconstant(0)
 DECLARE bloblen = i4 WITH noconstant(0)
 DECLARE count1 = i4 WITH noconstant(0)
 DECLARE blob_count = i4 WITH noconstant(0)
 DECLARE err_msg = vc
 SET reply->status_data.status = "F"
 SET where_cond = build("rtr.parent_entity_name = request->parent_entity_name",
  " and rtr.parent_entity_id = request->parent_entity_id")
 IF ((request->text_type_cd > 0))
  SET where_cond = build(where_cond," and rtr.text_type_cd = request->text_type_cd")
 ENDIF
 IF ((request->parent_entity_dt_tm > 0))
  SET where_cond = build(where_cond,
   " and rtr.beg_effective_dt_tm <= cnvtdatetime(request->parent_entity_dt_tm)")
  SET where_cond = build(where_cond,
   " and rtr.end_effective_dt_tm >= cnvtdatetime(request->parent_entity_dt_tm)")
 ENDIF
 SELECT INTO "nl:"
  bloblen = textlen(lb.long_blob)
  FROM ref_text_reltn rtr,
   ref_text rt,
   long_blob lb
  PLAN (rtr
   WHERE parser(where_cond))
   JOIN (rt
   WHERE rt.refr_text_id=rtr.refr_text_id)
   JOIN (lb
   WHERE lb.long_blob_id=rt.text_entity_id)
  ORDER BY rtr.beg_effective_dt_tm DESC
  HEAD REPORT
   count1 = 0, blob_count = 0, blob_length = 0,
   msg_buf = fillstring(32000," ")
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->ref_text_version,(count1+ 9))
   ENDIF
   reply->ref_text_version[count1].beg_effective_dt_tm = cnvtdatetime(rtr.beg_effective_dt_tm), reply
   ->ref_text_version[count1].end_effective_dt_tm = cnvtdatetime(rtr.end_effective_dt_tm), reply->
   ref_text_version[count1].text_type_cd = rtr.text_type_cd,
   reply->ref_text_version[count1].refr_text_id = rtr.refr_text_id, reply->ref_text_version[count1].
   ref_text_active_ind = rt.active_ind, reply->ref_text_version[count1].text_type_flag = rt
   .text_type_flag,
   reply->ref_text_version[count1].text_locator = rt.text_locator, reply->ref_text_version[count1].
   long_blob_id = lb.long_blob_id, reply->ref_text_version[count1].long_blob_updt_cnt = lb.updt_cnt,
   reply->ref_text_version[count1].ref_text_reltn_id = rtr.ref_text_reltn_id, offset = 0, retlen = 1
   WHILE (retlen > 0)
     retlen = blobget(msg_buf,offset,lb.long_blob)
     IF (retlen > 0)
      IF (retlen=size(msg_buf))
       reply->ref_text_version[count1].long_blob = concat(reply->ref_text_version[count1].long_blob,
        msg_buf)
      ELSE
       reply->ref_text_version[count1].long_blob = concat(reply->ref_text_version[count1].long_blob,
        substring(1,retlen,msg_buf))
      ENDIF
     ENDIF
     offset = (offset+ retlen)
   ENDWHILE
  FOOT REPORT
   stat = alterlist(reply->ref_text_version,count1)
  WITH nocounter, rdbarrayfetch = 1
 ;end select
 IF (curqual=0)
  SET err_msg = "unable to read from ref_text_reltn table"
  CALL log_status("READ","F","REF_TEXT_RELTN",err_msg)
  GO TO exit_script
 ENDIF
#exit_script
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
