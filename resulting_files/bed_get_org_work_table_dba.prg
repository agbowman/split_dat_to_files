CREATE PROGRAM bed_get_org_work_table:dba
 FREE SET reply
 RECORD reply(
   1 org_list[*]
     2 org_id = f8
     2 name = c60
     2 display = c40
     2 prefix = c4
     2 tax_id = c100
     2 time_zone_id = f8
     2 time_zone_display = c100
     2 start_ind = i2
     2 lab_ind = i2
     2 loc_list[*]
       3 loc_id = f8
       3 name = c60
       3 display = c40
       3 prefix = c6
       3 loc_type = c30
       3 outreach_ind = i2
       3 address1 = c100
       3 address2 = c100
       3 city = c100
       3 state_code_value = f8
       3 state_display = c40
       3 county_code_value = f8
       3 county_display = c40
       3 country_code_value = f8
       3 country_display = c40
       3 zip = c25
       3 phone = c50
       3 extension = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_count = 0
 SET count = 0
 SET tot_loc = 0
 SET loc_count = 0
 SET stat = alterlist(reply->org_list,50)
 SELECT INTO "NL:"
  FROM br_org_work org,
   br_loc_work loc,
   br_time_zone tz,
   code_value cv62,
   code_value cv15,
   code_value cv74
  PLAN (org
   WHERE org.status_ind=0)
   JOIN (tz
   WHERE tz.time_zone_id=outerjoin(org.time_zone_id))
   JOIN (loc
   WHERE loc.organization_id=org.organization_id)
   JOIN (cv62
   WHERE cv62.active_ind=outerjoin(1)
    AND cv62.code_set=outerjoin(62)
    AND cv62.code_value=outerjoin(loc.state_cd))
   JOIN (cv15
   WHERE cv15.active_ind=outerjoin(1)
    AND cv15.code_set=outerjoin(15)
    AND cv15.code_value=outerjoin(loc.country_cd))
   JOIN (cv74
   WHERE cv74.active_ind=outerjoin(1)
    AND cv74.code_set=outerjoin(74)
    AND cv74.code_value=outerjoin(loc.county_cd))
  ORDER BY loc.organization_id, loc.sequence
  HEAD org.organization_id
   IF (tot_count > 0)
    stat = alterlist(reply->org_list[tot_count].loc_list,tot_loc)
   ENDIF
   tot_count = (tot_count+ 1), count = (count+ 1)
   IF (count > 50)
    stat = alterlist(reply->org_list,(tot_count+ 50)), count = 1
   ENDIF
   reply->org_list[tot_count].org_id = org.organization_id, reply->org_list[tot_count].name = org
   .name, reply->org_list[tot_count].display = org.org_display,
   reply->org_list[tot_count].prefix = org.prefix, reply->org_list[tot_count].tax_id = org.tax_id_nbr,
   reply->org_list[tot_count].time_zone_id = org.time_zone_id,
   reply->org_list[tot_count].time_zone_display = tz.description, reply->org_list[tot_count].
   start_ind = org.start_ind, reply->org_list[tot_count].lab_ind = org.lab_ind,
   loc_count = 0, tot_loc = 0, stat = alterlist(reply->org_list[tot_count].loc_list,20)
  DETAIL
   tot_loc = (tot_loc+ 1), loc_count = (loc_count+ 1)
   IF (loc_count > 20)
    stat = alterlist(reply->org_list[tot_count].loc_list,(tot_loc+ 20)), loc_count = 1
   ENDIF
   reply->org_list[tot_count].loc_list[tot_loc].loc_id = loc.location_id, reply->org_list[tot_count].
   loc_list[tot_loc].name = loc.name, reply->org_list[tot_count].loc_list[tot_loc].display = loc
   .loc_display,
   reply->org_list[tot_count].loc_list[tot_loc].prefix = loc.prefix, reply->org_list[tot_count].
   loc_list[tot_loc].loc_type = loc.type, reply->org_list[tot_count].loc_list[tot_loc].outreach_ind
    = loc.outreach_ind,
   reply->org_list[tot_count].loc_list[tot_loc].address1 = loc.address1, reply->org_list[tot_count].
   loc_list[tot_loc].address2 = loc.address2, reply->org_list[tot_count].loc_list[tot_loc].city = loc
   .city,
   reply->org_list[tot_count].loc_list[tot_loc].state_code_value = loc.state_cd, reply->org_list[
   tot_count].loc_list[tot_loc].state_display = cv62.display, reply->org_list[tot_count].loc_list[
   tot_loc].county_code_value = loc.county_cd,
   reply->org_list[tot_count].loc_list[tot_loc].county_display = cv74.display, reply->org_list[
   tot_count].loc_list[tot_loc].country_code_value = loc.country_cd, reply->org_list[tot_count].
   loc_list[tot_loc].country_display = cv15.display,
   reply->org_list[tot_count].loc_list[tot_loc].zip = loc.zip, reply->org_list[tot_count].loc_list[
   tot_loc].phone = loc.phone, reply->org_list[tot_count].loc_list[tot_loc].extension = loc.extension
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->org_list[tot_count].loc_list,tot_loc)
 SET stat = alterlist(reply->org_list,tot_count)
 IF (tot_count=0)
  SET reply->status_data.status = "Z"
 ENDIF
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ENDIF
#enditnow
END GO
