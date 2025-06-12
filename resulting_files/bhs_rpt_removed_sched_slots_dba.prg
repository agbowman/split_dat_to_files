CREATE PROGRAM bhs_rpt_removed_sched_slots:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE mf_cs14490_removed = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14490,"REMOVED")),
 protect
 SELECT DISTINCT INTO  $OUTDEV
  personnel_name = substring(1,100,pr.name_full_formatted), personnel_user_name = substring(1,20,pr
   .username), removal_date = substring(1,30,format(sa.action_dt_tm,"dd-mm-yyyy hh:mm:ss;;q")),
  position = substring(1,30,uar_get_code_display(pr.position_cd)), slot = substring(1,100,sap
   .slot_mnemonic), location = substring(1,100,uar_get_code_display(sap.resource_cd)),
  slotstate = uar_get_code_display(sap.slot_state_cd)
  FROM sch_action sa,
   prsnl pr,
   sch_appt sap,
   sch_slot_type ss
  PLAN (sa
   WHERE (sa.action_dt_tm > (sysdate - 30))
    AND sa.updt_task=650005
    AND sa.active_ind=1)
   JOIN (sap
   WHERE sap.updt_dt_tm=sa.updt_dt_tm
    AND sap.slot_state_cd=mf_cs14490_removed
    AND sap.active_ind=1)
   JOIN (ss
   WHERE ss.slot_type_id=sap.slot_type_id)
   JOIN (pr
   WHERE (sa.updt_id= Outerjoin(pr.person_id))
    AND pr.active_ind=1)
  ORDER BY sa.action_dt_tm DESC, sap.slot_mnemonic
  WITH nocounter, format, separator = " "
 ;end select
END GO
