CREATE PROGRAM cp_get_section_position:dba
 RECORD reply(
   1 qual[*]
     2 position_cd = f8
     2 position_name = c50
     2 position_qual[*]
       3 chart_section_id = f8
       3 chart_section_name = c50
       3 chart_format_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE failed_ind = i2 WITH public, noconstant(1)
 DECLARE x = i4 WITH public, noconstant(0)
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=88
   AND c.active_ind=1
  DETAIL
   x = (x+ 1)
   IF (x > size(reply->qual,5))
    stat = alterlist(reply->qual,(x+ 9))
   ENDIF
   reply->qual[x].position_cd = c.code_value, reply->qual[x].position_name = c.display
  FOOT REPORT
   stat = alterlist(reply->qual,x)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET failed_ind = 0
 ENDIF
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(x)),
   sect_position_reltn s,
   chart_section cs
  PLAN (d)
   JOIN (s
   WHERE (s.position_cd=reply->qual[d.seq].position_cd)
    AND s.active_ind=1)
   JOIN (cs
   WHERE cs.chart_section_id=s.chart_section_id)
  HEAD d.seq
   x = 0
  DETAIL
   x = (x+ 1)
   IF (x > size(reply->qual[d.seq].position_qual,5))
    stat = alterlist(reply->qual[d.seq].position_qual,(x+ 9))
   ENDIF
   reply->qual[d.seq].position_qual[x].chart_section_id = s.chart_section_id, reply->qual[d.seq].
   position_qual[x].chart_section_name = cs.chart_section_desc, reply->qual[d.seq].position_qual[x].
   chart_format_id = s.chart_format_id
  FOOT  d.seq
   stat = alterlist(reply->qual[d.seq].position_qual,x)
  WITH nocounter
 ;end select
 IF (failed_ind=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
END GO
