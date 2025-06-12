CREATE PROGRAM ct_get_prot_role:dba
 RECORD reply(
   1 amendment_status_cd = f8
   1 amendment_status_disp = c50
   1 amendment_status_desc = c50
   1 amendment_status_mean = c12
   1 qual[*]
     2 prot_role_id = f8
     2 person_full_name = vc
     2 organization_id = f8
     2 org_name = vc
     2 person_id = f8
     2 prot_role_cd = f8
     2 prot_role_disp = c50
     2 prot_role_desc = c50
     2 prot_role_mean = c12
     2 prot_role_type_cd = f8
     2 prot_role_type_disp = c50
     2 prot_role_type_desc = c50
     2 prot_role_type_mean = c12
     2 position_cd = f8
     2 position_disp = c50
     2 position_desc = c50
     2 position_mean = c12
     2 primary_ind = i2
     2 updt_cnt = i4
   1 primary_contacts_list_ordered[*]
     2 prot_role_id = f8
     2 primary_contact_rank_nbr = i4
     2 contact_person_id = f8
     2 phone_num = vc
     2 pager_num = vc
     2 email_addr = vc
     2 organization_name = vc
     2 role_name = vc
     2 person_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp_contact_request(
   1 protocols[1]
     2 prot_master_id = f8
     2 prot_amendment_id = f8
   1 person_id = f8
 )
 RECORD temp_contact_reply(
   1 contact_info[*]
     2 prot_amendment_id = f8
     2 prot_master_id = f8
     2 person_id = f8
     2 prot_role_id = f8
     2 person_name = vc
     2 role_name = vc
     2 organization_name = vc
     2 phone_num = vc
     2 pager_num = vc
     2 email_addr = vc
     2 alphapager = vc
   1 primary_contacts[*]
     2 primary_contact_info[*]
       3 prot_amendment_id = f8
       3 prot_master_id = f8
       3 person_id = f8
       3 prot_role_id = f8
       3 person_name = vc
       3 role_name = vc
       3 organization_name = vc
       3 phone_num = vc
       3 pager_num = vc
       3 email_addr = vc
       3 alphapager = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE count1 = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SELECT INTO "nl:"
  pa.*
  FROM prot_amendment pa
  WHERE (pa.prot_amendment_id=request->prot_amendment_id)
  DETAIL
   reply->amendment_status_cd = pa.amendment_status_cd, temp_contact_request->protocols[1].
   prot_master_id = pa.prot_master_id, temp_contact_request->protocols[1].prot_amendment_id = request
   ->prot_amendment_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 EXECUTE ct_get_contact_info  WITH replace("REQUEST","TEMP_CONTACT_REQUEST"), replace("REPLY",
  "TEMP_CONTACT_REPLY")
 CALL echorecord(temp_contact_reply)
 SET contact_size = size(temp_contact_reply->primary_contacts,5)
 CALL echo("contact_size primaryContacts")
 CALL echo(contact_size)
 FOR (contact_idx = 1 TO contact_size)
   SET pr_contact_size = size(temp_contact_reply->primary_contacts[contact_idx].primary_contact_info,
    5)
   CALL echo("pr_contact_size")
   CALL echo(pr_contact_size)
   SET stat = alterlist(reply->primary_contacts_list_ordered,pr_contact_size)
   IF (pr_contact_size > 0)
    FOR (indx = 1 TO pr_contact_size)
      SET reply->primary_contacts_list_ordered[indx].prot_role_id = temp_contact_reply->
      primary_contacts[contact_idx].primary_contact_info[indx].prot_role_id
      SET reply->primary_contacts_list_ordered[indx].contact_person_id = temp_contact_reply->
      primary_contacts[contact_idx].primary_contact_info[indx].person_id
      SET reply->primary_contacts_list_ordered[indx].phone_num = temp_contact_reply->
      primary_contacts[contact_idx].primary_contact_info[indx].phone_num
      SET reply->primary_contacts_list_ordered[indx].pager_num = temp_contact_reply->
      primary_contacts[contact_idx].primary_contact_info[indx].pager_num
      SET reply->primary_contacts_list_ordered[indx].organization_name = temp_contact_reply->
      primary_contacts[contact_idx].primary_contact_info[indx].organization_name
      SET reply->primary_contacts_list_ordered[indx].role_name = temp_contact_reply->
      primary_contacts[contact_idx].primary_contact_info[indx].role_name
      SET reply->primary_contacts_list_ordered[indx].email_addr = temp_contact_reply->
      primary_contacts[contact_idx].primary_contact_info[indx].email_addr
      SET reply->primary_contacts_list_ordered[indx].person_name = temp_contact_reply->
      primary_contacts[contact_idx].primary_contact_info[indx].person_name
    ENDFOR
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  pr.person_id, pr.primary_contact_rank_nbr
  FROM prot_role pr
  WHERE (pr.prot_amendment_id=request->prot_amendment_id)
   AND pr.primary_contact_ind=1
   AND pr.end_effective_dt_tm > cnvtdatetime(sysdate)
  ORDER BY pr.primary_contact_rank_nbr
  DETAIL
   FOR (contact_idx = 1 TO contact_size)
     IF (pr_contact_size > 0)
      FOR (indx = 1 TO pr_contact_size)
        IF ((pr.prot_role_id=temp_contact_reply->primary_contacts[contact_idx].primary_contact_info[
        indx].prot_role_id))
         reply->primary_contacts_list_ordered[indx].primary_contact_rank_nbr = pr
         .primary_contact_rank_nbr, BREAK
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.prot_role_id, p.organization_id, p.person_id,
  p.prot_role_cd, p.prot_role_type_cd, p.updt_cnt,
  pr.name_full_formatted
  FROM prot_role p,
   organization o,
   prsnl pr,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1)
  PLAN (p
   WHERE (p.prot_amendment_id=request->prot_amendment_id)
    AND p.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (d1)
   JOIN (o
   WHERE p.organization_id=o.organization_id)
   JOIN (d2)
   JOIN (pr
   WHERE p.person_id=pr.person_id)
  ORDER BY p.prot_role_id
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].prot_role_id = p.prot_role_id, reply->qual[count1].organization_id = p
   .organization_id, reply->qual[count1].org_name = o.org_name,
   reply->qual[count1].person_id = p.person_id, reply->qual[count1].person_full_name = pr
   .name_full_formatted, reply->qual[count1].prot_role_cd = p.prot_role_cd,
   reply->qual[count1].prot_role_type_cd = p.prot_role_type_cd, reply->qual[count1].updt_cnt = p
   .updt_cnt, reply->qual[count1].primary_ind = p.primary_contact_ind,
   reply->qual[count1].position_cd = p.position_cd
  FOOT REPORT
   stat = alterlist(reply->qual,count1)
  WITH dontcare = o, outerjoin = d2, nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL echo(build("status:",reply->status_data.status))
 SET last_mod = "005"
 SET mod_date = "Feb 19, 2018"
END GO
