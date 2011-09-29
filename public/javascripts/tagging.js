/**
 * @author Andrew
 */

var docRoot = document.getElementById("web_root").getTitle();
var requests = [];
var loading_image = getLoading();

function add_tag(tags, insert_id, debt_id){
	var data = { 'debt_id' : debt_id, 'tags' : tags };
	ondone = function(data){
		
		var window = document.getElementById(insert_id);
		window.setStyle('display',"none");
		
		
		var tag = document.createElement('span');
		tag.setInnerFBML(data);
		window.getParentNode().insertBefore(tag, window);
	}
	execute_request(docRoot+'/debts/tag',data, insert_id, ondone);
}

function delete_tag(tag_id, debt_id){
	var data = { 'debt_id' : debt_id, 'tag_id' : tag_id };
	done = function(data){
			var tag = document.getElementById('tag_span_'+tag_id);
			tag.getParentNode().removeChild(tag);
			removeLoading();
	}
	execute_request(docRoot+'/debts/delete_tag',data,'tag_span_'+tag_id,done);
}

function getLoading(){
	var element = document.createElement("img");
	element.setSrc(docRoot+'/images/loading.gif');
	element.setStyle('width', "16px");
	element.setStyle('height',"16px");
	element.setId('loading');
	return element;
}

function removeLoading(){
	document.getElementById(target).setStyle('display',"none");
	var loading = document.getElementById('loading');
	loading.getParentNode().removeChild(loading);	
}

function execute_request(url, data, target, done){
	if(target in requests)
		requests[target].abort();
	
	var xhr = new Ajax();
	xhr.responseType = Ajax.FBML
	
	if (done == null) {
		done = function(data){
			removeLoading();
		}
	}
	xhr.ondone = done;
	
	xhr.onerror = function(data){
		removeLoading();
		dialog = new Dialog(DIALOG.DIALOG_POP)
		dialog.showMessage("Tagging Error", data);
	}
	
	xhr.post(url, data);
	
	document.getElementById(target).appendChild(loading_image);
	requests[target] = xhr;
}