CREATE PROGRAM afc_upt_bill_item:dba
 IF ("Z"=validate(afc_upt_bill_item_vrsn,"Z"))
  DECLARE afc_upt_bill_item_vrsn = vc WITH noconstant("469360.016")
 ENDIF
 SET afc_upt_bill_item_vrsn = "469360.016"
 IF ((validate(passive_check_define,- (99))=- (99)))
  DECLARE passive_check_define = i4 WITH constant(1)
  DECLARE column_exists(stable,scolumn) = i4
  SUBROUTINE column_exists(stable,scolumn)
    DECLARE ce_flag = i4
    SET ce_flag = 0
    DECLARE ce_temp = vc WITH noconstant("")
    SET stable = cnvtupper(stable)
    SET scolumn = cnvtupper(scolumn)
    IF (((currev=8
     AND currevminor=2
     AND currevminor2 >= 4) OR (((currev=8
     AND currevminor > 2) OR (currev > 8)) )) )
     SET ce_temp = build('"',stable,".",scolumn,'"')
     SET stat = checkdic(parser(ce_temp),"A",0)
     IF (stat > 0)
      SET ce_flag = 1
     ENDIF
    ELSE
     SELECT INTO "nl:"
      l.attr_name
      FROM dtableattr a,
       dtableattrl l
      WHERE a.table_name=stable
       AND l.attr_name=scolumn
       AND l.structtype="F"
       AND btest(l.stat,11)=0
      DETAIL
       ce_flag = 1
      WITH nocounter
     ;end select
    ENDIF
    RETURN(ce_flag)
  END ;Subroutine
 ENDIF
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 SET false = 0
 SET true = 1
 SET failedme = false
 SET table_name = fillstring(50," ")
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE taskcat = f8
 DECLARE ncolumnexists = i4 WITH noconstant(0)
 SET cdf_meaning = "TASKCAT"
 SET code_set = 13016
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET taskcat = code_value
 CALL echo(build("the taskcat code is : ",taskcat))
 DECLARE item_definition = f8
 SET cdf_meaning = "ITEM MASTER"
 SET code_set = 13016
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET item_definition = code_value
 CALL echo(build("ITEM_DEFINITION: ",cnvtstring(item_definition,17,2)))
 DECLARE alpha_response = f8
 SET cdf_meaning = "ALPHA RESP"
 SET code_set = 48
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET alpha_response = code_value
 CALL echo(build("ALPHA_RESPSONSE: ",cnvtstring(alpha_response,17,2)))
 DECLARE manf_item = f8
 SET cdf_meaning = "MANF ITEM"
 SET code_set = 13016
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET manf_item = code_value
 CALL echo(build("MANF_ITEM: ",cnvtstring(manf_item,17,2)))
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 bill_item_qual = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->bill_item_qual
  SET reply->bill_item_qual = request->bill_item_qual
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "BILL_ITEM"
 CALL upt_bill_item(action_begin,action_end)
 IF (failedme != false)
  GO TO check_error
 ENDIF
