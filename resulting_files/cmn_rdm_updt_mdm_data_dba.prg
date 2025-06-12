CREATE PROGRAM cmn_rdm_updt_mdm_data:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting cmn_updt_mdm_data script"
 FREE RECORD cmndata
 RECORD cmndata(
   1 cnt = i4
   1 qual[*]
     2 mpmpagedefid = f8
     2 olddriverscript = vc
     2 oldparamtxt = vc
     2 newdriverscript = vc
     2 newparamtxt = vc
     2 changeind = i2
 ) WITH protect
 FREE RECORD reportparam
 RECORD reportparam(
   1 params[*]
     2 paramvalue = vc
 ) WITH protect
 DECLARE temptxt = vc WITH protect, noconstant(" ")
 DECLARE newurl = vc WITH protect, noconstant(" ")
 DECLARE paramcount = i4 WITH protect, noconstant(0)
 DECLARE recindex = i4 WITH protect, noconstant(0)
 DECLARE viewpointname = vc WITH protect, noconstant(" ")
 DECLARE staticcontentlocation = vc WITH protect, noconstant(" ")
 DECLARE debugindicator = vc WITH protect, noconstant(" ")
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 IF (checkdic("MP_MPAGE_DEF","T",0)=0)
  SET readme_data->status = "S"
  SET readme_data->message = "Success: MP_MPAGE_DEF table does not exist, no work needs to be done"
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM mp_mpage_def m
  WHERE cnvtlower(m.driver_script_name) IN ("mp_unified_driver", "mp_unified_org_driver")
  DETAIL
   temptxt = m.parameter_txt
   IF (size(trim(temptxt,3)) > 0)
    cmndata->cnt += 1, stat = alterlist(cmndata->qual,cmndata->cnt), cmndata->qual[cmndata->cnt].
    mpmpagedefid = m.mp_mpage_def_id,
    cmndata->qual[cmndata->cnt].olddriverscript = m.driver_script_name, cmndata->qual[cmndata->cnt].
    oldparamtxt = temptxt, newurl = "",
    paramcount = arraysplit(reportparam->params[recindex].paramvalue,recindex,temptxt,",",2)
    IF (cnvtlower(cmndata->qual[cmndata->cnt].olddriverscript)="mp_unified_driver")
     IF (((paramcount=9) OR (paramcount=10)) )
      viewpointname = reportparam->params[9].paramvalue, staticcontentlocation = reportparam->params[
      8].paramvalue
      IF (paramcount=10)
       debugindicator = reportparam->params[10].paramvalue
      ELSE
       debugindicator = ""
      ENDIF
      newurl = build("<url>$DM_INFO:CONTENT_SERVICE_URL$/mp-content/idx.html?m=",
       "^CHT^&pId=$PAT_PERSONID$&eId=$VIS_ENCNTRID$&uId=$USR_PERSONID$",
       "&pCd=$USR_PositionCd$&ppr=$PAT_PPRCode$&app=^$APP_AppName$^&vId=",viewpointname)
      IF (staticcontentlocation != "")
       newurl = build(newurl,"&sLoc=",staticcontentlocation)
      ENDIF
      IF (debugindicator != "")
       newurl = build(newurl,"&dbg=",debugindicator)
      ENDIF
      IF (size(newurl,1) <= 255)
       cmndata->qual[cmndata->cnt].changeind = 1, cmndata->qual[cmndata->cnt].newdriverscript =
       newurl, cmndata->qual[cmndata->cnt].newparamtxt = ""
      ENDIF
     ENDIF
    ELSEIF (cnvtlower(cmndata->qual[cmndata->cnt].olddriverscript)="mp_unified_org_driver")
     IF (((paramcount=6) OR (paramcount=7)) )
      viewpointname = reportparam->params[6].paramvalue, staticcontentlocation = reportparam->params[
      5].paramvalue
      IF (paramcount=7)
       debugindicator = reportparam->params[7].paramvalue
      ELSE
       debugindicator = ""
      ENDIF
      newurl = build("<url>$DM_INFO:CONTENT_SERVICE_URL$/mp-content/idx.html?m=",
       "^ORG^&uId=$USR_PERSONID$&pCd=$USR_PositionCd$&app=^$APP_AppName$^&vId=",viewpointname)
      IF (staticcontentlocation != "")
       newurl = build(newurl,"&sLoc=",staticcontentlocation)
      ENDIF
      IF (debugindicator != "")
       newurl = build(newurl,"&dbg=",debugindicator)
      ENDIF
      IF (size(newurl,1) <= 255)
       cmndata->qual[cmndata->cnt].changeind = 1, cmndata->qual[cmndata->cnt].newdriverscript =
       newurl, cmndata->qual[cmndata->cnt].newparamtxt = ""
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Error querying MP_MPAGE_DEF - ",errmsg)
  GO TO exit_script
 ENDIF
 UPDATE  FROM mp_mpage_def m,
   (dummyt d  WITH seq = cmndata->cnt)
  SET m.driver_script_name = cmndata->qual[d.seq].newdriverscript, m.parameter_txt = cmndata->qual[d
   .seq].newparamtxt, m.updt_applctx = reqinfo->updt_applctx,
   m.updt_cnt = (m.updt_cnt+ 1), m.updt_dt_tm = cnvtdatetime(sysdate), m.updt_id = reqinfo->updt_id,
   m.updt_task = reqinfo->updt_task
  PLAN (d
   WHERE (cmndata->qual[d.seq].changeind=1))
   JOIN (m
   WHERE (m.mp_mpage_def_id=cmndata->qual[d.seq].mpmpagedefid))
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Error updating MP_MPAGE_DEF - ",errmsg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme updated all possible MP_MPAGE_DEF table data"
#exit_script
 IF ((readme_data->status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
