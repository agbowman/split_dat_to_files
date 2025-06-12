CREATE PROGRAM afc_upt_b_o_p
 SET reply->status_data.status = "F"
 SET table_name = "BILL_ORG_PAYOR"
 CALL upt_bill_org_payor(action_begin,action_end)
 IF (failed != false)
  GO TO check_error
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
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
 SUBROUTINE upt_bill_org_payor(upt_begin,upt_end)
   FOR (x = upt_begin TO upt_end)
     SET cur_updt_cnt[value(upt_end)] = 0
     SET count1 = 0
     SELECT INTO "nl:"
      b.*
      FROM bill_org_payor b,
       (dummyt d  WITH seq = value(upt_end))
      PLAN (d)
       JOIN (b
       WHERE (b.org_payor_id=request->bill_org_payor[d.seq].org_payor_id))
      HEAD REPORT
       count1 = 0
      DETAIL
       count1 += 1, cur_updt_cnt[count1] = b.updt_cnt
      WITH forupdate(b)
     ;end select
     IF (count1 != upt_end)
      SET failed = lock_error
      RETURN
     ENDIF
     UPDATE  FROM bill_org_payor b,
       (dummyt d  WITH seq = 1)
      SET b.seq = 1, b.organization_id = nullcheck(b.organization_id,request->bill_org_payor[x].
        organization_id,
        IF ((request->bill_org_payor[x].organization_id=0)) 0
        ELSE 1
        ENDIF
        ), b.bill_org_type_cd = request->bill_org_payor[x].bill_org_type_cd,
       b.bill_org_type_id = request->bill_org_payor[x].bill_org_type_id, b.bill_org_type_ind =
       request->bill_org_payor[x].bill_org_type_ind, b.bill_org_type_string = request->
       bill_org_payor[x].bill_org_type_string,
       b.interface_file_cd = nullcheck(b.interface_file_cd,request->bill_org_payor[x].
        interface_file_cd,
        IF ((request->bill_org_payor[x].interface_file_cd=0)) 0
        ELSE 1
        ENDIF
        ), b.priority = nullcheck(b.priority,request->bill_org_payor[x].priority,
        IF ((request->bill_org_payor[x].priority=0)) 0
        ELSE 1
        ENDIF
        ), b.beg_effective_dt_tm = nullcheck(b.beg_effective_dt_tm,cnvtdatetime(request->
         bill_org_payor[x].beg_effective_dt_tm),
        IF ((request->bill_org_payor[x].beg_effective_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ),
       b.end_effective_dt_tm = nullcheck(b.end_effective_dt_tm,cnvtdatetime(request->bill_org_payor[x
         ].end_effective_dt_tm),
        IF ((request->bill_org_payor[x].end_effective_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ), b.active_status_cd = nullcheck(b.active_status_cd,request->bill_org_payor[x].
        active_status_cd,
        IF ((request->bill_org_payor[x].active_status_cd=0)) 0
        ELSE 1
        ENDIF
        ), b.active_status_prsnl_id = nullcheck(b.active_status_prsnl_id,request->bill_org_payor[x].
        active_status_prsnl_id,
        IF ((request->bill_org_payor[x].active_status_prsnl_id=0)) 0
        ELSE 1
        ENDIF
        ),
       b.active_status_dt_tm = nullcheck(b.active_status_dt_tm,cnvtdatetime(request->bill_org_payor[x
         ].active_status_dt_tm),
        IF ((request->bill_org_payor[x].active_status_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ), b.updt_cnt = (cur_updt_cnt[d.seq]+ 1), b.updt_dt_tm = cnvtdatetime(sysdate),
       b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->
       updt_task,
       b.parent_entity_name =
       IF ((request->bill_org_payor[x].bill_org_type_cd=wl_standard_cd)) "WORKLOAD_STANDARD"
       ELSEIF ( $1) "CODE_VALUE"
       ELSE " "
       ENDIF
      PLAN (d)
       JOIN (b
       WHERE (b.org_payor_id=request->bill_org_payor[x].org_payor_id))
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = update_error
      RETURN
     ELSE
      SET reply->bill_org_payor[x].org_payor_id = request->bill_org_payor[x].org_payor_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
 FREE SET parent_entity
 FREE SET tiergroup_cv
END GO
