CREATE PROGRAM afc_run_custom:dba
 EXECUTE crmrtl
 EXECUTE srvrtl
 FREE SET reply
 RECORD reply(
   1 t01_qual = i2
   1 t01_recs[*]
     2 t01_id = f8
     2 t01_charge_item_id = f8
     2 t01_interfaced = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD outputlist(
   1 ol_fqual = i2
   1 ol_frecs[*]
     2 ol_file_num = i2
     2 ol_file_name = c80
     2 ol_file_id = f8
     2 ol_file_desc = c80
     2 ol_cdm_sched_cd = f8
     2 ol_cpt_sched_cd = f8
     2 ol_mult_bill_code_sched_cd = f8
     2 ol_contributor_system_cd = f8
     2 ol_doc_nbr_cd = f8
     2 ol_hl7_ind = i2
     2 ol_max_ft1 = c5
 )
 SET reply->status_data.status = "F"
 DECLARE prog_exists = i4 WITH protect
 DECLARE script_name = vc WITH protect
 IF (validate(request->ops_date,999)=999)
  EXECUTE cclseclogin
  SET message = nowindow
 ENDIF
 IF (validate(request->batch_selection," ") != " ")
  SET rptrun = 1
  SELECT INTO "nl:"
   FROM interface_file i
   WHERE (i.description=request->batch_selection)
   DETAIL
    stat = alterlist(outputlist->ol_frecs,1), outputlist->ol_frecs[1].ol_file_desc = i.description,
    outputlist->ol_frecs[1].ol_file_name = i.file_name,
    outputlist->ol_frecs[1].ol_file_id = i.interface_file_id, outputlist->ol_frecs[1].ol_cdm_sched_cd
     = i.cdm_sched_cd, outputlist->ol_frecs[1].ol_cpt_sched_cd = i.cpt_sched_cd,
    outputlist->ol_frecs[1].ol_mult_bill_code_sched_cd = i.mult_bill_code_sched_cd, outputlist->
    ol_frecs[1].ol_contributor_system_cd = i.contributor_system_cd, outputlist->ol_frecs[1].
    ol_doc_nbr_cd = i.doc_nbr_cd,
    outputlist->ol_frecs[1].ol_hl7_ind = i.hl7_ind, outputlist->ol_frecs[1].ol_max_ft1 = i.max_ft1,
    outputlist->ol_fqual = 1
   WITH nocounter
  ;end select
  IF ((outputlist->ol_frecs[1].ol_hl7_ind != 0))
   EXECUTE afc_hl7_batch_interface
  ELSE
   SET script_name = concat("AFC_CUSTOM_",cnvtupper(outputlist->ol_frecs[1].ol_file_desc))
   SET prog_exists = checkdic(script_name,"P",0)
   IF (prog_exists > 0)
    EXECUTE value(trim(script_name))
   ELSE
    CALL echo("** Load script could not be found ******")
    CALL echo(build(script_name," script does not exist"))
   ENDIF
  ENDIF
 ELSE
  SET count1 = 0
  SELECT INTO "nl:"
   i.interface_file_id, i.file_name, i.description
   FROM interface_file i
   WHERE i.file_name != "CLIENTBILL"
    AND i.interface_file_id > 0
    AND i.active_ind=1
   DETAIL
    count1 += 1, stat = alterlist(outputlist->ol_frecs,count1), outputlist->ol_frecs[count1].
    ol_file_desc = i.description,
    outputlist->ol_frecs[count1].ol_file_name = i.file_name, outputlist->ol_frecs[count1].ol_file_id
     = i.interface_file_id, outputlist->ol_frecs[count1].ol_cdm_sched_cd = i.cdm_sched_cd,
    outputlist->ol_frecs[count1].ol_cpt_sched_cd = i.cpt_sched_cd, outputlist->ol_frecs[count1].
    ol_mult_bill_code_sched_cd = i.mult_bill_code_sched_cd, outputlist->ol_frecs[count1].
    ol_contributor_system_cd = i.contributor_system_cd,
    outputlist->ol_frecs[count1].ol_doc_nbr_cd = i.doc_nbr_cd, outputlist->ol_frecs[count1].
    ol_hl7_ind = i.hl7_ind, outputlist->ol_frecs[count1].ol_max_ft1 = i.max_ft1,
    outputlist->ol_fqual = count1
   WITH nocounter
  ;end select
  SET rptrun = 0
  FOR (rptrun = 1 TO outputlist->ol_fqual)
    IF ((outputlist->ol_frecs[rptrun].ol_hl7_ind != 0))
     EXECUTE afc_hl7_batch_interface
    ELSE
     SET script_name = concat("AFC_CUSTOM_",cnvtupper(outputlist->ol_frecs[rptrun].ol_file_desc))
     SET prog_exists = checkdic(script_name,"P",0)
     IF (prog_exists > 0)
      EXECUTE value(trim(script_name))
     ELSE
      CALL echo("** Load script could not be found ******")
      CALL echo(build(script_name," script does not exist"))
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 GO TO end_program
#end_program
 COMMIT
 FREE SET outputlist
END GO
