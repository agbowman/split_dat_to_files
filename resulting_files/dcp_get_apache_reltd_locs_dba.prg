CREATE PROGRAM dcp_get_apache_reltd_locs:dba
 RECORD reply(
   1 org_list[*]
     2 organization_id = f8
     2 org_name = vc
     2 loc_list[*]
       3 location_cd = f8
       3 location_disp = vc
       3 location_desc = vc
       3 location_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE count0 = i2 WITH noconstant(0), public
 DECLARE count1 = i2 WITH noconstant(0), public
 SELECT INTO "nl:"
  FROM organization o,
   location l
  PLAN (o
   WHERE o.organization_id > 0
    AND o.active_ind=1)
   JOIN (l
   WHERE l.organization_id=o.organization_id
    AND (l.apache_reltn_flag=request->apache_reltn_flag)
    AND l.active_ind=1)
  HEAD REPORT
   count0 = 0
  HEAD o.organization_id
   count1 = 0, count0 = (count0+ 1), stat = alterlist(reply->org_list,count0),
   reply->org_list[count0].organization_id = o.organization_id, reply->org_list[count0].org_name = o
   .org_name
  DETAIL
   IF (l.location_cd > 0)
    count1 = (count1+ 1), stat = alterlist(reply->org_list[count0].loc_list,count1), reply->org_list[
    count0].loc_list[count1].location_cd = l.location_cd
   ENDIF
  WITH nocounter
 ;end select
 IF (count0 > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
