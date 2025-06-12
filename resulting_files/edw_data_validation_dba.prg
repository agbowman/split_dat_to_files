CREATE PROGRAM edw_data_validation:dba
 DECLARE quotes = vc WITH protect, constant(char(34))
 DECLARE extract_dt_tm = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime2))
 DECLARE paramfromdt = dq8 WITH protect, noconstant(cnvtdatetime( $1))
 DECLARE paramtodt = dq8 WITH protect, noconstant(cnvtdatetime( $2))
 DECLARE paramhss_id = i4 WITH protect, constant( $3)
 DECLARE ods_utc_var = i2 WITH protect, constant(evaluate(curutc,1,4,0,3))
 DECLARE sp_ind = i4
 DECLARE ivldcnfgrng = i4 WITH protect, constant(1000550)
 DECLARE iminuscnfgrng = i4 WITH protect, constant(1000500)
 DECLARE icolcnfgrngbeg = i4 WITH protect, constant(1000600)
 DECLARE icolcnfgrngend = i4 WITH protect, constant(1000799)
 DECLARE imaxdisplay = i4 WITH protect, noconstant(10000)
 DECLARE ivalidationcnt = i4 WITH protect, noconstant(0)
 DECLARE istat = i4 WITH protect, noconstant(0)
 DECLARE ividx = i4 WITH protect, noconstant(0)
 DECLARE iutctzindex = i2 WITH protect, noconstant(curtimezoneapp)
 DECLARE ctmperror = vc WITH protect, noconstant(" ")
 DECLARE cvldcnfgrngindnt = vc WITH protect, constant("1")
 DECLARE idebug = i2 WITH protect, noconstant(1)
 IF (reflect(parameter(4,0))="I4")
  SET imaxdisplay = parameter(4,0)
 ENDIF
 CALL echo(build("number to display max",imaxdisplay))
 DECLARE str_find = vc WITH noconstant, protect
 DECLARE str_replace = vc WITH noconstant, protect
 FOR (i = 1 TO 255)
   SET str_find = notrim(concat(str_find,char(i)))
 ENDFOR
 FOR (i = 1 TO 255)
   IF (((i < 32) OR (i IN (124, 127, 129, 141, 143,
   144, 157, 160))) )
    SET str_replace = notrim(concat(str_replace," "))
   ELSE
    SET str_replace = notrim(concat(str_replace,char(i)))
   ENDIF
 ENDFOR
 DECLARE get_edwconfigrules(icnfgvalrange=i4,icnfgvalrangeindent=vc,ihssid=i4) = i2
 DECLARE get_minusmetadata(icnfgvalrange=i4,ihssid=i4) = i2
 DECLARE get_cometadata(icolcnfgrngbeg=i4,icolcnfgrngend=i4,paramhss_id=i4) = i2
 DECLARE load_validstruct(cfilename=vc) = i2
 DECLARE processerrors(cdesc=vc,dprocessdttm=dq8,cqueue_reset=c1,ccustom=c1) = i2
 DECLARE comparecolumns(iindex=i4,ihssid=i4,dfromdate=dq8,dtodate=dq8,cdblink=vc) = i4
 DECLARE insertparserbuffer(cline=vc) = i2
 DECLARE execparserbuffer(ccallparser=vc,cdebug=vc) = i2
 DECLARE getdblink(ihssid=i4) = vc
 DECLARE chkdblink(cdblink=vc,dprocessdttm=dq8) = i2
 DECLARE getminbegindate(ihssid=i4) = dq8
 DECLARE createmiltemptable(dummy=i2) = i2
 DECLARE dropmiltemptable(dummy=i2) = i2
 DECLARE edwminus(iindex=i2,ihssid=i4,dfromdate=dq8,dtodate=dq8,cdblink=vc) = i4
 DECLARE millminus(iindex=i2,ihssid=i4,dfromdate=dq8,dtodate=dq8,cdblink=vc) = i4
 DECLARE insertsummaryrec(iindex=i2,ihssid=i4,dfromdttm=dq8,dtodttm=dq8,dexecdttm=dq8) = i4
 DECLARE insertcoldetails(iindex=i2,ihssid=i4,dfromdttm=dq8,dtodttm=dq8,dexecdttm=dq8) = i4
 DECLARE edwgetcodevaluefromcdfmeaning(code_set=i4(value),cdf_meaning=vc(value)) = f8 WITH protect
 DECLARE edw_date_continuity_check(dummy=i4,dummy2=vc) = null
 RECORD detail_rec(
   1 total_col_cnt = i4
   1 row_cnt = i4
   1 row_qual[*]
     2 mil_table = vc
     2 edw_table = vc
     2 mil_pk = vc
     2 edw_sk = vc
     2 col_cnt = i4
     2 col_qual[*]
       3 edw_col = vc
       3 edw_col_value = vc
       3 mil_col_value = vc
 )
 RECORD validation(
   1 valid_edw_minus = i1
   1 valid_mil_minus = i1
   1 valid_all_columns = i1
   1 source_utc_flag = i1
   1 dblink = vc
   1 process_dt_tm = dq8
   1 cnt = i4
   1 qual[*]
     2 edw_table = vc
     2 file_type = vc
     2 edw_sk = vc
     2 edw_sk_datatype = vc
     2 edw_sk_size = vc
     2 mil_table = vc
     2 mil_pk = vc
     2 mil_pk_datatype = vc
     2 mil_sk_size = vc
     2 mil_miss_cnt = i4
     2 edw_miss_cnt = i4
     2 col_diff_cnt = i4
     2 col_cnt = i4
     2 secondary_flg = vc
     2 secondary_table = vc
     2 secondary_column = vc
     2 primary_join_column = vc
     2 primary_join_condition = vc
     2 second_join_condition = vc
     2 col_qual[*]
       3 mil_col = vc
       3 mil_data_type = vc
       3 mil_col_size = vc
       3 edw_col = vc
       3 edw_data_type = vc
       3 edw_col_size = vc
 )
 RECORD parser_buffer(
   1 cnt = i4
   1 qual[*]
     2 line_text = vc
 )
 RECORD error_rec(
   1 cnt = i2
   1 qual[*]
     2 error_cd = i2
     2 err_msg = vc
     2 desc = vc
 )
 SET validation->process_dt_tm = extract_dt_tm
 SET error_cnt = processerrors("Declare Variables",extract_dt_tm,"Y","N")
 IF (error_cnt > 0)
  CALL echo("Exiting due to error")
  GO TO end_program
 ENDIF
 SET validation->dblink = concat("@",getdblink(paramhss_id))
 IF (chkdblink(validation->dblink,extract_dt_tm) > 0)
  CALL echo("DBLINK FAILED")
  GO TO end_program
 ENDIF
 DECLARE act_pharmacy_cd = f8 WITH constant(edwgetcodevaluefromcdfmeaning(106,"PHARMACY"))
 DECLARE cat_pharmacy_cd = f8 WITH constant(edwgetcodevaluefromcdfmeaning(6000,"PHARMACY"))
 DECLARE order_create_cd = f8 WITH constant(edwgetcodevaluefromcdfmeaning(16750,"ORDER CREATE"))
 IF (get_edwconfigrules(ivldcnfgrng,cvldcnfgrngindnt,paramhss_id)=0)
  SET error_cnt = processerrors("SubRoutine:GetMinBeginDate::No Configuration rules found",
   extract_dt_tm,"Y","Y")
  CALL echo("No configuration records found.  Aborting script.")
  GO TO end_program
 ENDIF
 DECLARE contr_sys_cd = vc WITH protect, noconstant(" ")
 DECLARE dm_info_table = vc WITH protect, constant(trim(build("dm_info",validation->dblink)))
 SELECT INTO "nl:"
  FROM (parser(dm_info_table) di)
  PLAN (di
   WHERE di.info_domain="PI EDW DATA CONFIGURATION|EXCLUDE CONTRIBUTOR SYSTEM LIST"
    AND di.info_name="EXCLUDE_CONTRIB_SYSTEM_LIST|FT")
  DETAIL
   contr_sys_cd = substring(1,(findstring("|",di.info_char,1) - 1),di.info_char)
  WITH nocounter
 ;end select
 SET ivalidationcnt = get_minusmetadata(iminuscnfgrng,paramhss_id)
 IF (ivalidationcnt=0)
  SET ctmperror = concat(
   "SubRoutine:Get_MinusMetaData::There were no tables selected for the data validation",
   " process to run against")
  SET error_cnt = processerrors(ctmperror,extract_dt_tm,"Y","Y")
  CALL echo("No Validation tables found to run against.  Aborting script.")
  GO TO end_program
 ENDIF
 IF ((validation->valid_all_columns > 0))
  IF (get_cometadata(icolcnfgrngbeg,icolcnfgrngend,paramhss_id)=0)
   SET ctmperror = concat(
    "SubRoutine:Get_CoMetaData::No valid column attributes were returned to compare.")
   SET error_cnt = processerrors(ctmperror,extract_dt_tm,"Y","Y")
   CALL echo("No Validation tables found to run against.  Aborting script.")
   GO TO end_program
  ENDIF
 ENDIF
 IF (cnvtdatetime(getminbegindate(paramhss_id)) > cnvtdatetime( $2))
  SET ctmperror = concat(
   "SubRoutine:GetMinBeginDate::The date range selected for the data validation process is outside ",
   "of the date ranges that were actually loaded into the data warehouse")
  SET error_cnt = processerrors(ctmperror,extract_dt_tm,"Y","Y")
  CALL echo("Invalid Date Range.  Aborting script")
  GO TO end_program
 ENDIF
 FOR (ividx = 1 TO ivalidationcnt)
   IF ((validation->valid_edw_minus=1))
    CALL echo(build(validation->qual[ividx].file_type,": EDW MINUS START :",format(sysdate,
       "MM/DD/YYYY HH:MM:SS;;D")))
    SET validation->qual[ividx].edw_miss_cnt = edwminus(ividx,paramhss_id,paramfromdt,paramtodt,
     validation->dblink)
    SET error_cnt = processerrors("SubRoutine:EDWMinus",extract_dt_tm,"Y","N")
    CALL echo(build(validation->qual[ividx].file_type,": EDW MINUS END :",format(sysdate,
       "MM/DD/YYYY HH:MM:SS;;D")))
   ENDIF
   IF ((validation->valid_mil_minus=1))
    CALL echo(build(validation->qual[ividx].file_type,": MIL MINUS START :",format(sysdate,
       "MM/DD/YYYY HH:MM:SS;;D")))
    SET validation->qual[ividx].mil_miss_cnt = millminus(ividx,paramhss_id,paramfromdt,paramtodt,
     validation->dblink)
    SET error_cnt = processerrors("SubRoutine:MillMinus",extract_dt_tm,"Y","N")
    CALL echo(build(validation->qual[ividx].file_type,": MIL MINUS END :",format(sysdate,
       "MM/DD/YYYY HH:MM:SS;;D")))
   ENDIF
   IF ((validation->valid_all_columns=1)
    AND (validation->qual[ividx].col_cnt > 0))
    CALL echo(build(validation->qual[ividx].file_type,": COL COMPARE START :",format(sysdate,
       "MM/DD/YYYY HH:MM:SS;;D")))
    SET validation->qual[ividx].col_diff_cnt = comparecolumns(ividx,paramhss_id,paramfromdt,paramtodt,
     validation->dblink,
     imaxdisplay)
    IF ((validation->qual[ividx].col_diff_cnt > 0))
     SET istat = insertcoldetails(detail_rec->row_cnt,paramhss_id,paramfromdt,paramtodt,extract_dt_tm
      )
    ENDIF
    SET istat = initrec(detail_rec)
    SET error_cnt = processerrors("SubRoutine:CompareColumns",extract_dt_tm,"Y","N")
    CALL echo(build(validation->qual[ividx].file_type,": COL COMPARE END :",format(sysdate,
       "MM/DD/YYYY HH:MM:SS;;D")))
   ENDIF
   SET istat = insertsummaryrec(ividx,paramhss_id,paramfromdt,paramtodt,extract_dt_tm)
 ENDFOR
 SELECT INTO "nl:"
  FROM wh_oth_cnfg_val cv
  WHERE cv.cnfg_value_range=1000550
   AND cv.cnfg_value_range_ident="2"
  DETAIL
   sp_ind = cnvtint(cv.cnfg_value)
  WITH nocounter
 ;end select
 IF (sp_ind=1)
  CALL echo(build("EDW_DATE_CONTINUITY_CHECK START : ",format(sysdate,"MM/DD/YYYY HH:MM:SS;;D")))
  CALL edw_date_continuity_check(paramhss_id,format(extract_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"))
  CALL echo(build("EDW_DATE_CONTINUITY_CHECK END : ",format(sysdate,"MM/DD/YYYY HH:MM:SS;;D")))
 ENDIF
 SUBROUTINE processerrors(cdesc,dprocessdttm,cqueue_reset,ccustom)
   DECLARE pe_reset_flg = i2 WITH private, noconstant(0)
   DECLARE pe_errcode = i2 WITH private, noconstant(1)
   DECLARE pe_cnt = i2 WITH private, noconstant(0)
   DECLARE pe_errmsg = vc WITH protect, noconstant(" ")
   DECLARE pe_object = vc WITH protect, constant(value(curprog))
   DECLARE pe_user = vc WITH protect, constant(value(curuser))
   DECLARE dupdtdttm = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime2))
   DECLARE icurqual = i4 WITH private, noconstant(0)
   IF (cqueue_reset="Y")
    SET pe_reset_flg = 1
   ENDIF
   WHILE (pe_errcode != 0)
    SET pe_errcode = error(pe_errmsg,pe_reset_flg)
    IF (pe_errcode > 0)
     SET pe_cnt = (pe_cnt+ 1)
     SET error_rec->cnt = (error_rec->cnt+ 1)
     IF (mod(error_rec->cnt,10)=1)
      SET stat = alterlist(error_rec->qual,(error_rec->cnt+ 9))
     ENDIF
     SET error_rec->qual[error_rec->cnt].error_cd = pe_errcode
     SET error_rec->qual[error_rec->cnt].err_msg = trim(pe_errmsg)
     SET error_rec->qual[error_rec->cnt].desc = trim(cdesc)
    ENDIF
   ENDWHILE
   IF (ccustom="Y")
    SET pe_cnt = (pe_cnt+ 1)
    SET error_rec->cnt = (error_rec->cnt+ 1)
    IF (mod(error_rec->cnt,10)=1)
     SET stat = alterlist(error_rec->qual,(error_rec->cnt+ 9))
    ENDIF
    SET error_rec->qual[error_rec->cnt].desc = trim(cdesc)
   ENDIF
   IF (cqueue_reset="Y"
    AND (error_rec->cnt > 0))
    INSERT  FROM wh_oth_process_msg_log msglog,
      (dummyt d  WITH seq = value(error_rec->cnt))
     SET msglog.object_name = pe_object, msglog.severity_flg = 3, msglog.message_text = concat(trim(
        error_rec->qual[d.seq].desc),"::",trim(error_rec->qual[d.seq].err_msg)),
      msglog.process_dt_tm = cnvtdatetime(dprocessdttm), msglog.updt_dt_tm = cnvtdatetime(dupdtdttm),
      msglog.updt_task = pe_object,
      msglog.updt_user = pe_user
     PLAN (d)
      JOIN (msglog)
     WITH nocounter
    ;end insert
    COMMIT
    SET stat = initrec(error_rec)
   ENDIF
   RETURN(pe_cnt)
 END ;Subroutine
 SUBROUTINE getdblink(ihssid)
   DECLARE cdblink = vc WITH protect, noconstant(" ")
   DECLARE ierrorcnt = i2 WITH private, noconstant(0)
   SELECT INTO "nl:"
    FROM wh_oth_hlth_sys_src_ref wohss
    WHERE wohss.health_system_source_id=ihssid
     AND wohss.active_ind=1
    DETAIL
     cdblink = trim(wohss.source_link)
    WITH nocounter
   ;end select
   RETURN(cdblink)
 END ;Subroutine
 SUBROUTINE chkdblink(cdblink,dprocessdttm)
   DECLARE cfromclause = vc WITH protect, noconstant(concat(" dual",cdblink))
   DECLARE ierrorcnt = i2 WITH private, noconstant(0)
   DECLARE cerrortxt = vc WITH private, noconstant(" ")
   SET cerrortxt = concat("SubRoutine:ChkDbLink - DB Link ",cdblink,
    " is not availible for data validation process to proceed")
   SELECT INTO "nl:"
    ccount = count(1)
    FROM (parser(cfromclause))
    WHERE 1=1
    WITH nocounter
   ;end select
   SET ierrorcnt = processerrors(cerrortxt,dprocessdttm,"Y","N")
   RETURN(ierrorcnt)
 END ;Subroutine
 SUBROUTINE edwgetcodevaluefromcdfmeaning(code_set,cdf_meaning)
   DECLARE return_value = f8 WITH protect, noconstant(0.0)
   DECLARE cdf_mean = vc WITH protect, constant(trim(cnvtupper(cdf_meaning)))
   DECLARE cv_table = vc WITH protect, constant(trim(build("code_value",validation->dblink)))
   SELECT INTO "nl:"
    c.code_value
    FROM (parser(cv_table) c)
    PLAN (c
     WHERE c.code_set=code_set
      AND c.cdf_meaning=cdf_mean
      AND c.active_ind=1)
    ORDER BY c.code_value
    HEAD c.code_value
     return_value = c.code_value
    WITH nocounter
   ;end select
   RETURN(return_value)
 END ;Subroutine
 SUBROUTINE getminbegindate(ihssid)
   DECLARE dminextractrange = dq8 WITH protect, noconstant(0.00)
   SELECT INTO "nl:"
    begin_range = min(wops.extract_range_begin)
    FROM wh_oth_process_stats wops
    WHERE wops.file_type="ENCNTR"
     AND wops.health_system_source_id=ihssid
    DETAIL
     dminextractrange = begin_range
    WITH nocounter
   ;end select
   RETURN(dminextractrange)
 END ;Subroutine
 SUBROUTINE get_edwconfigrules(icnfgvalrange,icnfgvalrangeindent,ihssid)
   SELECT INTO "nl:"
    FROM wh_oth_cnfg_val cv
    WHERE cv.cnfg_value_range=24
     AND cv.cnfg_value_range_ident="SP_LOGGING"
    ORDER BY cv.health_system_source_id
    HEAD cv.health_system_source_id
     idebug = cnvtint(cv.cnfg_value_2)
    WITH nocounter
   ;end select
   IF (idebug=1)
    SET message = information
   ELSE
    SET message = noinformation
   ENDIF
   SELECT INTO "nl:"
    FROM wh_oth_cnfg_val cv
    WHERE cv.cnfg_value_range=icnfgvalrange
     AND cv.cnfg_value_range_ident=icnfgvalrangeindent
    ORDER BY cv.health_system_source_id
    HEAD cv.health_system_source_id
     validation->valid_mil_minus = evaluate(trim(cv.cnfg_value),"1",1,0), validation->valid_edw_minus
      = evaluate(trim(cv.cnfg_value_2),"1",1,0), validation->valid_all_columns = evaluate(trim(cv
       .cnfg_value_3),"1",1,0),
     validation->source_utc_flag = evaluate(trim(cv.cnfg_value_5),"1",1,0)
    WITH nocounter
   ;end select
   RETURN(curqual)
 END ;Subroutine
 SUBROUTINE get_minusmetadata(icnfgvalrange,ihssid)
   SELECT INTO "nl:"
    FROM wh_oth_cnfg_val cv,
     wh_oth_process_table_reltn ptr
    PLAN (cv
     WHERE cv.cnfg_value_range=icnfgvalrange
      AND cv.cnfg_value="1"
      AND cv.cnfg_value_use="1")
     JOIN (ptr
     WHERE ptr.table_name=cv.cnfg_value_range_ident)
    ORDER BY cv.cnfg_value_range_ident
    HEAD cv.cnfg_value_range_ident
     validation->cnt = (validation->cnt+ 1)
     IF (mod(validation->cnt,10)=1)
      stat = alterlist(validation->qual,(validation->cnt+ 9))
     ENDIF
     validation->qual[validation->cnt].edw_table = trim(cv.cnfg_value_range_ident), validation->qual[
     validation->cnt].edw_sk = trim(cv.cnfg_value_4), validation->qual[validation->cnt].
     edw_sk_datatype = trim(cv.list_of_value_4),
     validation->qual[validation->cnt].edw_sk_size = trim(cv.cnfg_value_desc_4), validation->qual[
     validation->cnt].mil_table = trim(cv.cnfg_value_2), validation->qual[validation->cnt].mil_pk =
     trim(cv.cnfg_value_3),
     validation->qual[validation->cnt].mil_pk_datatype = trim(cv.list_of_value_3), validation->qual[
     validation->cnt].mil_sk_size = trim(cv.cnfg_value_desc_3), validation->qual[validation->cnt].
     file_type = trim(ptr.file_type),
     validation->qual[validation->cnt].secondary_flg = trim(cv.cnfg_value_condition), validation->
     qual[validation->cnt].secondary_table = trim(cv.cnfg_value_qual), validation->qual[validation->
     cnt].secondary_column = trim(cv.cnfg_value_5),
     validation->qual[validation->cnt].primary_join_column = trim(cv.cnfg_value_datatype_5),
     validation->qual[validation->cnt].primary_join_condition = trim(cv.list_of_value_5)
     IF (trim(cv.cnfg_value_3)="CLINICAL_EVENT"
      AND trim(contr_sys_cd) != "0"
      AND trim(contr_sys_cd) != "")
      validation->qual[validation->cnt].second_join_condition = concat(
       "AND mil.CONTRIBUTOR_SYSTEM_CD NOT IN (",trim(contr_sys_cd),")")
     ELSE
      validation->qual[validation->cnt].second_join_condition = trim(cv.cnfg_value_desc_5)
     ENDIF
    WITH nocounter
   ;end select
   IF (idebug=1)
    CALL echo(build2("EDW_Table- ",validation->qual[validation->cnt].edw_table))
    CALL echo(build2("EDW_SK- ",validation->qual[validation->cnt].edw_sk))
    CALL echo(build2("EDW_SK_Datatype- ",validation->qual[validation->cnt].edw_sk_datatype))
    CALL echo(build2("MIL_Table- ",validation->qual[validation->cnt].mil_table))
    CALL echo(build2("MIL_PK- ",validation->qual[validation->cnt].mil_pk))
    CALL echo(build2("FILE_Type- ",validation->qual[validation->cnt].file_type))
    CALL echo(build2("SECONDARY_FLG- ",validation->qual[validation->cnt].secondary_flg))
    CALL echo(build2("SECONDARY_Table- ",validation->qual[validation->cnt].secondary_table))
    CALL echo(build2("SECONDARY_Column- ",validation->qual[validation->cnt].secondary_column))
    CALL echo(build2("PRIMARY_JOIN_COLUMN- ",validation->qual[validation->cnt].primary_join_column))
   ENDIF
   RETURN(validation->cnt)
 END ;Subroutine
 SUBROUTINE get_cometadata(icolcnfgrngbeg,icolcnfgrngend,paramhss_id)
   DECLARE ividx = i2 WITH protect, noconstant(0)
   DECLARE icidx = i2 WITH protect, noconstant(0)
   DECLARE x = i2 WITH protect, noconstant(0)
   DECLARE itotalcolqual = i4 WITH protect, noconstant(0)
   DECLARE cmilattribute = vc WITH protect, noconstant(" ")
   DECLARE cedwattribute = vc WITH protect, noconstant(" ")
   DECLARE cerrortext = vc WITH protect, noconstant(" ")
   SELECT INTO "nl:"
    FROM wh_oth_cnfg_val cv,
     (dummyt d  WITH seq = value(validation->cnt))
    PLAN (d
     WHERE (validation->cnt > 0))
     JOIN (cv
     WHERE cv.cnfg_value_range BETWEEN icolcnfgrngbeg AND icolcnfgrngend
      AND cv.cnfg_value_qual=trim(validation->qual[d.seq].edw_table)
      AND cv.cnfg_value_use="1")
    ORDER BY cv.cnfg_value_qual, cnvtint(cv.cnfg_value_range_ident)
    HEAD REPORT
     x = 0, icidx = 0, ividx = 0,
     itotalcolqual = 0
    HEAD cv.cnfg_value_qual
     ividx = locateval(x,1,validation->cnt,trim(cv.cnfg_value_qual),validation->qual[x].edw_table),
     icidx = 0
    DETAIL
     cmilattribute = cnvtupper(concat(validation->qual[ividx].mil_table,".",trim(cv.cnfg_value_2))),
     cedwattribute = cnvtupper(concat(validation->qual[ividx].edw_table,".",trim(cv.cnfg_value)))
     IF (checkdic(cmilattribute,"A",0) > 0
      AND checkdic(cedwattribute,"A",0) > 0
      AND ividx > 0)
      icidx = (icidx+ 1)
      IF (mod(icidx,10)=1)
       stat = alterlist(validation->qual[ividx].col_qual,(icidx+ 9))
      ENDIF
      validation->qual[ividx].col_qual[icidx].mil_col = trim(cv.cnfg_value_2), validation->qual[ividx
      ].col_qual[icidx].mil_data_type = trim(cv.cnfg_value_datatype_2), validation->qual[ividx].
      col_qual[icidx].mil_col_size = trim(cv.list_of_value_2),
      validation->qual[ividx].col_qual[icidx].edw_col = trim(cv.cnfg_value), validation->qual[ividx].
      col_qual[icidx].edw_data_type = trim(cv.cnfg_value_datatype), validation->qual[ividx].col_qual[
      icidx].edw_col_size = trim(cv.list_of_value)
      IF (idebug=1)
       CALL echo(build2("MIL_col- ",validation->qual[ividx].col_qual[icidx].mil_col)),
       CALL echo(build2("MIL_data_type- ",validation->qual[ividx].col_qual[icidx].mil_data_type)),
       CALL echo(build2("EDW_col- ",validation->qual[ividx].col_qual[icidx].edw_col)),
       CALL echo(build2("EDW_data_type- ",validation->qual[ividx].col_qual[icidx].edw_data_type))
      ENDIF
     ELSE
      IF (checkdic(cmilattribute,"A",0)=0)
       cerrortxt = concat("Subroutine:Get_CoMetaData::Attribute ",cmilattribute,
        " does not exist in data dictionary"), stat = processerrors(cerrortxt,extract_dt_tm,"N","Y"),
       CALL echo(build2("cMilAttribute:Does not exist- ",cmilattribute))
      ENDIF
      IF (checkdic(cedwattribute,"A",0)=0)
       cerrortxt = concat("Subroutine:Get_CoMetaData::Attribute ",cedwattribute,
        " does not exist in data dictionary"), stat = processerrors(cerrortxt,extract_dt_tm,"N","Y"),
       CALL echo(build2("cEDWAttribute:DoesNot exist- ",cedwattribute))
      ENDIF
     ENDIF
    FOOT  cv.cnfg_value_qual
     itotalcolqual = (itotalcolqual+ icidx), validation->qual[ividx].col_cnt = icidx, stat =
     alterlist(validation->qual[ividx].col_qual,icidx)
    WITH nocounter
   ;end select
   RETURN(itotalcolqual)
 END ;Subroutine
 SUBROUTINE comparecolumns(iindex,ihssid,dfromdate,dtodate,cdblink,imaxdisplay)
   DECLARE chssid = vc WITH private, noconstant(trim(cnvtstring(ihssid,10,0)))
   DECLARE iparqual = i4 WITH private, noconstant(0)
   DECLARE cmil_date_condition = vc WITH private, noconstant(" ")
   DECLARE cjoinclause = vc WITH private, noconstant(" ")
   DECLARE data_length = vc WITH private, noconstant(" ")
   DECLARE data_type = vc WITH private, noconstant(" ")
   DECLARE cast_stmt = vc WITH private, noconstant(" ")
   DECLARE mil_column_comp = vc WITH private, noconstant(" ")
   DECLARE ctempline = vc WITH private, noconstant(" ")
   DECLARE cselectalias = vc WITH private, noconstant(" ")
   DECLARE chold_sk = vc WITH protect, noconstant("000000000000.000")
   DECLARE imaxrecmismatch = i4 WITH protect, noconstant(imaxdisplay)
   DECLARE icidx = i4 WITH protect, noconstant(0)
   DECLARE irowcnt = i4 WITH protect, noconstant(0)
   DECLARE icolcnt = i4 WITH protect, noconstant(0)
   DECLARE itotalcolcnt = i4 WITH protect, noconstant(0)
   DECLARE iutc_timezone_index = i2 WITH protect, noconstant(curtimezoneapp)
   DECLARE cdicactiveind = vc WITH private, noconstant(" ")
   IF ((validation->source_utc_flag > 0))
    SET cmil_date_condition = concat("  where mil.updt_dt_tm between cnvtdatetimeutc(cnvtdatetime(",
     build(dfromdate),"),1)"," AND cnvtdatetimeutc(cnvtdatetime(",build(dtodate),
     "),1)")
   ELSE
    SET cmil_date_condition = concat("  where mil.updt_dt_tm between cnvtdatetime(",build(dfromdate),
     ")"," AND cnvtdatetime(",build(dtodate),
     ")")
   ENDIF
   IF ((validation->qual[iindex].edw_sk_datatype=validation->qual[iindex].mil_pk_datatype))
    SET cjoinclause = concat("WHERE edw.",validation->qual[iindex].edw_sk," = mil.",validation->qual[
     iindex].mil_pk)
   ELSE
    SET data_length = build(cnvtint(validation->qual[iindex].edw_sk_size))
    IF ((validation->qual[iindex].edw_sk_datatype="VARCHAR2"))
     SET data_type = concat("VARCHAR(",trim(data_length,3),")")
    ELSE
     SET data_type = validation->qual[iindex].edw_sk_datatype
    ENDIF
    IF (findstring("sqlpassthru",validation->qual[iindex].mil_pk) > 0)
     SET cast_stmt = concat("cast(",validation->qual[iindex].mil_pk," AS ",data_type,")")
     SET ctempline = replace(validation->qual[iindex].mil_pk,"sqlpassthru(","",1)
     SET ctempline = replace(ctempline,",0)","",2)
     SET ctempline = replace(ctempline,quotes,"",1)
     SET ctempline = replace(ctempline,quotes,"",2)
     SET cast_stmt = concat("cast(",ctempline," AS ",data_type,")")
     SET cjoinclause = concat('WHERE SQLPASSTHRU("edw.',validation->qual[iindex].edw_sk," = ",
      cast_stmt,'")')
    ELSE
     SET cast_stmt = concat("cast(mil.",validation->qual[iindex].mil_pk," AS ",data_type,")")
     SET cjoinclause = concat('WHERE SQLPASSTHRU("edw.',validation->qual[iindex].edw_sk," = ",
      cast_stmt,'")')
    ENDIF
   ENDIF
   SET cselectalias = evaluate(findstring("sqlpass",validation->qual[iindex].mil_pk),0,"mil."," ")
   IF ( NOT ((validation->qual[iindex].secondary_flg IN ("1", "2", "5"))))
    SET stat = insertparserbuffer(concat("SELECT INTO ",quotes,"nl:",quotes))
    IF ((validation->qual[iindex].primary_join_condition != ""))
     SET stat = insertparserbuffer(concat("  mil_pk=",validation->qual[iindex].primary_join_condition
       ))
    ELSE
     SET stat = insertparserbuffer(concat("  mil_pk=",cselectalias,validation->qual[iindex].mil_pk))
    ENDIF
    SET stat = insertparserbuffer(concat("FROM  ",validation->qual[iindex].edw_table," edw"))
    SET stat = insertparserbuffer(concat("     ,",validation->qual[iindex].mil_table,cdblink," mil"))
    SET stat = insertparserbuffer("plan mil")
    SET stat = insertparserbuffer(cmil_date_condition)
   ELSEIF ((validation->qual[iindex].secondary_flg="1"))
    SET stat = insertparserbuffer(concat("SELECT INTO ",quotes,"nl:",quotes))
    SET stat = insertparserbuffer(concat("  mil_pk=mill.",validation->qual[iindex].secondary_column))
    SET stat = insertparserbuffer(concat("FROM  ",validation->qual[iindex].edw_table," edw"))
    SET stat = insertparserbuffer(concat("     ,",validation->qual[iindex].secondary_table,cdblink,
      " mill"))
    SET stat = insertparserbuffer(concat("     ,",validation->qual[iindex].mil_table,cdblink," mil"))
    SET stat = insertparserbuffer("plan mill")
    IF ((validation->source_utc_flag > 0))
     SET cmil_date_condition = concat("  where mill.updt_dt_tm between cnvtdatetimeutc(cnvtdatetime(",
      build(dfromdate),"),1)"," AND cnvtdatetimeutc(cnvtdatetime(",build(dtodate),
      "),1)")
    ELSE
     SET cmil_date_condition = concat("  where mill.updt_dt_tm between cnvtdatetime(",build(dfromdate
       ),")"," AND cnvtdatetime(",build(dtodate),
      ")")
    ENDIF
    SET stat = insertparserbuffer(cmil_date_condition)
    SET stat = insertparserbuffer("join mil")
    SET stat = insertparserbuffer(concat(" where  mil.",validation->qual[iindex].primary_join_column,
      " = mill.",validation->qual[iindex].secondary_column))
   ELSEIF ((validation->qual[iindex].secondary_flg="2"))
    SET stat = insertparserbuffer(concat("SELECT INTO ",quotes,"nl:",quotes))
    SET stat = insertparserbuffer(concat("  mil_pk=",cselectalias,validation->qual[iindex].mil_pk))
    SET stat = insertparserbuffer(concat("FROM  ",validation->qual[iindex].edw_table," edw"))
    SET stat = insertparserbuffer(concat("     ,",validation->qual[iindex].mil_table,cdblink," mil"))
    SET stat = insertparserbuffer(concat("     ,",validation->qual[iindex].secondary_table,cdblink,
      " mill"))
    SET stat = insertparserbuffer("plan mil")
    SET stat = insertparserbuffer(cmil_date_condition)
    SET stat = insertparserbuffer("join mill")
    SET stat = insertparserbuffer(concat(" where  mil.",validation->qual[iindex].primary_join_column,
      " = mill.",validation->qual[iindex].secondary_column))
   ELSEIF ((validation->qual[iindex].secondary_flg="5"))
    SET stat = insertparserbuffer(concat("SELECT INTO ",quotes,"nl:",quotes))
    SET stat = insertparserbuffer(concat("  mil_pk=",cselectalias,validation->qual[iindex].mil_pk))
    SET stat = insertparserbuffer(concat("FROM  ",validation->qual[iindex].edw_table," edw"))
    SET stat = insertparserbuffer(concat("     ,",validation->qual[iindex].mil_table,cdblink," mil"))
    SET stat = insertparserbuffer("plan mil")
    SET stat = insertparserbuffer(cmil_date_condition)
    SET stat = insertparserbuffer(validation->qual[iindex].primary_join_condition)
    SET stat = insertparserbuffer(validation->qual[iindex].second_join_condition)
   ENDIF
   SET stat = insertparserbuffer("JOIN edw")
   SET stat = insertparserbuffer(cjoinclause)
   SET stat = insertparserbuffer(concat("  and edw.health_system_source_id = ",chssid))
   IF ((validation->qual[iindex].edw_sk_datatype="NUMBER"))
    SET stat = insertparserbuffer(concat("  and edw.",validation->qual[iindex].edw_sk," != 0"))
   ELSE
    SET stat = insertparserbuffer(concat("  and edw.",validation->qual[iindex].edw_sk," != '0'"))
   ENDIF
   IF (trim(validation->qual[iindex].edw_table)="WH_CLN_ENCOUNTER")
    SET stat = insertparserbuffer(" and edw.MOST_RECENT_VISIT_IND = 1")
   ENDIF
   SET cdicactiveind = concat(validation->qual[iindex].edw_table,".ACTIVE_IND")
   IF (checkdic(cdicactiveind,"A",0) > 0)
    SET stat = insertparserbuffer("  and edw.ACTIVE_IND = 1")
   ENDIF
   SET stat = insertparserbuffer(concat("order by edw.",validation->qual[iindex].edw_sk))
   SET stat = insertparserbuffer(" ")
   SET stat = insertparserbuffer("HEAD REPORT")
   SET stat = insertparserbuffer("  cHold_SK = '0000000000000.00'")
   SET stat = insertparserbuffer("  iColCnt = 0")
   SET stat = insertparserbuffer("  iTotalColCnt = 0")
   SET stat = insertparserbuffer("  rec_mis_match_cnt=0")
   SET stat = insertparserbuffer("  iRowcnt = detail_rec->Row_cnt")
   SET stat = insertparserbuffer(" ")
   SET stat = insertparserbuffer("  macro ( add_column )")
   SET stat = insertparserbuffer("        iColCnt = iColCnt + 1")
   IF ((validation->qual[iindex].edw_sk_datatype="NUMBER"))
    SET stat = insertparserbuffer(concat("  if (rec_mis_match_cnt <= iMaxRecMisMatch AND build(edw.",
      validation->qual[iindex].edw_sk,") != cHold_SK)"))
   ELSE
    SET stat = insertparserbuffer(concat(
      "        if (rec_mis_match_cnt <= iMaxRecMisMatch AND trim(edw.",validation->qual[iindex].
      edw_sk,") != cHold_SK)"))
   ENDIF
   SET stat = insertparserbuffer("           iRowCnt=iRowCnt+1")
   SET stat = insertparserbuffer("           if ( mod(iRowCnt,10) = 1 )")
   SET stat = insertparserbuffer("              stat = alterlist(detail_rec->row_qual,iRowCnt + 9)")
   SET stat = insertparserbuffer("           endif")
   IF ((validation->qual[iindex].edw_sk_datatype="NUMBER"))
    SET stat = insertparserbuffer(concat("           cHold_SK = build( edw.",validation->qual[iindex]
      .edw_sk,")"))
   ELSE
    SET stat = insertparserbuffer(concat("           cHold_SK = trim(edw.",validation->qual[iindex].
      edw_sk,")"))
   ENDIF
   SET stat = insertparserbuffer("        endif")
   SET stat = insertparserbuffer("        if ( mod(iColCnt,10) = 1 )")
   SET stat = insertparserbuffer(
    "           stat = alterlist(detail_rec->row_qual[iRowCnt].col_qual,iColcnt + 9)")
   SET stat = insertparserbuffer("        endif")
   SET stat = insertparserbuffer("  endmacro")
   SET stat = insertparserbuffer(concat("HEAD edw.",validation->qual[iindex].edw_sk))
   SET stat = insertparserbuffer(" iColCnt=0")
   SET stat = insertparserbuffer(" ")
   SET stat = insertparserbuffer("DETAIL")
   FOR (icidx = 1 TO validation->qual[iindex].col_cnt)
     IF ((validation->qual[iindex].col_qual[icidx].edw_data_type=validation->qual[iindex].col_qual[
     icidx].mil_data_type))
      IF ((validation->qual[iindex].col_qual[icidx].edw_data_type IN ("CHAR", "VARCHAR2")))
       SET mil_column_comp = concat("trim(replace(mil.",validation->qual[iindex].col_qual[icidx].
        mil_col,",str_FIND,str_REPLACE,3),3)")
      ELSE
       SET mil_column_comp = concat("mil.",validation->qual[iindex].col_qual[icidx].mil_col)
      ENDIF
     ELSE
      IF ((validation->qual[iindex].col_qual[icidx].edw_data_type IN ("CHAR", "VARCHAR2"))
       AND (validation->qual[iindex].col_qual[icidx].mil_data_type IN ("CHAR", "VARCHAR2")))
       SET mil_column_comp = concat("trim(replace(mil.",validation->qual[iindex].col_qual[icidx].
        mil_col,",str_FIND,str_REPLACE,3),3)")
      ELSEIF ((validation->qual[iindex].col_qual[icidx].mil_data_type IN ("CHAR", "VARCHAR2"))
       AND (validation->qual[iindex].col_qual[icidx].edw_data_type="NUMBER"))
       SET mil_column_comp = concat("cnvtint(trim(mil.",validation->qual[iindex].col_qual[icidx].
        mil_col,"))")
      ELSEIF ((validation->qual[iindex].col_qual[icidx].mil_data_type IN ("NUMBER", "FLOAT"))
       AND (validation->qual[iindex].col_qual[icidx].edw_data_type IN ("NUMBER", "FLOAT")))
       SET mil_column_comp = concat("mil.",validation->qual[iindex].col_qual[icidx].mil_col)
      ELSE
       SET mil_column_comp = concat("trim(cnvtstring(mil.",validation->qual[iindex].col_qual[icidx].
        mil_col,",16,0))")
      ENDIF
     ENDIF
     IF ((validation->qual[iindex].col_qual[icidx].mil_data_type="DATE"))
      IF ((validation->source_utc_flag=1))
       SET ctempline = concat(" if ( format(cnvtdatetime(",mil_column_comp,"),",char(34),
        "MMDDYYYYHHMM;;Q",
        char(34),") ","!= format(cnvtdatetime(edw.",validation->qual[iindex].col_qual[icidx].edw_col,
        "),",
        char(34),"MMDDYYYYHHMM;;Q",char(34),"))")
      ELSE
       SET ctempline = concat(" if ( datetimezoneformat(cnvtdatetimeutc(",mil_column_comp,
        ",3),iUTC_TIMEZONE_INDEX,",char(34),"MMDDYYYYHHmm",
        char(34),") ","!= format(cnvtdatetime(edw.",validation->qual[iindex].col_qual[icidx].edw_col,
        "),",
        char(34),"MMDDYYYYHHMM;;Q",char(34),"))")
      ENDIF
     ELSE
      SET ctempline = concat(" if( ",mil_column_comp," !=edw.",validation->qual[iindex].col_qual[
       icidx].edw_col,")")
     ENDIF
     SET stat = insertparserbuffer(ctempline)
     SET stat = insertparserbuffer("   add_column ;;macro")
     SET stat = insertparserbuffer("   if (rec_mis_match_cnt <= iMaxRecMisMatch)")
     SET ctempline = concat("    detail_rec->row_qual[iRowCnt].col_qual[iColCnt].edw_col = ",quotes,
      validation->qual[iindex].col_qual[icidx].edw_col,quotes)
     SET stat = insertparserbuffer(ctempline)
     IF ((validation->qual[iindex].col_qual[icidx].mil_data_type="DATE"))
      SET ctempline = build2("    detail_rec->row_qual[iRowCnt].col_qual[iColCnt].mil_col_value = ",
       "datetimezoneformat(evaluate(validation->source_utc_flag,1,cnvtdatetime(",mil_column_comp,")",
       ",0,cnvtdatetimeutc(",
       mil_column_comp,",3)),","iUTC_TIMEZONE_INDEX,",char(34),"MM/DD/YYYY HH:mm",
       char(34),")")
      SET stat = insertparserbuffer(ctempline)
      SET ctempline = build2("   detail_rec->row_qual[iRowCnt].col_qual[iColCnt].edw_col_value = ",
       "format(cnvtdatetimeutc(edw.",validation->qual[iindex].col_qual[icidx].edw_col,",",ods_utc_var,
       "),",char(34),"MM/DD/YYYY HH:MM;;Q",char(34),")")
      SET stat = insertparserbuffer(ctempline)
     ELSE
      SET ctempline = concat(
       "    detail_rec->row_qual[iRowCnt].col_qual[iColCnt].edw_col_value = build(edw.",validation->
       qual[iindex].col_qual[icidx].edw_col,")")
      SET stat = insertparserbuffer(ctempline)
      IF ((validation->qual[iindex].col_qual[icidx].mil_data_type="FLOAT"))
       SET ctempline = concat("    detail_rec->row_qual[iRowCnt].col_qual[iColCnt].mil_col_value = ",
        "trim(cnvtstring(mil.",validation->qual[iindex].col_qual[icidx].mil_col,",16,12))")
      ELSE
       SET ctempline = concat(
        "    detail_rec->row_qual[iRowCnt].col_qual[iColCnt].mil_col_value = build(mil.",validation->
        qual[iindex].col_qual[icidx].mil_col,")")
      ENDIF
      SET stat = insertparserbuffer(ctempline)
     ENDIF
     SET stat = insertparserbuffer("   endif")
     SET stat = insertparserbuffer(" endif")
   ENDFOR
   SET stat = insertparserbuffer(concat("FOOT edw.",validation->qual[iindex].edw_sk))
   SET stat = insertparserbuffer(" if (iColCnt>0)")
   SET stat = insertparserbuffer(" rec_mis_match_cnt = rec_mis_match_cnt + 1")
   SET ctempline = concat("   detail_rec->row_qual[iRowCnt].mil_table = ",quotes,validation->qual[
    iindex].mil_table,quotes)
   SET stat = insertparserbuffer(ctempline)
   SET ctempline = concat("   detail_rec->row_qual[iRowCnt].edw_table = ",quotes,validation->qual[
    iindex].edw_table,quotes)
   SET stat = insertparserbuffer(ctempline)
   SET ctempline = concat("   detail_rec->row_qual[iRowCnt].mil_pk = build(mil_pk)")
   SET stat = insertparserbuffer(ctempline)
   SET ctempline = concat("   detail_rec->row_qual[iRowCnt].edw_sk = build(edw.",validation->qual[
    iindex].edw_sk,")")
   SET stat = insertparserbuffer(ctempline)
   SET stat = insertparserbuffer("   detail_rec->row_qual[iRowCnt].col_cnt = iColCnt")
   SET stat = insertparserbuffer("   iTotalColCnt = iTotalColCnt + iColCnt")
   SET stat = insertparserbuffer(
    "   stat = alterlist(detail_rec->row_qual[iRowCnt].col_qual,iColCnt)")
   SET stat = insertparserbuffer(" endif")
   SET stat = insertparserbuffer("foot report")
   SET stat = insertparserbuffer("   detail_rec->row_cnt = iRowCnt")
   SET stat = insertparserbuffer("   stat = alterlist(detail_rec->row_qual,iRowCnt)")
   SET stat = insertparserbuffer("with nocounter,noheading")
   SET irowcnt = detail_rec->row_cnt
   SET iparqual = execparserbuffer("Y","Y")
   RETURN(itotalcolcnt)
 END ;Subroutine
 SUBROUTINE createmiltemptable(dummy)
   DECLARE istat = i4 WITH private, noconstant(0)
   IF (checkdic("WH_TMP_DV_MILL","T",0) > 0)
    SET istat = dropmiltemptable(0)
   ENDIF
   RDB create global temporary table wh_tmp_dv_mill ( mil_sk varchar2 ( 100 ) , hss_id integer )
   END ;Rdb
   RDB create index xie101_wh_tmp_dv_mill on wh_tmp_dv_mill ( mil_sk , hss_id )
   END ;Rdb
   DROP DDLRECORD wh_tmp_dv_mill FROM DATABASE v500 WITH deps_deleted
   CREATE DDLRECORD wh_tmp_dv_mill FROM DATABASE v500
 TABLE wh_tmp_dv_mill
  1 mil_sk  = vc100 CCL(mil_sk)
  1 hss_id  = i4 CCL(hss_id)
 END TABLE wh_tmp_dv_mill
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dropmiltemptable(dummy)
   DROP TABLE wh_tmp_dv_mill
   RDB drop table wh_tmp_dv_mill
   END ;Rdb
   RETURN(1)
 END ;Subroutine
 SUBROUTINE edwminus(iindex,ihssid,dfromdate,dtodate,cdblink)
   DECLARE chssid = vc WITH private, noconstant(trim(cnvtstring(ihssid,10,0)))
   DECLARE cflagdesc = c1 WITH private, constant("2")
   DECLARE cmilselect = vc WITH private, noconstant(" ")
   DECLARE cedwselect = vc WITH private, noconstant(" ")
   DECLARE cinsertcolumns = vc WITH private, noconstant(" ")
   DECLARE cedw_date_condition = vc WITH private, noconstant(" ")
   DECLARE iparqual = i4 WITH private, noconstant(0)
   DECLARE ctask = vc WITH private, constant(value(curprog))
   DECLARE cuser = vc WITH private, constant("CCL")
   DECLARE dupdtdttm = dq8 WITH private, constant(cnvtdatetime(curdate,curtime2))
   DECLARE minlastproc_dt = dq8
   DECLARE maxlastproc_dt = dq8
   DECLARE tablename = vc WITH private, noconstant(" ")
   DECLARE ftype = vc WITH private, noconstant(" ")
   DECLARE ftypewithq = vc WITH private, noconstant(" ")
   SET tablename = validation->qual[iindex].edw_table
   SET ftype = validation->qual[iindex].file_type
   SET ftypewithq = concat(char(34),ftype,char(34))
   SELECT INTO "nl:"
    minlastproc = min(wops.extract_range_begin), maxlastproc = max(wops.extract_range_end)
    FROM wh_oth_process_stats wops
    WHERE wops.file_type=parser(ftypewithq)
     AND wops.process_dt_tm IN (
    (SELECT
     t.last_process_dt_tm
     FROM (parser(tablename) t)
     WHERE t.last_process_dt_tm BETWEEN cnvtdatetime(dfromdate) AND cnvtdatetime(dtodate)))
    DETAIL
     minlastproc_dt = minlastproc, maxlastproc_dt = maxlastproc
   ;end select
   SET cedwselect = concat("select edw.",validation->qual[iindex].edw_sk,",",chssid,",",
    quotes,validation->qual[iindex].edw_table,quotes,",",quotes,
    validation->qual[iindex].mil_table,quotes,",",quotes,cflagdesc,
    quotes,",","cnvtdatetimeutc(cnvtdatetime(",build(dfromdate),"),2),",
    "cnvtdatetimeutc(cnvtdatetime(",build(dtodate),"),2),","cnvtdatetimeutc(cnvtdatetime(",build(
     validation->process_dt_tm),
    "),2),","cnvtdatetimeutc(cnvtdatetime(",build(dupdtdttm),"),2),",quotes,
    ctask,quotes,",",quotes,cuser,
    quotes)
   IF ((validation->qual[iindex].secondary_flg="4"))
    SET cmilselect = concat("select mil.",validation->qual[iindex].mil_pk,",")
   ELSEIF ( NOT ((validation->qual[iindex].secondary_flg IN ("3"))))
    IF (findstring("sqlpassthru",validation->qual[iindex].mil_pk,1) > 0)
     SET cmilselect = concat("select ",replace(validation->qual[iindex].mil_pk,"decode","cast(decode",
       1),",")
     SET cmilselect = replace(cmilselect,quotes,' AS VARCHAR(100))"',2)
    ELSE
     SET cmilselect = concat("select sqlpassthru(",quotes,"cast(mil.",validation->qual[iindex].mil_pk,
      " as varchar(100))",
      quotes,", 100), ")
    ENDIF
   ELSE
    SET cmilselect = concat("select sqlpassthru(",quotes,"cast(mil.",validation->qual[iindex].mil_pk,
     " as varchar(100))",
     quotes,", 100), ")
   ENDIF
   SET cmilselect = concat(cmilselect,chssid,",",quotes,validation->qual[iindex].edw_table,
    quotes,",",quotes,validation->qual[iindex].mil_table,quotes,
    ",",quotes,cflagdesc,quotes,",",
    "cnvtdatetimeutc(cnvtdatetime(",build(dfromdate),"),2),","cnvtdatetimeutc(cnvtdatetime(",build(
     dtodate),
    "),2),","cnvtdatetimeutc(cnvtdatetime(",build(validation->process_dt_tm),"),2),",
    "cnvtdatetimeutc(cnvtdatetime(",
    build(dupdtdttm),"),2),",quotes,ctask,quotes,
    ",",quotes,cuser,quotes)
   SET cinsertcolumns = concat("(ods_ak,health_system_source_id,wh_table,mil_table,",
    "valid_flg,valid_beg_range_dt_tm,valid_end_range_dt_tm,",
    "process_dt_tm,updt_dt_tm,updt_task,updt_user )")
   SET cedw_date_condition = concat("  and edw.last_process_dt_tm between cnvtdatetime(",build(
     dfromdate),")"," AND cnvtdatetime(",build(dtodate),
    ")")
   SET stat = insertparserbuffer("insert from wh_oth_Data_valid_detail")
   SET stat = insertparserbuffer(cinsertcolumns)
   SET stat = insertparserbuffer("(")
   SET stat = insertparserbuffer(cedwselect)
   SET stat = insertparserbuffer(concat("from ",validation->qual[iindex].edw_table," edw"))
   SET stat = insertparserbuffer(concat("where edw.health_system_source_id = ",chssid))
   SET stat = insertparserbuffer(cedw_date_condition)
   SET stat = insertparserbuffer("MINUS (")
   SET stat = insertparserbuffer(cmilselect)
   SET stat = insertparserbuffer(concat("from ",validation->qual[iindex].mil_table,cdblink," mil"))
   SET stat = insertparserbuffer("where 1=1")
   IF ((validation->qual[iindex].secondary_flg="5"))
    SET stat = insertparserbuffer(validation->qual[iindex].primary_join_condition)
    SET stat = insertparserbuffer(validation->qual[iindex].second_join_condition)
    SET stat = insertparserbuffer(build("and mil.updt_dt_tm >= cnvtdatetime(",minlastproc_dt))
    SET stat = insertparserbuffer(")")
   ENDIF
   SET stat = insertparserbuffer(") WITH NOCOUNTER,RDBUNION,MAXCOMMIT=100000)")
   SET iparqual = execparserbuffer("Y","Y")
   COMMIT
   RETURN(iparqual)
 END ;Subroutine
 SUBROUTINE millminus(iindex,ihssid,dfromdate,dtodate,cdblink)
   DECLARE chssid = vc WITH private, noconstant(trim(cnvtstring(ihssid,10,0)))
   DECLARE cflagdesc = c1 WITH private, constant("1")
   DECLARE cmilselect = vc WITH private, noconstant(" ")
   DECLARE ctmpselect = vc WITH private, noconstant(" ")
   DECLARE cedwselect = vc WITH private, noconstant(" ")
   DECLARE cinsertcolumns = vc WITH private, noconstant(" ")
   DECLARE cmil_date_condition = vc WITH private, noconstant(" ")
   DECLARE ctemppkskjoin = vc WITH private, noconstant(" ")
   DECLARE cdicactiveind = vc WITH private, noconstant(" ")
   DECLARE iparqual = i4 WITH private, noconstant(0)
   DECLARE ctask = vc WITH private, constant(value(curprog))
   DECLARE cuser = vc WITH private, constant("CCL")
   DECLARE dupdtdttm = dq8 WITH private, constant(cnvtdatetime(curdate,curtime2))
   SET cedwselect = concat("select edw.",validation->qual[iindex].edw_sk)
   SET cmilselect = concat("select sqlpassthru(",quotes,"cast(mil.mil_sk as varchar(100))",quotes,
    ", 100), ",
    chssid,",",quotes,validation->qual[iindex].edw_table,quotes,
    ",",quotes,validation->qual[iindex].mil_table,quotes,",",
    quotes,cflagdesc,quotes,",","cnvtdatetimeutc(cnvtdatetime(",
    build(dfromdate),"),2),","cnvtdatetimeutc(cnvtdatetime(",build(dtodate),"),2),",
    "cnvtdatetimeutc(cnvtdatetime(",build(validation->process_dt_tm),"),2),",
    "cnvtdatetimeutc(cnvtdatetime(",build(dupdtdttm),
    "),2),",quotes,ctask,quotes,",",
    quotes,cuser,quotes)
   IF ((validation->qual[iindex].secondary_flg != "1"))
    IF (findstring("sqlpassthru",validation->qual[iindex].mil_pk,1) > 0)
     SET ctmpselect = concat("select ",validation->qual[iindex].mil_pk,", ",chssid)
     SET ctemppkskjoin = concat("edw.",validation->qual[iindex].edw_sk," = mil.mil_sk")
    ELSE
     SET ctmpselect = concat("select sqlpassthru(",quotes,"cast(mil.",validation->qual[iindex].mil_pk,
      " as varchar(100))",
      quotes,", 100), ",chssid)
     SET ctemppkskjoin = concat("edw.",validation->qual[iindex].edw_sk," = mil.mil_sk")
    ENDIF
   ELSE
    IF (findstring("sqlpassthru",validation->qual[iindex].secondary_column,1) > 0)
     SET ctmpselect = concat("select ",validation->qual[iindex].secondary_column,", ",chssid)
     SET ctemppkskjoin = concat("edw.",validation->qual[iindex].edw_sk," = mil.mil_sk")
    ELSE
     SET ctmpselect = concat("select sqlpassthru(",quotes,"cast(mil.",validation->qual[iindex].
      secondary_column," as varchar(100))",
      quotes,", 100), ",chssid)
     SET ctemppkskjoin = concat("edw.",validation->qual[iindex].edw_sk," = mil.mil_sk")
    ENDIF
   ENDIF
   SET cinsertcolumns = concat("(mill_ak,health_system_source_id,wh_table,mil_table,",
    "valid_flg,valid_beg_range_dt_tm,valid_end_range_dt_tm,",
    "process_dt_tm,updt_dt_tm,updt_task,updt_user )")
   IF ((validation->source_utc_flag > 0))
    SET cmil_date_condition = concat("  where mil.updt_dt_tm between cnvtdatetimeutc(cnvtdatetime(",
     build(dfromdate),"),1)"," AND cnvtdatetimeutc(cnvtdatetime(",build(dtodate),
     "),1)")
   ELSE
    SET cmil_date_condition = concat("  where mil.updt_dt_tm between cnvtdatetime(",build(dfromdate),
     ")"," AND cnvtdatetime(",build(dtodate),
     ")")
   ENDIF
   SET cdicactiveind = concat(validation->qual[iindex].mil_table,".ACTIVE_IND")
   SET stat = createmiltemptable(0)
   SET stat = insertparserbuffer("insert from wh_tmp_dv_mill")
   SET stat = insertparserbuffer("(mil_sk,hss_id)")
   SET stat = insertparserbuffer("(")
   SET stat = insertparserbuffer(ctmpselect)
   IF ( NOT ((validation->qual[iindex].secondary_flg IN ("1", "2", "5"))))
    SET stat = insertparserbuffer(concat("from ",validation->qual[iindex].mil_table,cdblink," mil"))
    SET stat = insertparserbuffer(cmil_date_condition)
    IF ((validation->qual[iindex].primary_join_condition != "")
     AND (validation->qual[iindex].secondary_table != ""))
     SET stat = insertparserbuffer(validation->qual[iindex].primary_join_condition)
    ENDIF
   ELSEIF ((validation->qual[iindex].secondary_flg="1"))
    SET stat = insertparserbuffer(concat("from ",validation->qual[iindex].secondary_table,cdblink,
      " mil"))
    SET stat = insertparserbuffer(concat("     ,",validation->qual[iindex].mil_table,cdblink," mill")
     )
    SET stat = insertparserbuffer(cmil_date_condition)
    SET stat = insertparserbuffer(concat(" and  mil.",validation->qual[iindex].secondary_column,
      " = mill.",validation->qual[iindex].primary_join_column))
    SET stat = insertparserbuffer(concat(" and  mil.",validation->qual[iindex].mil_pk," > 0"))
   ELSEIF ((validation->qual[iindex].secondary_flg="2"))
    SET stat = insertparserbuffer(concat("from ",validation->qual[iindex].mil_table,cdblink," mil"))
    SET stat = insertparserbuffer(concat("     ,",validation->qual[iindex].secondary_table,cdblink,
      " mill"))
    SET stat = insertparserbuffer(cmil_date_condition)
    SET stat = insertparserbuffer(concat(" and  mil.",validation->qual[iindex].primary_join_column,
      " = mill.",validation->qual[iindex].secondary_column))
    IF ((validation->qual[iindex].primary_join_condition != "")
     AND (validation->qual[iindex].secondary_table != ""))
     SET stat = insertparserbuffer(validation->qual[iindex].primary_join_condition)
    ENDIF
    SET stat = insertparserbuffer(concat(" and  mil.",validation->qual[iindex].mil_pk," > 0"))
   ELSEIF ((validation->qual[iindex].secondary_flg="5"))
    SET stat = insertparserbuffer(concat("from ",validation->qual[iindex].mil_table,cdblink," mil"))
    SET stat = insertparserbuffer(cmil_date_condition)
    SET stat = insertparserbuffer(validation->qual[iindex].primary_join_condition)
    SET stat = insertparserbuffer(validation->qual[iindex].second_join_condition)
   ENDIF
   IF (checkdic(cdicactiveind,"A",0) > 0)
    SET stat = insertparserbuffer("  and mil.ACTIVE_IND = 1")
   ENDIF
   SET stat = insertparserbuffer("with nocounter,maxcommit=100000)")
   SET iparqual = execparserbuffer("Y","Y")
   SET stat = insertparserbuffer("insert from wh_oth_Data_valid_detail")
   SET stat = insertparserbuffer(cinsertcolumns)
   SET stat = insertparserbuffer("(")
   SET stat = insertparserbuffer(cmilselect)
   SET stat = insertparserbuffer("from wh_tmp_dv_mill mil")
   SET stat = insertparserbuffer("where not exists (")
   SET stat = insertparserbuffer(cedwselect)
   SET stat = insertparserbuffer(concat("from ",validation->qual[iindex].edw_table," edw"))
   SET stat = insertparserbuffer("where edw.health_system_source_id = mil.hss_id")
   SET stat = insertparserbuffer(concat("  and ",ctemppkskjoin))
   SET stat = insertparserbuffer(")) WITH NOCOUNTER,MAXCOMMIT=100000")
   SET iparqual = execparserbuffer("Y","Y")
   COMMIT
   RETURN(iparqual)
 END ;Subroutine
 SUBROUTINE execparserbuffer(ccallparser,cdebug)
   DECLARE icnt = i2 WITH private, noconstant(0)
   DECLARE iqual = i4 WITH private, noconstant(0)
   FOR (icnt = 1 TO parser_buffer->cnt)
    IF (cdebug="Y")
     CALL echo(parser_buffer->qual[icnt].line_text)
    ENDIF
    IF (ccallparser="Y")
     CALL parser(parser_buffer->qual[icnt].line_text)
    ENDIF
   ENDFOR
   IF (ccallparser="Y")
    CALL parser(" GO")
    SET iqual = curqual
   ENDIF
   SET stat = initrec(parser_buffer)
   RETURN(iqual)
 END ;Subroutine
 SUBROUTINE insertparserbuffer(cline)
   SET parser_buffer->cnt = (parser_buffer->cnt+ 1)
   IF (mod(parser_buffer->cnt,10)=1)
    SET stat = alterlist(parser_buffer->qual,(parser_buffer->cnt+ 9))
   ENDIF
   SET parser_buffer->qual[parser_buffer->cnt].line_text = trim(cline)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE insertsummaryrec(iindex,ihssid,dfromdttm,dtodttm,dexecdttm)
   DECLARE iqual = i4 WITH private, noconstant(0)
   DECLARE ctask = vc WITH protect, constant(value(curprog))
   DECLARE cuser = vc WITH protect, constant("CCL")
   DECLARE dupdtdttm = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime2))
   INSERT  FROM wh_oth_data_valid_summary summary
    SET summary.health_system_source_id = ihssid, summary.wh_table = validation->qual[iindex].
     edw_table, summary.mil_table = validation->qual[iindex].mil_table,
     summary.file_type = validation->qual[iindex].file_type, summary.mill_ak = validation->qual[
     iindex].mil_pk, summary.ods_ak = validation->qual[iindex].edw_sk,
     summary.mill_to_ods_ck_ind = validation->valid_mil_minus, summary.ods_to_mil_ck_ind = validation
     ->valid_edw_minus, summary.column_ck_ind = validation->valid_all_columns,
     summary.mill_miss_cnt = validation->qual[iindex].mil_miss_cnt, summary.ods_miss_cnt = validation
     ->qual[iindex].edw_miss_cnt, summary.column_diff_cnt = validation->qual[iindex].col_diff_cnt,
     summary.valid_beg_range_dt_tm = cnvtdatetimeutc(cnvtdatetime(dfromdttm),2), summary
     .valid_end_range_dt_tm = cnvtdatetimeutc(cnvtdatetime(dtodttm),2), summary.process_dt_tm =
     cnvtdatetimeutc(cnvtdatetime(validation->process_dt_tm),2),
     summary.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(dupdtdttm),2), summary.updt_task = ctask,
     summary.updt_user = cuser
    PLAN (summary
     WHERE 1=1)
    WITH nocounter
   ;end insert
   SET iqual = curqual
   COMMIT
   RETURN(iqual)
 END ;Subroutine
 SUBROUTINE insertcoldetails(iindex,ihssid,dfromdttm,dtodttm,dexecdttm)
   DECLARE iqual = i4 WITH private, noconstant(0)
   DECLARE ctask = vc WITH protect, constant(value(curprog))
   DECLARE cuser = vc WITH protect, constant("CCL")
   DECLARE dupdtdttm = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime2))
   INSERT  FROM wh_oth_data_valid_detail wh_detail,
     (dummyt d1  WITH seq = value(iindex)),
     (dummyt d2  WITH seq = 1)
    SET wh_detail.health_system_source_id = ihssid, wh_detail.wh_table = detail_rec->row_qual[d1.seq]
     .edw_table, wh_detail.mil_table = detail_rec->row_qual[d1.seq].mil_table,
     wh_detail.mill_ak = detail_rec->row_qual[d1.seq].mil_pk, wh_detail.ods_ak = detail_rec->
     row_qual[d1.seq].edw_sk, wh_detail.ods_diff_column = detail_rec->row_qual[d1.seq].col_qual[d2
     .seq].edw_col,
     wh_detail.ods_column_value_txt = detail_rec->row_qual[d1.seq].col_qual[d2.seq].edw_col_value,
     wh_detail.mil_column_value_txt = detail_rec->row_qual[d1.seq].col_qual[d2.seq].mil_col_value,
     wh_detail.valid_flg = 3,
     wh_detail.valid_beg_range_dt_tm = cnvtdatetimeutc(cnvtdatetime(dfromdttm),2), wh_detail
     .valid_end_range_dt_tm = cnvtdatetimeutc(cnvtdatetime(dtodttm),2), wh_detail.process_dt_tm =
     cnvtdatetimeutc(cnvtdatetime(dexecdttm),2),
     wh_detail.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(dupdtdttm),2), wh_detail.updt_task = ctask,
     wh_detail.updt_user = cuser
    PLAN (d1
     WHERE maxrec(d2,detail_rec->row_qual[d1.seq].col_cnt))
     JOIN (d2)
     JOIN (wh_detail)
    WITH nocounter, maxcommit = 100000
   ;end insert
   SET iqual = curqual
   COMMIT
   RETURN(iqual)
 END ;Subroutine
#end_program
 FREE RECORD detail_rec
 FREE RECORD validation
 FREE RECORD parser_buffer
 FREE RECORD error_rec
 IF (checkdic("WH_TMP_DV_MILL","T",0) > 0)
  SET istat = dropmiltemptable(0)
 ENDIF
 SET script_version = "015 09/10/14 SB026554"
END GO
