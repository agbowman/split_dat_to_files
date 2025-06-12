CREATE PROGRAM bed_ens_rli_alias:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE error_flag = vc WITH private
 DECLARE error_msg = vc WITH private
 DECLARE numorders = i4
 DECLARE volume_units_cd = f8
 DECLARE supplier_flag = i4
 DECLARE supplier_meaning = vc
 DECLARE errmsg = vc
 DECLARE fatal_err = vc
 DECLARE err_cnt = i2
 DECLARE rvar = i2
 SELECT INTO "ccluserdir:bed_rli_alias_error.log"
  rvar
  HEAD REPORT
   curdate"dd-mmm-yyyy;;d", "-", curtime"hh:mm;;m",
   col + 1, "Bedrock RLI Alias Error Log"
  DETAIL
   row + 2, col 2, " "
  WITH nocounter, format = variable, version,
   noformfeed, maxcol = 132, maxrow = 1
 ;end select
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET err_cnt = 0
 SET fatal_err = "N"
 SET numorders = size(request->alias_list,5)
 CALL echorecord(request)
 FOR (i = 1 TO numorders)
   SELECT INTO "nl:"
    FROM br_rli_supplier brs
    PLAN (brs
     WHERE (brs.supplier_flag=request->alias_list[i].supplier_flag))
    DETAIL
     supplier_flag = brs.supplier_flag, supplier_meaning = brs.supplier_meaning
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Unable to read rli supplier data for supplier flag: ",request->
     alias_list[i].supplier_flag)
    SET fatal_err = "Y"
    SET errmsg = error_msg
    CALL logerrormessage(errmsg)
    GO TO exit_script
   ENDIF
   IF ((((request->alias_list[i].action_flag=1)) OR ((request->alias_list[i].action_flag=4))) )
    SELECT INTO "nl:"
     FROM br_auto_rli_alias b
     WHERE (b.code_set=request->alias_list[i].code_set)
      AND b.supplier_flag=supplier_flag
      AND (b.alias_name=request->alias_list[i].alias)
     WITH nocounter
    ;end select
    IF (curqual=0)
     INSERT  FROM br_auto_rli_alias b
      SET b.supplier_flag = supplier_flag, b.alias_id = seq(bedrock_seq,nextval), b.alias_name =
       request->alias_list[i].alias,
       b.code_set = request->alias_list[i].code_set, b.code_value = request->alias_list[i].code_value,
       b.display = request->alias_list[i].display,
       b.description = request->alias_list[i].description, b.definition = request->alias_list[i].
       definition, b.cdf_meaning = request->alias_list[i].cdf_meaning,
       b.unit_meaning = request->alias_list[i].unit_meaning, b.action_flag = request->alias_list[i].
       action_flag, b.active_ind = 1,
       b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,
        curtime),
       b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "T"
      SET error_msg = concat(error_msg,"Error adding code_value_alias for alias: ",request->
       alias_list[i].alias)
      SET errmsg = error_msg
      CALL logerrormessage(errmsg)
      GO TO exit_script
     ENDIF
    ENDIF
   ELSEIF ((request->alias_list[i].action_flag=2))
    UPDATE  FROM br_auto_rli_alias b
     SET b.alias_name = request->alias_list[i].alias, b.updt_applctx = reqinfo->updt_applctx, b
      .updt_cnt = (b.updt_cnt+ 1),
      b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = reqinfo->updt_id, b.updt_task =
      reqinfo->updt_task
     WHERE (b.code_set=request->alias_list[i].code_set)
      AND (b.code_value=request->alias_list[i].code_value)
     WITH nocounter
    ;end update
   ELSEIF ((request->alias_list[i].action_flag=3))
    UPDATE  FROM br_auto_rli_alias b
     SET b.active_ind = 0, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = (b.updt_cnt+ 1),
      b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = reqinfo->updt_id, b.updt_task =
      reqinfo->updt_task
     WHERE (b.code_set=request->alias_list[i].code_set)
      AND (b.code_value=request->alias_list[i].code_value)
     WITH nocounter
    ;end update
   ENDIF
 ENDFOR
 GO TO exit_script
 SUBROUTINE logerrormessage(errmsg)
   SET rvar = 0
   SELECT INTO "ccluserdir:bed_rli_alias_error.log"
    rvar
    DETAIL
     row + 1, col 0, errmsg
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 500, maxrow = 1
   ;end select
   IF (fatal_err="Y")
    SELECT INTO "ccluserdir:bed_rli_alias_error.log"
     rvar
     DETAIL
      row + 1, col 0, "Fatal error encountered - exiting script"
     WITH nocounter, append, format = variable,
      noformfeed, maxcol = 500, maxrow = 1
    ;end select
    GO TO exit_script
   ENDIF
   SET err_cnt = (err_cnt+ 1)
   IF (err_cnt > 20)
    SELECT INTO "ccluserdir:bed_rli_alias_error.log"
     rvar
     DETAIL
      row + 1, col 0, "Error threshhold exceeded - exiting script"
     WITH nocounter, append, format = variable,
      noformfeed, maxcol = 500, maxrow = 1
    ;end select
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="T")
  SET reply->error_msg = error_msg
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
