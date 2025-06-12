CREATE PROGRAM ct_mp_clin_trials_summary:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "person_id" = 0.0,
  "therapeutic_ind" = 0
  WITH outdev, person_id, therapeutic_ind
 SET trace = recpersist
 FREE RECORD request
 RECORD request(
   1 person_id = f8
   1 org_id = f8
   1 mrn = vc
   1 show_all_ind = i2
   1 org_security_ind = i2
   1 view_mode = i2
 )
 FREE RECORD data
 RECORD data(
   1 trials[*]
     2 primary_mnemonic = vc
     2 primary_mnemonic_amendment = vc
     2 prot_title = vc
     2 status = vc
     2 on_study_dt_tm = dq8
     2 on_study_date = vc
     2 off_study_dt_tm = dq8
     2 off_study_date = vc
     2 off_treatment_dt_tm = dq8
     2 off_treatment_date = vc
     2 contact_info[*]
       3 person_name = vc
       3 role_name = vc
       3 organization_name = vc
       3 phone_num = vc
       3 pager_num = vc
       3 email_addr = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD eksrequest
 RECORD eksrequest(
   1 source_dir = vc
   1 source_filename = vc
   1 nbrlines = i4
   1 line[*]
     2 linedata = vc
   1 overflowpage[*]
     2 ofr_qual[*]
       3 ofr_line = vc
   1 isblob = c1
   1 document_size = i4
   1 document = gvc
 )
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE qualonesize = i2 WITH protect, noconstant(0)
 DECLARE qualthreesize = i2 WITH protect, noconstant(0)
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE x = i2 WITH protect, noconstant(0)
 DECLARE y = i2 WITH protect, noconstant(0)
 DECLARE idx = i2 WITH protect, noconstant(0)
 DECLARE now = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE amendment_nbr = i2 WITH protect, noconstant(0)
 DECLARE contact_size = i4 WITH private, noconstant(0)
 FREE RECORD reply
 EXECUTE ct_get_org_security
 SET request->org_security_ind = reply->orgsecurityflag
 FREE RECORD reply
 SET request->person_id =  $PERSON_ID
 SET request->show_all_ind = 0
 SET request->view_mode = 0
 EXECUTE ct_get_pt_amd_assgn_history
 SET qualonesize = size(reply->qual_one,5)
 SET stat = alterlist(data->trials,qualonesize)
 FOR (x = 1 TO qualonesize)
   IF (((( $THERAPEUTIC_IND=0)) OR ((reply->qual_one[x].therapeutic_ind=1))) )
    SET cnt += 1
    SET data->trials[cnt].primary_mnemonic = reply->qual_one[x].primary_mnemonic
    SET contact_size = size(reply->qual_one[x].primary_contacts_info,5)
    IF (contact_size > 0)
     SET stat = alterlist(data->trials[cnt].contact_info,contact_size)
     FOR (contact_idx = 1 TO contact_size)
       SET data->trials[cnt].contact_info[contact_idx].person_name = reply->qual_one[x].
       primary_contacts_info[contact_idx].person_name
       SET data->trials[cnt].contact_info[contact_idx].role_name = reply->qual_one[x].
       primary_contacts_info[contact_idx].role_name
       SET data->trials[cnt].contact_info[contact_idx].organization_name = reply->qual_one[x].
       primary_contacts_info[contact_idx].organization_name
       SET data->trials[cnt].contact_info[contact_idx].phone_num = reply->qual_one[x].
       primary_contacts_info[contact_idx].phone_num
       SET data->trials[cnt].contact_info[contact_idx].pager_num = reply->qual_one[x].
       primary_contacts_info[contact_idx].pager_num
       SET data->trials[cnt].contact_info[contact_idx].email_addr = reply->qual_one[x].
       primary_contacts_info[contact_idx].email_addr
     ENDFOR
    ENDIF
    SET data->trials[cnt].on_study_dt_tm = reply->qual_one[x].qual_two[1].on_study_dt_tm
    IF (validate(reply->qual_one[x].qual_two[1].on_study_dt_tm)=1)
     SET data->trials[cnt].on_study_date = build(replace(datetimezoneformat(cnvtdatetime(reply->
         qual_one[x].qual_two[1].on_study_dt_tm),datetimezonebyname("UTC"),"yyyy-MM-dd HH:mm:ss",
        curtimezonedef)," ","T",1),"Z")
    ELSE
     SET data->trials[cnt].on_study_date = ""
    ENDIF
    SET data->trials[cnt].off_study_dt_tm = reply->qual_one[x].qual_two[1].off_study_dt_tm
    IF (validate(reply->qual_one[x].qual_two[1].off_study_dt_tm)=1)
     SET data->trials[cnt].off_study_date = build(replace(datetimezoneformat(cnvtdatetime(reply->
         qual_one[x].qual_two[1].off_study_dt_tm),datetimezonebyname("UTC"),"yyyy-MM-dd HH:mm:ss",
        curtimezonedef)," ","T",1),"Z")
    ELSE
     SET data->trials[cnt].off_study_date = ""
    ENDIF
    IF ((reply->qual_one[x].therapeutic_ind=1))
     SET data->trials[cnt].off_treatment_dt_tm = reply->qual_one[x].qual_two[1].off_treatment_dt_tm
     IF (validate(reply->qual_one[x].qual_two[1].off_treatment_dt_tm)=1)
      SET data->trials[cnt].off_treatment_date = build(replace(datetimezoneformat(cnvtdatetime(reply
          ->qual_one[x].qual_two[1].off_treatment_dt_tm),datetimezonebyname("UTC"),
         "yyyy-MM-dd HH:mm:ss",curtimezonedef)," ","T",1),"Z")
     ELSE
      SET data->trials[cnt].off_treatment_date = ""
     ENDIF
    ELSE
     IF ((now >= data->trials[cnt].off_study_dt_tm))
      SET data->trials[cnt].status = "Off Study"
     ELSE
      SET data->trials[cnt].status = "On Study"
     ENDIF
    ENDIF
    IF ((data->trials[cnt].status=null))
     IF ((now >= data->trials[cnt].off_study_dt_tm))
      SET data->trials[cnt].status = "Off Study"
     ELSEIF ((now >= data->trials[cnt].off_treatment_dt_tm))
      SET data->trials[cnt].status = "On Study/Off Treatment"
     ELSEIF ((now >= data->trials[cnt].on_study_dt_tm))
      SET data->trials[cnt].status = "On Study"
     ENDIF
    ENDIF
    SET qualthreesize = size(reply->qual_one[x].qual_two[1].qual_three,5)
    SET idx = locateval(y,1,qualthreesize,reply->qual_one[x].qual_two[1].off_study_dt_tm,reply->
     qual_one[x].qual_two[1].qual_three[y].assign_end_dt_tm)
    IF (idx > 0)
     SET data->trials[cnt].prot_title = reply->qual_one[x].qual_two[1].qual_three[idx].prot_title
     SET amendment_nbr = reply->qual_one[x].qual_two[1].qual_three[idx].amendment_nbr
     IF (amendment_nbr=0)
      SET data->trials[cnt].primary_mnemonic_amendment = build2(data->trials[cnt].primary_mnemonic,
       " - Initial Protocol")
     ELSE
      SET data->trials[cnt].primary_mnemonic_amendment = build2(data->trials[cnt].primary_mnemonic,
       " - Amendment ",build(amendment_nbr))
     ENDIF
    ELSE
     SET data->trials[cnt].prot_title = reply->qual_one[x].qual_two[1].qual_three[qualthreesize].
     prot_title
     SET amendment_nbr = reply->qual_one[x].qual_two[1].qual_three[qualthreesize].amendment_nbr
     IF (amendment_nbr=0)
      SET data->trials[cnt].primary_mnemonic_amendment = build2(data->trials[cnt].primary_mnemonic,
       " - Initial Protocol")
     ELSE
      SET data->trials[cnt].primary_mnemonic_amendment = build2(data->trials[cnt].primary_mnemonic,
       " - Amendment ",build(amendment_nbr))
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SET stat = alterlist(data->trials,cnt)
 FREE RECORD reply
 SET eksrequest->source_dir =  $OUTDEV
 SET eksrequest->isblob = "1"
 SET eksrequest->document = cnvtrectojson(data)
 SET eksrequest->document_size = size(eksrequest->document,1)
 EXECUTE eks_put_source  WITH replace("REQUEST",eksrequest)
 SET last_mod = "006"
 SET mod_date = "Feb 24, 2017"
 SET trace = norecpersist
END GO
