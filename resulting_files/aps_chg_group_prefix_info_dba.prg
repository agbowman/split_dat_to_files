CREATE PROGRAM aps_chg_group_prefix_info:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 exception_data[*]
     2 prefix_cd = f8
     2 prefix_name = c2
 )
 SET reply->status_data.status = "F"
 SET ap_act_code = 0.0
 SET next_grp_code = 0.0
 SET next_pre_code = 0.0
 SET next_acc_code = 0.0
 SET cur_updt_cnt = 0
 SET error_cnt = 0
 SET tag_error_cnt = 0
 SET add_tag_error = 0
 SET cnt = 0
 SET tag_error_ind = 0
 SET count1 = 0
 SET x = 1
 SET y = 1
 SET nbr_of_groups = cnvtint(size(request->group_qual,5))
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=106
   AND c.cdf_meaning="AP"
   AND c.active_ind=1
  HEAD REPORT
   ap_act_code = 0.0
  DETAIL
   ap_act_code = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","CODE_VALUE","ACTIVITY_CODE")
  GO TO exit_script
 ENDIF
 SET _acc_assign_date = cnvtdatetimeutc(cnvtdatetime(cnvtdate2(concat("0101",cnvtstring(year(curdate),
      4,0,r)),"mmddyyyy"),0),2)
