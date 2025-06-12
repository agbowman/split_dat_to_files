CREATE PROGRAM afc_add_bill_item:dba
 IF ("Z"=validate(afc_add_bill_item_vrsn,"Z"))
  DECLARE afc_add_bill_item_vrsn = vc WITH noconstant("469360.013")
 ENDIF
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
 DECLARE taskcat = f8 WITH noconstant(0.0)
 DECLARE ncolumnexists = i4 WITH noconstant(0)
 SET false = 0
 SET true = 1
 SET failedme = false
 SET table_name = fillstring(50," ")
 SET taskcat = 0
 SET code_set = 13016
 SET code_value = 0.0
 SET cdf_meaning = "TASKCAT"
 EXECUTE cpm_get_cd_for_cdf
 SET taskcat = code_value
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 actioncnt = i2
    1 actionlist[*]
      2 action1 = vc
      2 action2 = vc
    1 bill_item_qual = i4
    1 bill_item[*]
      2 bill_item_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c20
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  )
  SET action_begin = 1
  SET action_end = request->bill_item_qual
 ENDIF
 SET reply->bill_item_qual = request->bill_item_qual
 SET stat = alterlist(reply->bill_item,request->bill_item_qual)
 SET reply->status_data.status = "F"
 SET failedme = false
 SET table_name = "BILL_ITEM"
 CALL add_bill_item(action_begin,action_end)
 IF (failedme != false)
  GO TO check_error
 ENDIF
