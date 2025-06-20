CREATE PROGRAM bhs_eks_t_problems_find:dba
 FREE RECORD t_time
 RECORD t_time(
   1 start_tm = f8
   1 end_tm = f8
   1 diff = f8
 ) WITH protect
 SET t_time->start_tm = curtime3
 DECLARE validatenewparameter() = null
 CALL echo(concat(format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   "  *******  Beginning of Program eks_t_problems_find  *********"),1,0)
 SET rev_inc = "708"
 SET ininc = "eks_tell_ekscommon"
 SET ttemp = trim(eks_common->cur_module_name)
 SET eksmodule = trim(ttemp)
 FREE SET ttemp
 SET ttemp = trim(eks_common->event_name)
 SET eksevent = ttemp
 SET eksrequest = eks_common->request_number
 FREE SET ttemp
 DECLARE tcurindex = i4
 DECLARE tinx = i4
 SET tcurindex = 1
 SET tinx = 1
 SET evoke_inx = 1
 SET data_inx = 2
 SET logic_inx = 3
 SET action_inx = 4
 IF ( NOT (validate(eksdata->tqual,"Y")="Y"
  AND validate(eksdata->tqual,"Z")="Z"))
  FREE SET templatetype
  IF (conclude > 0)
   SET templatetype = "ACTION"
   SET basecurindex = (logiccnt+ evokecnt)
   SET tcurindex = 4
  ELSE
   SET templatetype = "LOGIC"
   SET basecurindex = evokecnt
   SET tcurindex = 3
  ENDIF
  SET cbinx = curindex
  SET tinx = logic_inx
 ELSE
  SET templatetype = "EVOKE"
  SET curindex = 0
  SET tcurindex = 0
  SET tinx = 0
 ENDIF
 CALL echo(concat("****  ",format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   "     Module:  ",
   trim(eksmodule),"  ****"),1,0)
 IF (validate(tname,"Y")="Y"
  AND validate(tname,"Z")="Z")
  IF (templatetype != "EVOKE")
   CALL echo(concat("****  EKM Beginning of ",trim(templatetype)," Template(",build(curindex),
     ")           Event:  ",
     trim(eksevent),"         Request number:  ",cnvtstring(eksrequest)),1,10)
  ELSE
   CALL echo(concat("****  EKM Beginning an Evoke Template","           Event:  ",trim(eksevent),
     "         Request number:  ",cnvtstring(eksrequest)),1,10)
  ENDIF
 ELSE
  IF (templatetype != "EVOKE")
   CALL echo(concat("****  EKM Beginning of ",trim(templatetype)," Template(",build(curindex),"):  ",
     trim(tname),"       Event:  ",trim(eksevent),"         Request number:  ",cnvtstring(eksrequest)
     ),1,10)
  ELSE
   CALL echo(concat("****  EKM Beginning Evoke Template:  ",trim(tname),"       Event:  ",trim(
      eksevent),"         Request number:  ",
     cnvtstring(eksrequest)),1,10)
  ENDIF
 ENDIF
 RECORD nomendata(
   1 stop_ind = i2
   1 match_cnt = i4
   1 all_matches_ind = i2
   1 hierarchy_ind = i2
   1 ignore_concepts_ind = i2
   1 cross_patient_ind = i2
   1 cross_vocabs_cnt = i4
   1 cross_vocabs[*]
     2 vocab_cd = f8
   1 nomen_cnt = i4
   1 nomen_qual[*]
     2 nomenclature_id = f8
     2 misc_id = f8
     2 misc_instance_id = f8
     2 ccki = vc
     2 match_ind = i2
     2 req_index = i4
 )
 DECLARE msg = vc
 DECLARE nlink = i2
 DECLARE opt_flag = i2
 DECLARE i = i4 WITH protect
 DECLARE stop_search_pos = i4 WITH protect
 DECLARE mod_version = vc WITH private
 SET mod_version = "001 01/13/09"
 SET personid = 0.0
 SET encntrid = 0.0
 SET accessionid = 0.0
 SET orderid = 0.0
 SET eks_ceid = 0.0
 SET ekstaskassaycd = 0.0
 SET retval = 0
 SET opt_flag = 0
 SET stop_search_pos = 0
 RECORD problemslist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 )
 RECORD nomenclatureid(
   1 cnt = i4
   1 qual[*]
     2 id = f8
 )
 RECORD opt_qualifierlist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 )
 RECORD opt_confirmationlist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 )
 RECORD opt_classificationlist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 )
 RECORD opt_life_cycle_statuslist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 )
 RECORD opt_severity_classlist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 )
 RECORD opt_severitylist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 )
 RECORD opt_courselist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 )
 IF (validate(link,"Z")="Z"
  AND validate(link,"Y")="Y")
  SET msg = "Parameter LINK does not exist!"
  SET retval = - (1)
  GO TO endprogram
 ELSE
  SET nlink = cnvtint(trim(link))
  IF (nlink > 0)
   SET personid = eksdata->tqual[tcurindex].qual[nlink].person_id
   IF (personid <= 0)
    SET msg = "Person ID is not set up in a linked template!"
    SET retval = - (1)
    GO TO endprogram
   ENDIF
   SET opt_flag = 1
  ELSE
   SET msg = "Required parameter LINK is not defined!"
   SET retval = - (1)
   GO TO endprogram
  ENDIF
 ENDIF
 IF (validate(opt_problems,"Z")="Z"
  AND validate(opt_problems,"Y")="Y")
  SET msg = "Parameter OPT_PROBLEMS does not exist!"
  SET retval = - (1)
  GO TO endprogram
 ELSEIF (((trim(opt_problems) < " ") OR (trim(opt_problems)="<undefined>")) )
  CALL echo("Optional parameter OPT_PROBLEMS is not defined.")
 ELSE
  CALL echo("Checking OPT_PROBLEMS.")
  SET orig_param = opt_problems
  EXECUTE eks_t_parse_list  WITH replace(reply,problemslist)
  FREE SET orig_param
  IF ((problemslist->cnt <= 0))
   CALL echo("No entries in the parameter OPT_PROBLEMS. Ignore.")
  ELSE
   SET opt_flag = 1
  ENDIF
 ENDIF
 IF (validate(opt_qualifier,"Z")="Z"
  AND validate(opt_qualifier,"Y")="Y")
  SET msg = "Parameter OPT_QUALIFIER does not exist!"
  SET retval = - (1)
  GO TO endprogram
 ELSEIF (((trim(opt_qualifier) < " ") OR (trim(opt_qualifier)="<undefined>")) )
  CALL echo("Optional parameter OPT_QUALIFIER is not defined.")
 ELSE
  CALL echo("Checking OPT_QUALIFIER.")
  SET orig_param = opt_qualifier
  EXECUTE eks_t_parse_list  WITH replace(reply,opt_qualifierlist)
  FREE SET orig_param
  IF ((opt_qualifierlist->cnt > 0))
   SET stop_search_pos = locateval(i,1,opt_qualifierlist->cnt,"*Stop search after first match",
    opt_qualifierlist->qual[i].value)
   IF (stop_search_pos > 0)
    CALL echo(concat("STOP SEARCH indicator found in the item ",build(stop_search_pos),
      ". Removing it from the list of qualifiers."))
    SET opt_qualifierlist->cnt -= 1
    IF ((opt_qualifierlist->cnt > 0))
     SET stat = alterlist(opt_qualifierlist->qual,opt_qualifierlist->cnt,(stop_search_pos - 1))
    ELSE
     SET stat = initrec(opt_qualifierlist)
    ENDIF
   ENDIF
  ENDIF
  IF ((opt_qualifierlist->cnt > 0))
   SET opt_flag = 1
  ELSE
   CALL echo("No entries in the parameter OPT_QUALIFIER. Ignore.")
  ENDIF
 ENDIF
 IF (validate(opt_confirmation,"Z")="Z"
  AND validate(opt_confirmation,"Y")="Y")
  SET msg = "Parameter OPT_CONFIRMATION does not exist!"
  SET retval = - (1)
  GO TO endprogram
 ELSEIF (((trim(opt_confirmation) < " ") OR (trim(opt_confirmation)="<undefined>")) )
  CALL echo("Optional parameter OPT_CONFIRMATION is not defined.")
 ELSE
  CALL echo("Checking OPT_CONFIRMATION.")
  SET orig_param = opt_confirmation
  EXECUTE eks_t_parse_list  WITH replace(reply,opt_confirmationlist)
  FREE SET orig_param
  IF ((opt_confirmationlist->cnt <= 0))
   CALL echo("No entries in the parameter OPT_CONFIRMATION. Ignore.")
  ELSE
   SET opt_flag = 1
  ENDIF
 ENDIF
 IF (validate(opt_classification,"Z")="Z"
  AND validate(opt_classification,"Y")="Y")
  SET msg = "Parameter OPT_CLASSIFICATION does not exist!"
  SET retval = - (1)
  GO TO endprogram
 ELSEIF (((trim(opt_classification) < " ") OR (trim(opt_classification)="<undefined>")) )
  CALL echo("Optional parameter OPT_CLASSIFICATION is not defined.")
 ELSE
  CALL echo("Checking OPT_CLASSIFICATION.")
  SET orig_param = opt_classification
  EXECUTE eks_t_parse_list  WITH replace(reply,opt_classificationlist)
  FREE SET orig_param
  IF ((opt_classificationlist->cnt <= 0))
   CALL echo("No entries in the parameter OPT_CLASSIFICATION. Ignore.")
  ELSE
   SET opt_flag = 1
  ENDIF
 ENDIF
 IF (validate(opt_life_cycle_status,"Z")="Z"
  AND validate(opt_life_cycle_status,"Y")="Y")
  SET msg = "Parameter OPT_LIFE_CYCLE_STATUS does not exist!"
  SET retval = - (1)
  GO TO endprogram
 ELSEIF (((trim(opt_life_cycle_status) < " ") OR (trim(opt_life_cycle_status)="<undefined>")) )
  CALL echo("Optional parameter OPT_LIFE_CYCLE_STATUS is not defined.")
 ELSE
  CALL echo("Checking OPT_LIFE_CYCLE_STATUS.")
  SET orig_param = opt_life_cycle_status
  EXECUTE eks_t_parse_list  WITH replace(reply,opt_life_cycle_statuslist)
  FREE SET orig_param
  IF ((opt_life_cycle_statuslist->cnt <= 0))
   CALL echo("No entries in the parameter OPT_LIFE_CYCLE_STATUS. Ignore.")
  ELSE
   SET opt_flag = 1
  ENDIF
 ENDIF
 IF (validate(opt_severity_class,"Z")="Z"
  AND validate(opt_severity_class,"Y")="Y")
  SET msg = "Parameter OPT_SEVERITY_CLASS does not exist!"
  SET retval = - (1)
  GO TO endprogram
 ELSEIF (((trim(opt_severity_class) < " ") OR (trim(opt_severity_class)="<undefined>")) )
  CALL echo("Optional parameter OPT_SEVERITY_CLASS is not defined.")
 ELSE
  CALL echo("Checking OPT_SEVERITY_CLASS.")
  SET orig_param = opt_severity_class
  EXECUTE eks_t_parse_list  WITH replace(reply,opt_severity_classlist)
  FREE SET orig_param
  IF ((opt_severity_classlist->cnt <= 0))
   CALL echo("No entries in the parameter OPT_SEVERITY_CLASS. Ignore.")
  ELSE
   SET opt_flag = 1
  ENDIF
 ENDIF
 IF (validate(opt_severity,"Z")="Z"
  AND validate(opt_severity,"Y")="Y")
  SET msg = "Parameter OPT_SEVERITY does not exist!"
  SET retval = - (1)
  GO TO endprogram
 ELSEIF (((trim(opt_severity) < " ") OR (trim(opt_severity)="<undefined>")) )
  CALL echo("Optional parameter OPT_SEVERITY is not defined.")
 ELSE
  CALL echo("Checking OPT_SEVERITY.")
  SET orig_param = opt_severity
  EXECUTE eks_t_parse_list  WITH replace(reply,opt_severitylist)
  FREE SET orig_param
  IF ((opt_severitylist->cnt <= 0))
   CALL echo("No entries in the parameter OPT_SEVERITY. Ignore.")
  ELSE
   SET opt_flag = 1
  ENDIF
 ENDIF
 IF (validate(opt_course,"Z")="Z"
  AND validate(opt_course,"Y")="Y")
  SET msg = "Parameter OPT_COURSE does not exist!"
  SET retval = - (1)
  GO TO endprogram
 ELSEIF (((trim(opt_course) < " ") OR (trim(opt_course)="<undefined>")) )
  CALL echo("Optional parameter OPT_COURSE is not defined.")
 ELSE
  CALL echo("Checking OPT_COURSE.")
  SET orig_param = opt_course
  EXECUTE eks_t_parse_list  WITH replace(reply,opt_courselist)
  FREE SET orig_param
  IF ((opt_courselist->cnt <= 0))
   CALL echo("No entries in the parameter OPT_COURSE. Ignore.")
  ELSE
   SET opt_flag = 1
  ENDIF
 ENDIF
 IF (opt_flag=0)
  SET msg = "Validation failed! At least one optional parameter has to be specified!"
  SET retval = - (1)
  GO TO endprogram
 ENDIF
 CALL echo(concat(format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   "  ------  Looking for matches in PROBLEM table  ------"))
 SELECT DISTINCT INTO "nl:"
  p.problem_id
  FROM problem p,
   (dummyt d1  WITH seq = value(opt_qualifierlist->cnt)),
   (dummyt d2  WITH seq = value(opt_confirmationlist->cnt)),
   (dummyt d3  WITH seq = value(opt_classificationlist->cnt)),
   (dummyt d4  WITH seq = value(opt_life_cycle_statuslist->cnt)),
   (dummyt d5  WITH seq = value(opt_severity_classlist->cnt)),
   (dummyt d6  WITH seq = value(opt_severitylist->cnt)),
   (dummyt d7  WITH seq = value(opt_courselist->cnt))
  PLAN (d1)
   JOIN (d2)
   JOIN (d3)
   JOIN (d4)
   JOIN (d5)
   JOIN (d6)
   JOIN (d7)
   JOIN (p
   WHERE p.person_id=personid
    AND p.active_ind=1
    AND cnvtdatetime(sysdate) BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm
    AND p.beg_effective_dt_tm < cnvtdatetime((curdate - 21),0)
    AND ((p.qualifier_cd=cnvtreal(opt_qualifierlist->qual[d1.seq].value)) OR ((opt_qualifierlist->cnt
   =0)))
    AND ((p.confirmation_status_cd=cnvtreal(opt_confirmationlist->qual[d2.seq].value)) OR ((
   opt_confirmationlist->cnt=0)))
    AND ((p.classification_cd=cnvtreal(opt_classificationlist->qual[d3.seq].value)) OR ((
   opt_classificationlist->cnt=0)))
    AND ((p.life_cycle_status_cd=cnvtreal(opt_life_cycle_statuslist->qual[d4.seq].value)) OR ((
   opt_life_cycle_statuslist->cnt=0)))
    AND ((p.severity_class_cd=cnvtreal(opt_severity_classlist->qual[d5.seq].value)) OR ((
   opt_severity_classlist->cnt=0)))
    AND ((p.severity_cd=cnvtreal(opt_severitylist->qual[d6.seq].value)) OR ((opt_severitylist->cnt=0)
   ))
    AND ((p.course_cd=cnvtreal(opt_courselist->qual[d7.seq].value)) OR ((opt_courselist->cnt=0))) )
  ORDER BY p.problem_id
  HEAD REPORT
   nomendata->nomen_cnt = 0, nomendata->stop_ind = 0, nomendata->match_cnt = 0
  DETAIL
   nomendata->nomen_cnt += 1, stat = alterlist(nomendata->nomen_qual,nomendata->nomen_cnt), nomendata
   ->nomen_qual[nomendata->nomen_cnt].nomenclature_id = p.nomenclature_id,
   nomendata->nomen_qual[nomendata->nomen_cnt].misc_id = p.problem_id, nomendata->nomen_qual[
   nomendata->nomen_cnt].misc_instance_id = p.problem_instance_id, nomendata->nomen_qual[nomendata->
   nomen_cnt].ccki = " "
   IF ((problemslist->cnt > 0))
    nomendata->nomen_qual[nomendata->nomen_cnt].match_ind = 0
   ELSE
    nomendata->nomen_qual[nomendata->nomen_cnt].match_ind = 1, nomendata->match_cnt += 1
   ENDIF
  WITH nocounter
 ;end select
 IF (nomendata->nomen_cnt)
  CALL echo(concat("Found ",trim(cnvtstring(nomendata->nomen_cnt)),
    " problem(s) in PROBLEM table that match specified criteria."))
  IF ((problemslist->cnt > 0))
   IF (stop_search_pos > 0)
    SET nomendata->stop_ind = 1
    CALL echo("Calling eks_t_nomenclature_check from a logic template using EVOKE search mode!")
   ENDIF
   CALL validatenewparameter(0)
   EXECUTE eks_t_nomenclature_check  WITH replace(ruledata,problemslist)
  ENDIF
  IF ((nomendata->match_cnt > 0))
   SET retval = 100
   SET msg = concat("Found ",trim(cnvtstring(nomendata->match_cnt)),
    " problem(s) matching specified criteria.")
  ELSE
   SET retval = 0
   SET msg = concat("No problem(s) found matching specified criteria.")
  ENDIF
 ELSE
  SET msg = "No qualifying problem(s) found in PROBLEM table."
  SET retval = 0
 ENDIF
 SUBROUTINE validatenewparameter(_null)
   RECORD opt_cross_vocabslist(
     1 cnt = i4
     1 qual[*]
       2 value = vc
       2 display = vc
   )
   IF (validate(opt_cross_vocabs,"Z")="Z"
    AND validate(opt_cross_vocabs,"Y")="Y")
    CALL echo("Parameter OPT_CROSS_VOCABS does not exist!")
    SET nomendata->cross_vocabs_cnt = 0
   ELSEIF (((trim(opt_cross_vocabs) < " ") OR (trim(opt_cross_vocabs)="<undefined>")) )
    CALL echo("Optional parameter OPT_CROSS_VOCABS is not defined.")
    SET nomendata->cross_vocabs_cnt = 0
   ELSE
    CALL echo("Checking OPT_CROSS_VOCABS.")
    SET orig_param = opt_cross_vocabs
    EXECUTE eks_t_parse_list  WITH replace(reply,opt_cross_vocabslist)
    FREE SET orig_param
    IF ((opt_cross_vocabslist->cnt <= 0))
     CALL echo("No entries in the parameter OPT_CROSS_VOCABS. Ignore.")
     SET nomendata->cross_vocabs_cnt = 0
    ELSEIF ((opt_cross_vocabslist->cnt=1))
     IF (cnvtupper(trim(opt_cross_vocabslist->qual[1].display,3))="*ALL")
      SET nomendata->cross_vocabs_cnt = 0
     ELSEIF (cnvtupper(trim(opt_cross_vocabslist->qual[1].display,3))="*NONE")
      SET nomendata->cross_vocabs_cnt = - (1)
     ELSE
      SET nomendata->cross_vocabs_cnt = 1
      SET stat = alterlist(nomendata->cross_vocabs,nomendata->cross_vocabs_cnt)
      SET nomendata->cross_vocabs[nomendata->cross_vocabs_cnt].vocab_cd = cnvtreal(
       opt_cross_vocabslist->qual[1].value)
     ENDIF
    ELSE
     SET nomendata->cross_vocabs_cnt = opt_cross_vocabslist->cnt
     SET stat = alterlist(nomendata->cross_vocabs,nomendata->cross_vocabs_cnt)
     SET i = 0
     FOR (i = 1 TO opt_cross_vocabslist->cnt)
       IF (trim(opt_cross_vocabslist->qual[i].value) IN ("*ALL", "*NONE"))
        SET retval = 0
        SET msg = concat("one of the OPT_CORSS_VOCABS options is ",trim(opt_cross_vocabslist->qual[i]
          .display),", so only ONE option is allowed.")
        GO TO endprogram
       ELSE
        SET nomendata->cross_vocabs[i].vocab_cd = cnvtreal(opt_cross_vocabslist->qual[i].value)
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   CALL echo(concat("nomendata->cross_vocabs_cnt: ",build(nomendata->cross_vocabs_cnt)))
   IF (validate(opt_person_activity,"Z")="Z"
    AND validate(opt_person_activity,"Y")="Y")
    CALL echo("Parameter OPT_PERSON_ACTIVITY does not exist!")
    SET nomendata->cross_patient_ind = 1
   ELSEIF (((trim(opt_person_activity) < " ") OR (trim(opt_person_activity)="<undefined>")) )
    CALL echo("Optional parameter OPT_PERSON_ACTIVITY is not defined.")
    SET nomendata->cross_patient_ind = 1
   ELSE
    CALL echo(concat("optional parameter OPT_PERSON_ACTIVITY: ",build(opt_person_activity)))
    IF (cnvtupper(trim(opt_person_activity))="INCLUDING")
     SET nomendata->cross_patient_ind = 1
    ELSEIF (cnvtupper(trim(opt_person_activity))="EXCLUDING")
     SET nomendata->cross_patient_ind = 0
    ELSE
     SET retval = 0
     SET msg = concat("invalid option found - ",trim(opt_person_activity))
     GO TO endprogram
    ENDIF
   ENDIF
   CALL echo(concat("nomendata->cross_patient_ind: ",build(nomendata->cross_patient_ind)))
   IF (validate(opt_vocab_hierarchy,"Z")="Z"
    AND validate(opt_vocab_hierarchy,"Y")="Y")
    CALL echo("Parameter OPT_VOCAB_HIERARCHY does not exist!")
    SET nomendata->hierarchy_ind = 1
   ELSEIF (((trim(opt_vocab_hierarchy) < " ") OR (trim(opt_vocab_hierarchy)="<undefined>")) )
    CALL echo("Optional parameter OPT_VOCAB_HIERARCHY is not defined.")
    SET nomendata->hierarchy_ind = 1
   ELSE
    CALL echo(concat("optional parameter OPT_VOCAB_HIERARCHY: ",build(opt_vocab_hierarchy)))
    IF (cnvtupper(trim(opt_vocab_hierarchy))="INCLUDE")
     SET nomendata->hierarchy_ind = 1
    ELSEIF (cnvtupper(trim(opt_vocab_hierarchy))="EXCLUDE")
     SET nomendata->hierarchy_ind = 0
    ELSE
     SET retval = 0
     SET msg = concat("invalid option found - ",trim(opt_vocab_hierarchy))
     GO TO endprogram
    ENDIF
   ENDIF
   CALL echo(concat("nomendata->hierarchy_ind: ",build(nomendata->hierarchy_ind)))
   IF (validate(opt_ignore_concepts,"Z")="Z"
    AND validate(opt_ignore_concepts,"Y")="Y")
    CALL echo("Parameter OPT_IGNORE_CONCEPTS does not exist!")
    SET nomendata->ignore_concepts_ind = 0
   ELSEIF (((trim(opt_ignore_concepts) < " ") OR (trim(opt_ignore_concepts)="<undefined>")) )
    CALL echo("Optional parameter OPT_VOCAB_HIERARCHY is not defined.")
    SET nomendata->ignore_concepts_ind = 0
   ELSE
    CALL echo(concat("optional parameter OPT_IGNORE_CONCEPTS: ",build(opt_ignore_concepts)))
    IF (cnvtupper(trim(opt_ignore_concepts))="YES")
     SET nomendata->ignore_concepts_ind = 1
    ELSEIF (cnvtupper(trim(opt_ignore_concepts))="NO")
     SET nomendata->ignore_concepts_ind = 0
    ELSE
     SET retval = 0
     SET msg = concat("invalid option found - ",trim(opt_ignore_concepts))
     GO TO endprogram
    ENDIF
   ENDIF
   CALL echo(concat("nomendata->ignore_concepts_ind: ",build(nomendata->ignore_concepts_ind)))
   IF (validate(opt_match_all,"Z")="Z"
    AND validate(opt_match_all,"Y")="Y")
    CALL echo("Parameter OPT_MATCH_ALL does not exist!")
    SET nomendata->all_matches_ind = 1
   ELSEIF (((trim(opt_match_all) < " ") OR (trim(opt_match_all)="<undefined>")) )
    CALL echo("Optional parameter OPT_MATCH_ALL is not defined.")
    SET nomendata->all_matches_ind = 1
   ELSE
    CALL echo(concat("optional parameter OPT_MATCH_ALL: ",build(opt_match_all)))
    IF (cnvtupper(trim(opt_match_all))="YES")
     SET nomendata->all_matches_ind = 1
    ELSEIF (cnvtupper(trim(opt_match_all))="NO")
     SET nomendata->all_matches_ind = 0
    ELSE
     SET retval = 0
     SET msg = concat("invalid option found - ",trim(opt_match_all))
     GO TO endprogram
    ENDIF
   ENDIF
   CALL echo(concat("nomendata->all_matches_ind: ",build(nomendata->all_matches_ind)))
 END ;Subroutine
