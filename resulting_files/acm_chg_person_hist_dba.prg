CREATE PROGRAM acm_chg_person_hist:dba
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
 FREE RECORD temp_record
 RECORD temp_record(
   1 person_hist_qual[*]
     2 person_flex_hist_id = f8
     2 person_id = f8
     2 pm_hist_tracking_id = f8
     2 transaction_dt_tm = dq8
     2 birth_dt_tm = dq8
     2 sex_cd = f8
     2 language_cd = f8
     2 race_cd = f8
     2 marital_type_cd = f8
     2 deceased_cd = f8
     2 deceased_dt_tm = dq8
     2 deceased_source_cd = f8
     2 cause_of_death = vc
     2 cause_of_death_cd = f8
     2 autopsy_cd = f8
     2 ethnic_grp_cd = f8
     2 birth_tz = i4
     2 change_bit = i4
     2 item_idx = i4
 )
 DECLARE chgbit = i4 WITH noconstant(0)
 DECLARE tracking_bit = i4 WITH noconstant(8191)
 DECLARE updt_cnt = i4 WITH noconstant(0)
 DECLARE index = i4 WITH protect, noconstant(0)
 FOR (index = 1 TO xref->chg_cnt)
   SET reply->person_qual[xref->chg[index].idx].status = 0
 ENDFOR
 SET stat = alterlist(temp_record->person_hist_qual,xref->chg_cnt)
 SET pfh_qual_cntr = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(xref->chg_cnt))
  PLAN (d)
  DETAIL
   item_idx = xref->chg[d.seq].idx, chg_str = acm_request->person_qual[item_idx].chg_str, chgbit = 0
   IF (findstring("BIRTH_DT_TM,",chg_str) != 0)
    chgbit = bor(1,chgbit)
   ENDIF
   IF (findstring("SEX_CD,",chg_str) != 0)
    chgbit = bor(2,chgbit)
   ENDIF
   IF (findstring("LANGUAGE_CD,",chg_str) != 0)
    chgbit = bor(4,chgbit)
   ENDIF
   IF (findstring("RACE_CD,",chg_str) != 0)
    chgbit = bor(8,chgbit)
   ENDIF
   IF (findstring("MARITAL_TYPE_CD,",chg_str) != 0)
    chgbit = bor(16,chgbit)
   ENDIF
   IF (findstring("DECEASED_CD,",chg_str) != 0)
    chgbit = bor(32,chgbit)
   ENDIF
   IF (findstring("DECEASED_DT_TM,",chg_str) != 0)
    chgbit = bor(64,chgbit)
   ENDIF
   IF (findstring("DECEASED_SOURCE_CD,",chg_str) != 0)
    chgbit = bor(128,chgbit)
   ENDIF
   IF (findstring("CAUSE_OF_DEATH,",chg_str) != 0)
    chgbit = bor(256,chgbit)
   ENDIF
   IF (findstring("CAUSE_OF_DEATH_CD,",chg_str) != 0)
    chgbit = bor(512,chgbit)
   ENDIF
   IF (findstring("AUTOPSY_CD,",chg_str) != 0)
    chgbit = bor(1024,chgbit)
   ENDIF
   IF (findstring("ETHNIC_GRP_CD,",chg_str) != 0)
    chgbit = bor(2048,chgbit)
   ENDIF
   IF (findstring("BIRTH_TZ,",chg_str) != 0)
    chgbit = bor(4096,chgbit)
   ENDIF
   IF (chgbit > 0)
    pfh_qual_cntr = (pfh_qual_cntr+ 1), temp_record->person_hist_qual[pfh_qual_cntr].change_bit =
    chgbit, temp_record->person_hist_qual[pfh_qual_cntr].item_idx = item_idx,
    temp_record->person_hist_qual[pfh_qual_cntr].person_id = acm_request->person_qual[item_idx].
    person_id, temp_record->person_hist_qual[pfh_qual_cntr].pm_hist_tracking_id = acm_request->
    person_qual[item_idx].pm_hist_tracking_id, temp_record->person_hist_qual[pfh_qual_cntr].
    transaction_dt_tm = acm_request->person_qual[item_idx].transaction_dt_tm,
    temp_record->person_hist_qual[pfh_qual_cntr].birth_dt_tm = acm_request->person_qual[item_idx].
    birth_dt_tm, temp_record->person_hist_qual[pfh_qual_cntr].sex_cd = acm_request->person_qual[
    item_idx].sex_cd, temp_record->person_hist_qual[pfh_qual_cntr].language_cd = acm_request->
    person_qual[item_idx].language_cd,
    temp_record->person_hist_qual[pfh_qual_cntr].race_cd = acm_request->person_qual[item_idx].race_cd,
    temp_record->person_hist_qual[pfh_qual_cntr].marital_type_cd = acm_request->person_qual[item_idx]
    .marital_type_cd, temp_record->person_hist_qual[pfh_qual_cntr].deceased_cd = acm_request->
    person_qual[item_idx].deceased_cd,
    temp_record->person_hist_qual[pfh_qual_cntr].deceased_dt_tm = acm_request->person_qual[item_idx].
    deceased_dt_tm, temp_record->person_hist_qual[pfh_qual_cntr].deceased_source_cd = acm_request->
    person_qual[item_idx].deceased_source_cd, temp_record->person_hist_qual[pfh_qual_cntr].
    cause_of_death = acm_request->person_qual[item_idx].cause_of_death,
    temp_record->person_hist_qual[pfh_qual_cntr].cause_of_death_cd = acm_request->person_qual[
    item_idx].cause_of_death_cd, temp_record->person_hist_qual[pfh_qual_cntr].autopsy_cd =
    acm_request->person_qual[item_idx].autopsy_cd, temp_record->person_hist_qual[pfh_qual_cntr].
    ethnic_grp_cd = acm_request->person_qual[item_idx].ethnic_grp_cd,
    temp_record->person_hist_qual[pfh_qual_cntr].birth_tz = acm_request->person_qual[item_idx].
    birth_tz
   ELSE
    reply->person_qual[item_idx].status = 1
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(temp_record->person_hist_qual,pfh_qual_cntr)
 IF (pfh_qual_cntr > 0)
  INSERT  FROM person_flex_hist pfh,
    (dummyt d  WITH seq = value(pfh_qual_cntr))
   SET pfh.person_flex_hist_id = seq(person_seq,nextval), pfh.person_id = temp_record->
    person_hist_qual[d.seq].person_id, pfh.pm_hist_tracking_id = temp_record->person_hist_qual[d.seq]
    .pm_hist_tracking_id,
    pfh.transaction_dt_tm = cnvtdatetime(temp_record->person_hist_qual[d.seq].transaction_dt_tm), pfh
    .birth_dt_tm = cnvtdatetime(temp_record->person_hist_qual[d.seq].birth_dt_tm), pfh.sex_cd =
    temp_record->person_hist_qual[d.seq].sex_cd,
    pfh.language_cd = temp_record->person_hist_qual[d.seq].language_cd, pfh.race_cd = temp_record->
    person_hist_qual[d.seq].race_cd, pfh.marital_type_cd = temp_record->person_hist_qual[d.seq].
    marital_type_cd,
    pfh.deceased_cd = temp_record->person_hist_qual[d.seq].deceased_cd, pfh.deceased_dt_tm =
    cnvtdatetime(temp_record->person_hist_qual[d.seq].deceased_dt_tm), pfh.deceased_source_cd =
    temp_record->person_hist_qual[d.seq].deceased_source_cd,
    pfh.cause_of_death = temp_record->person_hist_qual[d.seq].cause_of_death, pfh.cause_of_death_cd
     = temp_record->person_hist_qual[d.seq].cause_of_death_cd, pfh.autopsy_cd = temp_record->
    person_hist_qual[d.seq].autopsy_cd,
    pfh.ethnic_grp_cd = temp_record->person_hist_qual[d.seq].ethnic_grp_cd, pfh.birth_tz =
    temp_record->person_hist_qual[d.seq].birth_tz, pfh.tracking_bit = tracking_bit,
    pfh.change_bit = temp_record->person_hist_qual[d.seq].change_bit, pfh.active_ind = 1, pfh
    .active_status_cd = reqdata->active_status_cd,
    pfh.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pfh.active_status_prsnl_id = reqinfo->
    updt_id, pfh.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    pfh.updt_id = reqinfo->updt_id, pfh.updt_applctx = reqinfo->updt_applctx, pfh.updt_task = reqinfo
    ->updt_task,
    pfh.updt_cnt = updt_cnt
   PLAN (d)
    JOIN (pfh)
   WITH nocounter, status(reply->person_qual[temp_record->person_hist_qual[d.seq].item_idx].status)
  ;end insert
 ENDIF
 FOR (index = 1 TO xref->chg_cnt)
   IF ((reply->person_qual[xref->chg[index].idx].status=0))
    SET failed = insert_error
    SET table_name = "PERSON_FLEX_HIST"
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF (failed)
  SET reply->status_data.status = "F"
  IF (failed != true
   AND failed != false)
   IF ((validate(pm_subeventstatus_sub_,- (99))=- (99)))
    DECLARE pm_subeventstatus_sub_ = i2 WITH public, constant(1)
    DECLARE s_next_subeventstatus(s_null=i4) = i4
    DECLARE s_add_subeventstatus(s_oname=vc,s_ostatus=c1,s_tname=vc,s_tvalue=vc) = i4
    DECLARE s_add_subeventstatus_cclerr(s_null=i4) = i4
    DECLARE s_log_subeventstatus(s_null=i4) = i4
    DECLARE s_clear_subeventstatus(s_null=i4) = i4
    SUBROUTINE s_next_subeventstatus(s_null)
      DECLARE s_stat = i4 WITH private, noconstant(0)
      DECLARE stx1 = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5))
      IF ((((reply->status_data.subeventstatus[stx1].operationname > " ")) OR ((((reply->status_data.
      subeventstatus[stx1].operationstatus > " ")) OR ((((reply->status_data.subeventstatus[stx1].
      targetobjectname > " ")) OR ((reply->status_data.subeventstatus[stx1].targetobjectvalue > " ")
      )) )) )) )
       SET stx1 = (stx1+ 1)
       SET s_stat = alter(reply->status_data.subeventstatus,stx1)
      ENDIF
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE s_add_subeventstatus(s_oname,s_ostatus,s_tname,s_tvalue)
      DECLARE stx1 = i4 WITH private, noconstant(s_next_subeventstatus(1))
      SET reply->status_data.subeventstatus[stx1].operationname = s_oname
      SET reply->status_data.subeventstatus[stx1].operationstatus = s_ostatus
      SET reply->status_data.subeventstatus[stx1].targetobjectname = s_tname
      SET reply->status_data.subeventstatus[stx1].targetobjectvalue = s_tvalue
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE s_add_subeventstatus_cclerr(s_null)
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
    SUBROUTINE s_log_subeventstatus(s_null)
      DECLARE wi = i4 WITH protect, noconstant(0)
      DECLARE s_curprog = vc WITH protect, constant(curprog)
      FOR (wi = 1 TO size(reply->status_data.subeventstatus,5))
        CALL s_sch_msgview(s_curprog,nullterm(build(reply->status_data.subeventstatus[wi].
           operationname,",",reply->status_data.subeventstatus[wi].operationstatus,",",reply->
           status_data.subeventstatus[wi].targetobjectname,
           ",",reply->status_data.subeventstatus[wi].targetobjectvalue)),0)
      ENDFOR
    END ;Subroutine
    SUBROUTINE s_clear_subeventstatus(s_null)
      SET stat = alter(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].operationname = ""
      SET reply->status_data.subeventstatus[1].operationstatus = ""
      SET reply->status_data.subeventstatus[1].targetobjectname = ""
      SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
    END ;Subroutine
    DECLARE s_sch_msgview(t_event=vc,t_message=vc,t_log_level=i4) = i2
    SUBROUTINE s_sch_msgview(t_event,t_message,t_log_level)
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
