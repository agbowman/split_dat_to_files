CREATE PROGRAM core_get_copy_alias_info:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 error_msg = vc
   1 contributor_source_cd = f8
   1 contributor_source_disp = c40
   1 alias_list[*]
     2 action_type_flag = i2
     2 code_value_disp = c40
     2 cdf_meaning = c12
     2 code_value = f8
     2 alias_values[*]
       3 alias = vc
       3 primary_ind = i2
       3 alias_type_meaning = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 SET reply->status_data.status = "F"
 SET reply->contributor_source_cd = request->target_cntrbtr_src_cd
 IF ((request->copy_type_flag=0))
  SELECT INTO "nl:"
   cva.*, cva_ind = nullind(cva.alias), cv.display,
   cvo.*
   FROM code_value_alias cva,
    code_value cv,
    code_value_outbound cvo
   PLAN (cva
    WHERE (cva.contributor_source_cd=request->from_cntrbtr_src_cd)
     AND (cva.code_set=request->code_set))
    JOIN (cv
    WHERE cv.code_value=cva.code_value
     AND cv.code_set=cva.code_set)
    JOIN (cvo
    WHERE cvo.contributor_source_cd=outerjoin(request->target_cntrbtr_src_cd)
     AND cvo.code_value=outerjoin(cva.code_value))
   ORDER BY cva.code_value
   HEAD REPORT
    a_cnt = 0, alias_check = 0
   HEAD cva.code_value
    alias_check = 0
    IF ((cvo.contributor_source_cd=request->target_cntrbtr_src_cd))
     IF ((request->option_type_flag=1))
      a_cnt = (a_cnt+ 1), stat = alterlist(reply->alias_list,a_cnt), alias_check = 1,
      reply->alias_list[a_cnt].code_value = cva.code_value, reply->alias_list[a_cnt].code_value_disp
       = cv.display, reply->alias_list[a_cnt].cdf_meaning = cv.cdf_meaning,
      reply->alias_list[a_cnt].action_type_flag = 2
     ENDIF
    ELSE
     a_cnt = (a_cnt+ 1), stat = alterlist(reply->alias_list,a_cnt), alias_check = 1,
     reply->alias_list[a_cnt].code_value = cva.code_value, reply->alias_list[a_cnt].code_value_disp
      = cv.display, reply->alias_list[a_cnt].cdf_meaning = cv.cdf_meaning,
     reply->alias_list[a_cnt].action_type_flag = 1
    ENDIF
    l_cnt = 0
   DETAIL
    IF (alias_check=1)
     l_cnt = (l_cnt+ 1)
     IF (mod(l_cnt,10)=1)
      stat = alterlist(reply->alias_list[a_cnt].alias_values,(l_cnt+ 9))
     ENDIF
     IF (cva.alias=" "
      AND cva_ind=0)
      reply->alias_list[a_cnt].alias_values[l_cnt].alias = "<sp>"
     ELSE
      reply->alias_list[a_cnt].alias_values[l_cnt].alias = cva.alias
     ENDIF
     reply->alias_list[a_cnt].alias_values[l_cnt].primary_ind = cva.primary_ind, reply->alias_list[
     a_cnt].alias_values[l_cnt].alias_type_meaning = cva.alias_type_meaning
    ENDIF
   FOOT  cva.code_value
    IF (alias_check=1)
     stat = alterlist(reply->alias_list[a_cnt].alias_values,l_cnt)
    ENDIF
   FOOT REPORT
    row + 0
   WITH nocounter
  ;end select
 ELSEIF ((request->copy_type_flag=1))
  SELECT INTO "nl:"
   cvo.*, cvo_ind = nullind(cvo.alias), cv.display,
   cva.*
   FROM code_value_outbound cvo,
    code_value cv,
    code_value_alias cva
   PLAN (cv
    WHERE (cv.code_set=request->code_set))
    JOIN (cvo
    WHERE (cvo.contributor_source_cd=request->from_cntrbtr_src_cd)
     AND cvo.code_value=cv.code_value)
    JOIN (cva
    WHERE cva.contributor_source_cd=outerjoin(request->target_cntrbtr_src_cd)
     AND cva.code_set=outerjoin(cvo.code_set)
     AND cva.code_value=outerjoin(cvo.code_value)
     AND cva.alias=outerjoin(cvo.alias))
   ORDER BY cvo.code_value
   HEAD REPORT
    a_cnt = 0, alias_check = 0
   HEAD cvo.code_value
    alias_check = 0
    IF ( NOT ((cva.contributor_source_cd=request->target_cntrbtr_src_cd)))
     a_cnt = (a_cnt+ 1), stat = alterlist(reply->alias_list,a_cnt), alias_check = 1,
     reply->alias_list[a_cnt].code_value = cvo.code_value, reply->alias_list[a_cnt].code_value_disp
      = cv.display, reply->alias_list[a_cnt].cdf_meaning = cv.cdf_meaning,
     reply->alias_list[a_cnt].action_type_flag = 1
    ENDIF
    l_cnt = 0
   DETAIL
    IF (alias_check=1)
     l_cnt = (l_cnt+ 1)
     IF (mod(l_cnt,10)=1)
      stat = alterlist(reply->alias_list[a_cnt].alias_values,(l_cnt+ 9))
     ENDIF
     IF (cvo.alias=" "
      AND cvo_ind=0)
      reply->alias_list[a_cnt].alias_values[l_cnt].alias = "<sp>"
     ELSE
      reply->alias_list[a_cnt].alias_values[l_cnt].alias = cvo.alias
     ENDIF
     reply->alias_list[a_cnt].alias_values[l_cnt].alias_type_meaning = cvo.alias_type_meaning
    ENDIF
   FOOT  cvo.code_value
    IF (alias_check=1)
     stat = alterlist(reply->alias_list[a_cnt].alias_values,l_cnt)
    ENDIF
   FOOT REPORT
    row + 0
   WITH nocounter
  ;end select
 ELSEIF ((request->copy_type_flag=2))
  SELECT INTO "nl:"
   cva.*, cva_ind = nullind(cva.alias), cv.display,
   cva2.*
   FROM code_value_alias cva,
    code_value cv,
    code_value_alias cva2
   PLAN (cva
    WHERE (cva.contributor_source_cd=request->from_cntrbtr_src_cd)
     AND (cva.code_set=request->code_set))
    JOIN (cv
    WHERE cv.code_value=cva.code_value
     AND cv.code_set=cva.code_set)
    JOIN (cva2
    WHERE cva2.contributor_source_cd=outerjoin(request->target_cntrbtr_src_cd)
     AND cva2.code_set=outerjoin(cva.code_set)
     AND cva2.code_value=outerjoin(cva.code_value)
     AND cva2.alias=outerjoin(cva.alias))
   ORDER BY cva.code_value
   HEAD REPORT
    a_cnt = 0, alias_check = 0
   HEAD cva.code_value
    row + 0
   DETAIL
    alias_check = 0
    IF ((cva2.contributor_source_cd=request->target_cntrbtr_src_cd))
     IF ((request->option_type_flag=1))
      a_cnt = (a_cnt+ 1), stat = alterlist(reply->alias_list,a_cnt), alias_check = 1,
      reply->alias_list[a_cnt].code_value = cva.code_value, reply->alias_list[a_cnt].code_value_disp
       = cv.display, reply->alias_list[a_cnt].cdf_meaning = cv.cdf_meaning,
      reply->alias_list[a_cnt].action_type_flag = 2
     ENDIF
    ELSE
     a_cnt = (a_cnt+ 1), stat = alterlist(reply->alias_list,a_cnt), alias_check = 1,
     reply->alias_list[a_cnt].code_value = cva.code_value, reply->alias_list[a_cnt].code_value_disp
      = cv.display, reply->alias_list[a_cnt].cdf_meaning = cv.cdf_meaning,
     reply->alias_list[a_cnt].action_type_flag = 1
    ENDIF
    l_cnt = 0
    IF (alias_check=1)
     l_cnt = (l_cnt+ 1), stat = alterlist(reply->alias_list[a_cnt].alias_values,l_cnt)
     IF (cva.alias=" "
      AND cva_ind=0)
      reply->alias_list[a_cnt].alias_values[l_cnt].alias = "<sp>"
     ELSE
      reply->alias_list[a_cnt].alias_values[l_cnt].alias = cva.alias
     ENDIF
     reply->alias_list[a_cnt].alias_values[l_cnt].primary_ind = cva.primary_ind, reply->alias_list[
     a_cnt].alias_values[l_cnt].alias_type_meaning = cva.alias_type_meaning
    ENDIF
   FOOT  cva.code_value
    row + 0
   FOOT REPORT
    row + 0
   WITH nocounter
  ;end select
 ELSEIF ((request->copy_type_flag=3))
  SELECT INTO "nl:"
   cvo.*, cvo_ind = nullind(cvo.alias), cv.display,
   cvo2.*
   FROM code_value cv,
    code_value_outbound cvo,
    code_value_outbound cvo2
   PLAN (cv
    WHERE (cv.code_set=request->code_set))
    JOIN (cvo
    WHERE (cvo.contributor_source_cd=request->from_cntrbtr_src_cd)
     AND cvo.code_value=cv.code_value)
    JOIN (cvo2
    WHERE cvo2.contributor_source_cd=outerjoin(request->target_cntrbtr_src_cd)
     AND cvo2.code_value=outerjoin(cvo.code_value))
   ORDER BY cvo.code_value
   HEAD REPORT
    a_cnt = 0, alias_check = 0
   HEAD cvo.code_value
    row + 0
   DETAIL
    alias_check = 0
    IF ((cvo2.contributor_source_cd=request->target_cntrbtr_src_cd))
     IF ((request->option_type_flag=1))
      a_cnt = (a_cnt+ 1), stat = alterlist(reply->alias_list,a_cnt), alias_check = 1,
      reply->alias_list[a_cnt].code_value = cvo.code_value, reply->alias_list[a_cnt].code_value_disp
       = cv.display, reply->alias_list[a_cnt].cdf_meaning = cv.cdf_meaning,
      reply->alias_list[a_cnt].action_type_flag = 2
     ENDIF
    ELSE
     a_cnt = (a_cnt+ 1), stat = alterlist(reply->alias_list,a_cnt), alias_check = 1,
     reply->alias_list[a_cnt].code_value = cvo.code_value, reply->alias_list[a_cnt].code_value_disp
      = cv.display, reply->alias_list[a_cnt].cdf_meaning = cv.cdf_meaning,
     reply->alias_list[a_cnt].action_type_flag = 1
    ENDIF
    l_cnt = 0
    IF (alias_check=1)
     l_cnt = (l_cnt+ 1), stat = alterlist(reply->alias_list[a_cnt].alias_values,l_cnt)
     IF (cvo.alias=" "
      AND cvo_ind=0)
      reply->alias_list[a_cnt].alias_values[l_cnt].alias = "<sp>"
     ELSE
      reply->alias_list[a_cnt].alias_values[l_cnt].alias = cvo.alias
     ENDIF
     reply->alias_list[a_cnt].alias_values[l_cnt].alias_type_meaning = cvo.alias_type_meaning
    ENDIF
   FOOT  cvo.code_value
    row + 0
   FOOT REPORT
    row + 0
   WITH nocounter
  ;end select
 ELSE
  SET reply->error_msg = build("Can't recognize the copy_type_flag with the"," value:",request->
   copy_type_flag,".")
  SET failed = "T"
  GO TO exit_script
 ENDIF
 GO TO exit_script
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "000 04/07/03 JF8275"
END GO
