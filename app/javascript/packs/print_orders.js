window.changeOtherQuality = function() {
    var other = document.getElementById("other_quality");
    other.checked = true;
    other.value = document.getElementById("input_other_quality").value;
};

window.changeOtherFilament = function() {
    var other2 = document.getElementById("other_filament");
    other2.checked = true;
    other2.value = document.getElementById("input_other_filament").value;
};

window.change_color = function(radio) {
    if (radio.checked && radio.id === "Acrylic") {
        document.getElementById("color_form").style.display = 'block';
    } else {
        document.getElementById("color_form").style.display = 'none';
    }
};

window.checkFile = function(yourForm) {

    var file = yourForm.elements['print_order[final_file]'].value;

    if(file != ""){
        yourForm.submit();
    } else {
        if(confirm("Do you want to continue without adding a file ?")) {
            yourForm.submit();
        } else {
            return;
        }
    }
};