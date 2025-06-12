CREATE PROGRAM ags_log_header:dba
 IF (validate(ags_log_header_defined,0)=0)
  DECLARE ags_log_header_defined = i2 WITH constant(1), persistscript
  CALL echo("")
  CALL echo("<=== AGS_LOG_HEADER.PRG Begin ===>")
  CALL echo("MOD:000 10/23/06")
  CALL echo("")
  CALL echo("  Initializing global AGS subroutines")
  DECLARE ags_log_msg(eloglevel=i2,dtableid=f8,elogapp=i2,elogerror=i2,eelement=i2,
   smsg=vc) = null WITH copy
  DECLARE ags_set_status_block(eoperationname=i2,eoperationstatus=i2,stargetobjectname=vc,
   stargetobjectvalue=vc) = null WITH copy
  DECLARE set_log_level(request_level=i2) = null WITH copy
  DECLARE ags_log_status(dummy) = i2 WITH copy
  DECLARE get_script_status(dummy) = i2 WITH copy
  DECLARE get_char_debuglog(edebuglevel=i2) = vc WITH copy
  DECLARE get_char_status(estatus=i2) = c1 WITH copy
  DECLARE get_status_prefix(estatus=i2) = vc WITH copy
  CALL echo("  Initializing global AGS Log variables")
  DECLARE ihigheststatus = i2 WITH noconstant(0), persistscript
  DECLARE ags_log_grp_id = f8 WITH noconstant(0.0), persistscript
  DECLARE log_file_name = vc WITH noconstant(""), persistscript
  IF ((validate(false,- (1))=- (1)))
   DECLARE false = i2 WITH noconstant(0), persistscript
  ENDIF
  IF ((validate(true,- (1))=- (1)))
   DECLARE true = i2 WITH noconstant(1), persistscript
  ENDIF
  DECLARE serrmsg = vc WITH noconstant(""), persistscript
  DECLARE ierrcode = i2 WITH noconstant(0), persistscript
  DECLARE agsappcodeset = i4 WITH constant(4002007), persistscript
  DECLARE agsloglevelcodeset = i4 WITH constant(4002006), persistscript
  DECLARE agselementcodeset = i4 WITH constant(4002005), persistscript
  DECLARE agslogcodeset = i4 WITH constant(4002004), persistscript
  DECLARE egen_nbr = i2 WITH constant(1), persistscript
  DECLARE einsert = i2 WITH constant(2), persistscript
  DECLARE eupdate = i2 WITH constant(3), persistscript
  DECLARE edelete = i2 WITH constant(4), persistscript
  DECLARE eattribute = i2 WITH constant(5), persistscript
  DECLARE eselect = i2 WITH constant(6), persistscript
  DECLARE ecustom = i2 WITH constant(7), persistscript
  DECLARE esuccessful = i2 WITH constant(0), persistscript
  DECLARE einfo = i2 WITH constant(1), persistscript
  DECLARE ezero = i2 WITH constant(2), persistscript
  DECLARE ewarning = i2 WITH constant(3), persistscript
  DECLARE eerror = i2 WITH constant(4), persistscript
  DECLARE efailure = i2 WITH constant(5), persistscript
  DECLARE epersonload = i2 WITH constant(1), persistscript
  DECLARE eprsnlload = i2 WITH constant(2), persistscript
  DECLARE eorgload = i2 WITH constant(3), persistscript
  DECLARE eclaimload = i2 WITH constant(4), persistscript
  DECLARE eclaimdetload = i2 WITH constant(5), persistscript
  DECLARE ebenefitload = i2 WITH constant(6), persistscript
  DECLARE emedsload = i2 WITH constant(7), persistscript
  DECLARE eimmunload = i2 WITH constant(8), persistscript
  DECLARE eresultload = i2 WITH constant(9), persistscript
  DECLARE emergeload = i2 WITH constant(10), persistscript
  FREE RECORD app_cds
  RECORD app_cds(
    1 qual_knt = i4
    1 qual[*]
      2 dappcd = f8
      2 cmeaning = c12
  ) WITH persistscript
  SET app_cds->qual_knt = 10
  SET stat = alterlist(app_cds->qual,app_cds->qual_knt)
  SET app_cds->qual[epersonload].dappcd = ags_get_code_by("MEANING",agsappcodeset,"AGSPRSNLOAD")
  SET app_cds->qual[eprsnlload].dappcd = ags_get_code_by("MEANING",agsappcodeset,"AGSPRSNLLOAD")
  SET app_cds->qual[eorgload].dappcd = ags_get_code_by("MEANING",agsappcodeset,"AGSORGLOAD")
  SET app_cds->qual[eclaimload].dappcd = ags_get_code_by("MEANING",agsappcodeset,"AGSCLMLOAD")
  SET app_cds->qual[eclaimdetload].dappcd = ags_get_code_by("MEANING",agsappcodeset,"AGSCLMDTLOAD")
  SET app_cds->qual[ebenefitload].dappcd = ags_get_code_by("MEANING",agsappcodeset,"AGSBENFTLOAD")
  SET app_cds->qual[emedsload].dappcd = ags_get_code_by("MEANING",agsappcodeset,"AGSMEDSLOAD")
  SET app_cds->qual[eimmunload].dappcd = ags_get_code_by("MEANING",agsappcodeset,"AGSIMMUNLOAD")
  SET app_cds->qual[eresultload].dappcd = ags_get_code_by("MEANING",agsappcodeset,"AGSRESLOAD")
  SET app_cds->qual[emergeload].dappcd = ags_get_code_by("MEANING",agsappcodeset,"AGSMRGLOAD")
  SET app_cds->qual[epersonload].cmeaning = "AGSPRSNLOAD"
  SET app_cds->qual[eprsnlload].cmeaning = "AGSPRSNLLOAD"
  SET app_cds->qual[eorgload].cmeaning = "AGSORGLOAD"
  SET app_cds->qual[eclaimload].cmeaning = "AGSCLMLOAD"
  SET app_cds->qual[eclaimdetload].cmeaning = "AGSCLMDTLOAD"
  SET app_cds->qual[ebenefitload].cmeaning = "AGSBENFTLOAD"
  SET app_cds->qual[emedsload].cmeaning = "AGSMEDSLOAD"
  SET app_cds->qual[eimmunload].cmeaning = "AGSIMMUNLOAD"
  SET app_cds->qual[eresultload].cmeaning = "AGSRESLOAD"
  SET app_cds->qual[emergeload].cmeaning = "AGSMRGLOAD"
  FOR (idx = 1 TO app_cds->qual_knt)
    IF ((app_cds->qual[idx].dappcd < 1))
     CALL ags_set_status_block(eattribute,efailure,"APP_CDS",concat("CODE_VALUE for meaning ",app_cds
       ->qual[idx].cmeaning," invalid from CODE_SET 4002007"))
    ENDIF
  ENDFOR
  DECLARE emissing = i2 WITH constant(1), persistscript
  DECLARE elookup = i2 WITH constant(2), persistscript
  DECLARE emultiple = i2 WITH constant(3), persistscript
  DECLARE emessage = i2 WITH constant(4), persistscript
  FREE RECORD log_cds
  RECORD log_cds(
    1 qual_knt = i4
    1 qual[*]
      2 dlogcd = f8
      2 cmeaning = c12
  ) WITH persistscript
  SET log_cds->qual_knt = 4
  SET stat = alterlist(log_cds->qual,log_cds->qual_knt)
  SET log_cds->qual[emissing].dlogcd = ags_get_code_by("MEANING",agslogcodeset,"MISSINGELEMT")
  SET log_cds->qual[elookup].dlogcd = ags_get_code_by("MEANING",agslogcodeset,"LOOKUPFAILED")
  SET log_cds->qual[emultiple].dlogcd = ags_get_code_by("MEANING",agslogcodeset,"LOOKUPFNDMLT")
  SET log_cds->qual[emessage].dlogcd = ags_get_code_by("MEANING",agslogcodeset,"MESSAGE")
  SET log_cds->qual[emissing].cmeaning = "MISSINGELEMT"
  SET log_cds->qual[elookup].cmeaning = "LOOKUPFAILED"
  SET log_cds->qual[emultiple].cmeaning = "LOOKUPFNDMLT"
  SET log_cds->qual[emessage].cmeaning = "MESSAGE"
  FOR (idx = 1 TO log_cds->qual_knt)
    IF ((log_cds->qual[idx].dlogcd < 1))
     CALL ags_set_status_block(eattribute,efailure,"LOG_CDS",concat("CODE_VALUE for meaning ",log_cds
       ->qual[idx].cmeaning," invalid from CODE_SET 4002004"))
    ENDIF
  ENDFOR
  DECLARE esendfacility = i2 WITH constant(1), persistscript
  DECLARE eextalias = i2 WITH constant(2), persistscript
  DECLARE essnalias = i2 WITH constant(3), persistscript
  DECLARE edeaalias = i2 WITH constant(4), persistscript
  DECLARE eupinalias = i2 WITH constant(5), persistscript
  DECLARE eordextalias = i2 WITH constant(6), persistscript
  DECLARE eunitofmeasure = i2 WITH constant(7), persistscript
  DECLARE eeventcd = i2 WITH constant(8), persistscript
  DECLARE eperfextalias = i2 WITH constant(9), persistscript
  DECLARE eperfentalias = i2 WITH constant(10), persistscript
  DECLARE enamelast = i2 WITH constant(11), persistscript
  DECLARE enamefirst = i2 WITH constant(12), persistscript
  DECLARE enamemiddle = i2 WITH constant(13), persistscript
  DECLARE egender = i2 WITH constant(14), persistscript
  DECLARE ehistnamelast = i2 WITH constant(15), persistscript
  DECLARE ehistnamefirst = i2 WITH constant(16), persistscript
  DECLARE ehistnamemidl = i2 WITH constant(17), persistscript
  DECLARE ehistgender = i2 WITH constant(18), persistscript
  DECLARE ebirthdate = i2 WITH constant(19), persistscript
  DECLARE eattextalias = i2 WITH constant(20), persistscript
  DECLARE eadmtextalias = i2 WITH constant(21), persistscript
  DECLARE ebillextalias = i2 WITH constant(22), persistscript
  DECLARE eplaceofserv = i2 WITH constant(23), persistscript
  DECLARE eprocnomen = i2 WITH constant(24), persistscript
  DECLARE ediagnomen = i2 WITH constant(25), persistscript
  FREE RECORD element_cds
  RECORD element_cds(
    1 qual_knt = i4
    1 qual[*]
      2 delementcd = f8
      2 cmeaning = vc
  ) WITH persistscript
  SET element_cds->qual_knt = 25
  SET stat = alterlist(element_cds->qual,element_cds->qual_knt)
  SET element_cds->qual[esendfacility].delementcd = ags_get_code_by("MEANING",agselementcodeset,
   "SENDFACILITY")
  SET element_cds->qual[eextalias].delementcd = ags_get_code_by("MEANING",agselementcodeset,
   "EXTALIAS")
  SET element_cds->qual[essnalias].delementcd = ags_get_code_by("MEANING",agselementcodeset,
   "SSNALIAS")
  SET element_cds->qual[edeaalias].delementcd = ags_get_code_by("MEANING",agselementcodeset,
   "DEAALIAS")
  SET element_cds->qual[eupinalias].delementcd = ags_get_code_by("MEANING",agselementcodeset,
   "UPINALIAS")
  SET element_cds->qual[eordextalias].delementcd = ags_get_code_by("MEANING",agselementcodeset,
   "ORDEXTALIAS")
  SET element_cds->qual[eunitofmeasure].delementcd = ags_get_code_by("MEANING",agselementcodeset,
   "UNITOFMEAS")
  SET element_cds->qual[eeventcd].delementcd = ags_get_code_by("MEANING",agselementcodeset,"EVENTCD")
  SET element_cds->qual[eperfextalias].delementcd = ags_get_code_by("MEANING",agselementcodeset,
   "PERFEXTALIAS")
  SET element_cds->qual[eperfentalias].delementcd = ags_get_code_by("MEANING",agselementcodeset,
   "PERFENTALIAS")
  SET element_cds->qual[enamelast].delementcd = ags_get_code_by("MEANING",agselementcodeset,
   "NAMELAST")
  SET element_cds->qual[enamefirst].delementcd = ags_get_code_by("MEANING",agselementcodeset,
   "NAMEFIRST")
  SET element_cds->qual[enamemiddle].delementcd = ags_get_code_by("MEANING",agselementcodeset,
   "NAMEMIDDLE")
  SET element_cds->qual[egender].delementcd = ags_get_code_by("MEANING",agselementcodeset,"GENDER")
  SET element_cds->qual[ehistnamelast].delementcd = ags_get_code_by("MEANING",agselementcodeset,
   "HISTNAMELAST")
  SET element_cds->qual[ehistnamefirst].delementcd = ags_get_code_by("MEANING",agselementcodeset,
   "HISTNAMEFRST")
  SET element_cds->qual[ehistnamemidl].delementcd = ags_get_code_by("MEANING",agselementcodeset,
   "HISTNAMEMIDL")
  SET element_cds->qual[ehistgender].delementcd = ags_get_code_by("MEANING",agselementcodeset,
   "HISTGENDER")
  SET element_cds->qual[ebirthdate].delementcd = ags_get_code_by("MEANING",agselementcodeset,
   "BIRTHDATE")
  SET element_cds->qual[eattextalias].delementcd = ags_get_code_by("MEANING",agselementcodeset,
   "ATTEXTALIAS")
  SET element_cds->qual[eadmtextalias].delementcd = ags_get_code_by("MEANING",agselementcodeset,
   "ADMTEXTALIAS")
  SET element_cds->qual[ebillextalias].delementcd = ags_get_code_by("MEANING",agselementcodeset,
   "BILLEXTALIAS")
  SET element_cds->qual[eplaceofserv].delementcd = ags_get_code_by("MEANING",agselementcodeset,
   "PLACEOFSERV")
  SET element_cds->qual[eprocnomen].delementcd = ags_get_code_by("MEANING",agselementcodeset,
   "PROCNOMEN")
  SET element_cds->qual[ediagnomen].delementcd = ags_get_code_by("MEANING",agselementcodeset,
   "DIAGNOMEN")
  SET element_cds->qual[esendfacility].cmeaning = "SENDFACILITY"
  SET element_cds->qual[eextalias].cmeaning = "EXTALIAS"
  SET element_cds->qual[essnalias].cmeaning = "SSNALIAS"
  SET element_cds->qual[edeaalias].cmeaning = "DEAALIAS"
  SET element_cds->qual[eupinalias].cmeaning = "UPINALIAS"
  SET element_cds->qual[eordextalias].cmeaning = "ORDEXTALIAS"
  SET element_cds->qual[eunitofmeasure].cmeaning = "UNITOFMEAS"
  SET element_cds->qual[eeventcd].cmeaning = "EVENTCD"
  SET element_cds->qual[eperfextalias].cmeaning = "PERFEXTALIAS"
  SET element_cds->qual[eperfentalias].cmeaning = "PERFENTALIAS"
  SET element_cds->qual[enamelast].cmeaning = "NAMELAST"
  SET element_cds->qual[enamefirst].cmeaning = "NAMEFIRST"
  SET element_cds->qual[enamemiddle].cmeaning = "NAMEMIDDLE"
  SET element_cds->qual[egender].cmeaning = "GENDER"
  SET element_cds->qual[ehistnamelast].cmeaning = "HISTNAMELAST"
  SET element_cds->qual[ehistnamefirst].cmeaning = "HISTNAMEFRST"
  SET element_cds->qual[ehistnamemidl].cmeaning = "HISTNAMEMIDL"
  SET element_cds->qual[ehistgender].cmeaning = "HISTGENDER"
  SET element_cds->qual[ebirthdate].cmeaning = "BIRTHDATE"
  SET element_cds->qual[eattextalias].cmeaning = "ATTEXTALIAS"
  SET element_cds->qual[eadmtextalias].cmeaning = "ADMTEXTALIAS"
  SET element_cds->qual[ebillextalias].cmeaning = "BILLEXTALIAS"
  SET element_cds->qual[eplaceofserv].cmeaning = "PLACEOFSERV"
  SET element_cds->qual[eprocnomen].cmeaning = "PROCNOMEN"
  SET element_cds->qual[ediagnomen].cmeaning = "DIAGNOMEN"
  FOR (idx = 1 TO element_cds->qual_knt)
    IF ((element_cds->qual[idx].delementcd < 1))
     CALL ags_set_status_block(eattribute,efailure,concat("ELEMENT_CDS ",cnvtstring(idx)),concat(
       "CODE_VALUE for meaning ",element_cds->qual[idx].cmeaning," invalid from CODE_SET 4002005"))
    ENDIF
  ENDFOR
  DECLARE elogofflevel = i2 WITH constant(0), persistscript
  DECLARE eerrorlevel = i2 WITH constant(1), persistscript
  DECLARE ewarninglevel = i2 WITH constant(2), persistscript
  DECLARE eauditlevel = i2 WITH constant(3), persistscript
  DECLARE einfolevel = i2 WITH constant(4), persistscript
  DECLARE edebuglevel = i2 WITH constant(5), persistscript
  FREE RECORD log_level_cds
  RECORD log_level_cds(
    1 qual_knt = i4
    1 qual[*]
      2 dloglevelcd = f8
      2 cmeaning = c12
  ) WITH persistscript
  SET log_level_cds->qual_knt = 5
  SET stat = alterlist(log_level_cds->qual,log_level_cds->qual_knt)
  SET log_level_cds->qual[eerrorlevel].dloglevelcd = ags_get_code_by("MEANING",agsloglevelcodeset,
   "ERROR")
  SET log_level_cds->qual[ewarninglevel].dloglevelcd = ags_get_code_by("MEANING",agsloglevelcodeset,
   "WARNING")
  SET log_level_cds->qual[eauditlevel].dloglevelcd = ags_get_code_by("MEANING",agsloglevelcodeset,
   "AUDIT")
  SET log_level_cds->qual[einfolevel].dloglevelcd = ags_get_code_by("MEANING",agsloglevelcodeset,
   "INFO")
  SET log_level_cds->qual[edebuglevel].dloglevelcd = ags_get_code_by("MEANING",agsloglevelcodeset,
   "DEBUG")
  SET log_level_cds->qual[eerrorlevel].cmeaning = "ERROR"
  SET log_level_cds->qual[ewarninglevel].cmeaning = "WARNING"
  SET log_level_cds->qual[eauditlevel].cmeaning = "AUDIT"
  SET log_level_cds->qual[einfolevel].cmeaning = "INFO"
  SET log_level_cds->qual[edebuglevel].cmeaning = "DEBUG"
  FOR (idx = 1 TO log_level_cds->qual_knt)
    IF ((log_level_cds->qual[idx].dloglevelcd < 1))
     CALL ags_set_status_block(eattribute,efailure,"LOG_LEVEL_CDS",concat("CODE_VALUE for meaning ",
       log_level_cds->qual[idx].cmeaning," invalid from CODE_SET 4002006"))
    ENDIF
  ENDFOR
  DECLARE gdebuglogging = i2 WITH noconstant(0), persistscript
  SET trace = nocallecho
  SET trace = noechorecord
  SET trace = nordbprogram
  SET trace = nosrvuint
  SET trace = nocost
  SET message = noinformation
  CALL ags_set_status_block(ecustom,esuccessful,"","Script defaults to Success")
  SUBROUTINE set_log_level(request_level)
    CALL echo("")
    CALL echo("  <== Set_Log_Level() ==>")
    SET gdebuglogging = request_level
    CALL echo(concat("  gDebugLogging = ",cnvtstring(gdebuglogging)))
    IF (gdebuglogging > elogofflevel)
     SET trace = callecho
     IF (gdebuglogging >= eauditlevel)
      SET trace = rdbprogram
      SET trace = cost
     ENDIF
     IF (gdebuglogging >= einfolevel)
      SET message = information
     ENDIF
     IF (gdebuglogging >= edebuglevel)
      SET trace = srvuint
      SET trace = echorecord
     ENDIF
    ENDIF
  END ;Subroutine
  SUBROUTINE get_script_status(dummy)
    CALL echo("")
    CALL echo("  <=== Get_Script_Status() ===>")
    RETURN(ihigheststatus)
  END ;Subroutine
  SUBROUTINE ags_log_msg(eloglevel,dtableid,elogapp,elogerror,eelement,smsg)
    DECLARE app_cd = f8 WITH public, noconstant(0.0)
    DECLARE level_cd = f8 WITH public, noconstant(0.0)
    DECLARE log_cd = f8 WITH public, noconstant(0.0)
    DECLARE element_cd = f8 WITH public, noconstant(0.0)
    DECLARE log_id = f8 WITH public, noconstant(0.0)
    CALL echo("")
    CALL echo("  <=== AGS_Log_Msg() ===>")
    IF (gdebuglogging >= eloglevel)
     SET level_cd = log_level_cds->qual[eloglevel].dloglevelcd
     IF (elogapp > 0)
      SET app_cd = app_cds->qual[elogapp].dappcd
     ENDIF
     IF (elogerror > 0)
      SET log_cd = log_cds->qual[elogerror].dlogcd
     ENDIF
     IF (eelement > 0)
      SET element_cd = element_cds->qual[eelement].delementcd
     ENDIF
     IF (ags_log_grp_id=0.0)
      SELECT INTO "nl:"
       y = seq(gs_seq,nextval)
       FROM dual
       DETAIL
        ags_log_grp_id = cnvtreal(y)
       WITH nocounter
      ;end select
      SET log_file_name = concat(ags_get_code_display(app_cd),"_",format(cnvtdatetime(curdate,
         curtime3),"yyyymmddhhmm;;q"),".log")
     ENDIF
     SELECT INTO "nl:"
      y = seq(gs_seq,nextval)
      FROM dual
      DETAIL
       log_id = cnvtreal(y)
      WITH nocounter
     ;end select
     INSERT  FROM ags_log a
      SET a.ags_log_id = log_id, a.ags_log_grp_id = ags_log_grp_id, a.ags_job_id = working_job_id,
       a.ags_table_id = dtableid, a.ags_logging_app_cd = app_cd, a.log_level_cd = level_cd,
       a.log_cd = log_cd, a.element_cd = element_cd, a.message = smsg
      WITH nocounter
     ;end insert
     IF (gdebuglogging >= edebuglevel)
      FREE SET output_log
      SET logical output_log value(nullterm(concat("cer_log:",trim(cnvtlower(log_file_name)))))
      SELECT INTO output_log
       FROM (dummyt d  WITH seq = 1)
       HEAD REPORT
        out_line = fillstring(254," ")
       DETAIL
        out_line = trim(substring(1,254,concat(get_char_debuglog(eloglevel)," :: ",format(
            cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;q")," :: Table ID ",trim(cnvtstring
            (dtableid)),
           " :: ",ags_get_code_display(log_cd)," :: ",ags_get_code_display(element_cd)))), col 0,
        out_line
       WITH nocounter, nullreport, formfeed = none,
        format = crstream, append, maxcol = 255,
        maxrow = 1
      ;end select
     ENDIF
    ENDIF
  END ;Subroutine
  SUBROUTINE ags_set_status_block(eoperationname,eoperationstatus,stargetobjectname,
   stargetobjectvalue)
    CALL echo("")
    CALL echo("  <=== AGS_Set_Status_Block() ===>")
    IF (validate(reply,"!")="!")
     CALL echo("No incoming Reply record detected")
    ELSE
     FREE SET t_x
     DECLARE t_x = i4
     SET t_x = (size(reply->status_data.subeventstatus,5)+ 1)
     SET stat = alterlist(reply->status_data.subeventstatus,t_x)
     SET reply->status_data.subeventstatus[t_x].operationstatus = get_char_status(eoperationstatus)
     IF (trim(stargetobjectname,3) > "")
      SET reply->status_data.subeventstatus[t_x].targetobjectname = trim(stargetobjectname,3)
     ENDIF
     CASE (eoperationname)
      OF egen_nbr:
       SET reply->status_data.subeventstatus[t_x].operationname = "GENNBR"
      OF einsert:
       SET reply->status_data.subeventstatus[t_x].operationname = "INSERT"
      OF eupdate:
       SET reply->status_data.subeventstatus[t_x].operationname = "UPDATE"
      OF edelete:
       SET reply->status_data.subeventstatus[t_x].operationname = "DELETE"
      OF eattribute:
       SET reply->status_data.subeventstatus[t_x].operationname = "ATTRIBUTE"
      OF eselect:
       SET reply->status_data.subeventstatus[t_x].operationname = "SELECT"
      OF ecustom:
       SET reply->status_data.subeventstatus[t_x].operationname = "CUSTOM"
      ELSE
       SET reply->status_data.subeventstatus[t_x].operationname = "UNKNOWN"
     ENDCASE
     IF (trim(stargetobjectvalue,3) > "")
      SET stargetobjectvalue = concat(get_status_prefix(eoperationstatus)," ",trim(stargetobjectvalue,
        3))
      SET s_pos = 1
      SET c_pos = 80
      SET e_pos = size(trim(stargetobjectvalue,3))
      WHILE (s_pos < e_pos)
        SET stat = alterlist(reply->status_data.subeventstatus,t_x)
        SET reply->status_data.subeventstatus[t_x].targetobjectvalue = substring(s_pos,minval(c_pos,
          e_pos),stargetobjectvalue)
        SET s_pos = (c_pos+ 1)
        SET c_pos = (c_pos+ 80)
        SET t_x = (size(reply->status_data.subeventstatus,5)+ 1)
      ENDWHILE
     ENDIF
     IF (ihigheststatus <= eoperationstatus)
      CASE (eoperationstatus)
       OF einfo:
        SET ihigheststatus = esuccessful
       OF esuccessful:
        SET ihigheststatus = esuccessful
       OF ewarning:
        SET ihigheststatus = esuccessful
       OF ezero:
        SET ihigheststatus = ezero
       OF eerror:
        SET ihigheststatus = efailure
       OF efailure:
        SET ihigheststatus = efailure
      ENDCASE
      SET reply->status_data.status = get_char_status(ihigheststatus)
     ENDIF
    ENDIF
  END ;Subroutine
  SUBROUTINE get_char_debuglog(edebuglevel)
    FREE SET slevel
    DECLARE slevel = vc
    CASE (edebuglevel)
     OF elogofflevel:
      SET slevel = "OFF"
     OF eerrorlevel:
      SET slevel = "ERROR"
     OF ewarninglevel:
      SET slevel = "WARNING"
     OF eauditlevel:
      SET slevel = "AUDIT"
     OF einfolevel:
      SET slevel = "INFO"
     OF edebuglevel:
      SET slevel = "DEBUG"
     ELSE
      CALL echo("     Logging Level Unknown")
    ENDCASE
    RETURN(slevel)
  END ;Subroutine
  SUBROUTINE get_char_status(estatus)
    FREE SET cchar
    DECLARE cchar = c1
    SET cchar = "Z"
    CASE (estatus)
     OF einfo:
      SET cchar = "I"
     OF esuccessful:
      SET cchar = "S"
     OF ezero:
      SET cchar = "Z"
     OF ewarning:
      SET cchar = "W"
     OF eerror:
      SET cchar = "E"
     OF efailure:
      SET cchar = "F"
     ELSE
      CALL echo("   Operation Status Unknown")
    ENDCASE
    RETURN(cchar)
  END ;Subroutine
  SUBROUTINE get_status_prefix(estatus)
    FREE SET sprefix
    DECLARE sprefix = vc
    CASE (estatus)
     OF einfo:
      SET sprefix = "INFO"
     OF esuccessful:
      SET sprefix = "SUCCESSFUL"
     OF ezero:
      SET sprefix = "ZERO"
     OF ewarning:
      SET sprefix = "*WARNING*"
     OF eerror:
      SET sprefix = "!ERROR!"
     OF efailure:
      SET sprefix = "!!FAILURE!!"
     ELSE
      CALL echo("   OperationStatus Unknown ")
    ENDCASE
    RETURN(sprefix)
  END ;Subroutine
  SUBROUTINE ags_log_status(dummy)
    CALL echo("")
    CALL echo("  <=== AGS_LOG_STATUS() Begin ===>")
    DECLARE ags_status = i2 WITH noconstant(0)
    CALL echo(concat("debuglogging = ",cnvtstring(get_char_debuglog(gdebuglogging))))
    IF (validate(request,"!") != "!")
     CALL echorecord(request)
    ENDIF
    IF (validate(reply,"!") != "!")
     CALL echorecord(reply)
    ENDIF
    IF (get_script_status(0)=efailure)
     CALL echo("  *** rollback ***")
     SET ags_status = 0
     ROLLBACK
    ELSE
     CALL echo("   !!! COMMIT !!!!")
     SET ags_status = 1
     COMMIT
    ENDIF
    SET message = information
    SET trace = callecho
    SET trace = echorecord
    RETURN(ags_status)
  END ;Subroutine
  CALL echo("")
  CALL echo("<=== AGS_LOG_HEADER.PRG End ===>")
 ENDIF
END GO
