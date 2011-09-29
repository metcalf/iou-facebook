var DOC_ROOT = document.getElementById("web_root").getTitle();
var payment_dialog = null;

function get_edit_dialog(insert_element, other_user_id){
	if (payment_dialog != null) 
        return;
    
	put_loading(insert_element);
	
    var url = DOC_ROOT + "/payments/edit";
    var title = "Record a Payment";
    var ajax = new Ajax();
    ajax.responseType = Ajax.FBML;
    
    ajax.ondone = function(data){
        payment_dialog = new Dialog(Dialog.DIALOG_POP);
        var insert = document.getElementById('loading');
        insert.getParentNode().removeChild(insert);
        payment_dialog.onconfirm = function(){
            document.getElementById('debt_form').submit();
        }
        payment_dialog.oncancel = function(){
            payment_dialog = null;
        }
        payment_dialog.showChoice("Payment Editor", data, "Save");
    }
    ajax.onerror = function(data){
        payment_dialog = new Dialog(Dialog.DIALOG_POP);
        var insert = document.getElementById('loading');
        insert.getParentNode().removeChild(insert);
        payment_dialog.showMessage("Payment Editor Error", data);
    }
    
    ajax.post(url, {'start' : 1, 'other_user_id' : other_user_id});
}

function put_loading(insert_element){
    var element = document.createElement("img");
    element.setSrc(DOC_ROOT + '/images/loading.gif');
    element.setStyle('width', "16px");
    element.setStyle('height', "16px");
    element.setId('loading');
	
	insert_element.appendChild(element);
}

function start_edit_dialog(){
    if (payment_dialog == null) {
		payment_dialog = new Dialog(Dialog.DIALOG_POP);
		payment_dialog.onconfirm = function(){
			document.getElementById('debt_form').submit();
		}
		payment_dialog.oncancel = function(){
			payment_dialog = null;
		}
		payment_dialog.showChoice("Payment Editor", edit_payments_fbml, "Save");
	}
}

function unhide_name_edit(){
	var name_wrapper = document.getElementById("friend-name-wrapper");
	
	if (name_wrapper.getStyle('display') != "none") {
		name_wrapper.setStyle("display", "none");
		document.getElementById("friend-selector-wrapper").setStyle("display", "inline");
		document.getElementById("friend-selector-wrapper").getFirstChild().focus();
		
	}
}

function set_edit_values(data){
	var name_fbml = friend_name['e'+data['id']];
	var name_wrapper = document.getElementById("friend-name-wrapper");
	
	document.getElementById("friend-selector-wrapper").setStyle("display","none");
	name_wrapper.setStyle("display","inline");
	name_wrapper.getFirstChild().setInnerFBML(name_fbml);
	
	if(data['direction'] == 'payor')
		document.getElementById("payor_radio").setChecked(true);
	else
		document.getElementById("payee_radio").setChecked(true);
		
	document.getElementById("payment_amount").setValue(data['amount'])
	document.getElementById("payment_notes").setValue(data['notes'])
	document.getElementById("payment_id").setValue(data['id'])
	
	document.getElementById("payment_date_1i").setSelectedIndex(data['year']);
	document.getElementById("payment_date_2i").setSelectedIndex(data['month']);
	document.getElementById("payment_date_3i").setSelectedIndex(data['day']);
}

function delete_payment(id, url){
    var dialog = new Dialog(Dialog.DIALOG_POP);
    dialog.onconfirm = function(){
        document.setLocation(url+'/' + id);
    }
    dialog.showChoice("Delete", "Are you sure you want to delete?");
}
