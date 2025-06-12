CREATE PROGRAM bhs_athn_read_nomen_by_filter
 FREE RECORD result
 RECORD result(
   1 items[*]
     2 nomenclature_id = f8
     2 source_string = vc
     2 source_identifier = vc
     2 principle_type_cd = f8
     2 principle_type_disp = vc
     2 source_vocabulary_cd = f8
     2 source_vocabulary_disp = vc
     2 vocab_axis_cd = f8
     2 vocab_axis_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD nomenclatures
 RECORD nomenclatures(
   1 items[*]
     2 nomenclature_id = f8
     2 source_string = vc
     2 source_identifier = vc
     2 principle_type_cd = f8
     2 principle_type_disp = vc
     2 source_vocabulary_cd = f8
     2 source_vocabulary_disp = vc
     2 vocab_axis_cd = f8
     2 vocab_axis_disp = vc
 ) WITH protect
 FREE RECORD vocabularies
 RECORD vocabularies(
   1 vocabularycnt = i4
   1 list[*]
     2 value = f8
     2 meaning = vc
 ) WITH protect
 FREE RECORD req963000
 RECORD req963000(
   1 vocabularies[*]
     2 source_vocabulary_cd = f8
   1 principletypes[*]
     2 principle_type_cd = f8
   1 vocabularycnt = i2
   1 principletypecnt = i2
   1 all_ind = i2
   1 max_items = i2
   1 namestring = c200
   1 codestring = c200
   1 compare_dt_tm = dq8
   1 vocab_axis_cnt = i2
   1 vocab_axis[*]
     2 vocab_axis_cd = f8
   1 primary_vterm_ind = i2
   1 force_disallowed_ind = i2
 ) WITH protect
 FREE RECORD rep963000
 RECORD rep963000(
   1 item_cnt = i2
   1 items[*]
     2 active_ind = i2
     2 data_status_cd = f8
     2 source_string = vc
     2 string_identifier = vc
     2 source_identifier = vc
     2 concept_identifier = vc
     2 concept_source_cd = f8
     2 source_vocabulary_cd = f8
     2 source_vocabulary_disp = c40
     2 string_source_cd = f8
     2 string_source_disp = c40
     2 principle_type_cd = f8
     2 principle_type_disp = c40
     2 nomenclature_id = f8
     2 vocab_axis_cd = f8
     2 vocab_axis_disp = c40
     2 contributor_system_cd = f8
     2 contributor_system_disp = c40
     2 primary_vterm_ind = i2
     2 short_string = vc
     2 mnemonic = vc
     2 concept_cki = vc
   1 errormsg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req4174010
 RECORD req4174010(
   1 search_type_flag = i2
   1 preferred_type_flag = i2
   1 search_string = vc
   1 effective_dt_tm = dq8
   1 terminology_cds[*]
     2 terminology_cd = f8
   1 terminology_axis_cds[*]
     2 terminology_axis_cd = f8
   1 principle_type_cds[*]
     2 principle_type_cd = f8
   1 max_results = i2
   1 extensions[*]
     2 icd9
       3 age = f8
       3 gender = vc
     2 ignore_icd9_extension_ind = i2
     2 age = i4
     2 gender_flag = i2
     2 billable_flag = i2
   1 effective_flag = i2
   1 active_flag = i2
   1 local_time_zone = i4
 ) WITH protect
 FREE RECORD rep4174010
 RECORD rep4174010(
   1 nomenclatures[*]
     2 nomenclature_id = f8
     2 source_identifier = vc
     2 description = vc
     2 short_description = vc
     2 mnemonic = vc
     2 terminology_cd = f8
     2 terminology_axis_cd = f8
     2 principle_type_cd = f8
     2 language_cd = f8
     2 primary_vterm_ind = i2
     2 primary_cterm_ind = i2
     2 cki = vc
     2 active_ind = i2
     2 extensions[*]
       3 icd9[*]
         4 age = vc
         4 gender = vc
         4 billable = vc
       3 apc[*]
         4 minimum_unadjusted_coinsurance = f8
         4 national_unadjusted_coinsurance = f8
         4 payment_rate = f8
         4 status_indicator = vc
       3 drg[*]
         4 amlos = f8
         4 gmlos = f8
         4 drg_category = vc
         4 drg_weight = f8
         4 mdc_code = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 concept_identifier = vc
     2 concept_source_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req4174011
 RECORD req4174011(
   1 search_type_flag = i2
   1 preferred_type_flag = i2
   1 search_string = vc
   1 effective_dt_tm = dq8
   1 terminology_cds[*]
     2 terminology_cd = f8
   1 terminology_axis_cds[*]
     2 terminology_axis_cd = f8
   1 principle_type_cds[*]
     2 principle_type_cd = f8
   1 max_results = i2
   1 extensions[*]
     2 icd9
       3 age = f8
       3 gender = vc
     2 ignore_icd9_extension_ind = i2
     2 age = i4
     2 gender_flag = i2
     2 billable_flag = i2
   1 effective_flag = i2
   1 active_flag = i2
   1 local_time_zone = i4
 ) WITH protect
 FREE RECORD rep4174011
 RECORD rep4174011(
   1 nomenclatures[*]
     2 nomenclature_id = f8
     2 source_identifier = vc
     2 description = vc
     2 short_description = vc
     2 mnemonic = vc
     2 terminology_cd = f8
     2 terminology_axis_cd = f8
     2 principle_type_cd = f8
     2 language_cd = f8
     2 primary_vterm_ind = i2
     2 primary_cterm_ind = i2
     2 cki = vc
     2 active_ind = i2
     2 extensions[*]
       3 icd9[*]
         4 age = vc
         4 gender = vc
         4 billable = vc
       3 apc[*]
         4 minimum_unadjusted_coinsurance = f8
         4 national_unadjusted_coinsurance = f8
         4 payment_rate = f8
         4 status_indicator = vc
       3 drg[*]
         4 amlos = f8
         4 gmlos = f8
         4 drg_category = vc
         4 drg_weight = f8
         4 mdc_code = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 concept_identifier = vc
     2 concept_source_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callallergysearch(null) = i4
 DECLARE callgetnomenbydesc(null) = i4
 DECLARE callgetnomenbysourceid(null) = i4
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE itemcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE app_tz = i4 WITH protect, constant(evaluate(curutc,1,curtimezoneapp,0))
 SET result->status_data.status = "F"
 FREE RECORD req_format_str
 RECORD req_format_str(
   1 param = vc
 ) WITH protect
 FREE RECORD rep_format_str
 RECORD rep_format_str(
   1 param = vc
 ) WITH protect
 IF (textlen(trim( $2,3)))
  SET req_format_str->param =  $2
  EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
   "REP_FORMAT_STR")
  SET convnamestring = nullterm(trim(rep_format_str->param,3))
 ENDIF
 IF (textlen(trim( $3,3)))
  SET req_format_str->param =  $3
  EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
   "REP_FORMAT_STR")
  SET convcodestring = nullterm(trim(rep_format_str->param,3))
 ENDIF
 IF (textlen(trim( $2,3)) <= 0
  AND textlen(trim( $3,3)) <= 0)
  CALL echo("INVALID SEARCH STRING...EXITING")
  GO TO exit_script
 ELSEIF (cnvtint( $5) <= 0)
  CALL echo("INVALID MAX ITEMS PARAMTER...EXITING")
  GO TO exit_script
 ELSEIF (((cnvtint( $6) <= 0) OR (cnvtint( $6) > 2)) )
  CALL echo("INVALID MODE PARAMTER...EXITING")
  GO TO exit_script
 ENDIF
 DECLARE sourcevocabparam = vc WITH protect, noconstant("")
 DECLARE startpos = i4 WITH protect, noconstant(0)
 DECLARE endpos = i4 WITH protect, noconstant(0)
 DECLARE param = vc WITH protect, noconstant("")
 DECLARE source_vocabulary_cd = f8 WITH protect, noconstant(0.0)
 IF (textlen(trim( $4,3)) > 0)
  SET startpos = 1
  SET sourcevocabparam = trim( $4,3)
  CALL echo(build2("SOURCEVOCABPARAM IS: ",sourcevocabparam))
  WHILE (size(sourcevocabparam) > 0)
    SET endpos = (findstring(";",sourcevocabparam,1) - 1)
    IF (endpos <= 0)
     SET endpos = size(sourcevocabparam)
    ENDIF
    CALL echo(build("ENDPOS:",endpos))
    IF (startpos < endpos)
     SET param = substring(1,endpos,sourcevocabparam)
     CALL echo(build("PARAM:",param))
     SET vocabularies->vocabularycnt += 1
     SET stat = alterlist(vocabularies->list,vocabularies->vocabularycnt)
     SET vocabularies->list[vocabularies->vocabularycnt].meaning = trim(param,3)
    ENDIF
    SET sourcevocabparam = substring((endpos+ 2),(size(sourcevocabparam) - endpos),sourcevocabparam)
    CALL echo(build("SOURCEVOCABPARAM:",sourcevocabparam))
    CALL echo(build("SIZE(SOURCEVOCABPARAM):",size(sourcevocabparam)))
  ENDWHILE
  FOR (idx = 1 TO vocabularies->vocabularycnt)
    SET source_vocabulary_cd = uar_get_code_by("MEANING",400,vocabularies->list[idx].meaning)
    IF (source_vocabulary_cd <= 0.0)
     CALL echo("INVALID SOURCE VOCABULARY PARAMETER...EXITING")
     GO TO exit_script
    ENDIF
    SET vocabularies->list[idx].value = source_vocabulary_cd
  ENDFOR
 ENDIF
 IF (cnvtint( $6)=1)
  SET stat = callallergysearch(null)
  IF (stat=fail)
   GO TO exit_script
  ENDIF
 ELSEIF (cnvtint( $6)=2)
  IF (textlen(trim( $2,3)) > 0)
   SET stat = callgetnomenbydesc(null)
  ELSE
   SET stat = callgetnomenbysourceid(null)
  ENDIF
  IF (stat=fail)
   GO TO exit_script
  ENDIF
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v0 = vc WITH protect, noconstant("")
  DECLARE v1 = vc WITH protect, noconstant("")
  DECLARE v2 = vc WITH protect, noconstant("")
  DECLARE v3 = vc WITH protect, noconstant("")
  DECLARE v4 = vc WITH protect, noconstant("")
  DECLARE v5 = vc WITH protect, noconstant("")
  DECLARE v6 = vc WITH protect, noconstant("")
  DECLARE v7 = vc WITH protect, noconstant("")
  DECLARE v8 = vc WITH protect, noconstant("")
  DECLARE v9 = vc WITH protect, noconstant("")
  DECLARE v10 = vc WITH protect, noconstant("")
  DECLARE v11 = vc WITH protect, noconstant("")
  DECLARE v12 = vc WITH protect, noconstant("")
  SELECT INTO value(moutputdevice)
   FROM (dummyt d  WITH seq = value(1))
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v0 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v0, row + 1
   DETAIL
    col + 1, "<Nomenclatures>", row + 1
    FOR (idx = 1 TO size(result->items,5))
      col + 1, "<Nomenclature>", row + 1,
      v1 = build("<NomenclatureId>",cnvtint(result->items[idx].nomenclature_id),"</NomenclatureId>"),
      col + 1, v1,
      row + 1, v2 = build("<SourceString>",trim(replace(replace(replace(replace(replace(result->
             items[idx].source_string,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
         "&quot;",0),3),"</SourceString>"), col + 1,
      v2, row + 1, v3 = build("<SourceIdentifier>",trim(replace(replace(replace(replace(replace(
             result->items[idx].source_identifier,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
          "&apos;",0),'"',"&quot;",0),3),"</SourceIdentifier>"),
      col + 1, v3, row + 1,
      col + 1, "<PrincipleType>", row + 1,
      v4 = build("<Display>",trim(replace(replace(replace(replace(replace(result->items[idx].
             principle_type_disp,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
         "&quot;",0),3),"</Display>"), col + 1, v4,
      row + 1, v5 = build("<Meaning>",trim(replace(replace(replace(replace(replace(trim(
              uar_get_code_meaning(result->items[idx].principle_type_cd),3),"&","&amp;",0),"<","&lt;",
            0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Meaning>"), col + 1,
      v5, row + 1, v6 = build("<Value>",cnvtint(result->items[idx].principle_type_cd),"</Value>"),
      col + 1, v6, row + 1,
      col + 1, "</PrincipleType>", row + 1,
      col + 1, "<SourceVocabulary>", row + 1,
      v7 = build("<Display>",trim(replace(replace(replace(replace(replace(result->items[idx].
             source_vocabulary_disp,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
         "&quot;",0),3),"</Display>"), col + 1, v7,
      row + 1, v8 = build("<Meaning>",trim(replace(replace(replace(replace(replace(trim(
              uar_get_code_meaning(result->items[idx].source_vocabulary_cd),3),"&","&amp;",0),"<",
            "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Meaning>"), col + 1,
      v8, row + 1, v9 = build("<Value>",cnvtint(result->items[idx].source_vocabulary_cd),"</Value>"),
      col + 1, v9, row + 1,
      col + 1, "</SourceVocabulary>", row + 1,
      col + 1, "<VocabularyAxis>", row + 1,
      v10 = build("<Display>",trim(replace(replace(replace(replace(replace(result->items[idx].
             vocab_axis_disp,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
         0),3),"</Display>"), col + 1, v10,
      row + 1, v11 = build("<Meaning>",trim(replace(replace(replace(replace(replace(trim(
              uar_get_code_meaning(result->items[idx].vocab_axis_cd),3),"&","&amp;",0),"<","&lt;",0),
           ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Meaning>"), col + 1,
      v11, row + 1, v12 = build("<Value>",cnvtint(result->items[idx].vocab_axis_cd),"</Value>"),
      col + 1, v12, row + 1,
      col + 1, "</VocabularyAxis>", row + 1,
      col + 1, "</Nomenclature>", row + 1
    ENDFOR
    col + 1, "</Nomenclatures>", row + 1
   FOOT REPORT
    col + 1, "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req963000
 FREE RECORD rep963000
 FREE RECORD req4174010
 FREE RECORD rep4174010
 FREE RECORD req4174011
 FREE RECORD rep4174011
 FREE RECORD vocabularies
 FREE RECORD nomenclatures
 SUBROUTINE callallergysearch(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(963000)
   DECLARE requestid = i4 WITH protect, constant(963000)
   IF (textlen(trim( $2,3)) > 0)
    SET req963000->namestring = trim(convnamestring,3)
   ELSE
    SET req963000->codestring = trim(convcodestring,3)
   ENDIF
   IF ((vocabularies->vocabularycnt > 0))
    SET req963000->vocabularycnt = vocabularies->vocabularycnt
    SET stat = alterlist(req963000->vocabularies,req963000->vocabularycnt)
    FOR (idx = 1 TO vocabularies->vocabularycnt)
      SET req963000->vocabularies[idx].source_vocabulary_cd = vocabularies->list[idx].value
    ENDFOR
   ENDIF
   SET req963000->max_items = cnvtint( $5)
   SET req963000->compare_dt_tm = cnvtdatetime(sysdate)
   SET req963000->force_disallowed_ind = 1
   CALL echorecord(req963000)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req963000,
    "REC",rep963000,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep963000)
   IF ((rep963000->status_data.status="S"))
    SET stat = alterlist(result->items,size(rep963000->items,5))
    FOR (idx = 1 TO size(rep963000->items,5))
      IF ((rep963000->items[idx].active_ind=1))
       SET itemcnt += 1
       SET result->items[itemcnt].nomenclature_id = rep963000->items[idx].nomenclature_id
       SET result->items[itemcnt].source_string = rep963000->items[idx].source_string
       SET result->items[itemcnt].source_identifier = rep963000->items[idx].source_identifier
       SET result->items[itemcnt].principle_type_cd = rep963000->items[idx].principle_type_cd
       SET result->items[itemcnt].principle_type_disp = rep963000->items[idx].principle_type_disp
       SET result->items[itemcnt].source_vocabulary_cd = rep963000->items[idx].source_vocabulary_cd
       SET result->items[itemcnt].source_vocabulary_disp = rep963000->items[idx].
       source_vocabulary_disp
       SET result->items[itemcnt].vocab_axis_cd = rep963000->items[idx].vocab_axis_cd
       SET result->items[itemcnt].vocab_axis_disp = rep963000->items[idx].vocab_axis_disp
      ENDIF
    ENDFOR
    SET stat = alterlist(result->items,itemcnt)
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE callgetnomenbydesc(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(4171505)
   DECLARE requestid = i4 WITH protect, constant(4174010)
   SET req4174010->search_type_flag = 3
   SET req4174010->preferred_type_flag = 1
   SET req4174010->search_string = trim(convnamestring,3)
   IF ((vocabularies->vocabularycnt > 0))
    SET stat = alterlist(req4174010->terminology_cds,vocabularies->vocabularycnt)
    FOR (idx = 1 TO vocabularies->vocabularycnt)
      SET req4174010->terminology_cds[idx].terminology_cd = vocabularies->list[idx].value
    ENDFOR
   ENDIF
   SET req4174010->max_results = (cnvtint( $5) - 1)
   SET stat = alterlist(req4174010->extensions,1)
   SET req4174010->extensions[1].icd9.age = - (1)
   SET req4174010->extensions[1].ignore_icd9_extension_ind = 1
   SET req4174010->extensions[1].age = 15954
   SET req4174010->extensions[1].gender_flag = 2
   SET req4174010->local_time_zone = app_tz
   CALL echorecord(req4174010)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req4174010,
    "REC",rep4174010,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep4174010)
   IF ((rep4174010->status_data.status="S"))
    SET stat = alterlist(nomenclatures->items,size(rep4174010->nomenclatures,5))
    FOR (idx = 1 TO size(rep4174010->nomenclatures,5))
      IF ((rep4174010->nomenclatures[idx].active_ind=1))
       SET itemcnt += 1
       SET nomenclatures->items[itemcnt].nomenclature_id = rep4174010->nomenclatures[idx].
       nomenclature_id
       SET nomenclatures->items[itemcnt].source_string = rep4174010->nomenclatures[idx].description
       SET nomenclatures->items[itemcnt].source_identifier = rep4174010->nomenclatures[idx].
       source_identifier
       SET nomenclatures->items[itemcnt].principle_type_cd = rep4174010->nomenclatures[idx].
       principle_type_cd
       SET nomenclatures->items[itemcnt].principle_type_disp = uar_get_code_display(rep4174010->
        nomenclatures[idx].principle_type_cd)
       SET nomenclatures->items[itemcnt].source_vocabulary_cd = rep4174010->nomenclatures[idx].
       terminology_cd
       SET nomenclatures->items[itemcnt].source_vocabulary_disp = uar_get_code_display(rep4174010->
        nomenclatures[idx].terminology_cd)
       SET nomenclatures->items[itemcnt].vocab_axis_cd = rep4174010->nomenclatures[idx].
       terminology_axis_cd
       SET nomenclatures->items[itemcnt].vocab_axis_disp = uar_get_code_display(rep4174010->
        nomenclatures[idx].terminology_axis_cd)
      ENDIF
    ENDFOR
    SET stat = alterlist(nomenclatures->items,itemcnt)
    SET stat = sortresults(1)
    RETURN(stat)
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE callgetnomenbysourceid(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(4171505)
   DECLARE requestid = i4 WITH protect, constant(4174011)
   SET req4174011->search_type_flag = 1
   SET req4174011->preferred_type_flag = 1
   SET req4174011->search_string = trim(convcodestring,3)
   IF ((vocabularies->vocabularycnt > 0))
    SET stat = alterlist(req4174011->terminology_cds,vocabularies->vocabularycnt)
    FOR (idx = 1 TO vocabularies->vocabularycnt)
      SET req4174011->terminology_cds[idx].terminology_cd = vocabularies->list[idx].value
    ENDFOR
   ENDIF
   SET req4174011->max_results = (cnvtint( $5) - 1)
   SET stat = alterlist(req4174011->extensions,1)
   SET req4174011->extensions[1].icd9.age = - (1)
   SET req4174011->extensions[1].ignore_icd9_extension_ind = 1
   SET req4174011->extensions[1].age = 15954
   SET req4174011->extensions[1].gender_flag = 2
   SET req4174011->local_time_zone = app_tz
   CALL echorecord(req4174011)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req4174011,
    "REC",rep4174011,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep4174011)
   IF ((rep4174011->status_data.status="S"))
    SET stat = alterlist(nomenclatures->items,size(rep4174011->nomenclatures,5))
    FOR (idx = 1 TO size(rep4174011->nomenclatures,5))
      IF ((rep4174011->nomenclatures[idx].active_ind=1))
       SET itemcnt += 1
       SET nomenclatures->items[itemcnt].nomenclature_id = rep4174011->nomenclatures[idx].
       nomenclature_id
       SET nomenclatures->items[itemcnt].source_string = rep4174011->nomenclatures[idx].description
       SET nomenclatures->items[itemcnt].source_identifier = rep4174011->nomenclatures[idx].
       source_identifier
       SET nomenclatures->items[itemcnt].principle_type_cd = rep4174011->nomenclatures[idx].
       principle_type_cd
       SET nomenclatures->items[itemcnt].principle_type_disp = uar_get_code_display(rep4174011->
        nomenclatures[idx].principle_type_cd)
       SET nomenclatures->items[itemcnt].source_vocabulary_cd = rep4174011->nomenclatures[idx].
       terminology_cd
       SET nomenclatures->items[itemcnt].source_vocabulary_disp = uar_get_code_display(rep4174011->
        nomenclatures[idx].terminology_cd)
       SET nomenclatures->items[itemcnt].vocab_axis_cd = rep4174011->nomenclatures[idx].
       terminology_axis_cd
       SET nomenclatures->items[itemcnt].vocab_axis_disp = uar_get_code_display(rep4174011->
        nomenclatures[idx].terminology_axis_cd)
      ENDIF
    ENDFOR
    SET stat = alterlist(nomenclatures->items,itemcnt)
    SET stat = sortresults(2)
    RETURN(stat)
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE (sortresults(mode=i2) =i4)
   DECLARE resultcnt = i4 WITH protect, noconstant(0)
   IF (size(nomenclatures->items,5) > 0)
    SET stat = alterlist(result->items,size(nomenclatures->items,5))
    SELECT INTO "NL:"
     sortkey = evaluate(mode,1,cnvtupper(nomenclatures->items[d.seq].source_string),cnvtupper(
       nomenclatures->items[d.seq].source_identifier))
     FROM (dummyt d  WITH seq = size(nomenclatures->items,5))
     PLAN (d
      WHERE d.seq > 0)
     ORDER BY sortkey
     DETAIL
      resultcnt += 1, result->items[resultcnt].nomenclature_id = nomenclatures->items[d.seq].
      nomenclature_id, result->items[resultcnt].source_string = nomenclatures->items[d.seq].
      source_string,
      result->items[resultcnt].source_identifier = nomenclatures->items[d.seq].source_identifier,
      result->items[resultcnt].principle_type_cd = nomenclatures->items[d.seq].principle_type_cd,
      result->items[resultcnt].principle_type_disp = nomenclatures->items[d.seq].principle_type_disp,
      result->items[resultcnt].source_vocabulary_cd = nomenclatures->items[d.seq].
      source_vocabulary_cd, result->items[resultcnt].source_vocabulary_disp = nomenclatures->items[d
      .seq].source_vocabulary_disp, result->items[resultcnt].vocab_axis_cd = nomenclatures->items[d
      .seq].vocab_axis_cd,
      result->items[resultcnt].vocab_axis_disp = nomenclatures->items[d.seq].vocab_axis_disp
     WITH nocounter, time = 30
    ;end select
   ENDIF
   RETURN(success)
 END ;Subroutine
END GO
