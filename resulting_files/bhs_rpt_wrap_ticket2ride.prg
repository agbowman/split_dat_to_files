CREATE PROGRAM bhs_rpt_wrap_ticket2ride
 DECLARE acct_num = vc WITH protect
 SELECT INTO "nl:"
  FROM encntr_alias ea
  PLAN (ea
   WHERE (ea.encntr_id=request->visit[1].encntr_id)
    AND ea.encntr_alias_type_cd=1077)
  ORDER BY ea.alias
  HEAD ea.encntr_id
   acct_num = ea.alias
  WITH nocounter
 ;end select
 EXECUTE bhs_rpt_ticket_to_ride request->output_device, acct_num
END GO
