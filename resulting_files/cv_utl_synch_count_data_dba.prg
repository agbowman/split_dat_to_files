CREATE PROGRAM cv_utl_synch_count_data:dba
 PROMPT
  "Please enter dataset name to synchronize (e.g. STS or ACC02)[STS] = " = "STS",
  "Enter the begining date of forms (embedded in quotes e.g 01-JAN-2000) to process = " =
  "01-JAN-2000",
  "Enter the ending date of forms (embedded in quotes e.g 31-DEC-2005) to process = " = "31-DEC-2005"
 RECORD cv_omf_rec(
   1 case_id = f8
 )
 RECORD cv_case_rec(
   1 input_startdatevalue = dq8
   1 input_enddatevalue = dq8
   1 cv_case[*]
     2 cv_case_id = f8
 )
 SET dataset_param = cnvtupper( $1)
 SET cv_case_rec->input_startdatevalue = cnvtdate2( $2,"DD-MMM-YYYY")
 SET cv_case_rec->input_enddatevalue = cnvtdate2( $3,"DD-MMM-YYYY")
 DECLARE case_cnt = i2 WITH public, noconstant(0)
 SELECT INTO "nl:"
  cc.cv_case_id
  FROM cv_dataset cd,
   cv_case_dataset_r ccdr,
   cv_case cc
  PLAN (cd
   WHERE cnvtupper(trim(cd.dataset_internal_name))=dataset_param)
   JOIN (ccdr
   WHERE cd.dataset_id=ccdr.dataset_id)
   JOIN (cc
   WHERE cc.cv_case_id=ccdr.cv_case_id
    AND cc.updt_dt_tm BETWEEN cnvtdatetime(cv_case_rec->input_startdatevalue) AND cnvtdatetime(
    cv_case_rec->input_enddatevalue))
  HEAD REPORT
   case_cnt = 0
  DETAIL
   case_cnt = (case_cnt+ 1), stat = alterlist(cv_case_rec->cv_case,case_cnt), cv_case_rec->cv_case[
   case_cnt].cv_case_id = cc.cv_case_id
  WITH nocounter
 ;end select
 CALL echo(build("case_cnt: ",case_cnt))
 IF (case_cnt=0)
  GO TO exit_script
 ELSE
  FOR (m = 1 TO size(cv_case_rec->cv_case,5))
   SET cv_omf_rec->case_id = cv_case_rec->cv_case[m].cv_case_id
   EXECUTE cv_ins_updt_summary_count
  ENDFOR
 ENDIF
#exit_script
 IF (case_cnt=0)
  CALL echo("No cases meet the input conditions!")
 ELSE
  COMMIT
  CALL echo("cv_count_data table has been updated and action committed!")
 ENDIF
END GO
