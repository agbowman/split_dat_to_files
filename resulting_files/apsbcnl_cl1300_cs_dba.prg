CREATE PROGRAM apsbcnl_cl1300_cs:dba
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 SET pos = locateval(idx,1,field_cnt,"IDENTIFIER_CODE",label_job_data->fields[idx].name)
 IF (pos > 0)
  SET label_job_data->fields[pos].size = 21
 ENDIF
 SET pos = locateval(idx,1,field_cnt,"IDENTIFIER_TYPE",label_job_data->fields[idx].name)
 IF (pos > 0)
  SET label_job_data->fields[pos].size = 15
 ENDIF
 SET pos = locateval(idx,1,field_cnt,"DOMAIN",label_job_data->fields[idx].name)
 IF (pos > 0)
  SET label_job_data->fields[pos].size = 15
 ENDIF
 SET pos = locateval(idx,1,field_cnt,"IDENTIFIER_DISP",label_job_data->fields[idx].name)
 IF (pos > 0)
  SET label_job_data->fields[pos].size = 40
 ENDIF
 SET label_job_data->job_directory = ""
 SET label_job_data->job_file_suffix = ".job"
 SET label_job_data->format_file_name = "APSBCNL_CL1300_CS.lbl"
 SET label_job_data->printer_name = "LPT1"
 SET label_job_data->copies = 1
 SET printer->flatfile = "NICELABEL"
END GO