#endprogram
 IF (tcurindex > 0
  AND curindex > 0)
  SET rev_inc = "708"
  SET ininc = "eks_set_eksdata"
  IF (accessionid=0)
   IF (orderid != 0)
    SELECT INTO "NL:"
     a.accession_id
     FROM accession_order_r a
     WHERE a.order_id=orderid
      AND a.primary_flag=0
     DETAIL
      accessionid = a.accession_id
     WITH nocounter
    ;end select
   ELSEIF ( NOT (validate(accession,"Y")="Y"
    AND validate(accession,"Z")="Z"))
    IF (textlen(trim(accession)) > 0)
     SELECT INTO "NL:"
      a.accession_id
      FROM accession_order_r a
      WHERE a.accession=accession
      DETAIL
       accessionid = a.accession_id
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
  ENDIF
  IF (personid=0)
   FREE SET temp
   IF (orderid > 0)
    SELECT
     *
     FROM orders o
     WHERE o.order_id=orderid
     DETAIL
      personid = o.person_id
     WITH nocounter
    ;end select
   ELSEIF (encntrid > 0)
    SELECT
     *
     FROM encounter en
     WHERE en.encntr_id=encntrid
     DETAIL
      personid = en.person_id
     WITH nocounter
    ;end select
   ENDIF
   IF ( NOT (validate(temp,"Y")="Y"
    AND validate(temp,"Z")="Z"))
    SELECT INTO "nl:"
     o.person_id
     FROM orders o
     WHERE parser(temp)
     DETAIL
      personid = o.person_id
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
  SET eksdata->tqual[tcurindex].qual[curindex].accession_id = accessionid
  SET eksdata->tqual[tcurindex].qual[curindex].order_id = orderid
  SET eksdata->tqual[tcurindex].qual[curindex].encntr_id = encntrid
  SET eksdata->tqual[tcurindex].qual[curindex].person_id = personid
  IF ( NOT (validate(ekstaskassaycd,0)=0
   AND validate(ekstaskassaycd,1)=1))
   SET eksdata->tqual[tcurindex].qual[curindex].task_assay_cd = ekstaskassaycd
  ELSE
   SET eksdata->tqual[tcurindex].qual[curindex].task_assay_cd = 0
  ENDIF
  IF ( NOT (validate(eksdata->tqual[tcurindex].qual[curindex].template_name,"Y")="Y"
   AND validate(eksdata->tqual[tcurindex].qual[curindex].template_name,"Z")="Z"))
   IF (trim(eksdata->tqual[tcurindex].qual[curindex].template_name)=""
    AND  NOT (validate(tname,"Y")="Y"
    AND validate(tname,"Z")="Z"))
    SET eksdata->tqual[tcurindex].qual[curindex].template_name = tname
   ENDIF
  ENDIF
  IF ( NOT (validate(eksce_id,0)=0
   AND validate(eksce_id,1)=1))
   IF ( NOT (validate(eksdata->tqual[tcurindex].qual[curindex].clinical_event_id,0)=0
    AND validate(eksdata->tqual[tcurindex].qual[curindex].clinical_event_id,1)=1))
    SET eksdata->tqual[tcurindex].qual[curindex].clinical_event_id = eksce_id
   ENDIF
  ENDIF
  SET stat = alterlist(eksdata->tqual[tcurindex].qual[curindex].data,(nomendata->match_cnt+ 1))
  SET eksdata->tqual[tcurindex].qual[curindex].cnt = nomendata->match_cnt
  SET eksdata->tqual[tcurindex].qual[curindex].data[1].misc = "<PROBLEM_ID:PROBLEM_INSTANCE_ID>"
  SET icnt = 0
  FOR (i = 1 TO nomendata->nomen_cnt)
    IF ((nomendata->nomen_qual[i].match_ind > 0))
     SET icnt += 1
     SET eksdata->tqual[tcurindex].qual[curindex].data[(icnt+ 1)].misc = concat(trim(cnvtstring(
        nomendata->nomen_qual[i].misc_id,25,1)),":",trim(cnvtstring(nomendata->nomen_qual[i].
        misc_instance_id,25,1)))
     CALL echo(concat("PROBLEM_ID:PROBLEM_INSTANCE_ID = ",eksdata->tqual[tcurindex].qual[curindex].
       data[(icnt+ 1)].misc))
    ENDIF
  ENDFOR
 ELSE
  IF ((retval=- (1)))
   SET retval = 0
  ENDIF
 ENDIF
 SET t_time->end_tm = curtime3
 SET t_time->diff = ((t_time->end_tm - t_time->start_tm)/ 100)
 SET msg = concat(msg," (",trim(format(t_time->diff,"######.######"),3)," s)")
 SET eksdata->tqual[tcurindex].qual[curindex].logging = msg
 CALL echo(msg)
 SET mod_version = "004 04/07/14"
 CALL echo(concat(format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   "  *******  End of Program bhs_eks_t_problems_find  *********"),1,0)
END GO
