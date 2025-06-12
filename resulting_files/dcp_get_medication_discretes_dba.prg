CREATE PROGRAM dcp_get_medication_discretes:dba
 SET modify = predeclare
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[*]
      2 reference_task_id = f8
      2 required_ind = i2
      2 sequence = i4
      2 task_assay_cd = f8
      2 documentation_ind = i2
      2 acknowledge_ind = i2
      2 read_only_ind = i2
      2 ack_look_back_minutes = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD discrete(
   1 qual[*]
     2 reference_task_id = f8
     2 required_ind = i2
     2 sequence = i4
     2 task_assay_cd = f8
     2 documentation_ind = i2
     2 acknowledge_ind = i2
     2 read_only_ind = i2
     2 ack_look_back_minutes = i4
 )
 DECLARE discrete_count = i4 WITH noconstant(0)
 DECLARE stat = f8 WITH noconstant(0.0)
 DECLARE add_count = i4 WITH noconstant(0)
 DECLARE found = i2 WITH noconstant(0)
 DECLARE last_mod = c3 WITH noconstant("")
 DECLARE mod_date = vc WITH noconstant("")
 DECLARE acknow_result_cd = f8 WITH constant(uar_get_code_by("MEANING",4002164,"ACKRESULTMIN"))
 SET reply->status_data.status = "F"
 IF ((request->catalog_cd > 0))
  SET stat = alterlist(request->qual,1)
  SET request->qual[1].catalog_cd = request->catalog_cd
 ENDIF
 SELECT INTO "nl:"
  FROM order_task_xref otx,
   task_discrete_r tdr,
   dta_offset_min dom,
   (dummyt d  WITH seq = value(size(request->qual,5)))
  PLAN (d)
   JOIN (otx
   WHERE (otx.catalog_cd=request->qual[d.seq].catalog_cd))
   JOIN (tdr
   WHERE tdr.reference_task_id=otx.reference_task_id
    AND tdr.active_ind=1)
   JOIN (dom
   WHERE dom.task_assay_cd=outerjoin(tdr.task_assay_cd)
    AND dom.offset_min_type_cd=outerjoin(acknow_result_cd)
    AND dom.active_ind=outerjoin(1))
  ORDER BY d.seq, tdr.sequence, tdr.task_assay_cd
  HEAD REPORT
   count1 = 0
  HEAD tdr.task_assay_cd
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(discrete->qual,(count1+ 9))
   ENDIF
   discrete->qual[count1].reference_task_id = tdr.reference_task_id, discrete->qual[count1].
   required_ind = tdr.required_ind, discrete->qual[count1].task_assay_cd = tdr.task_assay_cd,
   discrete->qual[count1].sequence = tdr.sequence, discrete->qual[count1].documentation_ind = tdr
   .document_ind, discrete->qual[count1].acknowledge_ind = tdr.acknowledge_ind,
   discrete->qual[count1].read_only_ind = tdr.view_only_ind, discrete->qual[count1].
   ack_look_back_minutes = dom.offset_min_nbr
  FOOT REPORT
   stat = alterlist(discrete->qual,count1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
  SET discrete_count = size(discrete->qual,5)
  SET stat = alterlist(reply->qual,discrete_count)
  SET add_count = 1
  SET reply->qual[add_count].reference_task_id = discrete->qual[add_count].reference_task_id
  SET reply->qual[add_count].required_ind = discrete->qual[add_count].required_ind
  SET reply->qual[add_count].task_assay_cd = discrete->qual[add_count].task_assay_cd
  SET reply->qual[add_count].sequence = discrete->qual[add_count].sequence
  SET reply->qual[add_count].documentation_ind = discrete->qual[add_count].documentation_ind
  SET reply->qual[add_count].acknowledge_ind = discrete->qual[add_count].acknowledge_ind
  SET reply->qual[add_count].read_only_ind = discrete->qual[add_count].read_only_ind
  SET reply->qual[add_count].ack_look_back_minutes = discrete->qual[add_count].ack_look_back_minutes
  FOR (o = 2 TO discrete_count)
    SET found = 0
    FOR (i = 1 TO add_count)
      IF ((reply->qual[i].task_assay_cd=discrete->qual[o].task_assay_cd))
       SET found = 1
      ENDIF
    ENDFOR
    IF (found != 1)
     SET add_count = (add_count+ 1)
     SET reply->qual[add_count].reference_task_id = discrete->qual[o].reference_task_id
     SET reply->qual[add_count].required_ind = discrete->qual[o].required_ind
     SET reply->qual[add_count].task_assay_cd = discrete->qual[o].task_assay_cd
     SET reply->qual[add_count].sequence = discrete->qual[o].sequence
     SET reply->qual[add_count].documentation_ind = discrete->qual[o].documentation_ind
     SET reply->qual[add_count].acknowledge_ind = discrete->qual[o].acknowledge_ind
     SET reply->qual[add_count].read_only_ind = discrete->qual[o].read_only_ind
     SET reply->qual[add_count].ack_look_back_minutes = discrete->qual[o].ack_look_back_minutes
    ENDIF
  ENDFOR
  SET stat = alterlist(reply->qual,add_count)
 ENDIF
 FREE RECORD discrete
 SET last_mod = "004"
 SET mod_date = "06/23/2008"
 SET modify = nopredeclare
END GO
