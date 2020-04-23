<?xml version="1.0"?>
<queryset>

<fullquery name="Form.pm-0-orig">
      <querytext>
  --   if we have a value  update balance
  -- Form.pm.1690 This is a generic update. We need
  -- to redo this as individual table updates, in biz section.
    # retrieve balance from table
    SELECT $field FROM $table WHERE $where FOR UPDATE
  --  $balance += $value;
    # update balance
    UPDATE $table SET $field = $balance WHERE $where

      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      -- from Form.pm.1696
      SELECT $fld FROM exchangerate
      WHERE curr = :curr
      AND transdate = :transdate
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      -- get_exchangerate Form.pm.1764
         SELECT $fld FROM exchangerate
		   WHERE curr = '$curr'
		   AND transdate = '$transdate'
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
        INSERT INTO exchangerate (curr, buy, sell, transdate)
        VALUES (:curr, :buy, :sell, :transdate)
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
        SELECT buy, sell FROM exchangerate
	    WHERE curr = :curr
	    AND transdate = :transdate
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      SELECT precision FROM curr
      WHERE curr = :currency
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
INSERT INTO shipto (trans_id, shiptoname, shiptoaddress1,
                   shiptoaddress2, shiptocity, shiptostate,
		   shiptozipcode, shiptocountry, shiptocontact,
		   shiptophone, shiptofax, shiptoemail)
           VALUES (trans_id, :shiptoname, :shiptoaddress1,
                   :shiptoaddress2, :shiptocity, :shiptostate,
		   :shiptozipcode, :shiptocountry, :shiptocontact,
		   :shiptophone, :shiptofax, :shiptoemail)
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      SELECT name, id FROM employee 
                 WHERE login = :login
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
        -- part of search get_name Form.pm.1879
         SELECT ct.*,
                 ad.address1, ad.address2, ad.city, ad.state,
		 ad.zipcode, ad.country
         FROM $table ct
		 JOIN address ad ON (ad.trans_id = ct.id)
		 WHERE $where
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
        SELECT curr, precision FROM curr
                 ORDER BY rn
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
        SELECT precision FROM curr
              WHERE curr = :currency
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      -- vc is customer or vendor
      -- $joinarap = "JOIN $arap a ON (a.${vc}_id = vc.id)"
        if ($transdate) {
    $where .= qq| AND (vc.startdate IS NULL OR vc.startdate <= '$transdate')
                  AND (vc.enddate IS NULL OR vc.enddate >= '$transdate')|; }
  if ($openinv) {
    $joinarap = "JOIN $arap a ON (a.${vc}_id = vc.id)";
    $where .= " AND a.amount != a.paid";}

SELECT vc.id, vc.name
		FROM $vc vc
		$joinarap
		WHERE $where
		UNION SELECT vc.id, vc.name
		FROM $vc vc
		WHERE vc.id = ${vc}_id"}
		ORDER BY name
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
        SELECT *
              FROM language
	      ORDER BY 2
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      -- rebuild tax rates
        if ($transdate) {
        $where = qq| AND (t.validto >= '$transdate' OR t.validto IS NULL)|;
        }

        SELECT t.rate, t.taxnumber
                FROM tax t
		JOIN chart c ON (c.id = t.chart_id)
		WHERE c.accno = ?
		$where
		ORDER BY accno, validto
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      -- setup employees/sales contacts
SELECT id, name
 	         FROM employee
		 WHERE 1 = 1|;
		 
  if ($transdate) {
    $query .= qq| AND (startdate IS NULL OR startdate <= '$transdate')
                  AND (enddate IS NULL OR enddate >= '$transdate')|;
  } else {
    $query .= qq| AND enddate IS NULL|;
  }
  if ($sales) {
    $query .= qq| AND sales = '1'|;
  }
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      -- all projects
 $where = qq|id NOT IN (SELECT id
                         FROM parts
			 WHERE project_id > 0)| if ! $job;
			 
  my $query = qq|SELECT *
                 FROM project
		 WHERE $where|;

  if ($form->{language_code}) {
    $query = qq|SELECT pr.*, t.description AS translation
                FROM project pr
		LEFT JOIN translation t ON (t.trans_id = pr.id)
		WHERE t.language_code = '$form->{language_code}'|;
  }

  if ($transdate) {
    $query .= qq| AND (startdate IS NULL OR startdate <= '$transdate')
                  AND (enddate IS NULL OR enddate >= '$transdate')|;
  }

  $query .= qq|
	         ORDER BY projectnumber
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      -- all departments
  if ($vc) {
    if ($vc eq 'customer') {
      $where = " role = 'P'";
    }
  }
  
SELECT id, description
                 FROM department
	         WHERE $where
	         ORDER BY 2

      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      -- all warehouses
