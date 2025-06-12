CREATE PROGRAM ajt_cancel_orders
 PROMPT
  "Hours in the Past to Look: " = "24"
 FREE RECORD hold
 RECORD hold(
   1 enc_cnt = i4
   1 enc[*]
     2 encntr_id = f8
     2 fin_nbr = c15
     2 disch_dt_tm = c20
     2 pat_name = vc
     2 ord_cnt = i4
     2 ord[*]
       3 order_id = f8
       3 order_desc = c45
       3 order_status_cd = f8
       3 action_type_cd = f8
       3 action = c20
       3 catalog_cd = f8
       3 catalog_type_cd = f8
       3 updt_cnt = i4
       3 oe_format_id = f8
       3 l_labcorp_ind = i4
 )
 DECLARE dc_action_cd = f8
 DECLARE dc_status_cd = f8
 DECLARE can_action_cd = f8
 DECLARE can_status_cd = f8
 DECLARE ordered_status_cd = f8
 DECLARE disc_type_cd = f8
 DECLARE med_student_status_cd = f8
 DECLARE inprocess_status_cd = f8
 DECLARE incomplete_status_cd = f8
 DECLARE suspended_status_cd = f8
 SET dc_status_cd = uar_get_code_by("MEANING",6004,"DISCONTINUED")
 SET dc_action_cd = uar_get_code_by("MEANING",6003,"DISCONTINUE")
 SET can_status_cd = uar_get_code_by("MEANING",6004,"CANCELED")
 SET can_action_cd = uar_get_code_by("MEANING",6003,"CANCEL")
 SET ordered_status_cd = uar_get_code_by("MEANING",6004,"ORDERED")
 SET disc_type_cd = uar_get_code_by("MEANING",4038,"SYSTEMDISCH")
 SET med_student_status_cd = uar_get_code_by("MEANING",6004,"MEDSTUDENT")
 SET inprocess_status_cd = uar_get_code_by("MEANING",6004,"INPROCESS")
 SET incomplete_status_cd = uar_get_code_by("MEANING",6004,"INCOMPLETE")
 SET suspended_status_cd = uar_get_code_by("MEANING",6004,"SUSPENDED")
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx3 = i4 WITH protect, noconstant(0)
 SET failed_ind = 0
 SET date_qual = cnvtlookbehind(concat( $1,",H"),cnvtdatetime(sysdate))
 CALL echo(build("Date Qual: ",format(cnvtdatetime(date_qual),"MM/DD/YYYY HH:MM:SS;;D")))
 SELECT INTO "nl:"
  p.name_full_formatted, ea.alias"###########", disch_date = format(e.disch_dt_tm,
   "MM/DD/YYYY HH:MM;;D"),
  o.ordered_as_mnemonic
  FROM person p,
   encounter e,
   orders o,
   code_value_extension cve,
   encntr_alias ea
  PLAN (e
   WHERE e.disch_dt_tm BETWEEN cnvtdatetime((curdate - 30),0) AND cnvtdatetime(date_qual))
   JOIN (p
   WHERE e.person_id=p.person_id)
   JOIN (o
   WHERE e.encntr_id=o.encntr_id
    AND ((o.order_status_cd+ 0) IN (ordered_status_cd, inprocess_status_cd, med_student_status_cd,
   incomplete_status_cd, suspended_status_cd))
    AND o.template_order_id=0.00
    AND o.orig_ord_as_flag IN (0, 5)
    AND  NOT (o.cs_flag IN (1, 3, 4, 6)))
   JOIN (cve
   WHERE cve.code_value=o.dept_status_cd
    AND cve.field_name="DCP_ALLOW_CANCEL_IND"
    AND cve.field_value="1")
   JOIN (ea
   WHERE e.encntr_id=ea.encntr_id
    AND ea.encntr_alias_type_cd=1077)
  ORDER BY e.encntr_id, o.order_mnemonic
  HEAD e.encntr_id
   hold->enc_cnt += 1
   IF ((hold->enc_cnt > size(hold->enc,5)))
    stat = alterlist(hold->enc,(hold->enc_cnt+ 5))
   ENDIF
   hold->enc[hold->enc_cnt].ord_cnt = 0, hold->enc[hold->enc_cnt].encntr_id = e.encntr_id, hold->enc[
   hold->enc_cnt].fin_nbr = cnvtalias(ea.alias,ea.alias_pool_cd),
   hold->enc[hold->enc_cnt].pat_name = substring(1,30,p.name_full_formatted), hold->enc[hold->enc_cnt
   ].disch_dt_tm = disch_date
  DETAIL
   hold->enc[hold->enc_cnt].ord_cnt += 1, oc = hold->enc[hold->enc_cnt].ord_cnt
   IF (oc > size(hold->enc[hold->enc_cnt].ord,5))
    stat = alterlist(hold->enc[hold->enc_cnt].ord,(oc+ 10))
   ENDIF
   hold->enc[hold->enc_cnt].ord[oc].order_id = o.order_id, hold->enc[hold->enc_cnt].ord[oc].
   catalog_cd = o.catalog_cd, hold->enc[hold->enc_cnt].ord[oc].catalog_type_cd = o.catalog_type_cd,
   hold->enc[hold->enc_cnt].ord[oc].updt_cnt = o.updt_cnt, hold->enc[hold->enc_cnt].ord[oc].
   oe_format_id = o.oe_format_id, hold->enc[hold->enc_cnt].ord[oc].order_desc = o.order_mnemonic
   IF (o.current_start_dt_tm < cnvtdatetime(sysdate)
    AND o.order_status_cd != med_student_status_cd)
    hold->enc[hold->enc_cnt].ord[oc].order_status_cd = dc_status_cd, hold->enc[hold->enc_cnt].ord[oc]
    .action_type_cd = dc_action_cd, hold->enc[hold->enc_cnt].ord[oc].action = "DISCONTINUE"
   ELSE
    hold->enc[hold->enc_cnt].ord[oc].order_status_cd = can_status_cd, hold->enc[hold->enc_cnt].ord[oc
    ].action_type_cd = can_action_cd, hold->enc[hold->enc_cnt].ord[oc].action = "CANCEL"
   ENDIF
  FOOT  e.encntr_id
   stat = alterlist(hold->enc[hold->enc_cnt].ord,oc)
  WITH nocounter
 ;end select
 SET stat = alterlist(hold->enc,hold->enc_cnt)
 CALL echo(build("Number of Encounters that qualify:",hold->enc_cnt))
 DECLARE mf_cs16449_perfloc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "PERFORMINGLOCATIONAMBULATORY"))
 FOR (ml_idx1 = 1 TO hold->enc_cnt)
   FOR (ml_idx2 = 1 TO hold->enc[ml_idx1].ord_cnt)
     SELECT INTO "nl:"
      FROM order_detail od,
       code_value cv
      PLAN (od
       WHERE (od.order_id=hold->enc[ml_idx1].ord[ml_idx2].order_id)
        AND od.oe_field_id=mf_cs16449_perfloc_cd)
       JOIN (cv
       WHERE cv.code_value=od.oe_field_value
        AND cv.display_key="LABCORP")
      DETAIL
       hold->enc[ml_idx1].ord[ml_idx2].l_labcorp_ind = 1
      WITH nocounter
     ;end select
   ENDFOR
 ENDFOR
 IF ((hold->enc_cnt > 0))
  FOR (encntr = 1 TO hold->enc_cnt)
    SET buf = uar_fill_order_request()
    IF (buf > 0)
     SET reply->status_data.subeventstatus[1].operationname = "dcp_ops_inp_dc_orders"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "uar_fill_order_request"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = cnvtstring(buf)
     SET failed_ind = 1
    ENDIF
    IF (failed_ind=0
     AND (hold->enc[encntr].ord_cnt > 0))
     FOR (ord = 1 TO hold->enc[encntr].ord_cnt)
       IF ((hold->enc[encntr].ord[ord].order_id > 0)
        AND (hold->enc[encntr].ord[ord].l_labcorp_ind != 1))
        CALL echo(build("Canceling Order_id:",hold->enc[encntr].ord[ord].order_id))
        SET buf = uar_fill_order_dc(hold->enc[encntr].ord[ord].order_id,hold->enc[encntr].ord[ord].
         order_status_cd,hold->enc[encntr].ord[ord].action_type_cd,hold->enc[encntr].ord[ord].action,
         hold->enc[encntr].ord[ord].catalog_cd,
         hold->enc[encntr].ord[ord].catalog_type_cd,hold->enc[encntr].ord[ord].updt_cnt,hold->enc[
         encntr].ord[ord].oe_format_id,disc_type_cd)
        IF (mod(ord,50)=0
         AND (ord != hold->enc[encntr].ord_cnt))
         IF (failed_ind=0)
          CALL echo("Calling Order Write Synch Server")
          SET buf = uar_order_perform()
          CALL echo("Back from Order Server")
          IF (buf > 0)
           SET reply->status_data.subeventstatus[1].operationname = "dcp_ops_inp_dc_orders"
           SET reply->status_data.subeventstatus[1].operationstatus = "F"
           SET reply->status_data.subeventstatus[1].targetobjectname = "uar_order_perform"
           SET reply->status_data.subeventstatus[1].targetobjectvalue = cnvtstring(buf)
           SET failed_ind = 1
          ENDIF
         ENDIF
         SET buf = uar_fill_order_request()
         IF (buf > 0)
          SET reply->status_data.subeventstatus[1].operationname = "dcp_ops_inp_dc_orders"
          SET reply->status_data.subeventstatus[1].operationstatus = "F"
          SET reply->status_data.subeventstatus[1].targetobjectname = "uar_fill_order_request"
          SET reply->status_data.subeventstatus[1].targetobjectvalue = cnvtstring(buf)
          SET failed_ind = 1
         ENDIF
        ENDIF
        IF (buf > 0)
         SET reply->status_data.subeventstatus[1].operationname = "dcp_ops_inp_dc_orders"
         SET reply->status_data.subeventstatus[1].operationstatus = "F"
         SET reply->status_data.subeventstatus[1].targetobjectname = "uar_fill_order"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = cnvtstring(buf)
         SET failed_ind = 1
         GO TO exit_script
        ENDIF
       ENDIF
     ENDFOR
     IF (failed_ind=0)
      CALL echo("Calling Order Write Synch Server")
      SET buf = uar_order_perform()
      CALL echo("Back from Order Server")
      IF (buf > 0)
       SET reply->status_data.subeventstatus[1].operationname = "dcp_ops_inp_dc_orders"
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "uar_order_perform"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = cnvtstring(buf)
       SET failed_ind = 1
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
#exit_script
END GO
