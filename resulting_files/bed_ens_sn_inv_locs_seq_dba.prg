CREATE PROGRAM bed_ens_sn_inv_locs_seq:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_root
 RECORD temp_root(
   1 roots[*]
     2 code_value = f8
 )
 SET active_code_value = 0.0
 SET invloc_code_value = 0.0
 SET invlocator_code_value = 0.0
 SET auth_code_value = 0.0
 SET cnt = 0
 SET cnt2 = 0
 SET list_cnt = 0
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  DETAIL
   active_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning="INVLOC"
   AND cv.active_ind=1
  DETAIL
   invloc_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET cnt = size(request->inv_locations,5)
 FOR (x = 1 TO cnt)
   SELECT DISTINCT INTO "nl:"
    lg.root_loc_cd
    FROM location_group lg
    PLAN (lg
     WHERE (lg.parent_loc_cd=request->inv_locations[x].code_value))
    ORDER BY lg.root_loc_cd
    HEAD REPORT
     cnt2 = 0, list_cnt = 0, stat = alterlist(temp_root->roots,10)
    DETAIL
     cnt2 = (cnt2+ 1), list_cnt = (list_cnt+ 1)
     IF (list_cnt > 10)
      stat = alterlist(temp_root->roots,(cnt2+ 10)), list_cnt = 1
     ENDIF
     temp_root->roots[cnt2].code_value = lg.root_loc_cd
    FOOT REPORT
     stat = alterlist(temp_root->roots,cnt2)
    WITH nocounter
   ;end select
   DELETE  FROM location_group lg
    WHERE (lg.parent_loc_cd=request->inv_locations[x].code_value)
     AND lg.location_group_type_cd=invloc_code_value
    WITH nocounter
   ;end delete
   SET list_cnt = size(request->inv_locations[x].inv_locators,5)
   IF (list_cnt > 0)
    FOR (y = 1 TO cnt2)
      SET ierrcode = 0
      INSERT  FROM location_group lg,
        (dummyt d  WITH seq = list_cnt)
       SET lg.parent_loc_cd = request->inv_locations[x].code_value, lg.child_loc_cd = request->
        inv_locations[x].inv_locators[d.seq].code_value, lg.location_group_type_cd =
        invloc_code_value,
        lg.active_ind = 1, lg.active_status_cd = active_code_value, lg.active_status_dt_tm =
        cnvtdatetime(curdate,curtime3),
        lg.active_status_prsnl_id = reqinfo->updt_id, lg.beg_effective_dt_tm = cnvtdatetime(curdate,
         curtime3), lg.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
        lg.sequence = request->inv_locations[x].inv_locators[d.seq].sequence, lg.updt_dt_tm =
        cnvtdatetime(curdate,curtime3), lg.updt_id = reqinfo->updt_id,
        lg.updt_task = reqinfo->updt_task, lg.updt_cnt = 0, lg.updt_applctx = reqinfo->updt_applctx,
        lg.root_loc_cd = temp_root->roots[y].code_value, lg.view_type_cd = 0
       PLAN (d)
        JOIN (lg)
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET reply->error_msg = concat("Unable to insert inventory locators for location: ",trim(
         request->inv_locations[x].code_value)," into the location group table. ERROR: ",serrmsg)
       GO TO exit_script
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
