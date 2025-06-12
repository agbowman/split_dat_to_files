CREATE PROGRAM cpmnotify_dcp_notes:dba
 RECORD reply(
   1 run_dt_tm = dq8
   1 overlay_ind = i2
   1 entity_list[*]
     2 entity_id = f8
     2 datalist[*]
       3 sticky_notes_ind = i2
       3 assign_notes_ind = i2
       3 roundnote_cnt = i4
       3 roundnote_list[*]
         4 public_ind = i2
         4 updt_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->overlay_ind = 1
 SET reply->status_data.status = "F"
 SET shiftnote_cd = 0.0
 SET shiftnote_mean = "ASGMTNOTE"
 SET powerchart_cd = 0.0
 SET powerchart_mean = "POWERCHART"
 SET roundnote_cd = 0.0
 SET roundnote_mean = "ROUNDNOTE"
 SET reply->run_dt_tm = cnvtdatetime(curdate,curtime3)
 SET r_cnt = size(request->entity_list,5)
 SET x = 0
 SET cnt = 0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 14122
 SET cdf_meaning = shiftnote_mean
 EXECUTE cpm_get_cd_for_cdf
 SET shiftnote_cd = code_value
 SET code_set = 14122
 SET cdf_meaning = powerchart_mean
 EXECUTE cpm_get_cd_for_cdf
 SET powerchart_cd = code_value
 SET code_set = 14122
 SET cdf_meaning = roundnote_mean
 EXECUTE cpm_get_cd_for_cdf
 SET roundnote_cd = code_value
 SELECT INTO "nl:"
  check = decode(sn.seq,"s","z"), p_id = request->entity_list[d.seq].entity_id
  FROM (dummyt d  WITH seq = value(r_cnt)),
   sticky_note sn
  PLAN (d)
   JOIN (sn
   WHERE (sn.parent_entity_id=request->entity_list[d.seq].entity_id)
    AND sn.parent_entity_name="PERSON"
    AND sn.sticky_note_type_cd IN (powerchart_cd, shiftnote_cd, roundnote_cd)
    AND sn.beg_effective_dt_tm < cnvtdatetime(reply->run_dt_tm)
    AND sn.end_effective_dt_tm > cnvtdatetime(reply->run_dt_tm))
  ORDER BY d.seq
  HEAD d.seq
   x = (x+ 1), stat = alterlist(reply->entity_list,x), reply->entity_list[x].entity_id = p_id,
   stat = alterlist(reply->entity_list[x].datalist,1), reply->entity_list[x].datalist[1].
   sticky_notes_ind = 0, reply->entity_list[x].datalist[1].assign_notes_ind = 0,
   reply->entity_list[x].datalist[1].roundnote_cnt = 0, cnt = 0
  DETAIL
   IF (check="s")
    IF (sn.sticky_note_type_cd=powerchart_cd)
     reply->entity_list[x].datalist[1].sticky_notes_ind = 1
    ELSEIF (sn.sticky_note_type_cd=shiftnote_cd)
     reply->entity_list[x].datalist[1].assign_notes_ind = 1
    ELSEIF (sn.sticky_note_type_cd=roundnote_cd)
     cnt = (cnt+ 1), reply->entity_list[x].datalist[1].roundnote_cnt = cnt, stat = alterlist(reply->
      entity_list[x].datalist[1].roundnote_list,cnt),
     reply->entity_list[x].datalist[1].roundnote_list[cnt].public_ind = sn.public_ind, reply->
     entity_list[x].datalist[1].roundnote_list[cnt].updt_id = sn.updt_id
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
