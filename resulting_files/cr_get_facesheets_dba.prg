CREATE PROGRAM cr_get_facesheets:dba
 RECORD reply(
   1 facesheets[*]
     2 facesheetid = f8
     2 display = vc
     2 data_source_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD pdr_req
 RECORD pdr_req(
   1 action_flag = i4
   1 pm_post_doc_ref_id = f8
   1 document_type_cd = f8
   1 request_number_cd = f8
 )
 CALL echo("*****pm_get_post_doc_ref_reply.inc - 666833*****")
 FREE RECORD pdr_reply
 RECORD pdr_reply(
   1 mode = i2
   1 list[*]
     2 pm_post_doc_ref_id = f8
     2 prev_pm_post_doc_ref_id = f8
     2 process_name = vc
     2 sch_flex_id = f8
     2 request_number_cd = f8
     2 action_object_name = vc
     2 document_object_name = vc
     2 document_type_cd = f8
     2 output_dest_cd = f8
     2 copies_nbr = i4
     2 time_based_ops_ind = i2
     2 time_based_object_name = vc
     2 batch_print_ind = i2
     2 mnemonic = vc
     2 organizations[*]
       3 organization_id = f8
     2 related_person_doc_obj_name = vc
     2 related_person_doc_type_cd = f8
     2 ref_org_doc_obj_name = vc
     2 ref_org_doc_type_cd = f8
     2 primary_care_doc_obj_name = vc
     2 primary_care_doc_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE xr_action_flag = i2 WITH private, constant(5)
 DECLARE facesheetidx = i4 WITH private, noconstant(0)
 DECLARE facesheetcount = i4 WITH private, noconstant(0)
 DECLARE facesheetlocidx = i4 WITH private, noconstant(0)
 SET reply->status_data.status = "F"
 SET pdr_req->action_flag = xr_action_flag
 EXECUTE pm_get_post_doc_ref  WITH replace("REQUEST",pdr_req), replace("REPLY",pdr_reply)
 IF ((pdr_reply->status_data.status != "F"))
  IF (size(pdr_reply->list,5) > 0)
   FOR (facesheetidx = 1 TO size(pdr_reply->list,5))
     IF (checkprg(cnvtupper(trim(pdr_reply->list[facesheetidx].document_object_name,3))) != 0)
      IF (validate(request->facesheetlist)=1)
       IF (((locateval(facesheetlocidx,1,size(request->facesheetlist,5),pdr_reply->list[facesheetidx]
        .pm_post_doc_ref_id,request->facesheetlist[facesheetlocidx].facesheetid)) OR (size(request->
        facesheetlist,5) <= 0)) )
        SET facesheetcount += 1
        SET stat = alterlist(reply->facesheets,facesheetcount)
        SET reply->facesheets[facesheetcount].facesheetid = pdr_reply->list[facesheetidx].
        pm_post_doc_ref_id
        SET reply->facesheets[facesheetcount].display = pdr_reply->list[facesheetidx].process_name
        SET reply->facesheets[facesheetcount].data_source_name = pdr_reply->list[facesheetidx].
        document_object_name
       ENDIF
      ELSE
       SET facesheetcount += 1
       SET stat = alterlist(reply->facesheets,facesheetcount)
       SET reply->facesheets[facesheetcount].facesheetid = pdr_reply->list[facesheetidx].
       pm_post_doc_ref_id
       SET reply->facesheets[facesheetcount].display = pdr_reply->list[facesheetidx].process_name
       SET reply->facesheets[facesheetcount].data_source_name = pdr_reply->list[facesheetidx].
       document_object_name
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  CALL echorecord(pdr_req)
  CALL echorecord(pdr_reply)
  GO TO exit_script
 ENDIF
 IF (size(reply->facesheets,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
 FREE RECORD pdr_req
 FREE RECORD pdr_reply
END GO
