CREATE PROGRAM ams_remove_hold_source_encntr:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET exe_error = 10
 SET failed = false
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 FREE RECORD releasehold
 RECORD releasehold(
   1 benefit_order[*]
     2 benefit_ord_id = f8
     2 pe_status_reason_id = f8
 )
 DECLARE rel_cnt = i4 WITH protect, noconstant(0)
 FREE RECORD updtholdreq
 RECORD updtholdreq(
   1 objarray[*]
     2 pe_status_reason_id = f8
     2 pft_encntr_id = f8
     2 pft_balance_id = f8
     2 pe_status_reason_cd = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i4
     2 pe_hold_dt_tm = dq8
     2 pe_release_dt_tm = dq8
     2 pft_hold_id = f8
     2 claim_suppress_ind = i2
     2 bill_hold_rpts_suppress_ind = i2
     2 reason_comment = vc
     2 stmt_suppress_ind = i2
     2 pe_sub_status_reason_cd = f8
     2 precoll_suppress_ind = i2
     2 coll_suppress_ind = i2
     2 dunning_suppress_ind = i2
     2 pe_sub_status_reason_cd = f8
 )
 DECLARE active_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE inactive_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"INACTIVE"))
 DECLARE wait_for_coding_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",24450,
   "WAITINGFORCODINGORDERINGENCOUNTER"))
 DECLARE outpatientlifetime_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "OUTPATIENTLIFETIME"))
 SELECT INTO "nl:"
  FROM coding co,
   orders o,
   order_dispense od,
   charge c,
   pft_charge pc,
   pft_charge_bo_reltn pcb,
   bo_hp_reltn bhr,
   pe_status_reason p,
   benefit_order bo,
   pft_encntr pe,
   encounter e
  PLAN (co
   WHERE co.updt_dt_tm BETWEEN cnvtdatetime((curdate - 1),0) AND cnvtdatetime((curdate - 1),235959)
    AND co.coding_dt_tm BETWEEN cnvtdatetime((curdate - 1),0) AND cnvtdatetime((curdate - 1),235959)
    AND co.completed_dt_tm != null
    AND co.active_ind=1)
   JOIN (o
   WHERE o.encntr_id=co.encntr_id
    AND o.active_ind=1)
   JOIN (od
   WHERE od.parent_order_id=o.order_id)
   JOIN (c
   WHERE c.order_id=od.order_id
    AND c.active_ind=1)
   JOIN (pc
   WHERE pc.charge_item_id=c.charge_item_id
    AND pc.active_ind=1)
   JOIN (pcb
   WHERE pc.pft_charge_id=pcb.pft_charge_id
    AND pcb.active_ind=1)
   JOIN (bhr
   WHERE bhr.benefit_order_id=pcb.benefit_order_id
    AND bhr.active_ind=1)
   JOIN (p
   WHERE p.bo_hp_reltn_id=bhr.bo_hp_reltn_id
    AND p.pe_status_reason_cd=wait_for_coding_cd
    AND p.pe_release_dt_tm=null
    AND p.active_ind=1)
   JOIN (bo
   WHERE bo.benefit_order_id=bhr.benefit_order_id
    AND bo.active_ind=1)
   JOIN (pe
   WHERE pe.pft_encntr_id=bo.pft_encntr_id
    AND pe.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=pe.encntr_id
    AND e.encntr_type_cd=outpatientlifetime_cd
    AND e.active_ind=1)
  ORDER BY bo.benefit_order_id
  HEAD REPORT
   cnt = 0
  HEAD bo.benefit_order_id
   IF (mod(cnt,10)=0)
    stat = alterlist(releasehold->benefit_order,(cnt+ 10))
   ENDIF
   cnt = (cnt+ 1), releasehold->benefit_order[cnt].benefit_ord_id = bo.benefit_order_id, releasehold
   ->benefit_order[cnt].pe_status_reason_id = p.pe_status_reason_id
  FOOT REPORT
   stat = alterlist(releasehold->benefit_order,cnt)
  WITH nocounter
 ;end select
 FOR (x = 1 TO size(releasehold->benefit_order,5))
   SET rel_cnt = (rel_cnt+ 1)
   SET stat = alterlist(updtholdreq->objarray,rel_cnt)
   SET updtholdreq->objarray[rel_cnt].pe_status_reason_id = releasehold->benefit_order[x].
   pe_status_reason_id
   SET updtholdreq->objarray[rel_cnt].pe_release_dt_tm = cnvtdatetime(curdate,curtime3)
   SET updtholdreq->objarray[rel_cnt].active_ind = 0
   SET updtholdreq->objarray[rel_cnt].active_status_cd = inactive_status_cd
 ENDFOR
 IF (rel_cnt > 0)
  EXECUTE pft_da_upt_pe_status_reason  WITH replace("REQUEST",updtholdreq)
  COMMIT
 ENDIF
 CALL updtdminfo(trim(cnvtupper(curprog),3))
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
END GO
