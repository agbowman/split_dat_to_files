CREATE PROGRAM bed_rec_cs_run_detail:dba
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
 SET col_cnt = 9
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Check Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Template Number"
 SET reply->collist[2].data_type = 3
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Name"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Defined To Run"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Actual Setting Run Mode"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Recommended Setting Run Mode"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Actual Last Run Date"
 SET reply->collist[7].data_type = 4
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Recommendation For Last Run Date"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Resolution"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 DECLARE short_desc = vc
 DECLARE resolution_txt = vc
 DECLARE recommendation_txt = vc
 SET reply->run_status_flag = 1
 SET row_tot_cnt = 0
 SET plsize = 0
 SET plsize = size(request->paramlist,5)
 FOR (x = 1 TO plsize)
   IF ((request->paramlist[x].meaning="CSACTIVITYRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="CSACTIVITYRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr
       AND t.name="Charge Services Purge Activity")
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,0,"Charge Services Purge Activity","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="CSCHARGERUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="CSCHARGERUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr
       AND t.name="Charge Services Purge Charge")
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,0,"Charge Services Purge Charge","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="CSMODRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="CSMODRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr
       AND t.name="Charge Services Purge Charge Mod")
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,0,"Charge Services Purge Charge Mod","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="CSEVENTRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="CSEVENTRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr
       AND t.name="Charge Services Purge Event Log")
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,0,"Charge Services Purge Event Log","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="CSINTERFACERUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="CSINTERFACERUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr
       AND t.name="Charge Services Purge Interface Charge")
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,0,"Charge Services Purge Interface Charge","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="CRCHARTRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="CRCHARTRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr
       AND t.name="Chart Request Purge and Archive")
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,0,"Chart Request Purge and Archive","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="PATCAREWORKVIEWPRSN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="PATCAREWORKVIEWPRSN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=9980)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr
       AND t.name="INET PURGE WORKING_VIEW_PERSON")
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,0,"INET PURGE WORKING_VIEW_PERSON","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="PATCAREPDP"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="PATCAREPDP")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=10021)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr
       AND t.name="Preference Data Purge")
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,0,"Preference Data Purge","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="PATCAREDCPSA"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="PATCAREDCPSA")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=90)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr
       AND t.name="DCP Purge Shift Assignment")
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,0,"DCP Purge Shift Assignment","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="GENLABPURGETLIST"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="GENLABPURGETLIST")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=106)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,106,"PathNet Collections Purge transfer lists","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="GLPURGECOLLLIST"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="GLPURGECOLLLIST")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=104)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,104,"PathNet Collections Purge collection lists","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="GLPURGEWRKLST"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="GLPURGEWRKLST")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=107)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,107,"PathNet General Lab Purge worklists","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="MICROPURGEIC"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="MICROPURGEIC")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=108)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,108,"PathNet Micro Purge Infection Control","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="MICROPURGEANG"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="MICROPURGEANG")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=124)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,124,"PathNet Micro Purge ANG Status","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="IFPURGEESI"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="IFPURGEESI")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=87)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,87,"ESI Purge ESI_LOG","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="IFPURGEESO"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="IFPURGEESO")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=82)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,82,"ESO Purge CQM_FSIESO_QUE and children","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="IFPURGECQMOOC"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="IFPURGECQMOOC")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=84)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,84,"ESO Purge CQM_FSIOCC_QUE","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="IFPURGEESOORPH2"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="IFPURGEESOORPH2")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=80)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,80,"ESO Purge FSIESO_QUE_DETAILS orphans","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="IFPURGEORPHHOLD"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="IFPURGEORPHHOLD")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=85)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,85,"ESO Purge Orphan HOLD Queue rows","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="IFPURGEESOTR"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="IFPURGEESOTR")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=86)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,86,"ESO Purge orphan TR1 rows","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="IFPURGEESOSI"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="IFPURGEESOSI")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=83)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,83,"ESO Purge SI_BATCH and children","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="IFPURGEESOTIQ"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="IFPURGEESOTIQ")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=10020)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,10020,"ESO Purge TRIGHOLD_INPUT_QUE","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="OENCQMQUERUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="OENCQMQUERUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=77)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,77,"OEN Purge CQM Queue Rows","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="OENCQMTRIGGERRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="OENCQMTRIGGERRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=78)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,78,"OEN Purge CQM Trigger Rows","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="OENRLIRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="OENRLIRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=116)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,116,"OEN Purge RLI Batch Tables","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="OENSIAUDITRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="OENSIAUDITRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=10017)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,10017,"OEN Purge SI_AUDIT Table Rows","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="OENTRANSEVENTLOGRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="OENTRANSEVENTLOGRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=89)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,89,"OEN Purge Transaction Event Log","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="OENTRANSLOGRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="OENTRANSLOGRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=88)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,88,"OEN Purge Transaction Log","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="OENTXSTATSRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="OENTXSTATSRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=79)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,79,"OEN Purge TX Stats Log and children","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="OENSIMESSAGERUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="OENSIMESSAGERUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=10069)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,10069,"OEN Purge SI_MESSAGE_LOG","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="EEMTRANSRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="EEMTRANSRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=59)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id)
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,59,"EEM Purge Transactions","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="PMENCDOMAINRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="PMENCDOMAINRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=62)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,62,"PM Purge Encounter Domain","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="SCHDEFAPPLYRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="SCHDEFAPPLYRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=66)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,66,"SCH Purge scheduling default apply","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="SCHEVENTRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="SCHEVENTRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=72)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,72,"SCH Purge scheduling event","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="SCHLOGFILESRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="SCHLOGFILESRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=69)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,69,"SCH Purge scheduling log files","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="SCHPERSENCCOMRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="SCHPERSENCCOMRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=70)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,70,"SCH Purge scheduling person encounter comments","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="SCHREPORTQUERYRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="SCHREPORTQUERYRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=67)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,67,"SCH Purge scheduling report query log","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="SCHRESCOMMENTRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="SCHRESCOMMENTRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=68)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,68,"SCH Purge scheduling resource comments","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="SCHTIMESLOTSRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="SCHTIMESLOTSRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=71)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,71,"SCH Purge scheduling time slots","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="MDIGLRESULTRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="MDIGLRESULTRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=118)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,118,"MDI Purge GenLab Results Rows","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="MDIGLDOWNLOADRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="MDIGLDOWNLOADRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=117)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,117,"MDI Purge GenLab Download Rows","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="MDIMICRORESULTRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="MDIMICRORESULTRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=119)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,119,"MDI Purge Micro Results Rows","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="MDIMICRODOWNLOADRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="MDIMICRODOWNLOADRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=120)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,120,"MDI Purge Micro Download Rows","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="MDIPOCRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="MDIPOCRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=121)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,121,"MDI Purge Point of Care Rows","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="HIMBATCHLABELRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="HIMBATCHLABELRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=57)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,57,"HIM purge Batch Label","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="HIMDOCDEFALLOCRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="HIMDOCDEFALLOCRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=58)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,58,"HIM purge Document Deficiency Allocation","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="HIMSTICKYNOTESRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="HIMSTICKYNOTESRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=56)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,56,"HIM purge Sticky Notes","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="HIMTAGCOLORRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="HIMTAGCOLORRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=54)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,54,"HIM purge Tag Color","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="HIMTASKHISTRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="HIMTASKHISTRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=55)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,55,"HIM purge Task History","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="DDLOPSLOGRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="DDLOPSLOGRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=10039)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,10039,"Database Architecture DDL Ops Log Rows","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="DDLOPSRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="DDLOPSRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=10040)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,10040,"Database Architecture DDL Ops Rows","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="MERGEROWSRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="MERGEROWSRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=126)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,126,"Database Architecture Merge Rows","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="PLANROWSRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="PLANROWSRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=125)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,125,"Database Architecture Plan Rows","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="JOBPARMHISTRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="JOBPARMHISTRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=10045)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,10045,"Database Architecture Purge Job Parameter History","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="RDDSLOGROWSRUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="RDDSLOGROWSRUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=10014)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,10014,"Database Architecture RDDS Log Rows","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="SPACESUMMDATARUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="SPACESUMMDATARUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=10042)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,10042,"Database Architecture Space Summary Data","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="TSPACESIZERUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="TSPACESIZERUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=10047)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,10047,"Database Architecture TSSPACE_SIZE Purge","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="TSPACEOBJSIZERUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="TSPACEOBJSIZERUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=10048)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,10048,"Database Architecture TSPACE_OBJ_SIZE Purge","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
   IF ((request->paramlist[x].meaning="CODESETUPDATERUN"))
    SET recommendation_txt = ""
    SET short_desc = ""
    SET resolution_txt = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl,
      br_long_text bl2,
      br_name_value bnv
     PLAN (b
      WHERE b.rec_mean="CODESETUPDATERUN")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.resolution_txt_id)
      JOIN (bnv
      WHERE bnv.br_name=b.subcategory_mean
       AND bnv.br_nv_key1="DIAGNOSTICSUBCATEGORIES")
     DETAIL
      recommendation_txt = trim(bl.long_text), short_desc = trim(b.short_desc), resolution_txt = trim
      (bl2.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dm_purge_job j,
      dm_flags f,
      dm_purge_template t,
      dm_purge_job_token jt,
      dm_purge_token pt,
      dm_purge_job_log l
     PLAN (j
      WHERE j.active_flag=1
       AND j.template_nbr=128)
      JOIN (f
      WHERE f.table_name="DM_PURGE_JOB"
       AND f.column_name="PURGE_FLAG"
       AND f.flag_value=j.purge_flag)
      JOIN (t
      WHERE t.active_ind=1
       AND t.template_nbr=j.template_nbr)
      JOIN (jt
      WHERE jt.job_id=j.job_id)
      JOIN (pt
      WHERE pt.template_nbr=t.template_nbr)
      JOIN (l
      WHERE l.job_id=j.job_id
       AND l.updt_dt_tm > cnvtdatetime((curdate - 1),0))
     ORDER BY j.last_run_dt_tm DESC
     HEAD t.template_nbr
      stat = add_rep(short_desc,t.template_nbr,t.name,"Yes",f.description,
       "Purge with job level logging OR Purge with table level logging",j.last_run_dt_tm,
       recommendation_txt,resolution_txt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET stat = add_rep(short_desc,128,"DM info - Code Set Update and Seq Match Purge","No","",
      "",null,recommendation_txt,resolution_txt)
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE add_rep(p1,p2,p3,p4,p5,p6,p7,p8,p9)
   SET row_tot_cnt = (size(reply->rowlist,5)+ 1)
   SET stat = alterlist(reply->rowlist,row_tot_cnt)
   SET stat = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt)
   SET reply->rowlist[row_tot_cnt].celllist[1].string_value = p1
   SET reply->rowlist[row_tot_cnt].celllist[2].nbr_value = p2
   SET reply->rowlist[row_tot_cnt].celllist[3].string_value = p3
   SET reply->rowlist[row_tot_cnt].celllist[4].string_value = p4
   SET reply->rowlist[row_tot_cnt].celllist[5].string_value = p5
   SET reply->rowlist[row_tot_cnt].celllist[6].string_value = p6
   SET reply->rowlist[row_tot_cnt].celllist[7].date_value = p7
   SET reply->rowlist[row_tot_cnt].celllist[8].string_value = p8
   SET reply->rowlist[row_tot_cnt].celllist[9].string_value = p9
   RETURN(1)
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
