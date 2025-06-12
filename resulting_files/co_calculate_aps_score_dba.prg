CREATE PROGRAM co_calculate_aps_score:dba
 RECORD reply(
   1 result = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
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
   1 filler2 = c50
 )
 IF (cursys="AXP")
  RECORD aps_outcome(
    1 qual[100]
      2 cversionnumber = c1
      2 filler1 = c7
      2 dwoutcome = f8
      2 szequationname = c50
      2 filler2 = c6
  )
 ELSE
  RECORD aps_outcome(
    1 qual[100]
      2 cversionnumber = c1
      2 filler1 = c3
      2 dwoutcome = f8
      2 szequationname = c50
      2 filler2 = c2
  )
 ENDIF
 EXECUTE apachertl
 DECLARE status = i4
 SET aps_variable->sintubated = request->intubatedind
 SET aps_variable->svent = request->ventind
 SET aps_variable->sdialysis = request->dialysisind
 SET aps_variable->seyes = request->eyes
 SET aps_variable->smotor = request->motor
 SET aps_variable->sverbal = request->verbal
 SET aps_variable->smeds = request->meds
 SET aps_variable->dwurine = request->urine
 SET aps_variable->dwwbc = request->wbc
 SET aps_variable->dwtemp = request->temp
 SET aps_variable->dwrespiratoryrate = request->respiratoryrate
 SET aps_variable->dwsodium = request->sodium
 SET aps_variable->dwheartrate = request->heartrate
 SET aps_variable->dwmeanbp = request->meanbp
 SET aps_variable->dwph = request->ph
 SET aps_variable->dwhematocrit = request->hematocrit
 SET aps_variable->dwcreatinine = request->creatinine
 SET aps_variable->dwalbumin = request->albumin
 SET aps_variable->dwpao2 = request->pao2
 SET aps_variable->dwpco2 = request->pco2
 SET aps_variable->dwbun = request->bun
 SET aps_variable->dwglucose = request->glucose
 SET aps_variable->dwbilirubin = request->bilirubin
 SET aps_variable->dwfio2 = request->fio2
 CALL echo(build("p1=",size(aps_variable),",p2=",size(aps_prediction),",p3=",
   size(aps_outcome)))
 SET status = uar_amsapscalculate(aps_variable)
 CALL echo(build("uar_AmsApsCalculate=",status))
 SET reply->result = cnvtstring(status)
 SET reply->status_data.status = "S"
#9999_exit_program
 CALL echorecord(reply)
END GO
