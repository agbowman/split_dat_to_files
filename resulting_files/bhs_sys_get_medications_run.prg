CREATE PROGRAM bhs_sys_get_medications_run
 DECLARE output_err_msg(err_msg=vc) = null
 DECLARE get_prescriptions_by_person(null) = i2
 DECLARE get_prescriptions_by_person_reply(null) = i2
 DECLARE cs48_active_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE cs106_pharmacy_cd = f8 WITH constant(uar_get_code_by("MEANING",106,"PHARMACY"))
 DECLARE cs6004_incomplete_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE cs6004_inprocess_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE cs6004_ordered_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 IF (validate(bhs_medications_req->mode," ")=" ")
  CALL echo("No request mode found. Exitting Script")
  GO TO exit_script
 ELSE
  IF (trim(cnvtlower(bhs_medications_req->mode))="prescriptions")
   SET d0 = get_prescriptions_by_person(null)
  ELSE
   SET d0 = output_err_msg(build2("Invalid request mode (",trim(cnvtlower(bhs_medications_req->mode)),
     ") found. Exitting Script"))
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE output_err_msg(err_msg)
   IF ((validate(bhs_medications_reply->p_cnt,- (1))=- (1)))
    CALL echo(trim(err_msg))
   ELSE
    SET bhs_medications_reply->status = - (1)
    SET bhs_medications_reply->errmsg = trim(err_msg)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_prescriptions_by_person_reply(null)
   FREE RECORD bhs_medications_reply
   RECORD bhs_medications_reply(
     1 p_cnt = i4
     1 persons[*]
       2 person_id = f8
       2 m_cnt = i4
       2 medications[*]
         3 order_id = f8
         3 order_type_ind = i2
         3 hna_order_mnemonic = vc
         3 ordered_as_mnemonic = vc
     1 status = i2
     1 errmsg = vc
   ) WITH persist
   RETURN(1)
 END ;Subroutine
 SUBROUTINE get_prescriptions_by_person(null)
   IF (get_prescriptions_by_person_reply(null)=0)
    SET d0 = output_err_msg(
     "Unable to create REPLY record structure. Exiting 'get_prescriptions_by_person'")
    RETURN(0)
   ENDIF
   IF (size(bhs_medications_req->persons,5) <= 0)
    SET d0 = output_err_msg(
     "No persons found in bhs_medications_req. Exiting 'get_prescriptions_by_person'")
    RETURN(0)
   ENDIF
   SET stat = alterlist(bhs_medications_reply->persons,size(bhs_medications_req->persons,5))
   SET bhs_medications_reply->p_cnt = size(bhs_medications_reply->persons,5)
   FOR (p = 1 TO bhs_medications_reply->p_cnt)
     SET bhs_medications_reply->persons[p].person_id = bhs_medications_req->persons[p].person_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(bhs_medications_reply->p_cnt)),
     orders o
    PLAN (d)
     JOIN (o
     WHERE (bhs_medications_reply->persons[d.seq].person_id=o.person_id)
      AND o.activity_type_cd=cs106_pharmacy_cd
      AND o.template_order_id=0.00
      AND ((o.order_status_cd+ 0.00) IN (cs6004_incomplete_cd, cs6004_inprocess_cd, cs6004_ordered_cd
     ))
      AND o.orig_ord_as_flag IN (1, 2)
      AND o.discontinue_ind=0)
    ORDER BY o.hna_order_mnemonic
    HEAD REPORT
     m_cnt = 0
    DETAIL
     m_cnt = (bhs_medications_reply->persons[d.seq].m_cnt+ 1), stat = alterlist(bhs_medications_reply
      ->persons[d.seq].medications,m_cnt), bhs_medications_reply->persons[d.seq].m_cnt = m_cnt,
     bhs_medications_reply->persons[d.seq].medications[m_cnt].order_id = o.order_id,
     bhs_medications_reply->persons[d.seq].medications[m_cnt].order_type_ind = o.orig_ord_as_flag,
     bhs_medications_reply->persons[d.seq].medications[m_cnt].hna_order_mnemonic = trim(o
      .hna_order_mnemonic,3),
     bhs_medications_reply->persons[d.seq].medications[m_cnt].ordered_as_mnemonic = trim(o
      .ordered_as_mnemonic,3)
    WITH nocounter
   ;end select
   SET bhs_medications_reply->status = 1
   RETURN(1)
 END ;Subroutine
#exit_script
END GO