#check_error
 IF (failedme=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failedme)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF replace_error:
    SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   OF undelete_error:
    SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
   OF remove_error:
    SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
 GO TO end_program
 SUBROUTINE upt_bill_item(upt_begin,upt_end)
   FOR (x = upt_begin TO upt_end)
     SET cur_updt_cnt[value(upt_end)] = 0
     SET count1 = 0
     SELECT INTO "nl:"
      b.*
      FROM bill_item b,
       (dummyt d  WITH seq = value(upt_end))
      PLAN (d)
       JOIN (b
       WHERE (b.bill_item_id=request->bill_item[d.seq].bill_item_id))
      HEAD REPORT
       count1 = 0
      DETAIL
       count1 += 1, cur_updt_cnt[count1] = b.updt_cnt
      WITH forupdate(b), nocounter
     ;end select
     IF (count1 != upt_end)
      SET failedme = lock_error
      RETURN
     ENDIF
     UPDATE  FROM bill_item b,
       (dummyt d  WITH seq = 1)
      SET b.seq = 1, b.beg_effective_dt_tm = nullcheck(b.beg_effective_dt_tm,cnvtdatetime(request->
         bill_item[x].beg_effective_dt_tm),
        IF ((request->bill_item[x].beg_effective_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ), b.end_effective_dt_tm = nullcheck(b.end_effective_dt_tm,cnvtdatetime(request->bill_item[x]
         .end_effective_dt_tm),
        IF ((request->bill_item[x].end_effective_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ),
       b.ext_owner_cd = nullcheck(b.ext_owner_cd,request->bill_item[x].ext_owner_cd,
        IF ((request->bill_item[x].ext_owner_cd=0)) 0
        ELSE 1
        ENDIF
        ), b.ext_sub_owner_cd = validate(request->bill_item[x].ext_sub_owner_cd,b.ext_sub_owner_cd),
       b.ext_description = nullcheck(b.ext_description,request->bill_item[x].ext_description,
        IF (trim(request->bill_item[x].ext_description)="") 0
        ELSE 1
        ENDIF
        ),
       b.ext_short_desc = nullcheck(b.ext_short_desc,request->bill_item[x].ext_short_desc,
        IF (trim(request->bill_item[x].ext_short_desc)="") 0
        ELSE 1
        ENDIF
        ), b.charge_point_cd = nullcheck(b.charge_point_cd,request->bill_item[x].charge_point_cd,
        IF ((request->bill_item[x].charge_point_cd=0)) 0
        ELSE 1
        ENDIF
        ), b.workload_only_ind = request->bill_item[x].workload_only_ind,
       b.active_ind = 1, b.active_status_cd = nullcheck(b.active_status_cd,request->bill_item[x].
        active_status_cd,
        IF ((request->bill_item[x].active_status_cd=0)) 0
        ELSE 1
        ENDIF
        ), b.active_status_prsnl_id = nullcheck(b.active_status_prsnl_id,request->bill_item[x].
        active_status_prsnl_id,
        IF ((request->bill_item[x].active_status_prsnl_id=0)) 0
        ELSE 1
        ENDIF
        ),
       b.active_status_dt_tm = nullcheck(b.active_status_dt_tm,cnvtdatetime(request->bill_item[x].
         active_status_dt_tm),
        IF ((request->bill_item[x].active_status_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ), b.updt_cnt = (cur_updt_cnt[d.seq]+ 1), b.updt_dt_tm = cnvtdatetime(curdate,curtime),
       b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->
       updt_task,
       b.ext_parent_entity_name =
       IF ((request->bill_item[x].ext_parent_contributor_cd=item_definition)) "ITEM_DEFINITION"
       ELSEIF ((request->bill_item[x].ext_parent_contributor_cd=taskcat)) "ORDER_TASK"
       ELSEIF ((request->bill_item[x].ext_parent_contributor_cd=manf_item)) "MANUFACTURER_ITEM"
       ELSEIF ((request->bill_item[x].ext_parent_reference_id != 0)) "CODE_VALUE"
       ELSE ""
       ENDIF
       , b.ext_child_entity_name =
       IF ((request->bill_item[x].ext_child_contributor_cd=alpha_response)) "NOMENCLATURE"
       ELSEIF ((request->bill_item[x].ext_child_contributor_cd=taskcat)) "ORDER_TASK"
       ELSEIF ((request->bill_item[x].ext_child_reference_id != 0)) "CODE_VALUE"
       ELSE ""
       ENDIF
       , b.misc_ind = request->bill_item[x].misc_ind,
       b.stats_only_ind = request->bill_item[x].stats_only_ind, b.logical_domain_id = validate(
        request->logical_domain_id,b.logical_domain_id), b.logical_domain_enabled_ind = validate(
        request->logical_domain_enabled_ind,b.logical_domain_enabled_ind)
      PLAN (d)
       JOIN (b
       WHERE (b.bill_item_id=request->bill_item[x].bill_item_id))
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET reply->bill_item_qual = curqual
      SET failedme = update_error
      RETURN
     ELSE
      SET reqinfo->commit_ind = true
     ENDIF
     SET ncolumnexists = column_exists("BILL_ITEM","LATE_CHRG_EXCL_IND")
     IF (ncolumnexists=1)
      UPDATE  FROM bill_item b
       SET b.late_chrg_excl_ind = request->bill_item[x].late_chrg_excl_ind
       WHERE (b.bill_item_id=request->bill_item[x].bill_item_id)
      ;end update
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
