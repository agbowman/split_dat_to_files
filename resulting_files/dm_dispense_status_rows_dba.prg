CREATE PROGRAM dm_dispense_status_rows:dba
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
 RECORD serv_res(
   1 subsection[*]
     2 subsection_cd = f8
 )
 SET reply->status_data.status = "F"
 SET reply->table_name = "DISPENSE_STATUS"
 SET reply->rows_between_commit = 100
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE ldaystokeep = i4 WITH protect, noconstant(- (1))
 DECLARE dserviceresourcegroupcode = f8 WITH protect, noconstant(0.0)
 DECLARE ltokenindex = i4 WITH protect, noconstant(0)
 DECLARE lrowsleft = i4 WITH protect, noconstant(request->max_rows)
 DECLARE dbatchsize = f8 WITH protect, noconstant(50000.0)
 DECLARE dmaxid = f8 WITH protect, noconstant(0.0)
 DECLARE dcurrentminid = f8 WITH protect, noconstant(1.0)
 DECLARE dcurrentmaxid = f8 WITH protect, noconstant(0.0)
 DECLARE lerrcode = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = vc WITH protect, noconstant("")
 FOR (ltokenindex = 1 TO size(request->tokens,5))
  IF ((request->tokens[ltokenindex].token_str="DAYS_TO_KEEP"))
   SET ldaystokeep = cnvtint(request->tokens[ltokenindex].value)
  ENDIF
  IF ((request->tokens[ltokenindex].token_str="SERVICE_RES_CD"))
   SET dserviceresourcegroupcode = cnvtreal(request->tokens[ltokenindex].value)
  ENDIF
 ENDFOR
 IF (dserviceresourcegroupcode != 0)
  DECLARE lreccnt = i4 WITH protect, noconstant(0)
  DECLARE code_set_221 = i4 WITH protect, constant(221)
  SELECT INTO "nl:"
   FROM code_value_group cvg,
    code_value cv
   PLAN (cvg
    WHERE cvg.parent_code_value=dserviceresourcegroupcode)
    JOIN (cv
    WHERE cv.code_value=cvg.child_code_value
     AND cv.code_set=code_set_221
     AND cv.cdf_meaning="SUBSECTION")
   HEAD REPORT
    lreccnt = 0
   DETAIL
    lreccnt += 1
    IF (mod(lreccnt,10)=1)
     lstat = alterlist(serv_res->subsection,(lreccnt+ 9))
    ENDIF
    serv_res->subsection[lreccnt].subsection_cd = cv.code_value
   FOOT REPORT
    lstat = alterlist(serv_res->subsection,lreccnt)
   WITH nocounter
  ;end select
  IF (size(serv_res->subsection,5)=0)
   SET reply->err_code = - (1)
   SET reply->status_data.status = "F"
   SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"INVALID_SERVICE_RES_CD",
    "The Code Value provided: %1 is either invalid or no subsections were found.","d",
    dserviceresourcegroupcode)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (batch_ndx=1)
  SELECT INTO "nl:"
   minimumval = min(ds.dispense_status_id)
   FROM dispense_status ds
   WHERE ds.dispense_status_id > 0
   DETAIL
    dcurrentminid = maxval(cnvtreal(minimumval),1.0)
   WITH nocounter
  ;end select
 ELSE
  SET dcurrentminid = sbr_fetch_starting_id(null)
 ENDIF
 SELECT INTO "nl:"
  maximumval = max(ds.dispense_status_id)
  FROM dispense_status ds
  DETAIL
   dmaxid = maxval(cnvtreal(maximumval),1.0)
  WITH nocounter
 ;end select
 SET dcurrentmaxid = (dcurrentminid+ (dbatchsize - 1))
 DECLARE lqualcnt = i4 WITH protect, noconstant(0)
 DECLARE dordered = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE lidx = i4 WITH protect, noconstant(0)
 WHILE (dcurrentminid <= dmaxid
  AND lrowsleft > 0)
   SELECT
    IF (dserviceresourcegroupcode=0)
     ds.dispense_status_id
     PLAN (ds
      WHERE parser(sbr_getrowidnotexists("ds.dispense_status_id > 0","ds"))
       AND ds.dispense_status_id BETWEEN dcurrentminid AND dcurrentmaxid
       AND ds.updt_dt_tm <= cnvtdatetime((curdate - ldaystokeep),curtime3))
      JOIN (dh
      WHERE dh.dispense_hx_id=ds.dispense_hx_id)
      JOIN (o
      WHERE o.order_id=dh.order_id)
      JOIN (od
      WHERE od.order_id=dh.order_id
       AND ((o.order_status_cd != dordered) OR (o.order_status_cd=dordered
       AND od.expire_dt_tm < cnvtdatetime(sysdate))) )
    ELSE
     ds.dispense_status_id
     PLAN (ds
      WHERE parser(sbr_getrowidnotexists("ds.dispense_status_id > 0","ds"))
       AND ds.dispense_status_id BETWEEN dcurrentminid AND dcurrentmaxid
       AND ds.updt_dt_tm <= cnvtdatetime((curdate - ldaystokeep),curtime3)
       AND expand(lidx,1,value(size(serv_res->subsection,5)),ds.subsection_cd,serv_res->subsection[
       lidx].subsection_cd))
      JOIN (dh
      WHERE dh.dispense_hx_id=ds.dispense_hx_id)
      JOIN (o
      WHERE o.order_id=dh.order_id)
      JOIN (od
      WHERE od.order_id=dh.order_id
       AND ((o.order_status_cd != dordered) OR (o.order_status_cd=dordered
       AND od.expire_dt_tm < cnvtdatetime(sysdate))) )
    ENDIF
    INTO "nl:"
    FROM dispense_status ds,
     dispense_hx dh,
     orders o,
     order_dispense od
    DETAIL
     lqualcnt += 1
     IF (mod(lqualcnt,100)=1)
      lstat = alterlist(reply->rows,(lqualcnt+ 99))
     ENDIF
     reply->rows[lqualcnt].row_id = ds.rowid
    WITH nocounter, expand = 1, maxqual(ds,value(lrowsleft))
   ;end select
   SET lerrcode = error(serrmsg,1)
   IF (lerrcode != 0)
    SET reply->err_code = lerrcode
    SET reply->status_data.status = "F"
    SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"ROWCOLLECTIONERROR",
     "Failed in row collection: %1","s",nullterm(serrmsg))
    GO TO exit_script
   ENDIF
   CALL sbr_update_starting_id(dcurrentminid)
   SET dcurrentminid = (dcurrentmaxid+ 1)
   SET dcurrentmaxid = (dcurrentminid+ (dbatchsize - 1))
   SET lrowsleft = (request->max_rows - lqualcnt)
 ENDWHILE
 SET stat = alterlist(reply->rows,lqualcnt)
 SET reply->status_data.status = "S"
 SET reply->err_code = 0
#exit_script
 FREE RECORD serv_res
END GO
