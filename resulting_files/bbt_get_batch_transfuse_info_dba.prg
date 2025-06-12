CREATE PROGRAM bbt_get_batch_transfuse_info:dba
 RECORD reply(
   1 qual[*]
     2 product_id = f8
     2 product_nbr = c20
     2 product_sub_nbr = c5
     2 product_cd = f8
     2 product_disp = c40
     2 cur_unit_meas_cd = f8
     2 cur_unit_meas_disp = c40
     2 cur_expire_dt_tm = dq8
     2 product_updt_cnt = i4
     2 comments_ind = i2
     2 product_type = c2
     2 cur_abo_cd = f8
     2 cur_abo_disp = c40
     2 cur_rh_cd = f8
     2 cur_rh_disp = c40
     2 cur_volume = i4
     2 deriv_item_volume = i4
     2 deriv_item_unit_meas_cd = f8
     2 deriv_item_unit_meas_disp = c40
     2 deriv_updt_cnt = i4
     2 nbr_of_states = i4
     2 qual2[*]
       3 product_event_id = f8
       3 product_id = f8
       3 person_id = f8
       3 encntr_id = f8
       3 order_id = f8
       3 bb_result_id = f8
       3 event_type_cd = f8
       3 event_type_disp = c40
       3 event_type_mean = c60
       3 event_dt_tm = dq8
       3 event_prsnl_id = f8
       3 event_updt_cnt = i4
       3 pd_updt_cnt = i4
       3 pd_deriv_qty = i4
       3 pd_deriv_iu = i4
       3 pd_cooler_cd = f8
       3 pd_unknown_pat_ind = i2
       3 pd_unknown_pat_text = c50
       3 pd_cooler_text = c40
       3 xm_updt_cnt = i4
       3 accession_number = c20
     2 status = c2
     2 err_message = c28
     2 auto_ind = i2
     2 xm_required_ind = i2
     2 serial_nbr_txt = c22
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET event_date = cnvtdatetimeutc(cnvtdatetime(sysdate),1)
 SET reply->status_data.status = "F"
 SET reply->status = "S"
 SET count1 = 0
 SET count2 = 0
 SET max2 = 1
 SET qualstep = 0
 SET verified_status_cd = 0.0
 DECLARE pref_allow_cool_ind = i2
 DECLARE pref_allow_ref_ind = i2
 DECLARE quest_allow_cool_cd = f8
 DECLARE quest_allow_ref_cd = f8
 DECLARE ans_yes_cd = f8
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE hour_string = vc
 SET hour_string = ""
 SET quest_allow_cool_cd = 0.0
 SET quest_allow_ref_cd = 0.0
 SET pref_allow_cool_ind = 0
 SET pref_allow_ref_ind = 0
 SET ans_yes_cd = 0.0
 SET code_cnt = 1
 SET dispense_event_type_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(1610,"4",code_cnt,dispense_event_type_cd)
 IF (dispense_event_type_cd=0.0)
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_get_batch_transfuse.prg"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to retrieve the code_value for the cdf_meaning 4 in code_set 1610."
  SET reply->status = "F"
 ENDIF
 SET code_cnt = 1
 SET crossmatch_event_type_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(1610,"3",code_cnt,crossmatch_event_type_cd)
 IF (crossmatch_event_type_cd=0.0)
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_get_batch_transfuse.prg"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to retrieve the code_value for the cdf_meaning 3 in code_set 1610."
  SET reply->status = "F"
 ENDIF
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1661,"TRANSF INC C",code_cnt,quest_allow_cool_cd)
 IF (quest_allow_cool_cd=0.0)
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_get_batch_transfuse.prg"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to retrieve the code_value for the cdf_meaning TRANSF INC C in code_set 1661."
  SET reply->status = "F"
 ENDIF
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1661,"TRANSF INC R",code_cnt,quest_allow_ref_cd)
 IF (quest_allow_ref_cd=0.0)
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_get_batch_transfuse.prg"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to retrieve the code_value for the cdf_meaning TRANSF INC R in code_set 1661."
  SET reply->status = "F"
 ENDIF
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1659,"Y",code_cnt,ans_yes_cd)
 IF (ans_yes_cd=0.0)
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_get_batch_transfuse.prg"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to retrieve the code_value for the cdf_meaning Y in code_set 1659."
  SET reply->status = "F"
 ENDIF
 SELECT INTO "nl:"
  a.question_cd, a.answer
  FROM answer a
  WHERE a.question_cd IN (quest_allow_cool_cd, quest_allow_ref_cd)
   AND a.active_ind=1
  DETAIL
   CASE (a.question_cd)
    OF quest_allow_cool_cd:
     IF (cnvtint(a.answer)=ans_yes_cd)
      pref_allow_cool_ind = 1
     ENDIF
    OF quest_allow_ref_cd:
     IF (cnvtint(a.answer)=ans_yes_cd)
      pref_allow_ref_ind = 1
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failure_occured = "T"
  SET reply->status_data.status = "F"
  SET error_process = "get codevalues"
  SET error_message = "fail on getting preference answeres"
 ENDIF
 IF ((reply->status="S"))
  SET hour_string = concat(trim(cnvtstring(request->look_ahead_hrs)),",H")
  SET event_date = cnvtlookbehind(hour_string,event_date)
  SELECT
   IF (size(request->inv_area_qual,5) > 0)
    PLAN (pd
     WHERE pd.active_ind=1
      AND pd.product_id != 0
      AND pd.product_id != null)
     JOIN (p
     WHERE pd.product_id=p.product_id
      AND p.product_id != 0
      AND p.product_id != null
      AND expand(num,1,size(request->inv_area_qual,5),p.cur_inv_area_cd,request->inv_area_qual[num].
      inv_area_cd))
     JOIN (pe
     WHERE pe.product_event_id=pd.product_event_id
      AND pe.active_ind=1
      AND pe.product_id != 0
      AND pe.product_id != null
      AND pe.event_type_cd=dispense_event_type_cd
      AND cnvtdatetimeutc(event_date,2) >= pe.event_dt_tm)
   ELSE
    PLAN (pd
     WHERE pd.active_ind=1
      AND pd.product_id != 0
      AND pd.product_id != null)
     JOIN (p
     WHERE pd.product_id=p.product_id
      AND p.product_id != 0
      AND p.product_id != null)
     JOIN (pe
     WHERE pe.product_event_id=pd.product_event_id
      AND pe.active_ind=1
      AND pe.product_id != 0
      AND pe.product_id != null
      AND pe.event_type_cd=dispense_event_type_cd
      AND cnvtdatetimeutc(event_date,2) >= pe.event_dt_tm)
   ENDIF
   DISTINCT INTO "nl:"
   pe.product_id, pd.product_id, p.product_id
   FROM patient_dispense pd,
    product_event pe,
    product p
   ORDER BY p.product_id
   HEAD REPORT
    count1 = 0, max2 = 1, allow_product_ind = 0
   HEAD p.product_id
    count2 = 0, allow_product_ind = 0
    IF (((pd.device_id=0.0) OR (pd.device_id=null))
     AND ((pd.dispense_cooler_id=0.0) OR (pd.dispense_cooler_id=null))
     AND ((trim(pd.dispense_cooler_text,3) <= " ") OR (pd.dispense_cooler_text=null)) )
     allow_product_ind = 1
    ELSEIF (pd.device_id > 0.0)
     IF (pref_allow_ref_ind=1)
      allow_product_ind = 1
     ENDIF
    ELSEIF (((pd.dispense_cooler_id > 0) OR (trim(pd.dispense_cooler_text,3) > "")) )
     IF (pref_allow_cool_ind=1)
      allow_product_ind = 1
     ENDIF
    ENDIF
    IF (allow_product_ind=1)
     count1 += 1, stat = alterlist(reply->qual,count1)
    ENDIF
   DETAIL
    IF (allow_product_ind=1)
     reply->qual[count1].product_id = p.product_id
     IF (p.locked_ind=1)
      reply->qual[count1].status = "PL"
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->qual,count1)
  SET count2 = count1
  FOR (count = 1 TO count2)
   UPDATE  FROM product p
    SET p.locked_ind = 1, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(sysdate),
     p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
     updt_applctx
    PLAN (p
     WHERE (p.product_id=reply->qual[count].product_id)
      AND p.product_id != 0.0
      AND p.product_id != null
      AND ((p.locked_ind = null) OR (p.locked_ind=0)) )
    WITH nocounter
   ;end update
   IF (curqual=0)
    IF ((reply->qual[count].status != "PL"))
     SET reply->qual[count].status = "LF"
    ENDIF
    SET reply->qual[count].err_message = "Unable to lock product table"
   ELSE
    COMMIT
    SET reply->qual[count].product_updt_cnt += 1
   ENDIF
  ENDFOR
  IF (count2 > 0)
   SET count = 0
   SELECT INTO "nl:"
    p.product_id, p.product_nbr, p.product_sub_nbr,
    p.product_cd, p.cur_expire_dt_tm, p.updt_cnt,
    p.product_cat_cd, pi.autologous_ind, pc.xmatch_required_ind,
    pn.product_id, b.product_id, b.cur_volume,
    b.cur_abo_cd, b.cur_rh_cd, dr.product_id,
    dr.updt_cnt, com_found = decode(pn.seq,"cf","xx"), tablefrom = decode(b.seq,"b",dr.seq,"d","x")
    FROM product p,
     product_index pi,
     product_category pc,
     blood_product b,
     derivative dr,
     product_note pn,
     (dummyt d_pn  WITH seq = 1),
     (dummyt d1  WITH seq = 1),
     (dummyt d  WITH seq = value(count2))
    PLAN (d)
     JOIN (p
     WHERE (reply->qual[d.seq].product_id=p.product_id)
      AND p.product_id != 0.0
      AND p.product_id != null)
     JOIN (pi
     WHERE pi.product_cd=p.product_cd)
     JOIN (pc
     WHERE pc.product_cat_cd=p.product_cat_cd)
     JOIN (d1
     WHERE d1.seq=1)
     JOIN (((b
     WHERE b.product_id=p.product_id)
     ) ORJOIN ((dr
     WHERE dr.product_id=p.product_id)
     )) JOIN (d_pn
     WHERE d_pn.seq=1)
     JOIN (pn
     WHERE pn.product_id=p.product_id
      AND pn.active_ind=1)
    ORDER BY p.product_id
    HEAD p.product_id
     count1 = d.seq
    DETAIL
     reply->qual[count1].product_id = p.product_id, reply->qual[count1].product_nbr = p.product_nbr,
     reply->qual[count1].product_sub_nbr = p.product_sub_nbr,
     reply->qual[count1].product_updt_cnt = p.updt_cnt, reply->qual[count1].product_cd = p.product_cd,
     reply->qual[count1].cur_expire_dt_tm = cnvtdatetime(p.cur_expire_dt_tm),
     reply->qual[count1].cur_unit_meas_cd = p.cur_unit_meas_cd, reply->qual[count1].auto_ind = pi
     .autologous_ind, reply->qual[count1].xm_required_ind = pc.xmatch_required_ind,
     reply->qual[count1].serial_nbr_txt = p.serial_number_txt
     IF (com_found="cf")
      reply->qual[count1].comments_ind = 1
     ELSE
      reply->qual[count1].comments_ind = 0
     ENDIF
     IF (tablefrom="b")
      reply->qual[count1].product_type = "B", reply->qual[count1].cur_abo_cd = b.cur_abo_cd, reply->
      qual[count1].cur_rh_cd = b.cur_rh_cd,
      reply->qual[count1].cur_volume = b.cur_volume
     ELSEIF (tablefrom="d")
      reply->qual[count1].product_type = "D", reply->qual[count1].deriv_item_volume = dr.item_volume,
      reply->qual[count1].deriv_item_unit_meas_cd = dr.item_unit_meas_cd,
      reply->qual[count1].deriv_updt_cnt = dr.updt_cnt
     ENDIF
    WITH nocounter, outerjoin = d_pn
   ;end select
  ENDIF
  IF (count2 > 0)
   SET count1 = size(reply->qual,5)
   SET count = 0
   SELECT INTO "nl:"
    e.product_event_id, e.product_id, e.person_id,
    e.order_id, e.bb_result_id, e.event_type_cd,
    e.event_dt_tm, e.event_prsnl_id, e.person_id,
    e.encntr_id, e.updt_cnt, pd.updt_cnt,
    pd.cur_dispense_qty, pd.cur_dispense_intl_units, pd.dispense_cooler_id,
    pd.dispense_cooler_text, xm.product_event_id, xm.updt_cnt,
    asg.product_event_id, asg.updt_cnt, aor.accession,
    tablefrom2 = decode(pd.seq,"pd",xm.seq,"xm",asg.seq,
     "as","xx")
    FROM product_event e,
     patient_dispense pd,
     crossmatch xm,
     assign asg,
     accession_order_r aor,
     (dummyt d3  WITH seq = 1),
     (dummyt d4  WITH seq = 1),
     (dummyt d  WITH seq = value(count1))
    PLAN (d)
     JOIN (e
     WHERE (reply->qual[d.seq].product_id=e.product_id)
      AND (((reply->qual[d.seq].status != "LF")) OR ((reply->qual[d.seq].status != "PL")))
      AND (reply->qual[d.seq].status != "F")
      AND e.active_ind=1
      AND e.product_id != 0
      AND e.product_id != null
      AND ((e.event_status_flag < 1) OR (e.event_status_flag=null))
      AND (((reply->qual[d.seq].product_type="D")
      AND e.event_type_cd=dispense_event_type_cd) OR ((reply->qual[d.seq].product_type="B"))) )
     JOIN (d3
     WHERE d3.seq=1)
     JOIN (((pd
     WHERE pd.product_event_id=e.product_event_id)
     ) ORJOIN ((((xm
     WHERE xm.product_event_id=e.product_event_id)
     JOIN (d4
     WHERE d4.seq=1)
     JOIN (aor
     WHERE aor.order_id=e.order_id
      AND aor.primary_flag=0)
     ) ORJOIN ((asg
     WHERE asg.product_event_id=e.product_event_id)
     )) ))
    ORDER BY e.product_id
    HEAD e.product_id
     numstates = 0, count2 = 0
    DETAIL
     IF (e.event_type_cd != 0
      AND ((tablefrom2 != "pd") OR (cnvtdatetimeutc(event_date,2) >= e.event_dt_tm))
      AND (reply->qual[d.seq].status != "F")
      AND (((reply->qual[d.seq].product_type="D")
      AND e.event_type_cd=dispense_event_type_cd) OR ((reply->qual[d.seq].product_type="B"))) )
      count2 += 1
      IF (count2 > 0)
       stat = alterlist(reply->qual[d.seq].qual2,count2)
      ELSE
       stat = alterlist(reply->qual[d.seq].qual2,1)
      ENDIF
      reply->qual[d.seq].qual2[count2].product_event_id = e.product_event_id, reply->qual[d.seq].
      qual2[count2].product_id = e.product_id, reply->qual[d.seq].qual2[count2].person_id = e
      .person_id,
      reply->qual[d.seq].qual2[count2].encntr_id = e.encntr_id, reply->qual[d.seq].qual2[count2].
      order_id = e.order_id, reply->qual[d.seq].qual2[count2].event_type_cd = e.event_type_cd,
      reply->qual[d.seq].qual2[count2].event_dt_tm = cnvtdatetime(e.event_dt_tm), reply->qual[d.seq].
      qual2[count2].event_prsnl_id = e.event_prsnl_id, reply->qual[d.seq].qual2[count2].
      event_updt_cnt = e.updt_cnt
      IF (tablefrom2="pd")
       reply->qual[d.seq].qual2[count2].pd_deriv_qty = pd.cur_dispense_qty, reply->qual[d.seq].qual2[
       count2].pd_deriv_iu = pd.cur_dispense_intl_units, reply->qual[d.seq].qual2[count2].pd_updt_cnt
        = pd.updt_cnt,
       reply->qual[d.seq].qual2[count2].pd_cooler_cd = pd.dispense_cooler_id, reply->qual[d.seq].
       qual2[count2].pd_unknown_pat_ind = pd.unknown_patient_ind, reply->qual[d.seq].qual2[count2].
       pd_unknown_pat_text = pd.unknown_patient_text,
       reply->qual[d.seq].qual2[count2].pd_cooler_text = pd.dispense_cooler_text
      ENDIF
      IF (tablefrom2="xm")
       reply->qual[d.seq].qual2[count2].xm_updt_cnt = xm.updt_cnt, reply->qual[d.seq].qual2[count2].
       accession_number = aor.accession
      ENDIF
      IF (tablefrom2="as")
       reply->qual[d.seq].qual2[count2].xm_updt_cnt = asg.updt_cnt
      ENDIF
      reply->qual[d.seq].nbr_of_states = count2
     ENDIF
    WITH counter, outerjoin = d3, dontcare = d4
   ;end select
  ENDIF
  SET count1 = size(reply->qual,5)
  IF (count1=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
