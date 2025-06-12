CREATE PROGRAM dm_rx_fill_print_hx_rows:dba
 DECLARE output_plan(i_statement_id=vc,i_file=vc,i_debug_str=vc) = null
 DECLARE sbr_fetch_starting_id(null) = f8
 DECLARE sbr_update_starting_id(sbr_newid=f8) = null
 DECLARE sbr_delete_starting_id(null) = null
 DECLARE sbr_getrowidnotexists(sbr_whereclause=vc,sbr_tablealias=vc) = vc
 SUBROUTINE output_plan(i_statement_id,i_file,i_debug_str)
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
     WHERE outerjoin(p.object_name)=dm.index_name)
    ORDER BY p.statement_id, p.id, dm.index_name,
     dm.column_position
    HEAD REPORT
     indent = 0, line = fillstring(100,"=")
    HEAD p.statement_id
     "PLAN STATEMENT FOR ", p.statement_id, row + 1,
     line, row + 1, indent = 0
    HEAD p.id
     indent = (indent+ 1), col 0, p.id"#####",
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
 SUBROUTINE sbr_update_starting_id(sbr_newid)
   DECLARE sbr_infoname = vc WITH protect, noconstant("")
   SET sbr_infoname = concat(trim(cnvtstring(jobs->data[job_ndx].template_nbr),3)," - ",trim(
     cnvtstring(v_log_id),3))
   UPDATE  FROM dm_info di
    SET di.info_long_id = sbr_newid, di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     di.updt_cnt = (di.updt_cnt+ 1), di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
    WHERE di.info_domain="DM PURGE RESUME"
     AND di.info_name=sbr_infoname
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM PURGE RESUME", di.info_name = sbr_infoname, di.info_long_id = sbr_newid,
      di.info_date = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx, di
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
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
 SUBROUTINE sbr_getrowidnotexists(sbr_whereclause,sbr_tablealias)
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
 DECLARE batchsize = f8 WITH protect, noconstant(50000.0)
 DECLARE maxid = f8 WITH protect, noconstant(0.0)
 DECLARE curminid = f8 WITH protect, noconstant(1.0)
 DECLARE curmaxid = f8 WITH protect, noconstant(0.0)
 DECLARE rowsleft = i4 WITH protect, noconstant(request->max_rows)
 DECLARE v_rec_count = i4 WITH protect, noconstant(0)
 DECLARE v_err_msg2 = c132 WITH noconstant(fillstring(132," "))
 DECLARE v_err_code2 = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET reply->table_name = "FILL_PRINT_HX"
 SET reply->rows_between_commit = minval(10000,request->max_rows)
 DECLARE i = i2 WITH noconstant(0)
 DECLARE v_fill_days = i4 WITH noconstant(- (1))
 DECLARE v_aso_days = i4 WITH noconstant(- (1))
 DECLARE v_amb_days = i4 WITH noconstant(- (1))
 DECLARE v_mar_days = i4 WITH noconstant(- (1))
 DECLARE v_ord_days = i4 WITH noconstant(- (1))
 DECLARE v_pmp_days = i4 WITH noconstant(- (1))
 DECLARE v_udr_days = i4 WITH noconstant(- (1))
 DECLARE v_fill = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(4040,"FILL",1,v_fill)
 IF (v_fill=0.0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"FILL",
   "Unable to find code_value for CDF meaning 'FILL' in codeset 4040")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO the_end
 ENDIF
 DECLARE v_aso = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(4040,"ASO",1,v_aso)
 IF (v_aso=0.0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"ASO",
   "Unable to find code_value for CDF meaning 'ASO' in codeset 4040")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO the_end
 ENDIF
 DECLARE v_clm = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(4040,"CLM",1,v_clm)
 IF (v_clm=0.0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"CLM",
   "Unable to find code_value for CDF meaning 'CLM' in codeset 4040")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO the_end
 ENDIF
 DECLARE v_csb = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(4040,"CSB",1,v_csb)
 IF (v_csb=0.0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"CSB",
   "Unable to find code_value for CDF meaning 'CSB' in codeset 4040")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO the_end
 ENDIF
 DECLARE v_dpl = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(4040,"DPL",1,v_dpl)
 IF (v_dpl=0.0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"DPL",
   "Unable to find code_value for CDF meaning 'DPL' in codeset 4040")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO the_end
 ENDIF
 DECLARE v_dsr = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(4040,"DSR",1,v_dsr)
 IF (v_dsr=0.0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"DSR",
   "Unable to find code_value for CDF meaning 'DSR' in codeset 4040")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO the_end
 ENDIF
 DECLARE v_frr = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(4040,"FRR",1,v_frr)
 IF (v_frr=0.0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"FRR",
   "Unable to find code_value for CDF meaning 'FRR' in codeset 4040")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO the_end
 ENDIF
 DECLARE v_fin = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(4040,"FIN",1,v_fin)
 IF (v_fin=0.0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"FIN",
   "Unable to find code_value for CDF meaning 'FIN' in codeset 4040")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO the_end
 ENDIF
 DECLARE v_prr = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(4040,"PRR",1,v_prr)
 IF (v_prr=0.0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"PRR",
   "Unable to find code_value for CDF meaning 'PRR' in codeset 4040")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO the_end
 ENDIF
 DECLARE v_ptr = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(4040,"PTR",1,v_ptr)
 IF (v_ptr=0.0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"PTR",
   "Unable to find code_value for CDF meaning 'PTR' in codeset 4040")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO the_end
 ENDIF
 DECLARE v_mar = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(4040,"MAR",1,v_mar)
 IF (v_mar=0.0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"MAR",
   "Unable to find code_value for CDF meaning 'MAR' in codeset 4040")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO the_end
 ENDIF
 DECLARE v_ord = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(4040,"ORD",1,v_ord)
 IF (v_ord=0.0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"ORD",
   "Unable to find code_value for CDF meaning 'ORD' in codeset 4040")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO the_end
 ENDIF
 DECLARE v_pcl = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(4040,"PCL",1,v_pcl)
 IF (v_pcl=0.0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"PCL",
   "Unable to find code_value for CDF meaning 'PCL' in codeset 4040")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO the_end
 ENDIF
 DECLARE v_pmp = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(4040,"PMP",1,v_pmp)
 IF (v_pmp=0.0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"PMP",
   "Unable to find code_value for CDF meaning 'PMP' in codeset 4040")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO the_end
 ENDIF
 DECLARE v_udr = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(4040,"UDR",1,v_udr)
 IF (v_udr=0.0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"UDR",
   "Unable to find code_value for CDF meaning 'UDR' in codeset 4040")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO the_end
 ENDIF
 DECLARE dunknown = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(4040,"UNKNOWN",1,dunknown)
 IF (dunknown=0.0)
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"UNKNOWN",
   "Unable to find code_value for CDF meaning 'UNKNOWN' in codeset 4040")
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO the_end
 ENDIF
 FOR (i = 1 TO size(request->tokens,5))
   CASE (request->tokens[i].token_str)
    OF "FILL_DAYS":
     SET v_fill_days = ceil(cnvtreal(request->tokens[i].value))
    OF "ASO_DAYS":
     SET v_aso_days = ceil(cnvtreal(request->tokens[i].value))
    OF "AMB_DAYS":
     SET v_amb_days = ceil(cnvtreal(request->tokens[i].value))
    OF "MAR_DAYS":
     SET v_mar_days = ceil(cnvtreal(request->tokens[i].value))
    OF "ORD_DAYS":
     SET v_ord_days = ceil(cnvtreal(request->tokens[i].value))
    OF "PMP_DAYS":
     SET v_pmp_days = ceil(cnvtreal(request->tokens[i].value))
    OF "UDR_DAYS":
     SET v_udr_days = ceil(cnvtreal(request->tokens[i].value))
   ENDCASE
 ENDFOR
 IF (v_fill_days < 3)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"FILL_DAYS",
   "You must keep at least 3 days' worth of data.  You entered %1 days or did not enter any value.",
   "i",v_fill_days)
  GO TO the_end
 ELSEIF (v_aso_days < 1)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"ASO_DAYS",
   "You must keep at least 1 day's worth of data.  You entered %1 days or did not enter any value.",
   "i",v_aso_days)
  GO TO the_end
 ELSEIF (v_amb_days < 1)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"AMB_DAYS",
   "You must keep at least 1 day's worth of data.  You entered %1 days or did not enter any value.",
   "i",v_amb_days)
  GO TO the_end
 ELSEIF (v_mar_days < 3)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"MAR_DAYS",
   "You must keep at least 3 days' worth of data.  You entered %1 days or did not enter any value.",
   "i",v_mar_days)
  GO TO the_end
 ELSEIF (v_ord_days < 1)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"ORD_DAYS",
   "You must keep at least 1 day's worth of data.  You entered %1 days or did not enter any value.",
   "i",v_ord_days)
  GO TO the_end
 ELSEIF (v_pmp_days < 1)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"PMP_DAYS",
   "You must keep at least 1 day's worth of data.  You entered %1 days or did not enter any value.",
   "i",v_pmp_days)
  GO TO the_end
 ELSEIF (v_udr_days < 1)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"UDR_DAYS",
   "You must keep at least 1 day's worth of data.  You entered %1 days or did not enter any value.",
   "i",v_udr_days)
  GO TO the_end
 ELSE
  IF (batch_ndx=1)
   SELECT INTO "nl:"
    seqval = min(fp.run_id)
    FROM fill_print_hx fp
    WHERE fp.run_id > 0
    DETAIL
     curminid = maxval(cnvtreal(seqval),1.0)
    WITH nocounter
   ;end select
  ELSE
   SET curminid = sbr_fetch_starting_id(null)
  ENDIF
  SELECT INTO "nl:"
   seqval = max(fp.run_id)
   FROM fill_print_hx fp
   DETAIL
    maxid = cnvtreal(seqval)
   WITH nocounter
  ;end select
  SET curmaxid = (curminid+ (batchsize - 1))
  WHILE (curminid <= maxid
   AND rowsleft > 0)
    SELECT INTO "nl:"
     fp.rowid
     FROM fill_print_hx fp
     WHERE parser(sbr_getrowidnotexists("fp.run_id between curMinID and curMaxID","fp"))
      AND ((fp.run_type_cd=v_fill
      AND fp.cyc_from_dt_tm < cnvtdatetime((curdate - v_fill_days),curtime3)) OR (((fp.run_type_cd=
     v_aso
      AND fp.updt_dt_tm < cnvtdatetime((curdate - v_aso_days),curtime3)) OR (((fp.run_type_cd IN (
     v_clm, v_csb, v_dpl, v_dsr, v_frr,
     v_fin, v_prr, v_ptr)
      AND fp.updt_dt_tm < cnvtdatetime((curdate - v_amb_days),curtime3)) OR (((fp.run_type_cd=v_mar
      AND fp.updt_dt_tm < cnvtdatetime((curdate - v_mar_days),curtime3)) OR (((((fp.run_type_cd=v_ord
     ) OR (fp.run_type_cd=v_pcl))
      AND fp.updt_dt_tm < cnvtdatetime((curdate - v_ord_days),curtime3)) OR (((fp.run_type_cd=v_pmp
      AND fp.updt_dt_tm < cnvtdatetime((curdate - v_pmp_days),curtime3)) OR (((fp.run_type_cd=v_udr
      AND fp.updt_dt_tm < cnvtdatetime((curdate - v_udr_days),curtime3)) OR (fp.run_type_cd=dunknown
      AND fp.updt_dt_tm < cnvtdatetime((curdate - v_udr_days),curtime3))) )) )) )) )) )) ))
     DETAIL
      v_rec_count = (v_rec_count+ 1)
      IF (mod(v_rec_count,20)=1)
       stat = alterlist(reply->rows,(v_rec_count+ 19))
      ENDIF
      reply->rows[v_rec_count].row_id = fp.rowid
     WITH nocounter, maxqual(fp,value(rowsleft))
    ;end select
    SET v_err_code2 = error(v_err_msg2,0)
    IF (v_err_code2 != 0)
     SET reply->err_code = v_err_code2
     SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR",
      "Failed in row collection: %1","s",v_err_msg2)
     GO TO the_end
    ENDIF
    CALL sbr_update_starting_id(curminid)
    SET curminid = (curmaxid+ 1)
    SET curmaxid = (curminid+ (batchsize - 1))
    SET rowsleft = (request->max_rows - v_rec_count)
  ENDWHILE
  SET stat = alterlist(reply->rows,v_rec_count)
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->err_code = 0
#the_end
END GO
