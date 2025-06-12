CREATE PROGRAM bbd_get_all_donor_contacts:dba
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 RECORD reply(
   1 qual[*]
     2 contact_id = f8
     2 encntr_id = f8
     2 encntr_updt_cnt = i4
     2 encntr_prsn_r_id = f8
     2 person_reltn_cd = f8
     2 related_person_reltn_cd = f8
     2 encntr_prsn_r_updt_cnt = i4
     2 related_person_id = f8
     2 bbd_procedure_cd = f8
     2 bbd_procedure_cd_disp = c40
     2 bbd_procedure_cd_mean = c12
     2 contact_type_cd = f8
     2 contact_type_cd_disp = vc
     2 contact_type_cd_mean = vc
     2 contact_prsnl_id = f8
     2 contact_outcome_cd = f8
     2 contact_outcome_cd_disp = vc
     2 contact_outcome_cd_mean = vc
     2 contact_dt_tm = di8
     2 needed_dt_tm = di8
     2 contact_status_cd = f8
     2 contact_status_cd_disp = vc
     2 contact_status_cd_mean = vc
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE donate_mean = c12 WITH constant("DONATE")
 DECLARE donate_cd = f8 WITH noconstant(0.0)
 DECLARE recruit_mean = c12 WITH constant("RECRUIT")
 DECLARE recruit_cd = f8 WITH noconstant(0.0)
 DECLARE counsel_mean = c12 WITH constant("COUNSEL")
 DECLARE counsel_cd = f8 WITH noconstant(0.0)
 DECLARE other_mean = c12 WITH constant("OTHER")
 DECLARE other_cd = f8 WITH noconstant(0.0)
 DECLARE script_name = c25 WITH constant("bbd_get_all_donor_contacts")
 DECLARE uar_error = vc WITH noconstant("")
 SET reply->status_data.status = "F"
 SET count = 0
 SET stat = uar_get_meaning_by_codeset(14220,nullterm(donate_mean),1,donate_cd)
 IF (stat=1)
  SET uar_error = concat("Failed to retrieve contact type code with meaning of ",trim(donate_mean),
   ".")
  CALL subevent_add(script_name,"F","uar_get_meaning_by_codeset",uar_error)
  GO TO end_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(14220,nullterm(recruit_mean),1,recruit_cd)
 IF (stat=1)
  SET uar_error = concat("Failed to retrieve contact type code with meaning of ",trim(recruit_mean),
   ".")
  CALL subevent_add(script_name,"F","uar_get_meaning_by_codeset",uar_error)
  GO TO end_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(14220,nullterm(counsel_mean),1,counsel_cd)
 IF (stat=1)
  SET uar_error = concat("Failed to retrieve contact type code with meaning of ",trim(counsel_mean),
   ".")
  CALL subevent_add(script_name,"F","uar_get_meaning_by_codeset",uar_error)
  GO TO end_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(14220,nullterm(other_mean),1,other_cd)
 IF (stat=1)
  SET uar_error = concat("Failed to retrieve contact type code with meaning of ",trim(other_mean),"."
   )
  CALL subevent_add(script_name,"F","uar_get_meaning_by_codeset",uar_error)
  GO TO end_script
 ENDIF
 SELECT INTO "nl:"
  bd.*
  FROM bbd_donor_contact bd,
   encounter e,
   (dummyt d1  WITH seq = 1),
   encntr_person_reltn epr,
   (dummyt d2  WITH seq = 1)
  PLAN (bd
   WHERE (bd.person_id=request->person_id)
    AND bd.active_ind=1
    AND (((request->get_donate_ind=1)
    AND bd.contact_type_cd=donate_cd) OR ((((request->get_recruit_ind=1)
    AND bd.contact_type_cd=recruit_cd) OR ((((request->get_counsel_ind=1)
    AND bd.contact_type_cd=counsel_cd) OR ((request->get_other_ind=1)
    AND bd.contact_type_cd=other_cd)) )) )) )
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (e
   WHERE e.encntr_id > 0
    AND e.encntr_id=bd.encntr_id)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].contact_id = bd
   .contact_id,
   reply->qual[count].encntr_id = bd.encntr_id, reply->qual[count].encntr_updt_cnt = e.updt_cnt,
   reply->qual[count].encntr_prsn_r_id = epr.encntr_person_reltn_id,
   reply->qual[count].encntr_prsn_r_updt_cnt = epr.updt_cnt, reply->qual[count].related_person_id =
   epr.related_person_id, reply->qual[count].person_reltn_cd = epr.person_reltn_cd,
   reply->qual[count].related_person_reltn_cd = epr.related_person_reltn_cd, reply->qual[count].
   bbd_procedure_cd = e.bbd_procedure_cd, reply->qual[count].contact_type_cd = bd.contact_type_cd,
   reply->qual[count].contact_prsnl_id = bd.init_contact_prsnl_id, reply->qual[count].
   contact_outcome_cd = bd.contact_outcome_cd, reply->qual[count].contact_dt_tm = bd.contact_dt_tm,
   reply->qual[count].needed_dt_tm = bd.needed_dt_tm, reply->qual[count].contact_status_cd = bd
   .contact_status_cd, reply->qual[count].updt_cnt = bd.updt_cnt
  WITH nocounter, outerjoin = d1, outerjoin = d2,
   dontcare = epr
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO
