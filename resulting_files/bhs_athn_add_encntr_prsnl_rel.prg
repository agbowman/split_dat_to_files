CREATE PROGRAM bhs_athn_add_encntr_prsnl_rel
 RECORD orequest(
   1 prsnl_person_id = f8
   1 person_prsnl_reltn_cd = f8
   1 person_id = f8
   1 encntr_prsnl_reltn_cd = f8
   1 encntr_id = f8
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
 )
 DECLARE username = vc
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id= $2)
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
 SET orequest->prsnl_person_id =  $2
 SET orequest->encntr_id =  $3
 SET orequest->encntr_prsnl_reltn_cd =  $4
 SET stat = tdbexecute(600005,600507,600312,"REC",orequest,
  "REC",oreply,4)
 SET _memory_reply_string = cnvtrectojson(oreply)
END GO
