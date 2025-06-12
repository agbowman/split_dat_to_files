CREATE PROGRAM csm_ap_template_subs:dba
 DECLARE csm_evoke_apreportpriority(argument=vc,priority1=vc,priority2=vc,priority3=vc,priority4=vc,
  priority5=vc,priority6=vc,priority7=vc,priority8=vc,priority9=vc,
  priority10=vc,priority11=vc,priority12=vc,priority13=vc,priority14=vc,
  priority15=vc,priority16=vc,priority17=vc,priority18=vc,priority19=vc) = i4 WITH copy
 DECLARE csm_logic_apreportpriority(argument=vc,priority1=vc,priority2=vc,priority3=vc,priority4=vc,
  priority5=vc,priority6=vc,priority7=vc,priority8=vc,priority9=vc,
  priority10=vc,priority11=vc,priority12=vc,priority13=vc,priority14=vc,
  priority15=vc,priority16=vc,priority17=vc,priority18=vc,priority19=vc) = i4 WITH copy
 DECLARE csm_apreportpriorityassign(priority1=vc,priority2=vc,priority3=vc,priority4=vc,priority5=vc,
  priority6=vc,priority7=vc,priority8=vc,priority9=vc,priority10=vc,
  priority11=vc,priority12=vc,priority13=vc,priority14=vc,priority15=vc,
  priority16=vc,priority17=vc,priority18=vc,priority19=vc) = i4 WITH copy
 SUBROUTINE csm_evoke_apreportpriority(argument,priority1,priority2,priority3,priority4,priority5,
  priority6,priority7,priority8,priority9,priority10,priority11,priority12,priority13,priority14,
  priority15,priority16,priority17,priority18,priority19)
   DECLARE level0 = i2 WITH protected, constant(10)
   DECLARE level1 = i2 WITH protected, constant(5)
   DECLARE level2 = i2 WITH protected, constant(0)
   DECLARE i = i4 WITH protected, noconstant(0)
   DECLARE j = i4 WITH protected, noconstant(0)
   DECLARE array_size = i2 WITH protected, noconstant(19)
   DECLARE stat = i4 WITH protected, noconstant(0)
   DECLARE case_report_priority_code = f8 WITH protected, noconstant(0.0)
   DECLARE msg = vc WITH protected
   DECLARE priority_name = vc WITH protected
   DECLARE found = i2 WITH protected, noconstant(0)
   DECLARE priority_checks[value(array_size)] = f8 WITH public
   SET csmevent = eks_common->event_name
   SET tname = "CSMAP_CASE_E_RPT_PRIORITY"
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
   SET array_size = csm_apreportpriorityassign(priority1,priority2,priority3,priority4,priority5,
    priority6,priority7,priority8,priority9,priority10,
    priority11,priority12,priority13,priority14,priority15,
    priority16,priority17,priority18,priority19)
   SET ordercnt = size(request->orders,5)
   CALL echo(concat("Number of orders in this packet: ",trim(cnvtstring(ordercnt))),1,level2)
   FOR (i = 1 TO ordercnt)
     SET found = 0
     SET case_report_priority_code = request->orders[i].case_rpt_priority_cd
     SET priority_name = uar_get_code_display(case_report_priority_code)
     CALL echo(concat("   Case report priority cd: ",trim(cnvtstring(case_report_priority_code,32,2))
       ),1,level2)
     CALL echo(concat("    Case report priority name: ",trim(priority_name)),1,level2)
     FOR (j = 1 TO array_size)
      CALL echo(concat("Looking for  case report priority code: ",cnvtstring(priority_checks[j],32,2)
        ),1,level1)
      IF ((case_report_priority_code=priority_checks[i]))
       IF (cnvtupper(argument)="IS")
        CALL echo(concat("Case report priority cd ",trim(cnvtstring(priority_checks[j],32,2)),
          " found on order[",trim(cnvtstring(i)),"]"),1,level1)
        CALL echo(concat("***** End of Logic Template: ",tname," ****"),1,level1)
        RETURN(100)
       ELSE
        IF (cnvtupper(argument)="IS NOT")
         SET found = 1
         CALL echo(concat("Case report priority cd ",trim(cnvtstring(priority_checks[j],32,2)),
           " found on order[",trim(cnvtstring(i)),"]"),1,level1)
         SET j = array_size
        ENDIF
       ENDIF
      ENDIF
     ENDFOR
     IF (cnvtupper(argument)="IS NOT")
      IF (found=0)
       CALL echo("None of the entered case report priorities were found. Returning 100.",1,level1)
       CALL echo(concat("***** End of Evoke Template: ",tname," ****"),1,level1)
       RETURN(100)
      ENDIF
      CALL echo(
       "Undesired match found. One or more case report priorities were found. Exiting template.",1,
       level2)
      CALL echo(concat("***** End of Evoke Template: ",tname," ****"),1,level1)
      RETURN(0)
     ENDIF
   ENDFOR
   CALL echo("Invalid argument/case report priorities entered or no orders qualified. Returning 0.",1,
    level0)
   CALL echo(concat("***** End of Evoke Template: ",tname," ****"),1,level1)
   RETURN(0)
 END ;Subroutine
 SUBROUTINE csm_logic_apreportpriority(argument,priority1,priority2,priority3,priority4,priority5,
  priority6,priority7,priority8,priority9,priority10,priority11,priority12,priority13,priority14,
  priority15,priority16,priority17,priority18,priority19)
   DECLARE level0 = i2 WITH protected, constant(10)
   DECLARE level1 = i2 WITH protected, constant(5)
   DECLARE level2 = i2 WITH protected, constant(0)
   DECLARE i = i4 WITH protected, noconstant(0)
   DECLARE j = i4 WITH protected, noconstant(0)
   DECLARE k = i4 WITH protected, noconstant(0)
   DECLARE array_size = i2 WITH protected, noconstant(19)
   DECLARE stat = i4 WITH protected, noconstant(0)
   DECLARE case_report_priority_code = f8 WITH protected, noconstant(0.0)
   DECLARE msg = vc WITH protected
   DECLARE priority_name = vc WITH protected
   DECLARE priority_checks[value(array_size)] = f8 WITH public
   SET cur_ind = curindex
   SET rep_ind = eks_common->event_repeat_index
   SET rep_cnt = eks_common->event_repeat_count
   SET csmevent = eks_common->event_name
   SET tinx = 3
   SET tname = "CSMAP_CASE_L_RPT_PRIORITY"
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
   SET array_size = csm_apreportpriorityassign(priority1,priority2,priority3,priority4,priority5,
    priority6,priority7,priority8,priority9,priority10,
    priority11,priority12,priority13,priority14,priority15,
    priority16,priority17,priority18,priority19)
   SET accessionid = request->orders[rep_ind].accession_id
   SET orderid = request->orders[rep_ind].case_rpt_order_id
   SET personid = request->orders[rep_ind].person_id
   SET encntrid = request->orders[rep_ind].encntr_id
   SET eksdata->tqual[tinx].qual[cur_ind].accession_id = accessionid
   SET eksdata->tqual[tinx].qual[cur_ind].order_id = orderid
   SET eksdata->tqual[tinx].qual[cur_ind].encntr_id = encntrid
   SET eksdata->tqual[tinx].qual[cur_ind].person_id = personid
   SET eksdata->tqual[tinx].qual[cur_ind].cnt = 0
   CALL echo(concat("Filling out order level data for eksdata[",trim(cnvtstring(cur_ind)),"]"),1,
    level1)
   CALL echo(concat("Accession Id: ",cnvtstring(accessionid,32,2)),1,level2)
   CALL echo(concat("Order Id    : ",cnvtstring(orderid,32,2)),1,level2)
   CALL echo(concat("Encounter Id: ",cnvtstring(encntrid,32,2)),1,level2)
   CALL echo(concat("Person ID   : ",cnvtstring(personid,32,2)),1,level2)
   SET case_report_priority_code = request->orders[rep_ind].case_rpt_priority_cd
   SET priority_name = uar_get_code_display(case_report_priority_code)
   CALL echo(concat("   Case report priority code: : ",trim(cnvtstring(case_report_priority_code,32,2
       ))),1,level2)
   CALL echo(concat("   Case report priority name: : ",trim(casereportpriority_name)),1,level2)
   FOR (i = 1 TO array_size)
    CALL echo(concat("Looking for case report priority code: ",cnvtstring(priority_checks[i],32,2)),1,
     level1)
    IF ((case_report_priority_code=priority_checks[i]))
     IF (cnvtupper(argument)="IS")
      CALL echo(concat("Case report priority cd ",trim(cnvtstring(priority_checks[i],32,2)),
        " found on order[",trim(cnvtstring(rep_ind)),"]"),1,level1)
      CALL echo(concat("***** End of Logic Template: ",tname," ****"),1,level1)
      RETURN(100)
     ELSE
      IF (cnvtupper(argument)="IS NOT")
       CALL echo(concat("Case report priority cd ",trim(cnvtstring(priority_checks[i],32,2)),
         " found on order[",trim(cnvtstring(rep_ind)),"]"),1,level1)
       CALL echo("Undesired match found. Exiting template.",1,level0)
       CALL echo(concat("***** End of Logic Template: ",tname," ****"),1,level1)
       RETURN(0)
      ENDIF
     ENDIF
    ENDIF
   ENDFOR
   IF (cnvtupper(argument)="IS NOT")
    CALL echo("None of the entered priorities were found. Returning 100.",1,level1)
    CALL echo(concat("***** End of Logic Template: ",tname," ****"),1,level0)
    RETURN(100)
   ENDIF
   CALL echo("Invalid argument/procedures entered or no qualifications made. Returning 0.",1,level1)
   CALL echo(concat("***** End of Logic Template: ",tname," ****"),1,level1)
   RETURN(0)
 END ;Subroutine
 SUBROUTINE csm_apreportpriorityassign(priority1,priority2,priority3,priority4,priority5,priority6,
  priority7,priority8,priority9,priority10,priority11,priority12,priority13,priority14,priority15,
  priority16,priority17,priority18,priority19)
   DECLARE stat = i4 WITH protected, noconstant(0)
   DECLARE i = i4 WITH protected, noconstant(0)
   DECLARE priority_cnt = i4 WITH protected, noconstant(19)
   DECLARE priority_check_size = i4 WITH protected, noconstant(0)
   DECLARE priority_array[value(priority_cnt)] = c100
   SET priority_array[1] = priority1
   SET priority_array[2] = priority2
   SET priority_array[3] = priority3
   SET priority_array[4] = priority4
   SET priority_array[5] = priority5
   SET priority_array[6] = priority6
   SET priority_array[7] = priority7
   SET priority_array[8] = priority8
   SET priority_array[9] = priority9
   SET priority_array[10] = priority10
   SET priority_array[11] = priority11
   SET priority_array[12] = priority12
   SET priority_array[13] = priority13
   SET priority_array[14] = priority14
   SET priority_array[15] = priority15
   SET priority_array[16] = priority16
   SET priority_array[17] = priority17
   SET priority_array[18] = priority18
   SET priority_array[19] = priority19
   FOR (i = 1 TO priority_cnt)
     IF ((priority_array[i] != "<undefined>"))
      SET stat = uar_eks_codelup(1905,nullterm(value(cnvtupper(cnvtalphanum(priority_array[i])))),
       case_report_priority_code)
      IF (case_report_priority_code=0)
       SET stat = uar_eks_codelup(1905,nullterm(value(cnvtupper(cnvtalphanum(priority_array[i])))),
        case_report_priority_code)
      ENDIF
      IF (case_report_priority_code != 0)
       SET priority_check_size = (priority_check_size+ 1)
       SET priority_checks[value(priority_check_size)] = case_report_priority_code
      ENDIF
     ENDIF
   ENDFOR
   CALL echo("Case priority cd's to check for are:: ",1,level2)
   FOR (i = 1 TO priority_check_size)
     CALL echo(concat("  Case report priority[",trim(cnvtstring(i)),"]: ",cnvtstring(priority_checks[
        i],32,2)),1,level2)
   ENDFOR
   IF (priority_check_size <= 0)
    CALL echo("Invalid argument or Case report priorities entered. Returning 0",1,level0)
    RETURN(0)
   ENDIF
   RETURN(priority_check_size)
 END ;Subroutine
END GO
