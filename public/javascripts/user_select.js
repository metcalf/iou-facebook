/**
 * @author Andrew
 */

var DOC_ROOT = document.getElementById("web_root").getTitle();
var delete_image_path = DOC_ROOT + "/images/dele.gif";
amount_mode = 'manual';
blur_func = function() {
				setSplitAmounts();
			};

/*
	**USER EVENT METHODS**
*/

function attach(){
	var inputs = document.getElementById("debt_form").getElementsByTagName("input")

	for(var i=0; i < inputs.length; i++){
		if ((inputs[i].getClassName() == "inputtext typeahead_placeholder") ||
				(inputs[i].getClassName() == "inputtext")) {
			inputs[i].addEventListener("blur", updated, false);
			inputs[i].addEventListener("focus", clear, false);
			inputs[i].setId(inputs[i].getName());
			
			insert = document.getElementById(inputs[i].getName() + "_insert");
			if(insert.getTitle() == "")
				insert.setTitle("0");
			
		}
	}
}

function clear(evt){
	document.getElementById(evt.target.getId()).setValue("");
	evt.target.setValue("");
}

function updated(evt, name, target){
	var target = evt.target
	var prefix = target.getName();
	
	var nameVal = target.getValue();
	var idname = prefix + "_val";
	var idVal = document.getElementById("debt_form").serialize()[idname];
	if (idVal == null || idVal == "" || nameVal == "") {
		return;
	}
	
	var insert = document.getElementById(prefix + "_insert");
	var num = parseInt(insert.getTitle());
	
	// Iterate over the existing values to check for duplicates and deletions, 
	// if the element was deleted, undelete
	// if it is a duplicate, just return
	var pos = getSelection(prefix,idVal);
	if (pos != -1) {
		var deleted = document.getElementById(prefix+"_data["+pos+"]"+"[deleted]");
		if(deleted != null){
			deleted.getParentNode().setStyle('display','');
			deleted.getParentNode().removeChild(deleted);
		}
		return;
	}

	addRow(nameVal, idVal, "", prefix);
}

/*
	**ROW OPERATION METHODS**
*/

function addRow(nameVal, idVal, amountVal, prefix){
	
	var insert = document.getElementById(prefix + "_insert");
	
	var num = parseInt(insert.getTitle());
	
	var amountName = prefix+"_data["+num+"]"+"[amount]";
	var idName 	   = prefix+"_data["+num+"]"+"[selection_id]";
	
	var row = document.createElement("tr");
	row.setClassName("selected_item_row");
	
	var left = document.createElement("td");
	left.setClassName("left");
	var remove = document.createElement("img");
	remove.setSrc(delete_image_path);
	remove.addEventListener("click", removeRow, false);
	var name = document.createElement("span");
	name.setTextValue(nameVal);
	var item_id = document.createElement("input");
	item_id.setType("hidden");
	item_id.setId(idName);
	item_id.setName(idName);
	item_id.setValue(idVal);
	
	var center = document.createElement("td");
	center.setClassName("center");
	var label = document.createElement("label");
	label.setTextValue("Amount($):")
	
	var right = document.createElement("td");
	right.setClassName("right");
	var amount = document.createElement("input");
	amount.setType("text");
	amount.setName(amountName);
	amount.setId(amountName);
	amount.setValue(amountVal);
	
	left.appendChild(remove);
	left.appendChild(name);
	left.appendChild(item_id);
	center.appendChild(label);
	right.appendChild(amount);
	row.appendChild(left);
	row.appendChild(center);
	row.appendChild(right);
	insert.appendChild(row);
	
	insert.setTitle((num+1)+'');
	
	if (amount_mode == 'split') {
		amount.addEventListener('blur',blur_func);
		setSplitAmounts();
	}
}

// Removes a row from the list that is not in the database
function removeRow(evt){
	var parent = evt.target.getParentNode().getParentNode();
	parent.getParentNode().removeChild(parent);
}

// Removes a row from the list that is in the database by hiding it
// and flagging it for permanent removal
function deleteRow(id){
	var row = document.getElementById(id);
	row.setStyle('display','none');
	
	var deleted = document.getElementById(id+"[deleted]");
	if (deleted == null) {
		deleted = document.createElement('input');
		row.appendChild(deleted);
	}

	deleted.setType('hidden');
	deleted.setName(id+"[deleted]");
	deleted.setId(id+"[deleted]");
	deleted.setValue('true');
}

/*
   GETTER METHODS
*/

