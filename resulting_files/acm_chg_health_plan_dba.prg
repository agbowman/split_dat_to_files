CREATE PROGRAM acm_chg_health_plan:dba
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  DECLARE false = i2 WITH public, constant(0)
 ENDIF
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  DECLARE true = i2 WITH public, constant(1)
 ENDIF
 IF (validate(gen_nbr_error,0)=0
  AND validate(gen_nbr_error,1)=1)
  DECLARE gen_nbr_error = i2 WITH public, constant(3)
 ENDIF
 IF (validate(insert_error,0)=0
  AND validate(insert_error,1)=1)
  DECLARE insert_error = i2 WITH public, constant(4)
 ENDIF
 IF (validate(update_error,0)=0
  AND validate(update_error,1)=1)
  DECLARE update_error = i2 WITH public, constant(5)
 ENDIF
 IF (validate(replace_error,0)=0
  AND validate(replace_error,1)=1)
  DECLARE replace_error = i2 WITH public, constant(6)
 ENDIF
 IF (validate(delete_error,0)=0
  AND validate(delete_error,1)=1)
  DECLARE delete_error = i2 WITH public, constant(7)
 ENDIF
 IF (validate(undelete_error,0)=0
  AND validate(undelete_error,1)=1)
  DECLARE undelete_error = i2 WITH public, constant(8)
 ENDIF
 IF (validate(remove_error,0)=0
  AND validate(remove_error,1)=1)
  DECLARE remove_error = i2 WITH public, constant(9)
 ENDIF
 IF (validate(attribute_error,0)=0
  AND validate(attribute_error,1)=1)
  DECLARE attribute_error = i2 WITH public, constant(10)
 ENDIF
 IF (validate(lock_error,0)=0
  AND validate(lock_error,1)=1)
  DECLARE lock_error = i2 WITH public, constant(11)
 ENDIF
 IF (validate(none_found,0)=0
  AND validate(none_found,1)=1)
  DECLARE none_found = i2 WITH public, constant(12)
 ENDIF
 IF (validate(select_error,0)=0
  AND validate(select_error,1)=1)
  DECLARE select_error = i2 WITH public, constant(13)
 ENDIF
 IF (validate(update_cnt_error,0)=0
  AND validate(update_cnt_error,1)=1)
  DECLARE update_cnt_error = i2 WITH public, constant(14)
 ENDIF
 IF (validate(not_found,0)=0
  AND validate(not_found,1)=1)
  DECLARE not_found = i2 WITH public, constant(15)
 ENDIF
 IF (validate(inactivate_error,0)=0
  AND validate(inactivate_error,1)=1)
  DECLARE inactivate_error = i2 WITH public, constant(17)
 ENDIF
 IF (validate(activate_error,0)=0
  AND validate(activate_error,1)=1)
  DECLARE activate_error = i2 WITH public, constant(18)
 ENDIF
 IF (validate(uar_error,0)=0
  AND validate(uar_error,1)=1)
  DECLARE uar_error = i2 WITH public, constant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 DECLARE failed = i2 WITH protect, noconstant(false)
 DECLARE table_name = vc WITH protect, noconstant(" ")
 DECLARE call_echo_ind = i2 WITH protect, noconstant(0)
 DECLARE pmhc_contributory_system_cd = f8 WITH protect, noconstant(0.0)
 DECLARE t1 = i4 WITH noconstant(0), protect
 DECLARE t2 = i4 WITH noconstant(0), protect
 DECLARE max_val = i4 WITH noconstant(200), protect
 DECLARE t_val = i4 WITH noconstant(xref->chg_cnt), protect
 DECLARE f_val = i4 WITH noconstant(1), protect
 DECLARE idx = i4 WITH noconstant(0), protect
 DECLARE chg_cnt = i4 WITH noconstant(xref->chg_cnt), protect
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE active_status_prsnl_id = f8 WITH protect, noconstant(0.0)
 DECLARE active_status_dt_tm = f8 WITH protect, noconstant(0.0)
 FOR (index = 1 TO xref->chg_cnt)
   SET reply->health_plan_qual[xref->chg[index].idx].status = 0
 ENDFOR
 IF (t_val <= max_val)
  SET max_val = t_val
  CALL getexistingrows(max_val)
 ELSE
  SET t_val = max_val
  WHILE (chg_cnt > 0)
    CALL getexistingrows(max_val)
    SET chg_cnt -= max_val
    SET f_val = (t_val+ 1)
    IF (chg_cnt > max_val)
     SET t_val += max_val
    ELSE
     SET t_val += chg_cnt
    ENDIF
  ENDWHILE
 ENDIF
 UPDATE  FROM (dummyt d  WITH seq = value(xref->chg_cnt)),
   health_plan h
  SET h.health_plan_id = acm_request->health_plan_qual[xref->chg[d.seq].idx].health_plan_id, h
   .baby_coverage_cd = acm_request->health_plan_qual[xref->chg[d.seq].idx].baby_coverage_cd, h
   .beg_effective_dt_tm = cnvtdatetime(acm_request->health_plan_qual[xref->chg[d.seq].idx].
    beg_effective_dt_tm),
   h.comb_baby_bill_cd = acm_request->health_plan_qual[xref->chg[d.seq].idx].comb_baby_bill_cd, h
   .end_effective_dt_tm = cnvtdatetime(acm_request->health_plan_qual[xref->chg[d.seq].idx].
    end_effective_dt_tm), h.financial_class_cd = acm_request->health_plan_qual[xref->chg[d.seq].idx].
   financial_class_cd,
   h.ft_entity_id = acm_request->health_plan_qual[xref->chg[d.seq].idx].ft_entity_id, h
   .ft_entity_name = acm_request->health_plan_qual[xref->chg[d.seq].idx].ft_entity_name, h.group_name
    = acm_request->health_plan_qual[xref->chg[d.seq].idx].group_name,
   h.group_nbr = acm_request->health_plan_qual[xref->chg[d.seq].idx].group_nbr, h.pat_bill_pref_flag
    = acm_request->health_plan_qual[xref->chg[d.seq].idx].pat_bill_pref_flag, h.plan_class_cd =
   acm_request->health_plan_qual[xref->chg[d.seq].idx].plan_class_cd,
   h.plan_desc = acm_request->health_plan_qual[xref->chg[d.seq].idx].plan_desc, h.plan_name =
   acm_request->health_plan_qual[xref->chg[d.seq].idx].plan_name, h.plan_type_cd = acm_request->
   health_plan_qual[xref->chg[d.seq].idx].plan_type_cd,
   h.policy_nbr = acm_request->health_plan_qual[xref->chg[d.seq].idx].policy_nbr, h
   .pri_concurrent_ind = acm_request->health_plan_qual[xref->chg[d.seq].idx].pri_concurrent_ind, h
   .product_cd = acm_request->health_plan_qual[xref->chg[d.seq].idx].product_cd,
   h.sec_concurrent_ind = acm_request->health_plan_qual[xref->chg[d.seq].idx].sec_concurrent_ind, h
   .active_ind = acm_request->health_plan_qual[xref->chg[d.seq].idx].active_ind, h.active_status_cd
    = acm_request->health_plan_qual[xref->chg[d.seq].idx].active_status_cd,
   h.active_status_prsnl_id = active_status_prsnl_id, h.active_status_dt_tm = cnvtdatetime(
    active_status_dt_tm), h.updt_cnt = (h.updt_cnt+ 1),
   h.updt_dt_tm = cnvtdatetime(sysdate), h.updt_id = reqinfo->updt_id, h.updt_applctx = reqinfo->
   updt_applctx,
   h.updt_task = reqinfo->updt_task
  PLAN (d)
   JOIN (h
   WHERE (h.health_plan_id=acm_request->health_plan_qual[xref->chg[d.seq].idx].health_plan_id))
  WITH nocounter, status(reply->health_plan_qual[xref->chg[d.seq].idx].status)
 ;end update
 FOR (index = 1 TO xref->chg_cnt)
   IF ((reply->health_plan_qual[xref->chg[index].idx].status != 1))
    SET failed = update_error
    SET table_name = "HEALTH_PLAN"
    GO TO exit_script
   ENDIF
 ENDFOR
 SUBROUTINE getexistingrows(x)
   SELECT INTO "nl:"
    FROM health_plan h
    WHERE expand(t1,f_val,t_val,h.health_plan_id,acm_request->health_plan_qual[xref->chg[t1].idx].
     health_plan_id,
     max_val)
    DETAIL
     t2 = locateval(t1,f_val,t_val,h.health_plan_id,acm_request->health_plan_qual[xref->chg[t1].idx].
      health_plan_id,
      max_val), idx = xref->chg[t2].idx
     IF ((((h.updt_cnt=acm_request->health_plan_qual[idx].updt_cnt)) OR ((acm_request->force_updt_ind
     =1))) )
      reply->health_plan_qual[idx].status = - (1), reply->health_plan_qual[idx].health_plan_id =
      acm_request->health_plan_qual[idx].health_plan_id
     ELSE
      failed = update_cnt_error
     ENDIF
     chg_str = acm_request->health_plan_qual[idx].chg_str
     IF (findstring("BABY_COVERAGE_CD,",chg_str)=0)
      acm_request->health_plan_qual[idx].baby_coverage_cd = h.baby_coverage_cd
     ENDIF
     IF (findstring("BEG_EFFECTIVE_DT_TM,",chg_str)=0)
      acm_request->health_plan_qual[idx].beg_effective_dt_tm = h.beg_effective_dt_tm
     ENDIF
     IF (findstring("COMB_BABY_BILL_CD,",chg_str)=0)
      acm_request->health_plan_qual[idx].comb_baby_bill_cd = h.comb_baby_bill_cd
     ENDIF
     IF (findstring("END_EFFECTIVE_DT_TM,",chg_str)=0)
      acm_request->health_plan_qual[idx].end_effective_dt_tm = h.end_effective_dt_tm
     ENDIF
     IF (findstring("FINANCIAL_CLASS_CD,",chg_str)=0)
      acm_request->health_plan_qual[idx].financial_class_cd = h.financial_class_cd
     ENDIF
     IF (findstring("FT_ENTITY_ID,",chg_str)=0)
      acm_request->health_plan_qual[idx].ft_entity_id = h.ft_entity_id
     ENDIF
     IF (findstring("FT_ENTITY_NAME,",chg_str)=0)
      acm_request->health_plan_qual[idx].ft_entity_name = h.ft_entity_name
     ENDIF
     IF (findstring("GROUP_NAME,",chg_str)=0)
      acm_request->health_plan_qual[idx].group_name = h.group_name
     ENDIF
     IF (findstring("GROUP_NBR,",chg_str)=0)
      acm_request->health_plan_qual[idx].group_nbr = h.group_nbr
     ENDIF
     IF (findstring("PAT_BILL_PREF_FLAG,",chg_str)=0)
      acm_request->health_plan_qual[idx].pat_bill_pref_flag = h.pat_bill_pref_flag
     ENDIF
     IF (findstring("PLAN_CLASS_CD,",chg_str)=0)
      acm_request->health_plan_qual[idx].plan_class_cd = h.plan_class_cd
     ENDIF
     IF (findstring("PLAN_DESC,",chg_str)=0)
      acm_request->health_plan_qual[idx].plan_desc = h.plan_desc
     ENDIF
     IF (findstring("PLAN_NAME,",chg_str)=0)
      acm_request->health_plan_qual[idx].plan_name = h.plan_name
     ENDIF
     IF (findstring("PLAN_TYPE_CD,",chg_str)=0)
      acm_request->health_plan_qual[idx].plan_type_cd = h.plan_type_cd
     ENDIF
     IF (findstring("POLICY_NBR,",chg_str)=0)
      acm_request->health_plan_qual[idx].policy_nbr = h.policy_nbr
     ENDIF
     IF (findstring("PRI_CONCURRENT_IND,",chg_str)=0)
      acm_request->health_plan_qual[idx].pri_concurrent_ind = h.pri_concurrent_ind
     ENDIF
     IF (findstring("PRODUCT_CD,",chg_str)=0)
      acm_request->health_plan_qual[idx].product_cd = h.product_cd
     ENDIF
     IF (findstring("SEC_CONCURRENT_IND,",chg_str)=0)
      acm_request->health_plan_qual[idx].sec_concurrent_ind = h.sec_concurrent_ind
     ENDIF
     IF (findstring("ACTIVE_IND,",chg_str)=0)
      acm_request->health_plan_qual[idx].active_ind = h.active_ind
     ENDIF
     IF (findstring("ACTIVE_STATUS_CD,",chg_str)=0)
      acm_request->health_plan_qual[idx].active_status_cd = h.active_status_cd
     ENDIF
     IF (((findstring("ACTIVE_IND,",chg_str) != 0) OR (findstring("ACTIVE_STATUS_CD,",chg_str) != 0
     )) )
      active_status_prsnl_id = reqinfo->updt_id, active_status_dt_tm = cnvtdatetime(sysdate)
     ELSE
      active_status_prsnl_id = h.active_status_prsnl_id, active_status_dt_tm = cnvtdatetime(h
       .active_status_dt_tm)
     ENDIF
    WITH nocounter, forupdatewait(h), time = 5
   ;end select
   IF (failed)
    SET table_name = "HEALTH_PLAN"
    GO TO exit_script
   ENDIF
   FOR (index = f_val TO t_val)
     IF ((reply->health_plan_qual[xref->chg[index].idx].status=0))
      SET failed = select_error
      SET table_name = "HEALTH_PLAN"
      GO TO exit_script
     ENDIF
   ENDFOR
 END ;Subroutine
