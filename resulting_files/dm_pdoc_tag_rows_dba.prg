CREATE PROGRAM dm_pdoc_tag_rows:dba
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
 DECLARE crsl_msg_default = i4 WITH protect, noconstant(0)
 DECLARE scrsllogtext = vc WITH protect, noconstant("")
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle()
 SUBROUTINE log_error_message(logmsg)
   DECLARE log_program_name = vc WITH protect, constant("CURPROG")
   DECLARE crsl_msg_level = i4 WITH protect, noconstant(0)
   SET scrsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   CALL uar_msgwrite(crsl_msg_default,0,nullterm("Script_Error"),crsl_msg_level,nullterm(scrsllogtext
     ))
 END ;Subroutine
 FREE RECORD imagestopurge
 RECORD imagestopurge(
   1 imagetopurge[*]
     2 referenceuid = vc
     2 pdoctagentityid = f8
     2 blobhandle = vc
 )
 SET reply->status_data.status = "F"
 DECLARE dbatchsize = f8 WITH noconstant(50000.0)
 DECLARE dmaxid = f8 WITH noconstant(0.0)
 DECLARE dcurminid = f8 WITH noconstant(1.0)
 DECLARE dcurmaxid = f8 WITH noconstant(0.0)
 DECLARE irowsleft = i4 WITH noconstant(request->max_rows)
 DECLARE idaystokeep = i4 WITH noconstant(0)
 DECLARE serrmsg2 = vc WITH noconstant("")
 DECLARE ierrcode2 = i4 WITH noconstant(0)
 DECLARE itokindx = i4 WITH noconstant(0)
 DECLARE irowcnt = i4 WITH noconstant(0)
 DECLARE iimagestopurgecnt = i4 WITH noconstant(0)
 DECLARE revokeownershiponmmf(dummy) = vc WITH protect
 DECLARE logerrormessage(logmsg=vc) = null
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET reply->table_name = "PDOC_TAG"
 SET reply->rows_between_commit = minval(100,request->max_rows)
 DECLARE uar_revokemediaownership(p1=vc(ref),p2=vc(ref)) = i4 WITH image_axp = "dmsmanagement",
 image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
 uar = "DMSM_RevokeMediaOwnership", persist
 FOR (itokindx = 1 TO size(request->tokens,5))
   IF ((request->tokens[itokindx].token_str="DAYSTOKEEP"))
    SET idaystokeep = ceil(cnvtreal(request->tokens[itokindx].value))
   ENDIF
 ENDFOR
 IF (idaystokeep < 30)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s1",
   "You must keep at least 30 days worth of data.You entered %1 days or did not enter any value.",
   "i",idaystokeep)
 ELSE
  IF (batch_ndx=1)
   SELECT INTO "nl:"
    seqval = min(pt.pdoc_tag_id)
    FROM pdoc_tag pt
    WHERE pt.pdoc_tag_id > 0
    DETAIL
     dcurminid = maxval(cnvtreal(seqval),1.0)
    WITH nocounter
   ;end select
  ELSE
   SET dcurminid = sbr_fetch_starting_id(null)
  ENDIF
  SELECT INTO "nl:"
   seqval = max(pt.pdoc_tag_id)
   FROM pdoc_tag pt
   DETAIL
    dmaxid = cnvtreal(seqval)
   WITH nocounter
  ;end select
  SET dcurmaxid = (dcurminid+ (dbatchsize - 1))
  WHILE (dcurminid <= dmaxid
   AND irowsleft > 0)
    SET iimagestopurgecnt = 0
    SELECT INTO "nl:"
     pt.rowid
     FROM pdoc_tag pt
     WHERE parser(sbr_getrowidnotexists("pt.PDOC_TAG_ID between dCurMinID and dCurMaxID","pt"))
      AND pt.updt_dt_tm < cnvtdatetime((curdate - idaystokeep),curtime3)
      AND pt.pdoc_tag_id != 0
     DETAIL
      irowcnt = (irowcnt+ 1)
      IF (mod(irowcnt,100)=1)
       stat = alterlist(reply->rows,(irowcnt+ 99))
      ENDIF
      reply->rows[irowcnt].row_id = pt.rowid
      IF (pt.tag_entity_name="PDOC_TAG_HANDLE")
       iimagestopurgecnt = (iimagestopurgecnt+ 1)
       IF (mod(iimagestopurgecnt,100)=1)
        CALL alterlist(imagestopurge->imagetopurge,(iimagestopurgecnt+ 99))
       ENDIF
       imagestopurge->imagetopurge[iimagestopurgecnt].pdoctagentityid = pt.tag_entity_id,
       imagestopurge->imagetopurge[iimagestopurgecnt].referenceuid = pt.reference_uuid
      ENDIF
     WITH nocounter, maxqual(pt,value(irowsleft))
    ;end select
    SET ierrcode2 = 0
    SET ierrcode2 = error(serrmsg2,1)
    IF (ierrcode2 > 0)
     SET reply->err_code = ierrcode2
     SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s2","Failed in row collection: %1","s",
      nullterm(serrmsg2))
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
    IF ((request->purge_flag != c_audit)
     AND iimagestopurgecnt > 0)
     CALL alterlist(imagestopurge->imagetopurge,iimagestopurgecnt)
     CALL revokeownershiponmmf(null)
    ENDIF
    SET stat = initrec(imagestopurge)
    CALL sbr_update_starting_id(dcurminid)
    SET dcurminid = (dcurmaxid+ 1)
    SET dcurmaxid = (dcurminid+ (dbatchsize - 1))
    SET irowsleft = (request->max_rows - irowcnt)
  ENDWHILE
  SET stat = alterlist(reply->rows,irowcnt)
  SET reply->status_data.status = "S"
  SET reply->err_code = 0
 ENDIF
 SUBROUTINE revokeownershiponmmf(null)
   DECLARE mmfobject_cnt = i4 WITH protect, constant(size(imagestopurge->imagetopurge,5))
   DECLARE num = i4 WITH noconstant(0), public
   DECLARE expand_cnt = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH noconstant(0), public
   DECLARE outerindex = i4 WITH noconstant(0), public
   DECLARE mmf_storage_cd = f8 WITH protect, noconstant(0.0)
   SET mmf_storage_cd = uar_get_code_by("MEANING",25,nullterm("MMF"))
   IF ((((mmf_storage_cd=- (1.0))) OR (mmf_storage_cd=0.0)) )
    CALL log_error_message("Code Value not found")
   ENDIF
   SELECT
    pth.blob_handle, pth.pdoc_tag_handle_id
    FROM pdoc_tag_handle pth
    WHERE expand(expand_cnt,1,mmfobject_cnt,pth.pdoc_tag_handle_id,imagestopurge->imagetopurge[
     expand_cnt].pdoctagentityid)
     AND pth.storage_cd=mmf_storage_cd
    DETAIL
     pos = locateval(num,1,mmfobject_cnt,pth.pdoc_tag_handle_id,imagestopurge->imagetopurge[num].
      pdoctagentityid), imagestopurge->imagetopurge[pos].blobhandle = pth.blob_handle
    WITH nocounter, expand = 1
   ;end select
   FOR (outerindex = 1 TO mmfobject_cnt)
     IF ((imagestopurge->imagetopurge[outerindex].blobhandle != "")
      AND (imagestopurge->imagetopurge[outerindex].referenceuid != ""))
      SET tempblobhandle = nullterm(imagestopurge->imagetopurge[outerindex].blobhandle)
      IF (uar_revokemediaownership(nullterm(tempblobhandle),nullterm(imagestopurge->imagetopurge[
        outerindex].referenceuid))=0)
       CALL log_error_message(imagestopurge->imagetopurge[outerindex].blobhandle)
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
#exit_script
 FREE RECORD imagestopurge
END GO
