CREATE PROGRAM bbd_tmp_donor_card
 PROMPT
  "Output to File/Printer/MINE " = mine,
  "Enter Person Id " = 252237,
  "Enter Procedure Code " = 8014628,
  "Enter Donation Date " = "21-AUG-1997",
  "Enter Encounter Id " = 251292
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 10
 ENDIF
 SET ssn_cd = 0
 SET home_address_cd = 0
 SET home_phone_cd = 0
 SET business_phone_cd = 0
 SET abo_rh = fillstring(10," ")
 SET contact_type_cd = 0
 SET nbryrdon = 0
 SET nbr_all_donations = 0
 SET current_date = cnvtdatetime(curdate,curtime3)
 SET next_donation_dt_tm = cnvtdatetime(curdate,curtime3)
 SET donation_dt_tm = cnvtdatetime( $4)
 SET test_counter = 0
 SELECT INTO "nl:"
  FROM code_value cv6
  WHERE cv6.code_set=4
   AND cv6.cdf_meaning="SSN"
  DETAIL
   ssn_cd = cv6.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv7
  WHERE cv7.code_set=212
   AND cv7.cdf_meaning="HOME"
  DETAIL
   home_address_cd = cv7.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv8
  WHERE cv8.code_set=43
   AND cv8.cdf_meaning="HOME"
  DETAIL
   home_phone_cd = cv8.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv9
  WHERE cv9.code_set=43
   AND cv9.cdf_meaning="BUSINESS"
  DETAIL
   business_phone_cd = cv9.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM procedure_eligibility_r pe
  WHERE (pe.procedure_cd= $3)
   AND (pe.prev_procedure_cd= $3)
   AND pe.active_ind=1
  DETAIL
   next_donation_dt_tm = datetimeadd(cnvtdatetime( $4),pe.days_until_eligible)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv10
  WHERE cv10.code_set=14220
   AND cv10.cdf_meaning="DONATE"
  DETAIL
   contact_type_cd = cv10.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM bbd_donor_contact b,
   bbd_donation_results bd,
   procedure_outcome_r po
  WHERE (b.person_id= $2)
   AND b.active_ind=1
   AND b.contact_type_cd=contact_type_cd
   AND bd.encntr_id=b.encntr_id
   AND bd.active_ind=1
   AND po.outcome_cd=bd.outcome_cd
   AND po.procedure_cd=bd.procedure_cd
   AND po.active_ind=1
   AND po.count_as_donation_ind=1
  DETAIL
   nbr_all_donations = (nbr_all_donations+ 1)
   IF (b.contact_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND b.contact_dt_tm >= cnvtdatetime(datetimeadd(current_date,- (365))))
    nbryrdon = (nbryrdon+ 1)
   ENDIF
  WITH counter
 ;end select
 RECORD testing_list(
   1 qual[*]
     2 special_testing = vc
 )
 SELECT INTO "nl:"
  FROM code_value c,
   person_antigen pa
  WHERE c.code_value=pa.antigen_cd
   AND c.active_ind=1
   AND (pa.person_id= $2)
   AND pa.active_ind=1
  DETAIL
   test_counter = (test_counter+ 1), stat = alterlist(testing_list->qual,test_counter), testing_list
   ->qual[test_counter].special_testing = c.display
  WITH nocounter
 ;end select
 SELECT INTO  $1
  p.birth_dt_tm, sex_disp = uar_get_code_display(p.sex_cd), p.name_full_formatted,
  a.street_addr, a.street_addr2, a.street_addr3,
  a.street_addr4, a.city, a.state,
  a.zipcode, ph.phone_num, ph1.phone_num,
  pd.last_donation_dt_tm, e.reg_dt_tm, pa.alias,
  pd.eligibility_type_cd, eligibility_type_disp = uar_get_code_display(pd.eligibility_type_cd), pab
  .abo_cd,
  abo_disp = uar_get_code_display(pab.abo_cd), pab.rh_cd, rh_disp = uar_get_code_display(pab.rh_cd),
  e.bbd_procedure_cd, bbd_procedure_disp = uar_get_code_display(e.bbd_procedure_cd)
  FROM address a,
   dummyt d6,
   dummyt d1,
   dummyt d2,
   dummyt d3,
   dummyt d4,
   dummyt d7,
   encounter e,
   person p,
   person_aborh pab,
   person_alias pa,
   person_donor pd,
   phone ph,
   phone ph1
  PLAN (p
   WHERE (p.person_id= $2)
    AND p.active_ind=1)
   JOIN (e
   WHERE (e.encntr_id= $5)
    AND e.person_id=p.person_id
    AND e.active_ind=1)
   JOIN (d1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.active_ind=1
    AND pa.person_alias_type_cd=ssn_cd)
   JOIN (d2)
   JOIN (a
   WHERE a.parent_entity_id=p.person_id
    AND a.parent_entity_name="PERSON"
    AND a.address_type_cd=home_address_cd
    AND a.active_ind=1)
   JOIN (d3)
   JOIN (ph
   WHERE ph.parent_entity_id=p.person_id
    AND ph.parent_entity_name="PERSON"
    AND ph.phone_type_cd=home_phone_cd
    AND ph.active_ind=1)
   JOIN (d4)
   JOIN (ph1
   WHERE ph1.parent_entity_id=p.person_id
    AND ph1.parent_entity_name="PERSON"
    AND ph1.phone_type_cd=business_phone_cd
    AND ph1.active_ind=1)
   JOIN (d6)
   JOIN (pab
   WHERE pab.person_id=p.person_id
    AND pab.active_ind=1)
   JOIN (d7)
   JOIN (pd
   WHERE pd.person_id=p.person_id
    AND pd.active_ind=1)
  HEAD REPORT
   row 0, col 4, "Hospital Name",
   row + 1
  HEAD PAGE
   row + 1, col 4, "Hospital Address",
   row + 3
  DETAIL
   IF (((row+ 2) >= maxrow))
    BREAK
   ENDIF
   row + 1, name_full_formatted1 = substring(1,30,p.name_full_formatted), alias1 = substring(1,40,pa
    .alias),
   col 4, "Name:", col 10,
   name_full_formatted1, col 54, "Social Security Number:",
   col + 1, col 79, alias1,
   row + 1, row + 1
   IF (a.street_addr > " ")
    street_addr1 = substring(1,40,a.street_addr), phone_num1 = substring(1,20,ph.phone_num), col 4,
    "Address:", col 13, street_addr1,
    col 54, "Home Phone:", col 66,
    phone_num1, row + 1
   ELSE
    phone_num1 = substring(1,20,ph.phone_num), col 54, "Home Phone:",
    col 66, phone_num1, row + 1
   ENDIF
   row + 1
   IF (a.street_addr2 > " ")
    street_addr21 = substring(1,50,a.street_addr2), phone_num1 = substring(1,20,ph1.phone_num), col 4,
    street_addr21, col 54, "Business Phone:",
    col 69, phone_num1, row + 1
   ENDIF
   IF (a.street_addr3 > " "
    AND a.street_addr2=" ")
    street_addr31 = substring(1,50,a.street_addr3), phone_num1 = substring(1,20,ph1.phone_num), col 4,
    street_addr31, col 54, "Business Phone:",
    col 69, phone_num1, row + 1,
    col 4, "elseif (a.street_addr3 > ", ")",
    row + 1, street_addr31 = substring(1,50,a.street_addr3), col 4,
    street_addr31, row + 1
   ENDIF
   IF (a.street_addr4 > " "
    AND a.street_addr3=" ")
    street_addr41 = substring(1,50,a.street_addr4), phone_num1 = substring(1,20,ph1.phone_num), col 4,
    street_addr41, col 54, "Business Phone:",
    col 69, phone_num1, row + 1
   ELSEIF (a.street_addr4 > " ")
    street_addr41 = substring(1,50,a.street_addr4), col 4, street_addr41,
    row + 1
   ENDIF
   IF (a.street_addr2=" "
    AND a.street_addr3=" "
    AND a.street_addr4=" ")
    city1 = substring(1,20,a.city), state1 = substring(1,15,a.state), zipcode1 = substring(1,15,a
     .zipcode),
    phone_num1 = substring(1,20,ph1.phone_num), col 4, city1,
    col 22, state1, col 39,
    zipcode1, col 54, "Business Phone:",
    col 69, phone_num1, row + 1
   ELSE
    city1 = substring(1,20,a.city), state1 = substring(1,15,a.state), zipcode1 = substring(1,15,a
     .zipcode),
    col 4, city1, col 25,
    state1, col 41, zipcode1,
    row + 1
   ENDIF
   row + 7, abo_rh = concat(trim(abo_disp)," ",trim(rh_disp))
   IF (abo_rh > " ")
    sex_disp1 = substring(1,20,sex_disp), col 4, "Birth Date:",
    col 16, p.birth_dt_tm, col 32,
    "Gender:", col 41, sex_disp1,
    col 63, "ABO/Rh:", col + 1,
    CALL print(abo_rh)
   ELSE
    sex_disp1 = substring(1,10,sex_disp), col 4, "Birth Date:",
    col 16, p.birth_dt_tm, col 32,
    "Gender:", col 41, sex_disp1,
    col 66, "ABO/Rh:", row + 1
   ENDIF
   row + 2, last = trim(format(pd.last_donation_dt_tm,"MM/DD/YY;;D")), col 4,
   "Last Donation:", col + 2,
   CALL print(last),
   col + 30, col 54, "Next Donation:",
   col + 2,
   CALL print(trim(format(next_donation_dt_tm,"MM/DD/YY;;D"))), col + 3,
   row + 2, col 4, "Current Year Donation:",
   col + 3,
   CALL print(nbryrdon), col + 15,
   col 54, "Total Donations:", col + 3,
   CALL print(nbr_all_donations), row + 2, col 4,
   "Group Name:", col 54, "Number:",
   row + 2, bbd_procedure_disp1 = substring(1,30,bbd_procedure_disp), eligibility_type_disp1 =
   substring(1,30,eligibility_type_disp),
   col 4, "Donation Procedure:", col 25,
   bbd_procedure_disp1, col 54, "Eligibility Type:",
   col 72, eligibility_type_disp1, row + 2,
   row + 7, col 4, "Signature:",
   row + 1, row + 2, regdate = trim(format(e.reg_dt_tm,"MM/DD/YY;;D")),
   col 4, "Date:", col + 3,
   CALL print(regdate), col 35, "Time:",
   col + 3,
   CALL print(trim(format(e.reg_dt_tm,"HH:MM;;M"))), row + 2,
   col 4, "Special Testing:", col + 3
   FOR (index = 1 TO test_counter)
     IF (col > 60)
      row + 2
     ENDIF
     CALL print(trim(testing_list->qual[index].special_testing)), col + 2
   ENDFOR
  WITH maxcol = 500, time = value(maxsecs), dontcare = pa,
   dontcare = a, dontcare = pd, dontcare = ph,
   dontcare = ph1, dontcare = pab, outerjoin = d1,
   outerjoin = d2, outerjoin = d3, outerjoin = d4,
   outerjoin = d6, outerjoin = d7, noheading,
   format = variable
 ;end select
END GO
