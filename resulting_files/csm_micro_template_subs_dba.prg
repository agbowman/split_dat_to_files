CREATE PROGRAM csm_micro_template_subs:dba
 DECLARE csm_evoke_microspecimenlogin(argument=vc,login_location=vc) = i4 WITH copy
 DECLARE csm_logic_microspecimenlogin(argument=vc,login_location=vc) = i4 WITH copy
 DECLARE csm_evoke_microservres(argument=vc,service_resource1=vc,service_resource2=vc,
  service_resource3=vc,service_resource4=vc,
  service_resource5=vc,service_resource6=vc,service_resource7=vc,service_resource8=vc,
  service_resource9=vc,
  service_resource10=vc,service_resource11=vc,service_resource12=vc,service_resource13=vc,
  service_resource14=vc,
  service_resource15=vc,service_resource16=vc,service_resource17=vc,service_resource18=vc) = i4 WITH
 copy
 DECLARE csm_logic_microservres(argument=vc,service_resource1=vc,service_resource2=vc,
  service_resource3=vc,service_resource4=vc,
  service_resource5=vc,service_resource6=vc,service_resource7=vc,service_resource8=vc,
  service_resource9=vc,
  service_resource10=vc,service_resource11=vc,service_resource12=vc,service_resource13=vc,
  service_resource14=vc,
  service_resource15=vc,service_resource16=vc,service_resource17=vc,service_resource18=vc) = i4 WITH
 copy
 DECLARE csm_microservresassign(service_resource1=vc,service_resource2=vc,service_resource3=vc,
  service_resource4=vc,service_resource5=vc,
  service_resource6=vc,service_resource7=vc,service_resource8=vc,service_resource9=vc,
  service_resource10=vc,
  service_resource11=vc,service_resource12=vc,service_resource13=vc,service_resource14=vc,
  service_resource15=vc,
  service_resource16=vc,service_resource17=vc,service_resource18=vc) = i4 WITH copy
 RECORD serviceresource(
   1 qual[*]
     2 serv_qual[*]
       3 service_resource_cd = f8
 ) WITH persistscript
 DECLARE getserviceresourcehierarchy(dserviceresourcecd=f8) = i4 WITH copy
 SUBROUTINE getserviceresourcehierarchy(dserviceresourcecd)
   DECLARE mic_get_serv_res_service_resource_type_codeset = i4 WITH protect, constant(223)
   DECLARE mic_get_serv_res_hier_institution_cd = f8 WITH noconstant(0.0), protect
   DECLARE mic_get_serv_res_hier_department_cd = f8 WITH noconstant(0.0), protect
   DECLARE mic_get_serv_res_hier_section_cd = f8 WITH noconstant(0.0), protect
   DECLARE mic_get_serv_res_hier_subsection_cd = f8 WITH noconstant(0.0), protect
   DECLARE dserviceresourcechildtempcd = f8 WITH protected, noconstant(0.0)
   DECLARE lserviceresourcequalsize = i4 WITH protected, noconstant(0)
   DECLARE lserviceresourcequal = i4 WITH protected, noconstant(0)
   DECLARE lserviceresourcequalcnt = i4 WITH protected, noconstant(0)
   DECLARE stat = i4 WITH protected, noconstant(0)
   DECLARE lserviceresourcecnt = i4 WITH protected, noconstant(0)
   DECLARE iindex = i4 WITH protected, noconstant(0)
   DECLARE nmaxserviceresource = i4 WITH protected, constant(200)
   IF ( NOT (mic_get_serv_res_hier_institution_cd > 0.0))
    SET mic_get_serv_res_hier_institution_cd = uar_get_code_by("MEANING",
     mic_get_serv_res_service_resource_type_codeset,"INSTITUTION")
   ENDIF
   IF ( NOT (mic_get_serv_res_hier_department_cd > 0.0))
    SET mic_get_serv_res_hier_department_cd = uar_get_code_by("MEANING",
     mic_get_serv_res_service_resource_type_codeset,"DEPARTMENT")
   ENDIF
   IF ( NOT (mic_get_serv_res_hier_section_cd > 0.0))
    SET mic_get_serv_res_hier_section_cd = uar_get_code_by("MEANING",
     mic_get_serv_res_service_resource_type_codeset,"SECTION")
   ENDIF
   IF ( NOT (mic_get_serv_res_hier_subsection_cd > 0.0))
    SET mic_get_serv_res_hier_subsection_cd = uar_get_code_by("MEANING",
     mic_get_serv_res_service_resource_type_codeset,"SUBSECTION")
   ENDIF
   SET lserviceresourcequal = locateval(iindex,1,size(serviceresource->qual,5),dserviceresourcecd,
    serviceresource->qual[iindex].serv_qual[1].service_resource_cd)
   IF (lserviceresourcequal > 0)
    RETURN(lserviceresourcequal)
   ELSE
    IF (size(serviceresource->qual,5) < nmaxserviceresource)
     SET stat = alterlist(serviceresource->qual,(size(serviceresource->qual,5)+ 1))
    ENDIF
    SET lserviceresourcequal = size(serviceresource->qual,5)
    SET lserviceresourcecnt = 1
    SET stat = alterlist(serviceresource->qual[lserviceresourcequal].serv_qual,lserviceresourcecnt)
    SET serviceresource->qual[lserviceresourcequal].serv_qual[lserviceresourcecnt].
    service_resource_cd = dserviceresourcecd
    SET dserviceresourcechildtempcd = dserviceresourcecd
    WHILE (dserviceresourcechildtempcd > 0)
     SELECT INTO "nl:"
      rg.parent_service_resource_cd
      FROM resource_group rg
      WHERE rg.child_service_resource_cd=dserviceresourcechildtempcd
       AND rg.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       AND rg.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND rg.root_service_resource_cd=0
       AND rg.active_ind=1
       AND rg.resource_group_type_cd IN (mic_get_serv_res_hier_institution_cd,
      mic_get_serv_res_hier_department_cd, mic_get_serv_res_hier_section_cd,
      mic_get_serv_res_hier_subsection_cd)
      DETAIL
       lserviceresourcecnt = (lserviceresourcecnt+ 1), stat = alterlist(serviceresource->qual[
        lserviceresourcequal].serv_qual,lserviceresourcecnt), serviceresource->qual[
       lserviceresourcequal].serv_qual[lserviceresourcecnt].service_resource_cd = rg
       .parent_service_resource_cd,
       dserviceresourcechildtempcd = rg.parent_service_resource_cd
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET dserviceresourcechildtempcd = 0
     ENDIF
    ENDWHILE
    RETURN(lserviceresourcequal)
   ENDIF
 END ;Subroutine
 SUBROUTINE csm_evoke_microspecimenlogin(argument,login_location)
   DECLARE level0 = i2 WITH protected, constant(10)
   DECLARE level1 = i2 WITH protected, constant(5)
   DECLARE level2 = i2 WITH protected, constant(0)
   DECLARE i = i2 WITH protected, noconstant(0)
   DECLARE j = i2 WITH protected, noconstant(0)
   DECLARE stat = i4 WITH protected, noconstant(0)
   DECLARE location_cd = f8 WITH protected, noconstant(0.0)
   DECLARE login_loc_cd = f8 WITH protected, noconstant(0.0)
   DECLARE msg = vc WITH protected
   SET tname = "CSMMB_ORD_E_SPECIMEN_LOGIN"
   SET csmevent = eks_common->event_name
   CALL echo(concat("***** Running EVOKE Template: ",tname," ****"),1,level1)
   IF (csmevent != "RESULT_EVENT_CSM")
    CALL echo("Current event is not Result_Event_CSM.",1,level0)
    RETURN(0)
   ENDIF
   IF ( NOT ((eks_common->request_number IN (275001, 275002, 275065))))
    CALL echo(concat("Template: ",tname,
      "can only be used with Micro Result Requests under Result_Event_CSM. Now exiting."),1,level1)
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
   CALL echo(concat("Defining Argument : ",argument),1,level2)
   CALL echo("Specimen Login Locations to check are: ",1,level2)
   IF (login_location != "<undefined>")
    SET stat = uar_eks_codelup(220,nullterm(value(cnvtupper(cnvtalphanum(login_location)))),
     location_cd)
    IF (location_cd=0)
     SET stat = uar_eks_codelup(220,nullterm(value(cnvtupper(login_location))),location_cd)
    ENDIF
    IF (location_cd != 0)
     CALL echo(concat("Login Location to check : ",cnvtstring(location_cd,32,2)),1,level2)
    ELSE
     CALL echo("Invalid argument or specimen login resources entered. Returning 0.",1,level0)
     RETURN(0)
    ENDIF
   ENDIF
   SET ordercnt = size(request->orders,5)
   CALL echo(concat("Number of orders in this packet: ",trim(cnvtstring(ordercnt))),1,level1)
   FOR (i = 1 TO ordercnt)
     SET login_loc_cd = request->orders[i].specimen_login_loc_cd
     CALL echo(concat("   Login Location cd: ",trim(cnvtstring(login_loc_cd,32,2))),1,level1)
     IF (location_cd=login_loc_cd)
      IF (trim(cnvtupper(argument))="IS")
       CALL echo(concat("Login Location ",login_location," found on order[",trim(cnvtstring(i)),"]"),
        1,level1)
       CALL echo(concat("***** End of Evoke Template: ",tname," ****"),1,level0)
       RETURN(100)
      ELSE
       IF (cnvtupper(argument)="IS NOT")
        CALL echo(concat("No desired specimen login locations matches found for ",login_location),1,
         level0)
        CALL echo(concat("***** End of Evoke Template: ",tname," ****"),1,level0)
        RETURN(0)
       ENDIF
      ENDIF
     ELSE
      IF (cnvtupper(argument)="IS NOT")
       CALL echo(concat("Login Location ",login_location," not found on order[",trim(cnvtstring(i)),
         "]"),1,level1)
       CALL echo(concat("***** End of Evoke Template: ",tname," ****"),1,level0)
       RETURN(100)
      ENDIF
     ENDIF
   ENDFOR
   CALL echo(concat("No desired specimen login locations matches found for",login_location),1,level0)
   CALL echo(concat("***** End of Evoke Template: ",tname," ****"),1,level0)
   RETURN(0)
 END ;Subroutine
 SUBROUTINE csm_logic_microspecimenlogin(argument,login_location)
   DECLARE level0 = i2 WITH protected, constant(10)
   DECLARE level1 = i2 WITH protected, constant(5)
   DECLARE level2 = i2 WITH protected, constant(0)
   DECLARE stat = i4 WITH proctect, noconstant(0)
   DECLARE location_cd = f8 WITH proctect, noconstant(0.0)
   DECLARE login_loc_cd = f8 WITH proctect, noconstant(0.0)
   DECLARE msg = vc WITH protected
   DECLARE location_name = vc WITH protected
   DECLARE num_fnd = i2 WITH protected, noconstant(0)
   DECLARE num_notfnd = i2 WITH protected, noconstant(0)
   SET csmevent = eks_common->event_name
   SET tinx = 3
   SET tname = "CSMMB_ORD_L_SPECIMEN_LOGIN"
   CALL echo(concat("***** Running LOGIC Template: ",tname," ****"),1,level1)
   IF (csmevent != "RESULT_EVENT_CSM")
    CALL echo("Current event is not Result_Event_CSM.",1,level0)
    RETURN(0)
   ENDIF
   IF ( NOT ((eks_common->request_number IN (275001, 275002, 275065))))
    CALL echo(concat("Template: ",tname,
      "can only be used with Micro Result Requests under Result_Event_CSM. Now exiting."),1,level1)
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
   IF (login_location != "<undefined>")
    SET stat = uar_eks_codelup(220,nullterm(value(cnvtupper(cnvtalphanum(login_location)))),
     location_cd)
    IF (location_cd=0)
     SET stat = uar_eks_codelup(220,nullterm(value(cnvtupper(login_location))),location_cd)
    ENDIF
    IF (location_cd != 0)
     CALL echo(concat("Login Location to check : ",cnvtstring(location_cd,32,2)),1,level2)
    ELSE
     CALL echo("Invalid argument or specimen login resources entered. Returning 0.",1,level0)
     RETURN(0)
    ENDIF
   ENDIF
   SET accessionid = request->orders[rep_ind].accession_id
   SET orderid = request->orders[rep_ind].order_id
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
   SET login_loc_code = request->orders[rep_ind].specimen_login_loc_cd
   CALL echo(concat("Login Location cd: ",trim(cnvtstring(login_loc_code,32,2))),1,level1)
   SET location_name = uar_get_code_display(login_loc_code)
   IF (login_loc_code=location_cd)
    IF (cnvtupper(argument)="IS")
     SET num_fnd = (num_fnd+ 1)
     SET stat = alterlist(eksdata->tqual[tinx].qual[cur_ind].data,value(num_fnd))
     SET eksdata->tqual[tinx].qual[cur_ind].data[num_fnd].misc = cnvtstring(num_fnd)
     CALL echo(concat(" Match found on ",trim(location_name)),1,level1)
     SET eksdata->tqual[tinx].qual[cur_ind].cnt = num_fnd
     CALL echo(concat("***** End of Logic Template: ",tname," ****"),1,level1)
     RETURN(100)
    ELSE
     IF (cnvtupper(argument)="IS NOT")
      CALL echo(concat(" Undesired match found on ",trim(location_name)),1,level1)
      CALL echo(concat(" Login Location cd  : ",trim(cnvtstring(login_loc_code,32,2))),1,level1)
      CALL echo(concat("***** End of Logic Template: ",tname," ****"),1,level1)
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    IF (cnvtupper(argument)="IS NOT")
     SET num_notfnd = (num_notfnd+ 1)
     SET stat = alterlist(eksdata->tqual[tinx].qual[cur_ind].data,value(num_notfnd))
     SET eksdata->tqual[tinx].qual[cur_ind].data[num_notfnd].misc = cnvtstring(num_notfnd)
     SET eksdata->tqual[tinx].qual[cur_ind].cnt = num_notfnd
     CALL echo(concat("Number of qualifying Login Locations found: ",trim(cnvtstring(num_fnd))),1,
      level1)
     CALL echo(concat("***** End of Logic Template: ",tname," ****"),1,level1)
     RETURN(100)
    ENDIF
   ENDIF
   CALL echo("Invalid argument/procedures entered or no qualifications made. Returning 0.",1,level1)
   CALL echo(concat("***** End of Logic Template: ",tname," ****"),1,level1)
   RETURN(0)
 END ;Subroutine
 SUBROUTINE csm_evoke_microservres(argument,service_resource1,service_resource2,service_resource3,
  service_resource4,service_resource5,service_resource6,service_resource7,service_resource8,
  service_resource9,service_resource10,service_resource11,service_resource12,service_resource13,
  service_resource14,service_resource15,service_resource16,service_resource17,service_resource18)
   DECLARE level0 = i2 WITH protected, constant(10)
   DECLARE level1 = i2 WITH protected, constant(5)
   DECLARE level2 = i2 WITH protected, constant(0)
   DECLARE i = i4 WITH protected, noconstant(0)
   DECLARE j = i4 WITH protected, noconstant(0)
   DECLARE k = i4 WITH protected, noconstant(0)
   DECLARE array_size = i2 WITH protected, noconstant(18)
   DECLARE stat = i4 WITH protected, noconstant(0)
   DECLARE service_resource_cd = f8 WITH protected, noconstant(0.0)
   DECLARE serviceresource_code = f8 WITH protected, noconstant(0.0)
   DECLARE lserresqual = i4 WITH protected, noconstant(0)
   DECLARE msg = vc WITH protected
   DECLARE resource_name = vc WITH protected
   DECLARE found = i2 WITH protected, noconstant(0)
   DECLARE resource_checks[value(array_size)] = f8 WITH public
   SET csmevent = eks_common->event_name
   SET tname = "CSMMB_ORD_E_SERVICE_RESOURCE"
   CALL echo(concat("***** Running EVOKE Template: ",tname," ****"),1,level1)
   IF (csmevent != "RESULT_EVENT_CSM")
    CALL echo("Current event is not Result_Event_CSM.",1,level0)
    RETURN(0)
   ENDIF
   IF ( NOT ((eks_common->request_number IN (275001, 275002, 275065))))
    CALL echo(concat("Template: ",tname,
      "can only be used with Micro Result Requests under Result_Event_CSM. Now exiting."),1,level1)
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
   SET array_size = csm_microservresassign(service_resource1,service_resource2,service_resource3,
    service_resource4,service_resource5,
    service_resource6,service_resource7,service_resource8,service_resource9,service_resource10,
    service_resource11,service_resource12,service_resource13,service_resource14,service_resource15,
    service_resource16,service_resource17,service_resource18)
   SET ordercnt = size(request->orders,5)
   CALL echo(concat("Number of orders in this packet: ",trim(cnvtstring(ordercnt))),1,level2)
   FOR (i = 1 TO ordercnt)
     SET found = 0
     SET serviceresource_code = request->orders[i].service_resource_cd
     SET resource_name = uar_get_code_display(serviceresource_code)
     CALL echo(concat("   Service Resource cd: ",trim(cnvtstring(serviceresource_code,32,2))),1,
      level2)
     CALL echo(concat("   Service Resource Name: ",trim(resource_name)),1,level2)
     SET lserresqual = getserviceresourcehierarchy(serviceresource_code)
     SET iserrescount = size(serviceresource->qual[lserresqual].serv_qual,5)
     CALL echo(concat("Number of service resources: ",trim(cnvtstring(iserrescount))),1,level1)
     FOR (j = 1 TO array_size)
      CALL echo(concat("Looking for service resource code: ",cnvtstring(resource_checks[j],32,2)),1,
       level1)
      FOR (k = 1 TO iserrescount)
        IF ((serviceresource->qual[lserresqual].serv_qual[k].service_resource_cd=resource_checks[j]))
         IF (cnvtupper(argument)="IS")
          CALL echo(concat("Service Resource code ",trim(cnvtstring(resource_checks[j],32,2)),
            " found on order[",trim(cnvtstring(i)),"]"),1,level1)
          CALL echo(concat("***** End of Evoke Template: ",tname," ****"),1,level1)
          RETURN(100)
         ELSE
          IF (cnvtupper(argument)="IS NOT")
           SET found = 1
           CALL echo(concat("Found Service Resource:",cnvtstring(resource_checks[i],32,2)),1,level1)
           SET j = array_size
          ENDIF
         ENDIF
         CALL echo(concat("Service Resource code: ",trim(cnvtstring(serviceresource->qual[lserresqual
             ].serv_qual[k].service_resource_cd,32,2))),1,level1)
        ENDIF
      ENDFOR
     ENDFOR
     IF (cnvtupper(argument)="IS NOT")
      IF (found=0)
       CALL echo("A MB without a matching Service Resource was found. Returning 100.",1,level1)
       CALL echo(concat("***** End of Evoke Template: ",tname," ****"),1,level1)
       RETURN(100)
      ENDIF
      CALL echo(
       "Undesired match found. One or more Service Resources matched MB Service Resource Exiting template.",
       1,level2)
      CALL echo(concat("***** End of Evoke Template: ",tname," ****"),1,level1)
      RETURN(0)
     ENDIF
   ENDFOR
   CALL echo("Invalid argument/service resources entered or no orders qualified. Returning 0.",1,
    level0)
   CALL echo(concat("***** End of Evoke Template: ",tname," ****"),1,level1)
   RETURN(0)
 END ;Subroutine
 SUBROUTINE csm_logic_microservres(argument,service_resource1,service_resource2,service_resource3,
  service_resource4,service_resource5,service_resource6,service_resource7,service_resource8,
  service_resource9,service_resource10,service_resource11,service_resource12,service_resource13,
  service_resource14,service_resource15,service_resource16,service_resource17,service_resource18)
   DECLARE level0 = i2 WITH protected, constant(10)
   DECLARE level1 = i2 WITH protected, constant(5)
   DECLARE level2 = i2 WITH protected, constant(0)
   DECLARE i = i4 WITH protected, noconstant(0)
   DECLARE j = i4 WITH protected, noconstant(0)
   DECLARE k = i4 WITH protected, noconstant(0)
   DECLARE array_size = i2 WITH protected, noconstant(18)
   DECLARE stat = i4 WITH protected, noconstant(0)
   DECLARE service_resource_cd = f8 WITH protected, noconstant(0.0)
   DECLARE serviceresource_code = f8 WITH protected, noconstant(0.0)
   DECLARE lserresqual = i4 WITH protected, noconstant(0)
   DECLARE msg = vc WITH protected
   DECLARE resource_name = vc WITH protected
   DECLARE found = i2 WITH protected, noconstant(0)
   DECLARE found_cnt = i2 WITH protected, noconstant(0)
   DECLARE num_fnd = i2 WITH protected, noconstant(0)
   DECLARE resource_checks[value(array_size)] = f8 WITH public
   SET cur_ind = curindex
   SET rep_ind = eks_common->event_repeat_index
   SET rep_cnt = eks_common->event_repeat_count
   SET csmevent = eks_common->event_name
   SET tinx = 3
   SET tname = "CSMMB_ORD_L_SERVICE_RESOURCE"
   CALL echo(concat("***** Running LOGIC Template: ",tname," ****"),1,level1)
   IF (csmevent != "RESULT_EVENT_CSM")
    CALL echo("Current event is not Result_Event_CSM.",1,level0)
    RETURN(0)
   ENDIF
   IF ( NOT ((eks_common->request_number IN (275001, 275002, 275065))))
    CALL echo(concat("Template: ",tname,
      "can only be used with Micro Result Requests under Result_Event_CSM. Now exiting."),1,level1)
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
   SET array_size = csm_microservresassign(service_resource1,service_resource2,service_resource3,
    service_resource4,service_resource5,
    service_resource6,service_resource7,service_resource8,service_resource9,service_resource10,
    service_resource11,service_resource12,service_resource13,service_resource14,service_resource15,
    service_resource16,service_resource17,service_resource18)
   SET accessionid = request->orders[rep_ind].accession_id
   SET orderid = request->orders[rep_ind].order_id
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
   SET serviceresource_code = request->orders[rep_ind].service_resource_cd
   CALL echo(concat("Service Resource cd: ",trim(cnvtstring(serviceresource_code,32,2))),1,level1)
   SET resource_name = uar_get_code_display(serviceresource_code)
   CALL echo(concat("   Service Resource cd: ",trim(cnvtstring(serviceresource_code,32,2))),1,level2)
   CALL echo(concat("   Service Resource Name: ",trim(resource_name)),1,level2)
   SET lserresqual = getserviceresourcehierarchy(serviceresource_code)
   SET iserrescount = size(serviceresource->qual[lserresqual].serv_qual,5)
   CALL echo(concat("Number of service resource",trim(cnvtstring(iserrescount))),1,level1)
   FOR (i = 1 TO array_size)
    CALL echo(concat("Looking for service resource code: ",cnvtstring(resource_checks[i],32,2)),1,
     level1)
    FOR (j = 1 TO iserrescount)
      IF ((serviceresource->qual[lserresqual].serv_qual[j].service_resource_cd=resource_checks[i]))
       IF (cnvtupper(argument)="IS")
        SET num_fnd = (num_fnd+ 1)
        SET stat = alterlist(eksdata->tqual[tinx].qual[cur_ind].data,value(num_fnd))
        SET eksdata->tqual[tinx].qual[cur_ind].data[num_fnd].misc = cnvtstring(i)
        SET data_misc = eksdata->tqual[tinx].qual[cur_ind].data[num_fnd].misc
        CALL echo(concat("Match found on ",trim(resource_name),"  EksData[",trim(cnvtstring(cur_ind)),
          "].data[",
          trim(cnvtstring(num_fnd)),"].misc = ",data_misc),1,level1)
        SET eksdata->tqual[tinx].qual[cur_ind].cnt = num_fnd
        CALL echo(concat("***** End of Logic Template: ",tname," ****"),1,level1)
        RETURN(100)
       ELSE
        IF (cnvtupper(argument)="IS NOT")
         SET found = 1
         CALL echo(concat("Undesired match found on ",trim(resource_name)),1,level1)
         CALL echo(concat("Service resource cd  : ",trim(cnvtstring(serviceresource_code,32,2))),1,
          level1)
         SET i = array_size
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ENDFOR
   IF (cnvtupper(argument)="IS NOT")
    IF (found=0)
     SET found_cnt = (found_cnt+ 1)
     SET stat = alterlist(eksdata->tqual[tinx].qual[cur_ind].data,value(found_cnt))
     SET eksdata->tqual[tinx].qual[cur_ind].data[found_cnt].misc = cnvtstring(i)
     SET eksdata->tqual[tinx].qual[cur_ind].cnt = found_cnt
     CALL echo(concat("Number of MBs without matching service resources: ",trim(cnvtstring(found_cnt)
        )),1,level1)
     CALL echo(concat("***** End of Logic Template: ",tname," ****"),1,level1)
     RETURN(100)
    ENDIF
   ENDIF
   CALL echo("Invalid argument/procedures entered or no qualifications made. Returning 0.",1,level1)
   CALL echo(concat("***** End of Logic Template: ",tname," ****"),1,level1)
   RETURN(0)
 END ;Subroutine
 SUBROUTINE csm_microservresassign(service_resource1,service_resource2,service_resource3,
  service_resource4,service_resource5,service_resource6,service_resource7,service_resource8,
  service_resource9,service_resource10,service_resource11,service_resource12,service_resource13,
  service_resource14,service_resource15,service_resource16,service_resource17,service_resource18)
   DECLARE stat = i4 WITH protected, noconstant(0)
   DECLARE i = i4 WITH protected, noconstant(0)
   DECLARE service_cnt = i4 WITH protected, noconstant(18)
   DECLARE res_check_size = i4 WITH protected, noconstant(0)
   DECLARE resource_array[value(service_cnt)] = c100
   SET resource_array[1] = service_resource1
   SET resource_array[2] = service_resource2
   SET resource_array[3] = service_resource3
   SET resource_array[4] = service_resource4
   SET resource_array[5] = service_resource5
   SET resource_array[6] = service_resource6
   SET resource_array[7] = service_resource7
   SET resource_array[8] = service_resource8
   SET resource_array[9] = service_resource9
   SET resource_array[10] = service_resource10
   SET resource_array[11] = service_resource11
   SET resource_array[12] = service_resource12
   SET resource_array[13] = service_resource13
   SET resource_array[14] = service_resource14
   SET resource_array[15] = service_resource15
   SET resource_array[16] = service_resource16
   SET resource_array[17] = service_resource17
   SET resource_array[18] = service_resource18
   FOR (i = 1 TO service_cnt)
     IF ((resource_array[i] != "<undefined>"))
      SET stat = uar_eks_codelup(221,nullterm(value(cnvtupper(cnvtalphanum(resource_array[i])))),
       service_resource_cd)
      IF (service_resource_cd=0)
       SET stat = uar_eks_codelup(221,nullterm(value(cnvtupper(resource_array[i]))),
        service_resource_cd)
      ENDIF
      IF (service_resource_cd != 0)
       SET res_check_size = (res_check_size+ 1)
       SET resource_checks[value(res_check_size)] = service_resource_cd
      ENDIF
     ENDIF
   ENDFOR
   CALL echo("Service Resources to check are: ",1,level2)
   FOR (i = 1 TO res_check_size)
     CALL echo(concat("   Service Resource[",trim(cnvtstring(i)),"]: ",cnvtstring(resource_checks[i],
        32,2)),1,level2)
   ENDFOR
   IF (res_check_size <= 0)
    CALL echo("Invalid argument or service resources entered. Returning 0.",1,level0)
    RETURN(0)
   ENDIF
   RETURN(res_check_size)
 END ;Subroutine
END GO
