import TomSelect from "tom-select";
if (!document.getElementById("user_dashboard_select").tomsselect) {
  new TomSelect("#user_dashboard_select", {
    searchField: ["name"],
    valueField: "id",
    labelField: "name",
    options: [],
    maxOptions: 5,
    searchPlaceholder: "Choose User...",
    searchOnKeyUp: true,
    load: function (type, callback) {
      if (type.length < 2) {
        return;
      } else {
        let url = "/staff_dashboard/populate_users?search=" + type;
        fetch(url)
          .then((response) => response.json())
          .then((data) => {
            callback(
              data.users.map((user) => {
                return { id: user.username, name: user.name };
              })
            );
          });
      }
    },
    shouldLoad: function (type) {
      return type.length > 2;
    },
  });
}
let form = document.getElementById("sign_in_user_fastsearch");
form.onsubmit = function () {
  document.getElementById("sign_in_user_fastsearch_username").value = [
    document.getElementById("user_dashboard_select").value,
  ];
  form.submit();
};