// Returns the position number of the row if selected
// otherwise returns -1
// Note, this will also return deleted elements
function getSelection(prefix, id){
	var element;
	
	var insert = document.getElementById(prefix + '_insert');
    var count = parseInt(insert.getTitle());
    // If no debts are selected, return false
    if (isNaN(count)) 
        return -1;

    for (var i = 0; i < count; i++) {
        element = document.getElementById(prefix + "_data[" + i + "][selection_id]");
		if(element != null && id == parseInt(element.getValue()))
			return i;
    }
    
    return -1;
}

function getRowValue(prefix, rowNumber){
	var element = document.getElementById(prefix+"_data["+rowNumber+"][amount]");
	if (element != null) {
		amount = parseFloat(element.getValue());
		if (isNaN(amount)) 
			return 0;
		else 
			return amount;
	} else {
		return 0;
	}
}

function getSum(prefix){
	var element;
	var insert = document.getElementById(prefix + '_insert');
    var count = parseInt(insert.getTitle());
    
    var i;
    var amount = 0;
    var currAmount;
    
    for (i = 0; i < count; i++) {
		element = document.getElementById(prefix + "_data[" + i + "][amount]");
        if (element != null) {
			currAmount = parseFloat(element.getValue());
			var deleted = document.getElementById(prefix + "_data[" + i + "]" + "[deleted]");
			if (!isNaN(currAmount) && deleted == null) 
				amount = amount + currAmount;
		}
    }
    
    return amount;
}

// Counts the number of selected rows
function getCount(prefix){
	var amountElement;
	var deleted;
	var insert = document.getElementById(prefix + '_insert');
    var num = parseInt(insert.getTitle());
	
	var count = 0;
	for(var i=0;i<=num;i++){
		amountElement = document.getElementById(prefix+"_data["+i+"]"+"[amount]");
		if (amountElement != null) {
			deleted = document.getElementById(prefix+"_data["+i+"]"+"[deleted]");
			if(deleted == null){
				count += 1;
			}	
		}
	}
	return count;
}

/*
	SETTER METHODS
*/

function setAll(prefix, num, value){
	var amountElement;
	var deleted;
	for(var i=0;i<=num;i++){
		amountElement = document.getElementById(prefix+"_data["+i+"]"+"[amount]");
		if (amountElement != null) {
			deleted = document.getElementById(prefix+"_data["+i+"]"+"[deleted]");
			if(deleted == null){
				amountElement.setValue(value);	
			}
		}
	}
}

function setSplitAmounts(){
	var amountElement;
	var debNum =  parseInt(document.getElementById("debtor_selector_insert").getTitle());
	var credNum = parseInt(document.getElementById("creditor_selector_insert").getTitle());
	var amount = roundNumber(getSum("creditor_selector") / getCount("debtor_selector"),3);
	
	for(var i=0;i<=debNum;i++){
		amountElement = document.getElementById("debtor_selector_data["+i+"]"+"[amount]");
		if (amountElement != null) {
			amountElement.setValue(amount);
		}
	}
}

function setEntryMode(mode){
	amount_mode = mode;
	var debNum =  parseInt(document.getElementById("debtor_selector_insert").getTitle());
	var credNum = parseInt(document.getElementById("creditor_selector_insert").getTitle());
	if(mode == 'split'){
		var data = roundNumber(getSum("creditor_selector") / getCount("debtor_selector"),2);
		
		creditFunc = function(item, data){
			item.addEventListener('blur',blur_func);
		};
		debitFunc = function(item, data){
			item.setValue(data);
			item.addEventListener('blur',blur_func);
		};
	} else if (mode == 'manual'){
		var data = null;
		creditFunc = debitFunc = function(item, data){
			item.purgeEventListeners('blur');
		};
	}
	
	for(var i=0;i<=debNum;i++){
		var amountElement = document.getElementById("debtor_selector_data["+i+"]"+"[amount]");
		if (amountElement != null) {
			debitFunc(amountElement, data);
		}
	}
	for(var i=0;i<=credNum;i++){
		var amountElement = document.getElementById("creditor_selector_data["+i+"]"+"[amount]");
		if (amountElement != null) {
			creditFunc(amountElement, data);
		}
	}
}

function setRowValue(prefix, rowNumber, amount){
	var element = document.getElementById(prefix+"_data["+rowNumber+"][amount]");
	if (element != null) {
		element.setValue(amount);
	}
}

function roundNumber(num, dec){
    var result = Math.round(num * Math.pow(10, dec)) / Math.pow(10, dec);
    return result;
}

attach();