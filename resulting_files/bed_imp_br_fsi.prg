CREATE PROGRAM bed_imp_br_fsi
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET fsi_request
 RECORD fsi_request(
   1 fsilist[*]
     2 fsi_id = f8
     2 action_flag = i4
     2 fsi_supplier_name = vc
     2 fsi_system_name = vc
     2 adt_ind = i2
     2 order_ind = i2
     2 transcription_ind = i2
     2 result_ind = i2
     2 charge_ind = i2
     2 document_ind = i2
     2 dictation_ind = i2
     2 rli_ind = i2
     2 schedule_ind = i2
     2 phys_mfn_ind = i2
     2 problem_ind = i2
     2 allergy_ind = i2
     2 immun_ind = i2
     2 claims_ind = i2
     2 supply_ind = i2
     2 misc_type_ind = i2
     2 misc_type_desc = vc
 )
 FREE SET fsi_reply
 RECORD fsi_reply(
   1 fsis[*]
     2 br_fsi_id = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE error_msg = vc WITH private
 DECLARE error_flag = vc WITH private
 DECLARE numrows = i4
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET numrows = size(requestin->list_0,5)
 FOR (x = 1 TO numrows)
   SET stat = alterlist(fsi_request->fsilist,x)
   SET fsi_request->fsilist[x].action_flag = 1
   SET fsi_request->fsilist[x].fsi_supplier_name = requestin->list_0[x].supplier
   SET fsi_request->fsilist[x].fsi_system_name = requestin->list_0[x].system
   IF (cnvtupper(requestin->list_0[x].adt)="X")
    SET fsi_request->fsilist[x].adt_ind = 1
   ELSE
    SET fsi_request->fsilist[x].adt_ind = 0
   ENDIF
   IF (cnvtupper(requestin->list_0[x].orders)="X")
    SET fsi_request->fsilist[x].order_ind = 1
   ELSE
    SET fsi_request->fsilist[x].order_ind = 0
   ENDIF
   IF (cnvtupper(requestin->list_0[x].transcription)="X")
    SET fsi_request->fsilist[x].transcription_ind = 1
   ELSE
    SET fsi_request->fsilist[x].transcription_ind = 0
   ENDIF
   IF (cnvtupper(requestin->list_0[x].result)="X")
    SET fsi_request->fsilist[x].result_ind = 1
   ELSE
    SET fsi_request->fsilist[x].result_ind = 0
   ENDIF
   IF (cnvtupper(requestin->list_0[x].charge)="X")
    SET fsi_request->fsilist[x].charge_ind = 1
   ELSE
    SET fsi_request->fsilist[x].charge_ind = 0
   ENDIF
   IF (cnvtupper(requestin->list_0[x].document)="X")
    SET fsi_request->fsilist[x].document_ind = 1
   ELSE
    SET fsi_request->fsilist[x].document_ind = 0
   ENDIF
   IF (cnvtupper(requestin->list_0[x].dictation)="X")
    SET fsi_request->fsilist[x].dictation_ind = 1
   ELSE
    SET fsi_request->fsilist[x].dictation_ind = 0
   ENDIF
   IF (cnvtupper(requestin->list_0[x].rli)="X")
    SET fsi_request->fsilist[x].rli_ind = 1
   ELSE
    SET fsi_request->fsilist[x].rli_ind = 0
   ENDIF
   IF (cnvtupper(requestin->list_0[x].schedule)="X")
    SET fsi_request->fsilist[x].schedule_ind = 1
   ELSE
    SET fsi_request->fsilist[x].schedule_ind = 0
   ENDIF
   IF (cnvtupper(requestin->list_0[x].phys_mfn)="X")
    SET fsi_request->fsilist[x].phys_mfn_ind = 1
   ELSE
    SET fsi_request->fsilist[x].phys_mfn_ind = 0
   ENDIF
   IF (cnvtupper(requestin->list_0[x].problem)="X")
    SET fsi_request->fsilist[x].problem_ind = 1
   ELSE
    SET fsi_request->fsilist[x].problem_ind = 0
   ENDIF
   IF (cnvtupper(requestin->list_0[x].allergy)="X")
    SET fsi_request->fsilist[x].allergy_ind = 1
   ELSE
    SET fsi_request->fsilist[x].allergy_ind = 0
   ENDIF
   IF (cnvtupper(requestin->list_0[x].immunization)="X")
    SET fsi_request->fsilist[x].immun_ind = 1
   ELSE
    SET fsi_request->fsilist[x].immun_ind = 0
   ENDIF
   IF (cnvtupper(requestin->list_0[x].claims)="X")
    SET fsi_request->fsilist[x].claims_ind = 1
   ELSE
    SET fsi_request->fsilist[x].claims_ind = 0
   ENDIF
   IF (cnvtupper(requestin->list_0[x].supply)="X")
    SET fsi_request->fsilist[x].supply_ind = 1
   ELSE
    SET fsi_request->fsilist[x].supply_ind = 0
   ENDIF
   IF (cnvtupper(requestin->list_0[x].misc_type)="X")
    SET fsi_request->fsilist[x].misc_type_ind = 1
    SET fsi_request->fsilist[x].misc_type_desc = requestin->list_0[x].misc_type_description
   ELSE
    SET fsi_request->fsilist[x].misc_type_ind = 0
   ENDIF
 ENDFOR
 SET trace = recpersist
 EXECUTE bed_ens_br_fsi  WITH replace("REQUEST",fsi_request), replace("REPLY",fsi_reply)
 GO TO exit_script
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_BR_FSI","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
