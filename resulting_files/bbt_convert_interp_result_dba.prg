CREATE PROGRAM bbt_convert_interp_result:dba
 RECORD request(
   1 qual[1000]
     2 interp_result_id = f8
     2 interp_result_text = vc
     2 long_text_id = f8
     2 interp_active_ind = i2
     2 interp_active_status_cd = f8
     2 interp_active_dt_tm = dq8
     2 interp_active_id = f8
     2 updt_id = f8
     2 updt_applctx = f8
     2 updt_task = f8
 )
 SET active_code = 0.0
 SET x = 0
 SET idx = 0
 SET failed = "F"
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=48
   AND c.cdf_meaning="ACTIVE"
  DETAIL
   active_code = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET active_code = 0.0
 ENDIF
 SELECT
  *
  FROM interp_result i
  DETAIL
   x = (x+ 1), request->qual[x].interp_result_id = i.interp_result_id, request->qual[x].
   interp_result_text = i.result_text,
   request->qual[x].long_text_id = i.long_text_id, request->qual[x].interp_active_ind = i.active_ind,
   request->qual[x].interp_active_status_cd = i.active_status_cd,
   request->qual[x].interp_active_dt_tm = cnvtdatetime(i.active_status_dt_tm), request->qual[x].
   interp_active_id = i.active_status_prsnl_id, request->qual[x].updt_id = i.updt_id,
   request->qual[x].updt_applctx = i.updt_applctx, request->qual[x].updt_task = i.updt_task
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  GO TO end_program
 ENDIF
 IF (x=0)
  SET failed = "T"
  GO TO end_program
 ENDIF
 FOR (idx = 1 TO x)
   IF ((request->qual[idx].long_text_id=null))
    IF ((request->qual[idx].interp_result_text > ""))
     SET new_nbr = 0.0
     SELECT INTO "nl:"
      y = seq(long_data_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_nbr = cnvtreal(y)
      WITH format, counter
     ;end select
     IF (curqual=0)
      SET failed = "T"
      GO TO end_program
     ELSE
      INSERT  FROM long_text l
       SET l.long_text_id = new_nbr, l.parent_entity_name = "INTERP_RESULT", l.parent_entity_id =
        request->qual[idx].interp_result_id,
        l.long_text = request->qual[idx].interp_result_text, l.active_ind = request->qual[idx].
        interp_active_ind, l.active_status_cd = request->qual[idx].interp_active_status_cd,
        l.active_status_prsnl_id = request->qual[idx].updt_id, l.active_status_dt_tm = cnvtdatetime(
         request->qual[idx].interp_active_dt_tm), l.updt_cnt = 0,
        l.updt_dt_tm = cnvtdatetime(curdate,curtime), l.updt_id = request->qual[idx].updt_id, l
        .updt_applctx = request->qual[idx].updt_applctx,
        l.updt_task = request->qual[idx].updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET failed = "T"
       GO TO end_program
      ELSE
       SET request->qual[idx].long_text_id = new_nbr
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 FOR (idx = 1 TO x)
   IF ((request->qual[idx].interp_result_text > ""))
    IF ((request->qual[idx].long_text_id > 0))
     SELECT INTO "nl:"
      i.*
      FROM interp_result i
      WHERE (i.interp_result_id=request->qual[idx].interp_result_id)
      WITH nocounter, forupdate(i)
     ;end select
     IF (curqual=0)
      SET failed = "T"
      GO TO end_program
     ENDIF
     UPDATE  FROM interp_result i
      SET i.long_text_id = request->qual[idx].long_text_id, i.updt_cnt = (i.updt_cnt+ 1), i
       .updt_dt_tm = cnvtdatetime(curdate,curtime)
      WHERE (i.interp_result_id=request->qual[idx].interp_result_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = "T"
      GO TO end_program
     ENDIF
    ELSE
     SET failed = "T"
     GO TO end_program
    ENDIF
   ENDIF
 ENDFOR
#end_program
 IF (failed="T")
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
END GO
