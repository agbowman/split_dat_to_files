CREATE PROGRAM bed_get_mdro_drug_groups:dba
 FREE SET reply
 RECORD reply(
   1 drug_groups[*]
     2 drg_grp_id = f8
     2 name = vc
     2 drugs[*]
       3 drug_code_value = f8
       3 display = vc
       3 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM br_drug_group dg,
   br_drug_group_antibiotic dga,
   code_value cv
  PLAN (dg)
   JOIN (dga
   WHERE dga.br_drug_group_id=dg.br_drug_group_id)
   JOIN (cv
   WHERE cv.code_value=dga.antibiotic_cd
    AND cv.active_ind=1)
  ORDER BY dg.br_drug_group_id, dga.antibiotic_cd
  HEAD dg.br_drug_group_id
   tcnt = (tcnt+ 1), acnt = 0, stat = alterlist(reply->drug_groups,tcnt),
   reply->drug_groups[tcnt].drg_grp_id = dg.br_drug_group_id, reply->drug_groups[tcnt].name = dg
   .drug_group_name
  HEAD dga.antibiotic_cd
   acnt = (acnt+ 1), stat = alterlist(reply->drug_groups[tcnt].drugs,acnt), reply->drug_groups[tcnt].
   drugs[acnt].drug_code_value = dga.antibiotic_cd,
   reply->drug_groups[tcnt].drugs[acnt].display = cv.display, reply->drug_groups[tcnt].drugs[acnt].
   description = cv.description
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
