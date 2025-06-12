CREATE PROGRAM bhs_rpt_msg_cntr_audit_v2:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Physician Sign-On" = 0,
  "Start Date" = curdate,
  "End Date" = curdate
  WITH outdev, prompt1, prompt2,
  prompt3
 DECLARE dline = vc
 DECLARE phyname = vc
 DECLARE pid = f8
 SELECT INTO  $1
  cep.action_dt_tm, event_id = substring(1,30,cnvtstring(ce.parent_event_id)), p.name_full_formatted,
  ce_catalog_disp = uar_get_code_display(ce.catalog_cd), cep_action_type_disp = uar_get_code_display(
   cep.action_type_cd), ce.event_tag
  FROM ce_event_prsnl cep,
   clinical_event ce,
   person p
  PLAN (cep
   WHERE (cep.action_prsnl_id= $2)
    AND cep.action_dt_tm BETWEEN cnvtdatetime(cnvtdate( $PROMPT2),0) AND cnvtdatetime(cnvtdate(
      $PROMPT3),235959)
    AND cep.valid_until_dt_tm > sysdate)
   JOIN (ce
   WHERE ce.event_id=cep.event_id
    AND ce.valid_until_dt_tm > sysdate)
   JOIN (p
   WHERE p.person_id=ce.person_id)
  ORDER BY ce.parent_event_id
  WITH format(date,";;q"), format, seperator = " "
 ;end select
#end_script
END GO
