CREATE PROGRAM cn_ident_invld_prefs:dba
 DECLARE logfilename = vc WITH constant(build("cer_temp:corrupt_pref_log.csv"))
 DECLARE sout = vc WITH noconstant("")
 SELECT INTO value(logfilename)
  FROM name_value_prefs n,
   note_type nt
  PLAN (n
   WHERE n.pvc_name="pvNotes.DefaultNoteType"
    AND n.merge_name="NOTE_TYPE"
    AND cnvtreal(n.pvc_value) != 0.00
    AND n.pvc_value != " ")
   JOIN (nt
   WHERE nt.note_type_id=cnvtreal(n.pvc_value))
  HEAD REPORT
   sout = build(
    "Event Code,Note Type Id,Note Type Description,Update Date and Time,Merge Id,Merge Name,PVC NAME,PVC VALUE"
    ), row 0, col 0,
   sout
  DETAIL
   sout = build(nt.event_cd,",",nt.note_type_id,",",'"',
    nt.note_type_description,'"',",",format(nt.updt_dt_tm,"@SHORTDATETIME"),",",
    n.merge_id,",",n.merge_name,",",n.pvc_name,
    ",",n.pvc_value), row + 1, col 0,
   sout
  WITH nocounter, maxcol = 700, maxrow = 1
 ;end select
 CALL echo(build("   Total number of potentially affected Preferences: ",(curqual - 1)))
 CALL echo(build("   The Output file name: ",logfilename))
END GO
