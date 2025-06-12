CREATE PROGRAM auto_corsp_create:dba
 IF (validate(stat)=0)
  DECLARE stat = i4 WITH protect
 ENDIF
 IF (validate(cv_log_stat_cnt)=0)
  DECLARE cv_log_stat_cnt = i4
  DECLARE cv_log_msg_cnt = i4
  DECLARE cv_debug = i2 WITH constant(4)
  DECLARE cv_info = i2 WITH constant(3)
  DECLARE cv_audit = i2 WITH constant(2)
  DECLARE cv_warning = i2 WITH constant(1)
  DECLARE cv_error = i2 WITH constant(0)
  DECLARE cv_log_levels[5] = c8
  SET cv_log_levels[1] = "ERROR  :"
  SET cv_log_levels[2] = "WARNING:"
  SET cv_log_levels[3] = "AUDIT  :"
  SET cv_log_levels[4] = "INFO   :"
  SET cv_log_levels[5] = "DEBUG  :"
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime("31-DEC-2100 00:00:00"))
  DECLARE null_f8 = f8 WITH protect, noconstant(0.000001)
  DECLARE cv_log_error_file = i4 WITH noconstant(0)
  IF (currdbname IN ("PROV", "SOLT", "SURD"))
   SET cv_log_error_file = 1
  ENDIF
  DECLARE cv_err_msg = vc WITH noconstant(fillstring(128," "))
  DECLARE cv_log_file_name = vc WITH noconstant(build("cer_temp:CV_DEFAULT",cnvtstring(curtime2),
    ".dat"))
  DECLARE cv_log_error_string = vc WITH noconstant(fillstring(32000," "))
  DECLARE cv_log_error_string_cnt = i4
  CALL cv_log_msg(cv_info,"CV_LOG_MSG version: 002 10/16/08 AR012547")
 ENDIF
 CALL cv_log_msg(cv_info,concat("*** Entering ",curprog," at ",format(cnvtdatetime(sysdate),
    "@SHORTDATETIME")))
 IF (validate(request)=1
  AND (reqdata->loglevel >= cv_info))
  IF (cv_log_error_file=1)
   CALL echorecord(request,cv_log_file_name,1)
  ENDIF
  CALL echorecord(request)
 ENDIF
 SUBROUTINE (cv_log_stat(log_lev=i2,op_name=vc,op_stat=c1,obj_name=vc,obj_value=vc) =null)
   SET cv_log_stat_cnt = (size(reply->status_data.subeventstatus,5)+ 1)
   SET stat = alterlist(reply->status_data.subeventstatus,cv_log_stat_cnt)
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationstatus = op_stat
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectname = obj_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectvalue = obj_value
   IF ((reqdata->loglevel >= log_lev))
    CALL cv_log_msg(log_lev,build("Subevent:",nullterm(op_name),"=",nullterm(op_stat),"::",
      nullterm(obj_name),"::",obj_value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg(log_lev=i2,the_message=vc(byval)) =null)
   IF ((reqdata->loglevel >= log_lev))
    SET cv_err_msg = fillstring(128," ")
    SET cv_err_msg = concat("**",nullterm(cv_log_levels[(log_lev+ 1)]),trim(the_message)," at :",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME"))
    CALL echo(cv_err_msg)
    IF (cv_log_error_file=1)
     SET cv_log_error_string_cnt += 1
     SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg_post(script_vrsn=vc) =null)
  IF ((reqdata->loglevel >= cv_info))
   IF (validate(reply))
    IF (cv_log_error_file=1
     AND validate(request)=1)
     CALL echorecord(request,cv_log_file_name,1)
    ENDIF
    CALL echorecord(reply)
   ENDIF
   CALL cv_log_msg(cv_info,concat("*** Leaving ",curprog," version:",script_vrsn," at ",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME")))
  ENDIF
  IF (cv_log_error_string_cnt > 0)
   CALL cv_log_msg(cv_info,concat("*** The Error Log File is: ",cv_log_file_name))
   EXECUTE cv_log_flush_message
   SET cv_log_msg_cnt = 0
  ENDIF
 END ;Subroutine
 IF (validate(reply->status_data.status)=0)
  FREE SET reply
  RECORD reply(
    1 note = vc
    1 template_name = vc
    1 status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 FREE SET create_internal
 RECORD create_internal(
   1 template = vc
   1 tag[*]
     2 start_pos = i4
     2 stop_pos = i4
     2 tag_cd = f8
     2 tag_mean = vc
     2 tag_replace = vc
     2 status_flag = i2
 ) WITH protect
 DECLARE etagstatus_success = i4 WITH constant(1)
 DECLARE etagstatus_fail = i4 WITH constant(2)
 DECLARE etagstatus_failoption = i4 WITH constant(3)
 DECLARE c_encntr_alias_type_mrn = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 FREE RECORD empty_tags
 RECORD empty_tags(
   1 empty[*]
     2 tag_cd = f8
     2 default_val = vc
 ) WITH protect
 FREE RECORD memos
 RECORD memos(
   1 memo_cnt = i4
   1 memo[*]
     2 tag_mean = vc
     2 tag_value = vc
     2 tag_status = i2
 ) WITH protect
 DECLARE memo_cnt = i4 WITH protect
 DECLARE memo_idx = i4 WITH protect
 DECLARE addmemomean(p_tag_mean=vc,p_tag_value=vc,p_tag_status=i2) = i4
 DECLARE addsummarymemo(null) = null
 DECLARE c_tag_codeset = i4 WITH constant(4001916), protect
 DECLARE c_delim_codeset = i4 WITH constant(4001915), protect
 DECLARE tag_cnt = i4 WITH protect
 DECLARE tag_idx = i4 WITH protect
 DECLARE tag_str = vc WITH protect, noconstant(fillstring(255," "))
 DECLARE tag_stat = i2 WITH protect
 DECLARE tag_type = i2 WITH protect
 DECLARE empty_cnt = i4 WITH protect
 DECLARE empty_idx = i4 WITH protect
 DECLARE empty_pad = i4 WITH protect
 DECLARE c_block_size = i4 WITH protect, constant(20)
 DECLARE block_start = i4 WITH protect, noconstant(1)
 DECLARE note_pos = i4 WITH protect
 DECLARE move_size = i4 WITH protect
 DECLARE note_str = vc WITH noconstant(fillstring(32000,"*"))
 SELECT INTO "nl:"
  FROM clinical_note_template nt,
   long_blob lb
  PLAN (nt
   WHERE (nt.template_id=request->template_id)
    AND nt.long_blob_id > 0.0)
   JOIN (lb
   WHERE lb.long_blob_id=nt.long_blob_id)
  DETAIL
   reply->template_name = nullterm(trim(nt.template_name)), create_internal->template = nullterm(trim
    (lb.long_blob))
  WITH nocounter
 ;end select
 SET stat = parsetemplate(tag_cnt)
 IF (stat=1)
  CALL cv_log_stat(cv_warning,"CALL","F","ParseTemplate",build("stat=",stat))
  GO TO exit_script
 ENDIF
 CALL initializememo(null)
 IF (tag_cnt > 0)
  CALL cv_log_msg(cv_debug,"Performing tag lookups")
  FOR (tag_idx = 1 TO tag_cnt)
    SET memo_idx = evaluatetag(tag_idx)
    IF (memo_idx=0)
     SET tag_stat = etagstatus_fail
    ELSE
     SET tag_stat = memos->memo[memo_idx].tag_status
     SET tag_str = memos->memo[memo_idx].tag_value
    ENDIF
    SET create_internal->tag[tag_idx].status_flag = tag_stat
    IF (tag_stat=etagstatus_success)
     SET create_internal->tag[tag_idx].tag_replace = tag_str
    ELSE
     CALL addempty(create_internal->tag[tag_idx].tag_cd)
    ENDIF
  ENDFOR
  IF (empty_cnt > 0)
   CALL cv_log_msg(cv_debug,"Populating tags with defaults")
   FOR (empty_idx = (empty_cnt+ 1) TO empty_pad)
     SET empty_tags->empty[empty_idx].tag_cd = empty_tags->empty[empty_cnt].tag_cd
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((empty_pad/ c_block_size))),
     code_value_extension cve
    PLAN (d
     WHERE assign(block_start,evaluate(d.seq,1,1,(block_start+ c_block_size))))
     JOIN (cve
     WHERE expand(empty_idx,block_start,((block_start+ c_block_size) - 1),cve.code_value,empty_tags->
      empty[empty_idx].tag_cd)
      AND cve.field_name IN ("DEFAULT", "OPTIONAL"))
    ORDER BY cve.code_value
    HEAD cve.code_value
     l_optional_ind = 0, l_replace_ind = 1, l_replace_string = fillstring(100," ")
    DETAIL
     CASE (cve.field_name)
      OF "OPTIONAL":
       IF (cve.field_value="Y")
        l_optional_ind = 1
       ENDIF
      OF "DEFAULT":
       IF (size(trim(cve.field_value)) > 0)
        l_replace_string = trim(cve.field_value), l_replace_ind = 1
       ENDIF
     ENDCASE
    FOOT  cve.code_value
     tag_idx = locateval(tag_idx,1,tag_cnt,cve.code_value,create_internal->tag[tag_idx].tag_cd)
     WHILE (tag_idx > 0)
       IF (l_replace_ind=1)
        create_internal->tag[tag_idx].tag_replace = cve.field_value
       ENDIF
       IF (l_optional_ind=1)
        create_internal->tag[tag_idx].status_flag = etagstatus_failoption
       ENDIF
       tag_idx = locateval(tag_idx,(tag_idx+ 1),tag_cnt,cve.code_value,create_internal->tag[tag_idx].
        tag_cd)
     ENDWHILE
    WITH nocounter
   ;end select
  ENDIF
  CALL cv_log_msg(cv_debug,"Creating note text from template and tags")
  SET note_pos = (1+ movestring(create_internal->template,1,note_str,1,(create_internal->tag[1].
   start_pos - 1)))
  SET note_pos = 1
  FOR (tag_idx = 1 TO tag_cnt)
    IF (tag_idx=1)
     SET move_size = (create_internal->tag[tag_idx].start_pos - 1)
    ELSE
     SET move_size = ((create_internal->tag[tag_idx].start_pos - create_internal->tag[(tag_idx - 1)].
     stop_pos) - 1)
    ENDIF
    IF (move_size > 0)
     SET note_pos += movestring(create_internal->template,(create_internal->tag[tag_idx].start_pos -
      move_size),note_str,note_pos,move_size)
    ENDIF
    SET move_size = size(create_internal->tag[tag_idx].tag_replace)
    IF (move_size > 0)
     SET note_pos += movestring(create_internal->tag[tag_idx].tag_replace,1,note_str,note_pos,
      move_size)
    ENDIF
  ENDFOR
  SET move_size = (size(create_internal->template) - create_internal->tag[tag_cnt].stop_pos)
  IF (move_size > 0)
   SET note_pos += movestring(create_internal->template,(create_internal->tag[tag_cnt].stop_pos+ 1),
    note_str,note_pos,move_size)
  ENDIF
  SET reply->note = substring(1,(note_pos - 1),note_str)
  SET tag_idx = locateval(tag_idx,1,tag_cnt,2,create_internal->tag[tag_idx].status_flag)
  IF (tag_idx > 0)
   SET reply->status_flag = 2
  ELSE
   SET reply->status_flag = 1
  ENDIF
 ELSE
  CALL cv_log_msg(cv_info,"No tags found")
  SET reply->note = create_internal->template
  SET reply->status_flag = 1
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reqdata->loglevel >= cv_debug))
  CALL echorecord(memos)
  CALL echorecord(empty_tags)
  CALL echorecord(create_internal)
 ENDIF
 SUBROUTINE (parsetemplate(r_tag_cnt=i4(ref)) =i4 WITH protect)
   DECLARE c_max_tag_size = i4 WITH constant(40), protect
   DECLARE c_prefix_cd = f8 WITH constant(uar_get_code_by("MEANING",c_delim_codeset,"PREFIX")),
   protect
   DECLARE c_suffix_cd = f8 WITH constant(uar_get_code_by("MEANING",c_delim_codeset,"SUFFIX")),
   protect
   DECLARE prefix_disp = vc WITH noconstant(uar_get_code_display(c_prefix_cd)), protect
   DECLARE suffix_disp = vc WITH noconstant(uar_get_code_display(c_suffix_cd)), protect
   DECLARE prefix_size = i4 WITH constant(size(prefix_disp)), protect
   DECLARE suffix_size = i4 WITH constant(size(suffix_disp)), protect
   DECLARE tag_key = vc WITH protect
   DECLARE tag_cd = f8 WITH protect
   DECLARE prefix_pos = i4 WITH protect
   DECLARE suffix_pos = i4 WITH protect
   DECLARE search_pos = i4 WITH protect
   IF (c_prefix_cd <= 0.0)
    CALL cv_log_stat(cv_warning,"UAR_GET_CODE_BY","F",build("CODESET=",c_delim_codeset),"PREFIX")
    RETURN(1)
   ENDIF
   IF (c_suffix_cd <= 0.0)
    CALL cv_log_stat(cv_warning,"UAR_GET_CODE_BY","F",build("CODESET=",c_delim_codeset),"SUFFIX")
    RETURN(1)
   ENDIF
   IF (size(trim(prefix_disp))=0)
    CALL cv_log_stat(cv_warning,"UAR_GET_CODE_DISPLAY","F",build("CODESET=",c_delim_codeset),"PREFIX"
     )
    RETURN(1)
   ENDIF
   IF (size(trim(suffix_disp))=0)
    CALL cv_log_stat(cv_warning,"UAR_GET_CODE_DISPLAY","F",build("CODESET=",c_delim_codeset),"SUFFIX"
     )
    RETURN(1)
   ENDIF
   SET prefix_pos = findstring(prefix_disp,create_internal->template)
   WHILE (prefix_pos > 0)
     SET search_pos = (prefix_pos+ 1)
     SET suffix_pos = findstring(suffix_disp,substring((prefix_pos+ prefix_size),(c_max_tag_size+
       suffix_size),create_internal->template))
     IF (suffix_pos > 0)
      SET tag_key = trim(cnvtupper(cnvtalphanum(substring((prefix_pos+ prefix_size),(suffix_pos - 1),
          create_internal->template))))
      SET tag_cd = uar_get_code_by("DISPLAYKEY",c_tag_codeset,nullterm(trim(tag_key)))
      CALL cv_log_msg(cv_debug,build("Lookup of displaykey :",tag_key,": resulted in code_value=",
        tag_cd))
      IF (tag_cd > 0.0)
       SET r_tag_cnt += 1
       SET stat = alterlist(create_internal->tag,r_tag_cnt)
       SET create_internal->tag[r_tag_cnt].tag_cd = tag_cd
       SET create_internal->tag[r_tag_cnt].tag_mean = uar_get_code_meaning(tag_cd)
       SET create_internal->tag[r_tag_cnt].start_pos = prefix_pos
       SET create_internal->tag[r_tag_cnt].stop_pos = ((((prefix_pos+ prefix_size)+ suffix_pos)+
       suffix_size) - 2)
       SET search_pos = (create_internal->tag[r_tag_cnt].stop_pos+ 1)
      ENDIF
     ENDIF
     SET prefix_pos = findstring(prefix_disp,create_internal->template,search_pos)
   ENDWHILE
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (evaluatetag(p_tag_idx=i4) =i4 WITH protect)
   DECLARE eval_memo_idx = i4 WITH protect
   SET eval_memo_idx = findmemomean(create_internal->tag[p_tag_idx].tag_mean)
   IF (eval_memo_idx > 0)
    RETURN(eval_memo_idx)
   ENDIF
   CASE (create_internal->tag[p_tag_idx].tag_mean)
    OF "PATLNAME":
    OF "PATFNAME":
     CALL addnamememos("PAT",request->person_id,0)
    OF "REFERFNAME":
    OF "REFERLNAME":
     DECLARE ref_phys_id = f8 WITH protect
     DECLARE refer_cnt = i4 WITH protect
     SELECT INTO "nl:"
      FROM encntr_prsnl_reltn epr
      WHERE (epr.encntr_id=request->encntr_id)
       AND epr.encntr_prsnl_r_cd=value(uar_get_code_by("MEANING",333,"REFERDOC"))
       AND epr.active_ind=1
      DETAIL
       ref_phys_id = epr.prsnl_person_id, refer_cnt += 1
      WITH nocounter
     ;end select
     IF (refer_cnt > 1)
      SET ref_phys_id = 0.0
      CALL cv_log_stat(cv_audit,"SELECT","M","ENCNTR_PRSNL_RELTN","Multiple active REFERDOC found")
     ENDIF
     CALL addnamememos("REFER",ref_phys_id,1)
    OF "PRSNLFNAME":
    OF "PRSNLLNAME":
     CALL addnamememos("PRSNL",request->prsnl_id,1)
    OF "ENCNTRTYPE":
    OF "FACILITY":
     DECLARE encntr_type_str = vc WITH protect
     DECLARE encntr_facility_str = vc WITH protect
     SELECT INTO "nl:"
      FROM encounter e
      WHERE (e.encntr_id=request->encntr_id)
      DETAIL
       encntr_type_str = uar_get_code_display(e.encntr_type_cd), encntr_facility_str =
       uar_get_code_display(e.loc_facility_cd)
      WITH nocounter
     ;end select
     CALL addmemomean("ENCNTRTYPE",encntr_type_str)
     CALL addmemomean("FACILITY",encntr_facility_str)
    OF "MRN":
     DECLARE encntr_mrn_str = vc WITH protect
     DECLARE encntr_mrn_cnt = i4 WITH protect
     SELECT INTO "nl:"
      FROM encntr_alias ea
      WHERE (ea.encntr_id=request->encntr_id)
       AND ea.encntr_alias_type_cd=c_encntr_alias_type_mrn
      DETAIL
       encntr_mrn_cnt += 1
       IF (encntr_mrn_cnt=1)
        encntr_mrn_str = ea.alias
       ELSE
        encntr_mrn_str = build(encntr_mrn_str,";",ea.alias)
       ENDIF
      WITH nocounter
     ;end select
     CALL addmemomean("MRN",encntr_mrn_str)
    OF "SUMMARY":
     IF (validate(request->scd_story_id,0.0) > 0.0)
      FREE SET cgsns_reply
      RECORD cgsns_reply(
        1 summary_item_count = i4
        1 summary_item_list[*]
          2 summary_item = vc
        1 status_data
          2 status = c1
          2 subeventstatus[1]
            3 operationname = c25
            3 operationstatus = c1
            3 targetobjectname = c25
            3 targetobjectvalue = vc
      )
      EXECUTE cps_get_scd_note_summary  WITH replace("REQUEST",request), replace("REPLY",
       "CGSNS_REPLY")
      IF ((reqdata->loglevel >= cv_info))
       CALL echorecord(cgsns_reply)
      ENDIF
      IF ((cgsns_reply->summary_item_count > 0))
       CALL addsummarymemo(null)
      ELSE
       CALL addmemomean("SUMMARY","")
      ENDIF
     ELSE
      CALL addmemomean("SUMMARY","")
     ENDIF
    OF "TEXT":
     CALL addmemomean(create_internal->tag[p_tag_idx].tag_mean,"")
    ELSE
     CALL cv_log_stat(cv_audit,"EvaluateTag","F","tag_mean",create_internal->tag[p_tag_idx].tag_mean)
     RETURN(0)
   ENDCASE
   RETURN(findmemomean(create_internal->tag[p_tag_idx].tag_mean))
 END ;Subroutine
 SUBROUTINE addmemomean(p_tag_mean,p_tag_value)
   SET memo_cnt += 1
   IF (mod(memo_cnt,10)=1)
    SET stat = alterlist(memos->memo,(memo_cnt+ 9))
   ENDIF
   SET memos->memo[memo_cnt].tag_mean = p_tag_mean
   IF (textlen(trim(p_tag_value)) > 0)
    SET memos->memo[memo_cnt].tag_value = p_tag_value
    SET memos->memo[memo_cnt].tag_status = etagstatus_success
   ELSE
    SET memos->memo[memo_cnt].tag_status = etagstatus_fail
   ENDIF
   RETURN(memo_cnt)
 END ;Subroutine
 SUBROUTINE (findmemomean(p_tag_mean=vc) =i4)
   RETURN(locateval(memo_idx,1,memo_cnt,create_internal->tag[p_tag_idx].tag_mean,memos->memo[memo_idx
    ].tag_mean))
 END ;Subroutine
 SUBROUTINE (addnamememos(p_prefix_mean=vc,p_person_id=f8,p_prsnl_ind=i2) =null)
   DECLARE first_name_str = vc WITH protect, noconstant(fillstring(40," "))
   DECLARE last_name_str = vc WITH protect, noconstant(fillstring(40," "))
   IF (p_person_id > 0.0)
    SELECT
     IF (p_prsnl_ind=1)
      FROM prsnl p
     ELSE
     ENDIF
     INTO "nl:"
     FROM person p
     WHERE p.person_id=p_person_id
     DETAIL
      first_name_str = trim(p.name_first), last_name_str = trim(p.name_last)
     WITH nocounter, maxqual(p,1)
    ;end select
   ENDIF
   SET stat = addmemomean(build(p_prefix_mean,"FNAME"),first_name_str)
   SET stat = addmemomean(build(p_prefix_mean,"LNAME"),last_name_str)
 END ;Subroutine
 SUBROUTINE initializememo(null)
  SET memo_cnt = size(request->data,5)
  IF (memo_cnt > 0)
   SET stat = alterlist(memos->memo,(memo_cnt+ (9 - mod((memo_cnt+ 9),10))))
   FOR (memo_idx = 1 TO memo_cnt)
     SET memos->memo[memo_idx].tag_mean = request->data[memo_idx].name
     SET memos->memo[memo_idx].tag_value = request->data[memo_idx].value
     SET memos->memo[memo_idx].tag_status = etagstatus_success
   ENDFOR
  ENDIF
 END ;Subroutine
 SUBROUTINE addsummarymemo(null)
   IF ((reqdata->loglevel >= cv_debug))
    CALL cv_log_msg(cv_debug,"Begin AddSummaryMemo")
    CALL echorecord(cgsns_reply)
   ENDIF
   DECLARE summary_idx = i4 WITH protect
   DECLARE next_pos = i4 WITH protect, noconstant(1)
   DECLARE summary_str = vc WITH protect, noconstant(fillstring(32000,"*"))
   DECLARE line_rtf = vc WITH protect, noconstant(fillstring(1000," "))
   DECLARE line_sz = i4 WITH protect
   SET memo_cnt += 1
   IF (mod(memo_cnt,10)=1)
    SET stat = alterlist(memos->memo,(memo_cnt+ 9))
   ENDIF
   FOR (summary_idx = 1 TO cgsns_reply->summary_item_count)
     CALL texttortf(cgsns_reply->summary_item_list[summary_idx].summary_item,line_rtf)
     CALL echo(concat("|",line_rtf,"|"))
     SET line_sz = size(line_rtf)
     SET next_pos += movestring(line_rtf,1,summary_str,next_pos,line_sz)
     SET next_pos += movestring("\par ",1,summary_str,next_pos,5)
   ENDFOR
   SET memos->memo[memo_cnt].tag_mean = "SUMMARY"
   SET memos->memo[memo_cnt].tag_value = substring(1,(next_pos - 1),summary_str)
   SET memos->memo[memo_cnt].tag_status = etagstatus_success
 END ;Subroutine
 SUBROUTINE (texttortf(p_str=vc,r_rtf=vc(ref)) =null)
  SET r_rtf = replace(p_str,char(10),"\par ",0)
  SET r_rtf = replace(r_rtf,char(9),"\tab ",0)
 END ;Subroutine
 SUBROUTINE (addempty(p_tag_cd=f8) =null)
  SET empty_idx = locateval(empty_idx,1,empty_cnt,p_tag_cd,empty_tags->empty[empty_idx].tag_cd)
  IF (empty_idx=0)
   SET empty_cnt += 1
   IF (mod(empty_cnt,c_block_size)=1)
    SET empty_pad += c_block_size
    SET stat = alterlist(empty_tags->empty,empty_pad)
    SET empty_tags->empty[empty_cnt].tag_cd = p_tag_cd
   ENDIF
  ENDIF
 END ;Subroutine
 CALL cv_log_msg_post("000 06/06/2006 MH9140")
END GO
