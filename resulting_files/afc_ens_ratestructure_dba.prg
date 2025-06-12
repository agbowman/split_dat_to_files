CREATE PROGRAM afc_ens_ratestructure:dba
 SET afc_ens_ratestructure_vrsn = "201083.FT.004"
 FREE RECORD psireq
 RECORD psireq(
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
     2 action_type = vc
     2 price_sched_id = f8
     2 bill_item_id = f8
     2 price_sched_items_id = f8
     2 price_ind = i2
     2 price = f8
     2 allowable = f8
     2 percent_revenue = i4
     2 charge_level_cd = f8
     2 interval_template_cd = f8
     2 detail_charge_ind_ind = i2
     2 detail_charge_ind = i2
     2 exclusive_ind_ind = i2
     2 exclusive_ind = i2
     2 tax = f8
     2 cost_adj_amt = f8
     2 billing_discount_priority = i4
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm_ind = i2
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i2
     2 units_ind = i2
     2 units_ind_ind = i2
     2 stats_only_ind_ind = i2
     2 stats_only_ind = i2
     2 capitation_ind = i2
     2 referral_req_ind = i2
 )
 FREE RECORD psintervalreq
 RECORD psintervalreq(
   1 item_interval_qual = i2
   1 item_interval[*]
     2 action_type = c3
     2 upt_flg = i2
     2 interval_id = f8
     2 item_interval_id = f8
     2 interval_template_cd = f8
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 price = f8
     2 units = f8
 )
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE subpopulatepsireq(dummy=i2) = i4 WITH noconstant(0)
 DECLARE subexecuteuptpsi(dummy=i2) = i4 WITH noconstant(0)
 DECLARE subexecuteaddpsi(dummy=i2) = i4 WITH noconstant(0)
 DECLARE subpopulatepsintervalreq(dummy=i2) = i4 WITH noconstant(0)
 DECLARE subexecuteaddinterval(dummy=i2) = i4 WITH noconstant(0)
 DECLARE subpopulateintervalbimreq(action=vc) = i4 WITH noconstant(0)
 DECLARE subdeclarebim(dummy=i2) = i4 WITH noconstant(0)
 DECLARE subpopulatebimreq(action=vc) = i4 WITH noconstant(0)
 DECLARE subexecuteaddbim(dummy=i2) = i4 WITH noconstant(0)
 DECLARE subexecuteuptbim(dummy=i2) = i4 WITH noconstant(0)
 DECLARE subuarerror(codeset=vc,meaning=vc) = i4 WITH noconstant(0)
 DECLARE ncnt = i4 WITH noconstant(0)
 DECLARE nuptcnt = i4 WITH noconstant(0)
 IF ((validate(action_begin,- (1))=- (1)))
  DECLARE action_begin = i4
 ENDIF
 IF ((validate(action_end,- (1))=- (1)))
  DECLARE action_end = i4
 ENDIF
 DECLARE intervalcode_13019 = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(13019,"INTERVALCODE",1,intervalcode_13019)
 IF (intervalcode_13019 <= 0.0)
  CALL subuarerror("13019","INTERVALCODE")
  GO TO end_program
 ENDIF
 DECLARE chargepoint_13019 = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(13019,"CHARGE POINT",1,chargepoint_13019)
 IF (chargepoint_13019 <= 0.0)
  CALL subuarerror("13019","CHARGE POINT")
  GO TO end_program
 ENDIF
 CASE (request->ens_type_flag)
  OF 1:
   IF (subpopulatepsireq(0)=1)
    GO TO end_program
   ENDIF
   IF (subexecuteuptpsi(0)=1)
    GO TO end_program
   ENDIF
   IF (subexecuteaddpsi(0)=1)
    GO TO end_program
   ENDIF
   CALL subpopulatepsintervalreq(0)
   IF ((psintervalreq->item_interval_qual > 0))
    IF (subexecuteaddinterval(0)=1)
     GO TO end_program
    ENDIF
    CALL subdeclarebim(0)
    CALL subpopulateintervalbimreq("ADD")
    IF ((bimreq->bill_item_modifier_qual > 0))
     IF (subexecuteaddbim(0)=1)
      GO TO end_program
     ENDIF
    ENDIF
   ENDIF
  OF 2:
   CALL subdeclarebim(0)
   CALL subpopulatebimreq("UPT")
   IF ((bimreq->bill_item_modifier_qual > 0))
    IF (subexecuteuptbim(0)=1)
     GO TO end_program
    ENDIF
   ENDIF
   CALL subdeclarebim(0)
   CALL subpopulatebimreq("ADD")
   IF ((bimreq->bill_item_modifier_qual > 0))
    IF (subexecuteaddbim(0)=1)
     GO TO end_program
    ENDIF
   ENDIF
 ENDCASE
 SET reply->status_data.status = "S"
 SET reply->status_data.subeventstatus.operationname = "Save successful"
 SET reply->status_data.subeventstatus.operationstatus = "S"
 SET reply->status_data.subeventstatus.targetobjectname = ""
 SET reply->status_data.subeventstatus.targetobjectvalue = "AFC_ENS_RATESTRUCTURE"
 GO TO end_program
 SUBROUTINE subpopulatepsireq(dummy)
   SET psireq->price_sched_items_qual = size(request->objarray,5)
   SET stat = alterlist(psireq->price_sched_items,size(request->objarray,5))
   SET nuptcnt = 0
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = psireq->price_sched_items_qual)
    PLAN (d
     WHERE (request->objarray[d.seq].action_type="UPT"))
    DETAIL
     nuptcnt = (nuptcnt+ 1)
    WITH nocounter
   ;end select
   IF (nuptcnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = psireq->price_sched_items_qual)
     PLAN (d
      WHERE (request->objarray[d.seq].action_type="UPT"))
     DETAIL
      psireq->price_sched_items[d.seq].action_type = request->objarray[d.seq].action_type, psireq->
      price_sched_items[d.seq].price_sched_items_id = request->objarray[d.seq].price_sched_items_id,
      psireq->price_sched_items[d.seq].price_sched_id = request->objarray[d.seq].price_sched_id,
      psireq->price_sched_items[d.seq].bill_item_id = request->objarray[d.seq].bill_item_id, psireq->
      price_sched_items[d.seq].price = request->objarray[d.seq].price, psireq->price_sched_items[d
      .seq].interval_template_cd = request->objarray[d.seq].interval_template_cd,
      psireq->price_sched_items[d.seq].billing_discount_priority = request->objarray[d.seq].
      billing_discount_priority_seq, psireq->price_sched_items[d.seq].beg_effective_dt_tm = request->
      objarray[d.seq].beg_effective_dt_tm, psireq->price_sched_items[d.seq].end_effective_dt_tm =
      request->objarray[d.seq].end_effective_dt_tm,
      psireq->price_sched_items[d.seq].end_effective_dt_tm_ind = 1
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET reply->status_data.subeventstatus.operationname = "INSERT"
     SET reply->status_data.subeventstatus.operationstatus = "F"
     SET reply->status_data.subeventstatus.targetobjectname = "REQ"
     SET reply->status_data.subeventstatus.targetobjectvalue =
     "AFC_ENS_RATESTRUCTURE error in subroutine subpopulatepsireq (UPT Section)"
     RETURN(1)
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = psireq->price_sched_items_qual),
      price_sched_items psi
     PLAN (d
      WHERE (request->objarray[d.seq].action_type="ADD"))
      JOIN (psi
      WHERE (psi.price_sched_items_id=request->objarray[(d.seq - (psireq->price_sched_items_qual/ 2))
      ].price_sched_items_id))
     DETAIL
      psireq->price_sched_items[d.seq].action_type = request->objarray[d.seq].action_type, psireq->
      price_sched_items[d.seq].price_sched_items_id = request->objarray[d.seq].price_sched_items_id,
      psireq->price_sched_items[d.seq].price_sched_id = request->objarray[d.seq].price_sched_id,
      psireq->price_sched_items[d.seq].bill_item_id = request->objarray[d.seq].bill_item_id, psireq->
      price_sched_items[d.seq].price = request->objarray[d.seq].price, psireq->price_sched_items[d
      .seq].interval_template_cd = request->objarray[d.seq].interval_template_cd,
      psireq->price_sched_items[d.seq].billing_discount_priority = request->objarray[d.seq].
      billing_discount_priority_seq, psireq->price_sched_items[d.seq].beg_effective_dt_tm = request->
      objarray[d.seq].beg_effective_dt_tm, psireq->price_sched_items[d.seq].end_effective_dt_tm =
      request->objarray[d.seq].end_effective_dt_tm,
      psireq->price_sched_items[d.seq].allowable = psi.allowable, psireq->price_sched_items[d.seq].
      percent_revenue = psi.percent_revenue, psireq->price_sched_items[d.seq].charge_level_cd = psi
      .charge_level_cd,
      psireq->price_sched_items[d.seq].interval_template_cd = psi.interval_template_cd, psireq->
      price_sched_items[d.seq].tax = psi.tax, psireq->price_sched_items[d.seq].cost_adj_amt = psi
      .cost_adj_amt,
      psireq->price_sched_items[d.seq].billing_discount_priority = psi.billing_discount_priority_seq,
      psireq->price_sched_items[d.seq].capitation_ind = psi.capitation_ind, psireq->
      price_sched_items[d.seq].referral_req_ind = psi.referral_req_ind,
      psireq->price_sched_items[d.seq].detail_charge_ind_ind = 1, psireq->price_sched_items[d.seq].
      detail_charge_ind = psi.detail_charge_ind, psireq->price_sched_items[d.seq].exclusive_ind_ind
       = 1,
      psireq->price_sched_items[d.seq].exclusive_ind = psi.exclusive_ind, psireq->price_sched_items[d
      .seq].units_ind_ind = 1, psireq->price_sched_items[d.seq].units_ind = psi.units_ind,
      psireq->price_sched_items[d.seq].stats_only_ind_ind = 1, psireq->price_sched_items[d.seq].
      stats_only_ind = psi.stats_only_ind
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET reply->status_data.subeventstatus.operationname = "INSERT"
     SET reply->status_data.subeventstatus.operationstatus = "F"
     SET reply->status_data.subeventstatus.targetobjectname = "REQ"
     SET reply->status_data.subeventstatus.targetobjectvalue =
     "AFC_ENS_RATESTRUCTURE error in subroutine subpopulatepsireq (ADD Section)"
     RETURN(1)
    ELSE
     RETURN(0)
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = psireq->price_sched_items_qual)
     PLAN (d)
     DETAIL
      psireq->price_sched_items[d.seq].action_type = request->objarray[d.seq].action_type, psireq->
      price_sched_items[d.seq].price_sched_items_id = request->objarray[d.seq].price_sched_items_id,
      psireq->price_sched_items[d.seq].price_sched_id = request->objarray[d.seq].price_sched_id,
      psireq->price_sched_items[d.seq].bill_item_id = request->objarray[d.seq].bill_item_id, psireq->
      price_sched_items[d.seq].price = request->objarray[d.seq].price, psireq->price_sched_items[d
      .seq].interval_template_cd = request->objarray[d.seq].interval_template_cd,
      psireq->price_sched_items[d.seq].billing_discount_priority = request->objarray[d.seq].
      billing_discount_priority_seq, psireq->price_sched_items[d.seq].beg_effective_dt_tm = request->
      objarray[d.seq].beg_effective_dt_tm, psireq->price_sched_items[d.seq].end_effective_dt_tm =
      request->objarray[d.seq].end_effective_dt_tm,
      psireq->price_sched_items[d.seq].detail_charge_ind_ind = 1, psireq->price_sched_items[d.seq].
      detail_charge_ind = 1
      IF ((request->objarray[d.seq].action_type="UPT"))
       psireq->price_sched_items[d.seq].end_effective_dt_tm_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE subexecuteuptpsi(dummy)
   FREE RECORD psirep
   RECORD psirep(
     1 price_sched_items_qual = i2
     1 price_sched_items[*]
       2 price_sched_id = f8
       2 price_sched_items_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET action_begin = 1
   SET action_end = psireq->price_sched_items_qual
   SET stat = alterlist(psirep->price_sched_items,action_end)
   EXECUTE afc_upt_price_sched_item  WITH replace("REPLY",psirep), replace("REQUEST",psireq)
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(psirep)
    CALL echorecord(psireq)
   ENDIF
   IF ((psirep->status_data.status="S"))
    RETURN(0)
   ELSE
    SET reply->status_data.subeventstatus.operationname = psirep->status_data.subeventstatus.
    operationname
    SET reply->status_data.subeventstatus.operationstatus = psirep->status_data.subeventstatus.
    operationstatus
    SET reply->status_data.subeventstatus.targetobjectname = psirep->status_data.subeventstatus.
    targetobjectname
    SET reply->status_data.subeventstatus.targetobjectvalue = concat(
     "AFC_ENS_RATESTRUCTURE error in subroutine subexecuteuptpsi - ",psirep->status_data.
     subeventstatus.targetobjectvalue)
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE subexecuteaddpsi(dummy)
   FREE RECORD psirep
   RECORD psirep(
     1 price_sched_items_qual = i2
     1 price_sched_items[*]
       2 price_sched_id = f8
       2 price_sched_items_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET action_begin = 1
   SET action_end = psireq->price_sched_items_qual
   SET stat = alterlist(psirep->price_sched_items,action_end)
   EXECUTE afc_add_price_sched_item  WITH replace("REPLY",psirep), replace("REQUEST",psireq)
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(psirep)
    CALL echorecord(psireq)
   ENDIF
   IF ((psirep->status_data.status="S"))
    RETURN(0)
   ELSE
    SET reply->status_data.subeventstatus.operationname = psirep->status_data.subeventstatus.
    operationname
    SET reply->status_data.subeventstatus.operationstatus = psirep->status_data.subeventstatus.
    operationstatus
    SET reply->status_data.subeventstatus.targetobjectname = psirep->status_data.subeventstatus.
    targetobjectname
    SET reply->status_data.subeventstatus.targetobjectvalue = concat(
     "AFC_ENS_RATESTRUCTURE error in subroutine subexecuteaddpsi - ",psirep->status_data.
     subeventstatus.targetobjectvalue)
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE subpopulatepsintervalreq(dummy)
   DECLARE cnt = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(psireq->price_sched_items,5)),
     (dummyt d2  WITH seq = size(request->objarray,5))
    PLAN (d
     WHERE (psireq->price_sched_items[d.seq].interval_template_cd != 0.0)
      AND (psireq->price_sched_items[d.seq].action_type="ADD"))
     JOIN (d2
     WHERE (request->objarray[d2.seq].interval_template_cd=psireq->price_sched_items[d.seq].
     interval_template_cd)
      AND (request->objarray[d2.seq].action_type=psireq->price_sched_items[d.seq].action_type)
      AND (request->objarray[d2.seq].bill_item_id=psireq->price_sched_items[d.seq].bill_item_id))
    DETAIL
     FOR (ncnt = 1 TO size(request->objarray[d2.seq].interval_qual,5))
       cnt = (cnt+ 1), stat = alterlist(psintervalreq->item_interval,cnt), psintervalreq->
       item_interval[cnt].action_type = request->objarray[d2.seq].action_type,
       psintervalreq->item_interval[cnt].interval_id = request->objarray[d2.seq].interval_qual[ncnt].
       interval_id, psintervalreq->item_interval[cnt].parent_entity_id = psireq->price_sched_items[d
       .seq].price_sched_items_id, psintervalreq->item_interval[cnt].parent_entity_name =
       "PRICE_SCHED_ITEMS",
       psintervalreq->item_interval[cnt].interval_template_cd = request->objarray[d2.seq].
       interval_template_cd, psintervalreq->item_interval[cnt].price = request->objarray[d2.seq].
       interval_qual[ncnt].price
     ENDFOR
    WITH nocounter
   ;end select
   SET psintervalreq->item_interval_qual = size(psintervalreq->item_interval,5)
   RETURN(0)
 END ;Subroutine
 SUBROUTINE subexecuteaddinterval(dummy)
   FREE RECORD psintervalrep
   RECORD psintervalrep(
     1 item_interval_qual = i2
     1 item_interval[*]
       2 item_interval_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET action_begin = 1
   SET action_end = psintervalreq->item_interval_qual
   SET stat = alterlist(psintervalrep->item_interval,action_end)
   EXECUTE afc_add_price_sched_interval  WITH replace("REPLY",psintervalrep), replace("REQUEST",
    psintervalreq)
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(psintervalreq)
    CALL echorecord(psintervalrep)
   ENDIF
   IF ((psintervalrep->status_data.status="S"))
    RETURN(0)
   ELSE
    SET reply->status_data.subeventstatus.operationname = psintervalrep->status_data.subeventstatus.
    operationname
    SET reply->status_data.subeventstatus.operationstatus = psintervalrep->status_data.subeventstatus
    .operationstatus
    SET reply->status_data.subeventstatus.targetobjectname = psintervalrep->status_data.
    subeventstatus.targetobjectname
    SET reply->status_data.subeventstatus.targetobjectvalue = concat(
     "AFC_ENS_RATESTRUCTURE error in subroutine subexecuteaddinterval - ",psintervalrep->status_data.
     subeventstatus.targetobjectvalue)
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE subpopulateintervalbimreq(action)
  SET ncnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = size(psireq->price_sched_items,5)),
    (dummyt d1  WITH seq = size(request->objarray,5)),
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1),
    (dummyt d4  WITH seq = size(psintervalreq->item_interval,5))
   PLAN (d
    WHERE (psireq->price_sched_items[d.seq].interval_template_cd != 0.0)
     AND (psireq->price_sched_items[d.seq].action_type="ADD"))
    JOIN (d1
    WHERE (request->objarray[d1.seq].interval_template_cd=psireq->price_sched_items[d.seq].
    interval_template_cd)
     AND (request->objarray[d1.seq].action_type=psireq->price_sched_items[d.seq].action_type)
     AND (request->objarray[d1.seq].bill_item_id=psireq->price_sched_items[d.seq].bill_item_id)
     AND maxrec(d2,size(request->objarray[d1.seq].interval_qual,5)))
    JOIN (d2
    WHERE maxrec(d3,size(request->objarray[d1.seq].interval_qual[d2.seq].bill_code_sched,5)))
    JOIN (d3)
    JOIN (d4
    WHERE (request->objarray[d1.seq].interval_qual[d2.seq].interval_id=psintervalreq->item_interval[
    d4.seq].interval_id)
     AND (psintervalreq->item_interval[d4.seq].parent_entity_id=psireq->price_sched_items[d.seq].
    price_sched_items_id))
   HEAD REPORT
    ncnt = 0
   DETAIL
    ncnt = (ncnt+ 1), stat = alterlist(bimreq->bill_item_modifier,ncnt), bimreq->bill_item_modifier[
    ncnt].action_type = request->objarray[d1.seq].action_type,
    bimreq->bill_item_modifier[ncnt].bill_item_id = request->objarray[d1.seq].bill_item_id, bimreq->
    bill_item_modifier[ncnt].bill_item_type_cd = intervalcode_13019, bimreq->bill_item_modifier[ncnt]
    .key2_id = psintervalreq->item_interval[d4.seq].item_interval_id,
    bimreq->bill_item_modifier[ncnt].bim1_int = 1
    CASE (trim(uar_get_code_meaning(cnvtreal(request->objarray[d1.seq].interval_qual[d2.seq].
       bill_code_sched[d3.seq].bill_code_sched_cd))))
     OF "CPT4":
      bimreq->bill_item_modifier[ncnt].key1_id = request->objarray[d1.seq].interval_qual[d2.seq].
      bill_code_sched[d3.seq].bill_code_sched_cd,bimreq->bill_item_modifier[ncnt].key3_id = request->
      objarray[d1.seq].interval_qual[d2.seq].bill_code_sched[d3.seq].nomen_id,bimreq->
      bill_item_modifier[ncnt].key6 = request->objarray[d1.seq].interval_qual[d2.seq].
      bill_code_sched[d3.seq].bill_code_sched_value,
      bimreq->bill_item_modifier[ncnt].key7 = request->objarray[d1.seq].interval_qual[d2.seq].
      bill_code_sched[d3.seq].bill_code_sched_desc
     OF "MODIFIER":
      bimreq->bill_item_modifier[ncnt].key1_id = request->objarray[d1.seq].interval_qual[d2.seq].
      bill_code_sched[d3.seq].bill_code_sched_cd,bimreq->bill_item_modifier[ncnt].key5_id = request->
      objarray[d1.seq].interval_qual[d2.seq].bill_code_sched[d3.seq].key5_id,bimreq->
      bill_item_modifier[ncnt].key6 = request->objarray[d1.seq].interval_qual[d2.seq].
      bill_code_sched[d3.seq].bill_code_sched_value,
      bimreq->bill_item_modifier[ncnt].key7 = request->objarray[d1.seq].interval_qual[d2.seq].
      bill_code_sched[d3.seq].bill_code_sched_desc
     OF "HCPCS":
      bimreq->bill_item_modifier[ncnt].key1_id = request->objarray[d1.seq].interval_qual[d2.seq].
      bill_code_sched[d3.seq].bill_code_sched_cd,bimreq->bill_item_modifier[ncnt].key3_id = request->
      objarray[d1.seq].interval_qual[d2.seq].bill_code_sched[d3.seq].nomen_id,bimreq->
      bill_item_modifier[ncnt].key6 = request->objarray[d1.seq].interval_qual[d2.seq].
      bill_code_sched[d3.seq].bill_code_sched_value,
      bimreq->bill_item_modifier[ncnt].key7 = request->objarray[d1.seq].interval_qual[d2.seq].
      bill_code_sched[d3.seq].bill_code_sched_desc
     OF "PROCCODE":
      bimreq->bill_item_modifier[ncnt].key1_id = request->objarray[d1.seq].interval_qual[d2.seq].
      bill_code_sched[d3.seq].bill_code_sched_cd,bimreq->bill_item_modifier[ncnt].key3_id = request->
      objarray[d1.seq].interval_qual[d2.seq].bill_code_sched[d3.seq].nomen_id,bimreq->
      bill_item_modifier[ncnt].key6 = request->objarray[d1.seq].interval_qual[d2.seq].
      bill_code_sched[d3.seq].bill_code_sched_value,
      bimreq->bill_item_modifier[ncnt].key7 = request->objarray[d1.seq].interval_qual[d2.seq].
      bill_code_sched[d3.seq].bill_code_sched_desc
     OF "CDM_SCHED":
      bimreq->bill_item_modifier[ncnt].key1_id = request->objarray[d1.seq].interval_qual[d2.seq].
      bill_code_sched[d3.seq].bill_code_sched_cd,bimreq->bill_item_modifier[ncnt].key6 = request->
      objarray[d1.seq].interval_qual[d2.seq].bill_code_sched[d3.seq].bill_code_sched_value,bimreq->
      bill_item_modifier[ncnt].key7 = request->objarray[d1.seq].interval_qual[d2.seq].
      bill_code_sched[d3.seq].bill_code_sched_desc
    ENDCASE
   FOOT REPORT
    stat = alterlist(bimreq->bill_item_modifier,ncnt), bimreq->bill_item_modifier_qual = ncnt
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE subuarerror(codeset,meaning)
   SET reply->status_data.subeventstatus.operationname = "FAILED"
   SET reply->status_data.subeventstatus.operationstatus = "F"
   SET reply->status_data.subeventstatus.targetobjectname = "UAR"
   SET reply->status_data.subeventstatus.targetobjectvalue = concat(
    "AFC_ENS_RATESTRUCTURE UAR call Code Set ",codeset," Meaning ",meaning)
 END ;Subroutine
 SUBROUTINE subpopulatebimreq(action)
  SET ncnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = size(request->objarray,5))
   PLAN (d
    WHERE (request->objarray[d.seq].action_type=action))
   HEAD REPORT
    ncnt = 0, stat = alterlist(bimreq->bill_item_modifier,size(request->objarray,5))
   DETAIL
    ncnt = (ncnt+ 1), bimreq->bill_item_modifier[ncnt].action_type = request->objarray[d.seq].
    action_type, bimreq->bill_item_modifier[ncnt].bill_item_mod_id = request->objarray[d.seq].
    bill_item_mod_id,
    bimreq->bill_item_modifier[ncnt].bill_item_id = request->objarray[d.seq].bill_item_id, bimreq->
    bill_item_modifier[ncnt].bill_item_type_cd = chargepoint_13019, bimreq->bill_item_modifier[ncnt].
    key1_id = request->objarray[d.seq].charge_point_sched_cd,
    bimreq->bill_item_modifier[ncnt].key2_id = request->objarray[d.seq].charge_point_cd, bimreq->
    bill_item_modifier[ncnt].key4_id = request->objarray[d.seq].charge_level_cd, bimreq->
    bill_item_modifier[ncnt].bim1_int = request->objarray[d.seq].bim1_int
   FOOT REPORT
    stat = alterlist(bimreq->bill_item_modifier,ncnt), bimreq->bill_item_modifier_qual = ncnt
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE subexecuteuptbim(dummy)
   SET action_begin = 1
   SET action_end = bimreq->bill_item_modifier_qual
   SET stat = alterlist(bimrep->bill_item_modifier,action_end)
   EXECUTE afc_upt_bill_item_modifier  WITH replace("REPLY",bimrep), replace("REQUEST",bimreq)
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(bimreq)
    CALL echorecord(bimrep)
   ENDIF
   IF ((bimrep->status_data.status="S"))
    RETURN(0)
   ELSE
    SET reply->status_data.subeventstatus.operationname = bimrep->status_data.subeventstatus.
    operationname
    SET reply->status_data.subeventstatus.operationstatus = bimrep->status_data.subeventstatus.
    operationstatus
    SET reply->status_data.subeventstatus.targetobjectname = bimrep->status_data.subeventstatus.
    targetobjectname
    SET reply->status_data.subeventstatus.targetobjectvalue = concat(
     "AFC_ENS_RATESTRUCTURE error in subroutine subexecuteuptbim - ",bimrep->status_data.
     subeventstatus.targetobjectvalue)
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE subexecuteaddbim(dummy)
   SET action_begin = 1
   SET action_end = bimreq->bill_item_modifier_qual
   SET stat = alterlist(bimrep->bill_item_modifier,action_end)
   EXECUTE afc_add_bill_item_modifier  WITH replace("REPLY",bimrep), replace("REQUEST",bimreq)
   IF (validate(debug,- (1)) > 0)
    CALL echorecord(bimreq)
    CALL echorecord(bimrep)
   ENDIF
   IF ((bimrep->status_data.status="S"))
    RETURN(0)
   ELSE
    SET reply->status_data.subeventstatus.operationname = bimrep->status_data.subeventstatus.
    operationname
    SET reply->status_data.subeventstatus.operationstatus = bimrep->status_data.subeventstatus.
    operationstatus
    SET reply->status_data.subeventstatus.targetobjectname = bimrep->status_data.subeventstatus.
    targetobjectname
    SET reply->status_data.subeventstatus.targetobjectvalue = concat(
     "AFC_ENS_RATESTRUCTURE error in subroutine subexecuteaddbim - ",bimrep->status_data.
     subeventstatus.targetobjectvalue)
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE subdeclarebim(dummy)
   FREE RECORD bimreq
   RECORD bimreq(
     1 bill_item_modifier_qual = i2
     1 bill_item_modifier[*]
       2 action_type = c3
       2 bill_item_mod_id = f8
       2 bill_item_id = f8
       2 bill_item_type_cd = f8
       2 key1_id = f8
       2 key2_id = f8
       2 key3_id = f8
       2 key4_id = f8
       2 key5_id = f8
       2 key6 = vc
       2 key7 = vc
       2 key8 = vc
       2 key9 = vc
       2 key10 = vc
       2 key11 = vc
       2 key12 = vc
       2 key13 = vc
       2 key14 = vc
       2 key15 = vc
       2 key11_id = f8
       2 key12_id = f8
       2 key13_id = f8
       2 key14_id = f8
       2 key15_id = f8
       2 bim1_int = f8
       2 bim2_int = f8
       2 bim_ind = i2
       2 bim1_ind = i2
       2 bim1_nbr = f8
       2 active_ind_ind = i2
       2 active_ind = i2
       2 active_status_cd = f8
       2 active_status_dt_tm = dq8
       2 active_status_prsnl_id = f8
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 updt_cnt = i2
   ) WITH persistscript
   FREE RECORD bimrep
   RECORD bimrep(
     1 bill_item_modifier_qual = i2
     1 bill_item_modifier[*]
       2 bill_item_mod_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH persistscript
 END ;Subroutine
#end_program
 IF ((reply->status_data.status="S"))
  COMMIT
  SET reqinfo->commit_ind = 1
 ELSE
  ROLLBACK
  SET reqinfo->commit_ind = 0
 ENDIF
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(reply)
  CALL echorecord(request)
 ENDIF
 FREE RECORD psireq
 FREE RECORD psirep
 FREE RECORD psintervalreq
 FREE RECORD psintervalrep
 FREE RECORD bimreq
 FREE RECORD bimrep
END GO
