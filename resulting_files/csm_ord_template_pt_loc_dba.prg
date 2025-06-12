CREATE PROGRAM csm_ord_template_pt_loc:dba
 DECLARE pat_rel_loc_array_size = i4 WITH persistscript
 DECLARE pat_related_loc_cds[1] = f8 WITH persistscript
 SUBROUTINE (csm_ord_e_pt_loc_filter_sub(argument=vc,location=vc) =i4 WITH copy)
   DECLARE level0 = i2 WITH protect, constant(10)
   DECLARE level1 = i2 WITH protect, constant(5)
   DECLARE level2 = i2 WITH protect, constant(0)
   DECLARE loc_array_size = i4 WITH protect, noconstant(0)
   DECLARE stat = i4 WITH protect, noconstant(0)
   DECLARE loc_cd = f8 WITH protect, noconstant(0)
   DECLARE found = i2 WITH protect, noconstant(0)
   SET curecho = level2
   SET msg = fillstring(100," ")
   SET tname = "CSM_ORD_E_PT_LOCATION_FILTER"
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
   SET loc_array_size = 0
   SET stat = memalloc(loc_checks,loc_array_size,"f8")
   IF (location != "<undefined>")
    RECORD opt_location(
      1 cnt = i4
      1 qual[*]
        2 value = vc
        2 display = vc
    )
    SET orig_param = location
    EXECUTE eks_t_parse_list  WITH replace(reply,opt_location)
    FREE SET orig_param
    CALL echorecord(opt_location)
    SET stat = memrealloc(loc_checks,opt_location->cnt,"f8")
    FOR (i = 1 TO opt_location->cnt)
     SET loc_array_size += 1
     SET loc_checks[loc_array_size] = cnvtreal(opt_location->qual[i].value)
    ENDFOR
   ENDIF
   CALL echo(concat("Defining Argument : ",argument),1,level2)
   CALL echo("Location CDs to check for are: ",1,level2)
   FOR (i = 1 TO loc_array_size)
     CALL echo(concat("   Location[",trim(cnvtstring(i)),"]: ",cnvtstring(loc_checks[i])),1,level2)
   ENDFOR
   IF (loc_array_size <= 0)
    CALL echo("Invalid argument or patient locations entered. Returning 0.",1,level0)
    RETURN(0)
   ENDIF
   IF (cnvtupper(argument)="IS")
    FOR (i = 1 TO loc_array_size)
      CALL echo(concat("Currently looking for location cd: ",cnvtstring(loc_checks[i])),1,level1)
      SET ordercnt = size(request->orders,5)
      CALL echo(concat("Number of orders in this packet: ",trim(cnvtstring(ordercnt))),1,level2)
      FOR (i1 = 1 TO ordercnt)
        SET loc_cd = request->orders[i1].pat_location_cd
        CALL get_all_parent_locations(loc_cd)
        CALL echo(concat("Order[",trim(cnvtstring(i1)),"]"),1,level2)
        CALL echo(concat("   Location Cd: ",trim(cnvtstring(loc_cd))),1,level2)
        FOR (j = 1 TO pat_rel_loc_array_size)
          IF ((pat_related_loc_cds[j]=loc_checks[i]))
           CALL echo(concat("Location cd ",trim(cnvtstring(loc_checks[i]))," found on order[",trim(
              cnvtstring(i1)),"]"),1,level1)
           CALL echo(concat("***** End of Evoke Template: ",tname," ****"),1,level1)
           RETURN(100)
          ENDIF
        ENDFOR
      ENDFOR
    ENDFOR
   ENDIF
   IF (cnvtupper(argument)="IS NOT")
    SET ordercnt = size(request->orders,5)
    CALL echo(concat("Number of orders in this packet: ",trim(cnvtstring(ordercnt))),1,level2)
    FOR (i1 = 1 TO ordercnt)
      SET loc_cd = request->orders[i1].pat_location_cd
      CALL get_all_parent_locations(loc_cd)
      CALL echo(concat("Order[",trim(cnvtstring(i1)),"]"),1,level2)
      CALL echo(concat("   Location cd: ",trim(cnvtstring(loc_cd))),1,level2)
      SET found = 0
      FOR (i = 1 TO loc_array_size)
        FOR (j = 1 TO pat_rel_loc_array_size)
         CALL echo(concat("Currently looking for location cd: ",cnvtstring(loc_checks[i])),1,level1)
         IF ((pat_related_loc_cds[j]=loc_checks[i]))
          SET found = 1
          CALL echo(concat("Location cd ",trim(cnvtstring(loc_checks[i]))," found on order[",trim(
             cnvtstring(i1)),"]"),1,level1)
          SET i = loc_array_size
          SET j = pat_rel_loc_array_size
         ENDIF
        ENDFOR
      ENDFOR
      IF (found=0)
       CALL echo("None of the entered locations were found. Returning 100.",1,level1)
       CALL echo(concat("***** End of Evoke Template: ",tname," ****"),1,level1)
       RETURN(100)
      ENDIF
    ENDFOR
    CALL echo("Undesired match found. One or more Patient Locations were found. Exiting template.",1,
     level2)
    CALL echo(concat("***** End of Evoke Template: ",tname," ****"),1,level1)
    RETURN(0)
   ENDIF
   CALL echo("Invalid argument/patient locations entered or no orders qualified. Returning 0.",1,
    level0)
   CALL echo(concat("***** End of Evoke Template: ",tname," ****"),1,level1)
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (csm_ord_l_pt_loc_filter_sub(argument=vc,location=vc) =i4 WITH copy)
   DECLARE level0 = i2 WITH protect, constant(10)
   DECLARE level1 = i2 WITH protect, constant(5)
   DECLARE level2 = i2 WITH protect, constant(0)
   DECLARE loc_array_size = i4 WITH protect, noconstant(0)
   DECLARE stat = i4 WITH protect, noconstant(0)
   DECLARE loc_cd = f8 WITH protect, noconstant(0)
   DECLARE not_fnd_cnt = i4 WITH protect, noconstant(0)
   SET curecho = level2
   SET tname = "CSM_ORD_L_PT_LOCATION_FILTER"
   CALL echo(concat("***** Running LOGIC Template: ",tname," ****"),1,level1)
   SET csmevent = eks_common->event_name
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
   SET msg = fillstring(100," ")
   SET not_fnd_cnt = 0
   SET loc_array_size = 0
   SET stat = memalloc(loc_checks,loc_array_size,"f8")
   SET tinx = 3
   SET cur_ind = curindex
   SET rep_ind = eks_common->event_repeat_index
   SET rep_cnt = eks_common->event_repeat_count
   IF (location != "<undefined>")
    RECORD opt_location(
      1 cnt = i4
      1 qual[*]
        2 value = vc
        2 display = vc
    )
    SET orig_param = location
    EXECUTE eks_t_parse_list  WITH replace(reply,opt_location)
    FREE SET orig_param
    CALL echorecord(opt_location)
    SET stat = memrealloc(loc_checks,opt_location->cnt,"f8")
    FOR (i = 1 TO opt_location->cnt)
     SET loc_array_size += 1
     SET loc_checks[loc_array_size] = cnvtreal(opt_location->qual[i].value)
    ENDFOR
   ENDIF
   CALL echo(concat("Defining Argument : ",argument),1,level2)
   CALL echo("Location CDs to check for are: ",1,level2)
   FOR (i = 1 TO loc_array_size)
     CALL echo(concat("   Location[",trim(cnvtstring(i)),"]: ",cnvtstring(loc_checks[i])),1,level2)
   ENDFOR
   IF (loc_array_size <= 0)
    CALL echo("Invalid argument or patient locations entered. Returning 0.",1,level0)
    RETURN(0)
   ENDIF
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
   SET loc_cd = request->orders[rep_ind].pat_location_cd
   CALL get_all_parent_locations(loc_cd)
   IF (cnvtupper(argument)="IS")
    FOR (i = 1 TO loc_array_size)
      CALL echo(concat("Currently looking for location cd: ",cnvtstring(loc_checks[i])),1,level1)
      CALL echo(concat("Order[",trim(cnvtstring(rep_ind)),"]"),1,level2)
      CALL echo(concat("   Location Cd: ",trim(cnvtstring(loc_cd))),1,level2)
      FOR (j = 1 TO pat_rel_loc_array_size)
        IF ((pat_related_loc_cds[j]=loc_checks[i]))
         CALL echo(concat("Location cd ",trim(cnvtstring(loc_checks[i]))," found on order[",trim(
            cnvtstring(rep_ind)),"]"),1,level1)
         CALL echo(concat("***** End of Logic Template: ",tname," ****"),1,level1)
         RETURN(100)
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   IF (cnvtupper(argument)="IS NOT")
    FOR (i = 1 TO loc_array_size)
      CALL echo(concat("Currently looking for location cd: ",cnvtstring(loc_checks[i])),1,level1)
      CALL echo(concat("Order[",trim(cnvtstring(rep_ind)),"]"),1,level2)
      CALL echo(concat("   Location cd: ",trim(cnvtstring(loc_cd))),1,level2)
      FOR (j = 1 TO pat_rel_loc_array_size)
        IF ((pat_related_loc_cds[j] != loc_checks[i]))
         SET not_fnd_cnt = i
        ELSE
         CALL echo(concat("Location cd ",trim(cnvtstring(loc_checks[i]))," found on order[",trim(
            cnvtstring(rep_ind)),"]"),1,level1)
         CALL echo("Undesired match found. Exiting template.",1,level0)
         CALL echo(concat("***** End of Logic Template: ",tname," ****"),1,level1)
         RETURN(0)
        ENDIF
      ENDFOR
    ENDFOR
    IF (not_fnd_cnt=loc_array_size)
     CALL echo("None of the entered locations were found. Returning 100.",1,level1)
     CALL echo(concat("***** End of Logic Template: ",tname," ****"),1,level1)
     RETURN(100)
    ENDIF
   ENDIF
   CALL echo("Invalid argument or patient locations entered. Returning 0.",1,level0)
   CALL echo(concat("***** End of Logic Template: ",tname," ****"),1,level1)
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (get_all_parent_locations(loc_cd=f8) =null WITH copy)
   DECLARE found = i2 WITH protect, noconstant(0)
   SET pat_rel_loc_array_size = 0
   SET stat = initarray(pat_related_loc_cds,0)
   RECORD ptloc_req(
     1 loc_cd = f8
     1 loc_cdf = vc
   )
   RECORD ptloc_rep(
     1 loc_facility_cd = f8
     1 facility_disp = vc
     1 facility_desc = vc
     1 loc_build_cd = f8
     1 building_disp = vc
     1 building_desc = vc
     1 loc_nurse_unit_cd = f8
     1 unit_disp = vc
     1 unit_desc = vc
     1 loc_room_cd = f8
     1 room_disp = vc
     1 room_desc = vc
     1 bed_cd = f8
     1 bed_disp = vc
     1 bed_desc = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c15
         3 operationstatus = c1
         3 targetobjectname = c15
         3 targetobjectvalue = vc
   )
   SET ptloc_req->loc_cd = loc_cd
   EXECUTE trkcsp_get_loc_hierarchy  WITH replace("REQUEST",ptloc_req), replace("REPLY",ptloc_rep)
   IF ((ptloc_rep->loc_facility_cd != 0))
    SET pat_rel_loc_array_size += 1
    SET stat = memrealloc(pat_related_loc_cds,pat_rel_loc_array_size,"f8")
    SET pat_related_loc_cds[pat_rel_loc_array_size] = ptloc_rep->loc_facility_cd
   ENDIF
   IF ((ptloc_rep->loc_build_cd != 0))
    SET pat_rel_loc_array_size += 1
    SET stat = memrealloc(pat_related_loc_cds,pat_rel_loc_array_size,"f8")
    SET pat_related_loc_cds[pat_rel_loc_array_size] = ptloc_rep->loc_build_cd
   ENDIF
   IF ((ptloc_rep->loc_nurse_unit_cd != 0))
    SET pat_rel_loc_array_size += 1
    SET stat = memrealloc(pat_related_loc_cds,pat_rel_loc_array_size,"f8")
    SET pat_related_loc_cds[pat_rel_loc_array_size] = ptloc_rep->loc_nurse_unit_cd
   ENDIF
   IF ((ptloc_rep->loc_room_cd != 0))
    SET pat_rel_loc_array_size += 1
    SET stat = memrealloc(pat_related_loc_cds,pat_rel_loc_array_size,"f8")
    SET pat_related_loc_cds[pat_rel_loc_array_size] = ptloc_rep->loc_room_cd
   ENDIF
   IF ((ptloc_rep->bed_cd != 0))
    SET pat_rel_loc_array_size += 1
    SET stat = memrealloc(pat_related_loc_cds,pat_rel_loc_array_size,"f8")
    SET pat_related_loc_cds[pat_rel_loc_array_size] = ptloc_rep->bed_cd
   ENDIF
   FOR (pat_array_idx = 1 TO pat_rel_loc_array_size)
     IF ((pat_related_loc_cds[pat_array_idx]=loc_cd))
      SET found = 1
     ENDIF
   ENDFOR
   IF (found=0)
    SET pat_rel_loc_array_size += 1
    SET stat = memrealloc(pat_related_loc_cds,pat_rel_loc_array_size,"f8")
    SET pat_related_loc_cds[pat_rel_loc_array_size] = loc_cd
   ENDIF
 END ;Subroutine
END GO
