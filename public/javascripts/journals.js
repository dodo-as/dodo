/**
   Separate hournals namespace for journals specific scripting
 */
var journals = {

    /**
       Validate text entries. If something looks bad, disable submit button.
     */
    validate: function ()
    {
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
	for( var i =0; i<DODO.accountList.length; i++) {
	    if (DODO.accountList[i].account.id == id) {
		return DODO.accountList[i].account;
	    }
	}
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
    

    updateVat: function (reset_all) {
        for (var i=0; i < DODO.journalLines; i++)
            if (reset_all || $('#vatFactor_'+i)[0].value == "-1")
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
	    var account = journals.getAccount($('#dynfield_0_'+i)[0].value);
	    var vat_account;
            var vat_account_id;
            if (account.vat_account != undefined) {
                vat_account_id = account.vat_account.id;
                vat_account = account.vat_account.target_account;
            } else {
                vat_account_id = '';
                vat_account = {'name': '&lt;No VAT account&gt;', 'overridable': 0, 'id': ''};  
             }

	    $('#vat1_account_'+i)[0].innerHTML = journals.getAccount($('#dynfield_0_'+i)[0].value).name;
	    $('#vat2_account_'+i)[0].innerHTML = vat_account.name;
	    
	    var debet = parseFloatNazi($('#dynfield_2_' + i)[0].value);
	    var credit = parseFloatNazi($('#dynfield_1_' + i)[0].value);
	    var debet1 = $('#vat1_debet_'+i)[0];
	    var debet2 = $('#vat2_debet_'+i)[0];
	    var credit1 = $('#vat1_credit_'+i)[0];
	    var credit2 = $('#vat2_credit_'+i)[0];
	    credit1.innerHTML =debet1.innerHTML =credit2.innerHTML =debet2.innerHTML ='';
	    
	    var vatFactorInput = $('#vatFactor_'+i)[0];
	    var overridable = vat_account.overridable || account.vat_overridable;
	    
	    vatFactorInput.readOnly=!overridable;
	    
	    var vatFactor = 1.0 - 1.0/(1.0+0.01*parseFloatNazi(vatFactorInput.value));
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
	var sel = document.createElement("select");
	sel.name = "journal_operations[" + DODO.journalLines+"][account_id]";
	sel.id = "dynfield_0_"+ DODO.journalLines;
	
	for (var i=0; i<DODO.accountList.length; i++) {
	    sel.add(new Option("" + DODO.accountList[i].account.number + 
			       "-" +DODO.accountList[i].account.name,
			       DODO.accountList[i].account.id), null);
	}
	var line = DODO.journalLines;
	sel.onchange= function(){
	    journals.setDefaultVat(line);
	    journals.update();
	}
	
	return sel;
    },

    /**
       Return a DOM select node, populated with a list of all units that can be used for a transaction
     */
    makeUnitSelect: function () {
	var sel = document.createElement("select");
	sel.name = "journal_operations[" + DODO.journalLines+"][unit_id]";
	sel.id = "dynfield_3_"+ DODO.journalLines;
	
	for (var i=0; i<DODO.unitList.length; i++) {
	    sel.add(new Option(DODO.unitList[i].unit.name,
			       DODO.unitList[i].unit.id), null);
	}
	return sel;
    },

    /**
       Return a DOM select node, populated with a list of all projects that can be used for a transaction
     */
    makeProjectSelect: function () {
	var sel = document.createElement("select");
	sel.name = "journal_operations[" + DODO.journalLines+"][project_id]";
	sel.id = "dynfield_4_"+ DODO.journalLines;
	
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
	var account = journals.getAccount($('#dynfield_0_'+line)[0].value);
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

	$('#vatFactor_'+line)[0].value = percentage;

    },

    /**
       Check if either debet or credit column should be disabled to
       make it impossible to enter both a credit and debet amount on
       the same line.
     */
    doDisable: function (row_number)
    {
	var debet = $('#dynfield_1_' + row_number)[0];
	var credit = $('#dynfield_2_' + row_number)[0];
	
	credit.disabled=false;
	debet.disabled=false;
	
	if (parseFloatNazi(debet.value) > 0.0) {
	    credit.disabled=true;
	}
	else if (parseFloatNazi(credit.value) > 0.0) {
	    debet.disabled=true;
	}
	
    },

    /**
       Returns a DOM node suitable for using as a debet input box.
     */
    makeDebet: function () {
	var res = document.createElement("input");
	res.type="text";
	res.name = "journal_operations[" + DODO.journalLines+"][debet]";
	res.id='dynfield_1_' + DODO.journalLines;
	res.setAttribute("autocomplete","off");
	
	var fun;
	eval("fun=function (event) {journals.handleArrowKeys(event,  1, " + DODO.journalLines + ");}");
	res.onkeypress=fun;
	
	var fun2;
	eval("fun2=function (event) {journals.doDisable(" + DODO.journalLines + ");journals.update();}");
	res.onkeyup = fun2;
	
	return res;
	
    },
    
    /**
       Returns a DOM node suitable for using as a credit input box.
     */
    makeCredit: function () {
	var res = document.createElement("input");
	res.type="text";
	res.name = "journal_operations[" + DODO.journalLines+"][credit]";
	res.id='dynfield_2_' + DODO.journalLines;
	res.setAttribute("autocomplete","off");
	
	var fun;
	eval("fun=function (event) {journals.handleArrowKeys(event,  2, " + DODO.journalLines + ");}");
	res.onkeypress=fun;
	
	var fun2;
	eval("fun2=function (event) {journals.doDisable(" + DODO.journalLines + ");journals.update();}");
	res.onkeyup = fun2;
	
	return res;
    },
    
    /**
       Returns a DOM node suitable for using as a vat input box.
     */
    makeVat: function (val) {
	var res = document.createElement("input");
	res.type="text";
	res.name = "journal_operations[" + DODO.journalLines+"][vat]";
	res.id='vatFactor_' + DODO.journalLines;
	res.value = val;

	res.onkeyup = journals.update;
	
	return res;
    },
    
    /**
       Returns a DOM node suitable for using as a text status field.
     */
    makeText: function(id, content) {
	var res = document.createElement("span");
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
	var vat_account_id = document.createElement("input");
	vat_account_id.type = "hidden";
	vat_account_id.name = "journal_operations[" + DODO.journalLines+"][vat_account_id]";
	vat_account_id.id = "vat_account_" + DODO.journalLines;
	cell.appendChild(vat_account_id);

	row.addCell(cell);
	row.addCell(journals.makeDebet());
	row.addCell(journals.makeCredit());
	row.addCell(journals.makeText('balance'));
	row.addCell(journals.makeText('in'));
	row.addCell(journals.makeText('out'));
	row.addCell(journals.makeVat(line?line.vat:-1));
	row.addCell(journals.makeUnitSelect());
	row.addCell(journals.makeProjectSelect());

	if (line) {
	    amount = line.amount;
	    $("#dynfield_0_"+ DODO.journalLines)[0].value = line.account_id;
	    $("#dynfield_1_"+ DODO.journalLines)[0].value = amount<0?-amount:0;
	    $("#dynfield_2_"+ DODO.journalLines)[0].value = amount>0?amount:0;
	    $("#dynfield_3_"+ DODO.journalLines)[0].value = line.unit_id;
	    $("#dynfield_4_"+ DODO.journalLines)[0].value = line.project_id;
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
    
    /**
       Scroll with arrow keys
     */
    handleArrowKeys: function(evt, col_number, row_number) {
	evt = (evt) ? evt : ((window.event) ? event : null);
	if (evt) {
	    var el=null;
	    
	    switch (evt.keyCode) {
	    case 37:
		/*
		  left
		*/
		col_number--;
		break;    
		
	    case 38:
		/*
		  up
		*/
		row_number--;
		break;    
		
	    case 39:
		/*
		  right
		*/
		col_number++;
		break;    
		
	    case 40:
		/*
		  down
	    */
		row_number++;
		break;
		
	    }
	    
	    el = $('#dynfield_' + col_number+'_' +row_number)[0];
	    
	    if (el) {
		el.focus();
	    }
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