CREATE PROGRAM bhs_athn_cancel_allergy
 RECORD orequest(
   1 allergy_cnt = i4
   1 allergy[*]
     2 allergy_instance_id = f8
     2 allergy_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 substance_nom_id = f8
     2 substance_ftdesc = vc
     2 substance_type_cd = f8
     2 reaction_class_cd = f8
     2 severity_cd = f8
     2 source_of_info_cd = f8
     2 source_of_info_ft = vc
     2 onset_dt_tm = dq8
     2 onset_precision_cd = f8
     2 onset_precision_flag = i2
     2 reaction_status_cd = f8
     2 cancel_reason_cd = f8
     2 cancel_dt_tm = dq8
     2 cancel_prsnl_id = f8
     2 created_prsnl_id = f8
     2 reviewed_dt_tm = dq8
     2 reviewed_prsnl_id = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 contributor_system_cd = f8
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
     2 verified_status_flag = i2
     2 rec_src_vocab_cd = f8
     2 rec_src_identifier = vc
     2 rec_src_string = vc
     2 reaction_cnt = i4
     2 reaction[*]
       3 reaction_id = f8
       3 allergy_instance_id = f8
       3 allergy_id = f8
       3 reaction_nom_id = f8
       3 reaction_ftdesc = vc
       3 active_ind = i2
       3 active_status_cd = f8
       3 active_status_dt_tm = dq8
       3 active_status_prsnl_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 contributor_system_cd = f8
       3 data_status_cd = f8
       3 data_status_dt_tm = dq8
       3 data_status_prsnl_id = f8
     2 allergy_comment_cnt = i4
     2 allergy_comment[*]
       3 allergy_comment_id = f8
       3 allergy_instance_id = f8
       3 allergy_id = f8
       3 comment_dt_tm = dq8
       3 comment_prsnl_id = f8
       3 allergy_comment = vc
       3 active_ind = i2
       3 active_status_cd = f8
       3 active_status_dt_tm = dq8
       3 active_status_prsnl_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 contributor_system_cd = f8
       3 data_status_cd = f8
       3 data_status_dt_tm = dq8
       3 data_status_prsnl_id = f8
     2 comment_only = i2
     2 reaction_only = i2
 )
 RECORD srequest(
   1 param = vc
 )
 RECORD sreply(
   1 param = vc
 )
 DECLARE username = vc
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id= $3)
    AND p.active_ind=1)
  HEAD p.person_id
   username = p.username
  WITH nocounter, time = 30
 ;end select
 SET namelen = (textlen(username)+ 1)
 SET domainnamelen = (textlen(curdomain)+ 2)
 SET statval = memalloc(name,1,build("C",namelen))
 SET statval = memalloc(domainname,1,build("C",domainnamelen))
 SET name = username
 SET domainname = curdomain
 SET setcntxt = uar_secimpersonate(nullterm(username),nullterm(domainname))
 DECLARE canceled_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",12025,"CANCELED"))
 DECLARE t_line = vc
 SET orequest->allergy_cnt = 1
 SET stat = alterlist(orequest->allergy,1)
 SET orequest->allergy[1].allergy_id =  $2
 SET orequest->allergy[1].cancel_prsnl_id =  $3
 SET orequest->allergy[1].cancel_reason_cd =  $4
 SET orequest->allergy[1].reaction_status_cd = canceled_cd
 SET date_line = substring(1,10, $5)
 SET time_line = substring(12,8, $5)
 SET orequest->allergy[1].cancel_dt_tm = cnvtdatetimeutc2(date_line,"YYYY-MM-DD",time_line,"HH;mm;ss",
  4)
 IF (( $6 > " "))
  SET orequest->allergy[1].allergy_comment_cnt = 1
  SET stat = alterlist(orequest->allergy[1].allergy_comment,1)
  SET srequest->param =  $6
  EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","SREQUEST"), replace("REPLY","SREPLY")
  SET orequest->allergy[1].allergy_comment[1].allergy_comment = sreply->param
  SET orequest->allergy[1].allergy_comment[1].comment_dt_tm = orequest->allergy[1].cancel_dt_tm
  SET orequest->allergy[1].allergy_comment[1].comment_prsnl_id =  $3
 ENDIF
 SET stat = tdbexecute(3200000,3200066,3200125,"REC",orequest,
  "REC",oreply)
 CALL echojson(oreply, $1)
END GO
