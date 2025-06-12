CREATE PROGRAM dcp_get_nomen_info_by_id:dba
 RECORD reply(
   1 qual[*]
     2 source_string = vc
     2 nomenclature_id = f8
     2 active_ind = i2
   1 status_data
     2 status = c1
 )
 DECLARE nomenclature_cnt = i4
 DECLARE nomen_cnt = i4
 SET nomenclature_cnt = 0
 SET reply->status_data.status = "F"
 SET nomen_cnt = size(request->qual,5)
 SELECT INTO "nl:"
  n.nomenclature
  FROM nomenclature n,
   (dummyt d  WITH seq = value(nomen_cnt))
  PLAN (d)
   JOIN (n
   WHERE (n.nomenclature_id=request->qual[d.seq].nomenclature_id))
  DETAIL
   nomenclature_cnt = (nomenclature_cnt+ 1)
   IF (mod(nomenclature_cnt,10)=1)
    stat = alterlist(reply->qual,(nomenclature_cnt+ 9))
   ENDIF
   reply->qual[nomenclature_cnt].source_string = n.source_string, reply->qual[nomenclature_cnt].
   nomenclature_id = n.nomenclature_id, reply->qual[nomenclature_cnt].active_ind = n.active_ind
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,nomenclature_cnt)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
