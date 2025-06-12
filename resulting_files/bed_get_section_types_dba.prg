CREATE PROGRAM bed_get_section_types:dba
 FREE SET reply
 RECORD reply(
   1 qual[*]
     2 modality_name = vc
     2 modality_cd = f8
     2 modality_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 qual[*]
     2 modality_name = vc
     2 modality_cd = f8
     2 modality_mean = vc
     2 rqual[*]
       3 room_cd = f8
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 DECLARE radexamroom = f8 WITH public, noconstant(0.0)
 DECLARE radiology = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="RADEXAMROOM"
    AND cv.active_ind=1)
  DETAIL
   radexamroom = cv.code_value
  WITH nocounter
 ;end select
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM service_resource sr,
   resource_group rg,
   code_value cv,
   resource_group rg2,
   resource_group rg3,
   service_resource sr2
  PLAN (sr
   WHERE (sr.service_resource_cd=request->dept_cd)
    AND ((sr.active_ind+ 0)=1))
   JOIN (rg
   WHERE rg.parent_service_resource_cd=sr.service_resource_cd
    AND rg.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=rg.child_service_resource_cd)
   JOIN (rg2
   WHERE rg2.parent_service_resource_cd=rg.child_service_resource_cd
    AND rg2.active_ind=1)
   JOIN (rg3
   WHERE rg3.parent_service_resource_cd=rg2.child_service_resource_cd
    AND rg3.active_ind=1)
   JOIN (sr2
   WHERE sr2.service_resource_cd=rg3.child_service_resource_cd
    AND ((sr2.service_resource_type_cd+ 0)=radexamroom)
    AND ((sr2.active_ind+ 0)=1))
  ORDER BY rg.sequence
  HEAD REPORT
   cnt = 0, rcnt = 0
  HEAD rg.child_service_resource_cd
   rcnt = 0, cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt),
   temp->qual[cnt].modality_name = cv.description, temp->qual[cnt].modality_cd = rg
   .child_service_resource_cd, temp->qual[cnt].modality_mean = cv.display
  DETAIL
   rcnt = (rcnt+ 1), stat = alterlist(temp->qual[cnt].rqual,rcnt), temp->qual[cnt].rqual[rcnt].
   room_cd = sr2.service_resource_cd
  WITH nocounter
 ;end select
 SET cnt = 0
 FOR (x = 1 TO size(temp->qual,5))
   SET calendar_found = 0
   SET rcnt = size(temp->qual[x].rqual,5)
   IF (rcnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = rcnt),
      loc_resource_calendar l
     PLAN (d)
      JOIN (l
      WHERE (l.service_resource_cd=temp->qual[x].rqual[d.seq].room_cd))
     DETAIL
      calendar_found = 1
     WITH nocounter
    ;end select
   ENDIF
   IF (calendar_found=0)
    SET cnt = (cnt+ 1)
    SET stat = alterlist(reply->qual,cnt)
    SET reply->qual[cnt].modality_name = temp->qual[x].modality_name
    SET reply->qual[cnt].modality_cd = temp->qual[x].modality_cd
    SET reply->qual[cnt].modality_mean = temp->qual[x].modality_mean
   ENDIF
 ENDFOR
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
