CREATE PROGRAM bed_get_instr_by_org:dba
 FREE SET reply
 RECORD reply(
   01 mlist[*]
     02 manufacturer = vc
     02 ilist[*]
       03 br_instr_id = f8
       03 imodel = vc
       03 itype = vc
       03 point_of_care_ind = i2
       03 robotics_ind = i2
       03 multiplexor_ind = i2
       03 uni_ind = i2
       03 bi_ind = i2
       03 hq_ind = i2
       03 model_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET mcnt = 0
 SELECT INTO "nl:"
  FROM br_instr_org_reltn bior,
   br_instr bi
  PLAN (bior
   WHERE (bior.organization_id=request->organization_id))
   JOIN (bi
   WHERE bi.br_instr_id=bior.br_instr_id)
  ORDER BY bi.manufacturer, bi.model
  HEAD REPORT
   mcnt = 0
  HEAD bi.manufacturer
   mcnt = (mcnt+ 1), stat = alterlist(reply->mlist,mcnt), reply->mlist[mcnt].manufacturer = bi
   .manufacturer,
   icnt = 0
  DETAIL
   icnt = (icnt+ 1), stat = alterlist(reply->mlist[mcnt].ilist,icnt), reply->mlist[mcnt].ilist[icnt].
   br_instr_id = bi.br_instr_id,
   reply->mlist[mcnt].ilist[icnt].br_instr_org_reltn_id = bi.br_instr_org_reltn_id, reply->mlist[mcnt
   ].ilist[icnt].imodel = bi.model, reply->mlist[mcnt].ilist[icnt].model_disp = bior.model_disp,
   reply->mlist[mcnt].ilist[icnt].itype = bi.type, reply->mlist[mcnt].ilist[icnt].point_of_care_ind
    = bior.poc_ind, reply->mlist[mcnt].ilist[icnt].robotics_ind = bior.robotics_ind,
   reply->mlist[mcnt].ilist[icnt].multiplexor_ind = bior.multiplexor_ind, reply->mlist[mcnt].ilist[
   icnt].uni_ind = bior.uni_ind, reply->mlist[mcnt].ilist[icnt].bi_ind = bior.bi_ind,
   reply->mlist[mcnt].ilist[icnt].hq_ind = bior.hq_ind
  WITH nocounter
 ;end select
 IF (mcnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO
