<?xml version="1.0"?>
<queryset>

<fullquery name="CT.pm-0-orig">
      <querytext>
-- ct is either vendor, customer or contact,.. here, ct= contact.
SELECT ct.*,
                ad.id AS addressid, ad.address1, ad.address2, ad.city,
		ad.state, ad.zipcode, ad.country,
		b.description || '--' || b.id AS business, s.*,
                e.name || '--' || e.id AS employee,
		g.pricegroup || '--' || g.id AS pricegroup,
		m.description || '--' || m.id AS paymentmethod,
		d.description || '--' || d.id AS department,
		bk.name AS bankname,
		ad1.address1 AS bankaddress1,
		ad1.address2 AS bankaddress2,
		ad1.city AS bankcity,
		ad1.state AS bankstate,
		ad1.zipcode AS bankzipcode,
		ad1.country AS bankcountry,
		ct.curr
                FROM ct
		LEFT JOIN address ad ON (ct.id = ad.trans_id)
		LEFT JOIN business b ON (ct.business_id = b.id)
		LEFT JOIN shipto s ON (ct.id = s.trans_id)
		LEFT JOIN employee e ON (ct.employee_id = e.id)
		LEFT JOIN pricegroup g ON (g.id = ct.pricegroup_id)
		LEFT JOIN paymentmethod m ON (m.id = ct.paymentmethod_id)
		LEFT JOIN bank bk ON (bk.id = ct.id)
		LEFT JOIN address ad1 ON (bk.address_id = ad1.id)
		LEFT JOIN department d ON (ct.department_id = d.id)
                WHERE ct.id = :id    
      </querytext>
</fullquery>


<fullquery name="CT.pm-1-orig">
      <querytext>
        SELECT * FROM contact
        WHERE trans_id =:id
		ORDER BY id
      </querytext>
</fullquery>

<fullquery name="CT.pm-2-orig">
      <querytext>
        -- Check if *it* is orphaned CT.pm.75
        SELECT a.id
              FROM $arap a
	      JOIN $form->{db} ct ON (a.$form->{db}_id = ct.id)
	      WHERE ct.id = $form->{id}
	    UNION
	      SELECT a.id
	      FROM oe a
	      JOIN $form->{db} ct ON (a.$form->{db}_id = ct.id)
	      WHERE ct.id = $form->{id}
      </querytext>
</fullquery>

<fullquery name="CT.pm-3-orig">
      <querytext>
        -- get taxes for customer/vendor
        SELECT c.accno
		FROM chart c
		JOIN $form->{db}tax t ON (t.chart_id = c.id)
		WHERE t.$form->{db}_id = $form->{id}|;
      </querytext>
</fullquery>

<fullquery name="CT.pm-4-orig">
      <querytext>
        --for (qw(arap payment discount)) {
        --{"${_}_accno_id"} *= 1;
        SELECT c.accno, c.description,
        l.description AS translation
		FROM chart c
		LEFT JOIN translation l ON (l.trans_id = c.id AND l.language_code = '$myconfig->{countrycode}')
		  WHERE id = $form->{"${_}_accno_id"}|;
          ($accno, $description, $translation) = $dbh->selectrow_array($query);

          --$description = $translation if $translation;
          --$form->{"${_}_accno"} = "${accno}--$description";
    }
      </querytext>
</fullquery>

<fullquery name="CT.pm-5-orig">
      <querytext>
        --($form->{employee}, $form->{employee_id}) = $form->get_employee($dbh);
    $form->{employee} = "$form->{employee}--$form->{employee_id}";


      </querytext>
</fullquery>


<fullquery name="CT.pm-5-orig">
      <querytext>
        -- ARAP, payment and discount account
        SELECT c.accno, c.description, c.link,
        l.description AS translation
        FROM chart c
	    LEFT JOIN translation l ON (l.trans_id = c.id AND l.language_code = '$myconfig->{countrycode}')
	    WHERE c.link LIKE '%$form->{ARAP}%'
	    ORDER BY c.accno
      </querytext>
</fullquery>


<fullquery name="CT.pm-6-orig">
      <querytext>
  
        -- get tax labels
        SELECT DISTINCT c.accno, c.description,
        l.description AS translation
        FROM chart c
	    JOIN tax t ON (t.chart_id = c.id)
	    LEFT JOIN translation l ON (l.trans_id = c.id AND l.language_code = '$myconfig->{countrycode}')
	    WHERE c.link LIKE '%$form->{ARAP}_tax%'
	    ORDER BY c.accno|;

      </querytext>
