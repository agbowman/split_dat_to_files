CREATE PROGRAM bhs_sys_udpate_charges
 SET taskassay_cd = uar_get_code_by("MEANING",13016,"TASK ASSAY")
 SET susp_cd = uar_get_code_by("MEANING",13019,"SUSPENSE")
 SET binf_cd = uar_get_code_by("MEANING",13030,"NOBILLITEM")
 SET fin_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 SET mrn_cd = uar_get_code_by("MEANING",319,"MRN")
 FREE SET chg
 RECORD chg(
   1 cnt = i4
   1 chg[*]
     2 c_id = f8
     2 dta_desc = c100
 )
 SELECT INTO "nl:"
  c.charge_item_id, dta.description
  FROM charge c,
   charge_event ce,
   discrete_task_assay dta
  PLAN (c
   WHERE ((c.active_ind+ 0)=1)
    AND c.process_flg=1
    AND c.service_dt_tm BETWEEN cnvtdatetime("01-jan-2000") AND cnvtdatetime("01-jan-2009")
    AND  EXISTS (
   (SELECT
    cm.charge_item_id
    FROM charge_mod cm
    WHERE cm.charge_item_id=c.charge_item_id
     AND cm.active_ind=1
     AND cm.charge_mod_type_cd=susp_cd
     AND cm.field1_id=binf_cd)))
   JOIN (ce
   WHERE ce.charge_event_id=c.charge_event_id
    AND ce.active_ind=1
    AND ce.ext_p_reference_cont_cd=0
    AND ce.ext_i_reference_cont_cd=taskassay_cd)
   JOIN (dta
   WHERE dta.task_assay_cd=ce.ext_i_reference_id)
  HEAD REPORT
   chg->cnt = 0
  DETAIL
   chg->cnt = (chg->cnt+ 1), stat = alterlist(chg->chg,chg->cnt), chg->chg[chg->cnt].c_id = c
   .charge_item_id,
   chg->chg[chg->cnt].dta_desc = dta.description
  WITH maxqual(c,50000)
 ;end select
 UPDATE  FROM charge c,
   (dummyt d  WITH seq = value(chg->cnt))
  SET c.active_ind = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime), c.updt_id = 999.99
  PLAN (d)
   JOIN (c
   WHERE (c.charge_item_id=chg->chg[d.seq].c_id))
 ;end update
 COMMIT
END GO
