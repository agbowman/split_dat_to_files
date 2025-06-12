CREATE PROGRAM dcp_prediction_algorithm:dba
 RECORD reply(
   1 prediction_status = i4
   1 plist[*]
     2 equation_name = vc
     2 outcome = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 RECORD aps_variable(
   1 sintubated = i2
   1 svent = i2
   1 sdialysis = i2
   1 seyes = i2
   1 smotor = i2
   1 sverbal = i2
   1 smeds = i2
   1 filler1 = c2
   1 dwurine = f8
   1 dwwbc = f8
   1 dwtemp = f8
   1 dwrespiratoryrate = f8
   1 dwsodium = f8
   1 dwheartrate = f8
   1 dwmeanbp = f8
   1 dwph = f8
   1 dwhematocrit = f8
   1 dwcreatinine = f8
   1 dwalbumin = f8
   1 dwpao2 = f8
   1 dwpco2 = f8
   1 dwbun = f8
   1 dwglucose = f8
   1 dwbilirubin = f8
   1 dwfio2 = f8
   1 filler2 = c50
 )
 IF (((cursys="AXP") OR (cursys2="HPX")) )
  RECORD aps_prediction(
    1 sicuday = i2
    1 saps3day1 = i2
    1 saps3today = i2
    1 saps3yesterday = i2
    1 sgender = i2
    1 steachtype = i2
    1 sregion = i2
    1 sbedcount = i2
    1 sadmitsource = i2
    1 sgraftcount = i2
    1 smeds = i2
    1 sverbal = i2
    1 smotor = i2
    1 seyes = i2
    1 sage = i2
    1 szicuadmitdate = c27
    1 szhospadmitdate = c27
    1 szadmitdiagnosis = c11
    1 filler1 = c1
    1 bthrombolytics = i2
    1 bdiedinhospital = i2
    1 baids = i2
    1 bhepaticfailure = i2
    1 blymphoma = i2
    1 bmetastaticcancer = i2
    1 bleukemia = i2
    1 bimmunosuppression = i2
    1 bcirrhosis = i2
    1 belectivesurgery = i2
    1 bactivetx = i2
    1 breadmit = i2
    1 bima = i2
    1 bmidur = i2
    1 bventday1 = i2
    1 boobventday1 = i2
    1 boobintubday1 = i2
    1 bdiabetes = i2
    1 bmanagementsystem = i2
    1 filler2 = c2
    1 dwvar03hspxlos = f8
    1 dwpao2 = f8
    1 dwfio2 = f8
    1 dwejectfx = f8
    1 dwcreatinine = f8
    1 sdischargelocation = i2
    1 svisitnumber = i2
    1 samilocation = i2
    1 szicuadmitdatetime = c27
    1 szhospadmitdatetime = c27
    1 sday1meds = i2
    1 sday1verbal = i2
    1 sday1motor = i2
    1 sday1eyes = i2
    1 filler3 = c4
    1 dwday1pao2 = f8
    1 dwday1fio2 = f8
  )
  RECORD aps_outcome(
    1 qual[100]
      2 cversionnumber = c1
      2 filler1 = c7
      2 dwoutcome = f8
      2 szequationname = c50
      2 filler2 = c2
      2 nequationnamenumber = i2
      2 filler2 = c2
  )
 ELSE
  RECORD aps_prediction(
    1 sicuday = i2
    1 saps3day1 = i2
    1 saps3today = i2
    1 saps3yesterday = i2
    1 sgender = i2
    1 steachtype = i2
    1 sregion = i2
    1 sbedcount = i2
    1 sadmitsource = i2
    1 sgraftcount = i2
    1 smeds = i2
    1 sverbal = i2
    1 smotor = i2
    1 seyes = i2
    1 sage = i2
    1 szicuadmitdate = c27
    1 szhospadmitdate = c27
    1 szadmitdiagnosis = c11
    1 filler1 = c1
    1 bthrombolytics = i2
    1 bdiedinhospital = i2
    1 baids = i2
    1 bhepaticfailure = i2
    1 blymphoma = i2
    1 bmetastaticcancer = i2
    1 bleukemia = i2
    1 bimmunosuppression = i2
    1 bcirrhosis = i2
    1 belectivesurgery = i2
    1 bactivetx = i2
    1 breadmit = i2
    1 bima = i2
    1 bmidur = i2
    1 bventday1 = i2
    1 boobventday1 = i2
    1 boobintubday1 = i2
    1 bdiabetes = i2
    1 bmanagementsystem = i2
    1 filler2 = c2
    1 dwvar03hspxlos = f8
    1 dwpao2 = f8
    1 dwfio2 = f8
    1 dwejectfx = f8
    1 dwcreatinine = f8
    1 sdischargelocation = i2
    1 svisitnumber = i2
    1 samilocation = i2
    1 szicuadmitdatetime = c27
    1 szhospadmitdatetime = c27
    1 sday1meds = i2
    1 sday1verbal = i2
    1 sday1motor = i2
    1 sday1eyes = i2
    1 dwday1pao2 = f8
    1 dwday1fio2 = f8
  )
  RECORD aps_outcome(
    1 qual[100]
      2 cversionnumber = c1
      2 filler1 = c3
      2 dwoutcome = f8
      2 szequationname = c50
      2 filler2 = c2
      2 nequationnamenumber = i2
      2 filler2 = c2
  )
 ENDIF
 DECLARE status = i4
 DECLARE aps_status = i4
 DECLARE outcome_status = i4
 RECORD get_visit_parameters(
   1 risk_adjustment_id = f8
 )
 RECORD get_visit_reply(
   1 visit_number = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE apachertl
 EXECUTE FROM 1000_initialize TO 1099_initialize_exit
 EXECUTE FROM 2000_process TO 2099_process_exit
 GO TO 9999_exit_program
#1000_initialize
 SET reply->status_data.status = "S"
 SET failed_ind = "N"
 DECLARE failed_text = vc
 SET day1meds = - (1)
 SET day1verbal = - (1)
 SET day1motor = - (1)
 SET day1eyes = - (1)
 SET day1pao2 = - (1.0)
 SET day1fio2 = - (1.0)
#1099_initialize_exit
#2000_process
 SET aps_prediction->sicuday = request->cc_day
 SET aps_prediction->saps3day1 = request->aps3day1
 SET aps_prediction->saps3today = request->aps3today
 SET aps_prediction->saps3yesterday = request->aps3yesterday
 SET aps_prediction->sgender = request->gender
 SET aps_prediction->steachtype = request->teachtype
 SET aps_prediction->sregion = request->region
 SET aps_prediction->sbedcount = request->bedcount
 IF ((request->admit_source IN ("CHPAIN_CTR", "ICU", "ICU_TO_OR")))
  SET aps_prediction->sadmitsource = 5
 ELSEIF ((request->admit_source="OR"))
  SET aps_prediction->sadmitsource = 1
 ELSEIF ((request->admit_source="RR"))
  SET aps_prediction->sadmitsource = 2
 ELSEIF ((request->admit_source="ER"))
  SET aps_prediction->sadmitsource = 3
 ELSEIF ((request->admit_source="FLOOR"))
  SET aps_prediction->sadmitsource = 4
 ELSEIF ((request->admit_source="OTHER_HOSP"))
  SET aps_prediction->sadmitsource = 6
 ELSEIF ((request->admit_source="DIR_ADMIT"))
  SET aps_prediction->sadmitsource = 7
 ELSEIF ((request->admit_source IN ("SDU", "ICU_TO_SDU")))
  SET aps_prediction->sadmitsource = 8
 ENDIF
 SET aps_prediction->sgraftcount = request->nbr_grafts_performed
 SET aps_prediction->smeds = request->meds_ind
 SET aps_prediction->sverbal = request->verbal
 SET aps_prediction->smotor = request->motor
 SET aps_prediction->seyes = request->eyes
 SET aps_prediction->sage = request->age
 SET abc = fillstring(20," ")
 SET abc = format(request->icu_admit_dt_tm,"mm/dd/yyyy;;d")
 SET aps_prediction->szicuadmitdate = concat(trim(abc),char(0))
 SET abc = fillstring(20," ")
 SET abc = format(request->hosp_admit_dt_tm,"mm/dd/yyyy;;d")
 SET aps_prediction->szhospadmitdate = concat(trim(abc),char(0))
 SET aps_prediction->szadmitdiagnosis = concat(trim(request->admitdiagnosis),char(0))
 SET aps_prediction->bthrombolytics = request->thrombolytics_ind
 SET aps_prediction->bdiedinhospital = request->diedinhospital_ind
 SET aps_prediction->baids = request->aids_ind
 SET aps_prediction->bhepaticfailure = request->hepaticfailure_ind
 SET aps_prediction->blymphoma = request->lymphoma_ind
 SET aps_prediction->bmetastaticcancer = request->metastaticcancer_ind
 SET aps_prediction->bleukemia = request->leukemia_ind
 SET aps_prediction->bimmunosuppression = request->immunosuppression_ind
 SET aps_prediction->bcirrhosis = request->cirrhosis_ind
 SET aps_prediction->belectivesurgery = request->electivesurgery_ind
 SET aps_prediction->bactivetx = request->activetx_ind
 SET aps_prediction->breadmit = request->readmit_ind
 SET aps_prediction->bima = request->ima_ind
 SET aps_prediction->bmidur = request->midur_ind
 SET aps_prediction->bventday1 = request->ventday1_ind
 SET aps_prediction->boobventday1 = request->oobventday1_ind
 SET aps_prediction->boobintubday1 = maxval(request->oobintubday1_ind,request->oobventday1_ind)
 SET aps_prediction->bdiabetes = request->diabetes_ind
 SET aps_prediction->bmanagementsystem = 1
 SET aps_prediction->dwvar03hspxlos = request->var03hspxlos
 SET aps_prediction->dwpao2 = request->pao2
 SET aps_prediction->dwfio2 = request->fio2
 SET aps_prediction->dwejectfx = request->ejectfx
 SET aps_prediction->dwcreatinine = request->creatinine
 IF ((request->diedinicu_ind=1))
  SET request->discharge_location = "DEATH"
 ENDIF
 IF ((request->discharge_location="FLOOR"))
  SET aps_prediction->sdischargelocation = 4
 ELSEIF ((request->discharge_location="ICU_TRANSFER"))
  SET aps_prediction->sdischargelocation = 5
 ELSEIF ((request->discharge_location="OTHER_HOSP"))
  SET aps_prediction->sdischargelocation = 6
 ELSEIF ((request->discharge_location="HOME"))
  SET aps_prediction->sdischargelocation = 7
 ELSEIF ((request->discharge_location="OTHER"))
  SET aps_prediction->sdischargelocation = 8
 ELSEIF ((request->discharge_location="DEATH"))
  SET aps_prediction->sdischargelocation = 9
 ELSE
  SET aps_prediction->sdischargelocation = - (1)
 ENDIF
 SET aps_prediction->svisitnumber = request->visit_number
 IF ((request->ami_location="ANT"))
  SET aps_prediction->samilocation = 1
 ELSEIF ((request->ami_location="ANTLAT"))
  SET aps_prediction->samilocation = 2
 ELSEIF ((request->ami_location="ANTSEP"))
  SET aps_prediction->samilocation = 3
 ELSEIF ((request->ami_location="INF"))
  SET aps_prediction->samilocation = 4
 ELSEIF ((request->ami_location="LAT"))
  SET aps_prediction->samilocation = 5
 ELSEIF ((request->ami_location="NONQ"))
  SET aps_prediction->samilocation = 6
 ELSEIF ((request->ami_location="POST"))
  SET aps_prediction->samilocation = 7
 ELSE
  SET aps_prediction->samilocation = - (1)
 ENDIF
 SET abc = fillstring(20," ")
 SET abc = format(request->icu_admit_dt_tm,"mm/dd/yyyy hh:mm;;d")
 SET aps_prediction->szicuadmitdatetime = concat(trim(abc),char(0))
 SET abc = fillstring(20," ")
 SET abc = format(request->hosp_admit_dt_tm,"mm/dd/yyyy hh:mm;;d")
 SET aps_prediction->szhospadmitdatetime = concat(trim(abc),char(0))
 SET aps_prediction->sday1meds = request->day1_meds_ind
 SET aps_prediction->sday1verbal = request->day1_verbal
 SET aps_prediction->sday1motor = request->day1_motor
 SET aps_prediction->sday1eyes = request->day1_eyes
 SET aps_prediction->dwday1pao2 = request->day1_pao2
 SET aps_prediction->dwday1fio2 = request->day1_fio2
 SET status = uar_amscalculatepredictions(aps_prediction,aps_outcome)
 CALL echo(build("uar_AmsCalculatePredictions=",status))
 IF (status < 0)
  CALL echo(build("uar_AmsCalculatePredictions err=",uar_amsraprinterror(status)))
 ENDIF
 SET reply->prediction_status = status
 IF ((reply->prediction_status > 0))
  SET cnt = 0
  FOR (num = 1 TO 100)
    IF ((aps_outcome->qual[num].szequationname > " "))
     SET cnt = (cnt+ 1)
     SET stat = alterlist(reply->plist,cnt)
     SET reply->plist[cnt].equation_name = trim(aps_outcome->qual[num].szequationname)
     SET reply->plist[cnt].outcome = aps_outcome->qual[num].dwoutcome
    ENDIF
  ENDFOR
 ELSE
  CASE (reply->prediction_status)
   OF - (23009):
    SET f_text = "Error. Calculate Predictions is missing the ICU Day."
   OF - (23010):
    SET f_text = "Error. Calculate Predictions is missing the APS Today value."
   OF - (23011):
    SET f_text = "Error. Calculate Predictions is missing the APS day1 value."
   OF - (23012):
    SET f_text = "Error. Calculate Predictions is missing the APS yesterday value."
   OF - (23013):
    SET f_text = "Error. Calculate Predictions is missing the patient's DOB."
   OF - (23014):
    SET f_text = "Error. Calculate Predictions is missing hospital admit date."
   OF - (23015):
    SET f_text = "Error. Calculate Predictions is missing ICU admit date."
   OF - (23016):
    SET f_text = "Error. Calculate Predictions is missing admit diagnosis."
   OF - (23017):
    SET f_text = "Error. Calculate Predictions is missing admit source."
   OF - (23018):
    SET f_text = "Error. Calculate Predictions is missing gender."
   OF - (23019):
    SET f_text = "Error. Calculate Predictions is missing meds_ind."
   OF - (23020):
    SET f_text = "Error. Calculate Predictions is missing eyes."
   OF - (23021):
    SET f_text = "Error. Calculate Predictions is missing motor."
   OF - (23022):
    SET f_text = "Error. Calculate Predictions is missing verbal."
   OF - (23023):
    SET f_text = "Error. Calculate Predictions is missing thrombolytics."
   OF - (23024):
    SET f_text = "Error. Calculate Predictions is missing aids."
   OF - (23025):
    SET f_text = "Error. Calculate Predictions is missing hepatic_failure."
   OF - (23026):
    SET f_text = "Error. Calculate Predictions is missing lymphoma."
   OF - (23027):
    SET f_text = "Error. Calculate Predictions is missing metastatic cancer."
   OF - (23028):
    SET f_text = "Error. Calculate Predictions is missing leukemia."
   OF - (23029):
    SET f_text = "Error. Calculate Predictions is missing immunosuppression."
   OF - (23030):
    SET f_text = "Error. Calculate Predictions is missing cirrhosis."
   OF - (23031):
    SET f_text = "Error. Calculate Predictions is missing elective_surgery."
   OF - (23032):
    SET f_text = "Error. Calculate Predictions is missing active treatment."
   OF - (23033):
    SET f_text = "Error. Calculate Predictions is missing any chronic health info."
   OF - (23034):
    SET f_text = "Error. Calculate Predictions is missing readmission info."
   OF - (23035):
    SET f_text = "Error. Calculate Predictions is missing internal mammory artery info."
   OF - (23036):
    SET f_text =
    "Error. CalculatePredictions requires a Hospital Admission Date on or after 01/01/2002."
   OF - (23037):
    SET f_text = "Error.  Calculate Predictions requires a valid GCS-Eyes score for Day 1."
   OF - (23038):
    SET f_text = "Error.  Calculate Predictions requires a valid GCS-Motor score for Day 1"
   OF - (23039):
    SET f_text = "Error.  Calculate Predictions requires a valid GCS-Verbal score for Day 1."
   OF - (23040):
    SET f_text = "Error. CalculatePredictions requires an ICU Admission Date on or after 01/01/2002."
   OF - (23100):
    SET f_text = "Error. Calculate Predictions cannot be done non predictive diagnosis."
   OF - (23101):
    SET f_text = "Error. Calculate Predictions for ICU Day 1 only."
   OF - (23102):
    SET f_text = "Error. Calculate Predictions that Hospital Admission was not before ICU Admission."
   OF - (23103):
    SET f_text = "Error. Calculate Predictions cannot be done on patients < 16 years old."
   OF - (23104):
    SET f_text = "Error. Calculate Predictions received an unknown admit diagnosis."
   OF - (23105):
    SET f_text = "Error. Calculate Predictions received an unknown teach type."
   OF - (23106):
    SET f_text = "Error. Calculate Predictions received an unknown region."
   OF - (23107):
    SET f_text =
    "Error. Calculate Predictions determined that hospital admit date was before 10/01/93."
   OF - (23108):
    SET f_text = "Error. Calculate Predictions must receive a bed count > 0."
   OF - (23109):
    SET f_text =
    "Error. Calculate Predictions cannot be done on patients that are not male or female."
   OF - (23110):
    SET f_text = "Error. Calculate Predictions cannot be done on patients < 0 or > 120 years old."
   OF - (23111):
    SET f_text = "Error. Calculate Predictions cannot be done on CABG redo not Y or N."
   OF - (23112):
    SET f_text = "Error. Calculate Predictions cannot be done with day 1 fio2 < 21 or > 100 percent."
   OF - (23113):
    SET f_text = "Error. Calculate Predictions received an unknown Admit Source."
   OF - (23114):
    SET f_text =
    "Error. Calculate Predictions received an invalid Admit Source and Diagnosis combination."
   OF - (23115):
    SET f_text = "Error. Calculate Predictions cannot be done with a Creatinine < 0.1 or > 25.0."
   OF - (23116):
    SET f_text = "Error. Calculate Predictions cannot be done with an Ejection Fraction < 0 or > 100"
   OF - (23117):
    SET f_text =
    "Error. Calculate Predictions (K) cannot be done on patients admitted from another ICU."
   OF - (23118):
    SET f_text = "Error. Calculate Predictions received an unknown Discharge Location."
   OF - (23119):
    SET f_text = "Error. Calculate Predictions is missing ICU visit number."
   OF - (23120):
    SET f_text = "Error. CalculatePredictions requires a valid AMI location for AMI diagnosis."
   ELSE
    SET f_text = "Error. Unknown Error."
  ENDCASE
  SET reply->status_data.subeventstatus[1].targetobjectvalue = f_text
 ENDIF
#2099_process_exit
#9999_exit_program
 CALL echorecord(reply)
END GO
