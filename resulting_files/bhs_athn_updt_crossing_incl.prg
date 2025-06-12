CREATE PROGRAM bhs_athn_updt_crossing_incl
 RECORD orequest(
   1 patient_id = f8
   1 encntr_id = f8
   1 prsnl_id = f8
 )
 DECLARE username = vc
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id= $4)
    AND p.active_ind=1)
  HEAD p.person_id
   username = p.username
  WITH nocounter, time = 30
 ;end select
 SET namelen = (textlen(username)+ 1)
 SET domainnamelen = (textlen(curdomain)+ 2)
 SET statval = memalloc(name,1,build("C",namelen))
 SET statval = memalloc(domainname,1,build("C",domainnamelen))
 SET name = username
 SET domainname = curdomain
 SET setcntxt = uar_secimpersonate(nullterm(username),nullterm(domainname))
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id= $2))
  HEAD REPORT
   orequest->patient_id = e.person_id
  WITH nocounter, time = 30
 ;end select
 SET orequest->encntr_id =  $2
 SET orequest->prsnl_id =  $4
 SET stat = tdbexecute(600005,3202004,969575,"REC",orequest,
  "REC",oreply)
 SET inc_str = concat("INCLUDEINNOTE_",trim(cnvtstring(oreply->workflow_id)))
 EXECUTE uhs_mpg_upd_tag "mine", 0.00,  $3,
 inc_str,  $4
END GO
