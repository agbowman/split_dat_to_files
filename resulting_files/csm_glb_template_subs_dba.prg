CREATE PROGRAM csm_glb_template_subs:dba
 DECLARE csm_ord_evoke_physician_filter(argument=vc,physician=vc) = i4 WITH copy
 DECLARE csm_ord_logic_physician_filter(argument=vc,physician=vc) = i4 WITH copy
 SUBROUTINE csm_ord_evoke_physician_filter(argument,physician)
   DECLARE level0 = i2
   DECLARE level1 = i2
   DECLARE level2 = i2
   SET level0 = 10
   SET level1 = 5
   SET level2 = 0
   SET curecho = level2
   SET tname = "CSM_ORD_E_PHYSICIAN_FILTER"
   CALL echo(concat("***** Running EVOKE Template: ",tname," ****"),1,level1)
   SET csmevent = eks_common->event_name
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
   DECLARE array_size = i4
   DECLARE stat = i4
   DECLARE stat2 = i4
   DECLARE code_value = f8
   DECLARE physician_id = f8
   DECLARE phys_id = f8
   DECLARE phys_string = c20
   DECLARE perfrslt_id = f8
   SET msg = fillstring(100," ")
   SET flag = 0
   SET perfrslt_id = 0
   SET array_size = 0
   SET found = 0
   SET stat = memalloc(physician_checks,array_size,"f8")
   IF (physician != "<undefined>")
    RECORD opt_physician(
      1 cnt = i4
      1 qual[*]
        2 value = vc
        2 display = vc
    )
    SET orig_param = physician
    EXECUTE eks_t_parse_list  WITH replace(reply,opt_physician)
    FREE SET orig_param
    CALL echorecord(opt_physician)
    FOR (i = 1 TO opt_physician->cnt)
      SET array_size = (array_size+ 1)
      SET stat = memrealloc(physician_checks,array_size,"f8")
      SET physician_checks[array_size] = cnvtreal(opt_physician->qual[i].value)
    ENDFOR
   ENDIF
   CALL echo(concat("Defining Argument : ",argument),1,level2)
   CALL echo("Physician IDs to check for are: ",1,level2)
   FOR (i = 1 TO array_size)
     CALL echo(concat("   Physician[",trim(cnvtstring(i)),"]: ",cnvtstring(physician_checks[i])),1,
      level2)
   ENDFOR
   IF (cnvtupper(argument)="IS")
    FOR (i = 1 TO array_size)
      CALL echo(concat("Currently looking for physician id: ",cnvtstring(physician_checks[i])),1,
       level1)
      SET ordercnt = size(request->orders,5)
      CALL echo(concat("Number of orders in this packet: ",trim(cnvtstring(ordercnt))),1,level2)
      FOR (i1 = 1 TO ordercnt)
        SET phys_id = request->orders[i1].ord_dr_id
        CALL echo(concat("Order[",trim(cnvtstring(i1)),"]"),1,level2)
        CALL echo(concat("   Physician Id: ",trim(cnvtstring(phys_id))),1,level2)
        IF ((phys_id=physician_checks[i]))
         CALL echo(concat("Physician Id ",trim(cnvtstring(physician_checks[i]))," found on order[",
           trim(cnvtstring(i1)),"]"),1,level1)
         CALL echo(concat("***** End of Evoke Template: ",tname," ****"),1,level1)
         RETURN(100)
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   IF (cnvtupper(argument)="IS NOT")
    SET ordercnt = size(request->orders,5)
    CALL echo(concat("Number of orders in this packet: ",trim(cnvtstring(ordercnt))),1,level2)
    FOR (i1 = 1 TO ordercnt)
      SET phys_id = request->orders[i1].ord_dr_id
      CALL echo(concat("Order[",trim(cnvtstring(i1)),"]"),1,level2)
      CALL echo(concat("   Physician Id: ",trim(cnvtstring(phys_id))),1,level2)
      SET found = 0
      FOR (i = 1 TO array_size)
       CALL echo(concat("Currently looking for physician id: ",cnvtstring(physician_checks[i])),1,
        level1)
       IF ((phys_id=physician_checks[i]))
        SET found = 1
        CALL echo(concat("Physician id ",trim(cnvtstring(physician_checks[i]))," found on order[",
          trim(cnvtstring(i1)),"]"),1,level1)
        SET i = array_size
       ENDIF
      ENDFOR
      IF (found=0)
       CALL echo("None of the entered physicians were found. Returning 100.",1,level1)
       CALL echo(concat("***** End of Evoke Template: ",tname," ****"),1,level1)
       RETURN(100)
      ENDIF
    ENDFOR
    CALL echo("Undesired match found. One or more Physicians were found. Exiting template.",1,level2)
    CALL echo(concat("***** End of Evoke Template: ",tname," ****"),1,level1)
    RETURN(0)
   ENDIF
   CALL echo("Invalid argument/physicians entered or no orders qualified. Returning 0.",1,level0)
   CALL echo(concat("***** End of Evoke Template: ",tname," ****"),1,level1)
   RETURN(0)
 END ;Subroutine
 SUBROUTINE csm_ord_logic_physician_filter(argument,physician)
   DECLARE level0 = i2
   DECLARE level1 = i2
   DECLARE level2 = i2
   SET level0 = 10
   SET level1 = 5
   SET level2 = 0
   SET curecho = level2
   SET tname = "CSM_ORD_L_PHYSICIAN_FILTER"
   CALL echo(concat("***** Running LOGIC Template: ",tname," ****"),1,level1)
   SET csmevent = eks_common->event_name
   DECLARE array_size = i2
   DECLARE stat = i4
   DECLARE stat2 = i4
   DECLARE code_value = f8
   DECLARE physician_id = f8
   DECLARE phys_id = f8
   DECLARE perfrslt_id = f8
   SET msg = fillstring(100," ")
   SET flag = 0
   SET perfrslt_id = 0
   SET array_size = 0
   SET not_fnd_cnt = 0
   SET stat = memalloc(physician_checks,array_size,"f8")
   SET tinx = 3
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
   SET cur_ind = curindex
   SET rep_ind = eks_common->event_repeat_index
   SET rep_cnt = eks_common->event_repeat_count
   IF (physician != "<undefined>")
    RECORD opt_physician(
      1 cnt = i4
      1 qual[*]
        2 value = vc
        2 display = vc
    )
    SET orig_param = physician
    EXECUTE eks_t_parse_list  WITH replace(reply,opt_physician)
    FREE SET orig_param
    CALL echorecord(opt_physician)
    FOR (i = 1 TO opt_physician->cnt)
      SET array_size = (array_size+ 1)
      SET stat = memrealloc(physician_checks,array_size,"f8")
      SET physician_checks[array_size] = cnvtreal(opt_physician->qual[i].value)
    ENDFOR
   ENDIF
   CALL echo(concat("Defining Argument : ",argument),1,level2)
   CALL echo("Physician IDs to check are: ",1,level2)
   FOR (i = 1 TO array_size)
     CALL echo(concat("   Physician[",trim(cnvtstring(i)),"]: ",cnvtstring(physician_checks[i])),1,
      level2)
   ENDFOR
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
   CALL echo(concat("Accession Id: ",cnvtstring(accessionid)),1,level2)
   CALL echo(concat("Order Id    : ",cnvtstring(orderid)),1,level2)
   CALL echo(concat("Encounter Id: ",cnvtstring(encntrid)),1,level2)
   CALL echo(concat("Person ID   : ",cnvtstring(personid)),1,level2)
   IF (cnvtupper(argument)="IS")
    FOR (i = 1 TO array_size)
      CALL echo(concat("Currently looking for physician id: ",cnvtstring(physician_checks[i])),1,
       level1)
      SET ordercnt = size(request->orders,5)
      CALL echo(concat("Number of orders in this packet: ",trim(cnvtstring(ordercnt))),1,level2)
      SET phys_id = request->orders[rep_ind].ord_dr_id
      CALL echo(concat("Order[",trim(cnvtstring(rep_ind)),"]"),1,level2)
      CALL echo(concat("   Physician Id: ",trim(cnvtstring(phys_id))),1,level2)
      IF ((phys_id=physician_checks[i]))
       CALL echo(concat("Physician Id ",trim(cnvtstring(physician_checks[i]))," found on order[",trim
         (cnvtstring(rep_ind)),"]"),1,level1)
       CALL echo(concat("***** End of Logic Template: ",tname," ****"),1,level0)
       RETURN(100)
      ENDIF
    ENDFOR
   ENDIF
   IF (cnvtupper(argument)="IS NOT")
    FOR (i = 1 TO array_size)
      CALL echo(concat("Currently looking for physician id: ",cnvtstring(physician_checks[i])),1,
       level1)
      SET ordercnt = size(request->orders,5)
      CALL echo(concat("Number of orders in this packet: ",trim(cnvtstring(ordercnt))),1,level2)
      SET phys_id = request->orders[rep_ind].ord_dr_id
      CALL echo(concat("Order[",trim(cnvtstring(rep_ind)),"]"),1,level2)
      CALL echo(concat("   Physician Id: ",trim(cnvtstring(phys_id))),1,level2)
      IF ((phys_id != physician_checks[i]))
       SET not_fnd_cnt = (not_fnd_cnt+ 1)
      ELSE
       CALL echo(concat("Physician id ",trim(cnvtstring(physician_checks[i]))," found on order[",trim
         (cnvtstring(rep_ind)),"]"),1,level1)
       CALL echo("Undesired match found. Exiting template.",1,level0)
       CALL echo(concat("***** End of Logic Template: ",tname," ****"),1,level1)
       RETURN(0)
      ENDIF
    ENDFOR
    IF (not_fnd_cnt=array_size)
     CALL echo("None of the entered physicians were found. Returning 100.",1,level1)
     CALL echo(concat("***** End of Logic Template: ",tname," ****"),1,level1)
     RETURN(100)
    ENDIF
   ENDIF
   CALL echo("Invalid argument or physicians entered. Returning 0.",1,level0)
   CALL echo(concat("***** End of Logic Template: ",tname," ****"),1,level1)
   RETURN(0)
 END ;Subroutine
END GO
