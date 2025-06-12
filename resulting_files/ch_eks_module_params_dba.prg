CREATE PROGRAM ch_eks_module_params:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Load All" = 0
  WITH outdev, load_all
 SET modify maxvarlen 268435456
 CALL echo( $LOAD_ALL)
 DECLARE start_dt_tm = dq8 WITH noconstant(cnvtdatetime((curdate - 1),0))
 DECLARE end_dt_tm = dq8 WITH noconstant(cnvtdatetime(curdate,0))
 DECLARE templatetype = vc WITH noconstant("")
 DECLARE etx = c1 WITH protect, constant(char(3))
 DECLARE bel = c1 WITH protect, constant(char(7))
 DECLARE bs = c1 WITH protect, constant(char(8))
 DECLARE not_found = vc WITH protect, constant("%NOTFOUND%")
 DECLARE crlf = vc WITH protect, constant(concat(char(13),char(10)))
 DECLARE del = vc WITH protect, constant(char(9))
 DECLARE eot = c1 WITH protect, constant(char(4))
 DECLARE enq = c1 WITH protect, constant(char(5))
 DECLARE ack = c1 WITH protect, constant(char(6))
 DECLARE logic = i2 WITH protect, constant(8)
 DECLARE logic_template = vc WITH protect, noconstant(" ")
 DECLARE evoke = i2 WITH protect, constant(7)
 DECLARE evoke_template = vc WITH protect, noconstant(" ")
 DECLARE action_type = i2 WITH protect, constant(9)
 DECLARE action_template = vc WITH protect, noconstant(" ")
 DECLARE evoke_event = vc WITH protect, noconstant(" ")
 DECLARE remainder = vc WITH protect, noconstant(" ")
 DECLARE evoke_event_remainder = vc WITH protect, noconstant(" ")
 DECLARE action_template_remainder = vc WITH protect, noconstant(" ")
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
   1 file_buf = gvc
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
 RECORD discern_rule_param(
   1 param_data[*]
     2 module_name = vc
     2 version = vc
     2 type = vc
     2 param_id = vc
     2 param = vc
     2 visible_value = vc
     2 hidden_value = vc
     2 param_sequence = i4
 ) WITH protect
 RECORD tempparseparams(
   1 param_data[*]
     2 module_name = vc
     2 type = vc
     2 id = vc
     2 param = vc
     2 visible_value = vc
     2 hidden_value = vc
 )
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
 SUBROUTINE (writetofile(filecontents=gvc) =i2 WITH protect)
   SET file->file_buf = trim(filecontents,7)
   SET stat = cclio("PUTS",file)
   RETURN(stat)
 END ;Subroutine
 SUBROUTINE (openfile(filename=vc) =i2 WITH protect)
   SET file->file_name = filename
   SET file->file_buf = "a+"
   SET stat = cclio("OPEN",file)
   RETURN(stat)
 END ;Subroutine
 DECLARE closefile(null) = i2 WITH protect
 SUBROUTINE closefile(null)
  SET stat = cclio("CLOSE",file)
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
 SUBROUTINE (parsetemplate(txt=vc,template_type=vc,start_cnt=i4(value,0)) =null)
   DECLARE upper_bound = i4 WITH protect, constant(2000)
   DECLARE token = vc WITH protect, noconstant(" ")
   DECLARE remainder = vc WITH protect, noconstant(" ")
   DECLARE parameter_list = vc WITH protect, noconstant(" ")
   DECLARE token_cnt = i4 WITH protect, noconstant(0)
   DECLARE template_cnt = i4 WITH protect, noconstant(start_cnt)
   DECLARE limit = i4 WITH protect, noconstant(0)
   DECLARE end_pos = i4 WITH protect, noconstant(0)
   DECLARE type = vc
   DECLARE type_id = vc
   SET remainder = removebs2bel(txt)
   WHILE (size(remainder) > 0
    AND limit < upper_bound)
     SET limit += 1
     SET token = getnext(remainder,etx)
     IF ( NOT (isoperator(token)))
      SET template_cnt += 1
      CALL echo(build("+++",token,"=>",cnvtupper(template_type),template_cnt))
      SET type_id = build(cnvtupper(template_type),template_cnt)
      IF (template_type="E")
       SET type = "EVOKE"
      ENDIF
      IF (template_type="L")
       SET type = "LOGIC"
      ENDIF
      IF (template_type="A")
       SET type = "ACTION"
      ENDIF
      IF (template_type="G")
       SET type = "ACTION_GROUP"
      ENDIF
      IF (token != not_found)
       SET end_pos = findtemplateend(remainder)
       IF (end_pos > 0)
        SET parameter_list = substring(2,(end_pos - 2),remainder)
        CALL parseparams(token,parameter_list)
        SET pcnt = size(discern_rule_param->param_data,5)
        FOR (x = 1 TO size(tempparseparams->param_data,5))
          SET pcnt += 1
          SET stat = alterlist(discern_rule_param->param_data,pcnt)
          SET discern_rule_param->param_data[pcnt].param = tempparseparams->param_data[x].param
          SET discern_rule_param->param_data[pcnt].hidden_value = tempparseparams->param_data[x].
          hidden_value
          SET discern_rule_param->param_data[pcnt].visible_value = tempparseparams->param_data[x].
          visible_value
          SET discern_rule_param->param_data[pcnt].param_id = type_id
          SET discern_rule_param->param_data[pcnt].type = type
          SET discern_rule_param->param_data[pcnt].module_name = module_name
          SET discern_rule_param->param_data[pcnt].param_sequence = x
          SET discern_rule_param->param_data[pcnt].version = version
        ENDFOR
        SET stat = initrec(tempparseparams)
        SET remainder = substring((end_pos+ 1),(textlen(remainder) - end_pos),remainder)
       ELSE
        SET remainder = null
       ENDIF
      ELSE
       SET remainder = null
      ENDIF
     ENDIF
   ENDWHILE
   IF (limit >= upper_bound)
    CALL cclexception(999,"E",build("Infinite loop in parseTemplate(",template_type,")"))
   ENDIF
   RETURN(template_cnt)
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
 SUBROUTINE (parseparams(template_name=vc,txt=vc) =null WITH protect, copy)
   DECLARE upper_bound = i4 WITH protect, constant(50)
   DECLARE remainder = vc WITH protect, noconstant(txt)
   DECLARE param_value = vc WITH protect, noconstant(" ")
   DECLARE param_pos = vc WITH protect, noconstant(" ")
   DECLARE param_len = vc WITH protect, noconstant(" ")
   DECLARE editor_def = vc WITH protect, noconstant(" ")
   DECLARE literal = vc WITH protect, noconstant(" ")
   DECLARE data_type = vc WITH protect, noconstant(" ")
   DECLARE template_type = vc WITH protect, noconstant(" ")
   DECLARE param_string = vc WITH persistscript, noconstant(" ")
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE param_idx = i4 WITH protect, noconstant(0)
   DECLARE length = i4 WITH protect, noconstant(0)
   DECLARE param_cnt = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE limit = i4 WITH protect, noconstant(0)
   DECLARE template_idx = i4 WITH protect, noconstant(0)
   SET stat = ekstemplatesdef("F",template_name,template_idx)
   IF ( NOT (stat))
    SET stat = eksgettempparam(template_name)
    SET template_idx = eks_templates->cnt
    IF (stat)
     SET stat = ekstemplatesdef("A",template_name,template_idx)
    ELSE
     CALL cclexception(999,"E",build("Failed to save EKS Template:",template_name))
     RETURN
    ENDIF
   ENDIF
   IF (template_idx <= 0)
    CALL cclexception(999,"E",build("Failed to find EKS Template:",template_name))
    RETURN
   ENDIF
   SET editor_def = eks_templates->list[template_idx].editor_def
   SET template_type = eks_templates->list[template_idx].template_type
   SET curpos = 1
   WHILE (size(remainder) > 0
    AND limit < upper_bound)
     SET limit += 1
     SET param_cnt += 1
     SET stat = alterlist(tempparseparams->param_data,param_cnt)
     SET param_value = getnext(remainder,etx)
     SET param_pos = getnext(remainder,etx)
     SET param_len = getnext(remainder,etx)
     IF (findstring(bel,param_value) > 0)
      SET param_value = parseparamlist(param_value)
     ELSEIF (findstring(ack,param_value) > 0)
      SET tempparseparams->param_data[param_cnt].hidden_value = hiddenvalue(param_value)
     ENDIF
     SET param_idx = locateval(idx,1,eks_templates->list[template_idx].num_params,param_cnt,
      eks_templates->list[template_idx].param[idx].par_num)
     IF (param_idx > 0)
      SET pos = (eks_templates->list[template_idx].param[param_idx].pos+ 1)
      SET length = eks_templates->list[template_idx].param[param_idx].name_length
      SET data_type = eks_templates->list[template_idx].param[param_idx].data_type
      IF (curpos < pos)
       SET literal = notrim(substring(curpos,(pos - curpos),editor_def))
      ENDIF
      SET tempparseparams->param_data[param_cnt].param = substring(pos,length,editor_def)
      IF (size(trim(param_value))=0)
       SET param_value = substring(pos,length,editor_def)
      ELSE
       SET param_value = visiblevalue(param_value)
       SET tempparseparams->param_data[param_cnt].visible_value = param_value
      ENDIF
      IF (data_type="L")
       SET param_value = concat("Refer to L",param_value)
       SET tempparseparams->param_data[param_cnt].visible_value = param_value
      ENDIF
      SET curpos = (pos+ length)
      SET param_string = build2(param_string,literal,param_value)
     ELSE
      CALL echo("!!!Failed to find template parameters")
     ENDIF
   ENDWHILE
   IF (curpos <= size(editor_def))
    SET param_string = build2(param_string,trim(substring(curpos,size(editor_def),editor_def)))
   ENDIF
   IF (limit >= upper_bound)
    CALL cclexception(999,"E","Infinite loop in parseParams")
   ENDIF
   RETURN(param_string)
 END ;Subroutine
 SUBROUTINE (parseparamlist(txt=vc) =vc WITH protect)
   DECLARE list_item = vc WITH protect, noconstant(" ")
   DECLARE visible_list_item = vc WITH protect, noconstant(" ")
   DECLARE hidden_list_item = vc WITH protect, noconstant(" ")
   DECLARE param_list = vc WITH protect, noconstant(" ")
   DECLARE hidden_param_list = vc WITH protect, noconstant(" ")
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH noconstant(size(tempparseparams->param_data,5))
   WHILE (list_item != not_found)
     SET i += 1
     SET list_item = piece(txt,bel,i,not_found)
     IF (list_item != not_found)
      SET visible_list_item = visiblevalue(list_item)
      SET hidden_list_item = hiddenvalue(list_item)
      IF (i=1)
       SET param_list = visible_list_item
       SET hidden_param_list = hidden_list_item
      ELSE
       SET param_list = concat(param_list,"; ",visible_list_item)
       SET hidden_param_list = concat(hidden_param_list,"; ",hidden_list_item)
      ENDIF
     ENDIF
   ENDWHILE
   SET tempparseparams->param_data[idx].visible_value = param_list
   SET tempparseparams->param_data[idx].hidden_value = hidden_param_list
   RETURN(param_list)
 END ;Subroutine
 SUBROUTINE (eksgettempparam(template_name=vc) =i2 WITH protect)
   RECORD eksparam_request(
     1 template_name = c30
   ) WITH protect
   RECORD eksparam_reply(
     1 template_name = c30
     1 version = c10
     1 active_flag = c1
     1 template_type = c1
     1 updt_dt_tm = vc
     1 num_params = i4
     1 description = vc
     1 editor_def = vc
     1 ekm_def = vc
     1 param[*]
       2 template_name = c30
       2 version = c10
       2 par_num = i4
       2 par_name = c30
       2 data_type = c1
       2 format_mask = vc
       2 default_data = vc
       2 required_flag = c1
       2 help_type = c1
       2 help = vc
       2 validation_type = c1
       2 validation = vc
       2 pos = i4
       2 name_length = i4
       2 max_input_length = i4
       2 input_type = c1
       2 dependencyon = i4
       2 dependencylist = vc
       2 optimizable_ind = i2
       2 reconcile_script = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
     1 keyword = c30
     1 recommend_flag = i2
     1 always_true_ind = i2
   ) WITH protect
   DECLARE idx = i4 WITH protect, noconstant(0)
   SET eksparam_request->template_name = template_name
   EXECUTE eks_get_temp_param  WITH replace("REQUEST",eksparam_request), replace("REPLY",
    eksparam_reply)
   IF ((eksparam_reply->status_data.status != "S"))
    CALL cclexception(999,"E",build("Failure in EKS_GET_TEMP_PARAM"))
    RETURN(false)
   ENDIF
   SET idx = (eks_templates->cnt+ 1)
   SET stat = alterlist(eks_templates->list,idx)
   SET eks_templates->list[idx].template_name = eksparam_reply->template_name
   SET eks_templates->list[idx].version = eksparam_reply->version
   SET eks_templates->list[idx].active_flag = eksparam_reply->active_flag
   SET eks_templates->list[idx].template_type = eksparam_reply->template_type
   SET eks_templates->list[idx].updt_dt_tm = eksparam_reply->updt_dt_tm
   SET eks_templates->list[idx].num_params = eksparam_reply->num_params
   SET eks_templates->list[idx].description = eksparam_reply->description
   SET eks_templates->list[idx].editor_def = eksparam_reply->editor_def
   SET eks_templates->list[idx].ekm_def = eksparam_reply->ekm_def
   SET eks_templates->list[idx].keyword = eksparam_reply->keyword
   SET eks_templates->list[idx].recommend_flag = eksparam_reply->recommend_flag
   SET eks_templates->list[idx].always_true_ind = eksparam_reply->always_true_ind
   SET stat = moverec(eksparam_reply->param,eks_templates->list[idx].param)
   SET eks_templates->cnt = idx
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (visiblevalue(txt=vc) =vc WITH protect)
   DECLARE remaining_txt = vc WITH protect, noconstant(txt)
   IF (findstring(ack,txt) > 0)
    SET remaining_txt = piece(txt,ack,2," ")
   ENDIF
   RETURN(remaining_txt)
 END ;Subroutine
 SUBROUTINE (hiddenvalue(txt=vc) =vc WITH protect)
   DECLARE remaining_txt = vc WITH protect, noconstant(txt)
   IF (findstring(ack,txt) > 0)
    SET remaining_txt = piece(txt,ack,1," ")
   ENDIF
   RETURN(remaining_txt)
 END ;Subroutine
 RECORD eksmod_request(
   1 bexample = i2
   1 module_name = vc
 ) WITH protect
 DECLARE rule_cnt = i4 WITH noconstant(0)
 DECLARE template_cnt = i4 WITH noconstant(0)
 DECLARE manualxml = gvc WITH noconstant("")
 DECLARE tempxml = gvc WITH noconstant("")
 IF (validate(ctp_module_name))
  SET stat = alterlist(eksmod_reply->qual,1)
  SET eksmod_reply->qual[1].module_name = cnvtupper(ctp_module_name)
 ELSEIF (cnvtint( $LOAD_ALL)=0)
  CALL loadmodifiedmodules(cnvtdatetime(start_dt_tm),cnvtdatetime(end_dt_tm),eksmod_reply)
 ELSE
  SET request->bexample = 3
  EXECUTE eks_get_mod  WITH replace("REQUEST","EKSMOD_REQUEST"), replace("REPLY","EKSMOD_REPLY")
  IF ((eksmod_reply->status_data.status != "S"))
   CALL cclexception(999,"E","Failure in EKS_GET_MOD")
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (i = 1 TO size(eksmod_reply->qual,5))
   SET module_name = eksmod_reply->qual[i].module_name
   SET stat = initrec(eksmodstor_reply)
   SET stat = getmodulestorage(module_name)
   IF (stat)
    SET limit = 0
    SET version = eksmodstor_reply->version
    SET pos = locateval(idx,1,size(eksmodstor_reply->stor,5),logic,eksmodstor_reply->stor[idx].
     data_type)
    IF (pos > 0)
     IF (size(trim(eksmodstor_reply->stor[pos].ekm_info)) > 0)
      SET logic_template = eksmodstor_reply->stor[pos].ekm_info
     ELSE
      SET logic_template = eksmodstor_reply->stor[pos].ekm_info_blob
     ENDIF
    ENDIF
    CALL parsetemplate(logic_template,"L")
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
      CALL parsetemplate(evoke_template,"E")
      IF (evoke_event=not_found)
       SET evoke_event_remainder = null
      ENDIF
    ENDWHILE
    SET pos = locateval(idx,1,size(eksmodstor_reply->stor,5),action_type,eksmodstor_reply->stor[idx].
     data_type)
    IF (pos > 0)
     IF (size(trim(eksmodstor_reply->stor[pos].ekm_info)) > 0)
      SET action_template = eksmodstor_reply->stor[pos].ekm_info
     ELSE
      SET action_template = eksmodstor_reply->stor[pos].ekm_info_blob
     ENDIF
    ENDIF
    CALL parsetemplate(action_template,"A")
    SET pos = locateval(idx,1,size(eksmodstor_reply->stor,5),action_type,eksmodstor_reply->stor[idx].
     data_type)
    IF (pos > 0)
     IF (size(trim(eksmodstor_reply->stor[pos].ekm_info)) > 0)
      SET action_template_remainder = eksmodstor_reply->stor[pos].ekm_info
     ELSE
      SET action_template_remainder = eksmodstor_reply->stor[pos].ekm_info_blob
     ENDIF
    ENDIF
    WHILE (size(action_template_remainder) > 0
     AND limit < upper_bound)
      SET limit += 1
      SET remainder = action_template_remainder
      SET action_group = getnext(remainder,enq)
      IF (action_group != not_found)
       SET action_template = getnext(remainder,enq)
       SET action_template_remainder = remainder
       SET template_cnt = parsetemplate(action_template,"A",template_cnt)
      ENDIF
    ENDWHILE
   ENDIF
 ENDFOR
 CALL echo(size(discern_rule_param->param_data,5))
 SET stat = openfile("ccluserdir:mill_rules_discern_rule_params_2023_07_05_00_02_40.dat")
 FOR (i = 1 TO size(discern_rule_param->param_data,5))
   SET manualxml = concat(" ","<MODULE_NAME>",trim(discern_rule_param->param_data[i].module_name,3),
    "</MODULE_NAME>","<MODULE_VERSION>",
    trim(discern_rule_param->param_data[i].version,3),"</MODULE_VERSION>","<TYPE>",trim(
     discern_rule_param->param_data[i].type,3),"</TYPE>",
    "<PARAM_ID>",trim(discern_rule_param->param_data[i].param_id,3),"</PARAM_ID>","<PARAM>",trim(
     discern_rule_param->param_data[i].param,3),
    "</PARAM>","<HIDDEN_VALUE>",trim(substring(1,15000,discern_rule_param->param_data[i].hidden_value
      ),3),"</HIDDEN_VALUE>","<VISIBLE_VALUE>",
    trim(substring(1,15000,discern_rule_param->param_data[i].visible_value),3),"</VISIBLE_VALUE>",
    "<PARAM_SEQUENCE>",trim(cnvtstring(discern_rule_param->param_data[i].param_sequence),3),
    "</PARAM_SEQUENCE>",
    char(10))
   SET stat = writetofile(manualxml)
   IF (mod(i,100)=0)
    CALL echo(build2("Still working:",cnvtstring(i)))
   ENDIF
 ENDFOR
 GO TO exit_script
#exit_script
 SET stat = closefile(null)
END GO
