import TomSelect from 'tom-select';

window.showPass = function () {
    document.getElementById("password_repo_field").style.display = 'block'
};

window.hidePass = function () {
    document.getElementById("change_pass").style.display = 'none';
    document.getElementById("password_repo_field").style.display = 'none';
};
window.togglePass = function () {
    var x = document.getElementById("password_repo_field")
    if (x.style.display === 'none') {
        x.style.display = 'block'
    } else {
        x.style.display = 'none'
    }
}

document.addEventListener("DOMContentLoaded", function () {
    if (document.getElementById("search_users_add")) {
        console.log("Solved;")
        new TomSelect("#search_users_add", {
            searchField: ['name'],
            valueField: 'id',
            labelField: 'name',
            maxOptions: 5,
            searchOnKeyUp: true,
        })
    }
    if (document.getElementById("search_users_remove")) {
        new TomSelect("#search_users_remove", {
            searchField: ['name'],
            valueField: 'id',
            labelField: 'name',
            maxOptions: null,
            searchOnKeyUp: true,
        })
    }
    if (document.getElementById("search_project_proposals")) {
        new TomSelect("#search_project_proposals", {
            searchField: ['name'],
            valueField: 'id',
            labelField: 'name',
            maxOptions: null,
            searchOnKeyUp: true,
        })
    }
});

