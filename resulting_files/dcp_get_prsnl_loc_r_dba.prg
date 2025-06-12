CREATE PROGRAM dcp_get_prsnl_loc_r:dba
 RECORD reply(
   1 qual[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 location_cd = f8
     2 location_disp = vc
     2 note = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  d.*, p.person_id, l.location_cd
  FROM dcp_prsnl_loc_r d,
   prsnl p,
   location l,
   (dummyt d1  WITH seq = 1)
  PLAN (d
   WHERE d.active_ind=1
    AND d.person_id > 0)
   JOIN (p
   WHERE d.person_id=p.person_id)
   JOIN (d1)
   JOIN (l
   WHERE d.location_cd=l.location_cd)
  ORDER BY p.name_full_formatted
  HEAD REPORT
   count1 = 0, stat = alterlist(reply->qual,1)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->qual,count1), reply->qual[count1].person_id = d
   .person_id,
   reply->qual[count1].name_full_formatted = p.name_full_formatted, reply->qual[count1].location_cd
    = d.location_cd, reply->qual[count1].location_disp = uar_get_code_display(d.location_cd),
   reply->qual[count1].note = d.note
  WITH nocounter, outerjoin = d1
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET stat = alterlist(reply->qual,count1)
  SET reply->status_data.status = "S"
 ENDIF
 FOR (count = 1 TO count1)
   CALL echo(reply->qual[count].person_id)
   CALL echo(reply->qual[count].name_full_formatted)
   CALL echo(reply->qual[count].location_cd)
   CALL echo(reply->qual[count].location_disp)
   CALL echo(reply->qual[count].note)
   CALL echo(reply->status_data.status)
 ENDFOR
END GO
