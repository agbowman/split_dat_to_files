CREATE PROGRAM dcp_get_tsk_loc_group:dba
 RECORD reply(
   1 location_group_cd = f8
   1 location_list[*]
     2 location_cd = f8
   1 loc_bed_list[*]
     2 loc_bed_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 222
 SET cdf_meaning = "NURSEUNIT"
 EXECUTE cpm_get_cd_for_cdf
 SET nurse_unit_type_cd = code_value
 SET code_set = 222
 SET cdf_meaning = "BED"
 EXECUTE cpm_get_cd_for_cdf
 SET bed_type_cd = code_value
 SET code_set = 222
 SET cdf_meaning = "AMBULATORY"
 EXECUTE cpm_get_cd_for_cdf
 SET ambulatory_type_cd = code_value
 SET location_cnt = 0
 SET loc_bed_cnt = 0
 SET cur_dt_tm = cnvtdatetime(curdate,curtime)
 SET reply->location_group_cd = temp_location_group_cd
 SELECT INTO "nl:"
  loc.location_cd, loc.location_type_cd
  FROM location_group lg,
   location loc,
   dummyt d,
   location_group lg2
  PLAN (lg
   WHERE lg.root_loc_cd=temp_location_group_cd
    AND lg.active_ind=1
    AND lg.beg_effective_dt_tm <= cnvtdatetime(cur_dt_tm)
    AND lg.end_effective_dt_tm >= cnvtdatetime(cur_dt_tm))
   JOIN (loc
   WHERE loc.location_cd=lg.child_loc_cd
    AND ((loc.location_type_cd=bed_type_cd) OR (((loc.location_type_cd=nurse_unit_type_cd) OR (loc
   .location_type_cd=ambulatory_type_cd)) ))
    AND loc.active_ind=1
    AND loc.beg_effective_dt_tm <= cnvtdatetime(cur_dt_tm)
    AND loc.end_effective_dt_tm >= cnvtdatetime(cur_dt_tm))
   JOIN (d)
   JOIN (lg2
   WHERE lg2.parent_loc_cd=loc.location_cd
    AND lg2.root_loc_cd=temp_location_group_cd
    AND lg2.active_ind=1
    AND lg2.beg_effective_dt_tm <= cnvtdatetime(cur_dt_tm)
    AND lg2.end_effective_dt_tm >= cnvtdatetime(cur_dt_tm))
  HEAD REPORT
   location_cnt = 0, loc_bed_cnt = 0
  DETAIL
   IF (((loc.location_type_cd=ambulatory_type_cd) OR (loc.location_type_cd=nurse_unit_type_cd)) )
    location_cnt = (location_cnt+ 1)
    IF (location_cnt > size(reply->location_list,5))
     stat = alterlist(reply->location_list,(location_cnt+ 5))
    ENDIF
    reply->location_list[location_cnt].location_cd = loc.location_cd
   ELSEIF (loc.location_type_cd=bed_type_cd)
    loc_bed_cnt = (loc_bed_cnt+ 1)
    IF (loc_bed_cnt > size(reply->loc_bed_list,5))
     stat = alterlist(reply->loc_bed_list,(loc_bed_cnt+ 5))
    ENDIF
    reply->loc_bed_list[loc_bed_cnt].loc_bed_cd = loc.location_cd
   ENDIF
  WITH outerjoin = d, dontexist
 ;end select
 SET stat = alterlist(reply->location_list,location_cnt)
 SET stat = alterlist(reply->loc_bed_list,loc_bed_cnt)
 SET reply->location_group_cd = temp_location_group_cd
END GO
