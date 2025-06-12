CREATE PROGRAM bed_get_facility:dba
 FREE SET reply
 RECORD reply(
   1 organization_id = f8
   1 organization_name = c100
   1 organization_prefix = c5
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET facility_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=222
   AND c.cdf_meaning="FACILITY"
  DETAIL
   facility_cd = c.code_value
  WITH nocounter
 ;end select
 IF ((request->facility_id=0.0))
  GO TO exit_script
 ELSE
  SELECT INTO "nl:"
   FROM code_value c,
    location l,
    organization o,
    br_organization b
   PLAN (c
    WHERE (c.code_value=request->facility_id)
     AND c.code_set=220
     AND c.active_ind=1)
    JOIN (l
    WHERE l.location_cd=c.code_value
     AND l.location_type_cd=facility_cd)
    JOIN (o
    WHERE o.organization_id=l.organization_id)
    JOIN (b
    WHERE b.organization_id=outerjoin(l.organization_id))
   DETAIL
    reply->organization_id = o.organization_id, reply->organization_name = o.org_name, reply->
    organization_prefix = b.br_prefix
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
