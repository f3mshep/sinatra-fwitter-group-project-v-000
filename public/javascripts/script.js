$(document).ready(function(){
  $("#showme").hide()
	$("#show").click(function(){
	 $("#showme").show("fast");
	});


	$(function(){
    $("#modal-launcher, #modal-background, #modal-close").click(function() {
        $("#modal-content, #modal-background").toggleClass("active");
    });
});

	$(function(){
    $("#modal-launcher, #modal-background, #modal-close").click(function() {
        $("#modal-content, #modal-background").toggleClass("active");
    });
});
	    });
function countChar(val) {
	var len = val.value.length;
		if (len >= 150) {
		  val.value = val.value.substring(0, 150);
		} else {
		  $('#charNum').text(150 - len);
		  }
		};
