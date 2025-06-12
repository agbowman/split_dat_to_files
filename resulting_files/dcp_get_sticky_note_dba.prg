CREATE PROGRAM dcp_get_sticky_note:dba
 RECORD reply(
   1 sticky_note_cnt = i4
   1 qual[5]
     2 sticky_note_id = f8
     2 sticky_note_text = vc
     2 sticky_note_status_cd = f8
     2 sticky_note_status_cd_disp = c40
     2 sticky_note_status_cd_mean = c12
     2 public_ind = i2
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_name = c40
     2 beg_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET reply->sticky_note_cnt = 0
 SET cur_dt_tm = cnvtdatetime(curdate,curtime3)
 SELECT INTO "nl:"
  sn.updt_dt_tm, p.name_full_formatted, lt.long_text_id
  FROM sticky_note sn,
   prsnl p,
   long_text lt
  WHERE (sn.sticky_note_type_cd=request->sticky_note_type_cd)
   AND (sn.parent_entity_name=request->parent_entity_name)
   AND (sn.parent_entity_id=request->parent_entity_id)
   AND sn.updt_id=p.person_id
   AND sn.long_text_id=lt.long_text_id
   AND ((nullind(sn.beg_effective_dt_tm)=1) OR (sn.beg_effective_dt_tm <= cnvtdatetime(cur_dt_tm)))
   AND ((nullind(sn.end_effective_dt_tm)=1) OR (sn.end_effective_dt_tm > cnvtdatetime(cur_dt_tm)))
  ORDER BY sn.updt_dt_tm DESC
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->qual,5))
    stat = alter(reply->qual,(count1+ 10))
   ENDIF
   reply->qual[count1].sticky_note_id = sn.sticky_note_id
   IF (sn.long_text_id > 0)
    reply->qual[count1].sticky_note_text = lt.long_text
   ELSE
    reply->qual[count1].sticky_note_text = sn.sticky_note_text
   ENDIF
   reply->qual[count1].sticky_note_status_cd = sn.sticky_note_status_cd, reply->qual[count1].
   public_ind = sn.public_ind, reply->qual[count1].updt_dt_tm = sn.updt_dt_tm,
   reply->qual[count1].updt_id = sn.updt_id, reply->qual[count1].updt_name = p.name_full_formatted,
   reply->qual[count1].beg_effective_dt_tm = sn.beg_effective_dt_tm
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alter(reply->qual,count1)
 SET reply->sticky_note_cnt = count1
END GO