#start_of_groups
 IF (x != 1)
  ROLLBACK
 ENDIF
 FOR (x = x TO nbr_of_groups)
  IF ((request->group_qual[x].grp_act_ind="a"))
   SELECT INTO "nl:"
    seq_nbr = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     next_grp_code = cnvtreal(seq_nbr)
    WITH format, counter
   ;end select
   IF (curqual=0)
    CALL handle_errors("NEXTVAL","F","SEQUENCE","REFERENCE_SEQ")
    SET x += 1
    GO TO start_of_groups
   ENDIF
   INSERT  FROM accession_assign_pool aap
    SET aap.accession_assignment_pool_id = next_grp_code, aap.initial_value = 1, aap.reset_frequency
      = 1,
     aap.description = request->group_qual[x].group_desc, aap.increment_value = 1, aap
     .activity_type_cd = ap_act_code,
     aap.updt_dt_tm = cnvtdatetime(curdate,curtime), aap.updt_id = reqinfo->updt_id, aap.updt_task =
     reqinfo->updt_task,
     aap.updt_applctx = reqinfo->updt_applctx, aap.updt_cnt = 0
    WITH counter
   ;end insert
   IF (curqual=0)
    CALL handle_errors("INSERT","F","TABLE","ACCESSION_ASSIGN_POOL")
    SET x += 1
    GO TO start_of_groups
   ENDIF
   IF ((request->group_qual[x].next_available_nbr > 1))
    INSERT  FROM accession_assignment aa
     SET aa.acc_assign_pool_id = next_grp_code, aa.acc_assign_date = cnvtdatetimeutc(_acc_assign_date,
       0), aa.accession_seq_nbr = request->group_qual[x].next_available_nbr,
      aa.last_increment_dt_tm = cnvtdatetime(sysdate), aa.increment_value = 1, aa.updt_cnt = 0,
      aa.updt_dt_tm = cnvtdatetime(sysdate), aa.updt_id = reqinfo->updt_id, aa.updt_task = reqinfo->
      updt_task,
      aa.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL handle_errors("INSERT","F","TABLE","ACCESSION_ASSIGNMENT")
     SET x += 1
     GO TO start_of_groups
    ENDIF
   ENDIF
   SET request->group_qual[x].group_cd = next_grp_code
   INSERT  FROM prefix_group pg
    SET pg.group_id = next_grp_code, pg.group_name = request->group_qual[x].group_name, pg.group_desc
      = request->group_qual[x].group_desc,
     pg.reset_yearly_ind = request->group_qual[x].reset_yearly_ind, pg.manual_assign_ind = request->
     group_qual[x].manual_assign_ind, pg.active_ind = request->group_qual[x].active_ind,
     pg.site_cd = request->group_qual[x].site_cd, pg.updt_dt_tm = cnvtdatetime(curdate,curtime), pg
     .updt_id = reqinfo->updt_id,
     pg.updt_task = reqinfo->updt_task, pg.updt_applctx = reqinfo->updt_applctx, pg.updt_cnt = 0
    WITH counter
   ;end insert
   IF (curqual=0)
    CALL handle_errors("INSERT","F","TABLE","PREFIX_GROUP")
    SET x += 1
    GO TO start_of_groups
   ENDIF
   COMMIT
  ELSEIF ((request->group_qual[x].grp_act_ind="c"))
   SELECT INTO "nl:"
    pg.*
    FROM prefix_group pg
    WHERE (request->group_qual[x].group_cd=pg.group_id)
    DETAIL
     cur_updt_cnt = pg.updt_cnt
    WITH forupdate(pg)
   ;end select
   IF (curqual=0)
    CALL handle_errors("SELECT","F","TABLE","PREFIX_GROUP")
    SET x += 1
    GO TO start_of_groups
   ELSE
    IF ((request->group_qual[x].pg_updt_cnt != cur_updt_cnt))
     CALL handle_errors("LOCK","F","TABLE","PREFIX_GROUP")
     SET x += 1
     GO TO start_of_groups
    ELSE
     SET cur_updt_cnt += 1
     UPDATE  FROM prefix_group pg
      SET pg.group_id = request->group_qual[x].group_cd, pg.group_name = request->group_qual[x].
       group_name, pg.group_desc = request->group_qual[x].group_desc,
       pg.reset_yearly_ind = request->group_qual[x].reset_yearly_ind, pg.manual_assign_ind = request
       ->group_qual[x].manual_assign_ind, pg.active_ind = request->group_qual[x].active_ind,
       pg.site_cd = request->group_qual[x].site_cd, pg.updt_dt_tm = cnvtdatetime(curdate,curtime), pg
       .updt_id = reqinfo->updt_id,
       pg.updt_task = reqinfo->updt_task, pg.updt_applctx = reqinfo->updt_applctx, pg.updt_cnt =
       cur_updt_cnt
      WHERE (request->group_qual[x].group_cd=pg.group_id)
      WITH counter
     ;end update
     IF (curqual=0)
      CALL handle_errors("UPDATE","F","TABLE","PREFIX_GROUP")
      SET x += 1
      GO TO start_of_groups
     ELSE
      SELECT INTO "nl:"
       aap.accession_assignment_pool_id
       FROM accession_assign_pool aap
       WHERE (request->group_qual[x].group_cd=aap.accession_assignment_pool_id)
       DETAIL
        cur_updt_cnt = aap.updt_cnt
       WITH forupdate(aap)
      ;end select
      IF (curqual=0)
       CALL handle_errors("SELECT","F","TABLE","ACCESSION_ASSIGN_POOL")
       SET x += 1
       GO TO start_of_groups
      ELSE
       IF ((request->group_qual[x].aap_updt_cnt != cur_updt_cnt))
        CALL handle_errors("LOCK","F","TABLE","ACCESSION_ASSIGN_POOL")
        SET x += 1
        GO TO start_of_groups
       ELSE
        SET cur_updt_cnt += 1
        UPDATE  FROM accession_assign_pool aap
         SET aap.accession_assignment_pool_id = request->group_qual[x].group_cd, aap.description =
          request->group_qual[x].group_desc, aap.updt_dt_tm = cnvtdatetime(curdate,curtime),
          aap.updt_id = reqinfo->updt_id, aap.updt_task = reqinfo->updt_task, aap.updt_applctx =
          reqinfo->updt_applctx,
          aap.updt_cnt = cur_updt_cnt
         WHERE (request->group_qual[x].group_cd=aap.accession_assignment_pool_id)
         WITH counter
        ;end update
        IF (curqual=0)
         CALL handle_errors("UPDATE","F","TABLE","ACCESSION_ASSIGN_POOL")
         SET x += 1
         GO TO start_of_groups
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   COMMIT
  ENDIF
  EXECUTE aps_chg_db_prefixes
 ENDFOR
#exit_script
 IF (error_cnt > 0)
  IF (error_cnt=nbr_of_groups)
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "P"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 GO TO end_of_program
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt += 1
   IF (tag_error_ind=1)
    SET add_tag_error = 1
    SET cnt = 1
    IF (tag_error_cnt > 0)
     WHILE (((cnt <= tag_error_cnt) OR (add_tag_error=1)) )
      IF ((reply->exception_data[cnt].prefix_cd=request->group_qual[x].prefix_qual[y].prefix_cd))
       SET add_tag_error = 0
      ENDIF
      SET cnt += 1
     ENDWHILE
    ENDIF
    IF (add_tag_error=1)
     SET tag_error_cnt += 1
     SET stat = alterlist(reply->exception_data,tag_error_cnt)
     SET reply->exception_data[tag_error_cnt].prefix_cd = request->group_qual[x].prefix_qual[y].
     prefix_cd
     SET reply->exception_data[tag_error_cnt].prefix_name = ""
     SET reply->exception_data[tag_error_cnt].prefix_name = request->group_qual[x].prefix_qual[y].
     prefix_desc
    ENDIF
   ENDIF
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#end_of_program
END GO
