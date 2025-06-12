CREATE PROGRAM bhs_eventcdlist_temp_tables:dba
 CALL echo("define")
 CALL echo("select into")
 DECLARE temp_cd = f8 WITH public, constant(validatecodevalue("DISPLAY_KEY",72,"TEMPERATURE"))
 DECLARE hr_cd = f8 WITH public, constant(validatecodevalue("DISPLAY_KEY",72,"PULSERATE"))
 DECLARE sbp_cd = f8 WITH public, constant(validatecodevalue("DISPLAY_KEY",72,"SYSTOLICBLOODPRESSURE"
   ))
 DECLARE rr_cd = f8 WITH public, constant(validatecodevalue("DISPLAY_KEY",72,"RESPIRATORYRATE"))
 DECLARE o2sat_cd = f8 WITH public, constant(validatecodevalue("DISPLAY_KEY",72,"OXYGENSATURATION"))
 DECLARE lpm_cd = f8 WITH public, constant(validatecodevalue("DISPLAY_KEY",72,"LITERSPERMINUTE"))
 DECLARE nonrebreather_cd = f8 WITH public, constant(validatecodevalue("DISPLAY_KEY",200,
   "OXYGENVIANONREBREATHER"))
 DECLARE partnonrebreather_cd = f8 WITH public, constant(validatecodevalue("DISPLAY_KEY",200,
   "OXYGENVIAPARTIALREBREATHER"))
 DECLARE o2viamask_cd = f8 WITH public, constant(validatecodevalue("DISPLAY_KEY",200,"OXYGENVIAMASK")
  )
 DECLARE sodium_cd = f8 WITH public, constant(validatecodevalue("DISPLAY_KEY",72,"SODIUM"))
 DECLARE bili_cd = f8 WITH public, constant(validatecodevalue("DISPLAY_KEY",72,"BILIRUBINTOTAL"))
 DECLARE platelet_cd = f8 WITH public, constant(validatecodevalue("DISPLAY_KEY",72,"PLATELETCOUNT"))
 DECLARE glucose_cd = f8 WITH public, constant(validatecodevalue("DISPLAY_KEY",72,"GLUCOSELEVEL"))
 DECLARE glucosepoc_cd = f8 WITH public, constant(710167.00)
 DECLARE creatinine_cd = f8 WITH public, constant(validatecodevalue("DISPLAY",72,"Creatinine-Blood"))
 DECLARE lactate_cd = f8 WITH public, constant(validatecodevalue("DISPLAY_KEY",72,"LACTATE"))
 DECLARE wbc_cd = f8 WITH public, constant(validatecodevalue("DISPLAY_KEY",72,"WBC"))
 DECLARE band_cd = f8 WITH public, constant(validatecodevalue("DISPLAY_KEY",72,"BAND"))
 DECLARE ph_cd = f8 WITH public, constant(validatecodevalue("DISPLAY_KEY",72,"PH"))
 SUBROUTINE validatecodevalue(type,codeset,val)
   SET codeval = 0.0
   SET codeval = uar_get_code_by(value(type),codeset,value(val))
   IF (codeval <= 0)
    SET errmsg = concat("failed finding code_val - type: ",type," codeset:",build(codeset)," val:",
     val)
    GO TO exit_program
   ELSE
    CALL echo(concat("type: ",type," codeset:",build(codeset)," val:",
      val," Code_value=",cnvtstring(codeval)))
   ENDIF
   RETURN(codeval)
 END ;Subroutine
 SUBROUTINE sequence(temp)
   SET early_warning_id = 0
   SELECT INTO "nl:"
    nextid = seq(bhs_eks_seq,nextval)
    FROM dual d
    DETAIL
     early_warning_id = nextid
    WITH nocounter
   ;end select
   RETURN(early_warning_id)
 END ;Subroutine
 CALL echo("create eventcdlist table")
 FREE RECORD list
 RECORD list(
   1 list = vc
   1 listkey = vc
   1 active_ind = i4
   1 updt_id = f8
   1 updt_dt_tm = dq8
   1 qual[*]
     2 listtype = vc
     2 event_cd_list_id = f8
     2 grouper_id = i4
     2 event_cd = f8
 )
 SET cnt = 0
 SET list->list = ""
 SET list->listkey = ""
 SET list->active_ind = 0
 SET list->updt_id = 0.0
 SET list->updt_dt_tm = cnvtdatetime(curdate,curtime)
 SET list->list = ""
 SET list->listkey = ""
 SET list->active_ind = 0
 SET list->updt_id = 0.0
 SET list->updt_dt_tm = cnvtdatetime(curdate,curtime)
 SET cnt = (cnt+ 1)
 SET stat = alterlist(list->qual,cnt)
 SET list->qual[cnt].event_cd_list_id = 0
 SET list->qual[cnt].grouper_id = 0
 SET list->qual[cnt].event_cd = 0
 SET list->list = "Adult Early Warning System"
 SET tempv = replace(cnvtupper(list->list),"ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
  "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",3)
 SET list->listkey = tempv
 SET list->active_ind = 1
 SET list->updt_id = 0.0
 SET list->updt_dt_tm = cnvtdatetime(curdate,curtime)
 SET cnt = (cnt+ 1)
 SET stat = alterlist(list->qual,cnt)
 SET list->qual[cnt].event_cd_list_id = sequence(0)
 SET list->qual[cnt].grouper_id = 1
 SET list->qual[cnt].event_cd = temp_cd
 SET list->qual[cnt].listtype = "VITALS"
 SET cnt = (cnt+ 1)
 SET stat = alterlist(list->qual,cnt)
 SET list->qual[cnt].event_cd_list_id = sequence(0)
 SET list->qual[cnt].grouper_id = cnt
 SET list->qual[cnt].event_cd = hr_cd
 SET list->qual[cnt].listtype = "VITALS"
 SET cnt = (cnt+ 1)
 SET stat = alterlist(list->qual,cnt)
 SET list->qual[cnt].event_cd_list_id = sequence(0)
 SET list->qual[cnt].grouper_id = cnt
 SET list->qual[cnt].event_cd = sbp_cd
 SET list->qual[cnt].listtype = "VITALS"
 SET cnt = (cnt+ 1)
 SET stat = alterlist(list->qual,cnt)
 SET list->qual[cnt].event_cd_list_id = sequence(0)
 SET list->qual[cnt].grouper_id = cnt
 SET list->qual[cnt].event_cd = rr_cd
 SET list->qual[cnt].listtype = "VITALS"
 SET cnt = (cnt+ 1)
 SET stat = alterlist(list->qual,cnt)
 SET list->qual[cnt].event_cd_list_id = sequence(0)
 SET list->qual[cnt].grouper_id = cnt
 SET list->qual[cnt].event_cd = o2sat_cd
 SET list->qual[cnt].listtype = "VITALS"
 SET cnt = (cnt+ 1)
 SET stat = alterlist(list->qual,cnt)
 SET list->qual[cnt].event_cd_list_id = sequence(0)
 SET list->qual[cnt].grouper_id = cnt
 SET list->qual[cnt].event_cd = glucose_cd
 SET list->qual[cnt].listtype = "LABS"
 SET cnt = (cnt+ 1)
 SET stat = alterlist(list->qual,cnt)
 SET list->qual[cnt].event_cd_list_id = sequence(0)
 SET list->qual[cnt].grouper_id = (cnt - 1)
 SET list->qual[cnt].event_cd = glucosepoc_cd
 SET list->qual[cnt].listtype = "LABS"
 SET cnt = (cnt+ 1)
 SET stat = alterlist(list->qual,cnt)
 SET list->qual[cnt].event_cd_list_id = sequence(0)
 SET list->qual[cnt].grouper_id = cnt
 SET list->qual[cnt].event_cd = lpm_cd
 SET list->qual[cnt].listtype = "LABS"
 SET cnt = (cnt+ 1)
 SET stat = alterlist(list->qual,cnt)
 SET list->qual[cnt].event_cd_list_id = sequence(0)
 SET list->qual[cnt].grouper_id = cnt
 SET list->qual[cnt].event_cd = nonrebreather_cd
 SET list->qual[cnt].listtype = "LABS"
 SET cnt = (cnt+ 1)
 SET stat = alterlist(list->qual,cnt)
 SET list->qual[cnt].event_cd_list_id = sequence(0)
 SET list->qual[cnt].grouper_id = cnt
 SET list->qual[cnt].event_cd = partnonrebreather_cd
 SET list->qual[cnt].listtype = "LABS"
 SET cnt = (cnt+ 1)
 SET stat = alterlist(list->qual,cnt)
 SET list->qual[cnt].event_cd_list_id = sequence(0)
 SET list->qual[cnt].grouper_id = cnt
 SET list->qual[cnt].event_cd = o2viamask_cd
 SET list->qual[cnt].listtype = "LABS"
 SET cnt = (cnt+ 1)
 SET stat = alterlist(list->qual,cnt)
 SET list->qual[cnt].event_cd_list_id = sequence(0)
 SET list->qual[cnt].grouper_id = cnt
 SET list->qual[cnt].event_cd = sodium_cd
 SET list->qual[cnt].listtype = "LABS"
 SET cnt = (cnt+ 1)
 SET stat = alterlist(list->qual,cnt)
 SET list->qual[cnt].event_cd_list_id = sequence(0)
 SET list->qual[cnt].grouper_id = cnt
 SET list->qual[cnt].event_cd = bili_cd
 SET list->qual[cnt].listtype = "LABS"
 SET cnt = (cnt+ 1)
 SET stat = alterlist(list->qual,cnt)
 SET list->qual[cnt].event_cd_list_id = sequence(0)
 SET list->qual[cnt].grouper_id = cnt
 SET list->qual[cnt].event_cd = platelet_cd
 SET list->qual[cnt].listtype = "LABS"
 SET cnt = (cnt+ 1)
 SET stat = alterlist(list->qual,cnt)
 SET list->qual[cnt].event_cd_list_id = sequence(0)
 SET list->qual[cnt].grouper_id = cnt
 SET list->qual[cnt].event_cd = creatinine_cd
 SET list->qual[cnt].listtype = "LABS"
 SET cnt = (cnt+ 1)
 SET stat = alterlist(list->qual,cnt)
 SET list->qual[cnt].event_cd_list_id = sequence(0)
 SET list->qual[cnt].grouper_id = cnt
 SET list->qual[cnt].event_cd = lactate_cd
 SET list->qual[cnt].listtype = "LABS"
 SET cnt = (cnt+ 1)
 SET stat = alterlist(list->qual,cnt)
 SET list->qual[cnt].event_cd_list_id = sequence(0)
 SET list->qual[cnt].grouper_id = cnt
 SET list->qual[cnt].event_cd = wbc_cd
 SET list->qual[cnt].listtype = "LABS"
 SET cnt = (cnt+ 1)
 SET stat = alterlist(list->qual,cnt)
 SET list->qual[cnt].event_cd_list_id = sequence(0)
 SET list->qual[cnt].grouper_id = cnt
 SET list->qual[cnt].event_cd = ph_cd
 SET list->qual[cnt].listtype = "LABS"
 SET cnt = (cnt+ 1)
 SET stat = alterlist(list->qual,cnt)
 SET list->qual[cnt].event_cd_list_id = sequence(0)
 SET list->qual[cnt].grouper_id = cnt
 SET list->qual[cnt].event_cd = band_cd
 SET list->qual[cnt].listtype = "LABS"
 DELETE  FROM bhs_event_cd_list b
  WHERE b.event_cd_list_id >= 0
 ;end delete
 COMMIT
 SET y = 1
 INSERT  FROM bhs_event_cd_list b
  SET b.event_cd_list_id = list->qual[y].event_cd_list_id, b.grouper = " ", b.grouper_id = list->
   qual[y].grouper_id,
   b.event_cd = list->qual[y].event_cd, b.list = " ", b.listkey = " ",
   b.active_ind = 0, b.updt_id = list->updt_id, b.updt_dt_tm = cnvtdatetime(list->updt_dt_tm)
  WITH nocounter
 ;end insert
 COMMIT
 IF (cnt > 1)
  CALL echo("Insert new rows")
  FOR (y = 2 TO cnt)
    CALL echo(list->qual[y].event_cd_list_id)
    INSERT  FROM bhs_event_cd_list e
     SET e.event_cd_list_id = list->qual[y].event_cd_list_id, e.grouper_id = list->qual[y].grouper_id,
      e.event_cd = list->qual[y].event_cd,
      e.grouper = list->qual[y].listtype, e.list = list->list, e.listkey = list->listkey,
      e.active_ind = list->active_ind, e.updt_id = list->updt_id, e.updt_dt_tm = cnvtdatetime(list->
       updt_dt_tm)
     PLAN (e)
     WITH nocounter
    ;end insert
    COMMIT
  ENDFOR
 ENDIF
 IF (curqual=0)
  CALL echo("failed")
  GO TO exit_program
 ENDIF
 COMMIT
#exit_program
END GO
