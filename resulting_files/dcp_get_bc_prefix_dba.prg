CREATE PROGRAM dcp_get_bc_prefix:dba
 RECORD reply(
   1 qual[*]
     2 prefix = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE org_id = f8
 DECLARE count1 = i4
 SET org_id = 0
 SET count1 = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM location l
  WHERE (l.location_cd=request->location_cd)
   AND l.active_ind=1
  DETAIL
   org_id = l.organization_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET errmsg = concat("Organization not found for a given location_cd: ",cnvtstring(request->
    location_cd))
  CALL logstatus("SELECT","F","LOCATION",errmsg)
  GO TO exit_prg
 ENDIF
 SELECT DISTINCT INTO "nl:"
  trim(obf.prefix)
  FROM org_barcode_org obo,
   org_barcode_format obf
  PLAN (obo
   WHERE ((obo.scan_organization_id=org_id) OR (obo.scan_organization_id=0)) )
   JOIN (obf
   WHERE ((obf.organization_id=obo.label_organization_id
    AND obo.scan_organization_id > 0
    AND (obf.barcode_type_cd=request->barcode_type_cd)) OR (obo.scan_organization_id=0
    AND obf.organization_id=org_id
    AND (obf.barcode_type_cd=request->barcode_type_cd))) )
  ORDER BY obf.prefix
  HEAD REPORT
   count1 = 0
  HEAD obf.prefix
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].prefix = trim(obf.prefix)
  FOOT REPORT
   stat = alterlist(reply->qual,count1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET errmsg = concat("Formats did not qualify for organization_id: ",cnvtstring(org_id))
  CALL logstatus("SELECT","F","ORG_BARCODE_FORMAT",errmsg)
  GO TO exit_prg
 ENDIF
#exit_prg
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSEIF (curqual=1)
  SET reply->status_data.status = "S"
 ENDIF
 DECLARE logstatus(operationname=c25,operationstatus=c1,targetobjectname=c25,targetobjectvalue=vc) =
 null
 SUBROUTINE logstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
   SET reply->status_data.subeventstatus[1].operationname = operationname
   SET reply->status_data.subeventstatus[1].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[1].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[1].targetobjectvalue = targetobjectvalue
 END ;Subroutine
END GO
