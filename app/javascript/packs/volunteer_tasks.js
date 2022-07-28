document.addEventListener("turbolinks:load", () => {
    window.addEventListener('load', function () {
        var forms = document.getElementsByClassName('needs-validation');
        var validation = Array.prototype.filter.call(forms, function (form) {
            form.addEventListener('submit', function (event) {
                if (form.checkValidity() === false) {
                    event.preventDefault();
                    event.stopPropagation();
                }
                form.classList.add('was-validated');
            }, false);
        });
    }, false);
    if (document.getElementById("task_certifications")){
        new TomSelect("#task_certifications", {
            plugins: ['remove_button'],
            maxItems: null
        })
    }
    if (document.getElementById("volunteer_id")){
        new TomSelect("#volunteer_id", {
            plugins: ['remove_button'],
            maxItems: null
        })
    }
    if (document.getElementById("staff_id")){
        new TomSelect("#staff_id", {
            plugins: ['remove_button'],
            maxItems: null
        })
    }
    
});
