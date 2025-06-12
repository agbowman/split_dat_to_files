CREATE PROGRAM dcp_get_ppr_pos_for_prsnls:dba
 RECORD reply(
   1 qual[*]
     2 prsnl_id = f8
     2 position_cd = f8
     2 ppr_qual[*]
       3 ppr_reltn_id = f8
       3 ppr_cd = f8
       3 ppr_disp = c40
       3 ppr_desc = c60
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE num_of_prsnl = i4 WITH constant(cnvtint(size(request->prsnl_list,5)))
 DECLARE count1 = i4 WITH noconstant
 DECLARE count2 = i4 WITH noconstant
 DECLARE group_order = f8 WITH noconstant
 DECLARE patient_id = f8 WITH noconstant
 SET reply->status_data.status = "F"
 SET patient_id = request->person_id
 SELECT INTO "nl:"
  group_order = request->prsnl_list[d1.seq].prsnl_id
  FROM (dummyt d1  WITH seq = value(num_of_prsnl)),
   prsnl prsnl,
   person_prsnl_reltn ppr
  PLAN (d1)
   JOIN (prsnl
   WHERE (prsnl.person_id=request->prsnl_list[d1.seq].prsnl_id))
   JOIN (ppr
   WHERE ppr.prsnl_person_id=outerjoin(prsnl.person_id)
    AND ppr.person_id=outerjoin(patient_id))
  ORDER BY group_order, ppr.person_prsnl_reltn_id
  HEAD REPORT
   count1 = 0
  HEAD group_order
   count1 = (count1+ 1), count2 = 0
   IF (count1 > size(reply->qual,5))
    stat = alterlist(reply->qual,(count1+ 5))
   ENDIF
   reply->qual[count1].prsnl_id = request->prsnl_list[d1.seq].prsnl_id, reply->qual[count1].
   position_cd = prsnl.position_cd
  DETAIL
   count2 = (count2+ 1), stat = alterlist(reply->qual[count1].ppr_qual,count2), reply->qual[count1].
   ppr_qual[count2].ppr_reltn_id = ppr.person_prsnl_reltn_id,
   reply->qual[count1].ppr_qual[count2].ppr_cd = ppr.person_prsnl_r_cd
  FOOT  group_order
   stat = alterlist(reply->qual[count1].ppr_qual,count2)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,count1)
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
 GO TO exit_script
#exit_script
 SET reply->status_data.subeventstatus.operationname = "Get Person Prsnl Rltn"
 SET reply->status_data.subeventstatus.targetobjectname = "Table: prsnl,person_prsnl_relation"
 SET reply->status_data.subeventstatus.targetobjectvalue = "dcp_get_ppr_pos_for_prsnls.prg"
 IF ((reply->status_data.status="S"))
  SET reply->status_data.subeventstatus.operationstatus = "S"
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.subeventstatus.operationstatus = "Z"
  SET reply->status_data.status = "Z"
 ENDIF
END GO
