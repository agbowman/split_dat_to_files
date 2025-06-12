CREATE PROGRAM cv_get_observation_debug:dba
 SET modify = predeclare
 RECORD reply(
   1 qual[*]
     2 proc_id = f8
     2 order_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 catalog_cd = f8
     2 accession = vc
     2 priority_cd = f8
     2 proc_status_cd = f8
     2 order_physician_id = f8
     2 matched_im_study_id = f8
     2 im_study_id = f8
     2 cv_step[*]
       3 cv_step_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE encounterlistsize = i4 WITH public, noconstant(0)
 DECLARE personlistsize = i4 WITH public, noconstant(0)
 DECLARE orderlistsize = i2 WITH public, noconstant(0)
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE num1 = i4 WITH public, noconstant(0)
 DECLARE num2 = i4 WITH public, noconstant(0)
 DECLARE count = i4 WITH public, noconstant(0)
 DECLARE count1 = i4 WITH public, noconstant(0)
 DECLARE count2 = i4 WITH public, noconstant(0)
 DECLARE stat = i4 WITH public, noconstant(0)
 DECLARE personidclause = vc WITH public, noconstant("1=1")
 DECLARE procidclause = vc WITH public, noconstant("1=1")
 DECLARE accessionclause = vc WITH public, noconstant("1=1")
 DECLARE encntrclause = vc WITH public, noconstant("1=1")
 DECLARE selectitemgiven = i2 WITH public, noconstant(0)
 DECLARE mnemonic_cd = f8 WITH public, noconstant(0.0)
 DECLARE x = i2 WITH public, noconstant(0)
 DECLARE mv = f8 WITH public, noconstant(0.0)
 DECLARE mvu = f8 WITH public, noconstant(0.0)
 DECLARE buffer[60] = c150 WITH public, noconstant(fillstring(150," "))
 IF ((request->relations_only_ind=1))
  IF ((request->link_actrelationship_ind=0)
   AND (request->pertains_actrelationship_ind=0)
   AND (request->encounter_actrelationship_ind=0)
   AND (request->definition_actrelationship_ind=0)
   AND (request->component_actrelationship_ind=0)
   AND (request->responsible_participation_ind=0)
   AND (request->patient_participation_ind=0))
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "F"
 SET encounterlistsize = size(request->encntr_qual,5)
 SET personlistsize = size(request->person_qual,5)
 SET orderlistsize = size(request->proc_qual,5)
 IF ((request->accession != ""))
  SET selectitemgiven = 1
  SET accessionclause = "cv.accession = request->accession"
 ENDIF
 IF (personlistsize != 0)
  SET selectitemgiven = 1
  SET personidclause =
  "expand(num1, 1, personListSize, cv.person_id, request->person_qual[num1]->person_id)"
 ENDIF
 IF (orderlistsize != 0)
  SET selectitemgiven = 1
  SET procidclause = "expand(num2, 1, orderListSize, cv.proc_id, request->proc_qual[num2]->proc_id)"
 ENDIF
 IF (encounterlistsize != 0)
  SET selectitemgiven = 1
  SET encntrclause =
  "expand(num, 1, encounterListSize, cv.encntr_id, request->encntr_qual[num]->encntr_id)"
 ENDIF
 IF (selectitemgiven=0
  AND (request->im_study_id=0))
  GO TO exit_script
 ENDIF
 SET mvu = uar_get_code_by("MEANING",27700,"MVU")
 SET mv = uar_get_code_by("MEANING",27700,"MV")
 SET stat = alterlist(reply->qual,10)
 SELECT INTO "nl:"
  *
  FROM cv_proc cv,
   im_study s,
   im_study_parent_r pr,
   im_study s1,
   order_catalog order_cat,
   code_value_alias cva,
   order_catalog_synonym order_syn,
   cv_steps cvs
  PLAN (cv
   WHERE expand(num2,1,orderlistsize,cv.proc_id,request->proc_qual[num2].proc_id)
    AND (cv.accession=request->accession)
    AND expand(num1,1,personlistsize,cv.person_id,request->person_qual[num1].person_id)
    AND expand(num,1,encounterlistsize,cv.encntr_id,request->encntr_qual[num].encntr_id))
   JOIN (order_syn
   WHERE cv.catalog_cd=order_syn.catalog_cd
    AND (order_syn.mnemonic=request->req_proc_desc)
    AND order_syn.mnemonic_type_cd=mnemonic_cd)
   JOIN (order_cat
   WHERE cv.catalog_cd=order_cat.catalog_cd)
   JOIN (cva
   WHERE ((order_cat.activity_subtype_cd+ 0)=cva.code_value)
    AND (cva.alias=request->modality))
   JOIN (s1
   WHERE s1.orig_entity_id=outerjoin(cv.proc_id)
    AND s1.orig_entity_name="CV_PROC")
   JOIN (pr
   WHERE pr.parent_entity_id=outerjoin(cv.proc_id))
   JOIN (s
   WHERE s.im_study_id=outerjoin(pr.im_study_id)
    AND s.orig_entity_name="CV_PROC")
   JOIN (cvs
   WHERE cvs.proc_id=cv.proc_id)
  ORDER BY cv.proc_id
  HEAD cv.proc_id
   count2 = 0, count = (count+ 1)
   IF (mod(count,10)=1
    AND count > 1)
    stat = alterlist(reply->qual,(count+ 9))
   ENDIF
   reply->qual[count].order_id = cv.order_id, reply->qual[count].proc_id = cv.proc_id, reply->qual[
   count].priority_cd = cv.priority_cd,
   reply->qual[count].proc_status_cd = cv.proc_status_cd, reply->qual[count].accession = cv.accession
   IF (((s.study_state_cd=mv) OR (s.study_state_cd=mvu)) )
    reply->qual[count].matched_im_study_id = s.im_study_id
   ENDIF
   reply->qual[count].im_study_id = s1.im_study_id, reply->qual[count].person_id = cv.person_id,
   reply->qual[count].encntr_id = cv.encntr_id,
   reply->qual[count].catalog_cd = cv.catalog_cd, reply->qual[count].order_physician_id = cv
   .order_physician_id
  DETAIL
   count2 = (count2+ 1), stat = alterlist(reply->qual[count].cv_step,count2), reply->qual[count].
   cv_step[count2].cv_step_id = cvs.cv_step_id
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,count)
#exit_script
 IF (count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