#exit_script
 IF (failed)
  SET reply->status_data.status = "F"
  IF (failed != true
   AND failed != false)
   IF ((validate(pm_subeventstatus_sub_,- (99))=- (99)))
    DECLARE pm_subeventstatus_sub_ = i2 WITH public, constant(1)
    SUBROUTINE (s_next_subeventstatus(s_null=i4) =i4)
      DECLARE s_stat = i4 WITH private, noconstant(0)
      DECLARE stx1 = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5))
      IF ((((reply->status_data.subeventstatus[stx1].operationname > " ")) OR ((((reply->status_data.
      subeventstatus[stx1].operationstatus > " ")) OR ((((reply->status_data.subeventstatus[stx1].
      targetobjectname > " ")) OR ((reply->status_data.subeventstatus[stx1].targetobjectvalue > " ")
      )) )) )) )
       SET stx1 += 1
       SET s_stat = alter(reply->status_data.subeventstatus,stx1)
      ENDIF
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE (s_add_subeventstatus(s_oname=vc,s_ostatus=c1,s_tname=vc,s_tvalue=vc) =i4)
      DECLARE stx1 = i4 WITH private, noconstant(s_next_subeventstatus(1))
      SET reply->status_data.subeventstatus[stx1].operationname = s_oname
      SET reply->status_data.subeventstatus[stx1].operationstatus = s_ostatus
      SET reply->status_data.subeventstatus[stx1].targetobjectname = s_tname
      SET reply->status_data.subeventstatus[stx1].targetobjectvalue = s_tvalue
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE (s_add_subeventstatus_cclerr(s_null=i4) =i4)
      DECLARE serrmsg = vc WITH private, noconstant("")
      DECLARE ierrcode = i4 WITH private, noconstant(1)
      WHILE (ierrcode)
       SET ierrcode = error(serrmsg,0)
       IF (ierrcode)
        CALL s_add_subeventstatus("CCLERR","F",trim(curprog),serrmsg)
       ENDIF
      ENDWHILE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE (s_log_subeventstatus(s_null=i4) =i4)
      DECLARE wi = i4 WITH protect, noconstant(0)
      DECLARE s_curprog = vc WITH protect, constant(curprog)
      FOR (wi = 1 TO size(reply->status_data.subeventstatus,5))
        CALL s_sch_msgview(s_curprog,nullterm(build(reply->status_data.subeventstatus[wi].
           operationname,",",reply->status_data.subeventstatus[wi].operationstatus,",",reply->
           status_data.subeventstatus[wi].targetobjectname,
           ",",reply->status_data.subeventstatus[wi].targetobjectvalue)),0)
      ENDFOR
    END ;Subroutine
    SUBROUTINE (s_clear_subeventstatus(s_null=i4) =i4)
      SET stat = alter(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].operationname = ""
      SET reply->status_data.subeventstatus[1].operationstatus = ""
      SET reply->status_data.subeventstatus[1].targetobjectname = ""
      SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
    END ;Subroutine
    SUBROUTINE (s_sch_msgview(t_event=vc,t_message=vc,t_log_level=i4) =i2)
     IF (t_event > " "
      AND t_log_level BETWEEN 0 AND 4
      AND t_message > " ")
      DECLARE hlog = i4 WITH protect, noconstant(0)
      DECLARE hstat = i4 WITH protect, noconstant(0)
      CALL uar_syscreatehandle(hlog,hstat)
      IF (hlog != 0)
       CALL uar_sysevent(hlog,t_log_level,nullterm(t_event),nullterm(t_message))
       CALL uar_sysdestroyhandle(hlog)
      ENDIF
     ENDIF
     RETURN(1)
    END ;Subroutine
   ENDIF
   CASE (failed)
    OF lock_error:
     CALL s_add_subeventstatus("LOCK","F",trim(curprog),table_name)
    OF select_error:
     CALL s_add_subeventstatus("SELECT","F",trim(curprog),table_name)
    OF update_error:
     CALL s_add_subeventstatus("UPDATE","F",trim(curprog),table_name)
    OF insert_error:
     CALL s_add_subeventstatus("INSERT","F",trim(curprog),table_name)
    OF gen_nbr_error:
     CALL s_add_subeventstatus("GEN_NBR","F",trim(curprog),table_name)
    OF replace_error:
     CALL s_add_subeventstatus("REPLACE","F",trim(curprog),table_name)
    OF delete_error:
     CALL s_add_subeventstatus("DELETE","F",trim(curprog),table_name)
    OF undelete_error:
     CALL s_add_subeventstatus("UNDELETE","F",trim(curprog),table_name)
    OF remove_error:
     CALL s_add_subeventstatus("REMOVE","F",trim(curprog),table_name)
    OF attribute_error:
     CALL s_add_subeventstatus("ATTRIBUTE","F",trim(curprog),table_name)
    OF none_found:
     CALL s_add_subeventstatus("NONE_FOUND","F",trim(curprog),table_name)
    OF update_cnt_error:
     CALL s_add_subeventstatus("UPDATE_CNT","F",trim(curprog),table_name)
    OF not_found:
     CALL s_add_subeventstatus("NOT_FOUND","F",trim(curprog),table_name)
    OF inactivate_error:
     CALL s_add_subeventstatus("INACTIVATE","F",trim(curprog),table_name)
    OF activate_error:
     CALL s_add_subeventstatus("ACTIVATE","F",trim(curprog),table_name)
    OF uar_error:
     CALL s_add_subeventstatus("UAR_ERROR","F",trim(curprog),table_name)
    OF execute_error:
     CALL s_add_subeventstatus("EXECUTE","F",trim(curprog),table_name)
    OF duplicate_error:
     CALL s_add_subeventstatus("DUPLICATE","F",trim(curprog),table_name)
    OF ccl_error:
     CALL s_add_subeventstatus("CCLERROR","F",trim(curprog),table_name)
    ELSE
     CALL s_add_subeventstatus("UNKNOWN","F",trim(curprog),table_name)
   ENDCASE
   SET reqinfo->commit_ind = false
   CALL s_add_subeventstatus_cclerr(1)
   CALL s_log_subeventstatus(1)
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
