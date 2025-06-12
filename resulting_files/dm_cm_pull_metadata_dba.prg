CREATE PROGRAM dm_cm_pull_metadata:dba
 FREE RECORD dcp_script_rec
 RECORD dcp_script_rec(
   1 qual[*]
     2 sname = vc
     2 group_num = i4
     2 dict_date_utc = dq8
     2 info_date_utc = dq8
     2 exec_script_ind = i2
     2 remove_ind = i2
 )
 FREE RECORD dcp_reply
 RECORD dcp_reply(
   1 status = c1
   1 message = vc
 )
 DECLARE dcp_script_prefix = vc WITH protect, noconstant( $1)
 DECLARE dcp_cust_cnt = i4 WITH protect, noconstant(0)
 DECLARE dcp_noexec_script_cnt = i4 WITH protect, noconstant(0)
 DECLARE dcp_err = i4 WITH protect, noconstant(0)
 DECLARE dcp_idx = i4 WITH protect, noconstant(0)
 DECLARE dcp_pos = i4 WITH protect, noconstant(0)
 DECLARE dcp_cust_tbl_missing = i4 WITH protect, noconstant(0)
 DECLARE dcp_recpos = i2 WITH protect, noconstant(0)
 DECLARE dcp_ndx = i2 WITH protect, noconstant(0)
 DECLARE dcp_err_msg = vc WITH protect, noconstant("")
 DECLARE dcp_loopcnt = i2 WITH protect, noconstant(0)
 DECLARE dcp_remove_ind = i2 WITH protect, noconstant(0)
 DECLARE dcp_grp_scrpt_name = vc WITH protect, noconstant("")
 DECLARE dm_cm_calling_script = vc WITH public, constant("DM_CM_PULL_METADATA")
 SELECT INTO "nl:"
  dp.*
  FROM dprotect dp
  WHERE dp.object="P"
   AND dp.object_name=patstring(build2(cnvtupper(dcp_script_prefix),"*"))
  ORDER BY dp.object_name, dp.group DESC
  HEAD dp.object_name
   dcp_cust_cnt = (dcp_cust_cnt+ 1)
   IF (mod(dcp_cust_cnt,10)=1)
    stat = alterlist(dcp_script_rec->qual,(dcp_cust_cnt+ 9))
   ENDIF
   dcp_script_rec->qual[dcp_cust_cnt].sname = dp.object_name, dcp_script_rec->qual[dcp_cust_cnt].
   info_date_utc = cnvtdatetime("01-jan-1900"), dcp_script_rec->qual[dcp_cust_cnt].exec_script_ind =
   1,
   dcp_script_rec->qual[dcp_cust_cnt].group_num = dp.group, dcp_script_rec->qual[dcp_cust_cnt].
   dict_date_utc = cnvtdatetimeutc(cnvtdatetime(dp.datestamp,dp.timestamp),3)
  DETAIL
   IF ((dcp_script_rec->qual[dcp_cust_cnt].group_num != dp.group))
    dcp_script_rec->qual[dcp_cust_cnt].group_num = dp.group, dcp_script_rec->qual[dcp_cust_cnt].
    dict_date_utc = cnvtdatetimeutc(cnvtdatetime(dp.datestamp,dp.timestamp),3)
   ENDIF
  WITH nocounter
 ;end select
 IF (error(dcp_err_msg,1) > 0)
  SET dcp_reply->status = "F"
  SET dcp_reply->message = dcp_err_msg
  GO TO exit_script
 ENDIF
 SET stat = alterlist(dcp_script_rec->qual,dcp_cust_cnt)
 SELECT INTO "nl:"
  di.*
  FROM dm_info di
  WHERE di.info_domain="CONTENT MANAGER IMPORT SCRIPT DATE"
   AND di.info_name=patstring(build2(cnvtupper(dcp_script_prefix),"*"))
  DETAIL
   dcp_recpos = locateval(dcp_ndx,1,size(dcp_script_rec->qual,5),di.info_name,cnvtupper(
     dcp_script_rec->qual[dcp_ndx].sname))
   IF (dcp_recpos > 0)
    dcp_script_rec->qual[dcp_recpos].info_date_utc = cnvtdatetimeutc(di.info_date,0)
    IF ((dcp_script_rec->qual[dcp_recpos].info_date_utc=dcp_script_rec->qual[dcp_recpos].
    dict_date_utc))
     dcp_script_rec->qual[dcp_recpos].exec_script_ind = 0, dcp_noexec_script_cnt = (
     dcp_noexec_script_cnt+ 1)
    ENDIF
   ELSE
    dcp_cust_cnt = (dcp_cust_cnt+ 1), stat = alterlist(dcp_script_rec->qual,dcp_cust_cnt),
    dcp_script_rec->qual[dcp_cust_cnt].sname = di.info_name,
    dcp_script_rec->qual[dcp_cust_cnt].remove_ind = 1, dcp_remove_ind = 1
   ENDIF
  WITH nocounter, forupdatewait(di)
 ;end select
 IF (error(dcp_err_msg,1) > 0)
  SET dcp_reply->status = "F"
  SET dcp_reply->message = dcp_err_msg
  GO TO exit_script
 ENDIF
 IF (dcp_remove_ind=1)
  FOR (dcp_loopcnt = 1 TO dcp_cust_cnt)
    IF ((dcp_script_rec->qual[dcp_loopcnt].remove_ind > 0))
     DELETE  FROM dm_info di
      WHERE di.info_domain="CONTENT MANAGER IMPORT SCRIPT DATE"
       AND di.info_name=cnvtupper(dcp_script_rec->qual[dcp_loopcnt].sname)
      WITH nocounter
     ;end delete
     UPDATE  FROM code_value cv
      SET cv.active_ind = 0, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_task = reqinfo->updt_task,
       cv.updt_applctx = reqinfo->updt_applctx, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv
       .updt_id = reqinfo->updt_id
      WHERE cv.code_set=4148001
       AND cnvtupper(cv.description)=cnvtupper(dcp_script_rec->qual[dcp_loopcnt].sname)
      WITH nocounter
     ;end update
     IF (error(dcp_err_msg,1) > 0)
      SET dcp_reply->status = "F"
      SET dcp_reply->message = dcp_err_msg
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 IF (dcp_noexec_script_cnt != dcp_cust_cnt)
  FOR (dcp_loopcnt = 1 TO dcp_cust_cnt)
    IF ((dcp_script_rec->qual[dcp_loopcnt].exec_script_ind=1))
     IF ((dcp_script_rec->qual[dcp_loopcnt].group_num > 0))
      SET dcp_grp_scrpt_name = build(dcp_script_rec->qual[dcp_loopcnt].sname,":GROUP",cnvtstring(
        dcp_script_rec->qual[dcp_loopcnt].group_num,3,0))
     ELSE
      SET dcp_grp_scrpt_name = dcp_script_rec->qual[dcp_loopcnt].sname
     ENDIF
     CALL echo("-----")
     CALL echo(concat("execute ",dcp_grp_scrpt_name," 'MINE' go"))
     CALL echo("-----")
     CALL parser(concat("execute ",dcp_grp_scrpt_name," 'MINE' go"),1)
     IF (error(dcp_err_msg,1) > 0)
      SET dcp_reply->status = "F"
      SET dcp_reply->message = dcp_err_msg
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SET dcp_reply->status = "S"
 SET dcp_reply->message = "Success: custom content script metadata updated"
#exit_script
 IF ((dcp_reply->status != "S"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
END GO
