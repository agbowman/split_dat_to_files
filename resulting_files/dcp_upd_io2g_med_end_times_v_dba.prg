CREATE PROGRAM dcp_upd_io2g_med_end_times_v:dba
 DECLARE io = f8 WITH protect, noconstant(uar_get_code_by("MEANING",53,"IO"))
 DECLARE cnt = i4 WITH protect, constant(size(request->persons,5))
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = size(request->persons,5)),
   person p,
   ce_intake_output_result cir,
   clinical_event ce
  PLAN (d1)
   JOIN (p
   WHERE (p.person_id=request->persons[d1.seq].person_id)
    AND p.active_ind=1)
   JOIN (cir
   WHERE cir.person_id=p.person_id
    AND cir.io_start_dt_tm >= cnvtdatetime(request->persons[d1.seq].start_dt_tm)
    AND cir.io_start_dt_tm < cnvtdatetime(request->persons[d1.seq].end_dt_tm)
    AND cir.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
    AND cir.io_type_flag=1)
   JOIN (ce
   WHERE (ce.event_id=(cir.event_id+ 0))
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
    AND ce.event_class_cd=io)
  ORDER BY cir.person_id, cir.event_id
  HEAD cir.person_id
   CALL echo("******************************************************************"),
   CALL echo(cnvtupper(trim(p.name_full_formatted,3))),
   CALL echo("******************************************************************"),
   CALL echo("EVENT_ID                IO_START_DT_TM        IO_END_DT_TM"),
   CALL echo("----------------------  --------------------  --------------------")
  HEAD cir.event_id
   CALL echo(concat(format(cir.event_id,"####################.#;LT(2)"),"  ",format(cir
     .io_start_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"),"  ",format(cir.io_end_dt_tm,
     "DD-MMM-YYYY HH:MM:SS;;D")))
  WITH nocounter
 ;end select
#exit_program
END GO