SELECT id, description
                 FROM warehouse
	         ORDER BY 2
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
-- create links
SELECT c.accno, c.description, c.link,
              l.description AS translation
              FROM chart c
	      LEFT JOIN translation l ON (l.trans_id = c.id AND l.language_code = '$myconfig->{countrycode}')
	      WHERE c.link LIKE '%$module%'
	      ORDER BY c.accno
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      -- remove locks
SELECT a.invnumber, a.transdate,
                a.${vc}_id, a.datepaid, a.duedate, a.ordnumber,
		a.taxincluded, a.curr AS currency, a.notes, a.intnotes,
		a.terms, a.cashdiscount, a.discountterms,
		c.name AS $vc, c.${vc}number, a.department_id,
		d.description AS department,
		a.amount AS oldinvtotal, a.paid AS oldtotalpaid,
		a.employee_id, e.name AS employee, c.language_code,
		a.ponumber, a.approved,
		br.id AS batchid, br.description AS batchdescription,
		a.description, a.onhold, a.exchangerate, a.dcn,
		ch.accno AS bank_accno, ch.description AS bank_accno_description,
		t.description AS bank_accno_translation,
		pm.description AS paymentmethod, a.paymentmethod_id
		FROM $arap a
		JOIN $vc c ON (a.${vc}_id = c.id)
		LEFT JOIN employee e ON (e.id = a.employee_id)
		LEFT JOIN department d ON (d.id = a.department_id)
		LEFT JOIN vr ON (vr.trans_id = a.id)
		LEFT JOIN br ON (br.id = vr.br_id)
		LEFT JOIN chart ch ON (ch.id = a.bank_id)
		LEFT JOIN translation t ON (t.trans_id = ch.id AND t.language_code = '$myconfig->{countrycode}')
		LEFT JOIN paymentmethod pm ON (pm.id = a.paymentmethod_id)
		WHERE a.id = :id
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
 -- get paymentmethod
  SELECT *
	      FROM paymentmethod
	      ORDER BY rn
 
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      -- remove expired locks
      DELETE FROM semaphore
             WHERE expires < :expires
 
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      SELECT id, login FROM semaphore
		WHERE id = :id
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      -- arap is likely either AR or AP table.
            SELECT id FROM $arap
                 WHERE id IN (SELECT MAX(id) FROM $arap
		              WHERE $where
			      AND ${vc}_id > 0)
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      -- part of lastname_used Form.pm.2608
SELECT ct.name AS $vc, ct.${vc}number, a.curr AS currency,
              a.${vc}_id,
              $duedate AS duedate, a.department_id,
	      d.description AS department, ct.notes AS intnotes,
	      ct.curr AS currency, ct.remittancevoucher
	      FROM $arap a
	      JOIN $vc ct ON (a.${vc}_id = ct.id)
	      LEFT JOIN department d ON (a.department_id = d.id)
	      WHERE a.id = $trans_id
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      -- part of get_partsgroup Form.pm.2784
      SELECT DISTINCT pg.*, t.description AS translation
		FROM partsgroup pg
		JOIN parts p ON (p.partsgroup_id = pg.id)
		LEFT JOIN translation t ON (t.trans_id = pg.id AND t.language_code = '$p->{language_code}
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      -- part of update_status 
DELETE FROM status
 	         WHERE formname = '$self->{formname}'
	         AND trans_id = $self->{id}
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      -- part of update_status 
          INSERT INTO status (trans_id, printed, emailed,
	      spoolfile, formname) VALUES ($self->{id}, '$printed',
	      '$emailed', $spoolfile,
	      '$self->{formname}')|;
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      --part of save status
DELETE FROM status
		 WHERE trans_id = :id
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      --part of save status Form.pm.2865
INSERT INTO status (trans_id, printed, emailed,
		    spoolfile, formname)
		    VALUES ( :id, :printed, :emailed,
		    $queued{$formname}, :formname)
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
INSERT INTO status (trans_id, printed, emailed, formname)
		VALUES (:id, :printed, :emailed, :formname)
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      -- get recurring
SELECT s.*, se.formname || ':' || se.format AS emaila,
              se.message,
	      sp.formname || ':' || sp.format || ':' || sp.printer AS printa
	      FROM recurring s
	      LEFT JOIN recurringemail se ON (s.id = se.id)
	      LEFT JOIN recurringprint sp ON (s.id = sp.id)
	      WHERE s.id = :id
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      -- calculate nextdate
SELECT current_date - date :startdate AS a,
		  date :enddate - current_date AS b
		  FROM defaults
		  WHERE fldname = 'version'
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
INSERT INTO recurring (id, reference, description,
                startdate, enddate, nextdate,
		repeat, unit, howmany, payment)
                VALUES (:id, :reference, :description,
                :startdate, :enddate, :nextdate,
                :repeat, :unit, :howmany, :payment)
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      -- save intnotes internal notes
      -- vc is?? vendor, customer, transaction?
UPDATE $vc SET
                 intnotes = :intnotes
                 WHERE id = :id
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      -- from audittrail Form.pm.3544
INSERT INTO audittrail (trans_id, tablename, reference,
		    formname, action, employee_id, transdate)
	            VALUES (:id, :tablename,:reference,:formname,
                :action, :employee_id, :transdate)
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      -- load_report  Form.pm.3597
      select reportvariable, reportvalue from reportvars where reportid = :id
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      -- save report, uid = localtime Form.pm.3615
      INSERT INTO report (reportcode) values ( :uid) 
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
SELECT reportid FROM report WHERE reportcode = :uid
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
UPDATE report SET 
		reportcode = :reportcode,
		reportdescription = :reportdescription
		WHERE reportid = :id
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
INSERT INTO reportvars (reportid, reportvariable, reportvalue) 
VALUES (:reportid, :reportvariable, :reportvalue)
      </querytext>
</fullquery>

<fullquery name="Form.pm-0-orig">
      <querytext>
      -- all reports
SELECT reportid, reportdescription FROM report WHERE reportcode = '$self->{reportcode}' ORDER BY 2 
      </querytext>
</fullquery>

</queryset>