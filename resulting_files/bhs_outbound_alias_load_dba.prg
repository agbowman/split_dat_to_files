CREATE PROGRAM bhs_outbound_alias_load:dba
 EXECUTE bhs_hlp_csv
 CALL echo(build("Declaring variables..."))
 DECLARE ms_cd_str = vc WITH protect, noconstant(" ")
 DECLARE ms_display_str = vc WITH protect, noconstant(" ")
 DECLARE ms_alias_str = vc WITH protect, noconstant(" ")
 DECLARE ms_temp = vc WITH protect, noconstant(" ")
 DECLARE f_cnt = i4 WITH protect, noconstant(0)
 DECLARE x_cnt = i4 WITH protect, noconstant(0)
 FREE RECORD alias_input
 RECORD alias_input(
   1 qual[*]
     2 mf_code_value = f8
     2 ms_display = vc
     2 ms_outbound_alias_cd = vc
 )
 SET ms_temp = concat(trim(logical("bhscust"),3),":softmed_document_alias.csv")
 SET logical outbound_alias_file ms_temp
 FREE DEFINE rtl
 DEFINE rtl "outbound_alias_file"
 CALL echo(build("Querying information from Softmed File..."))
 SELECT
  r.line
  FROM rtlt r
  HEAD REPORT
   f_cnt = 0
  DETAIL
   f_cnt = (f_cnt+ 1), stat = alterlist(alias_input->qual,f_cnt), stat = getcsvcolumnatindex(r.line,1,
    ms_cd_str,",",","),
   stat = getcsvcolumnatindex(r.line,2,ms_display_str,",",'"'), stat = getcsvcolumnatindex(r.line,3,
    ms_alias_str,",",","), alias_input->qual[f_cnt].mf_code_value = cnvtreal(ms_cd_str),
   alias_input->qual[f_cnt].ms_display = ms_display_str, alias_input->qual[f_cnt].
   ms_outbound_alias_cd = ms_alias_str
  FOOT REPORT
   stat = 0
  WITH nocounter
 ;end select
 CALL echo(build("HELLOcurqual=",curqual))
 CALL echorecord(alias_input)
 IF (curqual <= 0)
  GO TO exit_program
 ENDIF
 CALL echo(build("updating information from Softmed File to outbound code_value table..."))
 IF (curqual=1)
  INSERT  FROM (dummyt d  WITH seq = value(size(alias_input->qual,5))),
    code_value_outbound cvo
   SET cvo.code_set = 72, cvo.alias = alias_input->qual[d.seq].ms_outbound_alias_cd, cvo.code_value
     = alias_input->qual[d.seq].mf_code_value,
    cvo.contributor_source_cd = 689444.00, cvo.updt_dt_tm = sysdate, cvo.updt_id = 99999,
    cvo.updt_task = 99999, cvo.updt_cnt = 1
   PLAN (d)
    JOIN (cvo)
   WITH nocounter
  ;end insert
  CALL echo(build("Updatecurqual=",curqual))
  COMMIT
 ENDIF
#exit_program
 CALL echo(build2("Exiting script ",curprog))
END GO
