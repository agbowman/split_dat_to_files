CREATE PROGRAM bed_get_sch_temp_list:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 ilist[*]
     2 import_name = vc
   1 dlist[*]
     2 br_sch_template_id = f8
     2 import_name = vc
     2 template_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 IF ((request->load_import_names_ind=1))
  SELECT DISTINCT INTO "nl:"
   bst.import_name
   FROM br_sch_template bst
   PLAN (bst)
   ORDER BY bst.import_name
   HEAD REPORT
    icnt = 0
   DETAIL
    icnt = (icnt+ 1), stat = alterlist(reply->ilist,icnt), reply->ilist[icnt].import_name = bst
    .import_name
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->load_def_sched_ind=1))
  SET dcnt = 0
  SELECT INTO "nl:"
   FROM br_sch_template bst
   PLAN (bst
    WHERE bst.template_status_flag=0)
   HEAD REPORT
    dcnt = 0
   DETAIL
    dcnt = (dcnt+ 1), stat = alterlist(reply->dlist,dcnt), reply->dlist[dcnt].br_sch_template_id =
    bst.br_sch_template_id,
    reply->dlist[dcnt].import_name = bst.import_name, reply->dlist[dcnt].template_name = bst
    .template_name
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
