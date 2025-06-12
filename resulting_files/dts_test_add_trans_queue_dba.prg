CREATE PROGRAM dts_test_add_trans_queue:dba
 PROMPT
  "Enter a  name/alias for transcriptionist (enter a 'string'): " = " ",
  "Enter a  name/alias for author (enter a 'string'): " = " ",
  "Enter a  name/alias for cosigner (enter a 'string'): " = " ",
  "Enter an alias for document type (enter a 'string'): " = " ",
  "Enter a  contributor system (enter a 'string'): " = " ",
  "Enter an accession number (enter a 'string'): " = " ",
  "Enter an order id (enter a number): " = 0,
  "Enter a  name or mrn or fin for a patient (enter a 'string'): " = " ",
  "Enter a  dictation length (enter a number): " = 0,
  "Enter a  job number (enter a 'string'): " = " ",
  "Enter a  dictation time zone (enter a number): " = 0,
  "Enter a dictation date (eg. '01-JAN-2002' include quotes): " = curdate
 FREE SET request
 RECORD request(
   1 trans_name = c100
   1 author_name = c100
   1 cosign_name = c100
   1 doc_type_alias = c255
   1 contributor_system = c255
   1 contributor_source_cd = f8
   1 accession_nbr = c20
   1 order_id = f8
   1 patient_info = c200
   1 dictation_dt_tm = dq8
   1 dictation_tz = i4
   1 dictation_length = i4
   1 job_nbr = c100
   1 updt_dt_tm = dq8
   1 updt_id = f8
   1 updt_task = i4
   1 updt_cnt = i4
   1 updt_applcix = i4
 )
 SET request->trans_name =  $1
 SET request->author_name =  $2
 SET request->cosign_name =  $3
 SET request->doc_type_alias =  $4
 SET request->contributor_system =  $5
 SET request->accession_nbr =  $6
 SET request->order_id =  $7
 SET request->patient_info =  $8
 SET request->dictation_length =  $9
 SET request->job_nbr =  $10
 SET request->dictation_tz =  $11
 SET request->dictation_dt_tm = cnvtdatetime( $12)
 CALL echo(request->trans_name)
 CALL echo(request->author_name)
 CALL echo(request->cosign_name)
 CALL echo(request->doc_type_alias)
 CALL echo(request->contributor_system)
 CALL echo(request->accession_nbr)
 CALL echo(request->order_id)
 CALL echo(request->dictation_length)
 CALL echo(request->patient_info)
 CALL echo(request->job_nbr)
 CALL echo(request->dictation_tz)
 CALL echo(cnvtdatetime(request->dictation_dt_tm))
 EXECUTE dts_add_upd_trans_queue
 COMMIT
END GO