</fullquery>

<fullquery name="CT.pm-7-orig">
      <querytext>
        -- get business types
        SELECT *
        FROM business
	    ORDER BY 2

      </querytext>
</fullquery>
<fullquery name="CT.pm-8-orig">
      <querytext>
        -- get paymentmethod
        SELECT *
        FROM paymentmethod
	    ORDER BY rn
      </querytext>
</fullquery>
<fullquery name="CT.pm-9-orig">
      <querytext>
        -- get departments
        SELECT id, description FROM department ORDER BY description
      </querytext>
</fullquery>
<fullquery name="CT.pm-10-orig">
      <querytext>
        DELETE FROM $form->{db}tax
                WHERE $form->{db}_id =:id 
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        DELETE FROM shipto
        WHERE trans_id = :id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        DELETE FROM contact
        WHERE id = :contactid
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        SELECT address_id
        FROM bank
        WHERE id =:id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        DELETE FROM bank
        WHERE id =:id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        DELETE FROM address
        WHERE id = :addressid
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        DELETE FROM address
        WHERE trans_id = :bank_address_id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
  <querytext>
    --- this is just too generic!
        SELECT id FROM $form->{db}
                WHERE id = :id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        -- too generic!
        INSERT INTO $form->{db} (id)
        VALUES ($form->{id})
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        -- retrieve enddate
        SELECT enddate, current_date AS now FROM $form->{db}
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        INSERT INTO bank (id, name, iban, bic, address_id)
		VALUES (:id,:name,:iban,:bic,:address_id)
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
  <querytext>
    --no bank address_id
    INSERT INTO bank (id, name, iban, bic)
	VALUES (:id,:name,:iban,:bic)
  </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        SELECT address_id
        FROM bank
        WHERE id =:id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        INSERT INTO address (id, trans_id, address1, address2,
		city, state, zipcode, country) VALUES (
        :id, :trans_id, :address1, :address2,
		    :city, :state, :zipcode, :country)
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        UPDATE vendor SET
        vendornumber = :vendornumber,
	    name =:name,
	    contact = :contact,
	    phone = :phone,
	    fax = :fax,
	    email = :email,
	    cc = :cc,
	    bcc = :bcc,
	    notes = :notes,
	    terms = :terms,
	    discount = :discount,
	    creditlimit = :creditlimit,
        iban = :iban,
        bic = :bic,
	    taxincluded = :taxincluded,
	    $gifi
	    business_id = $rec{business_id,
	    taxnumber = :taxnumber,
	      sic_code = :sic_code,
	      employee_id = $rec{employee_id,
	      language_code = :language_code,
	      pricegroup_id = $rec{pricegroup_id,
	      curr = :curr,
	      startdate = :startdate,
	      enddate = :enddate,
	      arap_accno_id = (SELECT id FROM chart WHERE accno = :arap_accno,
	      payment_accno_id = (SELECT id FROM chart WHERE accno = :payment_accno,
	      discount_accno_id = (SELECT id FROM chart WHERE accno = :discount_accno,
	      cashdiscount = :cashdiscount,
	      threshold = :threshold,
	      discountterms = :discountterms,
	      paymentmethod_id = :paymentmethod_id,
	      department_id = :department_id,
	      remittancevoucher = :remittancevoucher
	      WHERE id = :id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        -- save vendor taxes
        INSERT INTO vendortax (vendor_id, chart_id)
		  VALUES (:id, (SELECT id
				        FROM chart
				        WHERE accno = :item))
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        -- save customer taxes
        INSERT INTO customertax (customer_id, chart_id)
		  VALUES (:id, (SELECT id
				        FROM chart
				        WHERE accno = :item))

      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        -- save taxes
        -- From CT.pm.455 This may not be a permutation.
        INSERT INTO tax (tax_id, chart_id)
		  VALUES (:id, (SELECT id
				        FROM chart
				        WHERE accno = :item))

      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        -- add address
        INSERT INTO address (id trans_id, address1, address2,
        city, state, zipcode, country)
        VALUES (:id, :trans_id, :address1, :address2,
        :city, :state, :zipcode, :country)
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        INSERT INTO contact (id,trans_id, firstname, lastname,
        salutation, contacttitle, occupation, phone, fax, mobile,
	    typeofcontact, email, gender)
        VALUES (:id, :trans_id, :firstname, :lastname,
        :salutation, :contacttitle, :occupation, :phone, :fax, :mobile,
	    :typeofcontact, :email, :gender)
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        DELETE FROM customer where id = :id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        DELETE FROM vendor where id = :id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        SELECT address_id FROM bank
        WHERE id = :id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        DELETE FROM address WHERE id = :address_id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        DELETE FROM shipto where trans_id = :id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        DELETE FROM address where trans_id = :id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        DELETE from bank where id=:id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        DELETE from vendortax where vendor_id =:id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        DELETE from customertax where customer_id =:id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
  <querytext>
    --this may be redundant.. see CT.pm.546
    DELETE from tax where tax_id=:id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        DELETE from parts where parts_id = :id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        DELETE from partscustomer where customer_id = :id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        DELETE from partsvendor where vendor_id = :id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        DELETE from partsattr where attr_id = :id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        DELETE from partstax where tax_id = :id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        DELETE from partsgroup where group_id = :id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        SELECT c.*, b.description AS business,
                 e.name AS employee, g.pricegroup, l.description AS language,
		         m.name AS manager,
		         ad.address1, ad.address2, ad.city, ad.state, ad.zipcode,
		         ad.country,
		         pm.description AS paymentmethod,
		         ct.salutation, ct.firstname, ct.lastname, ct.contacttitle,
		         ct.occupation, ct.mobile, ct.gender, ct.typeofcontact
                 FROM $form->{db} c
	             JOIN contact ct ON (ct.trans_id = c.id)
	             LEFT JOIN address ad ON (ad.trans_id = c.id)
	             LEFT JOIN business b ON (c.business_id = b.id)
	             LEFT JOIN employee e ON (c.employee_id = e.id)
	             LEFT JOIN employee m ON (m.id = e.managerid)
	             LEFT JOIN pricegroup g ON (c.pricegroup_id = g.id)
	             LEFT JOIN language l ON (l.code = c.language_code)
	             LEFT JOIN paymentmethod pm ON (pm.id = c.paymentmethod_id)
                 WHERE $query_constraints
                 --- Varies See CT.pm.592 to 665, put in proc
                 ORDER BY $sortorder
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        -- redo for search if including invoices, orders and quotations
        -- see CT.pm.666 to 720  define tablename.. and constraints.
        -- this is for l_transnumber (last transaction number??)
        -- other cases are l_ordnumber, l_quonumber, l_invnumber
        -- table names cannot be quoted in openacs like :tablename.
        SELECT c.*, b.description AS business,
        a.invnumber, a.ordnumber, a.quonumber, a.id AS invid,
		'$ar' AS module, 'invoice' AS formtype,
		(a.amount = a.paid) AS closed, a.amount, a.netamount,
		e.name AS employee, m.name AS manager,
		ad.address1, ad.address2, ad.city, ad.state, ad.zipcode,
		ad.country,
		pm.description AS paymentmethod,
		ct.salutation, ct.firstname, ct.lastname, ct.contacttitle,
		ct.occupation, ct.mobile, ct.gender, ct.typeofcontact
		FROM :tablename c
	    JOIN contact ct ON (ct.trans_id = c.id)
		JOIN address ad ON (ad.trans_id = c.id)
		JOIN $ar a ON (a.$form->{db}_id = c.id)
	    LEFT JOIN business b ON (c.business_id = b.id)
		LEFT JOIN employee e ON (a.employee_id = e.id)
		LEFT JOIN employee m ON (m.id = e.managerid)
		LEFT JOIN paymentmethod pm ON (pm.id = c.paymentmethod_id)
		WHERE $where
		AND a.invoice = '0'
		$transwhere
		$openarap
        ORDER BY $sortorder
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
  <querytext>
    -- search with l_invnumber ie search by invoicenumbers
        SELECT c.*, b.description AS business,
		   a.invnumber, a.ordnumber, a.quonumber, a.id AS invid,
		   '$module' AS module, 'invoice' AS formtype,
		   (a.amount = a.paid) AS closed, a.amount, a.netamount,
		   e.name AS employee, m.name AS manager,
		   ad.address1, ad.address2, ad.city, ad.state, ad.zipcode,
		   ad.country,
		   pm.description AS paymentmethod,
		   ct.salutation, ct.firstname, ct.lastname, ct.contacttitle,
		   ct.occupation, ct.mobile, ct.gender, ct.typeofcontact
		   FROM :tablename c
	        JOIN contact ct ON (ct.trans_id = c.id)
		JOIN address ad ON (ad.trans_id = c.id)
		JOIN $ar a ON (a.$form->{db}_id = c.id)
	        LEFT JOIN business b ON (c.business_id = b.id)
		LEFT JOIN employee e ON (a.employee_id = e.id)
		LEFT JOIN employee m ON (m.id = e.managerid)
		LEFT JOIN paymentmethod pm ON (pm.id = c.paymentmethod_id)
		  WHERE $where
		  AND a.invoice = '1'
		  $transwhere
		  $openarap
		  ORDER BY $sortorder
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
  <querytext>
    ---- search by l_ordnumber ie search order numbers
    -- tablename is constrained to vendor, customer or payment
 SELECT c.*, b.description AS business,
		   ' ' AS invnumber, o.ordnumber, o.quonumber, o.id AS invid,
		   'oe' AS module, 'order' AS formtype,
		   o.closed, o.amount, o.netamount,
		   e.name AS employee, m.name AS manager,
		   ad.address1, ad.address2, ad.city, ad.state, ad.zipcode,
		   ad.country,
		   pm.description AS paymentmethod,
		   ct.salutation, ct.firstname, ct.lastname, ct.contacttitle,
		   ct.occupation, ct.mobile, ct.gender, ct.typeofcontact
		  FROM :tablename c
	        JOIN contact ct ON (ct.trans_id = c.id)
		JOIN address ad ON (ad.trans_id = c.id)
		JOIN oe o ON (o.$form->{db}_id = c.id)
	        LEFT JOIN business b ON (c.business_id = b.id)
		LEFT JOIN employee e ON (o.employee_id = e.id)
		LEFT JOIN employee m ON (m.id = e.managerid)
		LEFT JOIN paymentmethod pm ON (pm.id = c.paymentmethod_id)
		  WHERE $where
		  AND o.quotation = '0'
          $transwhere
		  $openoe
          ORDER BY $sortorder
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        -- search by l_quonumber ie quotation reference number
        SELECT c.*, b.description AS business,
		   ' ' AS invnumber, o.ordnumber, o.quonumber, o.id AS invid,
		   'oe' AS module, 'quotation' AS formtype,
		   o.closed, o.amount, o.netamount,
		   e.name AS employee, m.name AS manager,
		   ad.address1, ad.address2, ad.city, ad.state, ad.zipcode,
		   ad.country,
		   pm.description AS paymentmethod,
		   ct.salutation, ct.firstname, ct.lastname, ct.contacttitle,
		   ct.occupation, ct.mobile, ct.gender, ct.typeofcontact
		  FROM $form->{db} c
	        JOIN contact ct ON (ct.trans_id = c.id)
		JOIN address ad ON (ad.trans_id = c.id)
		JOIN oe o ON (o.$form->{db}_id = c.id)
	        LEFT JOIN business b ON (c.business_id = b.id)
		LEFT JOIN employee e ON (o.employee_id = e.id)
		LEFT JOIN employee m ON (m.id = e.managerid)
		LEFT JOIN paymentmethod pm ON (pm.id = c.paymentmethod_id)
		  WHERE $where
		  AND o.quotation = '1'
		  $transwhere
		  $openoe
		 ORDER BY $sortorder
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        --- param value begins and ends in %
        SELECT id, accno from chart
        where link LIKE :param
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        SELECT c.accno
        FROM chart c
	    JOIN customertax t ON (t.chart_id = c.id)
	    WHERE t.customer_id = :id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        SELECT c.accno
        FROM chart c
	    JOIN vendortax t ON (t.chart_id = c.id)
	    WHERE t.vendor_id = :id

      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        SELECT c.accno
        FROM chart c
	    JOIN partstax t ON (t.chart_id = c.id)
	    WHERE t.parts_id = :id

      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        SELECT c.accno
        FROM chart c
	    JOIN invoicetax t ON (t.chart_id = c.id)
	    WHERE t.invoice_id = :id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        SELECT b.*, a.*
        FROM bank b
	    LEFT JOIN address a ON (a.trans_id = b.address_id)
	    WHERE b.id = :id
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        -- see sub get_history CT.pm 891 to 1058
        -- table undefined here again as $table..
        SELECT ct.id AS ctid, ct.name, ad.address1,
	      ad.address2, ad.city, ad.state,
	      p.id AS pid, p.partnumber, a.id AS invid,
	      a.$invnumber, a.curr, i.description,
	      i.qty, i.$sellprice AS sellprice, i.discount,
	      i.$deldate, i.serialnumber, pr.projectnumber,
	      e.name AS employee, ad.zipcode, ad.country, i.unit,
              (SELECT $buysell FROM exchangerate ex
		    WHERE a.curr = ex.curr
		    AND a.transdate = ex.transdate) AS exchangerate
	      FROM $form->{db} ct
	      JOIN address ad ON (ad.trans_id = ct.id)
	      JOIN $table a ON (a.$form->{db}_id = ct.id)
	      $invjoin
	      JOIN parts p ON (p.id = i.parts_id)
	      LEFT JOIN project pr ON (pr.id = i.project_id)
	      LEFT JOIN employee e ON (e.id = a.employee_id)
	      WHERE $where
	      ORDER BY $sortorder
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
  <querytext>
    -- for customers
    SELECT DISTINCT pg.id, pg.partsgroup
	FROM parts p
	JOIN partsgroup pg ON (pg.id = p.partsgroup_id)
	WHERE p.partsgroup_id > 0
	ORDER BY pg.partsgroup
  </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
      <querytext>
        SELECT p.id, p.partnumber, p.description,
        p.sellprice, pg.partsgroup, p.partsgroup_id,
        m.pricebreak, m.sellprice,
		m.validfrom, m.validto, m.curr
        FROM partscustomer m
		JOIN parts p ON (p.id = m.parts_id)
		LEFT JOIN partsgroup pg ON (pg.id = p.partsgroup_id)
		WHERE m.customer_id = :id
		ORDER BY partnumber
      </querytext>
</fullquery>
<fullquery name="CT.pm-all_partsgroup-orig">
  <querytext>
    -- for vendors  all_partsgroup
    SELECT DISTINCT pg.id, pg.partsgroup
	FROM parts p
	JOIN partsgroup pg ON (pg.id = p.partsgroup_id)
	WHERE p.partsgroup_id > 0
	AND p.assembly = '0'
	ORDER BY pg.partsgroup
      </querytext>
</fullquery>
<fullquery name="CT.pm-allpartspricelist">
  <querytext>
    -- allpartspricelist
    SELECT p.id, p.partnumber AS sku, p.description,
                pg.partsgroup, p.partsgroup_id,
		m.partnumber, m.leadtime, m.lastcost, m.curr
		FROM partsvendor m
		JOIN parts p ON (p.id = m.parts_id)
		LEFT JOIN partsgroup pg ON (pg.id = p.partsgroup_id)
		WHERE m.vendor_id = $form->{id}
		ORDER BY p.partnumber
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
  <querytext>
    
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
  <querytext>
    -- save pricelist for pricebreak, sellprice
    INSERT INTO partscustomer (parts_id, customer_id,
	pricebreak, sellprice, validfrom, validto, curr)
	VALUES (:parts_id, :customer_id,
	:pricebreak, :sellprice, :validfrom, :validto, :curr)
    
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
  <querytext>
    INSERT INTO parts (parts_id, vendor_id,
	partnumber, lastcost, leadtime, curr)
	VALUES (:parts_id, :vendor_id,
	:partnumber, :lastcost, :leadtime, :curr)
    
      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
  <querytext>
        INSERT INTO partsvendor (parts_id, vendor_id,
	partnumber, lastcost, leadtime, curr)
	VALUES (:parts_id, :vendor_id,
	:partnumber, :lastcost, :leadtime, :curr)

      </querytext>
</fullquery>
<fullquery name="CT.pm-x-orig">
  <querytext>
    -- tablename is supposed to be customer, ar or ap,
    -- but the query at a.$form->{db}_id suggests nothing fits schema.
    SELECT
    s.shiptoname, s.shiptoaddress1, s.shiptoaddress2,
    s.shiptocity, s.shiptostate, s.shiptozipcode,
	s.shiptocountry, s.shiptocontact, s.shiptophone,
	s.shiptofax, s.shiptoemail
	FROM shipto s
	JOIN oe o ON (o.id = s.trans_id)
	WHERE o.$form->{db}_id =:id
	UNION
	SELECT
    s.shiptoname, s.shiptoaddress1, s.shiptoaddress2,
    s.shiptocity, s.shiptostate, s.shiptozipcode,
	s.shiptocountry, s.shiptocontact, s.shiptophone,
	s.shiptofax, s.shiptoemail
	FROM shipto s
	JOIN $table a ON (a.id = s.trans_id)
	WHERE a.$form->{db}_id = :id
	EXCEPT
	SELECT
	s.shiptoname, s.shiptoaddress1, s.shiptoaddress2,
    s.shiptocity, s.shiptostate, s.shiptozipcode,
	s.shiptocountry, s.shiptocontact, s.shiptophone,
	s.shiptofax, s.shiptoemail
	FROM shipto s
	WHERE s.trans_id = :id
      </querytext>
</fullquery>
