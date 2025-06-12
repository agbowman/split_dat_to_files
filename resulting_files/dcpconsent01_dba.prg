CREATE PROGRAM dcpconsent01:dba
 RECORD request(
   1 person_id = f8
   1 print_prsnl_id = f8
   1 order_qual[*]
     2 order_id = f8
     2 encntr_id = f8
     2 conversation_id = f8
   1 printer_name = c50
 )
 SET mrn_alias_cd = 0.0
 SET code_value = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET desc_list[10] = fillstring(100," ")
 SET description[10] = fillstring(15," ")
 SET count1 = size(request->order_qual,5)
 SET size = size(request->order_qual,5)
 DECLARE tempfile1a = vc WITH protect, noconstant(concat("ccluserdir:dcppcf1","_",cnvtalphanum(format
    (curtime3,"hh:mm:ss:cc;;m"))))
 DECLARE print_to_pdf_ind = i2 WITH protect, noconstant(0)
 IF (cnvtlower(request->printer_name)=patstring("*.ps"))
  SET tempfile1a = request->printer_name
  SET print_to_pdf_ind = 1
 ENDIF
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_cd = code_value
 SET order_string = fillstring(50,"")
 SELECT INTO "NL:"
  oc.description
  FROM (dummyt d  WITH seq = value(count1)),
   order_catalog oc,
   (dummyt d1  WITH seq = 1),
   orders o
  PLAN (d)
   JOIN (o
   WHERE (o.order_id=request->order_qual[d.seq].order_id))
   JOIN (d1)
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd)
  DETAIL
   desc_list[d.seq] = trim(oc.description)
  WITH outerjoin = d1, nocounter, dontcare = oc
 ;end select
 SELECT INTO value(tempfile1a)
  p.name_full_formatted, o.person_id, pl.name_full_formatted,
  pa.alias
  FROM person p,
   orders o,
   prsnl pl,
   (dummyt d3  WITH seq = 1),
   person_alias pa
  PLAN (o
   WHERE (o.order_id=request->order_qual[1].order_id))
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (pl
   WHERE pl.person_id=o.last_update_provider_id)
   JOIN (d3)
   JOIN (pa
   WHERE pa.person_id=o.person_id
    AND pa.person_alias_type_cd=mrn_alias_cd
    AND pa.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND pa.active_ind=1)
  HEAD REPORT
   line = fillstring(80,"_"), dashline = fillstring(112,"-"), patient_number = substring(1,26,pa
    .alias),
   patientname = substring(1,50,p.name_full_formatted), persname = substring(1,25,pl
    .name_full_formatted), "{cpi/13}{lpi/7}",
   "{pos/33/19}{box/95/71}", "{font/8}{CPI/12}", row + 1,
   "{pos/110/30}{B}REQUEST AND CONSENT FOR SURGICAL, MEDICAL OR DIAGNOSTIC PROCEDURES{ENDB}", row + 1,
   "{POS/170/40}{B}AND ACKNOWLEDGEMENT OF RECEIPT OF INFORMATION{ENDB}",
   row + 1, "{POS/50/90}PATIENT:  ", patientname,
   row + 1, "{POS/100/91}", line,
   row + 1, "{POS/50/105}PATIENT NO:   ", patient_number" #########################;l",
   "{POS/274/105} DATE:  ", curdate"mm/dd/yyyy;;q", "{POS/394/105} TIME:  ",
   curtime"hh:mm;;m", row + 1,
   "{POS/117/106}__________________________                   ____________                  _______",
   row + 1,
   "{POS/50/120}The hospital and your physician are required by law to obtain your consent to perform the",
   row + 1,
   "{pos/50/130}surgical, medical, or diagnostic procedure(s) listed below.  Signing this form will ",
   row + 1,
   "{pos/50/140}acknowledge that you request and consent to your physician performing the recommended ",
   row + 1,
   "{pos/50/150}procedure(s).  Your signature also confirms that your physician has explained to you ",
   row + 1,
   "{pos/50/160}the procedure(s), the risks of the procedure(s), the alternatives, if any, and risks ",
   row + 1,
   "{pos/50/170}of the alternatives and the risks or consequences of foregoing all treatment.  Please READ",
   row + 1,
   "{pos/50/180}THIS ENTIRE FORM CAREFULLY and then before signing it, ask your physician any additional",
   row + 1,
   "{pos/50/190}questions you may have.  Your request and consent is valid until you withdraw it.",
   row + 1, "{pos/205/207}",
   persname, row + 1,
   "{pos/62/208}I hereby request and authorize ______________________________________ with hospital personnel and/or",
   row + 1, "{pos/312/218}", patientname,
   row + 1,
   "{pos/62/219}other trained person of his/her choice to perform upon ____________________________________________",
   row + 1,
   "{pos/62/229}the following surgical, medical or diagnostic procedure(s):", row + 1, xcol = 70,
   ycol = 239
   FOR (x = 1 TO size)
     CALL print(calcpos(xcol,ycol)), "{b}", desc_list[x],
     "{endb}", row + 1, xcol = ((xcol+ (size(desc_list[x],1) * 5.5))+ 2)
     IF (xcol > 580)
      xcol = 66, ycol += 10
     ENDIF
     IF (ycol > 240)
      x = (size+ 1)
     ENDIF
   ENDFOR
   row + 1,
   "{pos/62/240}_______________________________________________________________________________________",
   row + 1,
   "{pos/66/238}", row + 1,
   "{pos/62/250}to include any necessary or advisable anesthesia and disposal of tissue removed during ",
   row + 1,
   "{pos/62/260}surgery.  I further request and authorize my physician and his assistant(s) to perform",
   row + 1,
   "{pos/62/270}any other procedure that in his or their judgment is advisable for my wellbeing.  This",
   row + 1,
   "{pos/62/280}additional request and authority is extended as I recognize that during the above ",
   row + 1,
   "{pos/62/290}listed procedure(s), unforeseen conditions may require different or additional procedures.",
   row + 1,
   "{pos/62/305}I understand the procedure to be: ____________________________________________________________",
   row + 1,
   "{pos/62/320}_______________________________________________________________________________________",
   row + 1,
   "{pos/62/330}I hereby request and consent to the administration of such anesthetics as are necessary. ",
   row + 1,
   "{pos/62/340}I further request that the choice of anesthetic to be used shall be made by professional",
   row + 1, "{pos/62/350}anesthesia personnel.",
   row + 1,
   "{pos/62/370}I acknowledge that some of the risks shown to be associated with surgery and anesthesia ",
   row + 1,
   "{pos/62/380}and which may be applicable to the proposed procedure(s) are:", row + 1,
   "{pos/62/395}INFECTION",
   "{pos/245/395}LOSS OF FUNCTION IN", "{pos/400/395}LOSS OF BOWEL FUNCTION", row + 1,
   "{POS/62/405}SEVERE BLOOD LOSS", "{pos/250/405}ARM OR LEG",
   "{pos/400/405}PARALYSIS BELOW THE WAIST",
   row + 1, "{POS/62/415}IMPOTENCE", "{pos/245/415}LOSS OF AN ORGAN",
   "{pos/400/415}PARALYSIS BELOW THE NECK", row + 1, "{POS/62/425}DISFIGURING SCARS",
   "{pos/245/425}LOSS OF ARM OR LEG", "{pos/400/425}BRAIN DAMAGE", row + 1,
   "{POS/62/435}LOSS OF FUNCTION OF AN ORGAN", "{POS/245/435}LOSS OF BLADDER FUNCTION",
   "{POS/400/435}DEATH",
   row + 1,
   "{pos/62/450}I am aware that the practice of medicine and surgery is not an exact science and",
   row + 1,
   "{pos/62/460}acknowledge that no guarantees or warranties have been made to me concerning the results",
   row + 1,
   "{pos/62/470}of the procedure(s).  I acknowledge that even though my physician has advised me of all",
   row + 1,
   "{pos/62/480}known risks, up to and including the rare but possible severe risks as revealed in item 3",
   row + 1,
   "{pos/62/490}of this form, that additional unforeseeable and unpreventable situations could arise in",
   row + 1, "{pos/62/500}the course of my care which might result in injury.",
   row + 1, "{pos/62/520}I HEREBY STATE THAT I HAVE READ AND UNDERSTAND THIS REQUEST AND CONSENT AND",
   row + 1,
   "{POS/62/530}THAT ALL MY QUESTIONS HAVE ABOUT THE PROCEDURE(S), ALTERNATIVE PROCEDURES(S),", row
    + 1, "{POS/62/540}AND RISKS OF EACH HAVE BEEN ANSWERED IN LANGUAGE THAT I UNDERSTOOD AND THAT",
   row + 1, "{POS/62/550}ALL BLANKS WERE FILLED IN PRIOR TO MY SIGNATURE.", row + 1,
   "{POS/108/570}Signed: ___________________________________________________________________", row +
   1, "{pos/108/590}Patient or person authorized",
   row + 1,
   "{pos/108/600}to request procedures for patient:  ______________________________________________",
   row + 1,
   "{pos/108/620}Relationships or capacity:  ____________________________________________________",
   row + 1,
   "{pos/108/640}Witness to signature:  ________________________________________________________",
   row + 1,
   " {pos/50/660}I have explained the procedure(s), alternative(s), and risks to the person or persons whose",
   row + 1,
   "{pos/50/670}signatures are affixed above.", row + 1,
   "{pos/108/715}_________________________________________________________________________",
   row + 1, "{pos/250/725}Signature of Physician", row + 1
  WITH outerjoin = d3, dio = postscript, maxcol = 600,
   maxrow = 150
 ;end select
 IF (print_to_pdf_ind=0)
  SET spool value(concat(tempfile1a,".dat")) value(request->printer_name) WITH deleted
 ENDIF
END GO
