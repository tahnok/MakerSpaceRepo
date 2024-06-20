import TomSelect from "tom-select";
import Rails from "@rails/ujs";

document.addEventListener("turbo:load", function () {
  const elements = document.querySelectorAll("[data-show], [data-hide]");
  for (let i = 0; i < elements.length; i++) {
    elements[i].addEventListener("change", function () {
      const selector =
        this.getAttribute("data-show") || this.getAttribute("data-hide");
      const show = this.getAttribute("data-show") != null;
      const hide = this.getAttribute("data-hide") != null;
      const checked = this.checked;

      if (checked && (show || hide)) {
        document.querySelector(selector).style.display = show
          ? "block"
          : "none";
      }
    });

    if (elements[i].checked) {
      elements[i].dispatchEvent(new Event("change"));
    }
  }

  const programSelect = document.getElementById("user_program");
  if (programSelect && !programSelect.tomselect) {
    new TomSelect(programSelect, {
      maxItems: 1,
      maxOptions: null,
      searchOnKeyUp: true,
    });
  }
  // Disable all program options by default
  // this is a non-live NodeList, we store it for later use
  const optgroups = Array.from(programSelect.querySelectorAll("optgroup"));
  for (let i = 0; i < optgroups.length; i++) {
    //optgroups[i].setAttribute("disabled", "")
  }
  programSelect.tomselect.clear();
  programSelect.tomselect.sync();

  const facultySelect = document.getElementById("user_faculty");
  if (facultySelect) {
    facultySelect.addEventListener("change", function () {
      programSelect.tomselect.clear(); // Clear chosen program
      // Remove all possible options
      let removeGroups = programSelect.getElementsByTagName("optgroup");
      while (removeGroups[0]) {
        // Live NodeList
        removeGroups[0].remove();
      }
      // Add allowed programs
      let target_label = facultySelect.value;
      for (let i = 0; i < optgroups.length; i++) {
        let option = optgroups[i];
        if (option.getAttribute("label") == target_label)
          programSelect.appendChild(option);
      }

      programSelect.tomselect.clearOptions(); // Clear chosen program
      programSelect.tomselect.sync();
    });
  }

  const staffRoleButtons = document.querySelectorAll(".role-button");
  const staffSpaceChanger = document.getElementById("staff-space-changer");
  if (staffRoleButtons) {
    staffRoleButtons.forEach((button) => {
      button.addEventListener("click", (e) => {
        if (e.target.value === "regular_user") {
          staffSpaceChanger.style.display = "none";
        } else {
          staffSpaceChanger.style.display = "block";
        }
      });
    });
  }

  const fileInputs = document.querySelectorAll(".key-cert-file");
  fileInputs.forEach((fileInput) => {
    fileInput.addEventListener("change", (e) => {
      const form = document.getElementById(e.target.id + "_form");
      const uploadedFile = fileInput.files[0];
      const url = form.getAttribute("action");
      const authToken = form[1].value;

      if (uploadedFile && uploadedFile.type === "application/pdf") {
        const formData = new FormData();
        formData.append(e.target.id, uploadedFile);
        formData.append("authenticity_token", authToken);

        Rails.ajax({
          url: url,
          type: "PATCH",
          data: formData,
          success: function (data) {
            document.getElementById(e.target.id + "_show").style.display =
              "none";
            document.getElementById(e.target.id + "_hide").style.display =
              "block";
          },
          error: function (data) {
            alert(
              "Something went wrong when uploading the file, please try again later"
            );
          },
        });
      } else {
        alert("Please attach a pdf file only");
      }
    });
  });
});
