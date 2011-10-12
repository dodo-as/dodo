/**
   Separate journals namespace for journals specific scripting
 */
var journals = {

    /**
       Validate text entries. If something looks bad, disable submit button.
     */
    validate: function ()
    {
	if(DODO.readonly)
	{
	    return;
	}
	
	var sum1 = $('#dynfield_1_sum')[0].innerHTML;
	var sum2 = $('#dynfield_2_sum')[0].innerHTML;
	
	$('#dynfield_diff')[0].innerHTML = toMoney(parseFloatNazi(sum1)-parseFloatNazi(sum2));
	
	var ok = (parseFloatNazi(sum1)-parseFloatNazi(sum2))==0.0;
	if (ok) {
	    $('#journal_submit')[0].className = 'submit_ok';
	    $('#journal_submit')[0].disabled = false;
	} else {
	    $('#journal_submit')[0].className = 'submit_error';
	    $('#journal_submit')[0].disabled = true;
	}
	return sum1==sum2;
    },
    
    /**
       Return the account with the specified id
     */
    getAccount: function (id) {
	//	console.log("Looking for account " + id);
	for( var i =0; i<DODO.accountList.length; i++) {
	    if (DODO.accountList[i].value == id) {
		//	console.log("Found it:");
		//console.log(DODO.accountList[i]);
		return DODO.accountList[i];
	    }
	}
	console.log("Failed");
	return null;
    },
    
    /**
       Update the sum cell at the bottom of the specified column. The
       column value must be either 1 or 2, for debit or credit column.
     */
    sumColumn: function (column)
    {
	var sum = 0.0;
	for (var i=0; i < DODO.journalLines; i++) {
	    sum += parseFloatNazi($('#dynfield_' + column + '_' + i)[0].value);
	}
	
	$('#dynfield_' + column + '_sum')[0].innerHTML = toMoney(sum);
	
    },
    
    getVat: function(line)
    {
	return $('#dynfield_4_'+line)[0];
    },
    
    getDebet: function(line)
    {
	return $('#dynfield_1_'+line)[0];
    },

    getCredit: function(line)
    {
	return $('#dynfield_2_'+line)[0];
    },

    getAmount: function(line)
    {
	return $('#dynfield_3_'+line)[0];
    },

    getInput: function(line)
    {
	return {
	    vat: journals.getVat(line),
	    debet: journals.getDebet(line),
	    credit: journals.getCredit(line),
	    amount: journals.getAmount(line)
	};
    },

    updateVat: function (reset_all) {
        for (var i=0; i < DODO.journalLines; i++)
            if (reset_all || journals.getVat(i).value == "-1")
                journals.setDefaultVat(i);
    },

    /**
       Update all automatic fields, such as the vat. This also calls the validate function.
     */
    update: function ()
    {
        journals.updateVat(false);
	journals.sumColumn(1);
	journals.sumColumn(2);
	for (var i=0; i < DODO.journalLines; i++) {
	    var account = journals.getAccount($('#account_'+i)[0].value);
	    var vat_account;
            var vat_account_id;
            if (account.vat_account != undefined) {
                vat_account_id = account.vat_account.id;
                vat_account = account.vat_account.target_account;
            } else {
                vat_account_id = '';
                vat_account = {'name': '&lt;No VAT account&gt;', 'overridable': 0, 'id': ''};  
             }

	    $('#vat1_account_'+i)[0].innerHTML = journals.getAccount($('#account_'+i)[0].value).name;
	    $('#vat2_account_'+i)[0].innerHTML = vat_account.name;
	    
	    var inputs = journals.getInput(i);
	    var debet = parseFloatNazi(inputs.debet.value);
	    var credit = parseFloatNazi(inputs.credit.value);

	    var debet1 = $('#vat1_debet_'+i)[0];
	    var debet2 = $('#vat2_debet_'+i)[0];
	    var credit1 = $('#vat1_credit_'+i)[0];
	    var credit2 = $('#vat2_credit_'+i)[0];
	    credit1.innerHTML =debet1.innerHTML =credit2.innerHTML =debet2.innerHTML ='';
	    
	    var overridable = vat_account.overridable || account.vat_overridable;
	    
	    inputs.vat.readOnly=!overridable;
	    
	    var vatFactor = 1.0 - 1.0/(1.0+0.01*parseFloatNazi(inputs.vat.value));
	    var baseAmount = (credit > 0.0)?credit:debet;
	    var vatAmount = toMoney(vatFactor * baseAmount);

	    var vatAccountInput = $('#vat_account_'+i)[0];
	    vatAccountInput.value = vat_account_id;
	    
	    if (debet > 0) {
		debet1.innerHTML = vatAmount;
		credit2.innerHTML = vatAmount;
	    } else {
		credit1.innerHTML = vatAmount;
		debet2.innerHTML = vatAmount;
	    }
	}
	
	journals.validate();
	journals.toggleVisibility();
    },

    /**
       Return a DOM select node, populated with a list of all accounts that can be used for a transaction
     */
    makeAccountSelect: function () {
	var id = "account_"+ DODO.journalLines;

	var sel = $("<select>")[0];
	if(DODO.readonly)
	{
	    sel.readOnly=true;
	}
	sel.name = "tralala[" +  DODO.journalLines + "]";
	sel.id = id;
	
	var a_id = $("<input type='hidden' />")[0];
	a_id.name = "journal_operations[" + DODO.journalLines+"][account_id]"; 
	
	var l_id = $("<input type='hidden' />")[0];
	l_id.name = "journal_operations[" + DODO.journalLines+"][ledger_id]"; 
	l_id.value=null;
	
	for (var i=0; i<DODO.accountList.length; i++) {
	    sel.add(new Option(DODO.accountList[i].name,			       
			       DODO.accountList[i].value), null);
	}
	var line = DODO.journalLines;
	
	var uf = function(){
		vals = sel.value.split(".");
		if(vals.length > 1){
		    a_id.value = vals[0];
		    l_id.value = vals[1];
		}
		else{
		    a_id.value = vals[0];
		    l_id.value = "";
		}

	}
	uf();

	$(sel).change(
	    function(){
		uf();
		journals.setDefaultVat(line);
		journals.update();
	    }
	    );
	
	var res = $("<span>");
	res.append(sel).append(a_id).append(l_id);
	return res[0];
    },

    /**
       Return a DOM select node, populated with a list of all cars that can be used for a transaction
     */
    makeCarSelect: function () {
	var sel = document.createElement("select");
	if(DODO.readonly)
	{
	    sel.readOnly=true;
	}
	sel.name = "journal_operations[" + DODO.journalLines+"][car_id]";
	sel.id = "car_"+ DODO.journalLines;
	
	for (var i=0; i<DODO.carList.length; i++) {
	    sel.add(new Option(DODO.carList[i].car.name,
			       DODO.carList[i].car.id), null);
	}
	return sel;
    },

    /**
       Return a DOM select node, populated with a list of all projects that can be used for a transaction
     */
    makeProjectSelect: function () {
	var sel = document.createElement("select");
	if(DODO.readonly)
	{
	    sel.readOnly=true;
	}
	sel.name = "journal_operations[" + DODO.journalLines+"][project_id]";
	sel.id = "project_"+ DODO.journalLines;
	
	for (var i=0; i<DODO.projectList.length; i++) {
	    sel.add(new Option(DODO.projectList[i].project.name,
			       DODO.projectList[i].project.id), null);
	}
	return sel;
    },

    /**
       Updates the vat amount to the default for the selected account
     */
    setDefaultVat: function (line) 
    {
        var current_date = $('#journal_journal_date')[0].value;

	console.log("Get account for line " + line);
	console.log("Select box:");
	console.log($('#account_'+line));

	var account = journals.getAccount($('#account_'+line)[0].value);
	console.log(account);

        var percentage = 0;
	
        if (current_date != '')
            current_date = Date.fromString(current_date);
	
        if (account.vat_account != undefined) {
            var current_vat_account_period;
            var current_vat_account_period_valid_from;
            $.each(account.vat_account.vat_account_periods,
               	function (i, vat_account_period) {
                    var vat_account_period_valid_from = Date.fromString(vat_account_period.valid_from)

                    if (   vat_account_period_valid_from < current_date
                        && (   current_vat_account_period_valid_from === undefined
                            || current_vat_account_period_valid_from < vat_account_period_valid_from)) {
			current_vat_account_period = vat_account_period;
			current_vat_account_period_valid_from = vat_account_period_valid_from;
                    }
                });
            console.log("SET",line, current_vat_account_period);
            if (current_vat_account_period !== undefined)
                percentage = current_vat_account_period.percentage;
        }

	$('#dynfield_4_'+line)[0].value = percentage;

    },

    /**
       Check if either debet or credit column should be disabled to
       make it impossible to enter both a credit and debet amount on
       the same line.
     */
    doDisable: function (row_number)
    {
	if(DODO.readonly)
	{
	    return;
	}

	var debet = $('#dynfield_1_' + row_number)[0];
	var credit = $('#dynfield_2_' + row_number)[0];
	
	credit.readOnly=false;
	debet.readOnly=false;
	
	if (parseFloatNazi(debet.value) > 0.0) {
	    credit.readOnly=true;
	}
	else if (parseFloatNazi(credit.value) > 0.0) {
	    debet.readOnly=true;
	}
	
    },

    /**
       Returns a DOM node suitable for using as a debet input box.
     */
    makeDebet: function () {
	var res = document.createElement("input");
	if(DODO.readonly)
	{
	    res.readOnly=true;
	}
	res.type="text";
	res.name = "journal_operations[" + DODO.journalLines+"][debet]";
	res.id='dynfield_1_' + DODO.journalLines;
	res.setAttribute("autocomplete","off");
	
	var currentLines = DODO.journalLines;
	
	$(res).keypress(journals.handleArrowKeys);
	$(res).keyup(function (event) {journals.doDisable( currentLines );journals.update();});
	
	return res;
    },
    
    /**
       Returns a DOM node suitable for using as a credit input box.
     */
    makeCredit: function () {
	var res = document.createElement("input");
	if(DODO.readonly)
	{
	    res.readOnly=true;
	}
	res.type="text";
	res.name = "journal_operations[" + DODO.journalLines+"][credit]";
	res.id='dynfield_2_' + DODO.journalLines;
	res.setAttribute("autocomplete","off");
	
	var currentLines = DODO.journalLines;
	$(res).keypress(journals.handleArrowKeys);
	$(res).keyup(function (event) {journals.doDisable( currentLines );journals.update();});
	
	return res;
    },
    
    /**
       Returns a DOM node suitable for using as a vat input box.
     */
    makeVat: function (val) {
	var res = document.createElement("input");
	if(DODO.readonly)
	{
	    res.readOnly=true;
	}
	res.type="text";
	res.name = "journal_operations[" + DODO.journalLines+"][vat]";
	res.id='dynfield_4_' + DODO.journalLines;
	res.value = val;

	$(res).keypress(journals.handleArrowKeys);
	$(res).keyup(journals.update);
	
	return res;
    },
    
    /**
       Returns a DOM node suitable for using as a amount input box.
     */
    makeAmount: function (val) {
	var res = document.createElement("input");
	if(DODO.readonly)
	{
	    res.readOnly=true;
	}
	res.type="text";
	res.name = "journal_operations[" + DODO.journalLines+"][amount_other]";
	res.id='dynfield_3_' + DODO.journalLines;
	res.value = val;

	$(res).keypress(journals.handleArrowKeys);
	$(res).keyup(journals.update);
	
	return res;
    },
    
    /**
       Returns a DOM node suitable for using as a text status field.
     */
    makeText: function(id, content) {
	var res = document.createElement("span");
	if(id)
	    res.id=id + "_" + DODO.journalLines;
	if (content) {
	    res.innerHTML = content;
	}
	return res;
    },
    
    makeDetails: function(line, type) {
	var lineId = '?';
	if (line && line.id) {
	    lineId = line.id;
	}

	return 'Postering:&nbsp;' + lineId+"-" + type + "<br/>Kilde:&nbsp;" + (type==0?'Manuell':'Automatisk opprettet MVA poste');
    },

    /**
       Add a new line to the journal_operation list. 
     */
    addAccountLine: function(line)
    { 
	if(!DODO.journalLines) {
	    DODO.journalLines = 0;
	}
	
	var opTable = $('#operations')[0];
	
	var row = opTable.insertRow(opTable.rows.length);

	var ac = function (content, className) {
	    var c = this.insertCell(this.cells.length);
	    if (className) {
		c.className = className;
		c.otherClassName = className;
	    }
	    c.appendChild(content);
	};

	row.addCell = ac;


	var row2 = opTable.insertRow(opTable.rows.length);
	row2.addCell = ac;
	
	var row3 = opTable.insertRow(opTable.rows.length);
	row3.addCell = ac;

	row.addCell(journals.makeText('main_details_'+DODO.journalLines,journals.makeDetails(line, 0)),'details');
	row2.addCell(journals.makeText('vat1_details_'+DODO.journalLines,journals.makeDetails(line, 1)),'details');
	row3.addCell(journals.makeText('vat2_details_'+DODO.journalLines,journals.makeDetails(line, 2)),'details');
	
	row2.className="vat";
	row2.addCell(journals.makeText('vat1_account'));
	row2.addCell(journals.makeText('vat1_debet'));
	row2.addCell(journals.makeText('vat1_credit'));
	
	row3.className="vat";
	row3.addCell(journals.makeText('vat2_account'));
	row3.addCell(journals.makeText('vat2_debet'));
	row3.addCell(journals.makeText('vat2_credit'));
	
	var cell = journals.makeAccountSelect()
	if (line) {
	    var line_id = document.createElement("input");
	    line_id.type = "hidden";
	    line_id.name = "journal_operations[" + DODO.journalLines+"][id]";
	    line_id.value = line.id;
	    cell.appendChild(line_id);
	}
	var vat_account_id = $("<input type='hidden'>")[0];
	vat_account_id.name = "journal_operations[" + DODO.journalLines+"][vat_account_id]";
	vat_account_id.id = "vat_account_" + DODO.journalLines;
	cell.appendChild(vat_account_id);

	row.addCell(cell);
	row.addCell(journals.makeDebet());
	row.addCell(journals.makeCredit());
	row.addCell(journals.makeText('balance'));
	row.addCell(journals.makeText('in'));
	row.addCell(journals.makeText('out'));
	row.addCell(journals.makeAmount(line?line.vat:''));
	row.addCell(journals.makeVat(line?line.vat:''));
	row.addCell(journals.makeCarSelect());
	row.addCell(journals.makeProjectSelect());

	if (line) {
	    amount = line.amount;
	    $("#account_"+ DODO.journalLines)[0].value = line.account_id;
	    $("#dynfield_1_"+ DODO.journalLines)[0].value = amount<0?-amount:0;
	    $("#dynfield_2_"+ DODO.journalLines)[0].value = amount>0?amount:0;
	    $("#car_"+ DODO.journalLines)[0].value = line.car_id;
	    $("#project_"+ DODO.journalLines)[0].value = line.project_id;
	    journals.doDisable(DODO.journalLines);
	}
	DODO.journalLines++;
	stripe('#operations_table');
	if (!line) 
	{
	    journals.update();
	}
    },

    /**
       Add all predefined journal_operation lines from the DODO.journalOperationList array.
     */
    addPredefined: function(){
	lines = DODO.journalOperationList;
	for (var i=0; i<lines.length; i++) {
	    line = lines[i]['journal_operation'];
	    journals.addAccountLine(line);
	}
        journals.updateVat(false);
	journals.update();
        $('#journal_journal_date')[0].onchange = function (e) {
            journals.updateVat(true);
	    journals.update();
        }
    },
    
    columnOf: function(input)
    {
	return parseInt(input.id.split("_")[1]);
    },

    rowOf: function(input)
    {
	return parseInt(input.id.split("_")[2]);
    },

    /**
       Scroll with arrow keys
     */
    handleArrowKeys: function(evt){
	col_number=journals.columnOf(evt.target);
	row_number=journals.rowOf(evt.target);
	/*
	console.log("AAA");
	console.log(evt);
	console.log(evt.target);
	console.log(col_number);
	console.log(row_number);
	*/
		    
	switch (evt.keyCode) {
	case $.ui.keyCode.LEFT:
	    col_number--;
	    break;    
	    
	case $.ui.keyCode.UP:
	    row_number--;
	    break;    
	    
	case $.ui.keyCode.RIGHT:
	    col_number++;
	    break;    
	    
	case $.ui.keyCode.DOWN:
	    row_number++;
	    break;
	}
	
	el = $('#dynfield_' + col_number+'_' +row_number)[0];
	    
	if (el) {
	    el.focus();
	}
    },

    /**
       Update things in accordance with vat/detals tobble checkboxes.
     */
    toggleVisibility : function() {
	var box = $('#vat')[0];
	box.checked ? $('.vat').show():$('.vat').hide();
	var box2 = $('#details')[0];
	box2.checked ? $('.details').show():$('.details').hide();
    }
   
}