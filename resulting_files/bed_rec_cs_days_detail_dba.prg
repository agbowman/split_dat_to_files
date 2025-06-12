CREATE PROGRAM bed_rec_cs_days_detail:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 paramlist[*]
      2 meaning = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET col_cnt = 8
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Check Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Purge Template Number"
 SET reply->collist[2].data_type = 3
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Purge Script Name"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Defined To Run"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Purge Script Question"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Recommended Setting"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Actual Setting"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Resolution"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 DECLARE tname = vc
 DECLARE recommendation_txt = vc
 SET reply->run_status_flag = 1
 SET row_tot_cnt = 0
 DECLARE short_desc = vc
 DECLARE resolution_txt = vc
 SET plsize = 0
 SET plsize = size(request->paramlist,5)
 FOR (x = 1 TO plsize)
   IF ((request->paramlist[x].meaning="CSACTIVITYDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="CSACTIVITYDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr
       AND t.name="Charge Services Purge Activity")
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
       "548 days (1.5 years)",jt.value,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,0,"Charge Services Purge Activity","No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="CSCHARGEDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="CSCHARGEDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr
       AND t.name="Charge Services Purge Charge")
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
       "548 days (1.5 years)",jt.value,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,0,"Charge Services Purge Charge","No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="CSMODDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="CSMODDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr
       AND t.name="Charge Services Purge Charge Mod")
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
       "548 days (1.5 years)",jt.value,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,0,"Charge Services Purge Charge Mod","No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="CSEVENTDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="CSEVENTDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr
       AND t.name="Charge Services Purge Event Log")
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
       "548 days (1.5 years)",jt.value,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,0,"Charge Services Purge Event Log","No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="CSINTERFACEDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="CSINTERFACEDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr
       AND t.name="Charge Services Purge Interface Charge")
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
       "548 days (1.5 years)",jt.value,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,0,"Charge Services Purge Interface Charge","No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="CRDAYSADHOC"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="CRDAYSADHOC")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr
       AND t.name="Chart Request Purge and Archive")
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="LOOKBACKDAYSADHOCEXP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="LOOKBACKDAYSADHOCEXP")
     DETAIL
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
       "A minimum of 90 days and a maximum of 365 days",jt.value,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,0,"Chart Request Purge and Archive","No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="CRDAYSDIST"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="CRDAYSDIST")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr
       AND t.name="Chart Request Purge and Archive")
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="LOOKBACKDAYSDIST")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="LOOKBACKDAYSDIST")
     DETAIL
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
       "A minimum of 90 days and a maximum of 365 days",jt.value,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,0,"Chart Request Purge and Archive","No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="GLPURGEONLINEDATA"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="GLPURGEONLINEDATA")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=106)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 60)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 60 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=106
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,106,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="GLPURGECOLLOD"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="GLPURGECOLLOD")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=104)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 14)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 14 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=104
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,104,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="GLPURGEWRKLSTOD"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="GLPURGEWRKLSTOD")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=107)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 30)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 30 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=107
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,107,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="MICROPURGEICOD"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="MICROPURGEICOD")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=108)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 730)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 730 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=108
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,108,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="MICROPURGEANGOD"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="MICROPURGEANGOD")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=124)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 30)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 30 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=124
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,124,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="IFPURGEESIOD"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="IFPURGEESIOD")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=87)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 14)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 14 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=87
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,87,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="IFPURGEESOOD"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="IFPURGEESOOD")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=82)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 7)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 7 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=82
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,82,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="IFPURGECQMOOCOD"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="IFPURGECQMOOCOD")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=84)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 7)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 7 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=84
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,84,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="IFPURGEESOSIOD"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="IFPURGEESOSIOD")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=83)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 7)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 7 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=83
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,83,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="IFPURGEESOTIQOD"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="IFPURGEESOTIQOD")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=10020)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 7)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 7 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=10020
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,10020,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="OENRLIDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="OENRLIDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=116)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 7)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 7 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=116
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,116,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="OENSIAUDITDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="OENSIAUDITDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=10017)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 7)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 7 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=10017
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,10017,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="OENTRANSEVENTLOGDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="OENTRANSEVENTLOGDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=89)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 7)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 7 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=89
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,89,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="OENTRANSLOGDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="OENTRANSLOGDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=88)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 7)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 7 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=88
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,88,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="OENTXSTATSDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="OENTXSTATSDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=79)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 7)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 7 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=79
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,79,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="OENSIMESSAGEDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="OENSIMESSAGEDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=10069)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 7)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 7 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=10069
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,10069,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="EEMTRANSDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="EEMTRANSDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=59)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (((cnvtint(trim(jt.value)) < 120) OR (cnvtint(trim(jt.value)) > 180)) )
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "120-180 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=59
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,59,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="PMENCDOMAINDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="PMENCDOMAINDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=62)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (((cnvtint(trim(jt.value)) < 7) OR (cnvtint(trim(jt.value)) > 14)) )
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "7-14 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=62
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,62,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="SCHDEFAPPLYDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="SCHDEFAPPLYDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=66)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) < 548)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        ">= 548 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=66
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,66,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="SCHEVENTDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="SCHEVENTDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=72)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) < 548)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        ">= 548 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=72
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,72,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="SCHLOGFILESDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="SCHLOGFILESDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=69)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) < 548)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        ">= 548 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=69
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,69,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="SCHPERSENCCOMDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="SCHPERSENCCOMDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=70)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) < 548)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        ">= 548 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=70
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,70,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="SCHREPORTQUERYDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="SCHREPORTQUERYDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=67)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) < 548)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        ">= 548 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=67
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,67,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="SCHRESCOMMENTDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="SCHRESCOMMENTDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=68)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) < 548)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        ">= 548 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=68
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,68,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="SCHTIMESLOTSDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="SCHTIMESLOTSDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=71)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) < 548)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        ">= 548 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=71
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,71,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="MDIGLRESULTDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="MDIGLRESULTDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=118)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 4)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 4 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=118
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,118,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="MDIGLDOWNLOADDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="MDIGLDOWNLOADDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=117)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 4)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 4 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=117
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,117,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="MDIMICRORESULTDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="MDIMICRORESULTDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=119)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 4)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 4 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=119
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,119,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="MDIMICRODOWNLOADDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="MDIMICRODOWNLOADDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=120)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 4)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 4 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=120
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,120,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="MDIPOCDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="MDIPOCDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=121)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 4)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 4 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=121
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,121,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="HIMTASKHISTDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="HIMTASKHISTDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.template_nbr=55
       AND j.active_flag=1)
      JOIN (t
      WHERE t.template_nbr=j.template_nbr
       AND t.active_ind=1)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 365)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 365 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=55
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,55,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="HIMBATCHLABELDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="HIMBATCHLABELDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.template_nbr=57
       AND j.active_flag=1)
      JOIN (t
      WHERE t.template_nbr=j.template_nbr
       AND t.active_ind=1)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 90)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 90 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=57
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,57,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="HIMSTICKYNOTESDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="HIMSTICKYNOTESDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.template_nbr=56
       AND j.active_flag=1)
      JOIN (t
      WHERE t.template_nbr=j.template_nbr
       AND t.active_ind=1)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 365)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 365 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=56
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,56,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="HIMTAGCOLORDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="HIMTAGCOLORDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.template_nbr=54
       AND j.active_flag=1)
      JOIN (t
      WHERE t.template_nbr=j.template_nbr
       AND t.active_ind=1)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 365)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 365 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=54
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,54,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="HIMDOCDEFALLOCDAYS"))
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl2
     PLAN (b
      WHERE b.rec_mean="HIMDOCDEFALLOCDAYS")
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
     DETAIL
      short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt
     PLAN (j
      WHERE j.template_nbr=58
       AND j.active_flag=1)
      JOIN (t
      WHERE t.template_nbr=j.template_nbr
       AND t.active_ind=1)
      JOIN (jt
      WHERE jt.job_id=j.job_id
       AND jt.token_str="DAYSTOKEEP")
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr
       AND pt.token_str="DAYSTOKEEP")
     DETAIL
      IF (cnvtint(trim(jt.value)) > 183)
       stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",pt.prompt_str,
        "<= 183 days",jt.value,resolution_txt)
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET tname = " "
     SELECT INTO "nl:"
      FROM dm_purge_template t
      WHERE t.template_nbr=58
       AND t.active_ind=1
      DETAIL
       tname = t.name
      WITH nocounter
     ;end select
     SET stat = add_rep(short_desc,58,tname,"No","",
      "","",resolution_txt)
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE add_rep(p1,p2,p3,p4,p5,p6,p7,p8)
   SET row_tot_cnt = (size(reply->rowlist,5)+ 1)
   SET stat = alterlist(reply->rowlist,row_tot_cnt)
   SET stat = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt)
   SET reply->rowlist[row_tot_cnt].celllist[1].string_value = p1
   SET reply->rowlist[row_tot_cnt].celllist[2].nbr_value = p2
   SET reply->rowlist[row_tot_cnt].celllist[3].string_value = p3
   SET reply->rowlist[row_tot_cnt].celllist[4].string_value = p4
   SET reply->rowlist[row_tot_cnt].celllist[5].string_value = p5
   SET reply->rowlist[row_tot_cnt].celllist[6].string_value = p6
   SET reply->rowlist[row_tot_cnt].celllist[7].string_value = p7
   SET reply->rowlist[row_tot_cnt].celllist[8].string_value = p8
   RETURN(1)
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
