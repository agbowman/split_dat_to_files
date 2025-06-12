CREATE PROGRAM accession_gen:dba
 RECORD reply(
   1 accession_status = i2
   1 qual[*]
     2 accession = c20
     2 accession_id = f8
   1 acc_error = c20
   1 acc_error_id = f8
   1 acc_error_nbr_check = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET acc_ok = 0
 SET unk_error = 5
 SET dup_accession = 10
 SET upd_accession = 15
 SET unk_assign_status = 20
 SET acc_sequence = 25
 SET ins_accession = 30
 SET accession_yes = 35
 SET accession_preassign = 40
 SET accession_no = 45
 SET dup_to_accession = 50
 SET inv_from_accession = 55
 SET inv_accession_seq = 60
 SET inv_quantity = 65
 SET julian_sequence_length = 6
 SET prefix_sequence_length = 7
 SET reply->status_data.status = "Z"
 SET reqinfo->commit_ind = 0
 SET reply->accession_status = unk_error
 DECLARE accession = c20
 DECLARE accession_check = c50
#accession_gen_begin
 IF ((request->quantity=0))
  SET reply->accession_status = inv_quantity
  GO TO accession_gen_exit
 ENDIF
 SET sequence_length = julian_sequence_length
 IF ((request->alpha_prefix > " "))
  SET sequence_length = prefix_sequence_length
 ENDIF
 SET increment_value = 1
 IF ((request->accession_sequence_nbr > 0))
  SELECT INTO "nl:"
   aap.accession_assignment_pool_id, aap.increment_value
   FROM accession_assign_pool aap
   WHERE (aap.accession_assignment_pool_id=request->accession_pool_id)
   DETAIL
    increment_value = aap.increment_value
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   aa.acc_assign_pool_id, aa.increment_value, aa.accession_seq_nbr
   FROM accession_assignment aa
   WHERE (aa.acc_assign_pool_id=request->accession_pool_id)
    AND aa.acc_assign_date=cnvtdatetime(request->acc_assign_date)
   DETAIL
    increment_value = aa.increment_value, request->accession_sequence_nbr = aa.accession_seq_nbr
   WITH nocounter
  ;end select
  IF ((request->accession_sequence_nbr=0))
   SET request->accession_sequence_nbr = 1
   SELECT INTO "nl:"
    aap.accession_assignment_pool_id, aap.increment_value
    FROM accession_assign_pool aap
    WHERE (aap.accession_assignment_pool_id=request->accession_pool_id)
    DETAIL
     increment_value = aap.increment_value
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (increment_value=0)
  SET increment_value = 1
 ENDIF
 IF ((request->accession_sequence_nbr=0))
  SET reply->accession_status = inv_accession_seq
  GO TO accession_gen_exit
 ENDIF
 SET count = 0
 FOR (i = 1 TO request->quantity)
   SET ins_accession = 0
   WHILE (ins_accession=0)
     SET accession = ""
     SET accession_check = ""
     SET accession = concat(trim(accession),trim(request->accession),cnvtstring(request->
       accession_sequence_nbr,value(sequence_length),0,r))
     SET accession_check = concat(trim(accession_check),request->accession_nbr_check,cnvtstring(
       request->accession_sequence_nbr,value(sequence_length),0,r))
     SELECT INTO "nl:"
      a.accession_id, a.accession, a.accession_nbr_check
      FROM accession a
      WHERE a.accession_nbr_check=accession_check
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET ins_accession = 1
     ELSE
      SET request->accession_sequence_nbr = (request->accession_sequence_nbr+ increment_value)
     ENDIF
   ENDWHILE
   SET accession_id = 0
   SELECT INTO "nl:"
    nextsequence = seq(accession_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     accession_id = cnvtint(nextsequence)
    WITH format, counter
   ;end select
   IF (accession_id > 0)
    INSERT  FROM accession a
     SET a.accession_id = accession_id, a.accession = accession, a.accession_nbr_check = trim(
       accession_check),
      a.site_prefix_cd = request->site_prefix_cd, a.accession_year = request->accession_year, a
      .accession_day = request->accession_day,
      a.accession_format_cd = request->accession_format_cd, a.alpha_prefix = request->alpha_prefix, a
      .accession_sequence_nbr = request->accession_sequence_nbr,
      a.accession_class_cd = 0, a.accession_pool_id = request->accession_pool_id, a.preactive_ind = 0,
      a.assignment_ind = request->assignment_ind, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a
      .updt_id = reqinfo->updt_id,
      a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual > 0)
     SET count = i
     IF (count > size(reply->qual,5))
      SET stat = alterlist(reply->qual,(count+ 10))
     ENDIF
     SET reply->qual[count].accession = accession
     SET reply->qual[count].accession_id = accession_id
    ELSE
     SET reply->accession_status = ins_accession
     SET reply->acc_error = accession
     SET reply->acc_error_id = accession_id
     SET reply->acc_error_nbr_check = accession_nbr_check
     GO TO accession_gen_exit
    ENDIF
   ELSE
    SET reply->accession_status = acc_sequence
    GO TO accession_gen_exit
   ENDIF
   SET request->accession_sequence_nbr = (request->accession_sequence_nbr+ increment_value)
 ENDFOR
 SET stat = alterlist(reply->qual,count)
 SET reply->accession_status = acc_ok
#accession_gen_exit
 IF ((reply->accession_status=acc_ok))
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
