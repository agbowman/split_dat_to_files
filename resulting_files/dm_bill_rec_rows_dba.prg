CREATE PROGRAM dm_bill_rec_rows:dba
 DECLARE sbr_fetch_starting_id(null) = f8
 DECLARE sbr_delete_starting_id(null) = null
 SUBROUTINE (output_plan(i_statement_id=vc,i_file=vc,i_debug_str=vc) =null)
   CALL echo(i_file)
   SELECT INTO value(i_file)
    x = substring(1,100,i_debug_str)
    FROM dual
    DETAIL
     x
    WITH maxcol = 130
   ;end select
   FOR (i = 2 TO ceil((size(i_debug_str)/ 100.0)))
     SELECT INTO value(i_file)
      x = substring((1+ ((i - 1) * 100)),100,i_debug_str)
      FROM dual
      DETAIL
       x
      WITH maxcol = 130, append
     ;end select
   ENDFOR
   SELECT INTO value(i_file)
    x = fillstring(100,"=")
    FROM dual
    DETAIL
     x
    WITH maxcol = 130, append
   ;end select
   SELECT INTO value(i_file)
    dm_ind = nullind(dm.index_name), p.statement_id, p.id,
    p.parent_id, p.position, p.operation,
    p.options, p.object_name, dm.table_name,
    dm.index_name, dm.column_position, dm.uniqueness,
    colname = substring(1,30,dm.column_name)
    FROM plan_table p,
     dm_user_ind_columns dm
    PLAN (p
     WHERE p.statement_id=patstring(i_statement_id))
     JOIN (dm
     WHERE (dm.index_name= Outerjoin(p.object_name)) )
    ORDER BY p.statement_id, p.id, dm.index_name,
     dm.column_position
    HEAD REPORT
     indent = 0, line = fillstring(100,"=")
    HEAD p.statement_id
     "PLAN STATEMENT FOR ", p.statement_id, row + 1,
     line, row + 1, indent = 0
    HEAD p.id
     indent += 1, col 0, p.id"#####",
     col + 1, col + indent, indent"###",
     ")", p.operation, col + 1,
     p.options, col + 1, p.object_name,
     col + 1
    DETAIL
     IF (dm_ind=0)
      IF (dm.column_position=1)
       row + 1, col + (indent+ 10), ">>>",
       col + 1, dm.uniqueness, col + 1
      ELSE
       ","
      ENDIF
      CALL print(trim(colname))
     ENDIF
    FOOT  p.id
     row + 1
    WITH nocounter, maxrow = 1, noformfeed,
     maxcol = 400, append
   ;end select
 END ;Subroutine
 SUBROUTINE sbr_fetch_starting_id(null)
   DECLARE sbr_startingid = f8 WITH protect, noconstant(1.0)
   DECLARE sbr_infoname = vc WITH protect, noconstant("")
   IF (batch_ndx=1)
    RETURN(1.0)
   ENDIF
   SET sbr_infoname = concat(trim(cnvtstring(jobs->data[job_ndx].template_nbr),3)," - ",trim(
     cnvtstring(v_log_id),3))
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM PURGE RESUME"
     AND di.info_name=sbr_infoname
    DETAIL
     sbr_startingid = di.info_long_id
    WITH nocounter
   ;end select
   RETURN(sbr_startingid)
 END ;Subroutine
 SUBROUTINE (sbr_update_starting_id(sbr_newid=f8) =null)
   DECLARE sbr_infoname = vc WITH protect, noconstant("")
   SET sbr_infoname = concat(trim(cnvtstring(jobs->data[job_ndx].template_nbr),3)," - ",trim(
     cnvtstring(v_log_id),3))
   UPDATE  FROM dm_info di
    SET di.info_long_id = sbr_newid, di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm =
     cnvtdatetime(sysdate),
     di.updt_cnt = (di.updt_cnt+ 1), di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
    WHERE di.info_domain="DM PURGE RESUME"
     AND di.info_name=sbr_infoname
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM PURGE RESUME", di.info_name = sbr_infoname, di.info_long_id = sbr_newid,
      di.info_date = cnvtdatetime(sysdate), di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm =
      cnvtdatetime(sysdate),
      di.updt_cnt = 0, di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ENDIF
   COMMIT
 END ;Subroutine
 SUBROUTINE sbr_delete_starting_id(null)
   DECLARE sbr_infoname = vc WITH protect, noconstant("")
   SET sbr_infoname = concat(trim(cnvtstring(jobs->data[job_ndx].template_nbr),3)," - ",trim(
     cnvtstring(v_log_id),3))
   DELETE  FROM dm_info di
    WHERE di.info_domain="DM PURGE RESUME"
     AND di.info_name=sbr_infoname
    WITH nocounter
   ;end delete
   COMMIT
 END ;Subroutine
 SUBROUTINE (sbr_getrowidnotexists(sbr_whereclause=vc,sbr_tablealias=vc) =vc)
   IF ((jobs->data[job_ndx].purge_flag != c_audit))
    RETURN(sbr_whereclause)
   ENDIF
   DECLARE sbr_newwhereclause = vc WITH protect, noconstant("")
   SET sbr_newwhereclause = concat(sbr_whereclause,
    " and NOT EXISTS (select rowidtbl.purge_table_rowid ","from dm_purge_rowid_list_gttp rowidtbl ",
    "where rowidtbl.purge_table_rowid = ",sbr_tablealias,
    ".rowid)")
   RETURN(sbr_newwhereclause)
 END ;Subroutine
 IF (validate(getcodevalue,char(128))=char(128))
  EXECUTE NULL ;noop
 ENDIF
 IF (validate(s_cdf_meaning,char(128))=char(128))
  DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 ENDIF
 IF ((validate(s_code_value,- (0.00001))=- (0.00001)))
  DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 ENDIF
 DECLARE pa_table_name = vc WITH protect, noconstant("")
 SUBROUTINE (getcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0.0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      SET pft_failed = uar_error
      EXECUTE pft_log "getcodevalue", pa_table_name, 0
      GO TO exit_script
     OF 1:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
     OF 2:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      EXECUTE pft_log "getcodevalue", pa_table_name, 3
     OF 3:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      CALL err_add_message(pa_table_name)
      SET pft_failed = uar_error
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 RECORD active_corsp_activity_id_list(
   1 activitylist[*]
     2 corspactivityid = f8
 ) WITH protect
 RECORD corsp_activity_id_list(
   1 activitylist[*]
     2 corspactivityid = f8
 ) WITH protect
 SET reply->status_data.status = "F"
 SET reply->err_code = - (1)
 DECLARE v_days_to_keep = i4 WITH protect, noconstant(0)
 DECLARE tok_ndx = i4 WITH protect, noconstant(0)
 DECLARE v_errmsg2 = vc WITH protect, noconstant("")
 DECLARE v_err_code2 = i4 WITH protect, noconstant(0)
 DECLARE batchsize = f8 WITH protect, noconstant(50000.0)
 DECLARE maxid = f8 WITH protect, noconstant(0.0)
 DECLARE curminid = f8 WITH protect, noconstant(1.0)
 DECLARE curmaxid = f8 WITH protect, noconstant(0.0)
 DECLARE rowsleft = i4 WITH protect, noconstant(request->max_rows)
 DECLARE rowcount = i4 WITH protect, noconstant(0)
 DECLARE purgedttm = dq8 WITH protect, noconstant(0.0)
 DECLARE corspidindx = i4 WITH protect, noconstant(0)
 DECLARE corspidcount = i4 WITH protect, noconstant(0)
 DECLARE issamecorspid = i2 WITH protect, noconstant(0)
 DECLARE samecorspidcount = i4 WITH protect, noconstant(0)
 DECLARE alterreplycount = i4 WITH protect, noconstant(0)
 IF ( NOT (validate(cs21749_client_inv_cd)))
  DECLARE cs21749_client_inv_cd = f8 WITH protect, constant(getcodevalue(21749,"CLIENT_INV",0))
 ENDIF
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET reply->table_name = "BILL_REC"
 SET reply->rows_between_commit = 100
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF ((request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = ceil(cnvtreal(request->tokens[tok_ndx].value))
    SET purgedttm = cnvtdatetime((curdate - v_days_to_keep),curtime3)
   ENDIF
 ENDFOR
 IF (v_days_to_keep < 60)
  SET reply->err_code = 1
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"DAYSTOKEEP",
   "You must keep at least 60 days' worth of data.  You entered %1 days or did not enter any value.",
   "i",v_days_to_keep)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 IF (batch_ndx=1)
  SELECT INTO "nl:"
   seqval = min(br.corsp_activity_id)
   FROM bill_rec br
   WHERE br.corsp_activity_id > 0
   DETAIL
    curminid = cnvtreal(seqval)
   WITH nocounter
  ;end select
 ELSE
  SET curminid = sbr_fetch_starting_id(null)
 ENDIF
 SELECT INTO "nl:"
  seqval = max(br.corsp_activity_id)
  FROM bill_rec br
  DETAIL
   maxid = cnvtreal(seqval)
  WITH nocounter
 ;end select
 SET curmaxid = (curminid+ (batchsize - 1))
 WHILE (curminid <= maxid
  AND rowsleft > 0)
   SET stat = initrec(active_corsp_activity_id_list)
   SET corspidcount = 0
   SELECT INTO "nl:"
    FROM bill_rec br
    WHERE parser(sbr_getrowidnotexists("br.corsp_activity_id between curMinID and curMaxID","br"))
     AND br.bill_type_cd=cs21749_client_inv_cd
     AND br.gen_dt_tm < cnvtdatetime(purgedttm)
     AND (br.balance_fwd > - (0.01))
     AND br.balance_fwd < 0.01
     AND (br.balance_due > - (0.01))
     AND br.balance_due < 0.01
     AND br.active_ind=1
    DETAIL
     corspidcount += 1
     IF (mod(corspidcount,50)=1)
      stat = alterlist(active_corsp_activity_id_list->activitylist,(corspidcount+ 49))
     ENDIF
     active_corsp_activity_id_list->activitylist[corspidcount].corspactivityid = br.corsp_activity_id
    WITH nocounter, maxqual(br,value(rowsleft))
   ;end select
   SET stat = alterlist(active_corsp_activity_id_list->activitylist,corspidcount)
   SELECT INTO "nl:"
    FROM bill_rec brec
    WHERE expand(corspidindx,1,corspidcount,brec.corsp_activity_id,active_corsp_activity_id_list->
     activitylist[corspidindx].corspactivityid)
    ORDER BY brec.corsp_activity_id, brec.bill_vrsn_nbr
    DETAIL
     rowcount += 1
     IF (mod(rowcount,50)=1)
      stat = alterlist(corsp_activity_id_list->activitylist,(rowcount+ 49)), stat = alterlist(reply->
       rows,(rowcount+ 49))
     ENDIF
     corsp_activity_id_list->activitylist[rowcount].corspactivityid = brec.corsp_activity_id, reply->
     rows[rowcount].row_id = brec.rowid
    WITH nocounter, expand = 1
   ;end select
   IF ((rowcount > request->max_rows))
    IF ((corsp_activity_id_list->activitylist[request->max_rows].corspactivityid !=
    corsp_activity_id_list->activitylist[(request->max_rows+ 1)].corspactivityid))
     SET alterreplycount = request->max_rows
    ELSE
     SET issamecorspid = 1
     SET samecorspidcount = 1
     WHILE (issamecorspid
      AND ((request->max_rows - samecorspidcount) > 0))
       IF ((corsp_activity_id_list->activitylist[request->max_rows].corspactivityid !=
       corsp_activity_id_list->activitylist[(request->max_rows - samecorspidcount)].corspactivityid))
        SET alterreplycount = (request->max_rows - samecorspidcount)
        SET issamecorspid = 0
        SET curminid = corsp_activity_id_list->activitylist[(request->max_rows - samecorspidcount)].
        corspactivityid
       ELSE
        SET samecorspidcount += 1
       ENDIF
     ENDWHILE
    ENDIF
   ELSE
    SET alterreplycount = rowcount
   ENDIF
   SET v_err_code2 = error(v_errmsg2,1)
   IF (v_err_code2 > 0)
    SET reply->err_code = v_err_code2
    SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR",
     "Failed in row collection: %1","s",nullterm(v_errmsg2))
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   CALL sbr_update_starting_id(curminid)
   SET curminid = (curmaxid+ 1)
   SET curmaxid = (curminid+ (batchsize - 1))
   SET rowsleft = (request->max_rows - rowcount)
 ENDWHILE
 SET stat = alterlist(reply->rows,alterreplycount)
 SET reply->status_data.status = "S"
 SET reply->err_code = 0
#exit_script
END GO
