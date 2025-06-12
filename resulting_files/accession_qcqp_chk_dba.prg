CREATE PROGRAM accession_qcqp_chk:dba
 SET year_ind = 1
 SELECT INTO "nl:"
  a.accession_id, a.accession, a.accession_nbr_check
  FROM accession a
  WHERE a.alpha_prefix IN ("QP", "QC")
  DETAIL
   IF (a.accession_year > 0)
    year_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SET txt = fillstring(100," ")
 IF (year_ind=1)
  SET txt = "QC/QP Accessions defined properly"
 ELSE
  SET txt = "QC/QP Accessions defined with year"
 ENDIF
 IF (validate(request,0))
  SET request->setup_proc[1].success_ind = year_ind
  SET request->setup_proc[1].error_msg = txt
  EXECUTE dm_add_upt_setup_proc_log
 ELSE
  CALL echo(build(txt," (status: ",year_ind,")"))
 ENDIF
END GO
