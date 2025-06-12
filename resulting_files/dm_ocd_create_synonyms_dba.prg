CREATE PROGRAM dm_ocd_create_synonyms:dba
 SUBROUTINE exist_synonym(es_owner,es_synonym)
  SELECT INTO "nl:"
   FROM all_synonyms a
   WHERE a.owner=cnvtupper(es_owner)
    AND a.synonym_name=cnvtupper(es_synonym)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   RETURN(1)
  ELSE
   RETURN(0)
  ENDIF
 END ;Subroutine
 SUBROUTINE verify_synonym(vs_table)
   IF (exist_synonym("PUBLIC",vs_table))
    CALL parser(concat("rdb drop public synonym ",vs_table," go"),1)
   ENDIF
   SET errcode = error(errmsg,1)
   CALL parser(concat("rdb create public synonym ",vs_table," for ",vs_table,"@",
     trim(con_str,3)," go"),1)
   SET errcode = error(errmsg,1)
   IF (errcode)
    SET errlog->count = (errlog->count+ 1)
    SET stat = alterlist(errlog->qual,errlog->count)
    SET errlog->qual[errlog->count].errmsg = errmsg
    SET errlog->qual[errlog->count].command = concat("rdb create public synonym ",vs_table)
   ELSE
    CALL parser(concat("execute ORAGEN3 '",vs_table,"@",trim(con_str,3),"' go"),1)
   ENDIF
 END ;Subroutine
 SET docd_reply->status = "F"
 SET count = 0
 SET errcode = 0
 SET errmsg = fillstring(132," ")
 SET command = fillstring(132," ")
 FREE RECORD errlog
 IF (currev >= 8)
  RECORD errlog(
    1 count = i4
    1 qual[*]
      2 errmsg = vc
      2 command = vc
    1 tempstr = vc
  )
 ELSE
  RECORD errlog(
    1 count = i4
    1 qual[*]
      2 errmsg = c132
      2 command = vc
    1 tempstr = vc
  )
 ENDIF
 SET errlog->count = 0
 SET stat = alterlist(errlog->qual,0)
 SET con_str = fillstring(20," ")
 SELECT INTO "nl:"
  FROM all_synonyms a
  WHERE a.table_name="DM_ENVIRONMENT"
  DETAIL
   con_str = cnvtlower(substring(1,(findstring(".",a.db_link) - 1),a.db_link))
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET errlog->count = (errlog->count+ 1)
  SET stat = alterlist(errlog->qual,errlog->count)
  SET errlog->qual[errlog->count].errmsg = "The ADMIN link cannot be determined !!!"
  SET errlog->qual[errlog->count].command =
  "Could not capture ADMIN link for DM_ENVIRONMENT table in ALL_SYNONYMNS table ..."
  SET docd_reply->status = "F"
  SET docd_reply->err_msg =
  "Could not capture ADMIN link for DM_ENVIRONMENT table in ALL_SYNONYMNS table ..."
  GO TO check_error_log
 ENDIF
 IF (validate(docd_reply->con_str,"-99") != "-99")
  SET docd_reply->con_str = con_str
 ENDIF
 CALL parser(concat("execute dm_cdba_synonym '",trim(con_str),"' go"),1)
 SET syn_cnt = 0
 FOR (syn_cnt = 1 TO radm->tcnt)
   CALL verify_synonym(radm->qual[syn_cnt].tname)
 ENDFOR
#check_error_log
 IF ((errlog->count > 0))
  SET docd_reply->status = "F"
  SET docd_reply->err_msg = errlog->qual[1].errmsg
  SET docs_log_file = build("DM_OCD_CREATE_SYN_",ocd_string,".LOG")
  SELECT INTO value(docs_log_file)
   FROM (dummyt d  WITH seq = value(errlog->count))
   DETAIL
    errlog->tempstr = build("ERROR #",d.seq), errlog->tempstr, row + 1,
    errlog->qual[d.seq].command, row + 1, errlog->qual[d.seq].errmsg,
    row + 1, row + 1
   WITH nocounter, maxrow = 1, maxcol = 512,
    noheading, format = variable, formfeed = none
  ;end select
  GO TO end_program
 ENDIF
 CALL parser(concat("execute oragen3 'APPLICATION' go"),1)
 CALL parser("drop table DBA_FREE_SPACE                 go",1)
 CALL parser("drop ddlrecord DBA_FREE_SPACE from database v500 with deps_deleted go",1)
 CALL parser("create ddlrecord DBA_FREE_SPACE from database v500")
 CALL parser("table DBA_FREE_SPACE")
 CALL parser("1  TABLESPACE_NAME")
 CALL parser("=c30")
 CALL parser(" ccl(TABLESPACE_NAME) ;null=N1VARCHAR2")
 CALL parser("1  FILE_ID")
 CALL parser("= f8")
 CALL parser(" ccl(FILE_ID) ;null=NNUMBER(len:22 prec:0 scale:0)")
 CALL parser("1  BLOCK_ID")
 CALL parser("= f8")
 CALL parser(" ccl(BLOCK_ID) ;null=NNUMBER(len:22 prec:0 scale:0)")
 CALL parser("1  BYTES")
 CALL parser("= f8")
 CALL parser(" ccl(BYTES) ;null=YNUMBER(len:22 prec:0 scale:0)")
 CALL parser("1  BLOCKS")
 CALL parser("= f8")
 CALL parser(" ccl(BLOCKS) ;null=NNUMBER(len:22 prec:0 scale:0)")
 CALL parser("1  rowid ccl(rowid) ;rowid")
 CALL parser("2  rowid_fld= c18")
 CALL parser("end table DBA_FREE_SPACE                 go",1)
 CALL parser("drop table DBA_DATA_FILES                 go",1)
 CALL parser("drop ddlrecord DBA_DATA_FILES from database v500 with deps_deleted go",1)
 CALL parser("create ddlrecord DBA_DATA_FILES from database v500")
 CALL parser("table DBA_DATA_FILES")
 CALL parser("1  FILE_NAME")
 CALL parser("=vc257")
 CALL parser(" ccl(FILE_NAME) ;null=Y1VARCHAR2")
 CALL parser("1  FILE_ID")
 CALL parser("= f8")
 CALL parser(" ccl(FILE_ID) ;null=YNUMBER(len:22 prec:0 scale:0)")
 CALL parser("1  TABLESPACE_NAME")
 CALL parser("=c30")
 CALL parser(" ccl(TABLESPACE_NAME) ;null=Y1VARCHAR2")
 CALL parser("1  BYTES")
 CALL parser("= f8")
 CALL parser(" ccl(BYTES) ;null=YNUMBER(len:22 prec:0 scale:0)")
 CALL parser("1  BLOCKS")
 CALL parser("= f8")
 CALL parser(" ccl(BLOCKS) ;null=YNUMBER(len:22 prec:0 scale:0)")
 CALL parser("1  STATUS")
 CALL parser("=c9")
 CALL parser(" ccl(STATUS) ;null=Y1VARCHAR2")
 CALL parser("1  rowid ccl(rowid) ;rowid")
 CALL parser("2  rowid_fld= c18")
 CALL parser("end table DBA_DATA_FILES                 go",1)
 SET docd_reply->status = "S"
 SET docd_reply->err_msg = "SUCCESS"
#end_program
 DELETE  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="DOMAIN SETUP CURRENTLY EXECUTING"
  WITH nocounter
 ;end delete
 COMMIT
END GO