#check_error
 IF (failedme=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CALL echo("Failure:  ",0)
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
  CALL echo(reply->status_data.subeventstatus[1])
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
 GO TO end_program
 SUBROUTINE add_bill_item(add_begin,add_end)
   FOR (x = add_begin TO add_end)
     SET new_nbr = 0.0
     SELECT INTO "nl:"
      y = seq(bill_item_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_nbr = cnvtreal(y)
      WITH format, nocounter
     ;end select
     IF (curqual=0)
      SET failedme = gen_nbr_error
      RETURN
     ENDIF
     SET active_code = 0.0
     IF ((request->bill_item[x].active_status_cd=0))
      SELECT INTO "nl:"
       FROM code_value c
       WHERE c.code_set=48
        AND c.cdf_meaning="ACTIVE"
       DETAIL
        active_code = c.code_value
       WITH nocounter
      ;end select
     ENDIF
     SET request->bill_item[x].bill_item_id = new_nbr
     SET reply->bill_item[x].bill_item_id = new_nbr
     CALL echo(build("the child_seq in the add script is: ",request->bill_item[x].child_seq))
     SET ncolumnexists = column_exists("BILL_ITEM","LATE_CHRG_EXCL_IND")
     IF (ncolumnexists != 1)
      INSERT  FROM bill_item b
       SET b.bill_item_id = new_nbr, b.ext_parent_reference_id = request->bill_item[x].
        ext_parent_reference_id, b.ext_parent_contributor_cd = request->bill_item[x].
        ext_parent_contributor_cd,
        b.ext_child_reference_id = request->bill_item[x].ext_child_reference_id, b
        .ext_child_contributor_cd = request->bill_item[x].ext_child_contributor_cd, b.ext_description
         = request->bill_item[x].ext_description,
        b.ext_short_desc =
        IF (trim(request->bill_item[x].ext_short_desc)="") substring(0,50,request->bill_item[x].
          ext_description)
        ELSE request->bill_item[x].ext_short_desc
        ENDIF
        , b.ext_owner_cd = request->bill_item[x].ext_owner_cd, b.ext_sub_owner_cd = validate(request
         ->bill_item[x].ext_sub_owner_cd,0.0),
        b.parent_qual_cd = request->bill_item[x].parent_qual_ind, b.charge_point_cd = request->
        bill_item[x].charge_point_cd, b.workload_only_ind = request->bill_item[x].workload_only_ind,
        b.beg_effective_dt_tm =
        IF ((request->bill_item[x].beg_effective_dt_tm <= 0)) cnvtdatetime(sysdate)
        ELSE cnvtdatetime(request->bill_item[x].beg_effective_dt_tm)
        ENDIF
        , b.end_effective_dt_tm =
        IF ((request->bill_item[x].end_effective_dt_tm <= 0)) cnvtdatetime("31-DEC-2100 00:00:00")
        ELSE cnvtdatetime(request->bill_item[x].end_effective_dt_tm)
        ENDIF
        , b.active_ind =
        IF ((request->bill_item[x].active_ind_ind=false)) true
        ELSE request->bill_item[x].active_ind
        ENDIF
        ,
        b.active_status_cd =
        IF ((request->bill_item[x].active_status_cd=0)) active_code
        ELSE request->bill_item[x].active_status_cd
        ENDIF
        , b.active_status_prsnl_id =
        IF ((request->bill_item[x].active_status_prsnl_id=0)) reqinfo->updt_id
        ELSE request->bill_item[x].active_status_prsnl_id
        ENDIF
        , b.active_status_dt_tm =
        IF ((request->bill_item[x].active_status_dt_tm <= 0)) cnvtdatetime(sysdate)
        ELSE cnvtdatetime(request->bill_item[x].active_status_dt_tm)
        ENDIF
        ,
        b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id,
        b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->updt_task, b
        .ext_parent_entity_name =
        IF ((request->bill_item[x].ext_parent_reference_id != 0)) "CODE_VALUE"
        ELSE ""
        ENDIF
        ,
        b.ext_child_entity_name =
        IF ((request->bill_item[x].ext_child_contributor_cd=taskcat)) "ORDER_TASK"
        ELSEIF ((request->bill_item[x].ext_child_reference_id != 0)) "CODE_VALUE"
        ELSE ""
        ENDIF
        , b.misc_ind = request->bill_item[x].misc_ind, b.stats_only_ind = request->bill_item[x].
        stats_only_ind,
        b.child_seq = request->bill_item[x].child_seq, b.logical_domain_id = validate(request->
         logical_domain_id,0.0), b.logical_domain_enabled_ind = validate(request->
         logical_domain_enabled_ind,0)
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET failedme = insert_error
       RETURN
      ENDIF
     ELSE
      INSERT  FROM bill_item b
       SET b.bill_item_id = new_nbr, b.ext_parent_reference_id = request->bill_item[x].
        ext_parent_reference_id, b.ext_parent_contributor_cd = request->bill_item[x].
        ext_parent_contributor_cd,
        b.ext_child_reference_id = request->bill_item[x].ext_child_reference_id, b
        .ext_child_contributor_cd = request->bill_item[x].ext_child_contributor_cd, b.ext_description
         = request->bill_item[x].ext_description,
        b.ext_short_desc =
        IF (trim(request->bill_item[x].ext_short_desc)="") substring(0,50,request->bill_item[x].
          ext_description)
        ELSE request->bill_item[x].ext_short_desc
        ENDIF
        , b.ext_owner_cd = request->bill_item[x].ext_owner_cd, b.ext_sub_owner_cd = validate(request
         ->bill_item[x].ext_sub_owner_cd,0.0),
        b.parent_qual_cd = request->bill_item[x].parent_qual_ind, b.charge_point_cd = request->
        bill_item[x].charge_point_cd, b.workload_only_ind = request->bill_item[x].workload_only_ind,
        b.beg_effective_dt_tm =
        IF ((request->bill_item[x].beg_effective_dt_tm <= 0)) cnvtdatetime(sysdate)
        ELSE cnvtdatetime(request->bill_item[x].beg_effective_dt_tm)
        ENDIF
        , b.end_effective_dt_tm =
        IF ((request->bill_item[x].end_effective_dt_tm <= 0)) cnvtdatetime("31-DEC-2100 00:00:00")
        ELSE cnvtdatetime(request->bill_item[x].end_effective_dt_tm)
        ENDIF
        , b.active_ind =
        IF ((request->bill_item[x].active_ind_ind=false)) true
        ELSE request->bill_item[x].active_ind
        ENDIF
        ,
        b.active_status_cd =
        IF ((request->bill_item[x].active_status_cd=0)) active_code
        ELSE request->bill_item[x].active_status_cd
        ENDIF
        , b.active_status_prsnl_id =
        IF ((request->bill_item[x].active_status_prsnl_id=0)) reqinfo->updt_id
        ELSE request->bill_item[x].active_status_prsnl_id
        ENDIF
        , b.active_status_dt_tm =
        IF ((request->bill_item[x].active_status_dt_tm <= 0)) cnvtdatetime(sysdate)
        ELSE cnvtdatetime(request->bill_item[x].active_status_dt_tm)
        ENDIF
        ,
        b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id,
        b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->updt_task, b
        .ext_parent_entity_name =
        IF ((request->bill_item[x].ext_parent_reference_id != 0)) "CODE_VALUE"
        ELSE ""
        ENDIF
        ,
        b.ext_child_entity_name =
        IF ((request->bill_item[x].ext_child_contributor_cd=taskcat)) "ORDER_TASK"
        ELSEIF ((request->bill_item[x].ext_child_reference_id != 0)) "CODE_VALUE"
        ELSE ""
        ENDIF
        , b.misc_ind = request->bill_item[x].misc_ind, b.stats_only_ind = request->bill_item[x].
        stats_only_ind,
        b.child_seq = request->bill_item[x].child_seq, b.late_chrg_excl_ind = request->bill_item[x].
        late_chrg_excl_ind, b.cost_basis_amt = 0,
        b.tax_ind = 0, b.logical_domain_id = validate(request->logical_domain_id,0.0), b
        .logical_domain_enabled_ind = validate(request->logical_domain_enabled_ind,0)
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET failedme = insert_error
       RETURN
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
