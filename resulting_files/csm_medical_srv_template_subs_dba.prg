CREATE PROGRAM csm_medical_srv_template_subs:dba
 DECLARE csm_evoke_medicalservices(argument=vc,medical_service1=vc,medical_service2=vc,
  medical_service3=vc,medical_service4=vc,
  medical_service5=vc,medical_service6=vc,medical_service7=vc,medical_service8=vc,medical_service9=vc,
  medical_service10=vc,medical_service11=vc,medical_service12=vc,medical_service13=vc,
  medical_service14=vc,
  medical_service15=vc,medical_service16=vc,medical_service17=vc,medical_service18=vc,
  medical_service19=vc) = i4 WITH copy
 DECLARE csm_logic_medicalservices(argument=vc,medical_service1=vc,medical_service2=vc,
  medical_service3=vc,medical_service4=vc,
  medical_service5=vc,medical_service6=vc,medical_service7=vc,medical_service8=vc,medical_service9=vc,
  medical_service10=vc,medical_service11=vc,medical_service12=vc,medical_service13=vc,
  medical_service14=vc,
  medical_service15=vc,medical_service16=vc,medical_service17=vc,medical_service18=vc,
  medical_service19=vc) = i4 WITH copy
 DECLARE csm_medicalservicesassign(medical_service1=vc,medical_service2=vc,medical_service3=vc,
  medical_service4=vc,medical_service5=vc,
  medical_service6=vc,medical_service7=vc,medical_service8=vc,medical_service9=vc,medical_service10=
  vc,
  medical_service11=vc,medical_service12=vc,medical_service13=vc,medical_service14=vc,
  medical_service15=vc,
  medical_service16=vc,medical_service17=vc,medical_service18=vc,medical_service19=vc) = i4 WITH copy
 SUBROUTINE csm_evoke_medicalservices(argument,medical_service1,medical_service2,medical_service3,
  medical_service4,medical_service5,medical_service6,medical_service7,medical_service8,
  medical_service9,medical_service10,medical_service11,medical_service12,medical_service13,
  medical_service14,medical_service15,medical_service16,medical_service17,medical_service18,
  medical_service19)
   DECLARE level0 = i2 WITH protected, constant(10)
   DECLARE level1 = i2 WITH protected, constant(5)
   DECLARE level2 = i2 WITH protected, constant(0)
   DECLARE i = i4 WITH protected, noconstant(0)
   DECLARE j = i4 WITH protected, noconstant(0)
   DECLARE array_size = i2 WITH protected, noconstant(19)
   DECLARE stat = i4 WITH protected, noconstant(0)
   DECLARE medical_service_code = f8 WITH protected, noconstant(0.0)
   DECLARE msg = vc WITH protected
   DECLARE medservice_name = vc WITH protected
   DECLARE found = i2 WITH protected, noconstant(0)
   DECLARE medicalservice_checks[value(array_size)] = f8 WITH public
   SET csmevent = eks_common->event_name
   SET tname = "CSM_ORD_E_MEDICAL_SERVICE"
   CALL echo(concat("***** Running EVOKE Template: ",tname," ****"),1,level1)
   IF (csmevent != "RESULT_EVENT_CSM")
    CALL echo("Current event is not Result_Event_CSM.",1,level0)
    RETURN(0)
   ENDIF
   IF ("<undefined>" IN (argument))
    SET msg = concat("EKS-E- One or more required parameters are uninstantiated.",
     "  Exiting template.","  Current event: ",eks_common->event_name,"  Template: ",
     tname,"  Module: ",eks_common->cur_module_name)
    SET eksdata->qual[curindex].logging = msg
    CALL echo(msg,1,level0)
    RETURN(0)
   ENDIF
   SET array_size = csm_medicalservicesassign(medical_service1,medical_service2,medical_service3,
    medical_service4,medical_service5,
    medical_service6,medical_service7,medical_service8,medical_service9,medical_service10,
    medical_service11,medical_service12,medical_service13,medical_service14,medical_service15,
    medical_service16,medical_service17,medical_service18,medical_service19)
   SET ordercnt = size(request->orders,5)
   CALL echo(concat("Number of orders in this packet: ",trim(cnvtstring(ordercnt))),1,level2)
   FOR (i = 1 TO ordercnt)
     SET found = 0
     SET medical_service_code = request->orders[i].medical_service_cd
     SET medservice_name = uar_get_code_display(medical_service_code)
     CALL echo(concat("   Medical service cd: ",trim(cnvtstring(medical_service_code,32,2))),1,level2
      )
     CALL echo(concat("   Medical service name: ",trim(medservice_name)),1,level2)
     SET found = locateval(j,1,array_size,medical_service_code,medicalservice_checks[j])
     IF (found > 0)
      IF (cnvtupper(argument)="IS")
       CALL echo("Match found")
       RETURN(100)
      ELSE
       IF (cnvtupper(argument)="IS NOT")
        SET found = 1
       ENDIF
      ENDIF
     ENDIF
     IF (cnvtupper(argument)="IS NOT")
      IF (found=0)
       CALL echo("None of the entered medical services were found. Returning 100.",1,level1)
       CALL echo(concat("***** End of Evoke Template: ",tname," ****"),1,level1)
       RETURN(100)
      ENDIF
     ENDIF
   ENDFOR
   CALL echo("Invalid argument/medical services entered or no orders qualified. Returning 0.",1,
    level0)
   CALL echo(concat("***** End of Evoke Template: ",tname," ****"),1,level1)
   RETURN(0)
 END ;Subroutine
 SUBROUTINE csm_logic_medicalservices(argument,medical_service1,medical_service2,medical_service3,
  medical_service4,medical_service5,medical_service6,medical_service7,medical_service8,
  medical_service9,medical_service10,medical_service11,medical_service12,medical_service13,
  medical_service14,medical_service15,medical_service16,medical_service17,medical_service18,
  medical_service19)
   DECLARE level0 = i2 WITH protected, constant(10)
   DECLARE level1 = i2 WITH protected, constant(5)
   DECLARE level2 = i2 WITH protected, constant(0)
   DECLARE i = i4 WITH protected, noconstant(0)
   DECLARE j = i4 WITH protected, noconstant(0)
   DECLARE k = i4 WITH protected, noconstant(0)
   DECLARE array_size = i2 WITH protected, noconstant(19)
   DECLARE stat = i4 WITH protected, noconstant(0)
   DECLARE medical_service_code = f8 WITH protected, noconstant(0.0)
   DECLARE msg = vc WITH protected
   DECLARE medservice_name = vc WITH protected
   DECLARE medicalservice_checks[value(array_size)] = f8 WITH public
   SET cur_ind = curindex
   SET rep_ind = eks_common->event_repeat_index
   SET rep_cnt = eks_common->event_repeat_count
   SET csmevent = eks_common->event_name
   SET tinx = 3
   SET tname = "CSM_ORD_L_MEDICAL_SERVICE"
   CALL echo(concat("***** Running LOGIC Template: ",tname," ****"),1,level1)
   IF (csmevent != "RESULT_EVENT_CSM")
    CALL echo("Current event is not Result_Event_CSM.",1,level0)
    RETURN(0)
   ENDIF
   IF ("<undefined>" IN (argument))
    SET msg = concat("EKS-E- One or more required parameters are uninstantiated.",
     "  Exiting template.","  Current event: ",eks_common->event_name,"  Template: ",
     tname,"  Module: ",eks_common->cur_module_name)
    SET eksdata->tqual[tinx].qual[curindex].logging = msg
    CALL echo(msg,1,level0)
    RETURN(0)
   ENDIF
   SET array_size = csm_medicalservicesassign(medical_service1,medical_service2,medical_service3,
    medical_service4,medical_service5,
    medical_service6,medical_service7,medical_service8,medical_service9,medical_service10,
    medical_service11,medical_service12,medical_service13,medical_service14,medical_service15,
    medical_service16,medical_service17,medical_service18,medical_service19)
   SET accessionid = request->orders[rep_ind].accession_id
   SET orderid = request->orders[rep_ind].order_id
   SET personid = request->orders[rep_ind].person_id
   SET encntrid = request->orders[rep_ind].encntr_id
   SET eksdata->tqual[tinx].qual[cur_ind].accession_id = accessionid
   SET eksdata->tqual[tinx].qual[cur_ind].order_id = orderid
   SET eksdata->tqual[tinx].qual[cur_ind].encntr_id = encntrid
   SET eksdata->tqual[tinx].qual[cur_ind].person_id = personid
   SET eksdata->tqual[tinx].qual[cur_ind].cnt = - (1)
   CALL echo(concat("Filling out order level data for eksdata[",trim(cnvtstring(cur_ind)),"]"),1,
    level1)
   CALL echo(concat("Accession Id: ",cnvtstring(accessionid,32,2)),1,level2)
   CALL echo(concat("Order Id    : ",cnvtstring(orderid,32,2)),1,level2)
   CALL echo(concat("Encounter Id: ",cnvtstring(encntrid,32,2)),1,level2)
   CALL echo(concat("Person ID   : ",cnvtstring(personid,32,2)),1,level2)
   SET medical_service_code = request->orders[rep_ind].medical_service_cd
   SET medservice_name = uar_get_code_display(medical_service_code)
   CALL echo(concat("   Medical service code: : ",trim(cnvtstring(medical_service_code,32,2))),1,
    level2)
   CALL echo(concat("   Medical service name: : ",trim(medservice_name)),1,level2)
   SET found = locateval(i,1,array_size,medical_service_code,medicalservice_checks[i])
   IF (found > 0)
    IF (cnvtupper(argument)="IS")
     CALL echo("Match found")
     RETURN(100)
    ELSE
     IF (cnvtupper(argument)="IS NOT")
      CALL echo("Match not found")
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (cnvtupper(argument)="IS NOT")
    CALL echo("None of the entered medical services were found. Returning 100.",1,level1)
    CALL echo(concat("***** End of Logic Template: ",tname," ****"),1,level0)
    RETURN(100)
   ENDIF
   CALL echo("Invalid argument/procedures entered or no qualifications made. Returning 0.",1,level1)
   CALL echo(concat("***** End of Logic Template: ",tname," ****"),1,level1)
   RETURN(0)
 END ;Subroutine
 SUBROUTINE csm_medicalservicesassign(medical_service1,medical_service2,medical_service3,
  medical_service4,medical_service5,medical_service6,medical_service7,medical_service8,
  medical_service9,medical_service10,medical_service11,medical_service12,medical_service13,
  medical_service14,medical_service15,medical_service16,medical_service17,medical_service18,
  medical_service19)
   DECLARE stat = i4 WITH protected, noconstant(0)
   DECLARE i = i4 WITH protected, noconstant(0)
   DECLARE service_cnt = i4 WITH protected, noconstant(19)
   DECLARE medical_service_size = i4 WITH protected, noconstant(0)
   DECLARE medicalservice_array[value(service_cnt)] = c100
   SET medicalservice_array[1] = medical_service1
   SET medicalservice_array[2] = medical_service2
   SET medicalservice_array[3] = medical_service3
   SET medicalservice_array[4] = medical_service4
   SET medicalservice_array[5] = medical_service5
   SET medicalservice_array[6] = medical_service6
   SET medicalservice_array[7] = medical_service7
   SET medicalservice_array[8] = medical_service8
   SET medicalservice_array[9] = medical_service9
   SET medicalservice_array[10] = medical_service10
   SET medicalservice_array[11] = medical_service11
   SET medicalservice_array[12] = medical_service12
   SET medicalservice_array[13] = medical_service13
   SET medicalservice_array[14] = medical_service14
   SET medicalservice_array[15] = medical_service15
   SET medicalservice_array[16] = medical_service16
   SET medicalservice_array[17] = medical_service17
   SET medicalservice_array[18] = medical_service18
   SET medicalservice_array[19] = medical_service19
   FOR (i = 1 TO service_cnt)
     IF ((medicalservice_array[i] != "<undefined>"))
      SET stat = uar_eks_codelup(34,nullterm(value(cnvtupper(cnvtalphanum(medicalservice_array[i])))),
       medical_service_code)
      IF (medical_service_code=0)
       SET stat = uar_eks_codelup(34,nullterm(value(cnvtupper(cnvtalphanum(medicalservice_array[i])))
         ),medical_service_code)
      ENDIF
      IF (medical_service_code != 0)
       SET medical_service_size = (medical_service_size+ 1)
       SET medicalservice_checks[value(medical_service_size)] = medical_service_code
      ENDIF
     ENDIF
   ENDFOR
   CALL echo("Medical services cd's to check for are:: ",1,level2)
   FOR (i = 1 TO medical_service_size)
     CALL echo(concat("  Medical service[",trim(cnvtstring(i)),"]: ",cnvtstring(medicalservice_checks
        [i],32,2)),1,level2)
   ENDFOR
   IF (medical_service_size <= 0)
    CALL echo("Invalid argument or medical services entered. Returning 0",1,level0)
    RETURN(0)
   ENDIF
   RETURN(medical_service_size)
 END ;Subroutine
END GO
