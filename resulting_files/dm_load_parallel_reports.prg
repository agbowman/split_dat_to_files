CREATE PROGRAM dm_load_parallel_reports
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Failed starting dm_load_parallel_reports..."
 DECLARE copy_recsize = i4 WITH protect, noconstant(size(copy_requestin->list_0,5))
 DECLARE req_recsize = i4 WITH protect, noconstant(size(requestin->list_0,5))
 DECLARE rec_idx = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 SET stat = alterlist(copy_requestin->list_0,(copy_recsize+ req_recsize))
 FOR (rec_idx = 1 TO req_recsize)
   SET copy_requestin->list_0[(copy_recsize+ rec_idx)].parent_id = cnvtreal(requestin->list_0[rec_idx
    ].parent_id)
   SET copy_requestin->list_0[(copy_recsize+ rec_idx)].child_id = cnvtreal(requestin->list_0[rec_idx]
    .child_id)
   SET copy_requestin->list_0[(copy_recsize+ rec_idx)].info_domain = requestin->list_0[rec_idx].
   info_domain
   SET copy_requestin->list_0[(copy_recsize+ rec_idx)].info_name = requestin->list_0[rec_idx].
   info_name
   SET copy_requestin->list_0[(copy_recsize+ rec_idx)].id_column = requestin->list_0[rec_idx].
   id_column
   SET copy_requestin->list_0[(copy_recsize+ rec_idx)].multiple_ind = cnvtint(requestin->list_0[
    rec_idx].multiple_ind)
 ENDFOR
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed requestin copy-over: ",errmsg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
#exit_script
END GO
