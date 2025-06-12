CREATE PROGRAM acm_chg_address_hist:dba
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
   1 address_hist_qual[*]
     2 address_hist_id = f8
     2 address_id = f8
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 pm_hist_tracking_id = f8
     2 transaction_dt_tm = dq8
     2 address_type_cd = f8
     2 street_addr = vc
     2 street_addr2 = vc
     2 street_addr3 = vc
     2 street_addr4 = vc
     2 city = vc
     2 state = vc
     2 state_cd = f8
     2 zipcode = vc
     2 county = vc
     2 county_cd = f8
     2 country = vc
     2 country_cd = f8
     2 address_info_status_cd = f8
     2 residence_cd = f8
     2 residence_type_cd = f8
     2 mail_stop = vc
     2 contact_name = vc
     2 operation_hours = vc
     2 comment_txt = vc
     2 postal_identifier = vc
     2 parent_beg_effective_dt_tm = dq8
     2 parent_end_effective_dt_tm = dq8
     2 change_bit = i4
     2 item_idx = i4
 )
 DECLARE chgbit = i4 WITH noconstant(0)
 DECLARE tracking_bit = i4 WITH noconstant(8388607)
 DECLARE updt_cnt = i4 WITH noconstant(0)
 DECLARE index = i4 WITH protect, noconstant(0)
 FOR (index = 1 TO xref->chg_cnt)
   SET reply->address_qual[xref->chg[index].idx].status = 0
 ENDFOR
 SET stat = alterlist(temp_record->address_hist_qual,xref->chg_cnt)
 SET ah_qual_cntr = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(xref->chg_cnt))
  PLAN (d)
  DETAIL
   item_idx = xref->chg[d.seq].idx, chg_str = acm_request->address_qual[item_idx].chg_str, chgbit = 0
   IF (findstring("ADDRESS_TYPE_CD,",chg_str) != 0)
    chgbit = bor(1,chgbit)
   ENDIF
   IF (findstring("STREET_ADDR,",chg_str) != 0)
    chgbit = bor(2,chgbit)
   ENDIF
   IF (findstring("STREET_ADDR2,",chg_str) != 0)
    chgbit = bor(4,chgbit)
   ENDIF
   IF (findstring("STREET_ADDR3,",chg_str) != 0)
    chgbit = bor(8,chgbit)
   ENDIF
   IF (findstring("STREET_ADDR4,",chg_str) != 0)
    chgbit = bor(16,chgbit)
   ENDIF
   IF (findstring("CITY,",chg_str) != 0)
    chgbit = bor(32,chgbit)
   ENDIF
   IF (findstring("STATE,",chg_str) != 0)
    chgbit = bor(64,chgbit)
   ENDIF
   IF (findstring("STATE_CD,",chg_str) != 0)
    chgbit = bor(128,chgbit)
   ENDIF
   IF (findstring("ZIPCODE,",chg_str) != 0)
    chgbit = bor(256,chgbit)
   ENDIF
   IF (findstring("COUNTY,",chg_str) != 0)
    chgbit = bor(512,chgbit)
   ENDIF
   IF (findstring("COUNTY_CD,",chg_str) != 0)
    chgbit = bor(1024,chgbit)
   ENDIF
   IF (findstring("COUNTRY,",chg_str) != 0)
    chgbit = bor(2048,chgbit)
   ENDIF
   IF (findstring("COUNTRY_CD,",chg_str) != 0)
    chgbit = bor(4096,chgbit)
   ENDIF
   IF (findstring("ADDRESS_INFO_STATUS_CD,",chg_str) != 0)
    chgbit = bor(8192,chgbit)
   ENDIF
   IF (findstring("RESIDENCE_CD,",chg_str) != 0)
    chgbit = bor(16384,chgbit)
   ENDIF
   IF (findstring("RESIDENCE_TYPE_CD,",chg_str) != 0)
    chgbit = bor(32768,chgbit)
   ENDIF
   IF (findstring("MAIL_STOP,",chg_str) != 0)
    chgbit = bor(65536,chgbit)
   ENDIF
   IF (findstring("CONTACT_NAME,",chg_str) != 0)
    chgbit = bor(131072,chgbit)
   ENDIF
   IF (findstring("OPERATION_HOURS,",chg_str) != 0)
    chgbit = bor(262144,chgbit)
   ENDIF
   IF (findstring("COMMENT_TXT,",chg_str) != 0)
    chgbit = bor(524288,chgbit)
   ENDIF
   IF (findstring("POSTAL_IDENTIFIER,",chg_str) != 0)
    chgbit = bor(1048576,chgbit)
   ENDIF
   IF (findstring("BEG_EFFECTIVE_DT_TM,",chg_str) != 0)
    chgbit = bor(2097152,chgbit)
   ENDIF
   IF (findstring("END_EFFECTIVE_DT_TM,",chg_str) != 0)
    chgbit = bor(4194304,chgbit)
   ENDIF
   IF (chgbit > 0)
    ah_qual_cntr = (ah_qual_cntr+ 1), temp_record->address_hist_qual[ah_qual_cntr].change_bit =
    chgbit, temp_record->address_hist_qual[ah_qual_cntr].item_idx = item_idx,
    temp_record->address_hist_qual[ah_qual_cntr].address_id = acm_request->address_qual[item_idx].
    address_id, temp_record->address_hist_qual[ah_qual_cntr].parent_entity_id = acm_request->
    address_qual[item_idx].parent_entity_id, temp_record->address_hist_qual[ah_qual_cntr].
    parent_entity_name = acm_request->address_qual[item_idx].parent_entity_name,
    temp_record->address_hist_qual[ah_qual_cntr].pm_hist_tracking_id = acm_request->address_qual[
    item_idx].pm_hist_tracking_id, temp_record->address_hist_qual[ah_qual_cntr].transaction_dt_tm =
    acm_request->address_qual[item_idx].transaction_dt_tm, temp_record->address_hist_qual[
    ah_qual_cntr].address_type_cd = acm_request->address_qual[item_idx].address_type_cd,
    temp_record->address_hist_qual[ah_qual_cntr].street_addr = acm_request->address_qual[item_idx].
    street_addr, temp_record->address_hist_qual[ah_qual_cntr].street_addr2 = acm_request->
    address_qual[item_idx].street_addr2, temp_record->address_hist_qual[ah_qual_cntr].street_addr3 =
    acm_request->address_qual[item_idx].street_addr3,
    temp_record->address_hist_qual[ah_qual_cntr].street_addr4 = acm_request->address_qual[item_idx].
    street_addr4, temp_record->address_hist_qual[ah_qual_cntr].city = acm_request->address_qual[
    item_idx].city, temp_record->address_hist_qual[ah_qual_cntr].state = acm_request->address_qual[
    item_idx].state,
    temp_record->address_hist_qual[ah_qual_cntr].state_cd = acm_request->address_qual[item_idx].
    state_cd, temp_record->address_hist_qual[ah_qual_cntr].zipcode = acm_request->address_qual[
    item_idx].zipcode, temp_record->address_hist_qual[ah_qual_cntr].county = acm_request->
    address_qual[item_idx].county,
    temp_record->address_hist_qual[ah_qual_cntr].county_cd = acm_request->address_qual[item_idx].
    county_cd, temp_record->address_hist_qual[ah_qual_cntr].country = acm_request->address_qual[
    item_idx].country, temp_record->address_hist_qual[ah_qual_cntr].country_cd = acm_request->
    address_qual[item_idx].country_cd,
    temp_record->address_hist_qual[ah_qual_cntr].address_info_status_cd = acm_request->address_qual[
    item_idx].address_info_status_cd, temp_record->address_hist_qual[ah_qual_cntr].residence_cd =
    acm_request->address_qual[item_idx].residence_cd, temp_record->address_hist_qual[ah_qual_cntr].
    residence_type_cd = acm_request->address_qual[item_idx].residence_type_cd,
    temp_record->address_hist_qual[ah_qual_cntr].mail_stop = acm_request->address_qual[item_idx].
    mail_stop, temp_record->address_hist_qual[ah_qual_cntr].contact_name = acm_request->address_qual[
    item_idx].contact_name, temp_record->address_hist_qual[ah_qual_cntr].operation_hours =
    acm_request->address_qual[item_idx].operation_hours,
    temp_record->address_hist_qual[ah_qual_cntr].comment_txt = acm_request->address_qual[item_idx].
    comment_txt, temp_record->address_hist_qual[ah_qual_cntr].postal_identifier = acm_request->
    address_qual[item_idx].postal_identifier, temp_record->address_hist_qual[ah_qual_cntr].
    parent_beg_effective_dt_tm = acm_request->address_qual[item_idx].beg_effective_dt_tm,
    temp_record->address_hist_qual[ah_qual_cntr].parent_end_effective_dt_tm = acm_request->
    address_qual[item_idx].end_effective_dt_tm
   ELSE
    reply->address_qual[item_idx].status = 1
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(temp_record->address_hist_qual,ah_qual_cntr)
 IF (ah_qual_cntr > 0)
  INSERT  FROM address_hist ah,
    (dummyt d  WITH seq = value(ah_qual_cntr))
   SET ah.address_hist_id = seq(address_seq,nextval), ah.address_id = temp_record->address_hist_qual[
    d.seq].address_id, ah.parent_entity_id = temp_record->address_hist_qual[d.seq].parent_entity_id,
    ah.parent_entity_name = temp_record->address_hist_qual[d.seq].parent_entity_name, ah
    .pm_hist_tracking_id = temp_record->address_hist_qual[d.seq].pm_hist_tracking_id, ah
    .transaction_dt_tm = cnvtdatetime(temp_record->address_hist_qual[d.seq].transaction_dt_tm),
    ah.address_type_cd = temp_record->address_hist_qual[d.seq].address_type_cd, ah.street_addr =
    temp_record->address_hist_qual[d.seq].street_addr, ah.street_addr2 = temp_record->
    address_hist_qual[d.seq].street_addr2,
    ah.street_addr3 = temp_record->address_hist_qual[d.seq].street_addr3, ah.street_addr4 =
    temp_record->address_hist_qual[d.seq].street_addr4, ah.city = temp_record->address_hist_qual[d
    .seq].city,
    ah.state = temp_record->address_hist_qual[d.seq].state, ah.state_cd = temp_record->
    address_hist_qual[d.seq].state_cd, ah.zipcode = temp_record->address_hist_qual[d.seq].zipcode,
    ah.county = temp_record->address_hist_qual[d.seq].county, ah.county_cd = temp_record->
    address_hist_qual[d.seq].county_cd, ah.country = temp_record->address_hist_qual[d.seq].country,
    ah.country_cd = temp_record->address_hist_qual[d.seq].country_cd, ah.address_info_status_cd =
    temp_record->address_hist_qual[d.seq].address_info_status_cd, ah.residence_cd = temp_record->
    address_hist_qual[d.seq].residence_cd,
    ah.residence_type_cd = temp_record->address_hist_qual[d.seq].residence_type_cd, ah.mail_stop =
    temp_record->address_hist_qual[d.seq].mail_stop, ah.contact_name = temp_record->
    address_hist_qual[d.seq].contact_name,
    ah.operation_hours = temp_record->address_hist_qual[d.seq].operation_hours, ah.comment_txt =
    temp_record->address_hist_qual[d.seq].comment_txt, ah.postal_identifier = temp_record->
    address_hist_qual[d.seq].postal_identifier,
    ah.parent_beg_effective_dt_tm = cnvtdatetime(temp_record->address_hist_qual[d.seq].
     parent_beg_effective_dt_tm), ah.parent_end_effective_dt_tm = cnvtdatetime(temp_record->
     address_hist_qual[d.seq].parent_end_effective_dt_tm), ah.tracking_bit = tracking_bit,
    ah.change_bit = temp_record->address_hist_qual[d.seq].change_bit, ah.active_ind = 1, ah
    .active_status_cd = reqdata->active_status_cd,
    ah.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ah.active_status_prsnl_id = reqinfo->
    updt_id, ah.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    ah.updt_id = reqinfo->updt_id, ah.updt_applctx = reqinfo->updt_applctx, ah.updt_task = reqinfo->
    updt_task,
    ah.updt_cnt = updt_cnt
   PLAN (d)
    JOIN (ah)
   WITH nocounter, status(reply->address_qual[temp_record->address_hist_qual[d.seq].item_idx].status)
  ;end insert
 ENDIF
 FOR (index = 1 TO xref->chg_cnt)
   IF ((reply->address_qual[xref->chg[index].idx].status=0))
    SET failed = insert_error
    SET table_name = "ADDRESS_HIST"
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
