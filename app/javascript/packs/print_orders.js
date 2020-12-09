window.changeOtherQuality = function() {
    let other = document.getElementById("other_quality");
    other.checked = true;
    other.value = document.getElementById("input_other_quality").value;
};

window.changeOtherFilament = function() {
    let other2 = document.getElementById("other_filament");
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

document.addEventListener("turbolinks:load", () => {
        let acrylic = document.getElementsByClassName("acrylic");
        let show = false;
        for (let i = 0; i < acrylic.length; i++) {
            if (acrylic[i].checked == true) {
                show = true;
            }
        }
        if (show == true) {
            document.getElementById("color_form").style.display = 'block';
        } else if(acrylic.length > 0) {
            document.getElementById("color_form").style.display = 'none';
        }

});

window.checkFile = function(yourForm) {

    let file = document.getElementById("print_order_final_file").files;

    let checked = true;
    for (x of file) {
        if (x.name == "") {
            checked = false;
        }
    }

    if(checked === true) {
        yourForm.submit();
    } else {
        if(confirm("Do you want to continue without adding a file ?")) {
            yourForm.submit();
        } else {
            return;
        }
    }
};

window.addEventListener('resize', function() {
    var progresses = document.querySelectorAll('.progress-row');
    [].forEach.call(progresses, function(progress) {
        if (window.innerWidth <= 720) {
            progress.classList.add('progress-tracker--vertical');
        } else {
            progress.classList.remove('progress-tracker--vertical');
        }
    });
}, false);