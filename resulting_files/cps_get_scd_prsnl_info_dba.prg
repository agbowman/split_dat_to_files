CREATE PROGRAM cps_get_scd_prsnl_info:dba
 FREE RECORD reply
 RECORD reply(
   1 prsnl[*]
     2 person_id = f8
     2 name_full_formatted = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 cps_error
     2 cnt = i4
     2 data[*]
       3 code = i4
       3 severity_level = i4
       3 supp_err_txt = c32
       3 def_msg = vc
       3 row_data
         4 lvl_1_idx = i4
         4 lvl_2_idx = i4
         4 lvl_3_idx = i4
 )
 DECLARE expand_start = i4 WITH protect, noconstant(1)
 DECLARE expand_idx = i4 WITH protect, noconstant(0)
 DECLARE id_idx = i4 WITH protect, noconstant(0)
 DECLARE locate_idx = i4 WITH protect, noconstant(0)
 DECLARE reply_size = i4 WITH protect, noconstant(0)
 DECLARE expand_size = i4 WITH protect, constant(10)
 DECLARE req_size = i4 WITH protect, constant(size(request->prsnl,5))
 DECLARE loop_count = i4 WITH protect, constant(ceil((cnvtreal(req_size)/ expand_size)))
 DECLARE new_size = i4 WITH protect, constant((loop_count * expand_size))
 IF (req_size=0)
  SET reply->status_data.status = "S"
  RETURN
 ENDIF
 IF (req_size != new_size)
  SET stat = alterlist(request->prsnl,new_size)
  DECLARE last_id = f8 WITH protect, constant(request->prsnl[req_size].person_id)
  FOR (id_idx = (req_size+ 1) TO new_size)
    SET request->prsnl[id_idx].person_id = last_id
  ENDFOR
 ENDIF
 SET stat = alterlist(reply->prsnl,req_size)
 SELECT INTO "NL:"
  p.person_id
  FROM (dummyt d  WITH seq = value(loop_count)),
   prsnl p
  PLAN (d
   WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
   JOIN (p
   WHERE expand(expand_idx,expand_start,(expand_start+ (expand_size - 1)),p.person_id,request->prsnl[
    expand_idx].person_id))
  DETAIL
   reply_size = (reply_size+ 1)
   IF (reply_size <= req_size)
    reply->prsnl[reply_size].person_id = p.person_id, reply->prsnl[reply_size].name_full_formatted =
    p.name_full_formatted
   ENDIF
  WITH nocounter
 ;end select
 IF (reply_size <= req_size)
  SET stat = alterlist(reply->prsnl,reply_size)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "Select From Prsnl"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Prsnl"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "More rows returned than requested"
 ENDIF
END GO
