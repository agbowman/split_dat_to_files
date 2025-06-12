CREATE PROGRAM bw_get_customer_q
 PROMPT
  "Output to File/Printer/MINE " = mine
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 60
 ENDIF
 SELECT INTO  $1
  b.billing_addr, b.city, b.company_name,
  b.contact_title, b.country, b.customer_id,
  b.customer_type_cd, b.email_addr, b.extension,
  b.fax_nbr, b.first_name, b.last_name,
  b.notes, b.phone_nbr, b.postal_cd,
  b.state
  FROM bw_customer b
  WITH format, time = value(maxsecs)
 ;end select
END GO
