CREATE PROGRAM bhs_rpt_narco_contract:dba
 FREE RECORD t_record
 RECORD t_record(
   1 encntr = f8
   1 pat_name = vc
   1 pat_dob = vc
   1 encntr_dt = vc
   1 provider = vc
   1 pcp = vc
   1 fin = vc
   1 mrn = vc
   1 para1 = vc
   1 para2 = vc
   1 para3 = vc
   1 para4 = vc
   1 para5 = vc
   1 para6 = vc
   1 para7 = vc
   1 para8 = vc
   1 para9 = vc
   1 para10 = vc
   1 para11 = vc
   1 para12 = vc
   1 para13 = vc
   1 para14 = vc
   1 para15 = vc
   1 para16 = vc
   1 para17 = vc
   1 para18 = vc
   1 para19 = vc
   1 para20 = vc
   1 para21 = vc
   1 para22 = vc
   1 para23 = vc
   1 para24 = vc
   1 para25 = vc
   1 para26 = vc
   1 para27 = vc
   1 para28 = vc
   1 para29 = vc
   1 para30 = vc
   1 para31 = vc
   1 para32 = vc
   1 para32b = vc
   1 para33 = vc
   1 para34 = vc
   1 para35 = vc
   1 para36 = vc
   1 para37 = vc
   1 para38 = vc
   1 para39 = vc
   1 para40 = vc
   1 para41 = vc
   1 para41b = vc
   1 para42 = vc
   1 para43 = vc
   1 para44 = vc
   1 para45 = vc
   1 para46 = vc
   1 line_cnt = i2
   1 line_qual[*]
     2 line = vc
 )
 IF (validate(request->visit,"Z") != "Z")
  SET printer_name = request->output_device
  SET t_record->encntr = request->visit[1].encntr_id
 ENDIF
 DECLARE fin_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mrn_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4,"CORPORATEMEDICALRECORDNUMBER"))
 DECLARE pcp_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",331,"PCP"))
 DECLARE attend_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,"ATTENDINGPHYSICIAN"))
 DECLARE t_line = vc
 DECLARE out_file = vc
 SELECT INTO "nl:"
  FROM encounter e,
   person p
  PLAN (e
   WHERE (e.encntr_id=t_record->encntr))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
  DETAIL
   t_record->pat_name = p.name_full_formatted, t_record->pat_dob = trim(format(cnvtdatetimeutc(
      datetimezone(p.birth_dt_tm,p.birth_tz),1),"mm-dd-yyyy;;q"))
  WITH nocounter
 ;end select
 SET t_record->encntr_dt = format(curdate,"mm-dd-yyyy;;q")
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_prsnl_reltn epr,
   prsnl p
  PLAN (e
   WHERE (e.encntr_id=t_record->encntr))
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=attend_cd)
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id)
  DETAIL
   t_record->provider = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   person_prsnl_reltn ppr,
   prsnl p
  PLAN (e
   WHERE (e.encntr_id=t_record->encntr))
   JOIN (ppr
   WHERE ppr.person_id=e.person_id
    AND ppr.person_prsnl_r_cd=pcp_cd
    AND ppr.active_ind=1
    AND cnvtdatetime(sysdate) BETWEEN ppr.beg_effective_dt_tm AND ppr.end_effective_dt_tm)
   JOIN (p
   WHERE p.person_id=ppr.prsnl_person_id
    AND p.active_ind=1)
  ORDER BY ppr.beg_effective_dt_tm DESC
  HEAD ppr.person_id
   t_record->pcp = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_alias ea
  PLAN (ea
   WHERE (ea.encntr_id=t_record->encntr)
    AND ea.encntr_alias_type_cd=fin_cd
    AND ea.active_ind=1)
  DETAIL
   t_record->fin = ea.alias
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   person_alias p
  PLAN (e
   WHERE (e.encntr_id=t_record->encntr))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.person_alias_type_cd=mrn_cd)
  DETAIL
   t_record->mrn = p.alias
  WITH nocounter
 ;end select
 SET t_record->para1 = concat(
  "My health care provider  (noted above) has recommended that I be placed on a trial of",
  " {f/11}controlled substances{f/8} to help manage my medical condition better and to",
  " improve my ability to participate in daily activities. This is a decision that I have made",
  " after fully discussing with my provider the risks and benefits of this treatment, as well as",
  " alternatives to this treatment.")
 SET t_record->para2 = concat(
  "I understand that treatment with controlled substances does have risks, including, but not",
  " limited to constipation, decreased appetite, nausea, drowsiness, confusion or other change in",
  " thinking ability, and problems with balance. These may make it unsafe to operate dangerous",
  " equipment or motor vehicles. I understand that there is a risk of having problems urinating,",
  " sexual difficulties and of breathing too slowly, and that an overdose can lead to respiratory",
  " arrest and death. There are known and unknown risks to unborn children, which include dependence,",
  " and other less common side effects.")
 SET t_record->para3 = concat(
  "I understand that there is a risk of physical dependence, which means that abruptly stopping the",
  " drug, may lead to withdrawal syndrome characterized by one or more of the following: runny nose,",
  " diarrhea, abdominal cramping, ",char(34),"goose flesh",
  char(34)," or anxiety.")
 SET t_record->para4 = concat(
  "I understand that there is a risk of psychological dependence, which means it is possible that",
  " stopping the drug will cause me to miss or crave it.")
 SET t_record->para5 = concat(
  "My provider is willing to begin or continue treating me with controlled substances under the",
  " following set of conditions, which I agree to: ")
 SET t_record->para6 = concat(
  "Other acceptable forms of medical treatment have not been effective or have produced too many",
  " side effects.")
 SET t_record->para7 = concat("I do not currently have problems with substance abuse or dependence.",
  " I have disclosed all previous and current substance use with my provider.")
 SET t_record->para8 = concat(
  "I am not currently involved in the sale, illegal possession, diversion, or transport of controlled",
  " substances (narcotics, sleeping pills, nerve pills, or painkillers).")
 SET t_record->para9 = concat(
  "I agree to obtain prescriptions for controlled substances only from my provider and/or my",
  " providers's colleagues. I agree to notify my provider in advance of any acute needs",
  " (i.e. dental work, surgery) that may necessitate a change in my medication dose.")
 SET t_record->para10 = concat(
  "I will take medicines only as prescribed by my provider and/or my provider's colleagues, and",
  " under no circumstances, allow other individuals to take my medications.")
 SET t_record->para11 = concat(
  "I give permission to my provider and/or my provider's colleagues to communicate with any other",
  " physician or health care provider and any pharmacists regarding my care and treatment in the",
  " use of controlled substances. ")
 SET t_record->para12 = concat(
  "I will follow the advice of my provider and/or my providers's colleagues in regard to stopping",
  " the use of controlled substances, should they feel it advisable.")
 SET t_record->para13 = concat(
  "I understand and consent to have unannounced {f/9}pill counts, blood screen or urine tests{f/8}",
  " in order to assess properly the effect of these medications I am prescribed and to assess my",
  " compliance with my medical regimen.")
 SET t_record->para14 = concat(
  "I understand that I must present for unannounced {f/9}pill counts, blood screen or",
  " urine tests{f/8} within 24 hours of notification.")
 SET t_record->para15 = concat(
  "I understand that my provider may recommend consultations/evaluations by other healthcare",
  " providers. This may include:")
 SET t_record->para16 =
 "I will see a psychiatrist for evaluation for psychotropic medications and treatment."
 SET t_record->para17 = concat(
  "I will see a psychologist or other health care provider for behavioral or other mental health",
  " care which may include Behavioral Pain Management.")
 SET t_record->para18 = "I will see an acupuncturist for acupuncture."
 SET t_record->para19 =
 "I will see a physician or other health care provider for this or other medical conditions."
 SET t_record->para20 = "Physical or Occupational Therapy."
 SET t_record->para21 = "Home Exercise Program."
 SET t_record->para22 = concat(
  "Due to known and unknown risks to unborn children, which include addiction, I will",
  " notify my provider if I am pregnant, or if I become pregnant in the future.")
 SET t_record->para23 = concat(
  "I understand that, in general, allowances {f/9}will not{f/8} be made for lost prescriptions",
  " or drugs. I will follow the policies for prescription refills of my provider's practice.")
 SET t_record->para24 = concat(
  "I understand that in general, my medical management treatment with controlled substances will",
  " be stopped if any of the following occur:")
 SET t_record->para25 = concat(
  "My provider and/or my providers's colleagues feel that the medications are not effective or",
  " that my functional activity is not improved.")
 SET t_record->para26 = "I give, sell, or misuse the drugs."
 SET t_record->para27 = "I develop rapid tolerance or loss of effect from this treatment."
 SET t_record->para28 = concat(
  "I develop side effects that my provider or my providers's colleagues believe are significant and",
  " detrimental to me.")
 SET t_record->para29 =
 "I obtain controlled substances from sources other than my provider and/or my providers's colleagues."
 SET t_record->para30 =
 "If test results indicate the improper use of prescribed medications or the use of illicit drugs."
 SET t_record->para31 = "I violate any of the terms of this consent form."
 SET t_record->para32 = "I miss 2 or more appointments."
 SET t_record->para32b =
 "I engage in inappropriate or threatening behavior toward my provider or support staff."
 SET t_record->para33 = concat(
  "If my provider needs to discontinue my medications, the dose will usually be reduced slowly over",
  " several days.  If my provider believes that I have a drug dependency problem, I may be referred",
  " to another health care provider for management of that dependency.")
 SET t_record->para34 =
 "I understand that I must abstain from any illegal drugs and alcohol while under treatment."
 SET t_record->para35 = concat(
  "I understand that I may need to identify a sponsor. This is someone who can attend",
  " an office visit periodically  and provide feedback regarding my function at home.")
 SET t_record->para36 = concat(
  "I understand I may not be allowed to drive or operate equipment that may put me or others",
  " at risk during periods of medication adjustments.")
 SET t_record->para37 =
 "I understand that I must keep all of my medication in a safe or locked box in a secure place."
 SET t_record->para38 = concat(
  "My provider recommends that I limit my health discussion to my healthcare providers and",
  " immediate family members.")
 SET t_record->para39 = concat(
  "I will report any new medications prescribed for me from other providers,",
  " including new medications from Emergency Department visits.")
 SET t_record->para40 = concat(
  "Once my medical condition is controlled and my medication regimen is stable,",
  " my continued prescription(s) of controlled substances",
  "may be deferred to my Primary Care Provider, or other healthcare provider,",
  " after discussion between both health professionals.")
 SET t_record->para41 = concat(
  "I need to notify my provider if I need to change pharmacies, if not done",
  " this action may make this agreement invalid.")
 SET t_record->para41b = concat(
  "Patient needs to notify the prescribing provider of changes in Primary Care Provider,",
  " if the prescribing provider is not the Primary Care Provider.")
 SET t_record->para42 = concat(
  "I have read this document, understand it, and have had all questions answered satisfactorily.",
  " I consent to the use of controlled substances to help control my medical condition, and I",
  " understand that my treatment with controlled substances will be carried out in accordance with",
  " the conditions stated above.")
 SET t_record->para43 = concat(
  "I agree to give a copy of this document to my pharmacist. If two pharmacies must be used, each",
  " pharmacy will receive a copy of this document. I agree to inform each pharmacy as to what",
  " medication I am receiving from the other.")
 SET t_record->para44 = concat(
  "I will use only _______________________________ Pharmacy for the filling of prescriptions for",
  " controlled substances.")
 SET t_record->para45 = concat(
  "I certify that the above named patient or responsible individual has received from me an",
  " explanation of this document. I have disclosed alternative methods of management that might be appropriate for",
  " the patient. I have offered to answer any questions by this patient/responsible individual.")
 SET t_record->para46 = concat(
  "I have interpreted the information and advice presented orally to the individual giving consent",
  " by the person obtaining this consent.  To the best of my knowledge and belief, the patient",
  " understood this explanation.")
 SET out_file = concat("narcocontract",cnvtlower(t_record->fin))
 SELECT INTO value(out_file)
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD PAGE
   "{f/8}{cpi/10}", y_pos = 714, t_line = concat("(Patient Name: ",t_record->pat_name,")"),
   "{ps/68", y_pos, " moveto ",
   t_line, " show/}", row + 1,
   t_line = concat("(Patient DOB: ",t_record->pat_dob,")"), "{ps/400", y_pos,
   " moveto ", t_line, " show/}",
   row + 1, y_pos -= 12, t_line = concat("(Date of encounter: ",t_record->encntr_dt,")"),
   "{ps/68", y_pos, " moveto ",
   t_line, " show/}", row + 1,
   t_line = concat("(Acct.#: ",t_record->fin,")"), "{ps/400", y_pos,
   " moveto ", t_line, " show/}",
   row + 1, y_pos -= 12, t_line = concat("(Provider: ",t_record->provider,")"),
   "{ps/68", y_pos, " moveto ",
   t_line, " show/}", row + 1,
   t_line = concat("(MRN: ",t_record->mrn,")"), "{ps/400", y_pos,
   " moveto ", t_line, " show/}",
   row + 1, y_pos -= 12, t_line = concat("(Primary Care Provider: ",t_record->pcp,")"),
   "{ps/68", y_pos, " moveto ",
   t_line, " show/}", row + 1
  DETAIL
   y_pos -= 32, t_line = "(AGREEMENT FOR THE PRESCRIPTION OF CONTROLLED SUBSTANCES)", "{b}{ps/306",
   y_pos, " moveto ", t_line,
   " dup stringwidth pop 2 div neg 0 rmoveto show/}{endb}", row + 1, y_pos -= 24,
   CALL lines(t_record->para1,90)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(68,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, t_line = "(RISKS:)", "{b}{ps/68",
   y_pos, " moveto ", t_line,
   " show/}{endb}", row + 1, y_pos -= 20,
   CALL lines(t_record->para2,90)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(68,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8,
   CALL lines(t_record->para3,90)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(68,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8,
   CALL lines(t_record->para4,90)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(68,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, t_line = "(CONDITIONS:)", "{b}{ps/68",
   y_pos, " moveto ", t_line,
   " show/}{endb}", row + 1, y_pos -= 20,
   CALL lines(t_record->para5,90)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(68,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (1.) show/}",
   CALL lines(t_record->para6,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(94,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (2.) show/}",
   CALL lines(t_record->para7,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(94,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (3.) show/}",
   CALL lines(t_record->para8,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(94,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (4.) show/}",
   CALL lines(t_record->para9,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(94,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (5.) show/}",
   CALL lines(t_record->para10,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(94,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (6.) show/}",
   CALL lines(t_record->para11,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(94,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos = 36, t_line = "(Page 1 of 4)", "{ps/306",
   y_pos, " moveto ", t_line,
   " dup stringwidth pop 2 div neg 0 rmoveto show/}", row + 1, BREAK,
   y_pos -= 32, "{ps/80", y_pos,
   " moveto (7.) show/}",
   CALL lines(t_record->para12,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(94,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (8.) show/}",
   CALL lines(t_record->para13,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(94,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (9.) show/}",
   CALL lines(t_record->para14,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(94,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (10.) show/}",
   CALL lines(t_record->para15,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (a.) show/}",
   CALL lines(t_record->para16,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (b.) show/}",
   CALL lines(t_record->para17,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (c.) show/}",
   CALL lines(t_record->para18,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (d.) show/}",
   CALL lines(t_record->para19,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (e.) show/}",
   CALL lines(t_record->para20,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (f.) show/}",
   CALL lines(t_record->para21,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (11.) show/}",
   CALL lines(t_record->para22,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (12.) show/}",
   CALL lines(t_record->para23,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (13.) show/}",
   CALL lines(t_record->para24,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (a.) show/}",
   CALL lines(t_record->para25,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (b.) show/}",
   CALL lines(t_record->para26,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (c.) show/}",
   CALL lines(t_record->para27,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (d.) show/}",
   CALL lines(t_record->para28,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (e.) show/}",
   CALL lines(t_record->para29,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (f.) show/}",
   CALL lines(t_record->para30,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos = 36, t_line = "(Page 2 of 4)", "{ps/306",
   y_pos, " moveto ", t_line,
   " dup stringwidth pop 2 div neg 0 rmoveto show/}", row + 1, BREAK,
   y_pos -= 32, "{ps/98", y_pos,
   " moveto (g.) show/}",
   CALL lines(t_record->para31,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (h.) show/}",
   CALL lines(t_record->para32,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (i.) show/}",
   CALL lines(t_record->para32b,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (14.) show/}",
   CALL lines(t_record->para33,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (15.) show/}",
   CALL lines(t_record->para34,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (16.) show/}",
   CALL lines(t_record->para35,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (17.) show/}",
   CALL lines(t_record->para36,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (18.) show/}",
   CALL lines(t_record->para37,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (19.) show/}",
   CALL lines(t_record->para38,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (20.) show/}",
   CALL lines(t_record->para39,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (21.) show/}",
   CALL lines(t_record->para40,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (22.) show/}",
   CALL lines(t_record->para41,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (23.) show/}",
   CALL lines(t_record->para41b,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8,
   CALL lines(t_record->para42,90)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(68,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8,
   CALL lines(t_record->para43,90)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(68,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos = 36, t_line = "(Page 3 of 4)", "{ps/306",
   y_pos, " moveto ", t_line,
   " dup stringwidth pop 2 div neg 0 rmoveto show/}", row + 1, BREAK,
   "{cpi/8}", y_pos -= 32, t_line = "(SIGNATURE PAGE)",
   "{b}{ps/306", y_pos, " moveto ",
   t_line, " dup stringwidth pop 2 div neg 0 rmoveto show/}{endb}", row + 1,
   "{cpi/10}", y_pos -= 32,
   CALL lines(t_record->para44,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(68,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 14
   ENDFOR
   y_pos -= 32, "{b}{ps/newpath 68 ", y_pos,
   " moveto 350 ", y_pos, " lineto stroke 36 ",
   y_pos, " moveto/}{endb}", row + 1,
   "{b}{ps/newpath 450 ", y_pos, " moveto 520 ",
   y_pos, " lineto stroke 450 ", y_pos,
   " moveto/}{endb}", y_pos -= 14, t_line = "PATIENT",
   "{b}{ps/68", y_pos, " moveto (",
   t_line, ") show/}{endb}", row + 1,
   t_line = "DATE", "{b}{ps/450", y_pos,
   " moveto (", t_line, ") show/}{endb}",
   row + 1, y_pos -= 32, "{b}{ps/newpath 68 ",
   y_pos, " moveto 350 ", y_pos,
   " lineto stroke 68 ", y_pos, " moveto/}{endb}",
   row + 1, "{b}{ps/newpath 450 ", y_pos,
   " moveto 520 ", y_pos, " lineto stroke 450 ",
   y_pos, " moveto/}{endb}", y_pos -= 14,
   t_line = "WITNESS", "{b}{ps/68", y_pos,
   " moveto (", t_line, ") show/}{endb}",
   row + 1, t_line = "DATE", "{b}{ps/450",
   y_pos, " moveto (", t_line,
   ") show/}{endb}", row + 1, y_pos -= 32,
   t_line = "(PHYSICIAN ~ NURSE CERTIFICATION)", "{b}{ps/306", y_pos,
   " moveto ", t_line, " dup stringwidth pop 2 div neg 0 rmoveto show/}{endb}",
   row + 1, y_pos -= 16,
   CALL lines(t_record->para45,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(68,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 32, "{b}{ps/newpath 68 ", y_pos,
   " moveto 350 ", y_pos, " lineto stroke 68 ",
   y_pos, " moveto/}{endb}", row + 1,
   "{b}{ps/newpath 450 ", y_pos, " moveto 520 ",
   y_pos, " lineto stroke 450 ", y_pos,
   " moveto/}{endb}", y_pos -= 14, t_line = "PHYSICIAN ~ NURSE",
   "{b}{ps/68", y_pos, " moveto (",
   t_line, ") show/}{endb}", row + 1,
   t_line = "DATE", "{b}{ps/450", y_pos,
   " moveto (", t_line, ") show/}{endb}",
   row + 1, y_pos -= 32, t_line = "(INTERPRETER STATEMENT)",
   "{b}{ps/306", y_pos, " moveto ",
   t_line, " dup stringwidth pop 2 div neg 0 rmoveto show/}{endb}", row + 1,
   y_pos -= 16,
   CALL lines(t_record->para46,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(68,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 32, "{b}{ps/newpath 68 ", y_pos,
   " moveto 350 ", y_pos, " lineto stroke 68 ",
   y_pos, " moveto/}{endb}", row + 1,
   "{b}{ps/newpath 450 ", y_pos, " moveto 520 ",
   y_pos, " lineto stroke 450 ", y_pos,
   " moveto/}{endb}", y_pos -= 14, t_line = "INTERPRETER",
   "{b}{ps/68", y_pos, " moveto (",
   t_line, ") show/}{endb}", row + 1,
   t_line = "DATE", "{b}{ps/450", y_pos,
   " moveto (", t_line, ") show/}{endb}",
   row + 1, y_pos = 36, t_line = "(Page 4 of 4)",
   "{ps/306", y_pos, " moveto ",
   t_line, " dup stringwidth pop 2 div neg 0 rmoveto show/}", row + 1
  WITH maxrow = 750, maxcol = 3200, dio = postscript,
   nullreport
 ;end select
 SET spool patstring(out_file) patstring(printer_name) WITH deleted
 SUBROUTINE lines(string,chars)
   DECLARE ms_temp_str = vc WITH protect, noconstant("")
   DECLARE ml_chars = i4 WITH protect, noconstant(0)
   DECLARE ml_not_done = i4 WITH protect, noconstant(0)
   DECLARE ml_last = i4 WITH protect, noconstant(0)
   SET ms_temp_str = string
   SET ml_chars = chars
   SET t_record->line_cnt = 0
   SET stat = alterlist(t_record->line_qual,0)
   SET ml_not_done = 1
   WHILE (ml_not_done=1)
    SET ml_last = findstring(" ",substring(1,ml_chars,ms_temp_str),1,1)
    IF (textlen(ms_temp_str) <= ml_chars)
     SET ml_not_done = 0
     IF (textlen(ms_temp_str) > 0)
      SET t_record->line_cnt += 1
      SET stat = alterlist(t_record->line_qual,t_record->line_cnt)
      SET t_record->line_qual[t_record->line_cnt].line = trim(ms_temp_str,2)
     ENDIF
    ELSE
     SET t_record->line_cnt += 1
     SET stat = alterlist(t_record->line_qual,t_record->line_cnt)
     SET t_record->line_qual[t_record->line_cnt].line = trim(substring(1,ml_last,ms_temp_str),2)
     SET ms_temp_str = trim(substring((ml_last+ 1),textlen(ms_temp_str),ms_temp_str),3)
    ENDIF
   ENDWHILE
 END ;Subroutine
END GO
