CREATE PROGRAM bhs_athn_write_dose_calc
 FREE RECORD result
 RECORD result(
   1 order_id = f8
   1 doseflag = vc
   1 dosecalculatoruseddttm = vc
   1 description = vc
   1 targetdose = vc
   1 targetdoseunitcd = vc
   1 targetdoseunitdisp = vc
   1 calculateddose = vc
   1 calculateddoseunitcd = vc
   1 calculateddoseunitdisp = vc
   1 calculatedvoldose = vc
   1 calculatedvoldoseunitcd = vc
   1 calculatedvoldoseunitdisp = vc
   1 reduceddose = vc
   1 reduceddoseunitcd = vc
   1 reduceddoseunitdisp = vc
   1 reducedvoldose = vc
   1 reducedvoldoseunitcd = vc
   1 reducedvoldoseunitdisp = vc
   1 percentagereduced = vc
   1 carryforwardpercentagereduced = vc
   1 finaldose = vc
   1 finaldoseunitcd = vc
   1 finaldoseunitdisp = vc
   1 finalvoldose = vc
   1 finalvoldoseunitcd = vc
   1 finalvoldoseunitdisp = vc
   1 actualfinaldose = vc
   1 actualfinaldoseunitcd = vc
   1 actualfinaldoseunitdisp = vc
   1 standarddose = vc
   1 standarddoseunitcd = vc
   1 standarddoseunitdisp = vc
   1 standardvoldose = vc
   1 standardvoldoseunitcd = vc
   1 standardvoldoseunitdisp = vc
   1 actualstandarddose = vc
   1 actualstandarddoseunitcd = vc
   1 actualstandarddoseunitdisp = vc
   1 roundingrulecd = vc
   1 roundingruledisp = vc
   1 ezdosecalculationtype = vc
   1 adjustreasoncd = vc
   1 adjustreasondisp = vc
   1 adjustreasonfreetext = vc
   1 silentinvoke = vc
   1 dob = vc
   1 birthdatetimedisp = vc
   1 ageinyears = vc
   1 ageinmonths = vc
   1 ageinweeks = vc
   1 ageindays = vc
   1 ageinhours = vc
   1 ageinminutes = vc
   1 carrydob = vc
   1 gendercd = vc
   1 genderdisp = vc
   1 racecd = vc
   1 racedisp = vc
   1 ethnicitycd = vc
   1 ethnicitydisp = vc
   1 height = vc
   1 heightunitcd = vc
   1 heightunitdisp = vc
   1 heightcaptureddttm = vc
   1 heightsourcecd = vc
   1 heightsourcedisp = vc
   1 weight = vc
   1 weightunitcd = vc
   1 weightunitdisp = vc
   1 weightcaptureddttm = vc
   1 weightsourcecd = vc
   1 weightsourcedisp = vc
   1 adjustedweight = vc
   1 adjustedweightmodifier = vc
   1 adjustedweightunitcd = vc
   1 adjustedweightunitdisp = vc
   1 adjustedweightdisp = vc
   1 weightadjustment = vc
   1 adjustmentmessage = vc
   1 serumcreatinine = vc
   1 serumcreatinineunitcd = vc
   1 serumcreatinineunitdisp = vc
   1 serumcreatininecaptureddttm = vc
   1 serumcreatininesourcecd = vc
   1 serumcreatininesourcedisp = vc
   1 creatinineclearance = vc
   1 creatinineclearanceunitcd = vc
   1 creatinineclearanceunitdisp = vc
   1 creatinineclearancemessage = vc
   1 creatinineclearancemodifier = vc
   1 creatinineclearancealgorithm = vc
   1 creatinineclearancealgorithmdisp = vc
   1 creatinineclearancelabel = vc
   1 crclweightused = vc
   1 crclweightusedlabel = vc
   1 crclweightusedtype = vc
   1 denormalizedcrclvalue = vc
   1 denormalizedcrclunitcd = vc
   1 denormalizedcrclunitdisp = vc
   1 denormalizedcrcllabel = vc
   1 bodysurfacearea = vc
   1 bodysurfaceareamodifier = vc
   1 bodysurfaceareaunitcd = vc
   1 bodysurfaceareaunitdisp = vc
   1 bodysurfaceareaalgorithm = vc
   1 bodysurfaceareaalgorithmdisp = vc
   1 denormalizedbsavalue = vc
   1 denormalizedbsaunitcd = vc
   1 denormalizedbsaunitdisp = vc
   1 denormalizedfinaldosevalue = vc
   1 denormalizedfinaldoseunitcd = vc
   1 denormalizedfinaldoseunitdisp = vc
   1 adjpermanuallychanged = vc
   1 weighteventid = vc
   1 heighteventid = vc
   1 weighteventcd = vc
   1 weighteventdisp = vc
   1 heighteventcd = vc
   1 heighteventdisp = vc
   1 ordertype = vc
   1 rate = vc
   1 rateunitcd = vc
   1 rateunitdisp = vc
   1 volume = vc
   1 volumeunitcd = vc
   1 volumeunitdisp = vc
   1 routecd = vc
   1 routedisp = vc
   1 frequencycd = vc
   1 frequencydisp = vc
   1 frequencymaxdaydose = vc
   1 ezdosecalcind = vc
   1 bsamessage = vc
   1 bsamethod = vc
   1 bsamethodformula = vc
   1 bsamethodformulastr = vc
   1 scdosecalculatorlongtext = vc
   1 error_message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD lines
 RECORD lines(
   1 list[*]
     2 data = vc
 ) WITH protect
 FREE RECORD req_format_str
 RECORD req_format_str(
   1 param = vc
 ) WITH protect
 FREE RECORD rep_format_str
 RECORD rep_format_str(
   1 param = vc
 ) WITH protect
 DECLARE formatparameters(null) = i4
 DECLARE builddosecalculatorlongtext(null) = i4
 DECLARE writetofile(null) = i4
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE app_tz = i4 WITH protect, constant(evaluate(curutc,1,curtimezoneapp,0))
 SET result->status_data.status = "F"
 SET result->order_id =  $2
 IF (( $2 <= 0.0))
  CALL echo("INVALID ORDER ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = formatparameters(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = builddosecalculatorlongtext(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = writetofile(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 DECLARE v1 = vc WITH protect, noconstant("")
 DECLARE v2 = vc WITH protect, noconstant("")
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  SELECT INTO value(moutputdevice)
   FROM dummyt d
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v1 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v1, row + 1, v2 = build("<ErrorMessage>",trim(replace(replace(replace(replace(replace(substring(1,
            439,result->error_message),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
       "&quot;",0),3),"</ErrorMessage>"),
    col + 1, v2, row + 1,
    col + 1, "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req_format_str
 FREE RECORD rep_format_str
 FREE RECORD lines
 SUBROUTINE formatparameters(null)
   IF (textlen(trim( $5,3)))
    SET req_format_str->param =  $5
    EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
     "REP_FORMAT_STR")
    SET result->description = rep_format_str->param
   ENDIF
   IF (textlen(trim( $33,3)))
    SET req_format_str->param =  $33
    EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
     "REP_FORMAT_STR")
    SET result->adjustreasonfreetext = rep_format_str->param
   ENDIF
   IF (textlen(trim( $41,3)))
    SET req_format_str->param =  $41
    EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
     "REP_FORMAT_STR")
    SET result->heightsourcedisp = rep_format_str->param
   ENDIF
   IF (textlen(trim( $45,3)))
    SET req_format_str->param =  $45
    EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
     "REP_FORMAT_STR")
    SET result->weightsourcedisp = rep_format_str->param
   ENDIF
   IF (textlen(trim( $54,3)))
    SET req_format_str->param =  $54
    EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
     "REP_FORMAT_STR")
    SET result->serumcreatininesourcedisp = rep_format_str->param
   ENDIF
   IF (textlen(trim( $47,3)))
    SET req_format_str->param =  $47
    EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
     "REP_FORMAT_STR")
    SET result->adjustedweightmodifier = rep_format_str->param
   ENDIF
   IF (textlen(trim( $50,3)))
    SET req_format_str->param =  $50
    EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
     "REP_FORMAT_STR")
    SET result->adjustmentmessage = rep_format_str->param
   ENDIF
   IF (textlen(trim( $57,3)))
    SET req_format_str->param =  $57
    EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
     "REP_FORMAT_STR")
    SET result->creatinineclearancemessage = rep_format_str->param
   ENDIF
   IF (textlen(trim( $58,3)))
    SET req_format_str->param =  $58
    EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
     "REP_FORMAT_STR")
    SET result->creatinineclearancemodifier = rep_format_str->param
   ENDIF
   IF (textlen(trim( $64,3)))
    SET req_format_str->param =  $64
    EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
     "REP_FORMAT_STR")
    SET result->bodysurfaceareamodifier = rep_format_str->param
   ENDIF
   IF (textlen(trim( $71,3)))
    SET req_format_str->param =  $71
    EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
     "REP_FORMAT_STR")
    SET result->adjpermanuallychanged = rep_format_str->param
   ENDIF
   IF (textlen(trim( $59,3)))
    SET req_format_str->param =  $59
    EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
     "REP_FORMAT_STR")
    SET result->creatinineclearancealgorithmdisp = rep_format_str->param
   ENDIF
   IF (textlen(trim( $86,3)))
    SET req_format_str->param =  $86
    EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
     "REP_FORMAT_STR")
    SET result->adjustedweightdisp = rep_format_str->param
   ENDIF
   IF (textlen(trim( $87,3)))
    SET req_format_str->param =  $87
    EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
     "REP_FORMAT_STR")
    SET result->bsamessage = rep_format_str->param
   ENDIF
   IF (textlen(trim( $89,3)))
    SET req_format_str->param =  $89
    EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
     "REP_FORMAT_STR")
    SET result->bsamethodformula = rep_format_str->param
   ENDIF
   IF (textlen(trim( $90,3)))
    SET req_format_str->param =  $90
    EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
     "REP_FORMAT_STR")
    SET result->bsamethodformulastr = rep_format_str->param
   ENDIF
   IF (textlen(trim( $91,3)))
    SET req_format_str->param =  $91
    EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
     "REP_FORMAT_STR")
    SET result->denormalizedcrcllabel = rep_format_str->param
   ENDIF
   IF (textlen(trim( $92,3)))
    SET req_format_str->param =  $92
    EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
     "REP_FORMAT_STR")
    SET result->crclweightusedlabel = rep_format_str->param
   ENDIF
   IF (textlen(trim( $93,3)))
    SET req_format_str->param =  $93
    EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
     "REP_FORMAT_STR")
    SET result->creatinineclearancelabel = rep_format_str->param
   ENDIF
   IF (textlen(trim( $94,3)))
    SET req_format_str->param =  $94
    EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
     "REP_FORMAT_STR")
    SET result->crclweightusedtype = rep_format_str->param
   ENDIF
   IF (textlen(trim( $60,3)))
    SET req_format_str->param =  $60
    EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
     "REP_FORMAT_STR")
    SET result->crclweightused = rep_format_str->param
   ENDIF
   SET result->dosecalculatoruseddttm = formatxmldate( $4,1)
   SET result->dob = formatxmldate( $35,1)
   SET result->birthdatetimedisp = formatdispdate( $35)
   SET result->ageinyears = formatage( $35,"YEARS")
   SET result->ageinmonths = formatage( $35,"MONTHS")
   SET result->ageinweeks = formatage( $35,"WEEKS")
   SET result->ageindays = formatage( $35,"DAYS")
   SET result->ageinhours = formatage( $35,"HOURS")
   SET result->ageinminutes = formatage( $35,"MINUTES")
   SET result->heightcaptureddttm = formatxmldate( $40,1)
   SET result->weightcaptureddttm = formatxmldate( $44,1)
   SET result->serumcreatininecaptureddttm = formatxmldate( $53,1)
   SET result->carrydob = result->dob
   SET result->doseflag = trim(build2( $3),3)
   SET result->targetdose = trim(cnvtstring( $6,20,4),3)
   SET result->targetdoseunitcd = trim(cnvtstring( $7,20,4),3)
   SET result->targetdoseunitdisp = uar_get_code_display(cnvtreal( $7))
   SET result->calculateddose = trim(cnvtstring( $8,20,4),3)
   SET result->calculateddoseunitcd = trim(cnvtstring( $9,20,4),3)
   SET result->calculateddoseunitdisp = uar_get_code_display(cnvtreal( $9))
   SET result->calculatedvoldose = trim(cnvtstring( $10,20,4),3)
   SET result->calculatedvoldoseunitcd = trim(cnvtstring( $11,20,4),3)
   SET result->calculatedvoldoseunitdisp = uar_get_code_display(cnvtreal( $11))
   SET result->reduceddose = trim(cnvtstring( $12,20,4),3)
   SET result->reduceddoseunitcd = trim(cnvtstring( $13,20,4),3)
   SET result->reduceddoseunitdisp = uar_get_code_display(cnvtreal( $13))
   SET result->reducedvoldose = trim(cnvtstring( $14,20,4),3)
   SET result->reducedvoldoseunitcd = trim(cnvtstring( $15,20,4),3)
   SET result->reducedvoldoseunitdisp = uar_get_code_display(cnvtreal( $15))
   SET result->percentagereduced = trim(cnvtstring( $16,20,4),3)
   SET result->carryforwardpercentagereduced = trim(cnvtstring( $17,20,4),3)
   SET result->finaldose = trim(cnvtstring( $18,20,4),3)
   SET result->finaldoseunitcd = trim(cnvtstring( $19,20,4),3)
   SET result->finaldoseunitdisp = uar_get_code_display(cnvtreal( $19))
   SET result->finalvoldose = trim(cnvtstring( $20,20,4),3)
   SET result->finalvoldoseunitcd = trim(cnvtstring( $21,20,4),3)
   SET result->finalvoldoseunitdisp = uar_get_code_display(cnvtreal( $21))
   SET result->actualfinaldose = trim(cnvtstring( $22,20,4),3)
   SET result->actualfinaldoseunitcd = trim(cnvtstring( $23,20,4),3)
   SET result->actualfinaldoseunitdisp = uar_get_code_display(cnvtreal( $23))
   SET result->standarddose = trim(cnvtstring( $24,20,4),3)
   SET result->standarddoseunitcd = trim(cnvtstring( $25,20,4),3)
   SET result->standarddoseunitdisp = uar_get_code_display(cnvtreal( $25))
   SET result->standardvoldose = trim(cnvtstring( $26,20,4),3)
   SET result->standardvoldoseunitcd = trim(cnvtstring( $27,20,4),3)
   SET result->standardvoldoseunitdisp = uar_get_code_display(cnvtreal( $27))
   SET result->actualstandarddose = trim(cnvtstring( $28,20,4),3)
   SET result->actualstandarddoseunitcd = trim(cnvtstring( $29,20,4),3)
   SET result->actualstandarddoseunitdisp = uar_get_code_display(cnvtreal( $29))
   SET result->roundingrulecd = trim(build2( $30),3)
   SET result->roundingruledisp = uar_get_code_display(cnvtreal( $30))
   SET result->ezdosecalculationtype = trim(build2( $31),3)
   SET result->adjustreasoncd = trim(cnvtstring( $32,20,4),3)
   SET result->adjustreasondisp = uar_get_code_display(cnvtreal( $32))
   SET result->silentinvoke = trim(build2( $34),3)
   SET result->gendercd = trim(cnvtstring( $36,20,4),3)
   SET result->genderdisp = uar_get_code_display(cnvtreal( $36))
   SET result->racecd = trim(cnvtstring( $37,20,4),3)
   SET result->racedisp = uar_get_code_display(cnvtreal( $37))
   SET result->height = trim(cnvtstring( $38,20,4),3)
   SET result->heightunitcd = trim(cnvtstring( $39,20,4),3)
   SET result->heightunitdisp = uar_get_code_display(cnvtreal( $39))
   SET result->weight = trim(cnvtstring( $42,20,4),3)
   SET result->weightunitcd = trim(cnvtstring( $43,20,4),3)
   SET result->weightunitdisp = uar_get_code_display(cnvtreal( $43))
   SET result->adjustedweight = trim(cnvtstring( $46,20,4),3)
   SET result->adjustedweightunitcd = trim(cnvtstring( $48,20,4),3)
   SET result->adjustedweightunitdisp = uar_get_code_display(cnvtreal( $48))
   SET result->weightadjustment = trim(build2( $49),3)
   SET result->serumcreatinine = trim(cnvtstring( $51,20,4),3)
   SET result->serumcreatinineunitcd = trim(cnvtstring( $52,20,4),3)
   SET result->serumcreatinineunitdisp = uar_get_code_display(cnvtreal( $52))
   SET result->creatinineclearance = trim(cnvtstring( $55,20,4),3)
   SET result->creatinineclearanceunitcd = trim(cnvtstring( $56,20,4),3)
   SET result->creatinineclearanceunitdisp = uar_get_code_display(cnvtreal( $56))
   SET result->creatinineclearancealgorithm = "0"
   SET result->denormalizedcrclvalue = evaluate( $61,0,"0",trim(build2( $61),3))
   SET result->denormalizedcrclunitcd = trim(build2( $62),3)
   SET result->denormalizedcrclunitdisp = uar_get_code_display(cnvtreal( $62))
   SET result->bodysurfacearea = trim(cnvtstring( $63,20,4),3)
   SET result->bodysurfaceareaunitcd = trim(cnvtstring( $65,20,4),3)
   SET result->bodysurfaceareaunitdisp = uar_get_code_display(cnvtreal( $65))
   SET result->bodysurfaceareaalgorithm = trim(build2( $66),3)
   IF (cnvtint( $66) > 0)
    SET result->bodysurfaceareaalgorithmdisp = uar_get_code_display(cnvtreal( $66))
   ELSE
    SET result->bodysurfaceareaalgorithmdisp = "Manually entered"
   ENDIF
   SET result->denormalizedbsavalue = trim(build2( $67),3)
   SET result->denormalizedbsaunitcd = trim(build2( $68),3)
   SET result->denormalizedbsaunitdisp = uar_get_code_display(cnvtreal( $68))
   SET result->denormalizedfinaldosevalue = evaluate( $69,0,"0",trim(build2( $69),3))
   SET result->denormalizedfinaldoseunitcd = trim(build2( $70),3)
   SET result->denormalizedfinaldoseunitdisp = uar_get_code_display(cnvtreal( $70))
   SET result->ethnicitycd = trim(cnvtstring( $72,20,4),3)
   SET result->ethnicitydisp = uar_get_code_display(cnvtreal( $72))
   SET result->weighteventid = trim(cnvtstring( $73,20,4),3)
   SET result->heighteventid = trim(cnvtstring( $74,20,4),3)
   SET result->weighteventcd = trim(cnvtstring( $75,20,4),3)
   SET result->weighteventdisp = uar_get_code_display(cnvtreal( $75))
   SET result->heighteventcd = trim(cnvtstring( $76,20,4),3)
   SET result->heighteventdisp = uar_get_code_display(cnvtreal( $76))
   SET result->ordertype = trim(build2( $77),3)
   SET result->rate = trim(cnvtstring( $78,20,4),3)
   SET result->rateunitcd = trim(cnvtstring( $79,20,4),3)
   SET result->rateunitdisp = uar_get_code_display(cnvtreal( $79))
   SET result->volume = trim(cnvtstring( $80,20,4),3)
   SET result->volumeunitcd = trim(cnvtstring( $81,20,4),3)
   SET result->volumeunitdisp = uar_get_code_display(cnvtreal( $81))
   SET result->routecd = trim(cnvtstring( $82,20,4),3)
   SET result->routedisp = uar_get_code_display(cnvtreal( $82))
   SET result->frequencycd = trim(cnvtstring( $83,20,4),3)
   SET result->frequencydisp = uar_get_code_display(cnvtreal( $83))
   SET result->frequencymaxdaydose = trim(build2( $84),3)
   SET result->ezdosecalcind = trim(build2( $85),3)
   SET result->bsamethod = evaluate( $88,0,"0",trim(build2( $88),3))
   RETURN(success)
 END ;Subroutine
 SUBROUTINE builddosecalculatorlongtext(null)
   DECLARE type_string = vc WITH protect, constant(' type="string">')
   DECLARE type_double = vc WITH protect, constant(' type="double">')
   DECLARE type_long = vc WITH protect, constant(' type="long">')
   DECLARE type_int = vc WITH protect, constant(' type="int">')
   DECLARE type_calendar = vc WITH protect, constant(' type="Calendar">')
   SET result->scdosecalculatorlongtext = concat("<?xml6 version=","'6.0'",
    "?> <?xml-stylesheet type=","'text/xml'"," href=",
    "'dom.xsl'","?>","<DosageInformation><DosageInformationVersion",type_string,"4.0",
    "</DosageInformationVersion>",buildxmlelement("DoseFlag",type_long,result->doseflag),
    buildxmlelement("DoseCalculatorUsedDtTm",type_calendar,result->dosecalculatoruseddttm),
    buildxmlelement("Description",type_string,result->description),"<Dose>",
    buildxmlelement("TargetDose",type_double,result->targetdose),buildxmlelement("TargetDoseUnitCd",
     type_double,result->targetdoseunitcd),buildxmlelement("TargetDoseUnitDisp",type_string,result->
     targetdoseunitdisp),buildxmlelement("CalculatedDose",type_double,result->calculateddose),
    buildxmlelement("CalculatedDoseUnitCd",type_double,result->calculateddoseunitcd),
    buildxmlelement("CalculatedDoseUnitDisp",type_string,result->calculateddoseunitdisp),
    buildxmlelement("CalculatedVolDose",type_double,result->calculatedvoldose),buildxmlelement(
     "CalculatedVolDoseUnitDisp",type_string,result->calculatedvoldoseunitdisp),buildxmlelement(
     "ReducedDose",type_double,result->reduceddose),buildxmlelement("ReducedDoseUnitCd",type_double,
     result->reduceddoseunitcd),
    buildxmlelement("ReducedDoseUnitDisp",type_string,result->reduceddoseunitdisp),buildxmlelement(
     "ReducedVolDose",type_double,result->reducedvoldose),buildxmlelement("ReducedVolDoseUnitDisp",
     type_string,result->reducedvoldoseunitdisp),buildxmlelement("PercentageReduced",type_double,
     result->percentagereduced),buildxmlelement("CarryForwardPercentageReduced",type_double,result->
     carryforwardpercentagereduced),
    buildxmlelement("FinalDose",type_double,result->finaldose),buildxmlelement("FinalDoseUnitCd",
     type_double,result->finaldoseunitcd),buildxmlelement("FinalDoseUnitDisp",type_string,result->
     finaldoseunitdisp),buildxmlelement("FinalVolDose",type_double,result->finalvoldose),
    buildxmlelement("FinalVolDoseUnitDisp",type_string,result->finalvoldoseunitdisp),
    buildxmlelement("ActualFinalDose",type_double,result->actualfinaldose),buildxmlelement(
     "ActualFinalDoseUnitCd",type_double,result->actualfinaldoseunitcd),buildxmlelement(
     "ActualFinalDoseUnitDisp",type_string,result->actualfinaldoseunitdisp),buildxmlelement(
     "StandardDose",type_double,result->standarddose),buildxmlelement("StandardDoseUnitCd",
     type_double,result->standarddoseunitcd),
    buildxmlelement("StandardDoseUnitDisp",type_string,result->standarddoseunitdisp),buildxmlelement(
     "StandardVolDose",type_double,result->standardvoldose),buildxmlelement("StandardVolDoseUnitDisp",
     type_string,result->standardvoldoseunitdisp),buildxmlelement("ActualStandardDose",type_double,
     result->actualstandarddose),buildxmlelement("ActualStandardDoseUnitCd",type_double,result->
     actualstandarddoseunitcd),
    buildxmlelement("ActualStandardDoseUnitDisp",type_string,result->actualstandarddoseunitdisp),
    buildxmlelement("RoundingRule",type_long,result->roundingrulecd),buildxmlelement(
     "RoundingRuleDisp",type_string,result->roundingruledisp),buildxmlelement("RoundingRuleCd",
     type_double,"0.0000"),buildxmlelement("EZDoseCalculationType",type_int,result->
     ezdosecalculationtype),
    buildxmlelement("AdjustReasonCd",type_double,result->adjustreasoncd),buildxmlelement(
     "AdjustReasonDisp",type_string,evaluate(size(trim(result->adjustreasonfreetext,3)),0,result->
      adjustreasondisp,result->adjustreasonfreetext)),buildxmlelement("SilentInvoke",type_int,result
     ->silentinvoke),"</Dose>","<OrderData>",
    buildxmlelement("OrderType",type_int,result->ordertype),buildxmlelement("Rate",type_double,result
     ->rate),buildxmlelement("RateUnitCd",type_double,result->rateunitcd),buildxmlelement(
     "RateUnitDisp",type_string,result->rateunitdisp),buildxmlelement("Volume",type_double,result->
     volume),
    buildxmlelement("VolumeUnitDisp",type_string,result->volumeunitdisp),buildxmlelement("RouteCd",
     type_double,result->routecd),buildxmlelement("RouteDisp",type_string,result->routedisp),
    buildxmlelement("FrequencyCd",type_double,result->frequencycd),buildxmlelement("FrequencyDisp",
     type_string,result->frequencydisp),
    buildxmlelement("FrequencyMaxDayDose",type_long,result->frequencymaxdaydose),buildxmlelement(
     "EZDoseCalcInd",type_int,result->ezdosecalcind),"</OrderData>","<ReferenceData>",buildxmlelement
    ("DOB",type_calendar,result->dob),
    buildxmlelement("DOBMessage",type_string,""),buildxmlelement("BirthDateTimeDisp",type_string,
     result->birthdatetimedisp),buildxmlelement("ageInYears",type_long,result->ageinyears),
    buildxmlelement("ageInMonths",type_long,result->ageinmonths),buildxmlelement("ageInWeeks",
     type_long,result->ageinweeks),
    buildxmlelement("ageInDays",type_long,result->ageindays),buildxmlelement("ageInHours",type_long,
     result->ageinhours),buildxmlelement("ageInMinutes",type_long,result->ageinminutes),
    buildxmlelement("GenderCd",type_double,result->gendercd),buildxmlelement("GenderDisp",type_string,
     result->genderdisp),
    buildxmlelement("GenderMessage",type_string,""),buildxmlelement("RaceCd",type_double,result->
     racecd),buildxmlelement("RaceDisp",type_string,result->racedisp),buildxmlelement("EthnicityCd",
     type_double,result->ethnicitycd),buildxmlelement("EthnicityDisp",type_string,result->
     ethnicitydisp),
    buildxmlelement("RaceEthnicityMessage",type_string,""),buildxmlelement("RaceEthnicityLabel",
     type_string,"&Ethnicity:"),buildxmlelement("Height",type_double,result->height),buildxmlelement(
     "HeightUnitCd",type_double,result->heightunitcd),buildxmlelement("HeightUnitDisp",type_string,
     result->heightunitdisp),
    buildxmlelement("HeightCapturedDtTm",type_calendar,result->heightcaptureddttm),buildxmlelement(
     "HeightSourceDisp",type_string,result->heightsourcedisp),buildxmlelement("Weight",type_double,
     result->weight),buildxmlelement("WeightUnitCd",type_double,result->weightunitcd),buildxmlelement
    ("WeightUnitDisp",type_string,result->weightunitdisp),
    buildxmlelement("WeightCapturedDtTm",type_calendar,result->weightcaptureddttm),buildxmlelement(
     "WeightSourceDisp",type_string,result->weightsourcedisp),buildxmlelement("AdjustedWeight",
     type_double,result->adjustedweight),buildxmlelement("AdjustedWeightModifier",type_string,result
     ->adjustedweightmodifier),buildxmlelement("AdjustedWeightUnitCd",type_double,result->
     adjustedweightunitcd),
    buildxmlelement("AdjustedWeightUnitDisp",type_string,result->adjustedweightunitdisp),
    buildxmlelement("AdjustedWeightDisp",type_string,result->adjustedweightdisp),buildxmlelement(
     "WeightAdjustment",type_long,result->weightadjustment),buildxmlelement("AdjustmentMessage",
     type_string,result->adjustmentmessage),buildxmlelement("SerumCreatinine",type_double,result->
     serumcreatinine),
    buildxmlelement("SerumCreatinineUnitCd",type_double,result->serumcreatinineunitcd),
    buildxmlelement("SerumCreatinineUnitDisp",type_string,result->serumcreatinineunitdisp),
    buildxmlelement("SerumCreatinineCapturedDtTm",type_calendar,result->serumcreatininecaptureddttm),
    buildxmlelement("SerumCreatinineSourceDisp",type_string,result->serumcreatininesourcedisp),
    buildxmlelement("CreatinineClearanceLabel",type_string,result->creatinineclearancelabel),
    buildxmlelement("CreatinineClearance",type_double,result->creatinineclearance),buildxmlelement(
     "CreatinineClearanceModifier",type_string,""),buildxmlelement("CreatinineClearanceUnitDisp",
     type_string,result->creatinineclearanceunitdisp),buildxmlelement("CreatinineClearanceAlgorithm",
     type_long,result->creatinineclearancealgorithm),buildxmlelement(
     "CreatinineClearanceAlgorithmDisp",type_string,result->creatinineclearancealgorithmdisp),
    buildxmlelement("CreatinineClearanceMessage",type_string,result->creatinineclearancemessage),
    buildxmlelement("CrClWeightUsedLabel",type_string,result->crclweightusedlabel),buildxmlelement(
     "CrClWeightUsedValue",type_string,result->crclweightused),buildxmlelement("CrClWeightUsedType",
     type_string,result->crclweightusedtype),buildxmlelement("DenormalizedCrClLabel",type_string,
     result->denormalizedcrcllabel),
    buildxmlelement("DenormalizedCrClValueDisp",type_string,result->denormalizedcrclvalue),
    buildxmlelement("DenormalizedCrClUnitDisp",type_string,result->denormalizedcrclunitdisp),
    buildxmlelement("BodySurfaceArea",type_double,result->bodysurfacearea),buildxmlelement(
     "BodySurfaceAreaModifier",type_string,result->bodysurfaceareamodifier),buildxmlelement(
     "BodySurfaceAreaUnitDisp",type_string,result->bodysurfaceareaunitdisp),
    buildxmlelement("BodySurfaceAreaAlgorithm",type_long,result->bodysurfaceareaalgorithm),
    buildxmlelement("BodySurfaceAreaAlgorithmDisp",type_string,result->bodysurfaceareaalgorithmdisp),
    buildxmlelement("BSAMessage",type_string,result->bsamessage),buildxmlelement(
     "DenormalizedBSAValueDisp",type_string,result->denormalizedbsavalue),buildxmlelement(
     "DenormalizedBSAUnitDisp",type_string,result->denormalizedbsaunitdisp),
    buildxmlelement("DenormalizedFinalDoseValueDisp",type_string,result->denormalizedfinaldosevalue),
    buildxmlelement("DenormalizedFinalDoseUnitDisp",type_string,result->denormalizedfinaldoseunitdisp
     ),buildxmlelement("AdjPerManuallyChanged",type_string,result->adjpermanuallychanged),
    buildxmlelement("WeightEventId",type_double,result->weighteventid),buildxmlelement(
     "DoseTypeApplied",type_int,"1"),
    buildxmlelement("OrderComments",type_string,""),buildxmlelement("HeightEventId",type_double,
     result->heighteventid),buildxmlelement("HeightEventCd",type_double,result->heighteventcd),
    buildxmlelement("WeightEventCd",type_double,result->weighteventcd),buildxmlelement(
     "AdjustedWeightPercent",type_string,""),
    buildxmlelement("WeightAdjustmentMethod",type_double,"0.0000"),buildxmlelement(
     "WeightAdjustmentMethodFormula",type_string,""),buildxmlelement(
     "WeightAdjustmentMethodFormulaStr",type_string,""),buildxmlelement("BSAMethod",type_double,
     result->bsamethod),buildxmlelement("BSAMethodFormula",type_string,result->bsamethodformula),
    buildxmlelement("BSAMethodFormulaStr",type_string,result->bsamethodformulastr),buildxmlelement(
     "CarryDOB",type_calendar,result->carrydob),buildxmlelement("HtVarianceMessage",type_string,""),
    buildxmlelement("WtVarianceMessage",type_string,""),"</ReferenceData>",
    "</DosageInformation>")
   SET result->scdosecalculatorlongtext = replace(result->scdosecalculatorlongtext,'"double">0<',
    '"double">0.0000<',0)
   CALL echo(build("RESULT->SCDOSECALCULATORLONGTEXT:",result->scdosecalculatorlongtext))
   RETURN(success)
 END ;Subroutine
 SUBROUTINE writetofile(null)
   DECLARE data_str = vc WITH protect, constant(result->scdosecalculatorlongtext)
   DECLARE max_line_length = i4 WITH protect, constant(1000)
   DECLARE doc_size = f8 WITH protect, constant(size(data_str))
   DECLARE tmp_filename = vc WITH protect, constant(concat("ATHN_SCDOSECALCLONGTEXT_",trim(cnvtstring
      (result->order_id),3),".TMP"))
   DECLARE nbr_of_lines = i4 WITH protect, constant(ceil((doc_size/ cnvtreal(max_line_length))))
   DECLARE line_pos = i4 WITH protect, noconstant(1)
   DECLARE compare_doc = vc WITH protect, noconstant("")
   DECLARE remainder_size = i4 WITH protect, noconstant(0)
   CALL echo(build("DOC_SIZE:",doc_size))
   CALL echo(build("NBR_OF_LINES:",nbr_of_lines))
   SET stat = alterlist(lines->list,nbr_of_lines)
   FOR (idx = 1 TO (nbr_of_lines - 1))
     SET lines->list[idx].data = substring(line_pos,max_line_length,data_str)
     SET line_pos += max_line_length
     SET compare_doc = evaluate(size(trim(compare_doc,3)),0,lines->list[idx].data,concat(compare_doc,
       lines->list[idx].data))
   ENDFOR
   CALL echo(build("COMPARE_DOC:",compare_doc))
   CALL echo(build("COMPARE_DOC SIZE:",cnvtstring(size(compare_doc))))
   SET remainder_size = (doc_size - size(compare_doc))
   IF (remainder_size > 0)
    SET lines->list[nbr_of_lines].data = substring(line_pos,remainder_size,data_str)
   ENDIF
   SELECT INTO value(concat("CER_TEMP:",tmp_filename))
    FROM (dummyt d  WITH seq = value(nbr_of_lines))
    PLAN (d
     WHERE d.seq >= 0)
    DETAIL
     col 0, lines->list[d.seq].data, row + 1
    WITH maxcol = 32000, nocounter, nullreport,
     formfeed = none, format = variable, time = 30
   ;end select
   IF (error(errmsg,0) > 0)
    SET result->error_message = concat("FAILED TO WRITE FILE: ",tmp_filename)
    RETURN(fail)
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE (formatdispdate(datestr=vc) =vc)
   DECLARE date_str = vc WITH protect, noconstant("")
   DECLARE disp_dt_tm = dq8 WITH protect, noconstant(0.0)
   DECLARE date_format = vc WITH protect, constant("MM/DD/YYYY;;D")
   IF (size(trim(datestr,3)) > 0)
    SET disp_dt_tm = cnvtdatetime(trim(datestr,3))
    IF (disp_dt_tm > 0)
     SET date_str = format(disp_dt_tm,date_format)
    ENDIF
   ELSE
    SET date_str = "NOT SET"
   ENDIF
   RETURN(date_str)
 END ;Subroutine
 SUBROUTINE (formatxmldate(datestr=vc,time_zone_ind=i2) =vc)
   DECLARE xml_dt_tm = dq8 WITH protect, noconstant(0.0)
   DECLARE date_str = vc WITH protect, noconstant("")
   DECLARE time_str = vc WITH protect, noconstant("")
   DECLARE xmldate_str = vc WITH protect, noconstant("")
   DECLARE tz_str = vc WITH protect, constant(concat(" - ",cnvtstring(app_tz)))
   DECLARE date_format = vc WITH protect, constant("YYYYMMDD;;D")
   DECLARE time_format = vc WITH protect, constant("HHMMSS;;m")
   DECLARE millisecond_str = vc WITH protect, constant("00")
   IF (size(trim(datestr,3)) > 0)
    SET xml_dt_tm = cnvtdatetime(trim(datestr,3))
    IF (xml_dt_tm > 0)
     SET date_str = format(xml_dt_tm,date_format)
     SET time_str = format(xml_dt_tm,time_format)
    ENDIF
   ELSE
    SET date_str = "00000000"
    SET time_str = "000000"
   ENDIF
   SET xmldate_str = concat(date_str,time_str,millisecond_str,evaluate(time_zone_ind,1,tz_str,""))
   RETURN(xmldate_str)
 END ;Subroutine
 SUBROUTINE (formatage(dob_str=vc,formatunit=vc) =vc)
   DECLARE dob_dt_tm = dq8 WITH protect, noconstant(0)
   DECLARE ageval = i4 WITH protect, noconstant(0)
   IF (size(trim(dob_str,3)) > 0)
    SET dob_dt_tm = cnvtdatetime(trim(dob_str,3))
    IF (dob_dt_tm > 0)
     CASE (formatunit)
      OF "SECONDS":
       SET ageval = datetimediff(cnvtdatetime(sysdate),dob_dt_tm,5)
      OF "MINUTES":
       SET ageval = datetimediff(cnvtdatetime(sysdate),dob_dt_tm,4)
      OF "HOURS":
       SET ageval = datetimediff(cnvtdatetime(sysdate),dob_dt_tm,3)
      OF "DAYS":
       SET ageval = datetimediff(cnvtdatetime(sysdate),dob_dt_tm,1)
      OF "WEEKS":
       SET ageval = datetimediff(cnvtdatetime(sysdate),dob_dt_tm,2)
      OF "MONTHS":
       SET ageval = datetimediff(cnvtdatetime(sysdate),dob_dt_tm,11)
      OF "YEARS":
       SET ageval = datetimediff(cnvtdatetime(sysdate),dob_dt_tm,10)
      ELSE
       SET ageval = 0
     ENDCASE
    ENDIF
   ENDIF
   RETURN(trim(cnvtstring(ageval),3))
 END ;Subroutine
 SUBROUTINE (buildxmlelement(name=vc,type_str=vc,data_str=vc) =vc)
   DECLARE xmlelement = vc WITH protect, noconstant("")
   SET xmlelement = concat("<",name,type_str,evaluate(size(trim(data_str,3)),0,"</",concat(
      replacespecialxmlchars(data_str),"</")),name,
    ">")
   RETURN(xmlelement)
 END ;Subroutine
 SUBROUTINE (replacespecialxmlchars(input=vc) =vc)
   DECLARE encoded_str = vc WITH protect, noconstant(input)
   SET encoded_str = replace(encoded_str,"&","&amp;",0)
   SET encoded_str = replace(encoded_str,"<","&lt;",0)
   SET encoded_str = replace(encoded_str,">","&gt;",0)
   SET encoded_str = replace(encoded_str,char(34),"&quot;",0)
   SET encoded_str = replace(encoded_str,char(39),"&apos;",0)
   RETURN(encoded_str)
 END ;Subroutine
END GO
