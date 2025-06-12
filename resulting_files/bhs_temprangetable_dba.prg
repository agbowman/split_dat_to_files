CREATE PROGRAM bhs_temprangetable:dba
 FREE RECORD scoresystem
 RECORD scoresystem(
   1 qual[*]
     2 event_cd = f8
     2 grouperid = f8
     2 lookbackhours = i4
     2 eventcompare = i4
     2 scores[*]
       3 parentid = f8
       3 index = f8
       3 scoretype = vc
       3 seq = i4
       3 score = i4
       3 lowerrange = f8
       3 upperrange = f8
       3 val = vc
       3 changetype = vc
 )
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
 SET scorecnt = 0
 SET qualcnt = 0
 SET qualcnt = (qualcnt+ 1)
 SET stat = alterlist(scoresystem->qual,qualcnt)
 SET scoresystem->qual[qualcnt].event_cd = 0.0
 SET scoresystem->qual[qualcnt].lookbackhours = 0
 SET scoresystem->qual[qualcnt].grouperid = 0
 SET scoresystem->qual[qualcnt].eventcompare = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype =
 "                                        "
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype =
 "                                       "
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val =
 "                                              "
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 0
 SET qualcnt = (qualcnt+ 1)
 SET stat = alterlist(scoresystem->qual,qualcnt)
 SET scoresystem->qual[qualcnt].event_cd = temp_cd
 SET scoresystem->qual[qualcnt].lookbackhours = 24
 SET scoresystem->qual[qualcnt].grouperid = 1
 SET scoresystem->qual[qualcnt].eventcompare = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "GREATERTHEN"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = "101.3"
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 2
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 5305
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "LESSTHEN"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = "98"
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 2
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 5305
 SET scorecnt = 0
 SET qualcnt = (qualcnt+ 1)
 SET stat = alterlist(scoresystem->qual,qualcnt)
 SET scoresystem->qual[qualcnt].event_cd = hr_cd
 SET scoresystem->qual[qualcnt].lookbackhours = 24
 SET scoresystem->qual[qualcnt].grouperid = 2
 SET scoresystem->qual[qualcnt].eventcompare = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "GREATERTHEN"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = "130"
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 3
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 5306
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "LESSTHEN"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = "40"
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 2
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 5306
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "RANGE"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 111
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 129
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 2
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 45306
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "RANGE"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 40
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 50
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 1
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 45306
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "RANGE"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 101
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 110
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 1
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 45306
 SET scorecnt = 0
 SET qualcnt = (qualcnt+ 1)
 SET stat = alterlist(scoresystem->qual,qualcnt)
 SET scoresystem->qual[qualcnt].event_cd = sbp_cd
 SET scoresystem->qual[qualcnt].lookbackhours = 24
 SET scoresystem->qual[qualcnt].grouperid = qualcnt
 SET scoresystem->qual[qualcnt].eventcompare = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "LESSTHEN"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = "70"
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 3
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "GREATERTHEN"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = "200"
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 3
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "RANGE"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 71
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 80
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 2
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "RANGE"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 81
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 100
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 1
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 0
 SET scorecnt = 0
 SET qualcnt = (qualcnt+ 1)
 SET stat = alterlist(scoresystem->qual,qualcnt)
 SET scoresystem->qual[qualcnt].event_cd = rr_cd
 SET scoresystem->qual[qualcnt].lookbackhours = 24
 SET scoresystem->qual[qualcnt].grouperid = qualcnt
 SET scoresystem->qual[qualcnt].eventcompare = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "LESSTHEN"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = "8"
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 3
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "GREATERTHEN"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = "30"
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 3
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "RANGE"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 21
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 30
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 2
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 0
 SET scorecnt = 0
 SET qualcnt = (qualcnt+ 1)
 SET stat = alterlist(scoresystem->qual,qualcnt)
 SET scoresystem->qual[qualcnt].event_cd = sodium_cd
 SET scoresystem->qual[qualcnt].lookbackhours = 48
 SET scoresystem->qual[qualcnt].grouperid = qualcnt
 SET scoresystem->qual[qualcnt].eventcompare = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "GREATERTHEN"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = "145"
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 3
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "LESSTHEN"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = "130"
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 2
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "RANGE"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 131
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 135
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 1
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 0
 SET scorecnt = 0
 SET qualcnt = (qualcnt+ 1)
 SET stat = alterlist(scoresystem->qual,qualcnt)
 SET scoresystem->qual[qualcnt].event_cd = bili_cd
 SET scoresystem->qual[qualcnt].lookbackhours = 48
 SET scoresystem->qual[qualcnt].grouperid = qualcnt
 SET scoresystem->qual[qualcnt].eventcompare = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "GREATERTHEN"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = "1.75"
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 3
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 0
 SET scorecnt = 0
 SET qualcnt = (qualcnt+ 1)
 SET stat = alterlist(scoresystem->qual,qualcnt)
 SET scoresystem->qual[qualcnt].event_cd = platelet_cd
 SET scoresystem->qual[qualcnt].lookbackhours = 48
 SET scoresystem->qual[qualcnt].grouperid = qualcnt
 SET scoresystem->qual[qualcnt].eventcompare = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "LESSTHEN"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = "150"
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 3
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 0
 SET scorecnt = 0
 SET qualcnt = (qualcnt+ 1)
 SET stat = alterlist(scoresystem->qual,qualcnt)
 SET scoresystem->qual[qualcnt].event_cd = glucose_cd
 SET scoresystem->qual[qualcnt].lookbackhours = 48
 SET scoresystem->qual[qualcnt].grouperid = qualcnt
 SET scoresystem->qual[qualcnt].eventcompare = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "GREATERTHEN"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = "400"
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 3
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "LESSTHEN"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = "40"
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 3
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 0
 SET scorecnt = 0
 SET qualcnt = (qualcnt+ 1)
 SET stat = alterlist(scoresystem->qual,qualcnt)
 SET scoresystem->qual[qualcnt].event_cd = glucosepoc_cd
 SET scoresystem->qual[qualcnt].lookbackhours = 48
 SET scoresystem->qual[qualcnt].grouperid = qualcnt
 SET scoresystem->qual[qualcnt].eventcompare = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "GREATERTHEN"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = "400"
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 3
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 5308
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "LESSTHEN"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = "40"
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 3
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 5308
 SET scorecnt = 0
 SET qualcnt = (qualcnt+ 1)
 SET stat = alterlist(scoresystem->qual,qualcnt)
 SET scoresystem->qual[qualcnt].event_cd = creatinine_cd
 SET scoresystem->qual[qualcnt].lookbackhours = 48
 SET scoresystem->qual[qualcnt].grouperid = qualcnt
 SET scoresystem->qual[qualcnt].eventcompare = 1
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "PERCENTINCREASE"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = "SINCEADMIN"
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = "100"
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 3
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 0
 SET scorecnt = 0
 SET qualcnt = (qualcnt+ 1)
 SET stat = alterlist(scoresystem->qual,qualcnt)
 SET scoresystem->qual[qualcnt].event_cd = lactate_cd
 SET scoresystem->qual[qualcnt].lookbackhours = 48
 SET scoresystem->qual[qualcnt].grouperid = qualcnt
 SET scoresystem->qual[qualcnt].eventcompare = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "GREATERTHEN"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = "4"
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 4
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 0
 SET scorecnt = 0
 SET qualcnt = (qualcnt+ 1)
 SET stat = alterlist(scoresystem->qual,qualcnt)
 SET scoresystem->qual[qualcnt].event_cd = wbc_cd
 SET scoresystem->qual[qualcnt].lookbackhours = 48
 SET scoresystem->qual[qualcnt].grouperid = qualcnt
 SET scoresystem->qual[qualcnt].eventcompare = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "GREATERTHEN"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = "16"
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 3
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "LESSTHEN"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = "4"
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 3
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 0
 SET scorecnt = 0
 SET qualcnt = (qualcnt+ 1)
 SET stat = alterlist(scoresystem->qual,qualcnt)
 SET scoresystem->qual[qualcnt].event_cd = ph_cd
 SET scoresystem->qual[qualcnt].lookbackhours = 48
 SET scoresystem->qual[qualcnt].grouperid = qualcnt
 SET scoresystem->qual[qualcnt].eventcompare = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "GREATERTHEN"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = "7.5"
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 3
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "LESSTHEN"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = "7.2"
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 3
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 0
 SET scorecnt = 0
 SET qualcnt = (qualcnt+ 1)
 SET stat = alterlist(scoresystem->qual,qualcnt)
 SET scoresystem->qual[qualcnt].event_cd = band_cd
 SET scoresystem->qual[qualcnt].lookbackhours = 48
 SET scoresystem->qual[qualcnt].grouperid = qualcnt
 SET scoresystem->qual[qualcnt].eventcompare = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "GREATERTHEN"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = "10"
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 3
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 0
 SET scorecnt = 0
 SET qualcnt = (qualcnt+ 1)
 SET stat = alterlist(scoresystem->qual,qualcnt)
 SET scoresystem->qual[qualcnt].event_cd = o2sat_cd
 SET scoresystem->qual[qualcnt].lookbackhours = 48
 SET scoresystem->qual[qualcnt].grouperid = qualcnt
 SET scoresystem->qual[qualcnt].eventcompare = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "LESSTHEN"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 0
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = "90"
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 3
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "RANGE"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 90
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 92
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 2
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 0
 SET scorecnt = (scorecnt+ 1)
 SET stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt)
 SET scoresystem->qual[qualcnt].scores[scorecnt].index = sequence(0)
 SET scoresystem->qual[qualcnt].scores[scorecnt].seq = scorecnt
 SET scoresystem->qual[qualcnt].scores[scorecnt].scoretype = "RANGE"
 SET scoresystem->qual[qualcnt].scores[scorecnt].changetype = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].lowerrange = 93
 SET scoresystem->qual[qualcnt].scores[scorecnt].upperrange = 95
 SET scoresystem->qual[qualcnt].scores[scorecnt].val = ""
 SET scoresystem->qual[qualcnt].scores[scorecnt].score = 2
 SET scoresystem->qual[qualcnt].scores[scorecnt].parentid = 0
 DELETE  FROM bhs_range_system b
  WHERE b.range_id >= 0
 ;end delete
 COMMIT
 SET updt_dt_tmt = format(cnvtdatetime(curdate,curtime),";;q")
 INSERT  FROM bhs_range_system b
  SET b.range_id = scoresystem->qual[1].scores[1].index, b.val = " ", b.change_type = " ",
   range_type = " ", b.look_back_hours = 0, b.parent_entity_id = 0,
   b.parent_entity_name = " ", b.seq = 0, b.score = 0,
   b.lowerrange = 0, b.upperrange = 0, b.active_ind = 1,
   b.updt_id = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime)
  WITH nocounter
 ;end insert
 COMMIT
 SET cnt = size(scoresystem->qual,5)
 CALL echorecord(scoresystem)
 SELECT
  *
  FROM bhs_event_cd_list b,
   (dummyt d  WITH seq = size(scoresystem->qual,5))
  PLAN (d)
   JOIN (b
   WHERE (b.event_cd=scoresystem->qual[d.seq].event_cd))
  DETAIL
   FOR (y = 1 TO size(scoresystem->qual[d.seq].scores,5))
     scoresystem->qual[d.seq].scores[y].parentid = b.event_cd_list_id
   ENDFOR
  WITH nocounter
 ;end select
 IF (cnt > 1)
  CALL echo("Insert new rows")
  FOR (y = 2 TO cnt)
    FOR (p = 1 TO size(scoresystem->qual[y].scores,5))
     INSERT  FROM bhs_range_system r
      SET r.range_id = scoresystem->qual[y].scores[p].index, r.range_type = scoresystem->qual[y].
       scores[p].scoretype, r.look_back_hours = scoresystem->qual[y].lookbackhours,
       r.parent_entity_id = scoresystem->qual[y].scores[p].parentid, r.parent_entity_name =
       "bhs_event_cd_list", r.seq = scoresystem->qual[y].scores[p].seq,
       r.score = scoresystem->qual[y].scores[p].score, r.lowerrange = scoresystem->qual[y].scores[p].
       lowerrange, r.upperrange = scoresystem->qual[y].scores[p].upperrange,
       r.val = scoresystem->qual[y].scores[p].val, r.change_type = scoresystem->qual[y].scores[p].
       changetype, r.active_ind = 1,
       r.updt_id = reqinfo->updt_id, updt_dt_tm = updt_dt_tmt
      PLAN (r)
      WITH nocounter
     ;end insert
     COMMIT
    ENDFOR
  ENDFOR
 ENDIF
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
   IF (curqual=0)
    SET errmsg = "bhs_eks_seq failed"
    GO TO exit_program
   ENDIF
   RETURN(early_warning_id)
 END ;Subroutine
END GO
