CREATE PROGRAM ch_eks_module_evoke:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Load All" = 0,
  "Start Dt/Tm" = 0.0,
  "End Dt/Tm" = 0.0
  WITH outdev, load_all
 SET modify maxvarlen 268435456
 CALL echo( $LOAD_ALL)
 DECLARE start_dt_tm = dq8 WITH noconstant(cnvtdatetime((curdate - 1),0))
 DECLARE end_dt_tm = dq8 WITH noconstant(cnvtdatetime(curdate,0))
 DECLARE etx = c1 WITH protect, constant(char(3))
 DECLARE eot = c1 WITH protect, constant(char(4))
 DECLARE bel = c1 WITH protect, constant(char(7))
 DECLARE bs = c1 WITH protect, constant(char(8))
 DECLARE not_found = vc WITH protect, constant("%NOTFOUND%")
 DECLARE evoke = i2 WITH protect, constant(7)
 DECLARE evoke_template = vc WITH protect, noconstant(" ")
 DECLARE evoke_event_remainder = vc WITH protect, noconstant(" ")
 DECLARE remainder = vc WITH protect, noconstant(" ")
 DECLARE upper_bound = i4 WITH protect, constant(20)
 DECLARE limit = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE data_type = i4 WITH protect, noconstant(0)
 DECLARE module_name = vc WITH protect, noconstant(" ")
 DECLARE version = vc WITH protect, noconstant(" ")
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE debug_on = i2 WITH protect, noconstant(0)
 DECLARE ekstemplatesdef(mode=vc,mapkey=vc,mapval=i4) = i4 WITH protect, map = "HASH"
 RECORD file(
   1 file_desc = i4
   1 file_name = vc
   1 file_buf = vc
   1 file_dir = i4
   1 file_offset = i4
 ) WITH protect
 RECORD eksmodstor_reply(
   1 module_name = c30
   1 version = c10
   1 num_storage = i4
   1 eks_release = c10
   1 active_flag = c1
   1 updt_dt_tm = vc
   1 maint_title = vc
   1 maint_filename = c30
   1 maint_version = c10
   1 maint_institution = vc
   1 maint_author = vc
   1 maint_specialist = vc
   1 maint_dt_tm = dq8
   1 maint_dur_begin_dt_tm = dq8
   1 maint_dur_end_dt_tm = dq8
   1 maint_validation = c12
   1 know_type = c20
   1 know_priority = i4
   1 know_urgency = i4
   1 current_version = c10
   1 current_maint_version = c10
   1 update_user = vc
   1 update_str = vc
   1 stor[*]
     2 data_type = i4
     2 data_seq = i4
     2 ekm_info = vc
     2 ekm_info_blob = gvc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 last_modified = dq8
   1 optimize_flag = i2
   1 optimized_ind = i2
   1 reconcile_flag = i2
   1 reconcile_dt_tm = dq8
 ) WITH protect
 RECORD eksmod_request(
   1 bexample = i2
   1 module_name = vc
 ) WITH protect
 RECORD eksmod_reply(
   1 qual[*]
     2 module_name = c30
     2 version = c10
     2 maint_title = vc
     2 updt_dt_tm = vc
     2 owner = vc
     2 last_modified = dq8
     2 description = vc
     2 maint_dur_begin_dt_tm = dq8
     2 maint_dur_end_dt_tm = dq8
     2 maint_validation = c12
     2 optimize_flag = i2
     2 optimized_ind = i2
     2 reconcile_dt_tm = dq8
     2 reconcile_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD eks_templates(
   1 cnt = i4
   1 list[*]
     2 template_name = c30
     2 version = c10
     2 active_flag = c1
     2 template_type = c1
     2 updt_dt_tm = vc
     2 num_params = i4
     2 description = vc
     2 editor_def = vc
     2 ekm_def = vc
     2 param[*]
       3 template_name = c30
       3 version = c10
       3 par_num = i4
       3 par_name = c30
       3 data_type = c1
       3 format_mask = vc
       3 default_data = vc
       3 required_flag = c1
       3 help_type = c1
       3 help = vc
       3 validation_type = c1
       3 validation = vc
       3 pos = i4
       3 name_length = i4
       3 max_input_length = i4
       3 input_type = c1
       3 dependencyon = i4
       3 dependencylist = vc
       3 optimizable_ind = i2
       3 reconcile_script = vc
     2 keyword = c30
     2 recommend_flag = i2
     2 always_true_ind = i2
 ) WITH protect
 RECORD tokens(
   1 cnt = i4
   1 list[*]
     2 index = i4
 ) WITH protect
 RECORD discern_rule_evoke(
   1 evoke_data[*]
     2 module_name = vc
     2 version = vc
     2 evoke_id = vc
     2 evoke_operator = vc
     2 evoke_template = vc
     2 evoke_sequence = i4
     2 evoke_event = vc
 ) WITH protect
 SUBROUTINE (getmodulestorage(module_name=vc) =i2 WITH protect)
   RECORD modstor_request(
     1 module_name = c40
   ) WITH protect
   SET modstor_request->module_name = module_name
   EXECUTE eks_get_mod_stor  WITH replace("REQUEST",modstor_request), replace("REPLY",
    eksmodstor_reply)
   IF ((eksmodstor_reply->status_data.status != "S"))
    CALL cclexception(999,"E","Failure in EKS_GET_MOD_STOR")
    RETURN(false)
   ELSE
    RETURN(true)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getnext(txt=vc(ref),delimiter=vc) =vc WITH protect)
   DECLARE next = vc WITH protect, noconstant(" ")
   DECLARE pos = i4 WITH protect, noconstant(0)
   SET pos = findstring(delimiter,txt)
   IF (pos=0)
    SET next = not_found
   ELSE
    SET next = notrim(substring(1,(pos - 1),txt))
    SET txt = notrim(substring((pos+ 1),(textlen(txt) - pos),txt))
   ENDIF
   RETURN(next)
 END ;Subroutine
 SUBROUTINE (writetofile(filename=vc,filecontents=gvc) =i2 WITH protect)
   RECORD frec(
     1 file_desc = i4
     1 file_offset = i4
     1 file_dir = i4
     1 file_name = vc
     1 file_buf = vc
   )
   SET frec->file_name = filename
   SET frec->file_buf = "a+"
   SET stat = cclio("OPEN",frec)
   SET frec->file_buf = trim(filecontents)
   SET stat = cclio("PUTS",frec)
   SET stat = cclio("CLOSE",frec)
   RETURN(stat)
 END ;Subroutine
 SUBROUTINE (loadmodifiedmodules(startdttm=dq8,enddttm=dq8,modulerec=vc(ref)) =null WITH protect)
   SELECT INTO "NL:"
    FROM eks_module em
    WHERE em.updt_dt_tm BETWEEN cnvtdatetime(startdttm) AND cnvtdatetime(enddttm)
    ORDER BY em.module_name
    HEAD REPORT
     cnt = 0
    HEAD em.module_name
     cnt += 1, stat = alterlist(modulerec->qual,cnt), modulerec->qual[cnt].module_name = em
     .module_name
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (isoperator(txt=vc) =i2 WITH protect)
   IF (txt IN ("AND", "OR", "NOT", ")", "("))
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 SUBROUTINE (parsetemplate(txt=vc,evoke_event=vc) =null)
   DECLARE upper_bound = i4 WITH protect, constant(2000)
   DECLARE token = vc WITH protect, noconstant(" ")
   DECLARE remainder = vc WITH protect, noconstant(" ")
   DECLARE parameter_list = vc WITH protect, noconstant(" ")
   DECLARE token_cnt = i4 WITH protect, noconstant(0)
   DECLARE template_cnt = i4 WITH protect, noconstant(0)
   DECLARE limit = i4 WITH protect, noconstant(0)
   DECLARE end_pos = i4 WITH protect, noconstant(0)
   DECLARE record_cnt = i4 WITH protect, noconstant(size(discern_rule_evoke->evoke_data,5))
   SET remainder = removebs2bel(txt)
   WHILE (size(remainder) > 0
    AND limit < upper_bound)
     SET limit += 1
     SET token_cnt += 1
     SET record_cnt += 1
     SET stat = alterlist(discern_rule_evoke->evoke_data,record_cnt)
     IF (mod(token_cnt,20)=1)
      SET stat = alterlist(tokens->list,(token_cnt+ 19))
     ENDIF
     SET token = getnext(remainder,etx)
     IF ( NOT (isoperator(token)))
      SET template_cnt += 1
      IF (token != not_found)
       SET end_pos = findtemplateend(remainder)
       IF (end_pos > 0)
        SET parameter_list = substring(2,(end_pos - 2),remainder)
        SET remainder = substring((end_pos+ 1),(textlen(remainder) - end_pos),remainder)
       ELSE
        SET remainder = null
       ENDIF
      ELSE
       SET remainder = null
      ENDIF
      SET discern_rule_evoke->evoke_data[record_cnt].evoke_id = build("E",template_cnt)
      SET discern_rule_evoke->evoke_data[record_cnt].evoke_template = token
     ELSE
      SET discern_rule_evoke->evoke_data[record_cnt].evoke_operator = token
     ENDIF
     SET discern_rule_evoke->evoke_data[record_cnt].evoke_event = evoke_event
     SET discern_rule_evoke->evoke_data[record_cnt].module_name = module_name
     SET discern_rule_evoke->evoke_data[record_cnt].version = version
     SET discern_rule_evoke->evoke_data[record_cnt].evoke_sequence = token_cnt
   ENDWHILE
   SET tokens->cnt = token_cnt
   SET stat = alterlist(tokens->list,token_cnt)
   SET stat = alterlist(discern_rule_evoke->evoke_data,record_cnt)
   IF (limit >= upper_bound)
    CALL cclexception(999,"E",build("Infinite loop in parseTemplate(L)"))
   ENDIF
 END ;Subroutine
 SUBROUTINE (removebs2bel(txt=vc) =vc WITH protect)
   DECLARE clean_txt = vc WITH protect, noconstant(txt)
   DECLARE left = vc WITH protect, noconstant(" ")
   DECLARE right = vc WITH protect, noconstant(" ")
   DECLARE posbs = i4 WITH protect, noconstant(0)
   DECLARE posbel = i4 WITH protect, noconstant(0)
   SET posbs = findstring(bs,clean_txt)
   WHILE (posbs > 0)
     SET posbel = searchleft(clean_txt,posbs,bel)
     IF (posbel > 0)
      SET left = substring(1,posbel,clean_txt)
     ENDIF
     SET right = substring((posbs+ 1),(size(clean_txt) - posbs),clean_txt)
     IF (posbel > 0)
      SET clean_txt = concat(left,right)
     ELSE
      SET clean_txt = right
     ENDIF
     SET posbs = findstring(bs,clean_txt)
   ENDWHILE
   RETURN(clean_txt)
 END ;Subroutine
 SUBROUTINE (searchleft(txt=vc,start=i4,delimiter=vc) =i4 WITH protect)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE char = c1 WITH protect, noconstant(" ")
   FOR (i = (start - 1) TO 1 BY - (1))
    SET char = substring(i,1,txt)
    IF (ichar(char)=ichar(delimiter))
     SET pos = i
     SET i = 0
    ENDIF
   ENDFOR
   RETURN(pos)
 END ;Subroutine
 SUBROUTINE (findtemplateend(txt=vc) =i4 WITH protect)
   DECLARE level = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE char = c1 WITH protect, noconstant(" ")
   DECLARE left = c1 WITH protect, noconstant(" ")
   DECLARE right = c1 WITH protect, noconstant(" ")
   FOR (i = 1 TO size(txt))
     SET char = substring(i,1,txt)
     IF (i=1)
      IF (ichar(char)=ichar("("))
       SET level += 1
      ELSE
       RETURN(pos)
      ENDIF
     ELSE
      SET left = substring((i - 1),1,txt)
      SET right = substring((i+ 1),1,txt)
      IF (ichar(left)=ichar(etx)
       AND ichar(char)=ichar(")")
       AND ichar(right) != ichar(etx))
       SET level -= 1
      ENDIF
     ENDIF
     IF (level=0)
      SET pos = i
      SET i = (size(txt)+ 1)
     ENDIF
   ENDFOR
   RETURN(pos)
 END ;Subroutine
 RECORD eksmod_request(
   1 bexample = i2
   1 module_name = vc
 ) WITH protect
 DECLARE rule_cnt = i4 WITH noconstant(0)
 DECLARE manualxml = gvc WITH noconstant(" ")
 IF (validate(ctp_module_name))
  SET stat = alterlist(eksmod_reply->qual,1)
  SET eksmod_reply->qual[1].module_name = cnvtupper(ctp_module_name)
 ELSEIF (cnvtint( $LOAD_ALL)=0)
  CALL loadmodifiedmodules(cnvtdatetime(),cnvtdatetime(),eksmod_reply)
 ELSE
  SET request->bexample = 3
  EXECUTE eks_get_mod  WITH replace("REQUEST","EKSMOD_REQUEST"), replace("REPLY","EKSMOD_REPLY")
  IF ((eksmod_reply->status_data.status != "S"))
   CALL cclexception(999,"E","Failure in EKS_GET_MOD")
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (i = 1 TO size(eksmod_reply->qual,5))
   SET limit = 0
   SET module_name = eksmod_reply->qual[i].module_name
   SET version = eksmod_reply->qual[i].version
   SET stat = initrec(eksmodstor_reply)
   SET stat = initrec(tokens)
   SET stat = getmodulestorage(module_name)
   IF (stat)
    SET version = eksmodstor_reply->version
    SET pos = locateval(idx,1,size(eksmodstor_reply->stor,5),evoke,eksmodstor_reply->stor[idx].
     data_type)
    IF (pos > 0)
     IF (size(trim(eksmodstor_reply->stor[pos].ekm_info)) > 0)
      SET evoke_event_remainder = eksmodstor_reply->stor[pos].ekm_info
     ELSE
      SET evoke_event_remainder = eksmodstor_reply->stor[pos].ekm_info_blob
     ENDIF
    ENDIF
    WHILE (size(evoke_event_remainder) > 0
     AND limit < upper_bound)
      SET limit += 1
      SET remainder = evoke_event_remainder
      SET evoke_event = getnext(remainder,eot)
      SET evoke_template = getnext(remainder,eot)
      SET evoke_event_remainder = remainder
      CALL parsetemplate(evoke_template,evoke_event)
      IF (evoke_event=not_found)
       SET evoke_event_remainder = null
      ENDIF
    ENDWHILE
   ENDIF
 ENDFOR
 FOR (i = 1 TO size(discern_rule_evoke->evoke_data,5))
   SET manualxml = ""
   IF (i > 1)
    SET manualxml = char(10)
   ENDIF
   SET manualxml = concat(manualxml,"<MODULE_NAME>",trim(discern_rule_evoke->evoke_data[i].
     module_name,3),"</MODULE_NAME>","<MODULE_VERSION>",
    trim(discern_rule_evoke->evoke_data[i].version,3),"</MODULE_VERSION>","<EVOKE_OPERATOR>",trim(
     discern_rule_evoke->evoke_data[i].evoke_operator,3),"</EVOKE_OPERATOR>",
    "<EVOKE_ID>",trim(discern_rule_evoke->evoke_data[i].evoke_id,3),"</EVOKE_ID>","<EVOKE_TEMPLATE>",
    trim(discern_rule_evoke->evoke_data[i].evoke_template,3),
    "</EVOKE_TEMPLATE>","<EVOKE_SEQUENCE>",trim(cnvtstring(discern_rule_evoke->evoke_data[i].
      evoke_sequence),3),"</EVOKE_SEQUENCE>","<EVOKE_EVENT>",
    trim(discern_rule_evoke->evoke_data[i].evoke_event,3),"</EVOKE_EVENT>")
   SET stat = writetofile("ccluserdir:mill_rules_discern_rule_evoke_2023_07_05_00_04_37.dat",
    manualxml)
   IF (mod(i,100)=0)
    CALL echo(build2("Still working:",cnvtstring(i)))
   ENDIF
 ENDFOR
 GO TO exit_script
#exit_script
END GO
