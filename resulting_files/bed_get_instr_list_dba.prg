CREATE PROGRAM bed_get_instr_list:dba
 FREE SET reply
 RECORD reply(
   01 mlist[*]
     02 manufacturer = vc
     02 manufacturer_alias = vc
     02 ilist[*]
       03 br_instr_id = f8
       03 imodel = vc
       03 imodel_alias = vc
       03 itype = vc
       03 iproperties = vc
       03 poc_ind = i2
       03 robotics_ind = i2
       03 multiplexor_ind = i2
       03 uni_ind = i2
       03 bi_ind = i2
       03 hq_ind = i2
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
 SET manufacturer = fillstring(100," ")
 SELECT INTO "nl:"
  manufacturer = cnvtupper(bi.manufacturer)
  FROM br_instr bi
  PLAN (bi)
  ORDER BY manufacturer, bi.model
  HEAD REPORT
   mcnt = 0
  HEAD manufacturer
   mcnt = (mcnt+ 1), stat = alterlist(reply->mlist,mcnt), reply->mlist[mcnt].manufacturer = bi
   .manufacturer,
   reply->mlist[mcnt].manufacturer_alias = bi.manufacturer_alias, icnt = 0
  DETAIL
   icnt = (icnt+ 1), stat = alterlist(reply->mlist[mcnt].ilist,icnt), reply->mlist[mcnt].ilist[icnt].
   br_instr_id = bi.br_instr_id,
   reply->mlist[mcnt].ilist[icnt].imodel = bi.model, reply->mlist[mcnt].ilist[icnt].imodel_alias = bi
   .model_alias, reply->mlist[mcnt].ilist[icnt].itype = bi.type,
   reply->mlist[mcnt].ilist[icnt].poc_ind = bi.point_of_care_ind, reply->mlist[mcnt].ilist[icnt].
   robotics_ind = bi.robotics_ind, reply->mlist[mcnt].ilist[icnt].multiplexor_ind = bi
   .multiplexor_ind,
   reply->mlist[mcnt].ilist[icnt].uni_ind = bi.uni_ind, reply->mlist[mcnt].ilist[icnt].bi_ind = bi
   .bi_ind, reply->mlist[mcnt].ilist[icnt].hq_ind = bi.hq_ind
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
