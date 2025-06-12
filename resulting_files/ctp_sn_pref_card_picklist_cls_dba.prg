CREATE PROGRAM ctp_sn_pref_card_picklist_cls:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 CREATE CLASS ctp_logical_domain
 init
 CALL echo("+++ ctp_logical_domain instantiated")
 SUBROUTINE (_::getlogicaldomain(ldomain=f8(ref),name=vc(ref)) =i2)
   DECLARE success = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM prsnl p,
     logical_domain ld
    PLAN (p
     WHERE (p.person_id=reqinfo->updt_id))
     JOIN (ld
     WHERE ld.logical_domain_id=p.logical_domain_id
      AND ld.active_ind=true)
    DETAIL
     ldomain = p.logical_domain_id, name = ld.mnemonic, success = true
    WITH nocounter
   ;end select
   RETURN(success)
 END ;Subroutine
 END; class scope:init
 final
 CALL echo("--- ctp_logical_domain out of scope")
 END; class scope:final
 WITH copy = 1
 CREATE CLASS sn_prompts
 init
 CALL echo("+++ sn_prompts instantiated")
 DECLARE _::delim = vc WITH noconstant(" "), protect
 DECLARE _::ld = f8 WITH noconstant(0.0), protect
 DECLARE _::maxorgs = i4 WITH noconstant(0), protect
 SUBROUTINE (_::surgicalorgs(error_output=vc,fieldname=vc,fieldvalue=vc,orglist=vc) =i2)
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE pos = i4 WITH noconstant(0), protect
   DECLARE prompt_parse = vc WITH noconstant(" "), protect
   DECLARE piece_cnt = i4 WITH noconstant(1), protect
   DECLARE not_found = vc WITH constant("NOT_FOUND"), protect
   DECLARE cnt = i4 WITH noconstant(0), protect
   DECLARE area_code_set_221 = i4 WITH constant(221), protect
   DECLARE surg_area_cd_mean = vc WITH constant("SURGAREA"), protect
   IF (size(trim(check(fieldvalue),3)) > 0)
    SET prompt_parse = piece(fieldvalue,_::delim,piece_cnt,not_found,3)
    WHILE (prompt_parse != not_found)
      SET cnt += 1
      SET stat = alterlist(sn_orgs->org,cnt)
      SET sn_orgs->org[cnt].prompt_value = prompt_parse
      SET piece_cnt += 1
      SET prompt_parse = piece(fieldvalue,_::delim,piece_cnt,not_found,3)
    ENDWHILE
    SELECT INTO "nl:"
     orgname = trim(cnvtupper(substring(1,100,o.org_name)),3)
     FROM code_value sa,
      service_resource sr,
      organization o,
      prsnl_org_reltn por
     PLAN (sa
      WHERE sa.code_set=area_code_set_221
       AND sa.cdf_meaning=surg_area_cd_mean
       AND sa.active_ind=true
       AND sa.begin_effective_dt_tm <= cnvtdatetime(sysdate)
       AND sa.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (sr
      WHERE sr.service_resource_cd=sa.code_value)
      JOIN (o
      WHERE o.organization_id=sr.organization_id
       AND (o.logical_domain_id=_::ld)
       AND o.active_ind=true
       AND expand(idx,1,size(sn_orgs->org,5),o.org_name,sn_orgs->org[idx].prompt_value))
      JOIN (por
      WHERE (por.person_id=reqinfo->updt_id)
       AND por.organization_id=o.organization_id
       AND por.active_ind=true
       AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND por.end_effective_dt_tm > cnvtdatetime(sysdate))
     ORDER BY orgname, o.organization_id
     HEAD REPORT
      placeholder = 1
     HEAD orgname
      cnt = 0
     HEAD o.organization_id
      pos = locateval(idx,1,size(sn_orgs->org,5),o.org_name,sn_orgs->org[idx].prompt_value)
      IF (pos > 0)
       cnt += 1
       IF (cnt=1)
        sn_orgs->org[pos].org_id = o.organization_id, sn_orgs->org[pos].org_name = o.org_name
       ELSE
        sn_orgs->org[pos].dup_ind = 1
       ENDIF
      ENDIF
     FOOT  o.organization_id
      placeholder = 1
     FOOT  orgname
      placeholder = 1
     WITH nocounter, expand = 2
    ;end select
    SELECT INTO "nl:"
     FROM code_value sa,
      service_resource sr,
      organization o,
      prsnl_org_reltn por
     PLAN (sa
      WHERE sa.code_set=area_code_set_221
       AND sa.cdf_meaning=surg_area_cd_mean
       AND sa.active_ind=true
       AND sa.begin_effective_dt_tm <= cnvtdatetime(sysdate)
       AND sa.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (sr
      WHERE sr.service_resource_cd=sa.code_value)
      JOIN (o
      WHERE o.organization_id=sr.organization_id
       AND (o.logical_domain_id=_::ld)
       AND expand(idx,1,size(sn_orgs->org,5),o.organization_id,cnvtreal(sn_orgs->org[idx].
        prompt_value)))
      JOIN (por
      WHERE (por.person_id=reqinfo->updt_id)
       AND por.organization_id=o.organization_id
       AND por.active_ind=true
       AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND por.end_effective_dt_tm > cnvtdatetime(sysdate))
     ORDER BY o.organization_id
     HEAD o.organization_id
      pos = locateval(idx,1,size(sn_orgs->org,5),o.organization_id,cnvtreal(sn_orgs->org[idx].
        prompt_value))
     DETAIL
      IF (pos > 0)
       sn_orgs->org[pos].org_id = o.organization_id, sn_orgs->org[pos].org_name = o.org_name
      ENDIF
     WITH nocounter, expand = 2
    ;end select
    FOR (cnt = 1 TO size(sn_orgs->org,5))
      IF ((((sn_orgs->org[cnt].org_id=0)) OR ((sn_orgs->org[cnt].dup_ind=1))) )
       SELECT INTO value(error_output)
        surg_org_id = cnvtstring(o.organization_id,20), surg_org_name = trim(substring(1,100,o
          .org_name),3), orgnamesort = trim(cnvtupper(substring(1,100,o.org_name)),3)
        FROM code_value sa,
         service_resource sr,
         organization o,
         prsnl_org_reltn por
        PLAN (sa
         WHERE sa.code_set=area_code_set_221
          AND sa.cdf_meaning=surg_area_cd_mean
          AND sa.active_ind=true
          AND sa.begin_effective_dt_tm <= cnvtdatetime(sysdate)
          AND sa.end_effective_dt_tm > cnvtdatetime(sysdate))
         JOIN (sr
         WHERE sr.service_resource_cd=sa.code_value)
         JOIN (o
         WHERE o.organization_id=sr.organization_id
          AND (o.logical_domain_id=_::ld))
         JOIN (por
         WHERE (por.person_id=reqinfo->updt_id)
          AND por.organization_id=o.organization_id
          AND por.active_ind=true
          AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
          AND por.end_effective_dt_tm > cnvtdatetime(sysdate))
        ORDER BY orgnamesort, o.organization_id
        HEAD REPORT
         IF ((sn_orgs->org[cnt].org_id=0))
          err_msg = concat("'",fieldname,"' ORG_NAME or ID invalid or has no Surgical Areas:"),
          list_msg = concat("Populate '",fieldname,
           "' prompt with up to 3 ORG_NAMEs or IDs separated by ';' from below list:")
         ELSEIF ((sn_orgs->org[cnt].dup_ind=1))
          err_msg = concat("Found duplicate '",fieldname,"' ORG_NAME:"), list_msg = concat(
           "Populate '",fieldname,"' prompt with up to 3 ORG_IDs separated by ';' from below list:")
         ENDIF
         col 0, err_msg, row + 2,
         sn_orgs->org[cnt].prompt_value, row + 2, list_msg,
         row + 2, col 3, "ORG_ID",
         col 30, "ORG_NAME", row + 1
        HEAD orgnamesort
         placeholder = 1
        HEAD o.organization_id
         col 3, surg_org_id, col 30,
         surg_org_name, row + 1
        FOOT  o.organization_id
         placeholder = 1
        FOOT  orgnamesort
         placeholder = 1
        WITH nocounter
       ;end select
       RETURN(false)
       SET cnt = (size(sn_orgs->org,5)+ 1)
      ENDIF
    ENDFOR
    SET stat = moverec(sn_orgs->org,parser(orglist))
    SET stat = copyrec(sn_orgs,TMP::sort)
    SELECT INTO "nl:"
     key_org_id = sn_orgs->org[d.seq].org_id
     FROM (dummyt d  WITH seq = size(sn_orgs->org,5))
     ORDER BY key_org_id
     HEAD REPORT
      cnt = 0, stat = alterlist(tmp::sort->org,size(sn_orgs->org,5))
     DETAIL
      cnt += 1, stat = movereclist(sn_orgs->org,tmp::sort->org,d.seq,cnt,1,
       0)
     FOOT REPORT
      stat = moverec(tmp::sort->org,sn_orgs->org)
     WITH nocounter
    ;end select
    RETURN(true)
    SET _::maxorgs = size(sn_orgs->org,5)
   ENDIF
 END ;Subroutine
 SUBROUTINE (_::codevalue(error_output=vc,fieldname=vc,fieldvalue=vc,codeset=i4,meaning=vc,
  code_value_list=vc) =i2)
   DECLARE meaning_parser = vc WITH protect, noconstant("1 = 1")
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE prompt_parse = vc WITH protect, noconstant(" ")
   DECLARE piece_cnt = i4 WITH protect, noconstant(1)
   DECLARE not_found = vc WITH protect, constant("NOT_FOUND")
   DECLARE cnt = i4 WITH protect, noconstant(0)
   RECORD code_values(
     1 qual[*]
       2 code_value = f8
       2 display = vc
       2 dup_ind = i2
       2 prompt_value = vc
   ) WITH protect
   IF (textlen(trim(meaning)) > 0)
    SET meaning_parser = build("cv.cdf_meaning = trim(meaning, 3)")
   ENDIF
   IF (size(trim(check(fieldvalue),3)) > 0)
    SET prompt_parse = piece(fieldvalue,_::delim,piece_cnt,not_found,3)
    WHILE (prompt_parse != not_found)
      SET cnt += 1
      SET stat = alterlist(code_values->qual,cnt)
      SET code_values->qual[cnt].prompt_value = cnvtupper(trim(prompt_parse,3))
      SET piece_cnt += 1
      SET prompt_parse = piece(fieldvalue,_::delim,piece_cnt,not_found,3)
    ENDWHILE
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE expand(idx,1,size(code_values->qual,5),cv.code_value,cnvtreal(code_values->qual[idx].
        prompt_value))
       AND cv.code_set=codeset
       AND cv.active_ind=1
       AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
       AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND parser(meaning_parser))
     ORDER BY cv.code_value
     HEAD cv.code_value
      pos = locateval(idx,1,size(code_values->qual,5),cv.code_value,cnvtreal(code_values->qual[idx].
        prompt_value))
     DETAIL
      IF (pos > 0)
       code_values->qual[pos].code_value = cv.code_value, code_values->qual[pos].display = cv.display
      ENDIF
     WITH nocounter, expand = 2
    ;end select
    SELECT INTO "nl:"
     display = cnvtupper(substring(1,40,trim(cv.display,3)))
     FROM code_value cv
     PLAN (cv
      WHERE expand(idx,1,size(code_values->qual,5),cnvtupper(cv.display),code_values->qual[idx].
       prompt_value)
       AND cv.code_set=codeset
       AND cv.active_ind=1
       AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
       AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND parser(meaning_parser))
     ORDER BY display
     HEAD display
      pos = locateval(idx,1,size(code_values->qual,5),cnvtupper(cv.display),code_values->qual[idx].
       prompt_value), cnt = 0
     DETAIL
      IF (pos > 0)
       cnt += 1
       IF (cnt=1)
        code_values->qual[pos].code_value = cv.code_value, code_values->qual[pos].display = cv
        .display
       ELSE
        code_values->qual[pos].dup_ind = 1
       ENDIF
      ENDIF
     WITH nocounter, expand = 2
    ;end select
    FOR (cnt = 1 TO size(code_values->qual,5))
      IF ((((code_values->qual[cnt].code_value=0)) OR ((code_values->qual[cnt].dup_ind=1))) )
       SELECT INTO value(error_output)
        code_value = cnvtstring(cv.code_value,20), display = cv.display
        FROM code_value cv
        WHERE cv.code_set=codeset
         AND parser(meaning_parser)
         AND cv.active_ind=1
        ORDER BY display
        HEAD REPORT
         IF ((code_values->qual[cnt].code_value=0))
          err_msg = concat("'",fieldname,"' Display or Code Value entered was not found:"), list_msg
           = concat("Populate '",fieldname,"' prompt with DISPLAY or CODE_VALUE from below list:")
         ELSEIF ((code_values->qual[cnt].dup_ind=1))
          err_msg = concat("Found duplicate '",fieldname,"' Display:"), list_msg = concat(
           "Populate '",fieldname,"' prompt with CODE_VALUE from below list:")
         ENDIF
         col 0, err_msg, row + 2,
         code_values->qual[cnt].prompt_value, row + 2, list_msg,
         row + 2, col 3, "CODE_VALUE",
         col 30, "DISPLAY", row + 1
        DETAIL
         col 3, code_value, col 30,
         display, row + 1
        WITH nocounter
       ;end select
       RETURN(false)
      ENDIF
    ENDFOR
    SET stat = moverec(code_values->qual,parser(code_value_list))
    RETURN(true)
   ENDIF
 END ;Subroutine
 SUBROUTINE (_::boolean(error_output=vc,fieldname=vc,fieldvalue=vc,indicator=i4(ref)) =i2)
   IF (cnvtupper(trim(fieldvalue,3)) IN ("YES", "Y", "1"))
    SET indicator = 1
    RETURN(true)
   ELSEIF (cnvtupper(trim(fieldvalue,3)) IN ("NO", "N", "0"))
    SET indicator = 0
    RETURN(true)
   ELSE
    CALL _::errmsg(error_output,concat(fieldname," prompt not valid. Must be set to 'Y' or 'N'"))
    RETURN(false)
   ENDIF
 END ;Subroutine
 SUBROUTINE (_::numeric(error_output=vc,fieldname=vc,fieldvalue=vc,number=i4(ref)) =i2)
   IF (isnumeric(fieldvalue))
    SET number = cnvtint(fieldvalue)
    RETURN(true)
   ELSE
    CALL _::errmsg(error_output,concat(fieldname,
      " prompt not valid. Must be numeric and greater than 0"))
    RETURN(false)
   ENDIF
 END ;Subroutine
 SUBROUTINE (_::maxlistsize(error_output=vc,fieldname=vc,rec_list=vc,max_size=vc) =i2)
   DECLARE success = i2 WITH noconstant(1), protect
   IF (size(parser(rec_list),5) > max_size)
    SET success = 0
    CALL _::errmsg(error_output,concat(fieldname," prompt only accepts a max of ",trim(cnvtstring(
        max_size),3)," value(s) per execution"))
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE _::errmsg(error_output,txt)
   SELECT INTO value(error_output)
    FROM dummyt
    HEAD REPORT
     col 0, txt
    WITH nocounter
   ;end select
 END ;Subroutine
 END; class scope:init
 final
 CALL echo("--- sn_prompts out of scope")
 END; class scope:final
 WITH copy = 1
 CREATE CLASS ip_script_ccl
 init
 RECORD _::request(
   1 dynamic = i1
 )
 RECORD _::reply(
   1 dynamic = i1
 )
 DECLARE PRIVATE::success_map(mode=vc,mapkey=vc,mapval=i1) = i4 WITH map = "hash"
 DECLARE PRIVATE::err_msg = vc WITH noconstant(" ")
 DECLARE PRIVATE::enabled_options = i2 WITH noconstant(0)
 DECLARE PRIVATE::first_enable_check = i2 WITH noconstant(true)
 IF ( NOT (validate(PRIVATE::free_reply)))
  DECLARE PRIVATE::free_reply = i2 WITH constant(0)
 ENDIF
 IF ( NOT (validate(PRIVATE::success_status)))
  DECLARE PRIVATE::success_status = vc WITH constant("S|Z")
 ENDIF
 IF ( NOT (validate(PRIVATE::commit_ind_check)))
  DECLARE PRIVATE::commit_ind_check = i2 WITH constant(0)
 ENDIF
 DECLARE _::initialize(null) = null
 SUBROUTINE _::initialize(null)
   SET stat = initrec(_::request)
   SET stat = initrec(_::reply)
   SET PRIVATE::err_msg = " "
 END ;Subroutine
 DECLARE _::geterror(null) = vc
 SUBROUTINE _::geterror(null)
  IF (size(trim(PRIVATE::err_msg))=0)
   SET PRIVATE::err_msg = concat(PRIVATE::object_name," unknown error")
  ENDIF
  RETURN(PRIVATE::err_msg)
 END ;Subroutine
 DECLARE _::perform(null) = i2
 SUBROUTINE _::perform(null)
   DECLARE status = i2 WITH protect, noconstant(0)
   SET status = PRIVATE::performwrapper(0)
   RETURN(status)
 END ;Subroutine
 DECLARE PRIVATE::performwrapper(null) = i2
 SUBROUTINE PRIVATE::performwrapper(null)
   SET reqinfo->commit_ind = false
   IF (error(PRIVATE::err_msg,0))
    RETURN(0)
   ENDIF
   CALL PRIVATE::enableobjectoptions(0)
   CALL PRIVATE::executewithreplace(_::request,_::reply)
   CALL PRIVATE::disableobjectoptions(0)
   DECLARE success = i1 WITH protect, noconstant(0)
   IF (error(PRIVATE::err_msg,0)=0)
    SET success = true
   ENDIF
   IF (success)
    IF (validate(_::reply->status_data.status))
     IF (PRIVATE::successful(_::reply->status_data.status))
      SET success = true
     ELSE
      SET PRIVATE::err_msg = PRIVATE::buildstatusblockmsg(0)
      SET success = false
     ENDIF
    ELSEIF (validate(_::reply->status_block.status_ind))
     IF ((_::reply->status_block.status_ind=1))
      SET success = true
     ELSE
      SET PRIVATE::err_msg = PRIVATE::buildstatusmsg(_::reply->status_block.status_code)
      SET success = false
     ENDIF
    ELSE
     SET PRIVATE::err_msg = concat(PRIVATE::object_name," unknown reply status method")
     SET success = false
    ENDIF
   ENDIF
   IF (success)
    IF (((PRIVATE::commit_ind_check
     AND (reqinfo->commit_ind=true)) OR ( NOT (PRIVATE::commit_ind_check)
     AND (reqinfo->commit_ind=false))) )
     SET success = true
    ELSE
     SET PRIVATE::err_msg = concat(PRIVATE::object_name," COMMIT_IND returned '",build(reqinfo->
       commit_ind),"'")
     SET success = false
    ENDIF
   ENDIF
   SET reqinfo->commit_ind = false
   IF (success)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (PRIVATE::executewithreplace(request=vc(ref),reply=vc(ref)) =null)
  IF (PRIVATE::free_reply)
   RECORD reply(
     1 dummy = i1
   ) WITH protect
  ENDIF
  EXECUTE value(PRIVATE::object_name)
 END ;Subroutine
 DECLARE PRIVATE::enableobjectoptions(null) = null
 SUBROUTINE PRIVATE::enableobjectoptions(null)
   IF (((PRIVATE::first_enable_check) OR (PRIVATE::enabled_options)) )
    IF (PRIVATE::ctrlobjectoptions(1))
     SET PRIVATE::enabled_options = true
    ELSE
     SET PRIVATE::first_enable_check = false
    ENDIF
   ENDIF
 END ;Subroutine
 DECLARE PRIVATE::disableobjectoptions(null) = null
 SUBROUTINE PRIVATE::disableobjectoptions(null)
   IF (PRIVATE::enabled_options)
    CALL PRIVATE::ctrlobjectoptions(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (PRIVATE::ctrlobjectoptions(enable_ind=i2(value,0)) =i2)
   DECLARE exists_ind = i2 WITH protect, noconstant(0)
   IF (validate(_set_trace_nocallecho_))
    IF (enable_ind)
     SET trace = nocallecho
    ELSE
     SET trace = callecho
    ENDIF
    SET exists_ind = true
   ENDIF
   IF (validate(_set_message_noinformation_))
    IF (enable_ind)
     SET message = noinformation
    ELSE
     SET message = information
    ENDIF
    SET exists_ind = true
   ENDIF
   IF (validate(_set_trace_nowarning_))
    IF (enable_ind)
     SET trace = nowarning
    ELSE
     SET trace = warning
    ENDIF
    SET exists_ind = true
   ENDIF
   IF (validate(_set_trace_nowarning2_))
    IF (enable_ind)
     SET trace = nowarning2
    ELSE
     SET trace = warning2
    ENDIF
    SET exists_ind = true
   ENDIF
   IF (validate(_set_trace_noechosub_))
    IF (enable_ind)
     SET trace = noechosub
    ELSE
     SET trace = echosub
    ENDIF
    SET exists_ind = true
   ENDIF
   IF (validate(_set_trace_noechoprog_))
    IF (enable_ind)
     SET trace = noechoprog
    ELSE
     SET trace = echoprog
    ENDIF
    SET exists_ind = true
   ENDIF
   IF (validate(_set_trace_echosub_))
    IF (enable_ind)
     SET trace = echosub
    ELSE
     SET trace = noechosub
    ENDIF
    SET exists_ind = true
   ENDIF
   IF (validate(_set_trace_echoprog_))
    IF (enable_ind)
     SET trace = echoprog
    ELSE
     SET trace = noechoprog
    ENDIF
    SET exists_ind = true
   ENDIF
   IF (validate(_set_trace_rdbdebug_))
    IF (enable_ind)
     SET trace = rdbdebug
    ELSE
     SET trace = nordbdebug
    ENDIF
    SET exists_ind = true
   ENDIF
   IF (validate(_set_trace_rdbbind_))
    IF (enable_ind)
     SET trace = rdbbind
    ELSE
     SET trace = nordbbind
    ENDIF
    SET exists_ind = true
   ENDIF
   IF (enable_ind
    AND exists_ind)
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 SUBROUTINE (PRIVATE::successful(return_status=vc) =i2)
   DECLARE not_found = vc WITH protect, constant("%NOTFOUND%")
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE item = vc WITH protect, noconstant(" ")
   DECLARE mapkey = i1 WITH protect, noconstant(0)
   DECLARE status = i1 WITH protect, noconstant(0)
   IF (PRIVATE::success_map("Count")=0)
    SET cnt = 1
    SET item = piece(PRIVATE::success_status,"|",cnt,not_found)
    WHILE (item != not_found)
      SET status = PRIVATE::success_map("Add",cnvtupper(trim(item,3)),1)
      SET cnt += 1
      SET item = piece(PRIVATE::success_status,"|",cnt,not_found)
    ENDWHILE
   ENDIF
   IF (PRIVATE::success_map("Find",cnvtupper(trim(return_status,3)),mapkey))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 DECLARE PRIVATE::buildstatusblockmsg(null) = vc
 SUBROUTINE PRIVATE::buildstatusblockmsg(null)
   DECLARE status_msg = vc WITH protect, noconstant(" ")
   DECLARE sub_status_msg = vc WITH protect, noconstant(" ")
   SET status_msg = PRIVATE::buildstatusmsg(_::reply->status_data.status)
   SET sub_status_msg = PRIVATE::buildsubstatusmsg(0)
   IF (size(trim(sub_status_msg)) > 0)
    SET status_msg = concat(status_msg," (",sub_status_msg,")")
   ENDIF
   RETURN(status_msg)
 END ;Subroutine
 SUBROUTINE (PRIVATE::buildstatusmsg(status_varient=vc) =vc)
   DECLARE msg = vc WITH protect, noconstant(" ")
   SET msg = concat(PRIVATE::object_name," returned '",trim(build(status_varient),3),"'")
   RETURN(msg)
 END ;Subroutine
 DECLARE PRIVATE::buildsubstatusmsg(null) = vc
 SUBROUTINE PRIVATE::buildsubstatusmsg(null)
   DECLARE enq = c1 WITH protect, constant(char(5))
   DECLARE sub_status_msg = vc WITH protect, noconstant(" ")
   IF (validate(_::reply->status_data.subeventstatus))
    IF (size(_::reply->status_data.subeventstatus,5) > 0)
     SET sub_status_msg = build(_::reply->status_data.subeventstatus[1].operationname,enq,_::reply->
      status_data.subeventstatus[1].operationstatus,enq,_::reply->status_data.subeventstatus[1].
      targetobjectname,
      enq,_::reply->status_data.subeventstatus[1].targetobjectvalue)
     IF (size(trim(sub_status_msg)) > 0)
      SET sub_status_msg = replace(trim(sub_status_msg,3),enq,":")
     ELSE
      SET sub_status_msg = " "
     ENDIF
    ENDIF
   ENDIF
   RETURN(sub_status_msg)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS message_log
 init
 RECORD PRIVATE::colmap(
   1 cnt = i4
   1 data[*]
     2 field = vc
     2 col = i4
 )
 RECORD PRIVATE::msgdef(
   1 cnt = i4
   1 list[*]
     2 name = vc
     2 msg = vc
     2 col_cnt = i4
     2 col[*]
       3 val = i4
 )
 RECORD _::msg(
   1 cnt = i4
   1 list[*]
     2 full_msg = vc
     2 msg_cnt = i4
     2 msg[*]
       3 txt = vc
     2 entity_id = f8
     2 entity_name = vc
     2 full_cell = vc
     2 cell_cnt = i4
     2 cell[*]
       3 cellref = vc
     2 success_ind = i2
   1 layout_error = i2
 )
 DECLARE PRIVATE::rows_processed = i4 WITH protect, noconstant(0)
 DECLARE PRIVATE::rows_with_errors = i4 WITH protect, noconstant(0)
 SUBROUTINE (_::errormsg(r=i4,enum_name=vc,addl_msg=vc(value," ")) =null)
   DECLARE name_key = vc WITH protect, noconstant(cnvtupper(enum_name))
   DECLARE msg_cnt = i4 WITH protect, noconstant(_::msg->list[r].msg_cnt)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE index = i4 WITH protect, noconstant(0)
   SET pos = locatevalsort(index,1,private::msgdef->cnt,name_key,private::msgdef->list[index].name)
   IF (pos > 0)
    SET msg_cnt += 1
    SET _::msg->list[r].msg_cnt = msg_cnt
    SET stat = alterlist(_::msg->list[r].msg,msg_cnt)
    SET _::msg->list[r].msg[msg_cnt].txt = private::msgdef->list[pos].msg
    IF (textlen(trim(addl_msg)) != 0)
     SET _::msg->list[r].msg[msg_cnt].txt = build(_::msg->list[r].msg[msg_cnt].txt,"::",addl_msg)
    ENDIF
    FOR (index = 1 TO private::msgdef->list[pos].col_cnt)
      CALL PRIVATE::errorcellref(r,private::msgdef->list[pos].col[index].val)
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (_::definemsg(enum_name=vc,error_msg=vc,columns=vc) =null)
   DECLARE name_key = vc WITH protect, constant(cnvtupper(enum_name))
   DECLARE not_found = vc WITH protect, constant("%NOTFOUND%")
   DECLARE enumpos = i4 WITH protect, noconstant(0)
   DECLARE colpos = i4 WITH protect, noconstant(0)
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE col_cnt = i4 WITH protect, noconstant(0)
   SET enumpos = locatevalsort(index,1,private::msgdef->cnt,name_key,private::msgdef->list[index].
    name)
   IF (enumpos <= 0)
    SET enumpos = abs(enumpos)
    SET private::msgdef->cnt += 1
    SET stat = alterlist(private::msgdef->list,private::msgdef->cnt,enumpos)
    SET enumpos += 1
    SET private::msgdef->list[enumpos].name = name_key
    SET private::msgdef->list[enumpos].msg = error_msg
    SET piece_cnt = 1
    SET column = cnvtupper(piece(columns,"|",piece_cnt,not_found,3))
    WHILE (column != not_found)
      IF (column != "ALL")
       SET col_cnt += 1
       SET stat = alterlist(private::msgdef->list[enumpos].col,col_cnt)
       SET colpos = locateval(index,1,private::colmap->cnt,column,private::colmap->data[index].field)
       IF (colpos > 0)
        SET private::msgdef->list[enumpos].col[col_cnt].val = private::colmap->data[colpos].col
       ENDIF
       SET piece_cnt += 1
       SET column = cnvtupper(piece(columns,"|",piece_cnt,not_found,3))
      ELSE
       SET col_cnt = (private::colmap->cnt - 1)
       SET stat = alterlist(private::msgdef->list[enumpos].col,col_cnt)
       FOR (index = 1 TO col_cnt)
         SET private::msgdef->list[enumpos].col[index].val = private::colmap->data[index].col
       ENDFOR
       SET column = not_found
      ENDIF
    ENDWHILE
    SET private::msgdef->list[enumpos].col_cnt = col_cnt
   ENDIF
 END ;Subroutine
 SUBROUTINE (_::parseerrorcolumn(map_persist=vc(ref)) =null)
   DECLARE piece_cnt = i4 WITH protect, noconstant(1)
   DECLARE errmapparse = vc WITH protect, noconstant(" ")
   DECLARE not_found = vc WITH protect, constant("%NOTFOUND%")
   IF (size(trim(requestin->list_0[1].errorcolumnmap))=0)
    SET requestin->list_0[1].errorcolumnmap = map_persist
   ELSE
    SET map_persist = requestin->list_0[1].errorcolumnmap
   ENDIF
   SET errmapparse = piece(requestin->list_0[1].errorcolumnmap,"|",piece_cnt,not_found,3)
   WHILE (errmapparse != not_found)
     SET private::colmap->cnt = piece_cnt
     SET stat = alterlist(private::colmap->data,piece_cnt)
     SET private::colmap->data[piece_cnt].field = cnvtupper(piece(errmapparse,":",1,not_found,3))
     SET private::colmap->data[piece_cnt].col = cnvtint(piece(errmapparse,":",2,not_found,3))
     SET piece_cnt += 1
     SET errmapparse = piece(requestin->list_0[1].errorcolumnmap,"|",piece_cnt,not_found,3)
   ENDWHILE
 END ;Subroutine
 DECLARE _::datavalidationsuccess(null) = i2
 SUBROUTINE _::datavalidationsuccess(null)
   DECLARE list_size = i4 WITH protect, constant(size(_::msg->list,5))
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE success_ind = i2 WITH protect, noconstant(false)
   FOR (idx = 1 TO list_size)
     IF ((_::msg->list[idx].msg_cnt=0))
      SET cnt += 1
     ELSE
      SET idx = list_size
     ENDIF
   ENDFOR
   IF (cnt=list_size)
    SET success_ind = true
   ENDIF
   RETURN(success_ind)
 END ;Subroutine
 SUBROUTINE (_::createstatusmessages(audit_ind=i2) =null)
   DECLARE csvrow = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SET PRIVATE::rows_processed = 0
   SET PRIVATE::rows_with_errors = 0
   FOR (csvrow = 1 TO size(_::msg->list,5))
    SET PRIVATE::rows_processed += 1
    IF ((_::msg->list[csvrow].msg_cnt > 0))
     SET PRIVATE::rows_with_errors += 1
     FOR (idx = 1 TO _::msg->list[csvrow].msg_cnt)
       IF (idx=1)
        SET _::msg->list[csvrow].full_msg = _::msg->list[csvrow].msg[idx].txt
       ELSE
        SET _::msg->list[csvrow].full_msg = build(_::msg->list[csvrow].full_msg,"|",_::msg->list[
         csvrow].msg[idx].txt)
       ENDIF
     ENDFOR
     FOR (idx = 1 TO _::msg->list[csvrow].cell_cnt)
       IF (idx=1)
        SET _::msg->list[csvrow].full_cell = _::msg->list[csvrow].cell[idx].cellref
       ELSE
        SET _::msg->list[csvrow].full_cell = build(_::msg->list[csvrow].full_cell,"|",_::msg->list[
         csvrow].cell[idx].cellref)
       ENDIF
     ENDFOR
    ELSEIF ((_::msg->layout_error=true))
     SET _::msg->list[csvrow].full_msg = " "
    ELSEIF (audit_ind=false)
     IF (size(trim(_::msg->list[csvrow].full_msg))=0)
      SET _::msg->list[csvrow].full_msg = "Audited Successfully"
     ELSE
      SET _::msg->list[csvrow].full_msg = build("Audited Successfully|",_::msg->list[csvrow].full_msg
       )
     ENDIF
    ELSEIF ((_::msg->list[csvrow].success_ind=true))
     IF (size(trim(_::msg->list[csvrow].full_msg))=0)
      SET _::msg->list[csvrow].full_msg = "Uploaded Successfully"
     ELSE
      SET _::msg->list[csvrow].full_msg = build("Uploaded Successfully|",_::msg->list[csvrow].
       full_msg)
     ENDIF
    ELSE
     SET _::msg->list[csvrow].full_msg = "Skipped due to unexpected error"
    ENDIF
   ENDFOR
 END ;Subroutine
 DECLARE _::rowsprocessed(null) = i4
 SUBROUTINE _::rowsprocessed(null)
   RETURN(PRIVATE::rows_processed)
 END ;Subroutine
 DECLARE _::rowswitherrors(null) = i4
 SUBROUTINE _::rowswitherrors(null)
   RETURN(PRIVATE::rows_with_errors)
 END ;Subroutine
 SUBROUTINE (PRIVATE::errorcellref(r=i4,c=i4) =null)
   DECLARE cell_cnt = i4 WITH protect, noconstant(_::msg->list[r].cell_cnt)
   DECLARE row_ref = i4 WITH protect, noconstant(r)
   SET cell_cnt += 1
   SET _::msg->list[r].cell_cnt = cell_cnt
   SET stat = alterlist(_::msg->list[r].cell,cell_cnt)
   IF (dm_dbi_start_row > 1)
    SET row_ref += (dm_dbi_start_row - 1)
   ENDIF
   SET _::msg->list[r].cell[cell_cnt].cellref = build(row_ref,",",c)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS sort_data
 init
 SUBROUTINE (_::sortrecord(in_record=vc(ref),list_items=vc,out_record=vc) =i2)
   RECORD query_rec(
     1 tot_item_cnt = i4
     1 lvl[*]
       2 name = vc
       2 item[*]
         3 name = vc
         3 dtype = vc
     1 select_list = vc
     1 from_list = vc
     1 plan_join = vc
     1 order_list = vc
     1 head_list = vc
     1 save_list = vc
     1 det_save_list = vc
     1 foot_list = vc
   ) WITH protect
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE field_list = vc WITH protect, noconstant(" ")
   DECLARE query_str = vc WITH protect, noconstant(" ")
   CALL PRIVATE::parsereclist(list_items,query_rec)
   CALL PRIVATE::buildoutrecord(query_rec)
   CALL PRIVATE::buildselectlist(query_rec)
   CALL PRIVATE::buildfromlist(query_rec)
   CALL PRIVATE::buildplanjoinlist(query_rec)
   CALL PRIVATE::buildorderlist(query_rec)
   CALL PRIVATE::buildheadlist(query_rec)
   CALL PRIVATE::buildsavelist(query_rec)
   CALL PRIVATE::builddetailsavelist(query_rec)
   CALL PRIVATE::buildfootlist(query_rec)
   SET query_str = concat("SELECT INTO 'NL:'",lf,query_rec->select_list,lf,"FROM",
    lf,query_rec->from_list,lf,query_rec->plan_join,lf,
    "ORDER",lf,query_rec->order_list,lf,"HEAD REPORT",
    lf,"cnt = 0",lf,query_rec->head_list,lf,
    "cnt = cnt + 1",lf,"if (mod(cnt, 5000) = 1)",lf,concat("stat = alterlist(",out_record,
     "->qual, cnt + 4999)"),
    lf,"endif",lf,query_rec->save_list,lf,
    "ptr_idx = 0",lf,"DETAIL",lf,"ptr_idx = ptr_idx + 1",
    lf,"if(mod(ptr_idx, 1000) = 1)",lf,concat("stat = alterlist(",out_record,
     "->qual[cnt].ptr, ptr_idx + 999)"),lf,
    "endif",lf,query_rec->det_save_list,lf,query_rec->foot_list,
    lf,"FOOT REPORT",lf,concat("stat = alterlist(",out_record,"->qual, cnt)"),lf,
    "WITH NOCOUNTER GO")
   CALL parser(query_str)
   IF (size(parser(build(out_record,"->qual")),5)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (PRIVATE::parsereclist(list=vc,query=vc(ref)) =null)
   DECLARE level_delim = c1 WITH protect, constant("|")
   DECLARE begin_item_delim = c1 WITH protect, constant(";")
   DECLARE level_cnt = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE remainder = vc WITH protect, noconstant(" ")
   DECLARE level = vc WITH protect, noconstant(" ")
   DECLARE item_list = vc WITH protect, noconstant(" ")
   DECLARE list_part = vc WITH protect, noconstant(list)
   SET pos = findstring(level_delim,list)
   IF (pos > 0)
    SET list_part = substring(1,(pos - 1),list)
    SET remainder = substring((pos+ 1),size(list),list)
   ENDIF
   SET pos = findstring(begin_item_delim,list_part)
   IF (pos > 0)
    SET level = substring(1,(pos - 1),list_part)
    SET item_list = substring((pos+ 1),size(list_part),list_part)
   ELSE
    SET level = list_part
   ENDIF
   SET level_cnt = (size(query->lvl,5)+ 1)
   SET stat = alterlist(query->lvl,level_cnt)
   SET query->lvl[level_cnt].name = level
   CALL PRIVATE::parserecitems(item_list,query)
   IF (size(trim(remainder)) > 0)
    CALL PRIVATE::parsereclist(remainder,query)
   ELSE
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE (PRIVATE::parserecitems(list=vc,query=vc(ref)) =null)
   DECLARE item_delim = c1 WITH protect, constant(",")
   DECLARE type_delim = c1 WITH protect, constant("-")
   DECLARE item_cnt = i4 WITH protect, noconstant(0)
   DECLARE level_cnt = i4 WITH protect, noconstant(0)
   DECLARE item_pos = i4 WITH protect, noconstant(0)
   DECLARE type_pos = i4 WITH protect, noconstant(0)
   DECLARE remainder = vc WITH protect, noconstant(" ")
   DECLARE item = vc WITH protect, noconstant(" ")
   DECLARE type = vc WITH protect, noconstant(" ")
   SET item_pos = findstring(item_delim,list)
   SET type_pos = findstring(type_delim,list,1,0)
   IF (item_pos > 0)
    SET item = substring(1,(type_pos - 1),list)
    SET type = substring((type_pos+ 1),((item_pos - type_pos) - 1),list)
    SET remainder = substring((item_pos+ 1),size(list),list)
   ELSE
    SET item = substring(1,(type_pos - 1),list)
    SET type = substring((type_pos+ 1),size(list),list)
   ENDIF
   IF (size(trim(item)) > 0)
    SET level_cnt = size(query->lvl,5)
    SET item_cnt = (size(query->lvl[level_cnt].item,5)+ 1)
    SET query->tot_item_cnt += 1
    SET stat = alterlist(query->lvl[level_cnt].item,item_cnt)
    SET query->lvl[level_cnt].item[item_cnt].name = item
    SET query->lvl[level_cnt].item[item_cnt].dtype = type
   ENDIF
   IF (size(trim(remainder)) > 0)
    CALL PRIVATE::parserecitems(remainder,query)
   ELSE
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE (PRIVATE::buildoutrecord(query=vc(ref)) =null)
   DECLARE lf = c2 WITH protect, constant(char(10))
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE lvl_idx = i4 WITH protect, noconstant(0)
   DECLARE item_idx = i4 WITH protect, noconstant(0)
   DECLARE item_cnt = i4 WITH protect, noconstant(0)
   DECLARE rec_var = vc WITH protect, noconstant(" ")
   IF (validate(parser(out_record)))
    CALL parser(concat("free record ",out_record," go"))
   ENDIF
   SET rec_var = concat("record ",out_record," (",sub)
   SET rec_var = concat(rec_var," 1 qual[*]",sub)
   FOR (lvl_idx = 1 TO size(query->lvl,5))
     FOR (item_idx = 1 TO size(query->lvl[lvl_idx].item,5))
      SET item_cnt += 1
      SET rec_var = build(rec_var," 2 id_",item_cnt," = ",query->lvl[lvl_idx].item[item_idx].dtype)
     ENDFOR
   ENDFOR
   SET rec_var = concat(rec_var," 2 ptr[*]",sub)
   SET item_cnt = 0
   FOR (lvl_idx = 1 TO size(query->lvl,5))
     FOR (item_idx = 1 TO size(query->lvl[lvl_idx].item,5))
      SET item_cnt += 1
      SET rec_var = build(rec_var," 3 id_",item_cnt,"_idx = i4")
     ENDFOR
   ENDFOR
   SET rec_var = build(rec_var,") with persistscript go",sub)
   SET rec_var = replace(rec_var,sub,lf)
   CALL parser(rec_var)
 END ;Subroutine
 SUBROUTINE (PRIVATE::buildselectlist(query=vc(ref)) =null)
   DECLARE lfc = c2 WITH protect, constant(concat(char(10),","))
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE record_path = vc WITH protect, noconstant(" ")
   DECLARE select_var = vc WITH protect, noconstant(" ")
   DECLARE lvl_idx = i4 WITH protect, noconstant(0)
   DECLARE item_idx = i4 WITH protect, noconstant(0)
   DECLARE select_cnt = i4 WITH protect, noconstant(0)
   FOR (lvl_idx = 1 TO size(query->lvl,5))
    SET record_path = trim(build(record_path,sub,query->lvl[lvl_idx].name,"[d",lvl_idx,
      ".seq]"),3)
    FOR (item_idx = 1 TO size(query->lvl[lvl_idx].item,5))
      SET select_cnt += 1
      SET select_var = build("in_record->",record_path,".",query->lvl[lvl_idx].item[item_idx].name)
      IF ((query->lvl[lvl_idx].item[item_idx].dtype="f8"))
       SET select_var = concat("cnvtreal(",select_var,")")
      ELSEIF ((query->lvl[lvl_idx].item[item_idx].dtype IN ("i2", "i4")))
       SET select_var = concat("cnvtint(",select_var,")")
      ELSE
       SET select_var = concat("substring(1, 255, cnvtupper(",select_var,"))")
      ENDIF
      SET select_var = build("id_",select_cnt," = ",select_var)
      SET select_var = replace(select_var,sub,".")
      SET query->select_list = trim(build(query->select_list,sub,select_var),3)
    ENDFOR
   ENDFOR
   SET query->select_list = replace(query->select_list,sub,lfc)
 END ;Subroutine
 SUBROUTINE (PRIVATE::buildfromlist(query=vc(ref)) =null)
   DECLARE lfc = c2 WITH protect, constant(concat(char(10),","))
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE lvl_idx = i4 WITH protect, noconstant(0)
   FOR (lvl_idx = 1 TO size(query->lvl,5))
     SET query->from_list = trim(build(query->from_list,sub,"(dummyt d",lvl_idx),3)
     IF (lvl_idx=1)
      SET query->from_list = concat(query->from_list," with seq = value(size(in_record->",query->lvl[
       lvl_idx].name,",5))")
     ENDIF
     SET query->from_list = build(query->from_list,")")
   ENDFOR
   SET query->from_list = replace(query->from_list,sub,lfc)
 END ;Subroutine
 SUBROUTINE (PRIVATE::buildplanjoinlist(query=vc(ref)) =null)
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE tmp_path = vc WITH protect, noconstant(" ")
   DECLARE tbl = vc WITH protect, noconstant(" ")
   DECLARE keyword = vc WITH protect, noconstant(" ")
   DECLARE record_path = vc WITH protect, noconstant(" ")
   DECLARE lvl_idx = i4 WITH protect, noconstant(0)
   DECLARE item_idx = i4 WITH protect, noconstant(0)
   DECLARE where_used = i2 WITH protect, noconstant(0)
   DECLARE item = vc WITH protect, noconstant(" ")
   FOR (lvl_idx = 1 TO size(query->lvl,5))
     SET where_used = 0
     SET record_path = trim(build(record_path,sub,query->lvl[lvl_idx].name,"[d",lvl_idx,
       ".seq]"),3)
     SET record_path = replace(record_path,sub,".")
     IF (lvl_idx < size(query->lvl,5))
      SET tmp_path = build(record_path,".",query->lvl[(lvl_idx+ 1)].name)
     ENDIF
     IF (lvl_idx=1)
      SET tbl = "PLAN"
     ELSE
      SET tbl = "JOIN"
     ENDIF
     SET tbl = concat(tbl," d",build(lvl_idx))
     IF (lvl_idx < size(query->lvl,5))
      SET tbl = concat(tbl," where maxrec(d",build((lvl_idx+ 1)),", size(in_record->",tmp_path,
       ",5))",sub)
      SET where_used = 1
     ENDIF
     FOR (item_idx = 1 TO size(query->lvl[lvl_idx].item,5))
       SET item = build("in_record->",record_path,".",query->lvl[lvl_idx].item[item_idx].name)
       IF (item_idx=1
        AND where_used=0)
        SET keyword = " WHERE"
       ELSE
        SET keyword = "AND"
       ENDIF
       IF ((query->lvl[lvl_idx].item[item_idx].dtype="f8"))
        SET tbl = concat(tbl,keyword," cnvtreal(",item,") > 0",
         sub)
       ELSEIF ((query->lvl[lvl_idx].item[item_idx].dtype IN ("i2", "i4")))
        SET tbl = concat(tbl,keyword," cnvtint(",item,") > 0",
         sub)
       ELSE
        SET tbl = concat(tbl,keyword," textlen(trim(",item,", 3)) > 0",
         sub)
       ENDIF
     ENDFOR
     SET query->plan_join = build(query->plan_join,sub,tbl)
   ENDFOR
   SET query->plan_join = replace(query->plan_join,sub,lf)
 END ;Subroutine
 SUBROUTINE (PRIVATE::buildorderlist(query=vc(ref)) =null)
   DECLARE lfc = c2 WITH protect, constant(concat(char(10),","))
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE order_cnt = i4 WITH protect, noconstant(0)
   DECLARE lvl_idx = i4 WITH protect, noconstant(0)
   FOR (lvl_idx = 1 TO size(query->lvl,5))
     FOR (item_idx = 1 TO size(query->lvl[lvl_idx].item,5))
      SET order_cnt += 1
      SET query->order_list = trim(build(query->order_list,sub,"id_",order_cnt),3)
     ENDFOR
   ENDFOR
   SET query->order_list = replace(query->order_list,sub,lfc)
 END ;Subroutine
 SUBROUTINE (PRIVATE::buildheadlist(query=vc(ref)) =null)
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE head_cnt = i4 WITH protect, noconstant(0)
   IF ((query->tot_item_cnt > 1))
    FOR (idx = 1 TO (query->tot_item_cnt - 1))
     SET head_cnt += 1
     SET query->head_list = trim(build(query->head_list,sub,"head id_",head_cnt,sub,
       "null"),3)
    ENDFOR
   ENDIF
   SET query->head_list = trim(build(query->head_list,sub,"head id_",query->tot_item_cnt),3)
   SET query->head_list = replace(query->head_list,sub,lf)
 END ;Subroutine
 SUBROUTINE (PRIVATE::buildsavelist(query=vc(ref)) =null)
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE item_idx = i4 WITH protect, noconstant(0)
   DECLARE lvl_idx = i4 WITH protect, noconstant(0)
   DECLARE save_cnt = i4 WITH protect, noconstant(0)
   FOR (lvl_idx = 1 TO size(query->lvl,5))
     FOR (item_idx = 1 TO size(query->lvl[lvl_idx].item,5))
      SET save_cnt += 1
      SET query->save_list = trim(build(query->save_list,sub,out_record,"->qual[cnt].id_",save_cnt,
        " = id_",save_cnt),3)
     ENDFOR
   ENDFOR
   SET query->save_list = replace(query->save_list,sub,lf)
 END ;Subroutine
 SUBROUTINE (PRIVATE::builddetailsavelist(query=vc(ref)) =null)
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE item_idx = i4 WITH protect, noconstant(0)
   DECLARE lvl_idx = i4 WITH protect, noconstant(0)
   DECLARE save_cnt = i4 WITH protect, noconstant(0)
   FOR (lvl_idx = 1 TO size(query->lvl,5))
     FOR (item_idx = 1 TO size(query->lvl[lvl_idx].item,5))
      SET save_cnt += 1
      SET query->det_save_list = trim(build(query->det_save_list,sub,out_record,
        "->qual[cnt].ptr[ptr_idx].id_",save_cnt,
        "_idx = d",lvl_idx,".seq"),3)
     ENDFOR
   ENDFOR
   SET query->det_save_list = replace(query->det_save_list,sub,lf)
 END ;Subroutine
 SUBROUTINE (PRIVATE::buildfootlist(query=vc(ref)) =null)
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE foot_cnt = i4 WITH protect, noconstant(0)
   SET query->foot_list = trim(build(sub,"foot id_",query->tot_item_cnt,sub,"stat = alterlist(",
     out_record,"->qual[cnt].ptr, ptr_idx)"),3)
   IF ((query->tot_item_cnt > 1))
    SET foot_cnt = query->tot_item_cnt
    FOR (idx = 1 TO (query->tot_item_cnt - 1))
     SET foot_cnt -= 1
     SET query->foot_list = trim(build(query->foot_list,sub,"foot id_",foot_cnt,sub,
       "null"),3)
    ENDFOR
   ENDIF
   SET query->foot_list = replace(query->foot_list,sub,lf)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS field_ref_validation
 init
 DECLARE _::found = i1 WITH constant(1)
 DECLARE _::notfound = i1 WITH constant(2)
 DECLARE _::duplicate = i1 WITH constant(3)
 DECLARE _::reevaluate = i1 WITH constant(4)
 DECLARE _::numeric = i1 WITH constant(1)
 DECLARE _::txt = i1 WITH constant(2)
 DECLARE _::key_data_type = i1 WITH noconstant(_::txt)
 RECORD _::reference(
   1 list[*]
     2 display = vc
     2 id = f8
 )
 RECORD _::id(
   1 list[*]
     2 text = vc
     2 value = f8
     2 status_flag = i1
 )
 SUBROUTINE (_::getstatus(idx=i4) =i1)
   RETURN(_::id->list[idx].status_flag)
 END ;Subroutine
 SUBROUTINE (_::getvalue(idx=i4) =i1)
   RETURN(_::id->list[idx].value)
 END ;Subroutine
 SUBROUTINE (_::gettxt(idx=i4) =i1)
   RETURN(_::id->list[idx].text)
 END ;Subroutine
 SUBROUTINE (_::copyreferencedata(record_name=vc,list_name=vc,field_id=vc,field_display=vc) =null)
   DECLARE rec_list = vc WITH protect, noconstant(build(record_name,"->",list_name))
   DECLARE rec_field_id = vc WITH protect, noconstant(build(rec_list,"[d.seq].",field_id))
   DECLARE rec_field_display = vc WITH protect, noconstant(build(rec_list,"[d.seq].",field_display))
   DECLARE rec_size = i4 WITH protect, noconstant(parser(build("size(",rec_list,",5)")))
   SET stat = initrec(_::reference)
   SELECT INTO "nl:"
    id = parser(rec_field_id), display = parser(build("substring(1,500,",rec_field_display,")"))
    FROM (dummyt d  WITH seq = rec_size)
    ORDER BY d.seq
    HEAD REPORT
     stat = alterlist(_::reference->list,rec_size)
    DETAIL
     _::reference->list[d.seq].id = id, _::reference->list[d.seq].display = display
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (_::evaluate(record_name=vc,list_name=vc,field_name=vc,option=i1(value,0)) =null)
   RECORD input_index(
     1 list[*]
       2 key_txt = vc
       2 key_id = f8
       2 instance[*]
         3 ptr = i4
   ) WITH protect
   RECORD reference_index(
     1 list[*]
       2 txt = vc
       2 id = f8
       2 duplicate_ind = i2
   ) WITH protect
   DECLARE reevaluate_ind = i1 WITH protect, noconstant(0)
   DECLARE rec_list_field = vc WITH protect, noconstant(build(record_name,"->",list_name,"[d.seq].",
     field_name))
   DECLARE rec_list = vc WITH protect, noconstant(build(record_name,"->",list_name))
   DECLARE rec_list_size = i4 WITH protect, noconstant(parser(build("size(",rec_list,",5)")))
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE ptr = i4 WITH protect, noconstant(0)
   DECLARE item = i4 WITH protect, noconstant(0)
   DECLARE inst = i4 WITH protect, noconstant(0)
   IF ((option=_::reevaluate))
    SET _::key_data_type = _::numeric
   ELSE
    SET _::key_data_type = _::txt
   ENDIF
   SELECT
    IF ((_::key_data_type=_::numeric))
     key_value = parser(build("cnvtreal(",rec_list_field,")"))
     PLAN (d
      WHERE (_::id->list[d.seq].status_flag=_::reevaluate))
    ELSE
    ENDIF
    INTO "nl:"
    key_value = parser(build("cnvtupper(substring(1,500,",rec_list_field,"))"))
    FROM (dummyt d  WITH seq = rec_list_size)
    PLAN (d
     WHERE parser(build("size(trim(",rec_list_field,")) > 0")))
    ORDER BY key_value
    HEAD REPORT
     k_cnt = 0
    HEAD key_value
     k_cnt += 1
     IF (k_cnt > size(input_index->list,5))
      stat = alterlist(input_index->list,(k_cnt+ 10000))
     ENDIF
     CALL PRIVATE::saveinputkey(0), p_cnt = 0
    DETAIL
     p_cnt += 1
     IF (p_cnt > size(input_index->list[k_cnt].instance,5))
      stat = alterlist(input_index->list[k_cnt].instance,(p_cnt+ 10000))
     ENDIF
     input_index->list[k_cnt].instance[p_cnt].ptr = d.seq
    FOOT  key_value
     stat = alterlist(input_index->list[k_cnt].instance,p_cnt)
    FOOT REPORT
     stat = alterlist(input_index->list,k_cnt)
    WITH nocounter
   ;end select
   SELECT
    IF ((_::key_data_type=_::numeric))
     key_value = _::reference->list[d.seq].id, id = _::reference->list[d.seq].id
    ELSE
     key_value = cnvtupper(substring(1,200,_::reference->list[d.seq].display)), id = _::reference->
     list[d.seq].id
    ENDIF
    INTO "nl:"
    FROM (dummyt d  WITH seq = size(_::reference->list,5))
    ORDER BY key_value, id
    HEAD REPORT
     cnt = 0
    HEAD key_value
     cnt += 1
     IF (cnt > size(reference_index->list,5))
      stat = alterlist(reference_index->list,(cnt+ 999))
     ENDIF
     CALL PRIVATE::savereferencekey(0), reference_index->list[cnt].id = id, instance_cnt = 0
    DETAIL
     instance_cnt += 1
    FOOT  key_value
     IF (instance_cnt > 1)
      reference_index->list[cnt].duplicate_ind = true
     ENDIF
     stat = alterlist(reference_index->list,cnt)
    WITH nocounter
   ;end select
   IF ((option != _::reevaluate))
    SET stat = initrec(_::id)
    SET stat = alterlist(_::id->list,rec_list_size)
   ENDIF
   FOR (item = 1 TO size(input_index->list,5))
    IF ((_::key_data_type=_::numeric))
     SET pos = locatevalsort(idx,1,size(reference_index->list,5),input_index->list[item].key_id,
      reference_index->list[idx].id)
    ELSE
     SET pos = locatevalsort(idx,1,size(reference_index->list,5),input_index->list[item].key_txt,
      reference_index->list[idx].txt)
    ENDIF
    FOR (inst = 1 TO size(input_index->list[item].instance,5))
     SET ptr = input_index->list[item].instance[inst].ptr
     IF (pos > 0)
      IF ( NOT (reference_index->list[pos].duplicate_ind))
       SET _::id->list[ptr].text = reference_index->list[pos].txt
       SET _::id->list[ptr].value = reference_index->list[pos].id
       SET _::id->list[ptr].status_flag = _::found
      ELSE
       SET _::id->list[ptr].status_flag = _::duplicate
      ENDIF
     ELSE
      IF ((option != _::reevaluate)
       AND isnumeric(input_index->list[item].key_txt) > 0)
       SET _::id->list[ptr].status_flag = _::reevaluate
       SET reevaluate_ind = true
      ELSE
       SET _::id->list[ptr].status_flag = _::notfound
      ENDIF
     ENDIF
    ENDFOR
   ENDFOR
   IF (reevaluate_ind)
    CALL _::evaluate(record_name,list_name,field_name,_::reevaluate)
   ENDIF
 END ;Subroutine
 DECLARE PRIVATE::saveinputkey(null) = null
 SUBROUTINE PRIVATE::saveinputkey(null)
   IF ((_::key_data_type=_::numeric))
    SET input_index->list[k_cnt].key_id = key_value
   ELSE
    SET input_index->list[k_cnt].key_txt = key_value
   ENDIF
 END ;Subroutine
 DECLARE PRIVATE::savereferencekey(null) = null
 SUBROUTINE PRIVATE::savereferencekey(null)
   IF ((_::key_data_type=_::numeric))
    SET reference_index->list[cnt].id = key_value
   ELSE
    SET reference_index->list[cnt].txt = key_value
   ENDIF
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS hash_map_i4 FROM hash_map
 init
 DECLARE PRIVATE::map(mode=vc,map_key=vc,map_val=i4) = i4 WITH map = "HASH"
 SUBROUTINE (_::find(map_key=vc) =i4)
   DECLARE status = i1 WITH protect, noconstant(- (1))
   DECLARE map_val = i4 WITH protect, noconstant(- (1))
   SET status = PRIVATE::perform("FIND",map_key,map_val)
   RETURN(map_val)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS hash_map
 init
 SUBROUTINE (_::add(map_key=vc,map_val=vc) =i1)
   DECLARE status = i1 WITH protect, noconstant(- (1))
   SET status = PRIVATE::perform("ADD",map_key,map_val)
   RETURN(status)
 END ;Subroutine
 DECLARE _::_print(null) = i1
 SUBROUTINE _::_print(null)
   DECLARE status = i1 WITH protect, noconstant(- (1))
   SET status = PRIVATE::map("PRINT")
   RETURN(status)
 END ;Subroutine
 SUBROUTINE (_::export(rec=vc(ref)) =null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SET stat = initrec(rec)
   CALL alterlist(rec->list,PRIVATE::map("COUNT"))
   FOR (idx = 1 TO size(rec->list,5))
     SET stat = PRIVATE::map("LOC",idx,rec->list[idx].key,rec->list[idx].val)
   ENDFOR
 END ;Subroutine
 SUBROUTINE (PRIVATE::perform(mode=vc,map_key=vc,map_val=vc(ref)) =i1)
   DECLARE status = i1 WITH protect, noconstant(- (1))
   CASE (substring(1,1,reflect(map_key)))
    OF "C":
     SET map_key = cnvtupper(trim(map_key,3))
   ENDCASE
   SET status = PRIVATE::map(value(trim(cnvtupper(mode),3)),map_key,map_val)
   RETURN(status)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS ctp_file_output
 init
 CALL echo("+++ ctp_file_output instantiated")
 RECORD PRIVATE::grid(
   1 row[*]
     2 col[*]
       3 txt = vc
 )
 DECLARE PRIVATE::by_column = i2 WITH constant(0)
 DECLARE PRIVATE::by_row = i2 WITH constant(1)
 DECLARE PRIVATE::start_column = i4 WITH constant(0)
 DECLARE PRIVATE::start_row = i4 WITH constant(0)
 DECLARE PRIVATE::file_name = vc WITH noconstant(" ")
 DECLARE PRIVATE::current_column = i4 WITH noconstant(PRIVATE::start_column)
 DECLARE PRIVATE::current_row = i4 WITH noconstant(PRIVATE::start_row)
 DECLARE PRIVATE::batch_size = i4 WITH noconstant(10000)
 DECLARE PRIVATE::max_columns = i4 WITH noconstant(0)
 IF ( NOT (validate(PRIVATE::date_format)))
  DECLARE PRIVATE::date_format = vc WITH constant("DD-MMM-YYYY HH:MM:SS;;q")
 ENDIF
 DECLARE _::initialize(file_name=vc,batch_size=i4(value,0)) = null
 SUBROUTINE _::initialize(file_name,batch_size)
  SET PRIVATE::file_name = file_name
  IF (batch_size > 0)
   SET PRIVATE::batch_size = batch_size
  ENDIF
 END ;Subroutine
 DECLARE _::getfilename(null) = null
 SUBROUTINE _::getfilename(null)
   RETURN(PRIVATE::file_name)
 END ;Subroutine
 SUBROUTINE (_::addheader(txt=vc) =null)
   SET PRIVATE::current_row = PRIVATE::start_row
   CALL PRIVATE::increment(PRIVATE::by_column)
   CALL PRIVATE::increment(PRIVATE::by_row)
   IF (size(private::grid->row,5)=0)
    SET stat = alterlist(private::grid->row,1)
   ENDIF
   SET stat = alterlist(private::grid->row[PRIVATE::current_row].col,PRIVATE::current_column)
   SET private::grid->row[PRIVATE::current_row].col[PRIVATE::current_column].txt = cnvtupper(trim(txt,
     3))
   SET PRIVATE::max_columns = PRIVATE::current_column
 END ;Subroutine
 SUBROUTINE (_::setrowsizeif(row_size=i4,batch_ind=i2(value,0)) =null)
  DECLARE new_size = i4 WITH protect, noconstant(0)
  IF (row_size > size(private::grid->row,5))
   IF (batch_ind)
    SET new_size = (row_size+ PRIVATE::batch_size)
   ELSE
    SET new_size = row_size
   ENDIF
   SET stat = alterlist(private::grid->row,new_size)
  ENDIF
 END ;Subroutine
 SUBROUTINE (_::setcolumnsize(row_number=i4) =null)
   SET stat = alterlist(private::grid->row[row_number].col,PRIVATE::max_columns)
 END ;Subroutine
 DECLARE _::nextrow(null) = null
 SUBROUTINE _::nextrow(null)
   DECLARE increment_by_batchsize = i2 WITH protect, constant(1)
   CALL PRIVATE::increment(PRIVATE::by_row)
   SET PRIVATE::current_column = PRIVATE::start_column
   CALL _::setrowsizeif(PRIVATE::current_row,increment_by_batchsize)
   CALL _::setcolumnsize(PRIVATE::current_row)
 END ;Subroutine
 SUBROUTINE (_::addvalue(value=vc,direction=i2(value,0)) =i2)
  DECLARE data_type = c1 WITH protect, noconstant(cnvtupper(reflect(value)))
  CASE (data_type)
   OF "C":
    CALL _::addtxt(value,direction)
   OF "G":
    CALL _::addtxt(" ",direction)
   OF "I":
    CALL _::addint(value,direction)
   OF "F":
    CALL _::addreal(value,0,direction)
   ELSE
    CALL cclexception(900,"E","REFLECT(unknown data type)")
  ENDCASE
 END ;Subroutine
 SUBROUTINE (_::addtxt(txt=vc,direction=i2(value,0)) =null)
  CALL PRIVATE::increment(direction)
  SET private::grid->row[PRIVATE::current_row].col[PRIVATE::current_column].txt = check(txt)
 END ;Subroutine
 SUBROUTINE (_::addreal(real=f8,option=i2(value,0),direction=i2(value,0)) =null)
   DECLARE formatted = vc WITH protect, noconstant(" ")
   CASE (option)
    OF 0:
    OF 1:
     SET formatted = trim(format(real,"############.#####;T(1)"),3)
    OF 2:
     SET formatted = trim(format(real,"############.#####;T(2)"),3)
    OF 3:
     SET formatted = cnvtstring(real,19,2)
    ELSE
     SET formatted = trim(format(real,"############.#####;T(1)"),3)
   ENDCASE
   CALL PRIVATE::increment(direction)
   SET private::grid->row[PRIVATE::current_row].col[PRIVATE::current_column].txt = formatted
 END ;Subroutine
 SUBROUTINE (_::addint(int=i4,direction=i2(value,0)) =null)
  CALL PRIVATE::increment(direction)
  SET private::grid->row[PRIVATE::current_row].col[PRIVATE::current_column].txt = cnvtstring(int,19)
 END ;Subroutine
 SUBROUTINE (_::adddttm(dttm=dq8,date_format=vc(value," "),direction=i2(value,0)) =null)
   CALL PRIVATE::increment(direction)
   IF (size(trim(date_format))=0)
    SET date_format = PRIVATE::date_format
   ENDIF
   SET private::grid->row[PRIVATE::current_row].col[PRIVATE::current_column].txt = format(dttm,
    date_format)
 END ;Subroutine
 SUBROUTINE (_::addind(ind=i2,direction=i2(value,0)) =null)
  CALL PRIVATE::increment(direction)
  SET private::grid->row[PRIVATE::current_row].col[PRIVATE::current_column].txt = evaluate(ind,1,"X",
   " ")
 END ;Subroutine
 SUBROUTINE (_::addlist(rec_name=vc,list_name=vc,item_name=vc) =null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE full_item_path = vc WITH protect, noconstant(" ")
   DECLARE list_size = i4 WITH protect, noconstant(size(parser(build(rec_name,"->",list_name)),5))
   SET full_item_path = build(rec_name,"->",list_name,"[idx].",item_name)
   CALL _::setrowsizeif((list_size+ 1))
   FOR (idx = 1 TO list_size)
     CALL _::addsingle(parser(full_item_path))
   ENDFOR
 END ;Subroutine
 SUBROUTINE (_::addsingle(value=vc) =null WITH protect)
   DECLARE next_row = i4 WITH protect, noconstant((PRIVATE::current_row+ 1))
   CALL _::setrowsizeif(next_row)
   CALL _::setcolumnsize(next_row)
   CALL _::addvalue(value,PRIVATE::by_row)
 END ;Subroutine
 SUBROUTINE (PRIVATE::increment(direction=i2) =null)
   IF ((direction=PRIVATE::by_row))
    SET PRIVATE::current_row += 1
   ELSE
    SET PRIVATE::current_column += 1
   ENDIF
 END ;Subroutine
 SUBROUTINE (_::delimitedoutput(delim=vc,resize=i2(value,0),append_ind=i2(value,0)) =i2)
   RECORD out_file(
     1 file_desc = i4
     1 file_name = vc
     1 file_buf = vc
     1 file_dir = i4
     1 file_offset = i4
   ) WITH protect
   DECLARE enq = c1 WITH protect, constant(char(5))
   DECLARE cr = c1 WITH protect, constant(char(13))
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE q = c1 WITH protect, constant('"')
   DECLARE start_row = i4 WITH protect, noconstant(1)
   DECLARE r = i4 WITH protect, noconstant(0)
   DECLARE c = i4 WITH protect, noconstant(0)
   DECLARE line = vc WITH protect, noconstant(" ")
   DECLARE str = vc WITH protect, noconstant(" ")
   DECLARE q_ind = i2 WITH protect, noconstant(0)
   IF (resize)
    SET stat = alterlist(private::grid->row,PRIVATE::current_row)
   ENDIF
   SET out_file->file_name = PRIVATE::file_name
   SET out_file->file_buf = evaluate(append_ind,1,"a","w")
   SET stat = cclio("OPEN",out_file)
   IF (stat=1)
    FOR (r = start_row TO size(private::grid->row,5))
      SET line = " "
      FOR (c = 1 TO size(private::grid->row[r].col,5))
        SET str = private::grid->row[r].col[c].txt
        IF (findstring(q,str) > 0)
         SET str = replace(str,q,fillstring(2,q))
         SET q_ind = true
        ELSE
         SET q_ind = false
        ENDIF
        IF (((findstring(delim,str) > 0) OR (q_ind)) )
         IF (c=1)
          SET line = build(q,str,q)
         ELSE
          SET line = build(line,enq,q,str,q)
         ENDIF
        ELSE
         IF (c=1)
          SET line = str
         ELSE
          SET line = build(line,enq,str)
         ENDIF
        ENDIF
      ENDFOR
      SET line = trim(line)
      IF (size(line) > 0)
       SET line = replace(line,enq,delim)
       SET out_file->file_buf = build(line,cr,lf)
       SET stat = cclio("WRITE",out_file)
       IF (stat=0)
        CALL cclexception(900,"E","CCLIO:Could not write to the file!")
        RETURN(0)
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    CALL cclexception(900,"E","CCLIO:Could not open file!")
    RETURN(0)
   ENDIF
   SET stat = cclio("CLOSE",out_file)
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 final
 CALL echo("--- ctp_file_output out of scope")
 END; class scope:final
 WITH copy = 1
 CREATE CLASS sn_org_surg_areas
 init
 CALL echo("+++ sn_org_surg_areas instantiated")
 DECLARE _::ld = f8 WITH noconstant(0.0), protect
 RECORD org_areas(
   1 prsnl_id = f8
   1 prsnl_logical_domain_id = f8
   1 org[1]
     2 org_id = f8
     2 org_name = vc
     2 area[*]
       3 area_cd = f8
       3 area_disp = vc
 ) WITH protect
 SUBROUTINE (_::getsurgareas(org=f8,orgidx=i4) =i2)
   DECLARE success = i2 WITH noconstant(0), protect
   DECLARE cnt = i4 WITH noconstant(0), protect
   DECLARE area_code_set_221 = i4 WITH constant(221), protect
   DECLARE surg_area_svc_res_type_223 = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!2867")),
   protect
   SELECT INTO "nl:"
    FROM organization o,
     service_resource sr,
     code_value sa
    PLAN (o
     WHERE o.organization_id=org
      AND o.active_ind=true
      AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND o.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND (o.logical_domain_id=_::ld))
     JOIN (sr
     WHERE sr.organization_id=o.organization_id
      AND sr.service_resource_type_cd=surg_area_svc_res_type_223
      AND sr.active_ind=true
      AND sr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND sr.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (sa
     WHERE sa.code_value=sr.service_resource_cd
      AND sa.code_set=area_code_set_221
      AND sa.active_ind=true
      AND sa.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND sa.end_effective_dt_tm > cnvtdatetime(sysdate))
    ORDER BY sa.code_value
    HEAD REPORT
     success = 1
    HEAD sa.code_value
     cnt += 1
     IF (mod(cnt,10)=1)
      stat = alterlist(org_areas->org[1].area,(cnt+ 9))
     ENDIF
     org_areas->org[1].area[cnt].area_cd = sa.code_value, org_areas->org[1].area[cnt].area_disp = sa
     .display
    FOOT  sa.code_value
     placeholder = 1
    FOOT REPORT
     stat = alterlist(org_areas->org[1].area,cnt)
    WITH nocounter
   ;end select
   SET stat = moverec(org_areas->org[1].area,sn_org_areas->org[orgidx].area)
   RETURN(success)
 END ;Subroutine
 END; class scope:init
 final
 CALL echo("--- sn_org_surg_areas out of scope")
 END; class scope:final
 WITH copy = 1
 CREATE CLASS sn_pref_card_pick_build
 init
 CALL echo("+++ sn_pref_card_pick_build instantiated")
 RECORD _::orgdomainbuild(
   1 list[*]
     2 org_name = vc
     2 org_id = f8
     2 pref_card_id = f8
     2 surg_area = vc
     2 surg_area_cd = f8
     2 doc_type = vc
     2 doc_type_cd = f8
     2 procedure = vc
     2 catalog_cd = f8
     2 provider = vc
     2 person_id = f8
     2 pc_pl_id = f8
     2 item_id = f8
     2 specialty = vc
     2 specialty_cd = f8
     2 prsnl_grp_id = f8
     2 item_number = vc
     2 description = vc
     2 clin_desc = vc
     2 open_qty = i4
     2 hold_qty = i4
     2 item_updt_cnt = i4
 ) WITH protect
 DECLARE _::ld = f8 WITH noconstant(0.0), protect
 SUBROUTINE (_::getdomainbuild(orgidx=i4,orgname=vc,orgid=f8) =i2)
   DECLARE cnt = i4 WITH noconstant(0), protect
   DECLARE success = i4 WITH noconstant(0), protect
   DECLARE areaidx = i4 WITH noconstant(0), protect
   DECLARE item_nbr_ident_type_cd_11000 = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3292")),
   protect
   DECLARE desc_ident_type_cd_11000 = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3290")),
   protect
   DECLARE clin_desc_ident_type_cd_11000 = f8 WITH constant(uar_get_code_by_cki(
     "CKI.CODEVALUE!3166806")), protect
   DECLARE item_master_item_type_cd_11001 = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3308"
     )), protect
   DECLARE equip_master_item_type_cd_11001 = f8 WITH constant(uar_get_code_by_cki(
     "CKI.CODEVALUE!3309")), protect
   DECLARE surgical_spec_mean = vc WITH constant("SURGSPEC"), protect
   DECLARE prsnl_group_type_code_set_357 = i4 WITH constant(357), protect
   DECLARE doc_type_code_set_14258 = i4 WITH constant(14258), protect
   DECLARE ornurse_doc_type_mean = vc WITH constant("ORNURSE"), protect
   DECLARE surgery_cat_type_cd_200 = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3084")),
   protect
   DECLARE surgery_act_type_cd_106 = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!2826")),
   protect
   SELECT INTO "nl:"
    FROM preference_card pc,
     (left JOIN order_catalog oc ON oc.catalog_cd=pc.catalog_cd
      AND oc.catalog_type_cd=surgery_cat_type_cd_200
      AND oc.activity_type_cd=surgery_act_type_cd_106
      AND oc.active_ind=true),
     (left JOIN prsnl pnl ON pnl.person_id=pc.prsnl_id
      AND (pnl.logical_domain_id=_::ld)),
     (left JOIN prsnl_group pnlg ON pnlg.prsnl_group_id=pc.surg_specialty_id
      AND pnlg.active_ind=true
      AND pnlg.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND pnlg.end_effective_dt_tm > cnvtdatetime(sysdate)),
     (left JOIN code_value cv ON cv.code_value=pnlg.prsnl_group_type_cd
      AND cv.active_ind=true
      AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND cv.code_set=prsnl_group_type_code_set_357
      AND cv.cdf_meaning=surgical_spec_mean),
     code_value dt,
     pref_card_pick_list pcpl,
     (left JOIN item_definition id ON id.item_id=pcpl.item_id
      AND id.active_ind=true
      AND id.item_type_cd IN (item_master_item_type_cd_11001, equip_master_item_type_cd_11001)
      AND (id.logical_domain_id=_::ld)),
     (left JOIN object_identifier_index oii ON oii.object_id=id.item_id
      AND oii.active_ind=true
      AND oii.generic_object=0
      AND oii.identifier_type_cd IN (item_nbr_ident_type_cd_11000, desc_ident_type_cd_11000,
     clin_desc_ident_type_cd_11000)
      AND (oii.logical_domain_id=_::ld))
    PLAN (pc
     WHERE expand(areaidx,1,size(sn_org_areas->org[orgidx].area,5),pc.surg_area_cd,sn_org_areas->org[
      orgidx].area[areaidx].area_cd)
      AND pc.active_ind=true)
     JOIN (oc)
     JOIN (pnl)
     JOIN (pnlg)
     JOIN (cv)
     JOIN (dt
     WHERE dt.code_value=pc.doc_type_cd
      AND dt.active_ind=true
      AND dt.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND dt.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND dt.code_set=doc_type_code_set_14258
      AND dt.cdf_meaning=ornurse_doc_type_mean)
     JOIN (pcpl
     WHERE pcpl.pref_card_id=pc.pref_card_id
      AND pcpl.active_ind=true
      AND pcpl.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND pcpl.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (id)
     JOIN (oii)
    ORDER BY pc.pref_card_id, pcpl.pref_card_pick_list_id
    HEAD REPORT
     placeholder = 1
    HEAD pc.pref_card_id
     placeholder = 1
    HEAD pcpl.pref_card_pick_list_id
     IF (oii.object_identifier_index_id > 0.0)
      cnt += 1
      IF (mod(cnt,100)=1)
       stat = alterlist(_::orgdomainbuild->list,(cnt+ 99))
      ENDIF
      _::orgdomainbuild->list[cnt].org_name = orgname, _::orgdomainbuild->list[cnt].org_id = orgid,
      _::orgdomainbuild->list[cnt].pref_card_id = pc.pref_card_id,
      _::orgdomainbuild->list[cnt].surg_area = uar_get_code_display(pc.surg_area_cd), _::
      orgdomainbuild->list[cnt].surg_area_cd = pc.surg_area_cd, _::orgdomainbuild->list[cnt].doc_type
       = uar_get_code_display(pc.doc_type_cd),
      _::orgdomainbuild->list[cnt].doc_type_cd = pc.doc_type_cd, _::orgdomainbuild->list[cnt].
      catalog_cd = pc.catalog_cd, _::orgdomainbuild->list[cnt].procedure = oc.primary_mnemonic,
      _::orgdomainbuild->list[cnt].provider = pnl.name_full_formatted, _::orgdomainbuild->list[cnt].
      person_id = pc.prsnl_id, _::orgdomainbuild->list[cnt].pc_pl_id = pcpl.pref_card_pick_list_id,
      _::orgdomainbuild->list[cnt].item_id = pcpl.item_id, _::orgdomainbuild->list[cnt].specialty =
      pnlg.prsnl_group_name, _::orgdomainbuild->list[cnt].specialty_cd = cv.code_value,
      _::orgdomainbuild->list[cnt].prsnl_grp_id = pnlg.prsnl_group_id, _::orgdomainbuild->list[cnt].
      open_qty = pcpl.request_open_qty, _::orgdomainbuild->list[cnt].hold_qty = pcpl.request_hold_qty,
      _::orgdomainbuild->list[cnt].item_updt_cnt = pcpl.updt_cnt
     ENDIF
    DETAIL
     IF (oii.object_identifier_index_id > 0.0)
      CASE (oii.identifier_type_cd)
       OF item_nbr_ident_type_cd_11000:
        _::orgdomainbuild->list[cnt].item_number = oii.value
       OF desc_ident_type_cd_11000:
        _::orgdomainbuild->list[cnt].description = oii.value
       OF clin_desc_ident_type_cd_11000:
        _::orgdomainbuild->list[cnt].clin_desc = oii.value
      ENDCASE
     ENDIF
    FOOT  pcpl.pref_card_pick_list_id
     placeholder = 1
    FOOT  pc.pref_card_id
     placeholder = 1
    FOOT REPORT
     stat = alterlist(_::orgdomainbuild->list,cnt)
    WITH nocounter, expand = 2
   ;end select
   IF (size(_::orgdomainbuild->list,5) > 0)
    SET stat = movereclist(_::orgdomainbuild->list,domainbuild->list,1,size(domainbuild->list,5),cnt,
     true)
    SET success = 1
   ENDIF
   RETURN(success)
 END ;Subroutine
 END; class scope:init
 final
 CALL echo("--- sn_pref_card_pick_build out of scope")
 END; class scope:final
 WITH copy = 1
 CREATE CLASS sn_org_surg_area_procs
 init
 CALL echo("+++ sn_org_surg_area_procs instantiated")
 RECORD _::area_proc_ref(
   1 list[*]
     2 org_id = f8
     2 org_name = vc
     2 area_cd = f8
     2 area_disp = vc
     2 proc_cat_cd = f8
     2 prim_mnem = vc
 ) WITH protect
 SUBROUTINE (_::getprocs(orgidx=i4,orgname=vc,orgid=f8) =i2)
   DECLARE cnt = i4 WITH noconstant(0), protect
   DECLARE success = i4 WITH noconstant(0), protect
   DECLARE areaidx = i4 WITH noconstant(0), protect
   DECLARE surgery_cat_type_cd_200 = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3084")),
   protect
   DECLARE surgery_act_type_cd_106 = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!2826")),
   protect
   DECLARE primary_mnem_type_cd_6011 = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3128")),
   protect
   SELECT INTO "nl:"
    FROM surgical_procedure p,
     order_catalog oc,
     surg_proc_detail spd,
     order_catalog_synonym ocs
    PLAN (p)
     JOIN (oc
     WHERE oc.catalog_cd=p.catalog_cd
      AND oc.catalog_type_cd=surgery_cat_type_cd_200
      AND oc.activity_type_cd=surgery_act_type_cd_106
      AND oc.active_ind=true)
     JOIN (spd
     WHERE spd.catalog_cd=oc.catalog_cd
      AND expand(areaidx,1,size(sn_org_areas->org[orgidx].area,5),spd.surg_area_cd,sn_org_areas->org[
      orgidx].area[areaidx].area_cd))
     JOIN (ocs
     WHERE ocs.catalog_cd=spd.catalog_cd
      AND ocs.mnemonic_type_cd=primary_mnem_type_cd_6011
      AND ocs.active_ind=true)
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt += 1
     IF (mod(cnt,100)=1)
      stat = alterlist(_::area_proc_ref->list,(cnt+ 99))
     ENDIF
     _::area_proc_ref->list[cnt].org_id = orgid, _::area_proc_ref->list[cnt].org_name = orgname, _::
     area_proc_ref->list[cnt].area_cd = spd.surg_area_cd,
     _::area_proc_ref->list[cnt].area_disp = uar_get_code_display(spd.surg_area_cd), _::area_proc_ref
     ->list[cnt].proc_cat_cd = oc.catalog_cd, _::area_proc_ref->list[cnt].prim_mnem = oc
     .primary_mnemonic
    FOOT REPORT
     stat = alterlist(_::area_proc_ref->list,cnt)
    WITH nocounter, expand = 2
   ;end select
   IF (size(_::area_proc_ref->list,5) > 0)
    SET stat = movereclist(_::area_proc_ref->list,area_proc_ref->list,1,size(area_proc_ref->list,5),
     cnt,
     true)
    SET success = 1
   ENDIF
   RETURN(success)
 END ;Subroutine
 END; class scope:init
 final
 CALL echo("--- sn_org_surg_area_procs out of scope")
 END; class scope:final
 WITH copy = 1
 CREATE CLASS sn_org_surg_area_docs
 init
 CALL echo("+++ sn_org_surg_area_docs instantiated")
 RECORD _::area_doc_ref(
   1 list[*]
     2 org_id = f8
     2 org_name = vc
     2 area_cd = f8
     2 area_disp = vc
     2 doc_type_cd = f8
     2 doc_type = vc
     2 doc_ref_id = f8
 ) WITH protect
 SUBROUTINE (_::getdocs(orgidx=i4,orgname=vc,orgid=f8) =i2)
   DECLARE cnt = i4 WITH noconstant(0), protect
   DECLARE success = i4 WITH noconstant(0), protect
   DECLARE areaidx = i4 WITH noconstant(0), protect
   DECLARE area_code_set_221 = i4 WITH constant(221), protect
   DECLARE surg_area_cd_mean = vc WITH constant("SURGAREA"), protect
   DECLARE ornurse_doc_type_mean = vc WITH constant("ORNURSE"), protect
   SELECT INTO "nl:"
    FROM code_value sa,
     sn_doc_ref ref,
     code_value doc
    PLAN (sa
     WHERE sa.code_set=area_code_set_221
      AND sa.active_ind=true
      AND sa.cdf_meaning=surg_area_cd_mean
      AND expand(areaidx,1,size(sn_org_areas->org[orgidx].area,5),sa.code_value,sn_org_areas->org[
      orgidx].area[areaidx].area_cd))
     JOIN (ref
     WHERE ref.area_cd=sa.code_value)
     JOIN (doc
     WHERE doc.code_value=ref.doc_type_cd
      AND doc.cdf_meaning=ornurse_doc_type_mean)
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt += 1
     IF (mod(cnt,100)=1)
      stat = alterlist(_::area_doc_ref->list,(cnt+ 99))
     ENDIF
     _::area_doc_ref->list[cnt].org_id = orgid, _::area_doc_ref->list[cnt].org_name = orgname, _::
     area_doc_ref->list[cnt].area_cd = sa.code_value,
     _::area_doc_ref->list[cnt].area_disp = uar_get_code_display(sa.code_value), _::area_doc_ref->
     list[cnt].doc_type_cd = ref.doc_type_cd, _::area_doc_ref->list[cnt].doc_type =
     uar_get_code_display(ref.doc_type_cd),
     _::area_doc_ref->list[cnt].doc_ref_id = ref.doc_ref_id
    FOOT REPORT
     stat = alterlist(_::area_doc_ref->list,cnt)
    WITH nocounter, expand = 2
   ;end select
   IF (size(_::area_doc_ref->list,5) > 0)
    SET stat = movereclist(_::area_doc_ref->list,area_doc_ref->list,1,size(area_doc_ref->list,5),cnt,
     true)
    SET success = 1
   ENDIF
   RETURN(success)
 END ;Subroutine
 END; class scope:init
 final
 CALL echo("--- sn_org_surg_area_docs out of scope")
 END; class scope:final
 WITH copy = 1
 CREATE CLASS sn_physicians
 init
 CALL echo("+++ sn_physicians instantiated")
 RECORD _::physicians(
   1 list[*]
     2 person_id = f8
     2 name_full = vc
     2 position = vc
 ) WITH protect
 DECLARE _::ld = f8 WITH noconstant(0.0), protect
 DECLARE _::getprsnlspec(null) = i2
 SUBROUTINE _::getprsnlspec(null)
   DECLARE cnt = i4 WITH noconstant(0), protect
   DECLARE success = i4 WITH noconstant(0), protect
   DECLARE prsnl_group_type_code_set_357 = i4 WITH constant(357), protect
   DECLARE surgical_spec_mean = vc WITH constant("SURGSPEC"), protect
   DECLARE auth_ver_data_status_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!2628")),
   protect
   SELECT INTO "nl:"
    FROM prsnl pnl
    PLAN (pnl
     WHERE pnl.physician_ind=true
      AND (pnl.logical_domain_id=_::ld)
      AND pnl.active_ind=true
      AND pnl.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND pnl.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND pnl.data_status_cd=auth_ver_data_status_cd)
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt += 1
     IF (mod(cnt,100)=1)
      stat = alterlist(_::physicians->list,(cnt+ 99))
     ENDIF
     _::physicians->list[cnt].person_id = pnl.person_id, _::physicians->list[cnt].name_full = pnl
     .name_full_formatted, _::physicians->list[cnt].position = uar_get_code_display(pnl.position_cd)
    FOOT REPORT
     stat = alterlist(_::physicians->list,cnt)
    WITH nocounter
   ;end select
   IF (size(_::physicians->list,5) > 0)
    SET stat = movereclist(_::physicians->list,physicians->list,1,size(physicians->list,5),cnt,
     true)
    SET success = 1
   ENDIF
   RETURN(success)
 END ;Subroutine
 END; class scope:init
 final
 CALL echo("--- sn_physicians out of scope")
 END; class scope:final
 WITH copy = 1
 CREATE CLASS sn_specialties
 init
 CALL echo("+++ sn_specialties instantiated")
 RECORD _::surg_specialties(
   1 list[*]
     2 prsnl_grp_id = f8
     2 spec_cd = f8
     2 specialty = vc
 ) WITH protect
 DECLARE _::getsnspecs(null) = i2
 SUBROUTINE _::getsnspecs(null)
   DECLARE cnt = i4 WITH noconstant(0), protect
   DECLARE success = i4 WITH noconstant(0), protect
   DECLARE prsnl_group_type_code_set_357 = i4 WITH constant(357), protect
   DECLARE surgical_spec_mean = vc WITH constant("SURGSPEC"), protect
   SELECT INTO "nl:"
    FROM code_value c,
     prsnl_group pg
    PLAN (c
     WHERE c.code_set=prsnl_group_type_code_set_357
      AND c.cdf_meaning=surgical_spec_mean
      AND c.active_ind=true
      AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND c.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (pg
     WHERE pg.prsnl_group_type_cd=c.code_value
      AND pg.active_ind=true
      AND pg.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND pg.end_effective_dt_tm > cnvtdatetime(sysdate))
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt += 1
     IF (mod(cnt,100)=1)
      stat = alterlist(_::surg_specialties->list,(cnt+ 99))
     ENDIF
     _::surg_specialties->list[cnt].prsnl_grp_id = pg.prsnl_group_id, _::surg_specialties->list[cnt].
     spec_cd = pg.prsnl_group_type_cd, _::surg_specialties->list[cnt].specialty = pg.prsnl_group_name
    FOOT REPORT
     stat = alterlist(_::surg_specialties->list,cnt)
    WITH nocounter
   ;end select
   IF (size(_::surg_specialties->list,5) > 0)
    SET stat = movereclist(_::surg_specialties->list,surg_specialties->list,1,size(surg_specialties->
      list,5),cnt,
     true)
    SET success = 1
   ENDIF
   RETURN(success)
 END ;Subroutine
 END; class scope:init
 final
 CALL echo("--- sn_specialties out of scope")
 END; class scope:final
 WITH copy = 1
 CREATE CLASS sn_pick_list_items
 init
 CALL echo("+++ sn_pick_list_items instantiated")
 RECORD _::pick_list_items(
   1 list[*]
     2 item_org_id = f8
     2 item_org = vc
     2 item_id = f8
     2 item_number = vc
     2 description = vc
     2 short_desc = vc
     2 clin_desc = vc
     2 item_type = vc
 ) WITH protect
 DECLARE _::ld = f8 WITH noconstant(0.0), protect
 DECLARE _::getplitems(null) = i2
 SUBROUTINE _::getplitems(null)
   DECLARE cnt = i4 WITH noconstant(0), protect
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE pos = i4 WITH noconstant(0), protect
   DECLARE success = i4 WITH noconstant(0), protect
   DECLARE surgical_spec_mean = vc WITH constant("SURGSPEC"), protect
   DECLARE item_nbr_ident_type_cd_11000 = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3292")),
   protect
   DECLARE desc_ident_type_cd_11000 = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3290")),
   protect
   DECLARE clin_desc_ident_type_cd_11000 = f8 WITH constant(uar_get_code_by_cki(
     "CKI.CODEVALUE!3166806")), protect
   DECLARE short_desc_ident_type_cd_11000 = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3293"
     )), protect
   DECLARE item_master_item_type_cd_11001 = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3308"
     )), protect
   DECLARE equip_master_item_type_cd_11001 = f8 WITH constant(uar_get_code_by_cki(
     "CKI.CODEVALUE!3309")), protect
   SELECT INTO "nl:"
    FROM item_definition id,
     object_identifier_index oii,
     item_org_reltn ior,
     organization o
    PLAN (id
     WHERE id.item_type_cd IN (item_master_item_type_cd_11001, equip_master_item_type_cd_11001)
      AND id.active_ind=true
      AND (id.logical_domain_id=_::ld))
     JOIN (oii
     WHERE oii.object_id=id.item_id
      AND oii.identifier_type_cd IN (item_nbr_ident_type_cd_11000, desc_ident_type_cd_11000,
     clin_desc_ident_type_cd_11000, short_desc_ident_type_cd_11000)
      AND oii.generic_object=false
      AND oii.active_ind=true
      AND oii.logical_domain_id=id.logical_domain_id)
     JOIN (ior
     WHERE (ior.item_id= Outerjoin(oii.object_id)) )
     JOIN (o
     WHERE (o.organization_id= Outerjoin(ior.org_id)) )
    ORDER BY id.item_id, o.organization_id
    HEAD REPORT
     cnt = 0
    HEAD id.item_id
     placeholder = 1
    HEAD o.organization_id
     pos = locatevalsort(idx,1,size(sn_orgs->org,5),o.organization_id,sn_orgs->org[idx].org_id)
     IF (((ior.org_id=0.0) OR (pos > 0)) )
      cnt += 1
      IF (mod(cnt,100)=1)
       stat = alterlist(_::pick_list_items->list,(cnt+ 99))
      ENDIF
      _::pick_list_items->list[cnt].item_org_id = ior.org_id, _::pick_list_items->list[cnt].item_org
       = o.org_name, _::pick_list_items->list[cnt].item_id = id.item_id,
      _::pick_list_items->list[cnt].item_type = uar_get_code_display(id.item_type_cd)
     ENDIF
    DETAIL
     IF (((ior.org_id=0.0) OR (pos > 0)) )
      CASE (oii.identifier_type_cd)
       OF item_nbr_ident_type_cd_11000:
        _::pick_list_items->list[cnt].item_number = oii.value
       OF desc_ident_type_cd_11000:
        _::pick_list_items->list[cnt].description = oii.value
       OF clin_desc_ident_type_cd_11000:
        _::pick_list_items->list[cnt].clin_desc = oii.value
       OF short_desc_ident_type_cd_11000:
        _::pick_list_items->list[cnt].short_desc = oii.value
      ENDCASE
     ENDIF
    FOOT  o.organization_id
     placeholder = 1
    FOOT  id.item_id
     placeholder = 1
    FOOT REPORT
     stat = alterlist(_::pick_list_items->list,cnt)
    WITH nocounter
   ;end select
   IF (size(_::pick_list_items->list,5) > 0)
    SET stat = movereclist(_::pick_list_items->list,pick_list_items->list,1,size(pick_list_items->
      list,5),cnt,
     true)
    SET success = 1
   ENDIF
   RETURN(success)
 END ;Subroutine
 END; class scope:init
 final
 CALL echo("--- sn_pick_list_items out of scope")
 END; class scope:final
 WITH copy = 1
 CREATE CLASS pref_shortfalls
 init
 CALL echo("+++ pref_shortfalls instantiated")
 RECORD _::orgdomainbuild(
   1 list[*]
     2 org_name = vc
     2 org_id = f8
     2 pref_card_id = f8
     2 surg_area = vc
     2 surg_area_cd = f8
     2 doc_type = vc
     2 doc_type_cd = f8
     2 procedure = vc
     2 catalog_cd = f8
     2 provider = vc
     2 person_id = f8
     2 pc_pl_id = f8
     2 item_id = f8
     2 specialty = vc
     2 specialty_cd = f8
     2 prsnl_grp_id = f8
     2 item_number = vc
     2 description = vc
     2 clin_desc = vc
     2 open_qty = i4
     2 hold_qty = i4
     2 item_updt_cnt = i4
 ) WITH protect
 DECLARE _::ld = f8 WITH noconstant(0.0), protect
 SUBROUTINE (_::getdomainbuild(orgidx=i4,orgname=vc,orgid=f8) =i2)
   DECLARE cnt = i4 WITH noconstant(0), protect
   DECLARE success = i4 WITH noconstant(0), protect
   DECLARE areaidx = i4 WITH noconstant(0), protect
   DECLARE item_nbr_ident_type_cd_11000 = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3292")),
   protect
   DECLARE desc_ident_type_cd_11000 = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3290")),
   protect
   DECLARE clin_desc_ident_type_cd_11000 = f8 WITH constant(uar_get_code_by_cki(
     "CKI.CODEVALUE!3166806")), protect
   DECLARE item_master_item_type_cd_11001 = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3308"
     )), protect
   DECLARE equip_master_item_type_cd_11001 = f8 WITH constant(uar_get_code_by_cki(
     "CKI.CODEVALUE!3309")), protect
   DECLARE surgical_spec_mean = vc WITH constant("SURGSPEC"), protect
   DECLARE prsnl_group_type_code_set_357 = i4 WITH constant(357), protect
   DECLARE surgery_cat_type_cd_200 = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3084")),
   protect
   DECLARE surgery_act_type_cd_106 = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!2826")),
   protect
   SELECT INTO "nl:"
    FROM preference_card pc,
     (left JOIN order_catalog oc ON oc.catalog_cd=pc.catalog_cd
      AND oc.catalog_type_cd=surgery_cat_type_cd_200
      AND oc.activity_type_cd=surgery_act_type_cd_106
      AND oc.active_ind=true),
     (left JOIN prsnl pnl ON pnl.person_id=pc.prsnl_id
      AND pnl.active_ind=true
      AND pnl.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND pnl.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND (pnl.logical_domain_id=_::ld)),
     (left JOIN prsnl_group pnlg ON pnlg.prsnl_group_id=pc.surg_specialty_id
      AND pnlg.active_ind=true
      AND pnlg.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND pnlg.end_effective_dt_tm > cnvtdatetime(sysdate)),
     (left JOIN code_value cv ON cv.code_value=pnlg.prsnl_group_type_cd
      AND cv.active_ind=true
      AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND cv.code_set=prsnl_group_type_code_set_357
      AND cv.cdf_meaning=surgical_spec_mean),
     pref_card_pick_list pcpl,
     item_definition id,
     object_identifier_index oii
    PLAN (pc
     WHERE expand(areaidx,1,size(sn_org_areas->org[orgidx].area,5),pc.surg_area_cd,sn_org_areas->org[
      orgidx].area[areaidx].area_cd)
      AND pc.active_ind=true)
     JOIN (oc)
     JOIN (pnl)
     JOIN (pnlg)
     JOIN (cv)
     JOIN (pcpl
     WHERE pcpl.pref_card_id=pc.pref_card_id
      AND pcpl.active_ind=true
      AND pcpl.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND pcpl.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (id
     WHERE id.item_id=pcpl.item_id
      AND id.active_ind=true
      AND id.item_type_cd IN (item_master_item_type_cd_11001, equip_master_item_type_cd_11001)
      AND (id.logical_domain_id=_::ld))
     JOIN (oii
     WHERE oii.object_id=id.item_id
      AND oii.active_ind=true
      AND oii.generic_object=0
      AND oii.identifier_type_cd IN (item_nbr_ident_type_cd_11000, desc_ident_type_cd_11000,
     clin_desc_ident_type_cd_11000)
      AND (oii.logical_domain_id=_::ld))
    ORDER BY pc.pref_card_id, pcpl.pref_card_pick_list_id
    HEAD REPORT
     placeholder = 1
    HEAD pc.pref_card_id
     placeholder = 1
    HEAD pcpl.pref_card_pick_list_id
     IF (oii.object_identifier_index_id > 0.0)
      cnt += 1
      IF (mod(cnt,100)=1)
       stat = alterlist(_::orgdomainbuild->list,(cnt+ 99))
      ENDIF
      _::orgdomainbuild->list[cnt].org_name = orgname, _::orgdomainbuild->list[cnt].org_id = orgid,
      _::orgdomainbuild->list[cnt].pref_card_id = pc.pref_card_id,
      _::orgdomainbuild->list[cnt].surg_area = uar_get_code_display(pc.surg_area_cd), _::
      orgdomainbuild->list[cnt].surg_area_cd = pc.surg_area_cd, _::orgdomainbuild->list[cnt].doc_type
       = uar_get_code_display(pc.doc_type_cd),
      _::orgdomainbuild->list[cnt].doc_type_cd = pc.doc_type_cd, _::orgdomainbuild->list[cnt].
      catalog_cd = pc.catalog_cd, _::orgdomainbuild->list[cnt].procedure = oc.primary_mnemonic,
      _::orgdomainbuild->list[cnt].provider = pnl.name_full_formatted, _::orgdomainbuild->list[cnt].
      person_id = pc.prsnl_id, _::orgdomainbuild->list[cnt].pc_pl_id = pcpl.pref_card_pick_list_id,
      _::orgdomainbuild->list[cnt].item_id = pcpl.item_id, _::orgdomainbuild->list[cnt].specialty =
      cv.description, _::orgdomainbuild->list[cnt].specialty_cd = cv.code_value,
      _::orgdomainbuild->list[cnt].prsnl_grp_id = pnlg.prsnl_group_id, _::orgdomainbuild->list[cnt].
      open_qty = pcpl.request_open_qty, _::orgdomainbuild->list[cnt].hold_qty = pcpl.request_hold_qty,
      _::orgdomainbuild->list[cnt].item_updt_cnt = pcpl.updt_cnt
     ENDIF
    DETAIL
     IF (oii.object_identifier_index_id > 0.0)
      CASE (oii.identifier_type_cd)
       OF item_nbr_ident_type_cd_11000:
        _::orgdomainbuild->list[cnt].item_number = oii.value
       OF desc_ident_type_cd_11000:
        _::orgdomainbuild->list[cnt].description = oii.value
       OF clin_desc_ident_type_cd_11000:
        _::orgdomainbuild->list[cnt].clin_desc = oii.value
      ENDCASE
     ENDIF
    FOOT  pcpl.pref_card_pick_list_id
     placeholder = 1
    FOOT  pc.pref_card_id
     placeholder = 1
    FOOT REPORT
     stat = alterlist(_::orgdomainbuild->list,cnt)
    WITH nocounter, expand = 2
   ;end select
   IF (size(_::orgdomainbuild->list,5) > 0)
    SET stat = movereclist(_::orgdomainbuild->list,domainbuild->list,1,size(domainbuild->list,5),cnt,
     true)
    SET success = 1
   ENDIF
   RETURN(success)
 END ;Subroutine
 END; class scope:init
 final
 CALL echo("--- pref_shortfalls out of scope")
 END; class scope:final
 WITH copy = 1
END GO
