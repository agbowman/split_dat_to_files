CREATE PROGRAM bed_imp_br_sched_dept_type:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET temp_subacts
 RECORD temp_subacts(
   1 subacts[*]
     2 sa_code_value = f8
 )
 SET reply->status_data.status = "F"
 SET tot_cnt = size(requestin->list_0,5)
 FOR (x = 1 TO tot_cnt)
   SET stat = initrec(temp_subacts)
   SET skip_ind = 0
   SET cat_type_code_value = 0.0
   IF ((requestin->list_0[x].cat_cdf > " "))
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_set=6000
      AND (cv.cdf_meaning=requestin->list_0[x].cat_cdf)
      AND cv.active_ind=1
     DETAIL
      cat_type_code_value = cv.code_value
     WITH nocounter
    ;end select
    IF (((cat_type_code_value=0) OR (curqual > 1)) )
     SET skip_ind = 1
    ENDIF
   ENDIF
   SET act_type_code_value = 0.0
   IF ((requestin->list_0[x].act_cdf > " "))
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_set=106
      AND (cv.cdf_meaning=requestin->list_0[x].act_cdf)
      AND cv.active_ind=1
     DETAIL
      act_type_code_value = cv.code_value
     WITH nocounter
    ;end select
    IF (((act_type_code_value=0) OR (curqual > 1)) )
     SET skip_ind = 1
    ENDIF
   ENDIF
   SET sub_act_type_code_value1 = 0.0
   SET tcnt = 0
   SET subact_cnt = 0
   IF ((requestin->list_0[x].sub_act_cdf1 > " "))
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_set=5801
      AND (cv.cdf_meaning=requestin->list_0[x].sub_act_cdf1)
      AND cv.active_ind=1
     HEAD REPORT
      cnt = 0, tcnt = 0, stat = alterlist(temp_subacts->subacts,10)
     DETAIL
      cnt = (cnt+ 1), tcnt = (tcnt+ 1)
      IF (cnt > 10)
       stat = alterlist(temp_subacts->subacts,(tcnt+ 10)), cnt = 1
      ENDIF
      temp_subacts->subacts[tcnt].sa_code_value = cv.code_value
     FOOT REPORT
      stat = alterlist(temp_subacts->subacts,tcnt)
     WITH nocounter
    ;end select
    SET subact_cnt = tcnt
    IF (subact_cnt=0)
     SET skip_ind = 1
    ENDIF
   ENDIF
   SET sub_act_type_code_value2 = 0.0
   SET sact_size2 = 0
   IF ((requestin->list_0[x].sub_act_cdf2 > " "))
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_set=5801
      AND (cv.cdf_meaning=requestin->list_0[x].sub_act_cdf2)
      AND cv.active_ind=1
     HEAD REPORT
      cnt = 0, tcnt = size(temp_subacts->subacts,5), stat = alterlist(temp_subacts->subacts,(tcnt+ 10
       ))
     DETAIL
      cnt = (cnt+ 1), tcnt = (tcnt+ 1)
      IF (cnt > 10)
       stat = alterlist(temp_subacts->subacts,(tcnt+ 10)), cnt = 1
      ENDIF
      temp_subacts->subacts[tcnt].sa_code_value = cv.code_value
     FOOT REPORT
      stat = alterlist(temp_subacts->subacts,tcnt)
     WITH nocounter
    ;end select
    IF (subact_cnt=tcnt)
     SET skip_ind = 1
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].department_name > " ")
    AND (requestin->list_0[x].prefix > " "))
    SET dept_id = 0.0
    SELECT INTO "NL:"
     j = seq(bedrock_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      dept_id = cnvtreal(j)
     WITH format, counter
    ;end select
    INSERT  FROM br_sched_dept_type b
     SET b.dept_type_id = dept_id, b.dept_type_display = trim(substring(1,40,requestin->list_0[x].
        department_name)), b.dept_type_prefix = trim(substring(1,4,requestin->list_0[x].prefix)),
      b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
      b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (skip_ind=0
     AND cat_type_code_value > 0)
     IF (tcnt > 0)
      FOR (b = 1 TO tcnt)
        INSERT  FROM br_sched_dept_type_r btr
         SET btr.dept_type_id = dept_id, btr.catalog_type_cd = cat_type_code_value, btr
          .activity_type_cd = act_type_code_value,
          btr.activity_subtype_cd = temp_subacts->subacts[b].sa_code_value, btr.updt_cnt = 0, btr
          .updt_dt_tm = cnvtdatetime(curdate,curtime3),
          btr.updt_id = reqinfo->updt_id, btr.updt_task = reqinfo->updt_task, btr.updt_applctx =
          reqinfo->updt_applctx
         WITH nocounter
        ;end insert
      ENDFOR
     ELSE
      INSERT  FROM br_sched_dept_type_r btr
       SET btr.dept_type_id = dept_id, btr.catalog_type_cd = cat_type_code_value, btr
        .activity_type_cd = act_type_code_value,
        btr.activity_subtype_cd = 0.0, btr.updt_cnt = 0, btr.updt_dt_tm = cnvtdatetime(curdate,
         curtime3),
        btr.updt_id = reqinfo->updt_id, btr.updt_task = reqinfo->updt_task, btr.updt_applctx =
        reqinfo->updt_applctx
       WITH nocounter
      ;end insert
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
