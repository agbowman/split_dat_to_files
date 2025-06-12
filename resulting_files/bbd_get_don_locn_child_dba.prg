CREATE PROGRAM bbd_get_don_locn_child:dba
 RECORD reply(
   1 childlist[*]
     2 location_cd = f8
     2 location_cd_disp = c40
     2 location_cd_desc = vc
     2 location_cd_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET childcount = 0
 SELECT INTO "nl:"
  lg.parent_loc_cd
  FROM location_group lg,
   code_value c
  PLAN (lg
   WHERE (lg.parent_loc_cd=request->parent_loc_cd)
    AND lg.active_ind=1
    AND (lg.active_status_cd=reqdata->active_status_cd)
    AND lg.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND lg.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (c
   WHERE c.code_value=lg.location_group_type_cd
    AND c.code_set=222
    AND c.active_ind=1
    AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ((c.cdf_meaning="FACILITY") OR (((c.cdf_meaning="BUILDING") OR (((c.cdf_meaning="BBINVAREA")
    OR (c.cdf_meaning="BBDRAW")) )) )) )
  DETAIL
   childcount = (childcount+ 1), stat = alterlist(reply->childlist,childcount), reply->childlist[
   childcount].location_cd = lg.child_loc_cd
  WITH counter
 ;end select
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "T"
 ENDIF
END GO
