CREATE PROGRAM dm_rdds_compare_table_orig:dba
 DECLARE check_sql_error(cse_object_name=vc,cse_object_type=vc) = i4
 SUBROUTINE check_sql_error(cse_object_name,cse_object_type)
   DECLARE sql_obj_name = vc WITH protect, noconstant(cnvtupper(trim(cse_object_name,3)))
   DECLARE sql_obj_type = vc WITH protect, noconstant(cnvtupper(trim(cse_object_type,3)))
   DECLARE par = c20 WITH protect, noconstant("")
   DECLARE sql_error_msg = vc WITH protect, noconstant("")
   DECLARE sql_disp_msg = vc WITH protect, noconstant("")
   DECLARE sql_chk_num = i4 WITH protect, noconstant(1)
   DECLARE sql_chk_cnt = i4 WITH protect, noconstant(0)
   DECLARE valid_obj_flg = i4 WITH protect, noconstant(0)
   IF (((sql_obj_name=" ") OR (sql_obj_type=" ")) )
    SET valid_obj_flg = 0
    SET sql_disp_msg = "Incorrect parameters. Usage:dm_rmc_sql_chk <object_name>, <object_type>"
    CALL echo("Incorrect parameters. Usage:dm_rmc_sql_chk <object_name>, <object_type>")
    RETURN(valid_obj_flg)
   ENDIF
   SELECT INTO "nl:"
    u.text
    FROM user_errors u
    WHERE u.name=sql_obj_name
     AND u.type=sql_obj_type
    DETAIL
     sql_error_msg = u.text
    WITH nocounter
   ;end select
   IF (curqual)
    SET sql_disp_msg = concat(sql_obj_type," ",sql_obj_name," failed to compile:",sql_error_msg)
    CALL echo(concat(sql_obj_type," ",sql_obj_name," failed to compile:",sql_error_msg))
    SET valid_obj_flg = 0
   ENDIF
   SELECT INTO "nl:"
    u.object_name
    FROM user_objects u
    WHERE u.object_name=sql_obj_name
     AND u.object_type=sql_obj_type
     AND u.status="VALID"
    WITH nocounter
   ;end select
   IF (curqual)
    SET sql_disp_msg = concat(sql_obj_type," ",sql_obj_name," is valid.")
    CALL echo(sql_disp_msg)
    SET valid_obj_flg = 1
   ELSE
    SET sql_disp_msg = concat(sql_obj_type," ",sql_obj_name," is invalid.")
    CALL echo(sql_disp_msg)
    SET valid_obj_flg = 0
   ENDIF
   RETURN(valid_obj_flg)
 END ;Subroutine
 FREE RECORD parser_buf_1_2
 RECORD parser_buf_1_2(
   1 qual[*]
     2 line = vc
 ) WITH protect
 FREE RECORD parser_buf_3
 RECORD parser_buf_3(
   1 qual[*]
     2 line = vc
 )
 DECLARE i = i2 WITH protect, noconstant(0)
 DECLARE iidx = i4 WITH protect, noconstant(0)
 DECLARE icnt = i4 WITH protect, noconstant(0)
 DECLARE inum = i4 WITH protect, noconstant(0)
 DECLARE ilogtypeidx = i4 WITH protect, noconstant(0)
 DECLARE itotalcnt = i4 WITH protect, noconstant(0)
 DECLARE icolumncnt = i4 WITH protect, noconstant(0)
 DECLARE sviewjoin = vc WITH protect, noconstant("")
 DECLARE sjoin_3 = vc WITH protect, noconstant("")
 DECLARE sviewselect = vc WITH protect, noconstant("")
 DECLARE sviewselecttrans = vc WITH protect, noconstant("")
 DECLARE nsqllines = i4 WITH protect, noconstant(0)
 DECLARE naudits = i2 WITH protect, constant(3)
 DECLARE imaxerrors = i4 WITH private, noconstant(0)
 DECLARE iparsercnt = i4 WITH protect, noconstant(0)
 DECLARE sfunctionpre = vc WITH protect, noconstant("")
 DECLARE sfunctionsuffix = vc WITH protect, noconstant("")
 DECLARE rdds_diff_translate_src(p1,p2,p3,p4,p5) = f8
 DECLARE rdds_diff_translate_tgt(p1,p2,p3,p4,p5) = f8
 DECLARE ssql = vc WITH protect, noconstant("")
 DECLARE sdefault = vc WITH protect, noconstant("")
 DECLARE sdefaulttrans = vc WITH protect, noconstant("")
 DECLARE scondition_3 = vc WITH protect, noconstant("")
 DECLARE strim = vc WITH protect, noconstant("")
 DECLARE strimparam = vc WITH protect, noconstant("")
 DECLARE sdetailsectionpk_3 = vc WITH protect, noconstant("")
 DECLARE sdetailsection_1_2 = vc WITH protect, noconstant("")
 DECLARE sselectlist = vc WITH protect, noconstant("")
 DECLARE sselectlist_3 = vc WITH protect, noconstant("")
 DECLARE sdecode = vc WITH protect, noconstant("")
 DECLARE sdecode_3 = vc WITH protect, noconstant("")
 DECLARE sdecodeparent = vc WITH protect, noconstant("")
 DECLARE sdecodeseq = vc WITH protect, noconstant("")
 DECLARE sdecodemergedel = vc WITH protect, noconstant("")
 DECLARE sdecodeexceptionflg = vc WITH protect, noconstant("")
 DECLARE ssourcefilter = vc WITH protect, noconstant("")
 DECLARE stargetfilter = vc WITH protect, noconstant("")
 DECLARE stranslate = vc WITH protect, noconstant("")
 DECLARE nsize = i2 WITH protect, noconstant(0)
 DECLARE slogtype = vc WITH protect, noconstant("")
 DECLARE nlogtypecnt = i4 WITH protect, noconstant(0)
 DECLARE slogtypedetail = vc WITH protect, noconstant("")
 DECLARE sversionfilter = vc WITH protect, noconstant("")
 DECLARE ifunctionexists = i2 WITH protect, noconstant(0)
 DECLARE sversionfiltersrc = vc WITH protect, noconstant("")
 DECLARE sversionfiltertgt = vc WITH protect, noconstant("")
 DECLARE smergedelete = vc WITH protect, noconstant("")
 DECLARE sdefattind = vc WITH protect, noconstant("")
 DECLARE slogtypeselectsrc = vc WITH protect, noconstant("")
 DECLARE scontextselectsrc = vc WITH protect, noconstant("")
 DECLARE slogtypeselectsrc_3 = vc WITH protect, noconstant("")
 DECLARE scontextselectsrc_3 = vc WITH protect, noconstant("")
 DECLARE soradecodesrc = vc WITH protect, noconstant("")
 DECLARE slogtypeselecttgt = vc WITH protect, noconstant("")
 DECLARE scontextselecttgt = vc WITH protect, noconstant("")
 DECLARE slogtypewhereclause = vc WITH protect, noconstant("")
 DECLARE scontextwhereclause = vc WITH protect, noconstant("")
 DECLARE scontextwhereclause_3 = vc WITH protect, noconstant("")
 DECLARE soradecodetgt = vc WITH protect, noconstant("")
 DECLARE stablenamestr = vc WITH protect, noconstant("")
 DECLARE iviewjoinind = i2 WITH protect, noconstant(1)
 DECLARE spkcolumnname = vc WITH protect, noconstant("")
 DECLARE ipkcnt = i2 WITH protect, noconstant(0)
 DECLARE icolumncomparecnt = i2 WITH protect, noconstant(0)
 DECLARE sfromjoin_3 = vc WITH protect, noconstant("")
 DECLARE swherejoinview_3 = vc WITH protect, noconstant("")
 DECLARE sdetailsectionidx_1_2 = i4 WITH protect, noconstant(0)
 DECLARE slogtypevar = vc WITH protect, noconstant("")
 DECLARE nbufferdetailstart_3 = i2 WITH protect, constant(20)
 DECLARE ndetailnextidx_3 = i2 WITH protect, noconstant(nbufferdetailstart_3)
 SET imaxerrors = (irownum+ 1)
 SET stat = alterlist(audit_info->audit_types,3)
 SET audit_info->audit_types[1].audit_flg = 1
 SET audit_info->audit_types[1].audit_desc = "Rows in the target domain that are not in the source"
 SET stat = alterlist(parser_buf_1_2->qual,500)
 SET stat = alterlist(parser_buf_3->qual,500)
 SET slogtypedetail = concat("sLogType = v_log_type ",
  "		iLogTypeIdx = locateval(iNum,1,audit_info->audit_types[::AUDIT].log_type_cnt, ",
  "		    sLogType,audit_info->audit_types[::AUDIT].log_types[iNum].log_type) ",
  "		if (iLogTypeIdx > 0) ","		  audit_info->audit_types[::AUDIT].log_types[iLogTypeIdx].cnt = ",
  "	  	  audit_info->audit_types[::AUDIT].log_types[iLogTypeIdx].cnt + 1 ","		else ",
  "		  nLogTypeCnt = nLogTypeCnt + 1 ",
  "		  audit_info->audit_types[::AUDIT].log_type_cnt = nLogTypeCnt",
  "		  stat = alterlist(audit_info->audit_types[::AUDIT].log_types, nLogTypeCnt)",
  " 		  audit_info->audit_types[::AUDIT].log_types[nLogTypeCnt].log_type = sLogType ",
  "		  audit_info->audit_types[::AUDIT].log_types[nLogTypeCnt].cnt = 1 ","		endif")
 SET sdetailsectionidx_1_2 = 13
 FOR (iidx = 1 TO table_info->tables[itableidx].column_cnt)
   SET icolumncnt = (icolumncnt+ 1)
   SET smergedelete = cnvtstring(table_info->tables[itableidx].columns[iidx].no_backfill_ind)
   SET sdefattind = cnvtstring(table_info->tables[itableidx].columns[iidx].defining_attribute_ind)
   IF ((((table_info->tables[itableidx].columns[iidx].data_type="F")) OR ((table_info->tables[
   itableidx].columns[iidx].data_type="I"))) )
    SET sfunctionpre = "trim(cnvtstring("
    SET sfunctionsuffix = "),3)"
    IF ((table_info->tables[itableidx].columns[iidx].data_type="I"))
     SET sdefault = "0"
    ELSE
     SET sdefault = "0.0"
    ENDIF
    SET strim = "("
    SET strimparam = ")"
   ELSEIF ((table_info->tables[itableidx].columns[iidx].data_type="Q"))
    SET sfunctionpre = "format("
    SET sfunctionsuffix = ',";;q")'
    SET sdefault = "cnvtdatetime(1,1)"
    SET strim = "("
    SET strimparam = ")"
   ELSE
    SET sfunctionpre = "("
    SET sfunctionsuffix = ")"
    SET sdefault = '"NULL"'
    SET strim = "trim("
    SET strimparam = ",3)"
   ENDIF
   SET sdefaulttrans = sdefault
   IF ((table_info->tables[itableidx].columns[iidx].translation_ind=1))
    SET stranslate = concat('," > ",',sfunctionpre,table_info->tables[itableidx].columns[iidx].
     column_name,"_src",sfunctionsuffix)
   ELSE
    SET stranslate = notrim(" ")
   ENDIF
   SET parser_buf_1_2->qual[sdetailsectionidx_1_2].line = concat(
    "audit_info->audit_types[1].audit_values[iCnt].data_values[",cnvtstring(icolumncnt),
    "].column_name = ",'"',table_info->tables[itableidx].columns[iidx].column_name,
    '"'," audit_info->audit_types[1].audit_values[iCnt].data_values[",cnvtstring(icolumncnt),
    "].::STRUCTNAME = concat(",sfunctionpre,
    "s.",table_info->tables[itableidx].columns[iidx].column_name,sfunctionsuffix,stranslate,")")
   SET sdetailsectionidx_1_2 = (sdetailsectionidx_1_2+ 1)
   SET ndetailnextidx_3 = (ndetailnextidx_3+ 1)
   SET parser_buf_3->qual[ndetailnextidx_3].line = concat(" cnt = cnt + 1",
    " stat = alterlist(audit_info->audit_types[3].audit_values[iCnt].data_values,cnt)",
    " audit_info->audit_types[3].audit_values[iCnt].data_values[cnt].column_name = ",'"',table_info->
    tables[itableidx].columns[iidx].column_name,
    '"')
   SET nsize = size(table_info->tables[itableidx].columns[iidx].parent_entity_vals,5)
   IF ((table_info->tables[itableidx].columns[iidx].no_compare_ind != 1))
    SET icolumncomparecnt = (icolumncomparecnt+ 1)
    IF (nsize > 0)
     SET sdecode_3 = concat("DECODE(TRIM(s.",trim(table_info->tables[itableidx].columns[iidx].
       parent_entity_col,3),",3),")
     SET sdecode = concat("DECODE(RTRIM(LTRIM(s.",trim(table_info->tables[itableidx].columns[iidx].
       parent_entity_col,3),")),")
     FOR (i = 1 TO nsize)
       SET sdecodeparent = concat(trim(sdecodeparent,3),",'",trim(table_info->tables[itableidx].
         columns[iidx].parent_entity_vals[i].pe_table_value,3),"','",trim(table_info->tables[
         itableidx].columns[iidx].parent_entity_vals[i].root_entity_name,3),
        "'")
       SET sdecodeseq = concat(trim(sdecodeseq,3),",'",trim(table_info->tables[itableidx].columns[
         iidx].parent_entity_vals[i].pe_table_value,3),"','",trim(cnvtstring(table_info->tables[
          itableidx].columns[iidx].parent_entity_vals[i].sequence_match),3),
        "'")
       SET sdecodemergedel = concat(trim(sdecodemergedel,3),",'",trim(table_info->tables[itableidx].
         columns[iidx].parent_entity_vals[i].pe_table_value,3),"','",trim(cnvtstring(table_info->
          tables[itableidx].columns[iidx].parent_entity_vals[i].no_backfill_ind),3),
        "'")
       SET sdecodeexceptionflg = concat(trim(sdecodeexceptionflg,3),",'",trim(table_info->tables[
         itableidx].columns[iidx].parent_entity_vals[i].pe_table_value,3),"','",trim(cnvtstring(
          table_info->tables[itableidx].columns[iidx].parent_entity_vals[i].exception_flg),3),
        "'")
     ENDFOR
     SET scondition_3 = concat(trim(scondition_3,3)," OR rdds_diff_translate_src(",replace(sdecode_3,
       "DECODE(","EVALUATE("),substring(2,size(sdecodeparent,1),sdecodeparent),"),",
      replace(sdecode_3,"DECODE(","EVALUATE("),substring(2,size(sdecodeseq,3),sdecodeseq),"),s.",
      table_info->tables[itableidx].columns[iidx].column_name,",",
      replace(sdecode_3,"DECODE(","EVALUATE("),substring(2,size(sdecodemergedel,1),sdecodemergedel),
      "),",sdefattind,",",
      replace(sdecode_3,"DECODE(","EVALUATE("),substring(2,size(sdecodeexceptionflg,1),
       sdecodeexceptionflg),")",")!=t.",table_info->tables[itableidx].columns[iidx].column_name,
      " ")
     SET sselectlist = concat(trim(sselectlist,3),",",table_info->tables[itableidx].columns[iidx].
      column_name,"_src = ","sqlpassthru(^decode(sign(rownum - ",
      cnvtstring(imaxerrors),"),-1,::TRANSLATE(",replace(sdecode,"DECODE(TRIM","DECODE(RTRIM(LTRIM"),
      substring(2,size(sdecodeparent,1),sdecodeparent),"),",
      replace(sdecode,"DECODE(TRIM","DECODE(RTRIM(LTRIM"),substring(2,size(sdecodeseq,3),sdecodeseq),
      "),s.",table_info->tables[itableidx].columns[iidx].column_name,",",
      replace(sdecode,"DECODE(TRIM","DECODE(RTRIM(LTRIM"),substring(2,size(sdecodemergedel,1),
       sdecodemergedel),"),",sdefattind,",",
      replace(sdecode,"DECODE(TRIM","DECODE(RTRIM(LTRIM"),substring(2,size(sdecodeexceptionflg,1),
       sdecodeexceptionflg),")","),NULL)^,30)")
     SET sselectlist = replace(sselectlist,",3),",",3)),")
     SET sselectlist_3 = concat(trim(sselectlist_3,3),",",table_info->tables[itableidx].columns[iidx]
      .column_name,"_src =","::TRANSLATE(",
      replace(sdecode_3,"DECODE(","EVALUATE("),substring(2,size(sdecodeparent,1),sdecodeparent),"),",
      replace(sdecode_3,"DECODE(","EVALUATE("),substring(2,size(sdecodeseq,3),sdecodeseq),
      "),s.",table_info->tables[itableidx].columns[iidx].column_name,",",replace(sdecode_3,"DECODE(",
       "EVALUATE("),substring(2,size(sdecodemergedel,1),sdecodemergedel),
      "),",sdefattind,",",replace(sdecode_3,"DECODE(","EVALUATE("),substring(2,size(
        sdecodeexceptionflg,1),sdecodeexceptionflg),
      ")",")")
    ELSEIF ((table_info->tables[itableidx].columns[iidx].translation_ind=1))
     IF ((table_info->tables[itableidx].columns[iidx].pk_ind != 1))
      SET scondition_3 = concat(trim(scondition_3,3)," or rdds_diff_translate_src(","'",table_info->
       tables[itableidx].columns[iidx].root_entity_name,"',",
       cnvtstring(table_info->tables[itableidx].columns[iidx].sequence_match),",s.",table_info->
       tables[itableidx].columns[iidx].column_name,",",smergedelete,
       ",",sdefattind,",",cnvtstring(table_info->tables[itableidx].columns[iidx].exception_flg),
       ") != t.",
       table_info->tables[itableidx].columns[iidx].column_name)
     ENDIF
     SET sselectlist = concat(trim(sselectlist,3),",",table_info->tables[itableidx].columns[iidx].
      column_name,"_src =","sqlpassthru(^decode(sign(rownum - ",
      cnvtstring(imaxerrors),"),-1,::TRANSLATE(","'",table_info->tables[itableidx].columns[iidx].
      root_entity_name,"',",
      cnvtstring(table_info->tables[itableidx].columns[iidx].sequence_match),",s.",table_info->
      tables[itableidx].columns[iidx].column_name,",",smergedelete,
      ",",sdefattind,",",cnvtstring(table_info->tables[itableidx].columns[iidx].exception_flg),
      "),NULL)^,30)")
     SET sselectlist_3 = concat(trim(sselectlist_3,3),",",table_info->tables[itableidx].columns[iidx]
      .column_name,"_src =","::TRANSLATE(",
      "'",table_info->tables[itableidx].columns[iidx].root_entity_name,"',",cnvtstring(table_info->
       tables[itableidx].columns[iidx].sequence_match),",s.",
      table_info->tables[itableidx].columns[iidx].column_name,",",smergedelete,",",sdefattind,
      ",",cnvtstring(table_info->tables[itableidx].columns[iidx].exception_flg),")")
     SET sdefaulttrans = "0.0"
    ELSE
     SET scondition_3 = concat(trim(scondition_3,3)," OR nullval(",strim,"s.",table_info->tables[
      itableidx].columns[iidx].column_name,
      strimparam,",",sdefault,") != nullval(",strim,
      "t.",table_info->tables[itableidx].columns[iidx].column_name,strimparam,",",sdefault,
      ")")
     SET sselectlist = concat(trim(sselectlist,3),",",table_info->tables[itableidx].columns[iidx].
      column_name,"_src =","sqlpassthru(^decode(sign(rownum - ",
      cnvtstring(imaxerrors),"),-1,s.",table_info->tables[itableidx].columns[iidx].column_name,
      ",NULL)^,30)")
     SET sselectlist_3 = concat(trim(sselectlist_3,3),",",table_info->tables[itableidx].columns[iidx]
      .column_name,"_src =","s.",
      table_info->tables[itableidx].columns[iidx].column_name)
    ENDIF
    SET ndetailnextidx_3 = (ndetailnextidx_3+ 1)
    SET parser_buf_3->qual[ndetailnextidx_3].line = concat(" if (nullval(",strim,table_info->tables[
     itableidx].columns[iidx].column_name,"_src",strimparam,
     ",",sdefaulttrans,") != nullval(",strim,"t.",
     table_info->tables[itableidx].columns[iidx].column_name,strimparam,",",sdefault,"))",
     " audit_info->audit_types[3].audit_values[iCnt].data_values[cnt].tgt_column_value = concat(",
     '"***",',sfunctionpre,strim,"t.",
     table_info->tables[itableidx].columns[iidx].column_name,strimparam,sfunctionsuffix,',"***")',
     " audit_info->audit_types[3].audit_values[iCnt].data_values[cnt].src_column_value = concat(",
     '"***",',sfunctionpre,strim,"s.",table_info->tables[itableidx].columns[iidx].column_name,
     strimparam,sfunctionsuffix,stranslate,',"***")'," else ",
     " audit_info->audit_types[3].audit_values[iCnt].data_values[cnt].src_column_value = concat(",
     sfunctionpre,"s.",table_info->tables[itableidx].columns[iidx].column_name,sfunctionsuffix,
     stranslate,")",
     " audit_info->audit_types[3].audit_values[iCnt].data_values[cnt].tgt_column_value = ",
     sfunctionpre,"t.",
     table_info->tables[itableidx].columns[iidx].column_name,sfunctionsuffix," endif ")
   ELSE
    SET ndetailnextidx_3 = (ndetailnextidx_3+ 1)
    SET parser_buf_3->qual[ndetailnextidx_3].line = concat(
     " audit_info->audit_types[3].audit_values[iCnt].data_values[cnt].src_column_value = concat(",
     sfunctionpre,"s.",table_info->tables[itableidx].columns[iidx].column_name,sfunctionsuffix,
     ")"," audit_info->audit_types[3].audit_values[iCnt].data_values[cnt].tgt_column_value = ",
     sfunctionpre,"t.",table_info->tables[itableidx].columns[iidx].column_name,
     sfunctionsuffix)
   ENDIF
   IF ((table_info->tables[itableidx].columns[iidx].pk_ind=1))
    SET ipkcnt = (ipkcnt+ 1)
    SET spkcolumnname = table_info->tables[itableidx].columns[iidx].column_name
    SET sviewjoin = concat(" AND s.",table_info->tables[itableidx].columns[iidx].column_name,"=","v.",
     table_info->tables[itableidx].columns[iidx].column_name,
     sviewjoin)
    SET sviewselect = concat(",",table_info->tables[itableidx].columns[iidx].column_name,sviewselect)
    IF (nsize > 0)
     SET sviewselecttrans = concat(",rdds_diff_translate_src(",sdecode,substring(2,size(sdecodeparent,
        1),sdecodeparent),"),",sdecode,
      substring(2,size(sdecodeseq,3),sdecodeseq),"),",table_info->tables[itableidx].columns[iidx].
      column_name,",",sdecode,
      substring(2,size(sdecodemergedel,1),sdecodemergedel),"),",sdefattind,",",sdecode,
      substring(2,size(sdecodeexceptionflg,1),sdecodeexceptionflg),")) as ",table_info->tables[
      itableidx].columns[iidx].column_name," ",sviewselecttrans)
     SET sjoin_3 = concat(" AND rdds_diff_translate_src(",replace(sdecode_3,"DECODE(","EVALUATE("),
      substring(2,size(sdecodeparent,1),sdecodeparent),"),",replace(sdecode_3,"DECODE(","EVALUATE("),
      substring(2,size(sdecodeseq,3),sdecodeseq),"),s.",table_info->tables[itableidx].columns[iidx].
      column_name,",",replace(sdecode_3,"DECODE(","EVALUATE("),
      substring(2,size(sdecodemergedel,1),sdecodemergedel),"),",sdefattind,",",replace(sdecode_3,
       "DECODE(","EVALUATE("),
      substring(2,size(sdecodeexceptionflg,1),sdecodeexceptionflg),")) = t.",table_info->tables[
      itableidx].columns[iidx].column_name,sjoin_3)
     SET iviewjoinind = 0
    ELSE
     IF ((table_info->tables[itableidx].columns[iidx].translation_ind=1))
      SET sviewselecttrans = concat(",rdds_diff_translate_src(","'",table_info->tables[itableidx].
       columns[iidx].root_entity_name,"',",cnvtstring(table_info->tables[itableidx].columns[iidx].
        sequence_match),
       ",",table_info->tables[itableidx].columns[iidx].column_name,",",smergedelete,",",
       sdefattind,",",cnvtstring(table_info->tables[itableidx].columns[iidx].exception_flg),") as ",
       table_info->tables[itableidx].columns[iidx].column_name,
       sviewselecttrans)
      SET stablenamestr = concat(stablenamestr,"','",table_info->tables[itableidx].columns[iidx].
       root_entity_name)
      SET sjoin_3 = concat(" AND rdds_diff_translate_src(","'",table_info->tables[itableidx].columns[
       iidx].root_entity_name,"',",cnvtstring(table_info->tables[itableidx].columns[iidx].
        sequence_match),
       ",s.",table_info->tables[itableidx].columns[iidx].column_name,",",smergedelete,",",
       sdefattind,",",cnvtstring(table_info->tables[itableidx].columns[iidx].exception_flg),") = t.",
       table_info->tables[itableidx].columns[iidx].column_name,
       sjoin_3)
     ELSE
      SET sviewselecttrans = concat(",",table_info->tables[itableidx].columns[iidx].column_name,
       sviewselecttrans)
      SET sjoin_3 = concat(" AND s.",table_info->tables[itableidx].columns[iidx].column_name," = t.",
       table_info->tables[itableidx].columns[iidx].column_name,sjoin_3)
      SET iviewjoinind = 0
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 IF (ipkcnt=1
  AND iviewjoinind=1)
  SET iviewjoinind = 1
 ELSE
  SET iviewjoinind = 0
 ENDIF
 SET stablenamestr = concat(trim(stablenamestr,3),"'")
 SET sviewselect = substring(2,size(sviewselect,1),sviewselect)
 SET sviewselecttrans = substring(2,size(sviewselecttrans,1),sviewselecttrans)
 SET stablenamestr = substring(3,(size(stablenamestr,1) - 2),stablenamestr)
 IF (size(table_info->tables[itableidx].tgt_filter_function,1) > 0)
  SET ifunctionexists = 1
  SET stargetfilter = concat(" where ",table_info->tables[itableidx].tgt_filter_function,"('ADD'",
   replace(table_info->tables[itableidx].tgt_filter_parameters,"::","t."),") = 1")
  SET ssourcefilter = concat(" where ",table_info->tables[itableidx].src_filter_function,sdblink,
   "('ADD'",replace(table_info->tables[itableidx].src_filter_parameters,"::","t."),
   ") = 1")
 ELSE
  SET ifunctionexists = 0
  SET ssourcefilter = ""
  SET stargetfilter = ""
 ENDIF
 IF ((table_info->tables[itableidx].version_flg > 0))
  IF ((table_info->tables[itableidx].version_flg=1))
   SET sversionfilter = " ::ALIASactive_ind = 1 "
  ELSEIF ((table_info->tables[itableidx].version_flg=2))
   SET sversionfilter = concat(" ::SYSDATE between ",char(10),"::ALIAS",table_info->tables[itableidx]
    .beg_column_name," and ",
    "::ALIAS",table_info->tables[itableidx].end_column_name)
  ELSE
   SET sversionfilter = ""
  ENDIF
  IF (ifunctionexists=1)
   SET ssourcefilter = concat(ssourcefilter," and ",replace(sversionfilter,"::ALIAS","t."))
   SET stargetfilter = concat(stargetfilter," and ",replace(sversionfilter,"::ALIAS","t."))
  ELSE
   SET ssourcefilter = concat("where ",replace(sversionfilter,"::ALIAS","t."))
   SET stargetfilter = ssourcefilter
  ENDIF
  SET ssourcefilter = replace(ssourcefilter,"::SYSDATE","sysdate")
  SET stargetfilter = replace(stargetfilter,"::SYSDATE","sysdate")
 ENDIF
 IF (ilimitchglog=1)
  SET soradecodetgt = concat("decode(sign(rownum-",cnvtstring(imaxerrors),
   "),-1, dm_rdds_log_type_tgt(",substring(2,(size(replace(table_info->tables[itableidx].
      tgt_pkwhere_parameters,"::","s."),1) - 1),replace(table_info->tables[itableidx].
     tgt_pkwhere_parameters,"::","s.")),",0)",
   ",'**SKIPPED CHANGE LOG CHECK**')")
  SET slogtypeselecttgt = concat('v_log_type =  sqlpassthru("',soradecodetgt,'",30) ')
  SET soradecodesrc = concat("decode(sign(rownum-",cnvtstring(imaxerrors),
   "),-1, dm_rdds_log_type_src(",substring(2,(size(replace(table_info->tables[itableidx].
      cmp_pkwhere_parameters,"::","s."),1) - 1),replace(table_info->tables[itableidx].
     cmp_pkwhere_parameters,"::","s.")),",0)",
   ",'**SKIPPED CHANGE LOG CHECK**')")
  SET slogtypeselectsrc = concat('v_log_type =  sqlpassthru("',soradecodesrc,'",30) ')
  SET soradecodetgt = concat("decode(sign(rownum-",cnvtstring(imaxerrors),
   "),-1, dm_rdds_log_type_tgt(",substring(2,(size(replace(table_info->tables[itableidx].
      tgt_pkwhere_parameters,"::","s."),1) - 1),replace(table_info->tables[itableidx].
     tgt_pkwhere_parameters,"::","s.")),",1)",
   ",'**SKIPPED CHANGE LOG CHECK**')")
  SET scontextselecttgt = concat('v_context_name =  sqlpassthru("',soradecodetgt,'",30) ')
  SET soradecodesrc = concat("decode(sign(rownum-",cnvtstring(imaxerrors),
   "),-1, dm_rdds_log_type_src(",substring(2,(size(replace(table_info->tables[itableidx].
      cmp_pkwhere_parameters,"::","s."),1) - 1),replace(table_info->tables[itableidx].
     cmp_pkwhere_parameters,"::","s.")),",1)",
   ",'**SKIPPED CHANGE LOG CHECK**')")
  SET scontextselectsrc = concat('v_context_name =  sqlpassthru("',soradecodesrc,'",30) ')
 ELSE
  SET slogtypeselecttgt = concat(" v_log_type = dm_rdds_log_type_tgt(",substring(2,(size(replace(
      table_info->tables[itableidx].tgt_pkwhere_parameters,"::","s."),1) - 1),replace(table_info->
     tables[itableidx].tgt_pkwhere_parameters,"::","s.")),",0)")
  SET slogtypeselectsrc = concat(" v_log_type = dm_rdds_log_type_src(",substring(2,(size(replace(
      table_info->tables[itableidx].cmp_pkwhere_parameters,"::","s."),1) - 1),replace(table_info->
     tables[itableidx].cmp_pkwhere_parameters,"::","s.")),",0)")
  SET scontextselecttgt = concat(" v_context_name = dm_rdds_log_type_tgt(",substring(2,(size(replace(
      table_info->tables[itableidx].tgt_pkwhere_parameters,"::","s."),1) - 1),replace(table_info->
     tables[itableidx].tgt_pkwhere_parameters,"::","s.")),",1)")
  SET scontextselectsrc = concat(" v_context_name = dm_rdds_log_type_src(",substring(2,(size(replace(
      table_info->tables[itableidx].cmp_pkwhere_parameters,"::","s."),1) - 1),replace(table_info->
     tables[itableidx].cmp_pkwhere_parameters,"::","s.")),",1)")
 ENDIF
 SET slogtypeselectsrc_3 = concat(" v_log_type = dm_rdds_log_type_src(",substring(2,(size(replace(
     table_info->tables[itableidx].cmp_pkwhere_parameters,"::","s."),1) - 1),replace(table_info->
    tables[itableidx].cmp_pkwhere_parameters,"::","s.")),",0)")
 SET scontextselectsrc_3 = concat(" v_context_name = dm_rdds_log_type_src(",substring(2,(size(replace
    (table_info->tables[itableidx].cmp_pkwhere_parameters,"::","s."),1) - 1),replace(table_info->
    tables[itableidx].cmp_pkwhere_parameters,"::","s.")),",1)")
 SET sselectlist = substring(2,size(sselectlist,1),sselectlist)
 SET sselectlist_3 = substring(2,size(sselectlist_3,1),sselectlist_3)
 IF (sselectlist > " ")
  SET slogtypeselecttgt = concat(slogtypeselecttgt,",")
  SET slogtypeselectsrc = concat(slogtypeselectsrc,",")
  SET slogtypeselectsrc_3 = concat(slogtypeselectsrc_3,",")
  SET scontextselecttgt = concat(scontextselecttgt,",")
  SET scontextselectsrc = concat(scontextselectsrc,",")
  SET scontextselectsrc_3 = concat(scontextselectsrc_3,",")
 ENDIF
 SET dm_err->eproc = "Creating source view"
 IF (iviewjoinind=0)
  SET ssql = concat("rdb asis(^create or replace view v_rdds_src_compare as ",char(10),"select ",char
   (10),trim(sviewselect,3),
   char(10),"   from ",table_info->tables[itableidx].table_name," t ",char(10),
   trim(stargetfilter,3),char(10),"	minus",char(10),"   select ",
   char(10),trim(sviewselecttrans,3),char(10),"   from ",table_info->tables[itableidx].table_name,
   sdblink," s ^) go")
 ELSE
  SET ssql = concat("rdb asis(^create or replace view v_rdds_translate as ",char(10),
   "select table_name, from_value, max(to_value) as to_value ",char(10),
   "from dm_merge_translate dmt ",
   char(10),"where dmt.env_source_id = ",cnvtstring(isrcenvid),char(10),
   "      and dmt.env_target_id = ",
   cnvtstring(itgtenvidmock),char(10),"      and dmt.table_name in (",stablenamestr,") ",
   char(10),"group by table_name, from_value ",char(10),"union ",char(10),
   "select table_name, to_value, max(from_value) ",char(10),"from dm_merge_translate",sdblink,
   " sdmt ",
   char(10),"where sdmt.env_source_id = ",cnvtstring(itgtenvidmock),char(10),
   "      and sdmt.env_target_id = ",
   cnvtstring(isrcenvid),char(10),"      and sdmt.table_name in (",stablenamestr,") ",
   char(10),"group by table_name, to_value","^) go")
  CALL parser(trim(ssql,3))
  SET ssql = concat("rdb asis(^create or replace view v_rdds_translate_2 as ",
   "select table_name, to_value, max(from_value) as from_value ","from dm_merge_translate dmt ",
   "where dmt.env_source_id = ",cnvtstring(isrcenvid),
   " and dmt.env_target_id = ",cnvtstring(itgtenvidmock)," and dmt.table_name in (",stablenamestr,
   ") ",
   "group by table_name, to_value ","union ",char(10),"select table_name, from_value, max(to_value) ",
   "from dm_merge_translate",
   sdblink," sdmt ","where sdmt.env_source_id = ",cnvtstring(itgtenvidmock),
   "      and sdmt.env_target_id = ",
   cnvtstring(isrcenvid),"      and sdmt.table_name in (",stablenamestr,") ",
   "group by table_name, from_value",
   "^) go")
  CALL parser(trim(ssql,3))
  SET ssql = concat("rdb asis(^create or replace view v_rdds_src_compare as ",char(10),"select ",char
   (10),trim(sviewselect,3),
   char(10),"   from ",table_info->tables[itableidx].table_name," t ",char(10),
   trim(stargetfilter,3),char(10),"	minus",char(10),"   select ",
   char(10),"   decode(v.to_value,NULL,decode(",spkcolumnname,",0,0, ","		decode(",
   smergedelete,",1,ts.",spkcolumnname,",-1)),v.to_value) ","   from ",
   table_info->tables[itableidx].table_name,sdblink," ts,",char(10),"        v_rdds_translate v",
   char(10),"   where ts.",spkcolumnname," = v.from_value (+) ",char(10),
   "^) go")
 ENDIF
 CALL parser(trim(ssql,3))
 IF (iviewjoinind=0)
  SET ssql = concat("rdb asis(^create or replace view v_rdds_tgt_compare as ",char(10),"   select ",
   char(10),trim(sviewselect,3),
   char(10),"   from ",table_info->tables[itableidx].table_name,sdblink," t ",
   char(10),trim(ssourcefilter,3),char(10),"	minus",char(10),
   "   select ",char(10),trim(replace(sviewselecttrans,"translate_src","translate_tgt"),3),char(10),
   "   from ",
   table_info->tables[itableidx].table_name," s ^) go")
 ELSE
  SET ssql = concat("rdb asis(^create or replace view v_rdds_tgt_compare as ",char(10),"   select ",
   char(10),trim(sviewselect,3),
   char(10),"   from ",table_info->tables[itableidx].table_name,sdblink," t ",
   char(10),trim(ssourcefilter,3),char(10),"	minus ","   select decode(v.from_value,NULL,decode(",
   spkcolumnname,",0,0, ","				decode(",smergedelete,",1,tt.",
   spkcolumnname,",-1)),v.from_value) ","   from ",table_info->tables[itableidx].table_name," tt,",
   "        v_rdds_translate_2 v",char(10),"   where tt.",spkcolumnname," = v.to_value (+) ",
   char(10),"^) go")
 ENDIF
 SET dm_err->eproc = "Creating the target view"
 CALL parser(ssql)
 SET ivalidobjind = check_sql_error("V_RDDS_TGT_COMPARE","VIEW")
 IF (ivalidobjind=0)
  SET dm_err->eproc = concat("V_RDDS_TGT_COMPARE"," view creation experienced a compile error.")
  SET dm_err->user_action =
  "This is a table level view so the view will be re-created for the next table"
  SET dm_err->err_ind = 0
  CALL disp_msg(" ",dm_err->logfile,0)
 ELSE
  SET dm_err->eproc = concat("V_RDDS_TGT_COMPARE"," view was created successfully.")
  CALL disp_msg(" ",dm_err->logfile,0)
 ENDIF
 SET ivalidobjind = check_sql_error("V_RDDS_TRANSLATE","VIEW")
 IF (ivalidobjind=0)
  SET dm_err->eproc = concat("V_RDDS_TRANSLATE"," view creation experienced a compile error.")
  SET dm_err->user_action =
  "This is a table level view so the view will be re-created for the next table"
  SET dm_err->err_ind = 0
  CALL disp_msg(" ",dm_err->logfile,0)
 ELSE
  SET dm_err->eproc = concat("V_RDDS_TRANSLATE"," view was created successfully.")
  CALL disp_msg(" ",dm_err->logfile,0)
 ENDIF
 SET ivalidobjind = check_sql_error("V_RDDS_SRC_COMPARE","VIEW")
 IF (ivalidobjind=0)
  SET dm_err->eproc = concat("V_RDDS_SRC_COMPARE"," view creation experienced a compile error.")
  SET dm_err->user_action =
  "This is a table level view so the view will be re-created for the next table"
  SET dm_err->err_ind = 0
  CALL disp_msg(" ",dm_err->logfile,0)
 ELSE
  SET dm_err->eproc = concat("V_RDDS_SRC_COMPARE"," view was created successfully.")
  CALL disp_msg(" ",dm_err->logfile,0)
 ENDIF
 EXECUTE oragen3 "v_rdds_tgt_compare"
 EXECUTE oragen3 "v_rdds_translate"
 EXECUTE oragen3 "v_rdds_src_compare"
 SET parser_buf_1_2->qual[1].line = concat('select into "NL:" ',slogtypeselecttgt,scontextselecttgt,
  replace(sselectlist,"::TRANSLATE","rdds_diff_translate_tgt"))
 SET parser_buf_1_2->qual[2].line = concat(" from ",table_info->tables[itableidx].table_name," s,")
 SET parser_buf_1_2->qual[3].line = "v_rdds_src_compare v where "
 SET parser_buf_1_2->qual[4].line = substring(5,(size(sviewjoin) - 1),sviewjoin)
 SET parser_buf_1_2->qual[5].line = "detail"
 SET parser_buf_1_2->qual[6].line = "iCnt = iCnt + 1"
 SET parser_buf_1_2->qual[7].line = "if (iCnt = 1)"
 SET parser_buf_1_2->qual[8].line = concat(
  "stat = alterlist(audit_info->audit_types[1].audit_values,",trim(cnvtstring((imaxerrors - 1)),3),
  ")")
 SET parser_buf_1_2->qual[9].line = "endif"
 SET parser_buf_1_2->qual[10].line = concat("if (iCnt < ",trim(cnvtstring(imaxerrors),3),")")
 SET parser_buf_1_2->qual[11].line = concat(
  "stat = alterlist(audit_info->audit_types[1].audit_values[iCnt].data_values,",trim(cnvtstring(
    icolumncnt),3),")")
 SET iidx = 12
 WHILE (iidx <= sdetailsectionidx_1_2)
  SET parser_buf_1_2->qual[iidx].line = replace(parser_buf_1_2->qual[iidx].line,"::STRUCTNAME",
   "tgt_column_value")
  SET iidx = (iidx+ 1)
 ENDWHILE
 SET parser_buf_1_2->qual[(sdetailsectionidx_1_2+ 1)].line = concat(
  "audit_info->audit_types[1].audit_values[iCnt].log_type = v_log_type ",
  " audit_info->audit_types[1].audit_values[iCnt].context_name = v_context_name")
 SET parser_buf_1_2->qual[(sdetailsectionidx_1_2+ 2)].line = concat("endif;if iCnt > ",trim(
   cnvtstring(imaxerrors),3))
 SET parser_buf_1_2->qual[(sdetailsectionidx_1_2+ 3)].line = replace(slogtypedetail,"::AUDIT","1")
 SET parser_buf_1_2->qual[(sdetailsectionidx_1_2+ 4)].line = " with nocounter go "
 SET dm_err->eproc = concat("Excuting audit 1 for ",table_info->tables[itableidx].table_name)
 SET nlogtypecnt = 0
 SET iidx = 0
 SET nsqllines = size(parser_buf_1_2->qual,5)
 SET iparsercnt = 1
 SET icnt = 0
 CALL echo(concat("TIMER:",table_info->tables[itableidx].table_name," AUDIT 1 STARTING ",format(
    cnvtdatetime(curdate,curtime2),"@SHORTDATETIME")))
 IF ((table_info->tables[itableidx].exclusion_flg != 1))
  IF (icontextauditind=0)
   IF (ioutputchglog=0)
    WHILE (iparsercnt <= nsqllines)
     CALL parser(parser_buf_1_2->qual[iparsercnt].line)
     SET iparsercnt = (iparsercnt+ 1)
    ENDWHILE
   ELSE
    CALL echo(concat(
      "Audit Type 1 will be excluded since the audit output is being limited by log type. ",format(
       cnvtdatetime(curdate,curtime2),"@SHORTDATETIME")))
   ENDIF
  ELSE
   CALL echo(concat(
     "Audit Type 1 will be excluded since the audit output is being limited by context name. ",format
     (cnvtdatetime(curdate,curtime2),"@SHORTDATETIME")))
  ENDIF
 ELSE
  CALL echo(concat(table_info->tables[itableidx].table_name," has been excluded from Audit Type 1 ",
    format(cnvtdatetime(curdate,curtime2),"@SHORTDATETIME")))
 ENDIF
 CALL echo(concat("TIMER:",table_info->tables[itableidx].table_name," AUDIT 1 FINISHED ",format(
    cnvtdatetime(curdate,curtime2),"@SHORTDATETIME")))
 IF (check_error(dm_err->eproc)=1)
  SET audit_info->audit_types[1].audit_msg = concat("ERROR:",dm_err->emsg)
  SET dm_err->emsg = audit_info->audit_types[1].audit_msg
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 0
 ENDIF
 SET audit_info->audit_types[1].audit_cnt = icnt
 IF (icnt < imaxerrors)
  SET stat = alterlist(audit_info->audit_types[1].audit_values,icnt)
 ENDIF
 SET audit_info->audit_types[2].audit_flg = 2
 SET audit_info->audit_types[2].audit_desc = "Rows in the source domain that are not in the target"
 SET slogtypewhereclause = concat(" dm_rdds_log_type_src(",substring(2,(size(replace(table_info->
     tables[itableidx].cmp_pkwhere_parameters,"::","s."),1) - 1),replace(table_info->tables[itableidx
    ].cmp_pkwhere_parameters,"::","s.")),",0) != ","'","**NO CHANGE LOG RECORD FOUND**",
  "'")
 SET scontextwhereclause = replace(s_where_clause,"d.context_name",concat("dm_rdds_log_type_src(",
   substring(2,(size(replace(table_info->tables[itableidx].cmp_pkwhere_parameters,"::","s."),1) - 1),
    replace(table_info->tables[itableidx].cmp_pkwhere_parameters,"::","s.")),",1)"))
 SET parser_buf_1_2->qual[1].line = concat('select into "NL:" ',slogtypeselectsrc,scontextselectsrc,
  replace(sselectlist,"::TRANSLATE","rdds_diff_translate_src"))
 SET parser_buf_1_2->qual[2].line = concat(" from ",table_info->tables[itableidx].table_name,sdblink,
  " s,")
 SET parser_buf_1_2->qual[3].line = "v_rdds_tgt_compare v where "
 IF (icontextauditind=1)
  SET parser_buf_1_2->qual[4].line = concat(scontextwhereclause," AND",slogtypewhereclause," AND ",
   substring(5,(size(sviewjoin) - 1),sviewjoin))
 ELSE
  IF (ioutputchglog=1)
   SET parser_buf_1_2->qual[4].line = concat(slogtypewhereclause," AND ",substring(5,(size(sviewjoin)
      - 1),sviewjoin))
  ELSE
   SET parser_buf_1_2->qual[4].line = substring(5,(size(sviewjoin) - 1),sviewjoin)
  ENDIF
 ENDIF
 SET parser_buf_1_2->qual[5].line = "detail"
 SET iidx = 12
 WHILE (iidx <= sdetailsectionidx_1_2)
  SET parser_buf_1_2->qual[iidx].line = replace(parser_buf_1_2->qual[iidx].line,"::STRUCTNAME",
   "src_column_value")
  SET iidx = (iidx+ 1)
 ENDWHILE
 SET parser_buf_1_2->qual[(sdetailsectionidx_1_2+ 1)].line = concat(
  "audit_info->audit_types[2].audit_values[iCnt].log_type = v_log_type ",
  " audit_info->audit_types[2].audit_values[iCnt].context_name = v_context_name")
 SET parser_buf_1_2->qual[(sdetailsectionidx_1_2+ 3)].line = replace(slogtypedetail,"::AUDIT","2")
 SET dm_err->eproc = concat("Excuting audit 2 for ",table_info->tables[itableidx].table_name)
 SET nlogtypecnt = 0
 SET iidx = 0
 SET nsqllines = size(parser_buf_1_2->qual,5)
 SET iparsercnt = 1
 SET icnt = 0
 CALL echo(concat("TIMER:",table_info->tables[itableidx].table_name," AUDIT 2 STARTING ",format(
    cnvtdatetime(curdate,curtime2),"@SHORTDATETIME")))
 IF ((table_info->tables[itableidx].exclusion_flg != 2))
  WHILE (iparsercnt <= nsqllines)
   CALL parser(replace(replace(parser_buf_1_2->qual[iparsercnt].line,"audit_types[1]",
      "audit_types[2]"),"tgt_column_value","src_column_value"))
   SET iparsercnt = (iparsercnt+ 1)
  ENDWHILE
 ELSE
  CALL echo(concat(table_info->tables[itableidx].table_name," has been excluded from Audit Type 2 ",
    format(cnvtdatetime(curdate,curtime2),"@SHORTDATETIME")))
 ENDIF
 CALL echo(concat("TIMER:",table_info->tables[itableidx].table_name," AUDIT 2 FINISHED ",format(
    cnvtdatetime(curdate,curtime2),"@SHORTDATETIME")))
 IF (check_error(dm_err->eproc)=1)
  SET audit_info->audit_types[2].audit_msg = concat("ERROR:",dm_err->emsg)
  SET dm_err->emsg = audit_info->audit_types[2].audit_msg
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 0
 ENDIF
 SET audit_info->audit_types[2].audit_cnt = icnt
 IF (icnt < imaxerrors)
  SET stat = alterlist(audit_info->audit_types[2].audit_values,icnt)
 ENDIF
 SET audit_info->audit_types[3].audit_flg = 3
 SET audit_info->audit_types[3].audit_desc = concat("Rows that are in the source and target but ",
  "have one or more attributes that don't match")
 IF (sversionfilter > "")
  SET sversionfilter = concat(sversionfilter," and ")
  SET sversionfilter = replace(sversionfilter,"::SYSDATE","cnvtdatetime(curdate, curtime3)")
  SET sversionfiltertgt = replace(sversionfilter,"::ALIAS","t.")
  SET sversionfiltersrc = replace(sversionfilter,"::ALIAS","s.")
 ELSE
  SET sversionfiltersrc = ""
  SET sversionfiltertgt = ""
 ENDIF
 IF (iviewjoinind=1
  AND smergedelete != "1")
  SET sfromjoin_3 = ", v_rdds_translate v "
  SET sjoin_3 = concat(" s.",spkcolumnname," = v.from_value and t.",spkcolumnname," = v.to_value ")
 ELSE
  SET sfromjoin_3 = ""
  SET sjoin_3 = trim(substring(5,(size(sjoin_3,1) - 4),sjoin_3),3)
 ENDIF
 IF (icolumncomparecnt > ipkcnt)
  SET parser_buf_3->qual[1].line = concat('select into "NL:" ',slogtypeselectsrc_3,
   scontextselectsrc_3)
  SET parser_buf_3->qual[2].line = replace(sselectlist_3,"::TRANSLATE","rdds_diff_translate_src")
  SET parser_buf_3->qual[3].line = concat("from ",table_info->tables[itableidx].table_name," t,")
  SET parser_buf_3->qual[4].line = concat(table_info->tables[itableidx].table_name,sdblink," s ",trim
   (sfromjoin_3,3)," where ",
   char(10),sversionfiltersrc,char(10),sversionfiltertgt,char(10))
  IF (icontextauditind=1)
   SET parser_buf_3->qual[5].line = concat(scontextwhereclause," AND",slogtypewhereclause," AND ",
    sjoin_3)
  ELSE
   IF (ioutputchglog=1)
    SET parser_buf_3->qual[5].line = concat(slogtypewhereclause," AND ",sjoin_3)
   ELSE
    SET parser_buf_3->qual[5].line = sjoin_3
   ENDIF
  ENDIF
  SET parser_buf_3->qual[6].line = " AND ( "
  SET parser_buf_3->qual[7].line = concat(substring(4,(size(scondition_3,1) - 3),scondition_3),")")
  SET parser_buf_3->qual[8].line = "detail"
  SET parser_buf_3->qual[9].line = "iCnt = iCnt + 1"
  SET parser_buf_3->qual[10].line = "cnt = 0"
  SET parser_buf_3->qual[11].line = "if (iCnt = 1)"
  SET parser_buf_3->qual[12].line = concat(
   "stat = alterlist(audit_info->audit_types[3].audit_values,",trim(cnvtstring((imaxerrors - 1)),3),
   ")")
  SET parser_buf_3->qual[13].line = "endif"
  SET parser_buf_3->qual[14].line = concat("if (iCnt < ",trim(cnvtstring(imaxerrors),3),")")
  SET parser_buf_3->qual[15].line = sdetailsectionpk_3
  SET parser_buf_3->qual[(ndetailnextidx_3+ 1)].line = concat(
   "audit_info->audit_types[3].audit_values[iCnt].log_type = v_log_type",
   "  audit_info->audit_types[3].audit_values[iCnt].context_name = v_context_name")
  SET parser_buf_3->qual[(ndetailnextidx_3+ 2)].line = " endif "
  SET parser_buf_3->qual[(ndetailnextidx_3+ 3)].line = "audit_info->audit_types[3].audit_cnt = iCnt"
  SET parser_buf_3->qual[(ndetailnextidx_3+ 4)].line = replace(slogtypedetail,"::AUDIT","3")
  SET parser_buf_3->qual[(ndetailnextidx_3+ 5)].line = "  with nocounter go"
  SET dm_err->eproc = concat("Excuting audit 3 for ",table_info->tables[itableidx].table_name)
  SET nlogtypecnt = 0
  SET iidx = 0
  SET nsqllines = size(parser_buf_3->qual,5)
  SET iparsercnt = 1
  SET icnt = 0
  SET cnt = 0
  CALL echo(concat("TIMER:",table_info->tables[itableidx].table_name," AUDIT 3 STARTING ",format(
     cnvtdatetime(curdate,curtime2),"@SHORTDATETIME")))
  IF ((table_info->tables[itableidx].exclusion_flg != 3))
   CALL echo(concat("sVersionFilter : ",sversionfilter))
   CALL echo(concat("sVersionFilterSrc :",sversionfiltersrc))
   CALL echo(concat("sVersionFilterTgt :",sversionfiltertgt))
   WHILE (iparsercnt <= nsqllines)
    CALL parser(parser_buf_3->qual[iparsercnt].line)
    SET iparsercnt = (iparsercnt+ 1)
   ENDWHILE
  ELSE
   CALL echo(concat(table_info->tables[itableidx].table_name," has been excluded from Audit Type 3 ",
     format(cnvtdatetime(curdate,curtime2),"@SHORTDATETIME")))
  ENDIF
  CALL echo(concat("TIMER:",table_info->tables[itableidx].table_name," AUDIT 3 FINISHED ",format(
     cnvtdatetime(curdate,curtime2),"@SHORTDATETIME")))
  IF (check_error(dm_err->eproc)=1)
   SET audit_info->audit_types[3].audit_msg = concat("ERROR:",dm_err->emsg)
   SET dm_err->emsg = audit_info->audit_types[3].audit_msg
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   SET dm_err->err_ind = 0
  ENDIF
 ENDIF
 IF (icnt < imaxerrors)
  SET stat = alterlist(audit_info->audit_types[3].audit_values,icnt)
 ENDIF
END GO
