import TomSelect from "tom-select";
document.addEventListener("turbo:load", function () {
  if (document.getElementById("job_type_ids_option")) {
    if (!document.getElementById("job_type_ids_option").tomselect) {
      new TomSelect("#job_type_ids_option", {});
    }
  }
});
