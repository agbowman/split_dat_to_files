CREATE PROGRAM ct_rn_gather_data:dba
 DECLARE rn_start = i4 WITH protect, constant(200)
 DECLARE rn_screen_start = i4 WITH protect, constant(200)
 DECLARE rn_screen_compl = i4 WITH protect, constant(300)
 DECLARE rn_data_ext_success = i4 WITH protect, constant(350)
 DECLARE rn_data_ext_fail = i4 WITH protect, constant(355)
 DECLARE rn_gather_start = i4 WITH protect, constant(400)
 DECLARE rn_gather_compl = i4 WITH protect, constant(500)
 DECLARE rn_send_start = i4 WITH protect, constant(600)
 DECLARE rn_send_compl = i4 WITH protect, constant(700)
 DECLARE rn_forced_compl = i4 WITH protect, constant(900)
 DECLARE rn_completed = i4 WITH protect, constant(1000)
 DECLARE hmsg = i4 WITH protect, constant(0)
 DECLARE insertrnrunactivity(ct_rn_prot_run_id=f8,rn_status=i4) = i2
 SUBROUTINE insertrnrunactivity(ct_rn_prot_run_id,rn_status)
   DECLARE _stat = i4 WITH private, noconstant(0)
   IF (hmsg=0)
    CALL uar_syscreatehandle(hmsg,_stat)
   ENDIF
   INSERT  FROM ct_rn_run_activity ra
    SET ra.ct_rn_run_activity_id = seq(protocol_def_seq,nextval), ra.ct_rn_prot_run_id =
     ct_rn_prot_run_id, ra.status_flag = rn_status,
     ra.updt_dt_tm = cnvtdatetime(curdate,curtime3), ra.updt_id = reqinfo->updt_id, ra.updt_applctx
      = reqinfo->updt_applctx,
     ra.updt_task = reqinfo->updt_task, ra.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET stat = msgwrite(hmsg,"INSERT ACTIVTY ERROR",emsglvl_warn,"Unable to insert Run Activity")
    CALL echo(concat("Unable to insert run activity (",trim(cnvtstring(rn_status)),
      ") for ct_rn_prot_run_id = ",trim(cnvtstring(ct_rn_prot_run_id))))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 IF ( NOT (validate(status_reply,0)))
  RECORD status_reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD pt_data
 RECORD pt_data(
   1 protocols[*]
     2 prot_master_id = f8
     2 mnemonic = vc
     2 run_start_dt_tm = dq8
     2 data_extract_status = vc
     2 person_cnt = i4
     2 gender
       3 male_cnt = i4
       3 female_cnt = i4
       3 other_cnt = i4
     2 age
       3 ranges[*]
         4 range_cnt = i4
       3 unknown_cnt = i4
     2 orgs[*]
       3 org_id = f8
       3 org_name = vc
       3 org_person_cnt = i4
       3 gender
         4 male_cnt = i4
         4 female_cnt = i4
         4 other_cnt = i4
       3 age
         4 ranges[*]
           5 range_cnt = i4
         4 unknown_cnt = i4
 )
 FREE RECORD protocols
 RECORD protocols(
   1 cnt = i4
   1 prots[*]
     2 prot_master_id = f8
     2 ct_rn_prot_run_id = f8
     2 look_back_to_dt_tm = dq8
     2 pt_sent_nbr = i4
     2 run_start_dt_tm = dq8
     2 data_extract_ind = i2
     2 raw_age_str = vc
     2 ages_cnt = i4
     2 ages[*]
       3 agevalue1 = i2
       3 agevalue2 = i2
       3 agevalue1dttm = dq8
       3 agevalue2dttm = dq8
 )
 FREE RECORD excl_facilties
 RECORD excl_facilties(
   1 cnt = i4
   1 facs[*]
     2 id = f8
 )
 IF ( NOT (validate(pref_request,0)))
  RECORD pref_request(
    1 pref_entry = vc
  )
 ENDIF
 IF ( NOT (validate(pref_reply,0)))
  RECORD pref_reply(
    1 pref_value = i4
    1 pref_values[*]
      2 values = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET stat = initrec(pref_reply)
 SET stat = initrec(pref_request)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE output_file = vc WITH constant(concat("cer_temp:ct_rn_data",trim(cnvtstring( $1)),".xml"))
 DECLARE notfound = vc WITH protect, constant("<not_found>")
 DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17901,"PENDING"))
 DECLARE run_group_id = f8 WITH protect, noconstant( $1)
 DECLARE start_dt_time = vc WITH protect, noconstant("")
 DECLARE start_dt_unit = vc WITH protect, noconstant("")
 DECLARE age_range_str = vc WITH protect, noconstant("")
 DECLARE lookbehinddttm = vc WITH protect, noconstant("")
 DECLARE run_start_dt_tm = dq8 WITH protect
 DECLARE data = vc WITH protect, noconstant("")
 DECLARE tempstr = vc WITH protect, noconstant("")
 DECLARE prot_cnt = i2 WITH protect, noconstant(0)
 DECLARE org_cnt = i2 WITH protect, noconstant(0)
 DECLARE idx = i2 WITH protect, noconstant(0)
 DECLARE prot_idx = i2 WITH protect, noconstant(0)
 DECLARE prot_age_idx = i2 WITH protect, noconstant(0)
 DECLARE ar_idx = i2 WITH protect, noconstant(0)
 DECLARE rng_found = i2 WITH protect, noconstant(0)
 DECLARE min_result_val = i2 WITH protect, noconstant(0)
 DECLARE pt_count_str = vc WITH protect, noconstant("")
 DECLARE exclfac_idx = i4 WITH protect, noconstant(0)
 DECLARE excluded_fac = i2 WITH protect, noconstant(0)
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE cur_list_size = i2 WITH protect, noconstant(0)
 DECLARE loaddata(dummy=i2) = i2 WITH protect
 DECLARE buildxml(dummy=i2) = i2 WITH protect
 DECLARE buildxmlgender(xml_str=vc(ref),female_cnt=i4,male_cnt=i4,other_cnt=i4) = i2 WITH protect
 DECLARE buildxmlagerange(xml_str=vc(ref),prot_idx=i4,org_idx=i4) = i2 WITH protect
 DECLARE insertgatherrunactivity(rn_status=i4) = i2 WITH protect
 DECLARE parseagerangestring(null) = i2
 CALL echo("Starting ct_rn_gather_data")
 CALL echo(build2("OUTPUT_FILE = ",output_file))
 SELECT INTO "nl:"
  FROM ct_rn_prot_run pr,
   ct_rn_prot_config pc,
   prot_master pm,
   ct_rn_run_activity ra
  PLAN (pr
   WHERE pr.run_group_id=run_group_id)
   JOIN (pc
   WHERE pc.prot_master_id=pr.prot_master_id
    AND pc.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (pm
   WHERE pm.prot_master_id=pr.prot_master_id)
   JOIN (ra
   WHERE ra.ct_rn_prot_run_id=pr.ct_rn_prot_run_id
    AND ((ra.status_flag=rn_screen_compl) OR (ra.status_flag=rn_screen_start)) )
  ORDER BY pm.prot_master_id, ra.status_flag
  HEAD REPORT
   prot_cnt = 0
  HEAD pm.prot_master_id
   rng_found = 0
  HEAD ra.status_flag
   IF (ra.status_flag=rn_screen_compl
    AND rng_found=0)
    rng_found = 1, start_dt_time = "", start_dt_unit = "",
    lookbehinddttm = "", data = "", prot_cnt = (prot_cnt+ 1)
    IF (mod(prot_cnt,10)=1)
     stat = alterlist(protocols->prots,(prot_cnt+ 9))
    ENDIF
    protocols->prots[prot_cnt].prot_master_id = pr.prot_master_id, protocols->prots[prot_cnt].
    ct_rn_prot_run_id = pr.ct_rn_prot_run_id
    IF (uar_get_code_meaning(pc.rn_protocol_cd)="DATAEXTR")
     protocols->prots[prot_cnt].data_extract_ind = 1,
     CALL echo(concat("SETTING data extract ind = 1 for ",pm.primary_mnemonic))
    ELSE
     protocols->prots[prot_cnt].data_extract_ind = 0,
     CALL echo(concat("SETTING data extract ind = 0 for ",pm.primary_mnemonic))
    ENDIF
    num = 1, tempstr = "", data = pc.config_info,
    CALL echo(build("pc.config_info =",pc.config_info))
    WHILE (tempstr != notfound
     AND num < 1000)
      tempstr = piece(data,"|",num,notfound),
      CALL echo(build("piece",num,"=",tempstr))
      CASE (num)
       OF 4:
        start_dt_time = tempstr
       OF 5:
        start_dt_unit = tempstr
       OF 10:
        age_range_str = tempstr
      ENDCASE
      num = (num+ 1)
    ENDWHILE
    lookbehinddttm = concat("'",start_dt_time,",",start_dt_unit,"'"), protocols->prots[prot_cnt].
    look_back_to_dt_tm = cnvtlookbehind(build(lookbehinddttm),cnvtdatetime(curdate,curtime3)),
    protocols->prots[prot_cnt].raw_age_str = age_range_str
   ELSEIF (ra.status_flag=rn_screen_start)
    run_start_dt_tm = ra.updt_dt_tm
   ENDIF
  FOOT  pm.prot_master_id
   IF (rng_found=1)
    protocols->prots[prot_cnt].run_start_dt_tm = run_start_dt_tm
   ENDIF
  FOOT REPORT
   stat = alterlist(protocols->prots,prot_cnt), protocols->cnt = prot_cnt
  WITH nocounter
 ;end select
 IF (prot_cnt=0)
  CALL echo("No protocols that are ready to be processed.")
  GO TO exit_script
 ENDIF
 SET pref_request->pref_entry = "rn_min_result"
 EXECUTE ct_get_rn_pref  WITH replace("REQUEST_STRUCT","PREF_REQUEST"), replace("REPLY","PREF_REPLY")
 SET min_result_val = pref_reply->pref_value
 SET stat = initrec(pref_reply)
 SET stat = initrec(pref_request)
 SET pref_request->pref_entry = "rn_facility_excl"
 EXECUTE ct_get_rn_pref  WITH replace("REQUEST_STRUCT","PREF_REQUEST"), replace("REPLY","PREF_REPLY")
 SET org_cnt = size(pref_reply->pref_values,5)
 IF ((pref_reply->pref_value > 0))
  SET excl_facilties->cnt = 1
  SET stat = alterlist(excl_facilties->facs,1)
  SET excl_facilties->facs[1].id = cnvtreal(pref_reply->pref_value)
 ELSEIF (org_cnt > 0)
  SET excl_facilties->cnt = org_cnt
  IF (org_cnt > 0)
   SET stat = alterlist(excl_facilties->facs,org_cnt)
  ENDIF
  FOR (idx = 1 TO org_cnt)
    SET excl_facilties->facs[idx].id = cnvtreal(pref_reply->pref_values[idx].values)
  ENDFOR
 ENDIF
 CALL echorecord(excl_facilties)
 CALL parseagerangestring(null)
 CALL insertgatherrunactivity(rn_gather_start)
 CALL echorecord(protocols)
 SET cur_list_size = size(protocols->prots,5)
 SELECT INTO "nl:"
  FROM prot_master pm,
   pt_prot_prescreen ppp,
   person p,
   encounter e,
   organization o,
   (dummyt d1  WITH seq = value(cur_list_size)),
   dummyt d2,
   dummyt d3,
   dummyt d4,
   ct_rn_run_activity ra
  PLAN (d1)
   JOIN (pm
   WHERE (pm.prot_master_id=protocols->prots[d1.seq].prot_master_id)
    AND pm.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d2)
   JOIN (ppp
   WHERE ppp.prot_master_id=pm.prot_master_id
    AND ((ppp.screening_status_cd+ 0)=pending_cd))
   JOIN (p
   WHERE p.person_id=ppp.person_id
    AND p.active_ind=1)
   JOIN (e
   WHERE e.person_id=p.person_id
    AND e.reg_dt_tm > cnvtdatetime(protocols->prots[d1.seq].look_back_to_dt_tm))
   JOIN (d3)
   JOIN (o
   WHERE o.organization_id=e.organization_id)
   JOIN (d4)
   JOIN (ra
   WHERE (ra.ct_rn_prot_run_id=protocols->prots[d1.seq].ct_rn_prot_run_id)
    AND ((ra.status_flag=rn_data_ext_success) OR (ra.status_flag=rn_data_ext_fail)) )
  ORDER BY ppp.prot_master_id, e.organization_id, p.person_id
  HEAD REPORT
   prot_cnt = 0, org_cnt = 0, prot_age_idx = 0
  HEAD pm.prot_master_id
   prot_cnt = (prot_cnt+ 1)
   IF (mod(prot_cnt,10)=1)
    stat = alterlist(pt_data->protocols,(prot_cnt+ 9))
   ENDIF
   pt_data->protocols[prot_cnt].prot_master_id = pm.prot_master_id, pt_data->protocols[prot_cnt].
   mnemonic = pm.primary_mnemonic, org_cnt = 0,
   prot_age_idx = locateval(idx,0,cur_list_size,pm.prot_master_id,protocols->prots[idx].
    prot_master_id), pt_data->protocols[prot_cnt].run_start_dt_tm = protocols->prots[prot_age_idx].
   run_start_dt_tm,
   CALL echo(build("prot_age_idx = ",prot_age_idx)),
   CALL echo(build("protocols->prots[prot_age_idx].data_extract_ind: ",protocols->prots[prot_age_idx]
    .data_extract_ind)),
   CALL echo(build("num: ",num))
   IF ((protocols->prots[prot_age_idx].data_extract_ind=0))
    pt_data->protocols[prot_cnt].data_extract_status = "NONE"
   ELSE
    IF (ra.status_flag=rn_data_ext_success)
     pt_data->protocols[prot_cnt].data_extract_status = "SUCCESS"
    ELSE
     pt_data->protocols[prot_cnt].data_extract_status = "FAILURE"
    ENDIF
   ENDIF
  HEAD e.organization_id
   exclfac_idx = locateval(idx,0,excl_facilties->cnt,e.loc_facility_cd,excl_facilties->facs[idx].id)
   IF (exclfac_idx=0
    AND p.person_id > 0)
    org_cnt = (org_cnt+ 1)
    IF (mod(org_cnt,10)=1)
     stat = alterlist(pt_data->protocols[prot_cnt].orgs,(org_cnt+ 9))
    ENDIF
    pt_data->protocols[prot_cnt].orgs[org_cnt].org_id = e.organization_id, pt_data->protocols[
    prot_cnt].orgs[org_cnt].org_name = o.org_name, stat = alterlist(pt_data->protocols[prot_cnt].
     orgs[org_cnt].age.ranges,protocols->prots[prot_age_idx].ages_cnt)
   ENDIF
  HEAD p.person_id
   CALL echo(build2("Person id = ",p.person_id))
   IF (exclfac_idx=0
    AND p.person_id > 0)
    CALL echo(concat("Processing, ",trim(p.name_full_formatted),", ",trim(cnvtage2(p.birth_dt_tm)),
     ", ",
     trim(uar_get_code_meaning(p.sex_cd)),", ",cnvtstring(p.person_id)))
    CASE (uar_get_code_meaning(p.sex_cd))
     OF "MALE":
      pt_data->protocols[prot_cnt].orgs[org_cnt].gender.male_cnt = (pt_data->protocols[prot_cnt].
      orgs[org_cnt].gender.male_cnt+ 1)
     OF "FEMALE":
      pt_data->protocols[prot_cnt].orgs[org_cnt].gender.female_cnt = (pt_data->protocols[prot_cnt].
      orgs[org_cnt].gender.female_cnt+ 1)
     ELSE
      pt_data->protocols[prot_cnt].orgs[org_cnt].gender.other_cnt = (pt_data->protocols[prot_cnt].
      orgs[org_cnt].gender.other_cnt+ 1)
    ENDCASE
    ar_idx = 1, rng_found = 0
    WHILE ((ar_idx <= protocols->prots[prot_age_idx].ages_cnt)
     AND rng_found=0)
     IF (cnvtdatetime(p.birth_dt_tm) BETWEEN cnvtdatetime(protocols->prots[prot_age_idx].ages[ar_idx]
      .agevalue2dttm) AND cnvtdatetime(protocols->prots[prot_age_idx].ages[ar_idx].agevalue1dttm))
      rng_found = 1, pt_data->protocols[prot_cnt].orgs[org_cnt].age.ranges[ar_idx].range_cnt = (
      pt_data->protocols[prot_cnt].orgs[org_cnt].age.ranges[ar_idx].range_cnt+ 1)
     ENDIF
     ,ar_idx = (ar_idx+ 1)
    ENDWHILE
    IF (rng_found=0)
     pt_data->protocols[prot_cnt].orgs[org_cnt].age.unknown_cnt = (pt_data->protocols[prot_cnt].orgs[
     org_cnt].age.unknown_cnt+ 1)
    ENDIF
   ENDIF
  FOOT  e.organization_id
   IF (exclfac_idx=0
    AND p.person_id > 0)
    pt_data->protocols[prot_cnt].orgs[org_cnt].org_person_cnt = ((pt_data->protocols[prot_cnt].orgs[
    org_cnt].gender.female_cnt+ pt_data->protocols[prot_cnt].orgs[org_cnt].gender.male_cnt)+ pt_data
    ->protocols[prot_cnt].orgs[org_cnt].gender.other_cnt)
   ENDIF
  FOOT  pm.prot_master_id
   stat = alterlist(pt_data->protocols[prot_cnt].orgs,org_cnt)
  FOOT REPORT
   stat = alterlist(pt_data->protocols,prot_cnt)
  WITH nocounter, outerjoin = d2, outerjoin = d3,
   dontcare = ppp, dontcare = o, dontcare = e,
   dontcare = p, outerjoin = d4, dontcare = ra
 ;end select
 SELECT INTO "nl:"
  FROM prot_master pm,
   pt_prot_prescreen ppp,
   person p,
   encounter e,
   organization o,
   (dummyt d1  WITH seq = value(cur_list_size)),
   dummyt d2,
   dummyt d3
  PLAN (d1)
   JOIN (pm
   WHERE (pm.prot_master_id=protocols->prots[d1.seq].prot_master_id)
    AND pm.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d2)
   JOIN (ppp
   WHERE ppp.prot_master_id=pm.prot_master_id
    AND ((ppp.screening_status_cd+ 0)=pending_cd))
   JOIN (p
   WHERE p.person_id=ppp.person_id
    AND p.active_ind=1)
   JOIN (e
   WHERE e.person_id=p.person_id
    AND e.reg_dt_tm > cnvtdatetime(protocols->prots[d1.seq].look_back_to_dt_tm))
   JOIN (d3)
   JOIN (o
   WHERE o.organization_id=e.organization_id)
  ORDER BY ppp.prot_master_id, p.person_id, e.organization_id
  HEAD REPORT
   person_cnt = 0, prot_idx = 0
  HEAD pm.prot_master_id
   person_cnt = 0, prot_idx = locateval(prot_idx,1,size(pt_data->protocols,5),pm.prot_master_id,
    pt_data->protocols[prot_idx].prot_master_id), prot_age_idx = locateval(idx,0,cur_list_size,pm
    .prot_master_id,protocols->prots[idx].prot_master_id),
   stat = alterlist(pt_data->protocols[prot_idx].age.ranges,protocols->prots[prot_age_idx].ages_cnt)
  HEAD p.person_id
   IF (p.person_id > 0)
    person_cnt = (person_cnt+ 1)
    CASE (uar_get_code_meaning(p.sex_cd))
     OF "MALE":
      pt_data->protocols[prot_idx].gender.male_cnt = (pt_data->protocols[prot_idx].gender.male_cnt+ 1
      )
     OF "FEMALE":
      pt_data->protocols[prot_idx].gender.female_cnt = (pt_data->protocols[prot_idx].gender.
      female_cnt+ 1)
     ELSE
      pt_data->protocols[prot_idx].gender.other_cnt = (pt_data->protocols[prot_idx].gender.other_cnt
      + 1)
    ENDCASE
    ar_idx = 1, rng_found = 0
    WHILE ((ar_idx <= protocols->prots[prot_age_idx].ages_cnt)
     AND rng_found=0)
     IF (cnvtdatetime(p.birth_dt_tm) BETWEEN cnvtdatetime(protocols->prots[prot_age_idx].ages[ar_idx]
      .agevalue2dttm) AND cnvtdatetime(protocols->prots[prot_age_idx].ages[ar_idx].agevalue1dttm))
      rng_found = 1, pt_data->protocols[prot_idx].age.ranges[ar_idx].range_cnt = (pt_data->protocols[
      prot_idx].age.ranges[ar_idx].range_cnt+ 1)
     ENDIF
     ,ar_idx = (ar_idx+ 1)
    ENDWHILE
    IF (rng_found=0)
     pt_data->protocols[prot_idx].age.unknown_cnt = (pt_data->protocols[prot_idx].age.unknown_cnt+ 1)
    ENDIF
   ENDIF
  FOOT  pm.prot_master_id
   pt_data->protocols[prot_idx].person_cnt = person_cnt
   IF (prot_age_idx > 0)
    protocols->prots[prot_age_idx].pt_sent_nbr = person_cnt
   ENDIF
  WITH nocounter, outerjoin = d2, outerjoin = d3,
   dontcare = ppp, dontcare = o, dontcare = e,
   dontcare = p
 ;end select
 SET stat = alterlist(protocols->prots,cur_list_size)
 CALL echorecord(pt_data)
 CALL buildxml(0)
 CALL echo("Done building XML")
 FOR (idx = 1 TO protocols->cnt)
  UPDATE  FROM ct_rn_prot_run rpr
   SET rpr.pt_sent_nbr = protocols->prots[idx].pt_sent_nbr, rpr.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), rpr.updt_id = reqinfo->updt_id,
    rpr.updt_applctx = reqinfo->updt_applctx, rpr.updt_task = reqinfo->updt_task, rpr.updt_cnt = (rpr
    .updt_cnt+ 1)
   WHERE (rpr.ct_rn_prot_run_id=protocols->prots[idx].ct_rn_prot_run_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL echo("Error updating prot run record with patient sent count")
   SET status_reply->status_data.status = "F"
   SET status_reply->status_data.subeventstatus[1].targetobjectvalue =
   "ct_rn_gather_data:Error updating prot run record with patient sent count"
   GO TO exit_script
  ENDIF
 ENDFOR
 CALL insertgatherrunactivity(rn_gather_compl)
 SUBROUTINE buildxml(dummy)
   DECLARE xml_str = vc WITH noconstant(" "), protect
   DECLARE client_mnemonic = vc WITH noconstant(" "), protect
   DECLARE prot_idx = i4 WITH noconstant(0), protect
   DECLARE org_idx = i4 WITH noconstant(0), protect
   DECLARE temp = i4 WITH noconstant(0), protect
   IF (size(pt_data->protocols,5) < 1)
    RETURN(0)
   ENDIF
   FREE RECORD frec
   RECORD frec(
     1 file_desc = i4
     1 file_name = vc
     1 file_buf = vc
     1 file_dir = i4
     1 file_offset = i4
   )
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="CLIENT MNEMONIC"
    DETAIL
     client_mnemonic = trim(di.info_char)
    WITH nocounter
   ;end select
   SET xml_str = concat(xml_str,
    '<RESEARCHNETWORK xmlns="http://www.cerner.com/Engineering/ClientData/RESEARCHNETWORK/1">',
    "<ClientDomain>",trim(curdomain),"</ClientDomain>",
    "<StudyList>")
   FOR (prot_idx = 1 TO size(pt_data->protocols,5))
     IF ((((pt_data->protocols[prot_idx].person_cnt=0)) OR ((pt_data->protocols[prot_idx].person_cnt
      >= min_result_val))) )
      SET pt_count_str = trim(cnvtstring(pt_data->protocols[prot_idx].person_cnt))
     ELSE
      SET pt_count_str = trim(concat("Between 1 and ",trim(cnvtstring(min_result_val))))
     ENDIF
     SET xml_str = concat(xml_str,"<Study>","<Id>",pt_data->protocols[prot_idx].mnemonic,"</Id>",
      "<Start>","<DateTime>",format(cnvtdatetime(pt_data->protocols[prot_idx].run_start_dt_tm),
       "YYYYMMDDHHMMSSCC;;D"),"</DateTime>","<UTC_Offset>",
      build(curutcdiff),"</UTC_Offset>","</Start>","<Complete>","<DateTime>",
      format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSSCC;;D"),"</DateTime>","<UTC_Offset>",build
      (curutcdiff),"</UTC_Offset>",
      "</Complete>","<TotalCount>",pt_count_str,"</TotalCount>")
     IF ((pt_data->protocols[prot_idx].person_cnt >= min_result_val))
      CALL buildxmlgender(xml_str,pt_data->protocols[prot_idx].gender.female_cnt,pt_data->protocols[
       prot_idx].gender.male_cnt,pt_data->protocols[prot_idx].gender.other_cnt)
      CALL echo("Start BuildXMLAgeRange")
      CALL buildxmlagerange(xml_str,prot_idx,0)
      CALL echo("Complete BuildXMLAgeRange")
      SET xml_str = concat(xml_str,"<DataExtractStatus>",pt_data->protocols[prot_idx].
       data_extract_status,"</DataExtractStatus>")
      SET xml_str = concat(xml_str,"<OrganizationList>")
      FOR (org_idx = 1 TO size(pt_data->protocols[prot_idx].orgs,5))
        SET xml_str = concat(xml_str,'<Organization id="',trim(cnvtstring(pt_data->protocols[prot_idx
           ].orgs[org_idx].org_id)),'" name="',trim(pt_data->protocols[prot_idx].orgs[org_idx].
          org_name),
         '">')
        SET xml_str = concat(xml_str,"<TotalCount>",trim(cnvtstring(pt_data->protocols[prot_idx].
           orgs[org_idx].org_person_cnt)),"</TotalCount>")
        CALL buildxmlgender(xml_str,pt_data->protocols[prot_idx].orgs[org_idx].gender.female_cnt,
         pt_data->protocols[prot_idx].orgs[org_idx].gender.male_cnt,pt_data->protocols[prot_idx].
         orgs[org_idx].gender.other_cnt)
        CALL buildxmlagerange(xml_str,prot_idx,org_idx)
        SET xml_str = concat(xml_str,"</Organization>")
      ENDFOR
      SET xml_str = concat(xml_str,"</OrganizationList>","</Study>")
     ELSE
      SET xml_str = concat(xml_str,"</Study>")
     ENDIF
   ENDFOR
   SET xml_str = concat(xml_str,"</StudyList>","</RESEARCHNETWORK>")
   SET frec->file_name = trim(output_file)
   SET frec->file_buf = "wb+"
   SET temp = cclio("OPEN",frec)
   CALL echo(build("OPEN=",temp))
   SET frec->file_buf = xml_str
   SET temp = cclio("WRITE",frec)
   CALL echo(build("WRITE=",temp))
   CALL echo(build("FILE_OFFSET=",frec->file_offset))
   SET temp = cclio("CLOSE",frec)
   CALL echo(build("CLOSE=",temp))
   RETURN(1)
 END ;Subroutine
 SUBROUTINE buildxmlgender(xml_str,female_cnt,male_cnt,other_cnt)
   SET xml_str = concat(xml_str,'<Gender femaleCount="',trim(cnvtstring(female_cnt)),'" maleCount="',
    trim(cnvtstring(male_cnt)),
    '" otherCount="',trim(cnvtstring(other_cnt)),'"></Gender>')
 END ;Subroutine
 SUBROUTINE buildxmlagerange(xml_str,prot_idx,org_idx)
   DECLARE ar_idx = i4 WITH protect, noconstant(0)
   DECLARE prot_age_idx = i4 WITH protect, noconstant(0)
   SET xml_str = concat(xml_str,"<Age>")
   SET prot_age_idx = locateval(prot_age_idx,0,protocols->cnt,pt_data->protocols[prot_idx].
    prot_master_id,protocols->prots[prot_age_idx].prot_master_id)
   FOR (ar_idx = 1 TO protocols->prots[prot_age_idx].ages_cnt)
     IF (org_idx=0)
      SET xml_str = concat(xml_str,'<AgeRangeCount start="',trim(cnvtstring(protocols->prots[
         prot_age_idx].ages[ar_idx].agevalue1)),'" end="',trim(cnvtstring(protocols->prots[
         prot_age_idx].ages[ar_idx].agevalue2)),
       '">',trim(cnvtstring(pt_data->protocols[prot_idx].age.ranges[ar_idx].range_cnt)),
       "</AgeRangeCount>")
     ELSE
      SET xml_str = concat(xml_str,'<AgeRangeCount start="',trim(cnvtstring(protocols->prots[
         prot_age_idx].ages[ar_idx].agevalue1)),'" end="',trim(cnvtstring(protocols->prots[
         prot_age_idx].ages[ar_idx].agevalue2)),
       '">',trim(cnvtstring(pt_data->protocols[prot_idx].orgs[org_idx].age.ranges[ar_idx].range_cnt)),
       "</AgeRangeCount>")
     ENDIF
   ENDFOR
   SET xml_str = concat(xml_str,"</Age>")
 END ;Subroutine
 SUBROUTINE insertgatherrunactivity(rn_status)
   DECLARE prot_cnt = i2 WITH protect, noconstant(0)
   SET prot_cnt = size(protocols->prots,5)
   FOR (idx = 1 TO prot_cnt)
     CALL insertrnrunactivity(protocols->prots[idx].ct_rn_prot_run_id,rn_status)
   ENDFOR
 END ;Subroutine
 SUBROUTINE parseagerangestring(null)
   DECLARE idx = i2 WITH protect, noconstant(0)
   DECLARE agerangestr = vc WITH protect, noconstant("")
   DECLARE valuestr = vc WITH protect, noconstant("")
   DECLARE notfound = vc WITH protect, constant("<not_found>")
   DECLARE age_idx = i4 WITH protect, noconstant(1)
   DECLARE age_cnt = i4 WITH protect, noconstant(1)
   DECLARE range_exceeded = i2 WITH protect, noconstant(0)
   FOR (idx = 1 TO protocols->cnt)
     SET age_cnt = 1
     SET age_idx = 1
     SET valuestr = ""
     SET range_exceeded = 0
     CALL echo(build("protocols->prots[idx].raw_age_str = ",protocols->prots[idx].raw_age_str))
     WHILE (valuestr != notfound
      AND age_idx < 1000
      AND range_exceeded=0)
       SET valuestr = piece(protocols->prots[idx].raw_age_str,",",age_idx,notfound)
       CALL echo(build("valueStr:",valuestr))
       IF (valuestr != notfound)
        IF (mod(age_cnt,10)=1)
         SET stat = alterlist(protocols->prots[idx].ages,(age_cnt+ 9))
        ENDIF
        IF (age_cnt=1)
         SET protocols->prots[idx].ages[age_cnt].agevalue1dttm = cnvtdatetime("31-DEC-2100 00:00:00")
        ENDIF
        SET age_cnt = (age_cnt+ 1)
        SET protocols->prots[idx].ages[age_cnt].agevalue1 = cnvtint(valuestr)
        CALL echo(build("protocols->prots[idx].ages[age_cnt]->ageValue1 = ",protocols->prots[idx].
          ages[age_cnt].agevalue1))
        IF ((protocols->prots[idx].ages[age_cnt].agevalue1=0))
         SET protocols->prots[idx].ages[age_cnt].agevalue1dttm = cnvtdatetime(curdate,curtime3)
        ELSE
         SET protocols->prots[idx].ages[age_cnt].agevalue1dttm = cnvtlookbehind(build(protocols->
           prots[idx].ages[age_cnt].agevalue1,",Y"),cnvtdatetime(curdate,curtime3))
        ENDIF
        IF (age_cnt > 1)
         IF (valuestr != "X")
          SET protocols->prots[idx].ages[(age_cnt - 1)].agevalue2 = cnvtint(valuestr)
         ENDIF
        ENDIF
        IF ((protocols->prots[idx].ages[(age_cnt - 1)].agevalue2 >= 90))
         SET protocols->prots[idx].ages[(age_cnt - 1)].agevalue2 = 90
         SET range_exceeded = 1
        ENDIF
        IF ((protocols->prots[idx].ages[(age_cnt - 1)].agevalue2=0))
         SET protocols->prots[idx].ages[(age_cnt - 1)].agevalue2dttm = cnvtdatetime(
          "01-JAN-1800 00:00:00")
        ELSE
         SET protocols->prots[idx].ages[(age_cnt - 1)].agevalue2dttm = cnvtlookbehind(build(protocols
           ->prots[idx].ages[(age_cnt - 1)].agevalue2,",Y"),cnvtdatetime(curdate,curtime3))
        ENDIF
        CALL echo(build("piece",age_idx,"=",valuestr))
       ENDIF
       SET age_idx = (age_idx+ 1)
     ENDWHILE
     SET stat = alterlist(protocols->prots[idx].ages,age_cnt)
     SET protocols->prots[idx].ages_cnt = age_cnt
   ENDFOR
 END ;Subroutine
 COMMIT
#exit_script
 CALL echo("Ending ct_rn_gather_data")
 SET last_mod = "004"
 SET mod_date = "November 23, 2009"
END GO
